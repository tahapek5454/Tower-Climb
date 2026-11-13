class_name ShopMenu
extends UiScreen
## Elmas mağazası (yalnız ana menüden açılır): başlık + bakiye, kategori sekmeleri, solda canlı karakter
## önizlemesi, sağda kaydırılabilir ürün listesi, altta tuş ipucu ve Geri. Klavye: ←/→ sekme, ↑/↓ ürün,
## Enter/Space al ya da kuşan, Esc geri. Listede odaktaki kozmetik önizlemede satın almadan denenir.
## Satın alma/kuşanma Shop autoload'unda (kaydeder, Events yayınlar); bu ekran yalnız çağırır ve
## görünümü yeniler. Tuning.SHOP_ENABLED kapalıysa main bu ekranı hiç kurmaz.

const CARD_WIDTH: float = 920.0
const LIST_HEIGHT: float = 392.0
const TITLE_FONT_SIZE: int = 28
## Kart diğer menülerden daha opak: geniş liste arkadaki oyun dünyasıyla karışmasın.
const CARD_ALPHA: float = 0.95
const HINT_FONT_SIZE: int = 12
const ROW_STAGGER: float = 0.03
const ROW_SLIDE_TIME: float = 0.22
const ROW_SLIDE: float = 14.0

var _balance: ShopBalance
var _tabs: ShopTabs
var _preview: ShopPreview
var _scroll: ScrollContainer
var _lists: Array[VBoxContainer] = []
var _active: int = 0


func _init() -> void:
	super()
	var card_style: StyleBoxFlat = UiStyle.panel_style(PADDING)
	card_style.bg_color.a = CARD_ALPHA
	card.add_theme_stylebox_override(&"panel", card_style)
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 12)
	content.add_child(_build_header())
	var titles: Array[String] = []
	for category: StringName in ShopCatalog.CATEGORIES:
		titles.append(ShopCatalog.CATEGORY_TITLES[category])
	_tabs = ShopTabs.new(titles)
	_tabs.tab_selected.connect(func(index: int) -> void: _select_tab(index, true))
	content.add_child(_tabs)
	content.add_child(_build_body())
	content.add_child(_build_footer())
	closed.connect(func() -> void: _preview.deactivate())


func open() -> void:
	if is_open:
		return
	_balance.snap()
	_preview.activate()
	first_focus = null
	super()
	_select_tab(_active, false)


## Etkin sekmenin listesindeki satırlar.
func rows() -> Array[ShopRow]:
	var result: Array[ShopRow] = []
	for child: Node in _lists[_active].get_children():
		result.append(child as ShopRow)
	return result


func preview() -> ShopPreview:
	return _preview


func active_tab() -> int:
	return _active


## ←/→ sekme değiştirir (odak listede kalır).
func _input(input_event: InputEvent) -> void:
	if not is_open:
		return
	var direction: int = 0
	if input_event.is_action_pressed(&"ui_left"):
		direction = -1
	elif input_event.is_action_pressed(&"ui_right"):
		direction = 1
	if direction != 0:
		get_viewport().set_input_as_handled()
		_select_tab(ShopLabels.wrap_index(_active, direction, _lists.size()), true)


func _build_header() -> Control:
	var header := HBoxContainer.new()
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT)
	title.text = "MAĞAZA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_balance = ShopBalance.new()
	_balance.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_balance)
	return header


func _build_body() -> Control:
	var body := HBoxContainer.new()
	body.add_theme_constant_override(&"separation", 18)
	var stage := PanelContainer.new()
	var stage_style: StyleBoxFlat = UiStyle.button_style(Color(1.0, 1.0, 1.0, 0.03), Color(UiStyle.BORDER, 0.25), 1, 8.0, 8.0)
	stage.add_theme_stylebox_override(&"panel", stage_style)
	_preview = ShopPreview.new()
	stage.add_child(_preview)
	body.add_child(stage)
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size.y = LIST_HEIGHT
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_style_scrollbar()
	var lists := VBoxContainer.new()
	lists.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(lists)
	for category: StringName in ShopCatalog.CATEGORIES:
		lists.add_child(_build_list(category))
	body.add_child(_scroll)
	return body


