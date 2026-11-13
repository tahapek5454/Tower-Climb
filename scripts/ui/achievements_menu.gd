class_name AchievementsMenu
extends UiScreen
## Başarımlar ekranı (ana menüden açılır): başlık, "7 / 15" sayacı, kaydırılabilir satır listesi
## (açıklar altın tikli, kilitliler soluk kilitli), Geri. Ok tuşlarıyla satırlar arasında gezilir
## (liste otomatik kayar); Esc / Geri ana menüye döner. Durumu açılırken kayıttan okur.

const CARD_WIDTH: float = 460.0
const LIST_HEIGHT: float = 340.0
const TITLE_FONT_SIZE: int = 28
const COUNT_FONT_SIZE: int = 15

var _count: Label
var _scroll: ScrollContainer
var _list: VBoxContainer


func _init() -> void:
	super()
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 8)
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "BAŞARIMLAR"
	content.add_child(title)
	_count = UiStyle.label(COUNT_FONT_SIZE, UiStyle.COMBO, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_count)
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size.y = LIST_HEIGHT
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_style_scrollbar()
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override(&"separation", 4)
	_scroll.add_child(_list)
	content.add_child(_scroll)
	var back := UiButton.new("Geri", true, true)
	back.pressed.connect(_on_cancel)
	content.add_child(back)
	first_focus = back


func open() -> void:
	if is_open:
		return
	_rebuild(SaveData.load_achievements())
	_scroll.scroll_vertical = 0
	super()


func _rebuild(unlocked: Dictionary) -> void:
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_count.text = "%d / %d" % [AchievementRules.count_unlocked(unlocked), AchievementRules.total()]
	var first_row: Control = null
	for def: Dictionary in AchievementRules.all_defs():
		var row := AchievementRow.new(def, unlocked.has(String(def["id"])))
		_list.add_child(row)
		if first_row == null:
			first_row = row
	first_focus = first_row if first_row != null else first_focus


## İnce, yuvarlak, soluk kaydırma çubuğu (varsayılan tema yerine).
func _style_scrollbar() -> void:
	var bar: VScrollBar = _scroll.get_v_scroll_bar()
	var track := StyleBoxFlat.new()
	track.bg_color = UiStyle.TRACK
	track.set_corner_radius_all(3)
	track.content_margin_left = 3.0
	track.content_margin_right = 3.0
	bar.add_theme_stylebox_override(&"scroll", track)
	for state: StringName in [&"grabber", &"grabber_highlight", &"grabber_pressed"]:
		var grabber := StyleBoxFlat.new()
		grabber.bg_color = Color(UiStyle.ACCENT, 0.55)
		grabber.set_corner_radius_all(3)
		grabber.content_margin_left = 3.0
		grabber.content_margin_right = 3.0
		bar.add_theme_stylebox_override(state, grabber)
