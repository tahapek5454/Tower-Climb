class_name ShopBalance
extends HBoxContainer
## Mağazanın elmas bakiyesi: simge + sayı. Bakiye değişince sayı yeni değere sayarak iner/çıkar,
## harcamada sayının altında "−80" yazısı belirip aşağı süzülerek söner. Değeri GameState/Events'ten okur.

const FONT_SIZE: int = 24
const COUNT_TIME: float = 0.6
const FLOAT_FONT_SIZE: int = 16
const FLOAT_DROP: float = 18.0
const FLOAT_TIME: float = 0.9
const ICON_SCALE: float = 0.9

var _value: Label
var _icon: Control
var _float: Label
var _shown: int = 0
var _count_tween: Tween
var _float_tween: Tween


func _init() -> void:
	add_theme_constant_override(&"separation", 6)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon = Control.new()
	_icon.custom_minimum_size = Vector2(DiamondArt.HALF_WIDTH * 2.0 + 4.0, 30.0) * ICON_SCALE
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.draw.connect(func() -> void:
		var middle: float = (DiamondArt.TOP + DiamondArt.TIP) * 0.5 * ICON_SCALE
		DiamondArt.draw(_icon, _icon.size * 0.5 - Vector2(0.0, middle), ICON_SCALE))
	add_child(_icon)
	_value = UiStyle.label(FONT_SIZE, DiamondArt.LIGHT)
	_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_value)
	# Süzülen yazı: düz bir Control'ün çocuğu (kapsayıcı yerleşimine girmez).
	var anchor := Control.new()
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(anchor)
	_float = UiStyle.label(FLOAT_FONT_SIZE, DiamondArt.MID, HORIZONTAL_ALIGNMENT_RIGHT)
	_float.size = Vector2(80.0, 22.0)
	_float.modulate.a = 0.0
	anchor.add_child(_float)


func _ready() -> void:
	_set_shown(GameState.diamonds)
	Events.diamonds_changed.connect(_on_diamonds_changed)


## Ekran açılırken animasyonsuz güncel değer.
func snap() -> void:
	if _count_tween != null:
		_count_tween.kill()
	_set_shown(GameState.diamonds)


func shown_value() -> int:
	return _shown


func _set_shown(value: int) -> void:
	_shown = value
	_value.text = str(value)


func _on_diamonds_changed(total: int) -> void:
	var change: int = total - _shown
	if change == 0 or not is_visible_in_tree():
		_set_shown(total)
		return
	if _count_tween != null:
		_count_tween.kill()
	_count_tween = create_tween()
	_count_tween.tween_method(func(v: float) -> void: _set_shown(roundi(v)), float(_shown), float(total), COUNT_TIME) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if change < 0:
		_show_spent(-change)


func _show_spent(amount: int) -> void:
	if _float_tween != null:
		_float_tween.kill()
	_float.text = "−%d" % amount
	_float.position = Vector2(-_float.size.x, FONT_SIZE * 0.9)
	_float.modulate.a = 1.0
	_float_tween = create_tween().set_parallel()
	_float_tween.tween_property(_float, ^"position:y", _float.position.y + FLOAT_DROP, FLOAT_TIME) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_float_tween.tween_property(_float, ^"modulate:a", 0.0, FLOAT_TIME).set_delay(FLOAT_TIME * 0.35)
