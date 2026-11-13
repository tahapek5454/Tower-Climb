class_name ReviveHeart
extends Control
## Devam kartının ortasındaki büyük kalp: çift vuruşla atar, çevresindeki halka kalan süreyle erir
## (süre azalınca halka kızarır, kalp hızlanır). Kabulde kalp parlayıp büyür, halka dalgası ve
## kıvılcımlar saçılır; redde kalp solup küçülür. Tıklanınca `clicked` (kart kabul sayar).

signal clicked

const RING_RADIUS: float = 64.0
const RING_WIDTH: float = 6.0
const RING_POINTS: int = 72
const HEART_SCALE: float = 2.5
## Çift vuruş: normal ve acil döngü süresi (s), büyüme oranı.
const BEAT_TIME: float = 1.0
const BEAT_TIME_URGENT: float = 0.55
const BEAT_SCALE: float = 0.12
## Kalbin arkasındaki yumuşak hâle (kenara doğru solan daire).
const GLOW_RADIUS: float = 72.0
const GLOW_ALPHA: float = 0.32
## Kabul patlaması: büyüme, dalga yarıçapı çarpanı, kıvılcım sayısı ve uzaklığı.
const BURST_GROW: float = 0.6
const BURST_WAVE: float = 1.9
const SPARKS: int = 14
const SPARK_DISTANCE: float = 110.0
const SPARK_SIZE: float = 4.5
## Ret: kalbin küçülme oranı.
const FADE_SHRINK: float = 0.25

## Halkanın kalan oranı (1 = dolu).
var ratio: float = 1.0:
	set(value):
		ratio = value
		queue_redraw()

var _beat_phase: float = 0.0
## Kabul patlaması (0..1; -1 yok) ve ret sönmesi (0..1).
var _burst: float = -1.0
var _fade: float = 0.0
var _tween: Tween


func _init() -> void:
	custom_minimum_size = Vector2.ONE * (RING_RADIUS + RING_WIDTH) * 2.0
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_on_gui_input)


## Yeni teklif: dolu halka, normal kalp.
func reset() -> void:
	if _tween != null:
		_tween.kill()
	_burst = -1.0
	_fade = 0.0
	_beat_phase = 0.0
	ratio = 1.0


## Kabul: kalp parlayıp büyür, dalga ve kıvılcımlar saçılır.
func burst(duration: float) -> void:
	_restart_tween().tween_method(_set_burst, 0.0, 1.0, duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Ret / süre doldu: kalp solar ve küçülür.
func fade(duration: float) -> void:
	_restart_tween().tween_method(_set_fade, 0.0, 1.0, duration)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var cycle: float = BEAT_TIME_URGENT if ReviveRules.is_urgent(ratio) else BEAT_TIME
	_beat_phase = fmod(_beat_phase + delta / cycle, 1.0)
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size * 0.5
	var pulse: float = maxf(sin(_beat_phase * TAU * 4.0), 0.0) if _beat_phase < 0.5 else 0.0
	var alive: float = 1.0 - _fade
	_draw_glow(center, GLOW_RADIUS * (1.0 + 0.12 * pulse), Color(HeartArt.GLOW, GLOW_ALPHA * alive * (0.7 + 0.3 * pulse)))
	_draw_ring(center, alive)
	if _burst >= 0.0:
		_draw_burst(center)
	var scale_now: float = HEART_SCALE * (1.0 + BEAT_SCALE * pulse)
	var fill: Color = HeartArt.RED
	if _burst >= 0.0:
		scale_now = HEART_SCALE * (1.0 + BURST_GROW * _burst)
		fill = HeartArt.RED.lerp(HeartArt.SHINE, minf(_burst * 2.0, 1.0))
		fill.a = 1.0 - smoothstep(0.45, 1.0, _burst)
	elif _fade > 0.0:
		scale_now *= 1.0 - FADE_SHRINK * _fade
		fill = HeartArt.RED.lerp(HeartArt.EMPTY, _fade * 0.85)
		fill.a = 1.0 - _fade * 0.6
	if fill.a > 0.01:
		HeartArt.draw(self, center, scale_now, fill)


## Kalan süre halkası: soluk iz + saat yönünde eriyen yay (yuvarlak uçlu).
func _draw_ring(center: Vector2, alive: float) -> void:
	draw_arc(center, RING_RADIUS, 0.0, TAU, RING_POINTS, Color(UiStyle.TRACK, UiStyle.TRACK.a * alive), RING_WIDTH, true)
	if ratio <= 0.0 or _burst >= 0.0:
		return
	var urgency: float = clampf(1.0 - ratio / Tuning.REVIVE_URGENT_RATIO, 0.0, 1.0)
	var color: Color = UiStyle.ACCENT.lerp(HeartArt.RED, urgency)
	color.a *= alive
	var start: float = -PI * 0.5
	var finish: float = start + TAU * ratio
	draw_arc(center, RING_RADIUS, start, finish, maxi(int(RING_POINTS * ratio), 2), color, RING_WIDTH, true)
	for angle: float in [start, finish]:
		draw_circle(center + Vector2.from_angle(angle) * RING_RADIUS, RING_WIDTH * 0.5, color, true, -1.0, true)


## Kabul: genişleyip solan halka dalgası ve iki renkli kıvılcımlar.
func _draw_burst(center: Vector2) -> void:
	var wave_alpha: float = 1.0 - _burst
	draw_arc(center, RING_RADIUS * (1.0 + (BURST_WAVE - 1.0) * _burst), 0.0, TAU, RING_POINTS,
			Color(HeartArt.GLOW, 0.8 * wave_alpha), RING_WIDTH * (1.0 - 0.6 * _burst), true)
	_draw_glow(center, GLOW_RADIUS * (1.0 + _burst), Color(HeartArt.SHINE, 0.6 * wave_alpha))
	for i: int in SPARKS:
		var angle: float = TAU * i / SPARKS + 0.2
		var reach: float = RING_RADIUS * 0.6 + SPARK_DISTANCE * _burst * (0.75 + 0.25 * float(i % 3) / 2.0)
		var color: Color = UiStyle.COMBO if i % 2 == 0 else HeartArt.GLOW
		draw_circle(center + Vector2.from_angle(angle) * reach, SPARK_SIZE * (1.0 - 0.5 * _burst),
				Color(color, wave_alpha), true, -1.0, true)


func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	draw_texture_rect(SoftTextures.dot(), Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false, color)


func _set_burst(value: float) -> void:
	_burst = value
	queue_redraw()


func _set_fade(value: float) -> void:
	_fade = value
	queue_redraw()


func _restart_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	return _tween


func _on_gui_input(input_event: InputEvent) -> void:
	var button := input_event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		accept_event()
		clicked.emit()
