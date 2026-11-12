class_name UiSlider
extends MiniSlider
## Menü kaydırıcısı: MiniSlider'ın klavye odağı alan, ok tuşlarıyla (sol/sağ) ayarlanan hâli.
## Fare üstüne gelince odak alır. Sürükleme/ok tuşu bırakılınca value_committed (kayıt için) yayınlanır.

const KEY_STEP: float = 0.05
const HEIGHT: float = 30.0
const TRACK_WIDTH: float = 4.0


func _init() -> void:
	super()
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(160.0, HEIGHT)
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _gui_input(input_event: InputEvent) -> void:
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
	var filled_x: float = lerpf(left, right, value)
	draw_line(Vector2(left, y), Vector2(right, y), UiStyle.TRACK, TRACK_WIDTH, true)
	draw_line(Vector2(left, y), Vector2(filled_x, y), UiStyle.ACCENT, TRACK_WIDTH, true)
	var center := Vector2(filled_x, y)
	if has_focus():
		draw_arc(center, knob * 1.45, 0.0, TAU, 24, UiStyle.ACCENT, 2.0, true)
	draw_circle(center, knob * (1.15 if _hover or _dragging else 1.0), UiStyle.TEXT, true, -1.0, true)
