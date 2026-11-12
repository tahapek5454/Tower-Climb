class_name MiniSlider
extends Control
## İnce, kodla çizilen kaydırıcı (0..1). Sürüklerken value_changed, bırakınca value_committed
## (kayıt için). Klavye odağı almaz.

signal value_changed(value: float)
signal value_committed(value: float)

var value: float = 0.5:
	set(new_value):
		value = clampf(new_value, 0.0, 1.0)
		queue_redraw()
var _dragging: bool = false
var _hover: bool = false


func _init() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func() -> void: _hover = true; queue_redraw())
	mouse_exited.connect(func() -> void: _hover = false; queue_redraw())


func _gui_input(input_event: InputEvent) -> void:
	var click := input_event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT:
		_dragging = click.pressed
		if click.pressed:
			_set_from_x(click.position.x)
		else:
			value_committed.emit(value)
		accept_event()
	var motion := input_event as InputEventMouseMotion
	if motion != null and _dragging:
		_set_from_x(motion.position.x)
		accept_event()


func _set_from_x(x: float) -> void:
	var knob: float = _knob_radius()
	value = inverse_lerp(knob, size.x - knob, x)
	value_changed.emit(value)


func _knob_radius() -> float:
	return size.y * 0.32


func _draw() -> void:
	var knob: float = _knob_radius()
	var y: float = size.y * 0.5
	var left: float = knob
	var right: float = size.x - knob
	var filled_x: float = lerpf(left, right, value)
	draw_line(Vector2(left, y), Vector2(right, y), RadioStyle.TRACK, 2.0, true)
	draw_line(Vector2(left, y), Vector2(filled_x, y), RadioStyle.ACCENT, 2.0, true)
	draw_circle(Vector2(filled_x, y), knob * (1.15 if _hover or _dragging else 1.0), RadioStyle.TEXT, true, -1.0, true)
