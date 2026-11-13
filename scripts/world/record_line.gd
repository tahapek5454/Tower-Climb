class_name RecordLine
extends Node2D
## Rekor çizgisi: kayıtlı en yüksek katın hizasında, kule içinde ince altın kesik çizgi (+ silik hâle,
## solda küçük yıldız ve kat sayısı). Tur başındaki rekora göre konur, tur içinde yer değiştirmez.
## Oyuncu çizgiyi geçince (iniş ya da roketle) parlayıp söner, boyunca altın parıltı saçılır; tur başına bir kez.

const GOLD := UiStyle.COMBO
const OUTLINE := UiStyle.OUTLINE
const STAR_RADIUS: float = 7.0
const STAR_INNER_RATIO: float = 0.5
const STAR_TEXT_GAP: float = 5.0

var best_floor: int = 0

var _half_width: float
var _time: float = 0.0
## Parlama: 0 = sakin, 1 = tam parlak; solma: 1 = görünür, 0 = kayboldu.
var _flash: float = 0.0
var _visible_amount: float = 1.0
var _crossed: bool = false
var _halo: Sprite2D
var _sparks: CPUParticles2D


func _ready() -> void:
	_half_width = Tuning.TOWER_WIDTH * 0.5
	position = Vector2(0.0, RecordLineRules.line_y(best_floor))
	_halo = Sprite2D.new()
	_halo.texture = SoftTextures.dot()
	_halo.material = SoftTextures.additive()
	_halo.scale = Vector2(_half_width * 2.0, Tuning.RECORD_LINE_HALO_HEIGHT) / float(SoftTextures.DOT_SIZE)
	add_child(_halo)
	_sparks = _make_sparks()
	add_child(_sparks)
	Events.floor_changed.connect(_on_floor_changed)
	_on_floor_changed(GameState.floor_number)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	var alpha: float = _alpha()
	_halo.modulate = Color(GOLD, Tuning.RECORD_LINE_HALO_ALPHA * alpha)


func _draw() -> void:
	var alpha: float = _alpha()
	if alpha <= 0.0:
		return
	var width: float = lerpf(Tuning.RECORD_LINE_WIDTH,
			Tuning.RECORD_LINE_WIDTH * Tuning.RECORD_LINE_FLASH_WIDTH_SCALE, _flash)
	var color := Color(GOLD, alpha)
	_draw_dashes(width, color)
	_draw_label(alpha)


## Uçları yuvarlak kesik çizgi; baştan ve sondan yarım boşlukla başlar (kenarlarda yarım kesik kalmasın).
func _draw_dashes(width: float, color: Color) -> void:
	var span: float = Tuning.RECORD_LINE_DASH + Tuning.RECORD_LINE_GAP
	var count: int = maxi(floori((_half_width * 2.0 + Tuning.RECORD_LINE_GAP) / span), 1)
	var total: float = count * span - Tuning.RECORD_LINE_GAP
	var x: float = -total * 0.5
	var cap: float = width * 0.5
	for i: int in count:
		var from := Vector2(x + cap, 0.0)
		var to := Vector2(x + Tuning.RECORD_LINE_DASH - cap, 0.0)
		draw_line(from, to, color, width, true)
		draw_circle(from, cap, color)
		draw_circle(to, cap, color)
		x += span


## Solda: altın yıldız + kat sayısı (yazı lacivert dış çizgili; çizginin biraz üstünde).
func _draw_label(alpha: float) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: int = Tuning.RECORD_LINE_LABEL_SIZE
	var text: String = str(best_floor)
	var base := Vector2(-_half_width + 12.0, -Tuning.RECORD_LINE_LABEL_GAP)
	var star_center: Vector2 = base + Vector2(STAR_RADIUS, -size * 0.35)
	_draw_star(star_center, alpha)
	var text_pos: Vector2 = base + Vector2(STAR_RADIUS * 2.0 + STAR_TEXT_GAP, 0.0)
	draw_string_outline(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, 4, Color(OUTLINE, alpha))
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, Color(GOLD, alpha))


func _draw_star(center: Vector2, alpha: float) -> void:
	var points := PackedVector2Array()
	for i: int in 10:
		var radius: float = STAR_RADIUS * (1.0 if i % 2 == 0 else STAR_INNER_RATIO)
		var angle: float = -PI * 0.5 + i * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, Color(GOLD, alpha))
	# Köşeleri yumuşatan ince dış hat.
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, Color(OUTLINE, alpha * 0.8), 1.5, true)


## Görünürlük: nefes alan taban alfa; parlarken yükselir, sönerken sıfıra iner.
func _alpha() -> float:
	var breath: float = 1.0 + Tuning.RECORD_LINE_BREATH_AMOUNT * sin(_time * Tuning.RECORD_LINE_BREATH_SPEED)
	var base: float = Tuning.RECORD_LINE_ALPHA * breath
	return clampf(lerpf(base, Tuning.RECORD_LINE_FLASH_ALPHA, _flash), 0.0, 1.0) * _visible_amount


func _on_floor_changed(floor_number: int) -> void:
	if _crossed or not RecordLineRules.is_crossed(best_floor, floor_number):
		return
	_crossed = true
	Events.record_line_crossed.emit(best_floor)
	_sparks.restart()
	var time: float = Tuning.RECORD_LINE_CELEBRATE_TIME
	var tween := create_tween()
	tween.tween_property(self, ^"_flash", 1.0, time * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"_visible_amount", 0.0, time * 0.8) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Parıltılar sönene kadar düğüm kalır.
	tween.tween_interval(_sparks.lifetime)
	tween.tween_callback(queue_free)


## Çizgi boyunca yukarı süzülen altın parıltılar (tek seferlik).
func _make_sparks() -> CPUParticles2D:
	var sparks := CPUParticles2D.new()
	sparks.texture = SoftTextures.dot()
	sparks.material = SoftTextures.additive()
	sparks.one_shot = true
	sparks.emitting = false
	sparks.explosiveness = 0.7
	sparks.amount = Tuning.RECORD_LINE_SPARKS
	sparks.lifetime = 0.9
	sparks.local_coords = false
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparks.emission_rect_extents = Vector2(_half_width, 3.0)
	sparks.direction = Vector2.UP
	sparks.spread = 35.0
	sparks.gravity = Vector2(0.0, 40.0)
	sparks.initial_velocity_min = 40.0
	sparks.initial_velocity_max = 150.0
	sparks.damping_min = 40.0
	sparks.damping_max = 80.0
	sparks.scale_amount_min = 0.06
	sparks.scale_amount_max = 0.16
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.97, 0.85, 1.0))
	ramp.add_point(0.3, Color(GOLD, 0.9))
	ramp.set_color(2, Color(GOLD, 0.0))
	sparks.color_ramp = ramp
	return sparks
