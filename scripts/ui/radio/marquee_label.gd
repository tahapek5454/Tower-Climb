class_name MarqueeLabel
extends Control
## Tek satırlık yazı; sığmıyorsa yavaşça kayar (başta ve sonda bekleyerek ileri-geri).

const SPEED: float = 18.0
const PAUSE: float = 1.4

var text: String = "":
	set(value):
		text = value
		_time = 0.0
		queue_redraw()
var font_size: int = 11
var color: Color = Color.WHITE
var _time: float = 0.0


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if _overflow() > 0.0:
		_time += delta
		queue_redraw()


func _overflow() -> float:
	var font: Font = get_theme_default_font()
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x - size.x


## Kayma: bekle → sona kay → bekle → başa kay (döngü).
func _offset() -> float:
	var overflow: float = _overflow()
	if overflow <= 0.0:
		return 0.0
	var travel: float = overflow / SPEED
	var cycle: float = fmod(_time, (PAUSE + travel) * 2.0)
	if cycle < PAUSE:
		return 0.0
	if cycle < PAUSE + travel:
		return -(cycle - PAUSE) * SPEED
	if cycle < PAUSE * 2.0 + travel:
		return -overflow
	return -overflow + (cycle - PAUSE * 2.0 - travel) * SPEED


func _draw() -> void:
	var font: Font = get_theme_default_font()
	var baseline: float = (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(_offset(), baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
