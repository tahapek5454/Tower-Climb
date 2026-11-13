class_name DiamondCounter
extends HBoxContainer
## Elmas simgesi + sayı (HUD ve ana menü). Değeri kendisi GameState/Events'ten okur; elmas alınınca
## simge ve sayı kısa bir an büyür.

const PULSE_SCALE: float = 1.45
const PULSE_TIME: float = 0.3

var _icon: Control
var _value: Label
var _icon_scale: float
var _pulse: Tween


## font_size: sayının yazı boyutu; simge buna göre ölçeklenir.
func _init(font_size: int) -> void:
	add_theme_constant_override(&"separation", 5)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_scale = font_size / 26.0
	_icon = Control.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.custom_minimum_size = Vector2(DiamondArt.HALF_WIDTH * 2.0 + 4.0, font_size * 1.2) * \
			Vector2(_icon_scale, 1.0)
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon.draw.connect(_draw_icon)
	add_child(_icon)
	_value = UiStyle.label(font_size, DiamondArt.LIGHT)
	_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_value)


func _ready() -> void:
	_set_value(GameState.diamonds)
	Events.diamonds_changed.connect(_on_diamonds_changed)


func shown_value() -> String:
	return _value.text


func _set_value(total: int) -> void:
	_value.text = str(total)


func _on_diamonds_changed(total: int) -> void:
	_set_value(total)
	if _pulse != null:
		_pulse.kill()
	for node: Control in [_icon, _value]:
		node.pivot_offset = node.size * 0.5
		node.scale = Vector2.ONE * PULSE_SCALE
	_pulse = create_tween().set_parallel()
	for node: Control in [_icon, _value]:
		_pulse.tween_property(node, ^"scale", Vector2.ONE, PULSE_TIME) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _draw_icon() -> void:
	# Taşın dikey ortası (TOP..TIP) simge kutusunun ortasına gelsin.
	var middle: float = (DiamondArt.TOP + DiamondArt.TIP) * 0.5 * _icon_scale
	DiamondArt.draw(_icon, _icon.size * 0.5 - Vector2(0.0, middle), _icon_scale)
