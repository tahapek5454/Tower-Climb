class_name PowerupRow
extends VBoxContainer
## HUD'da süreli bir güçlendirmenin satırı: ayırıcı + başlık + kalan süre çubuğu. Etki dışında gizli.

const FONT_SIZE: int = 13
const BAR_HEIGHT: float = 3.0

var _bar: Control
var _bar_color: Color
var _duration: float = 1.0
var _left: float = 0.0


func _init(caption: String, caption_color: Color, bar_color: Color) -> void:
	add_theme_constant_override(&"separation", 3)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var separator := HSeparator.new()
	separator.add_theme_color_override(&"separator", UiStyle.TRACK)
	add_child(separator)
	var label: Label = UiStyle.label(FONT_SIZE, caption_color)
	label.text = caption
	add_child(label)
	_bar = Control.new()
	_bar.custom_minimum_size.y = BAR_HEIGHT + 2.0
	_bar.draw.connect(_draw_bar)
	add_child(_bar)
	_bar_color = bar_color
	visible = false


## duration: kalan süre (s); çubuk dolu başlar.
func start(duration: float) -> void:
	_duration = maxf(duration, 0.01)
	_left = duration
	visible = true


func stop() -> void:
	visible = false


func _process(delta: float) -> void:
	if visible:
		_left = maxf(_left - delta, 0.0)
		_bar.queue_redraw()


func _draw_bar() -> void:
	var y: float = _bar.size.y * 0.5
	var width: float = _bar.size.x
	var ratio: float = clampf(_left / _duration, 0.0, 1.0)
	_bar.draw_line(Vector2(0.0, y), Vector2(width, y), UiStyle.TRACK, BAR_HEIGHT, true)
	_bar.draw_line(Vector2(0.0, y), Vector2(width * ratio, y), _bar_color, BAR_HEIGHT, true)
