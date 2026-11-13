class_name ShopTabs
extends Control
## Mağaza kategori sekmeleri: yan yana yazılar, seçilinin altında yumuşak turkuaz bir zemin ve çizgi
## (seçim değişince kayarak yer değiştirir). Sekmeler fareyle seçilir; klavye (←/→) ShopMenu'de.
## Sekmeler odak almaz: klavye odağı hep listede kalır.

signal tab_selected(index: int)

const FONT_SIZE: int = 15
const HEIGHT: float = 38.0
const SLIDE_TIME: float = 0.28
const BAR_HEIGHT: float = 3.0

var active: int = 0

var _row: HBoxContainer
var _buttons: Array[Button] = []
var _indicator: Control
var _from := Rect2()
var _to := Rect2()
var _t: float = 1.0:
	set(value):
		_t = value
		_indicator.queue_redraw()
var _tween: Tween


func _init(titles: Array[String]) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator = Control.new()
	_indicator.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator.draw.connect(_draw_indicator)
	add_child(_indicator)
	_row = HBoxContainer.new()
	_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_row.add_theme_constant_override(&"separation", 4)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.minimum_size_changed.connect(update_minimum_size)
	_row.sort_children.connect(func() -> void: _jump_to(active))
	add_child(_row)
	for i: int in titles.size():
		_row.add_child(_make_tab(titles[i], i))
	_apply_colors()


func _get_minimum_size() -> Vector2:
	return Vector2(_row.get_combined_minimum_size().x if _row != null else 0.0, HEIGHT)


## Seçili sekme; animate: gösterge kayarak gider.
func set_active(index: int, animate: bool = true) -> void:
	active = clampi(index, 0, _buttons.size() - 1)
	_apply_colors()
	if not animate or not is_inside_tree():
		_jump_to(active)
		return
	_from = _current_rect()
	_to = _tab_rect(active)
	if _tween != null:
		_tween.kill()
	_t = 0.0
	_tween = create_tween()
	_tween.tween_property(self, ^"_t", 1.0, SLIDE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func tab_count() -> int:
	return _buttons.size()


func _make_tab(title: String, index: int) -> Button:
	var tab := Button.new()
	tab.text = title
	tab.flat = true
	tab.focus_mode = Control.FOCUS_NONE
	tab.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab.add_theme_font_size_override(&"font_size", FONT_SIZE)
	var empty := StyleBoxEmpty.new()
	for state: StringName in [&"normal", &"hover", &"pressed", &"focus", &"hover_pressed"]:
		tab.add_theme_stylebox_override(state, empty)
	tab.pressed.connect(func() -> void:
		if index != active:
			tab_selected.emit(index))
	_buttons.append(tab)
	return tab


func _apply_colors() -> void:
	for i: int in _buttons.size():
		var color: Color = UiStyle.TEXT if i == active else UiStyle.TEXT_DIM
		for color_name: StringName in [&"font_color", &"font_pressed_color", &"font_focus_color"]:
			_buttons[i].add_theme_color_override(color_name, color)
		_buttons[i].add_theme_color_override(&"font_hover_color", UiStyle.TEXT)


func _jump_to(index: int) -> void:
	if _tween != null and _tween.is_running():
		_to = _tab_rect(active)
		return
	_from = _tab_rect(index)
	_to = _from
	_t = 1.0


func _tab_rect(index: int) -> Rect2:
	if index < 0 or index >= _buttons.size():
		return Rect2()
	var tab: Button = _buttons[index]
	return Rect2(tab.position + _row.position, tab.size)


func _current_rect() -> Rect2:
	return Rect2(_from.position.lerp(_to.position, _t), _from.size.lerp(_to.size, _t))


func _draw_indicator() -> void:
	var rect: Rect2 = _current_rect()
	if rect.size.x <= 0.0:
		return
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(UiStyle.ACCENT, 0.13)
	fill.set_corner_radius_all(UiStyle.CORNER_RADIUS)
	_indicator.draw_style_box(fill, rect)
	var bar_width: float = rect.size.x * 0.42
	var bar := Rect2(rect.position.x + (rect.size.x - bar_width) * 0.5, rect.end.y - BAR_HEIGHT - 2.0, bar_width, BAR_HEIGHT)
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = UiStyle.ACCENT
	bar_style.set_corner_radius_all(2)
	_indicator.draw_style_box(bar_style, bar)
