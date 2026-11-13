class_name AchievementRow
extends PanelContainer
## Başarım listesi satırı: solda durum simgesi (açık: altın tik, kilitli: soluk kilit), ortada başlık ve
## açıklama, sağda ödül (+N elmas). Kilitli satırlar soluk. Klavyeyle gezilebilmesi için odaklanabilir
## (odaktayken hafif turkuaz zemin); fare tekerleği üstündeyken kaydırmaya geçer.

const ICON_SIZE: float = 30.0

var unlocked: bool

var _icon: Control
var _style: StyleBoxFlat


func _init(def: Dictionary, p_unlocked: bool) -> void:
	unlocked = p_unlocked
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_PASS
	_style = UiStyle.button_style(Color(1.0, 1.0, 1.0, 0.04), Color(0.0, 0.0, 0.0, 0.0), 0, 12.0, 7.0)
	add_theme_stylebox_override(&"panel", _style)
	focus_entered.connect(func() -> void: _style.bg_color = UiStyle.BUTTON_FOCUS)
	focus_exited.connect(func() -> void: _style.bg_color = Color(1.0, 1.0, 1.0, 0.04))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	_icon = Control.new()
	_icon.custom_minimum_size = Vector2.ONE * ICON_SIZE
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.draw.connect(_draw_icon)
	row.add_child(_icon)
	var texts := VBoxContainer.new()
	texts.add_theme_constant_override(&"separation", -1)
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title: Label = UiStyle.label(16, UiStyle.TEXT if unlocked else UiStyle.TEXT_DIM)
	title.text = def["title"]
	texts.add_child(title)
	var desc: Label = UiStyle.label(12, UiStyle.TEXT_DIM if unlocked else Color(UiStyle.TEXT_DIM, 0.7))
	desc.text = def["desc"]
	texts.add_child(desc)
	row.add_child(texts)
	row.add_child(_build_reward(int(def["reward"])))


func _build_reward(amount: int) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override(&"separation", 3)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not unlocked:
		box.modulate.a = 0.5
	var label: Label = UiStyle.label(15, DiamondArt.LIGHT)
	label.text = "+%d" % amount
	box.add_child(label)
	var diamond := Control.new()
	diamond.custom_minimum_size = Vector2(20.0, 22.0)
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diamond.draw.connect(func() -> void: DiamondArt.draw(diamond, diamond.size * 0.5 - Vector2(0.0, 2.0), 0.65))
	box.add_child(diamond)
	return box


func _draw_icon() -> void:
	if unlocked:
		AchievementArt.draw_check(_icon, _icon.size * 0.5, 0.95)
	else:
		AchievementArt.draw_lock(_icon, _icon.size * 0.5, 1.0)
