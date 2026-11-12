class_name UiSlider
extends MiniSlider
## Menü kaydırıcısı: MiniSlider'ın klavye odağı alan, ok tuşlarıyla (sol/sağ) ayarlanan hâli.
## Fare üstüne gelince odak alır. Sürükleme/ok tuşu bırakılınca value_committed (kayıt için) yayınlanır.
## Kilitliyken (set_locked) düğme sıfıra kayar, çizgi söner ve kaydırıcı girişi yok sayar; gerçek `value`
## değişmez, kilit açılınca düğme yerine geri kayar (ör. "Tümünü sustur" açıkken ses kaydırıcıları).

const KEY_STEP: float = 0.05
const HEIGHT: float = 30.0
const TRACK_WIDTH: float = 4.0
const LOCK_TIME: float = 0.3

var locked: bool = false
## Kilit görünümü (0 = açık, 1 = kilitli, düğme sıfırda); animasyon için.
var _lock_t: float = 0.0:
	set(new_value):
		_lock_t = new_value
		queue_redraw()
var _lock_tween: Tween


func _init() -> void:
	super()
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(160.0, HEIGHT)
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


## Kilitler / açar. animate: düğme kayarak yer değiştirir.
func set_locked(is_locked: bool, animate: bool = true) -> void:
	locked = is_locked
	if _lock_tween != null:
		_lock_tween.kill()
	var target: float = 1.0 if is_locked else 0.0
	if not animate:
		_lock_t = target
		return
	_lock_tween = create_tween()
	_lock_tween.tween_property(self, ^"_lock_t", target, LOCK_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _gui_input(input_event: InputEvent) -> void:
	if locked:
		return
	var direction: float = 0.0
	if input_event.is_action_pressed(&"ui_left", true):
		direction = -1.0
	elif input_event.is_action_pressed(&"ui_right", true):
		direction = 1.0
	if direction != 0.0:
		value += direction * KEY_STEP
		value_changed.emit(value)
		value_committed.emit(value)
		accept_event()
		return
	super(input_event)


func _draw() -> void:
	var knob: float = _knob_radius()
	var y: float = size.y * 0.5
	var left: float = knob
	var right: float = size.x - knob
	var filled_x: float = lerpf(left, right, lerpf(value, 0.0, _lock_t))
	var fill_color: Color = UiStyle.ACCENT.lerp(UiStyle.DISABLED, _lock_t)
	var knob_color: Color = UiStyle.TEXT.lerp(UiStyle.TEXT_DIM, _lock_t * 0.8)
	draw_line(Vector2(left, y), Vector2(right, y), UiStyle.TRACK, TRACK_WIDTH, true)
	draw_line(Vector2(left, y), Vector2(filled_x, y), fill_color, TRACK_WIDTH, true)
	var center := Vector2(filled_x, y)
	if has_focus() and not locked:
		draw_arc(center, knob * 1.45, 0.0, TAU, 24, UiStyle.ACCENT, 2.0, true)
	var lively: bool = (_hover or _dragging) and not locked
	draw_circle(center, knob * (1.15 if lively else 1.0), knob_color, true, -1.0, true)
