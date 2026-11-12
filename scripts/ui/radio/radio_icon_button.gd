class_name RadioIconButton
extends Control
## Radyo panelinin küçük ikon düğmesi (kodla çizilir). Fare ile tıklanır; klavye odağı almaz
## (oyun klavyeyle oynanır). filled: dolu yuvarlak zemin (çal/duraklat gibi ana düğme).

signal pressed

var kind: StringName = &"play"
var filled: bool = false
var enabled: bool = true:
	set(value):
		enabled = value
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if value else Control.CURSOR_ARROW
		queue_redraw()
var _hover: bool = false


func _init(p_kind: StringName = &"play", p_size: float = 16.0, p_filled: bool = false) -> void:
	kind = p_kind
	filled = p_filled
	custom_minimum_size = Vector2.ONE * p_size
	size = custom_minimum_size
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func() -> void: _hover = true; queue_redraw())
	mouse_exited.connect(func() -> void: _hover = false; queue_redraw())


func set_kind(new_kind: StringName) -> void:
	kind = new_kind
	queue_redraw()


func _gui_input(input_event: InputEvent) -> void:
	var click := input_event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT and click.pressed and enabled:
		pressed.emit()
		accept_event()


func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.5
	if not enabled:
		RadioStyle.icon(self, kind, center, radius * 1.1, RadioStyle.DISABLED)
		return
	if filled:
		draw_circle(center, radius, RadioStyle.ACCENT.lightened(0.12) if _hover else RadioStyle.ACCENT, true, -1.0, true)
		RadioStyle.icon(self, kind, center + Vector2(radius * 0.06 if kind == &"play" else 0.0, 0.0),
				radius * 0.95, RadioStyle.ACCENT_DARK)
	else:
		if _hover:
			draw_circle(center, radius, Color(1.0, 1.0, 1.0, 0.08), true, -1.0, true)
		RadioStyle.icon(self, kind, center, radius * 1.1, RadioStyle.TEXT if _hover else RadioStyle.TEXT_DIM)