func _build_list(category: StringName) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override(&"separation", 6)
	list.visible = false
	for item: Dictionary in ShopCatalog.items_in(category):
		var row := ShopRow.new(item)
		row.activated.connect(_on_row_activated)
		row.focus_entered.connect(func() -> void: _preview.preview_item(row.item_id))
		list.add_child(row)
	_lists.append(list)
	return list


func _build_footer() -> Control:
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override(&"separation", 16)
	var hint: Label = UiStyle.label(HINT_FONT_SIZE, UiStyle.TEXT_DIM)
	hint.text = "←  →  sekme      ↑  ↓  seç      Enter  al / kuşan      Esc  geri"
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(hint)
	var back := UiButton.new("Geri", false, true)
	back.custom_minimum_size.x = 140.0
	back.pressed.connect(_on_cancel)
	back.focus_entered.connect(func() -> void: _preview.preview_item(&""))
	footer.add_child(back)
	return footer


## Sekmeyi açar: listesini gösterir, satırları yeniler ve sırayla kaydırarak getirir; odak kuşanılı
## ürüne (yoksa ilk satıra) sessizce gider.
func _select_tab(index: int, animate: bool) -> void:
	var changed: bool = index != _active
	_active = index
	for i: int in _lists.size():
		_lists[i].visible = i == _active
	_tabs.set_active(_active, animate and changed)
	if animate and changed:
		AudioManager.play(&"ui_hover", 1.12, Tuning.UI_HOVER_DB)
	_scroll.scroll_vertical = 0
	var target: ShopRow = null
	var category: StringName = ShopCatalog.CATEGORIES[_active]
	var index_in_list: int = 0
	for row: ShopRow in rows():
		row.refresh()
		row.slide_in(index_in_list * ROW_STAGGER, ROW_SLIDE, ROW_SLIDE_TIME)
		index_in_list += 1
		if target == null or (ShopCatalog.is_slot(category) and row.item_id == Shop.equipped(category)):
			target = row
	if target != null:
		first_focus = target
		target.focus_silently()
		_preview.preview_item(target.item_id)


func _on_row_activated(row: ShopRow) -> void:
	var id: StringName = row.item_id
	match ShopLabels.action_for(Shop.status(id)):
		ShopLabels.Action.BUY:
			if Shop.buy(id):
				row.celebrate(true)
				_preview.celebrate(true, _colors_of(row.item))
				AudioManager.play(&"shop_buy", 1.0, Tuning.SFX_SHOP_BUY_DB)
			else:
				_deny(row)
		ShopLabels.Action.EQUIP:
			if Shop.equip(id):
				row.celebrate(false)
				_preview.celebrate(false, _colors_of(row.item))
				AudioManager.play(&"shop_equip", 1.0, Tuning.SFX_SHOP_EQUIP_DB)
		ShopLabels.Action.DENY:
			_deny(row)
	for other: ShopRow in rows():
		other.refresh()
	_preview.preview_item(id)


func _deny(row: ShopRow) -> void:
	row.shake()
	AudioManager.play(&"shop_deny", 1.0, Tuning.SFX_SHOP_DENY_DB)


## Kutlama parıltısının renkleri: renkli ürünlerde kendi renkleri + altın; diğerlerinde varsayılan.
func _colors_of(item: Dictionary) -> Array[Color]:
	var colors: Array[Color] = []
	if item.has("color"):
		colors.append(item["color"])
		colors.append(item.get("color2", item["color"]))
		colors.append(UiStyle.COMBO)
		colors.append(UiStyle.TEXT)
	return colors


## İnce, yuvarlak, soluk kaydırma çubuğu (başarımlar ekranıyla aynı).
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
