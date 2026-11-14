class_name VersionLabel
extends Label
## Ana menüde sol alt köşede silik sürüm yazısı (ör. "v1.0.0"); radyo panelinin altındaki boşlukta.
## Sürüm BuildInfo'dan (project.godot). ENABLED = false kaldırır.

const ENABLED: bool = true
const FONT_SIZE: int = 11
## Köşeden uzaklık (px, tasarım çözünürlüğünde).
const MARGIN := Vector2(10.0, 8.0)
const ALPHA: float = 0.7


func _init() -> void:
	text = BuildInfo.version_text()
	add_theme_font_size_override(&"font_size", FONT_SIZE)
	add_theme_color_override(&"font_color", UiStyle.TEXT_DIM)
	modulate.a = ALPHA
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.0
	anchor_right = 0.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	offset_left = MARGIN.x
	offset_bottom = -MARGIN.y
