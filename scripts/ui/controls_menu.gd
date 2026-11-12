class_name ControlsMenu
extends UiScreen
## Kontroller sayfası (salt okunur): tuş listesi, tuş kapaklarıyla. Ayarlar ekranından açılır;
## Esc / Geri ile ayarlara döner. Tuşlar project.godot'taki eylemlerle aynı olmalı.

const CARD_WIDTH: float = 420.0
const TITLE_FONT_SIZE: int = 26
const TIP_FONT_SIZE: int = 12
const KEY_SEPARATOR_TEXT: String = "/"

## [eylem, [[tuş, tuş], [alternatif tuşlar]...]] — gruplar "/" ile ayrılır, bir gruptaki tuşlar yan yana.
const ENTRIES: Array = [
	["Koş", [["←", "→"], ["A", "D"]]],
	["Zıpla", [["Space"], ["↑"], ["W"]]],
	["Duraklat", [["Esc"]]],
	["Yeniden başla (oyun sonu)", [["R"]]],
	["Sesi kapat / aç", [["M"]]],
	["Tam ekran", [["F11"], ["Alt", "Enter"]]],
	["Hata ayıklama paneli", [["F3"]]],
]


func _init() -> void:
	super()
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 9)
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "KONTROLLER"
	content.add_child(title)
	content.add_child(UiStyle.spacer(4.0))
	for entry: Array in ENTRIES:
		content.add_child(UiStyle.row(entry[0], _keys(entry[1])))
	content.add_child(UiStyle.spacer(4.0))
	var tip: Label = UiStyle.label(TIP_FONT_SIZE, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	tip.text = "Ne kadar hızlı koşarsan o kadar yükseğe zıplarsın.\nDuvara hızlı çarpınca seker, katları atlayınca kombo yaparsın."
	content.add_child(tip)
	var back := UiButton.new("Geri", true, true)
	back.pressed.connect(_on_cancel)
	content.add_child(back)
	first_focus = back


## Alternatif tuş gruplarını "/" ile ayırarak yan yana dizer.
func _keys(groups: Array) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override(&"separation", 5)
	box.alignment = BoxContainer.ALIGNMENT_END
	for group_index: int in groups.size():
		if group_index > 0:
			var separator: Label = UiStyle.label(13, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
			separator.text = KEY_SEPARATOR_TEXT
			box.add_child(separator)
		for key_text: String in groups[group_index]:
			box.add_child(UiStyle.key_cap(key_text))
	return box
