class_name ShopRow
extends Control
## Mağaza listesinin bir satırı: simge, ad (+ renk örneği / seviye noktaları / stok), açıklama, fiyat
## (elmas simgeli) ve durum düğmesi ("Al", "Kuşan", "Kuşanıldı", "Tam", "Dolu"). Satırın tamamı tek
## düğme gibi davranır: fare üstünde hareket edince ya da ok tuşlarıyla odak alır, Enter/Space/tık ile
## `activated`. Gövde düz bir Control'ün içinde durur: sallanma ve büyüme animasyonlarını
## kapsayıcı (VBox) sıfırlamaz.

signal activated(row: ShopRow)

const ICON_SIZE: float = 44.0
const PILL_SIZE := Vector2(108.0, 34.0)
const PILL_FONT_SIZE: int = 14
const PIP_RADIUS: float = 4.5
const PIP_GAP: float = 13.0
const SHAKE_DISTANCE: float = 7.0
const SHAKE_TIME: float = 0.32
const POP_SCALE: float = 1.035
const POP_TIME: float = 0.35
const IDLE_FILL := Color(1.0, 1.0, 1.0, 0.04)

var item: Dictionary
var item_id: StringName
var status: ShopRules.Status = ShopRules.Status.UNKNOWN

var _body: PanelContainer
var _style: StyleBoxFlat
var _price_box: HBoxContainer
var _price: Label
var _pill: Control
var _pips: Control
var _pip_count: int = 0
var _pip_filled: int = 0
var _pip_pop: float = 0.0:
	set(value):
		_pip_pop = value
		if _pips != null:
			_pips.queue_redraw()
var _silent_focus: bool = false
var _anim: Tween


func _init(p_item: Dictionary) -> void:
	item = p_item
	item_id = item["id"]
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body = PanelContainer.new()
	_body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style = UiStyle.button_style(IDLE_FILL, Color(0.0, 0.0, 0.0, 0.0), 1, 10.0, 6.0)
	_body.add_theme_stylebox_override(&"panel", _style)
	_body.minimum_size_changed.connect(update_minimum_size)
	_body.resized.connect(func() -> void: _body.pivot_offset = _body.size * 0.5)
	add_child(_body)
	_build()
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_update_style)


func _get_minimum_size() -> Vector2:
	return _body.get_combined_minimum_size() if _body != null else Vector2.ZERO


## Ses çalmadan odak alır (sekme değişince ilk satır).
func focus_silently() -> void:
	_silent_focus = true
	grab_focus()
	_silent_focus = false


## Durumu Shop'tan yeniden okur (bakiye ya da sahiplik değişince).
func refresh() -> void:
	status = Shop.status(item_id)
	var shows_price: bool = ShopLabels.shows_price(status)
	_price_box.visible = shows_price
	if shows_price:
		_price.text = str(Shop.price(item_id))
		_price_box.modulate.a = 1.0 if status == ShopRules.Status.BUYABLE else 0.4
	var filled: int = _pip_value()
	if filled > _pip_filled and is_inside_tree():
		_pip_pop = 1.0
		create_tween().tween_property(self, ^"_pip_pop", 0.0, POP_TIME * 1.6) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_pip_filled = filled
	_update_style()
	_pill.queue_redraw()
	if _pips != null:
		_pips.queue_redraw()


## Sekme açılınca: sağdan kayarak belirir.
func slide_in(delay: float, distance: float, time: float) -> void:
	_restart_anim()
	_body.position.x = distance
	_body.modulate.a = 0.0
	_anim.set_parallel()
	_anim.tween_property(_body, ^"position:x", 0.0, time).set_delay(delay) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_anim.tween_property(_body, ^"modulate:a", 1.0, time).set_delay(delay)


## Yetmiyor / alınamaz: nazik yana sallanma.
func shake() -> void:
	_restart_anim()
	var steps: Array[float] = [SHAKE_DISTANCE, -SHAKE_DISTANCE * 0.7, SHAKE_DISTANCE * 0.4, -SHAKE_DISTANCE * 0.2, 0.0]
	for target: float in steps:
		_anim.tween_property(_body, ^"position:x", target, SHAKE_TIME / steps.size()) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Satın alma / kuşanma: kısa büyüme ve altın parlama.
func celebrate(strong: bool) -> void:
	_restart_anim()
	_body.scale = Vector2.ONE * (POP_SCALE if strong else lerpf(1.0, POP_SCALE, 0.5))
	_body.modulate = Color(1.25, 1.18, 0.95) if strong else Color(1.1, 1.1, 1.1)
	_anim.set_parallel()
	_anim.tween_property(_body, ^"scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_anim.tween_property(_body, ^"modulate", Color.WHITE, POP_TIME * 1.4)


func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion and not has_focus():
		grab_focus()
	var mouse := input_event as InputEventMouseButton
	if mouse != null and mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
		if not has_focus():
			grab_focus()
		activated.emit(self)
		accept_event()
	elif input_event.is_action_pressed(&"ui_accept"):
		activated.emit(self)
		accept_event()


func _build() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_child(row)
	var icon := Control.new()
	icon.custom_minimum_size = Vector2.ONE * ICON_SIZE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func() -> void: ShopIcons.draw(icon, item, icon.size * 0.5, 1.05))
	row.add_child(icon)
	row.add_child(_build_texts())
	row.add_child(_build_price())
	_pill = Control.new()
	_pill.custom_minimum_size = PILL_SIZE
	_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill.draw.connect(_draw_pill)
	row.add_child(_pill)


func _build_texts() -> Control:
	var texts := VBoxContainer.new()
	texts.add_theme_constant_override(&"separation", 0)
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := HBoxContainer.new()
	top.add_theme_constant_override(&"separation", 10)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title: Label = UiStyle.label(16, UiStyle.TEXT)
	title.text = item["title"]
	top.add_child(title)
	var category: StringName = item["category"]
	if category == ShopCatalog.UPGRADE or category == ShopCatalog.BOOST:
		_pip_count = ShopCatalog.max_level(item_id) if category == ShopCatalog.UPGRADE else Tuning.SHOP_BOOST_MAX_STOCK
		_pip_filled = _pip_value()
		_pips = Control.new()
		_pips.custom_minimum_size = Vector2(PIP_GAP * _pip_count + 4.0, 16.0)
		_pips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pips.draw.connect(_draw_pips)
		if category == ShopCatalog.BOOST:
			var caption: Label = UiStyle.label(11, UiStyle.TEXT_DIM)
			caption.text = "stok"
			caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			top.add_child(caption)
		top.add_child(_pips)
	texts.add_child(top)
	if item.has("desc"):
		var desc: Label = UiStyle.label(12, UiStyle.TEXT_DIM)
		desc.text = item["desc"]
		texts.add_child(desc)
	return texts


func _build_price() -> Control:
	_price_box = HBoxContainer.new()
	_price_box.add_theme_constant_override(&"separation", 2)
	_price_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_price_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price = UiStyle.label(17, DiamondArt.LIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_price.custom_minimum_size.x = 34.0
	_price_box.add_child(_price)
	var gem := Control.new()
	gem.custom_minimum_size = Vector2(20.0, 22.0)
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gem.draw.connect(func() -> void: DiamondArt.draw(gem, gem.size * 0.5 - Vector2(0.0, 2.0), 0.62))
	_price_box.add_child(gem)
	return _price_box


func _pip_value() -> int:
	if item["category"] == ShopCatalog.UPGRADE:
		return Shop.upgrade_level(item_id)
	if item["category"] == ShopCatalog.BOOST:
		return Shop.boost_stock(item_id)
	return 0


func _update_style() -> void:
	var focused: bool = has_focus()
	_style.bg_color = UiStyle.BUTTON_FOCUS if focused else IDLE_FILL
	if focused:
		_style.border_color = Color(UiStyle.ACCENT, 0.7)
	elif status == ShopRules.Status.EQUIPPED:
		_style.border_color = Color(UiStyle.COMBO, 0.35)
	else:
		_style.border_color = Color(0.0, 0.0, 0.0, 0.0)


func _on_focus_entered() -> void:
	_update_style()
	_pill.queue_redraw()
	if not _silent_focus:
		AudioManager.play(&"ui_hover", 1.0, Tuning.UI_HOVER_DB)


## Durum düğmesi: dolu turkuaz (Al), soluk (yetmiyor / dolu), turkuaz çerçeve (Kuşan), altın (Kuşanıldı / Tam).
func _draw_pill() -> void:
	var rect := Rect2(Vector2.ZERO, _pill.size)
	var fill: Color = UiStyle.BUTTON_IDLE
	var border := Color(0.0, 0.0, 0.0, 0.0)
	var text_color: Color = UiStyle.TEXT_DIM
	var check: bool = false
	match status:
		ShopRules.Status.BUYABLE:
			fill = UiStyle.ACCENT.lightened(0.15) if has_focus() else UiStyle.ACCENT
			text_color = UiStyle.TEXT_ON_ACCENT
		ShopRules.Status.TOO_EXPENSIVE:
			text_color = UiStyle.DISABLED
		ShopRules.Status.OWNED:
			fill = UiStyle.BUTTON_FOCUS if has_focus() else Color(0.0, 0.0, 0.0, 0.0)
			border = UiStyle.ACCENT
			text_color = UiStyle.ACCENT.lightened(0.2)
		ShopRules.Status.EQUIPPED, ShopRules.Status.MAXED:
			fill = Color(UiStyle.COMBO, 0.16)
			text_color = UiStyle.COMBO
			check = true
	var style: StyleBoxFlat = UiStyle.button_style(fill, border, 2 if border.a > 0.0 else 0)
	style.set_corner_radius_all(int(rect.size.y * 0.5))
	_pill.draw_style_box(style, rect)
	var text: String = ShopLabels.action_text(status)
	var font: Font = _pill.get_theme_default_font()
	var text_width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, PILL_FONT_SIZE).x
	var check_width: float = 15.0 if check else 0.0
	var x: float = (rect.size.x - text_width - check_width) * 0.5
	var baseline: float = (rect.size.y + font.get_ascent(PILL_FONT_SIZE) - font.get_descent(PILL_FONT_SIZE)) * 0.5
	if check:
		var c := Vector2(x + 5.0, rect.size.y * 0.5)
		_pill.draw_polyline(PackedVector2Array([c + Vector2(-4.0, 0.0), c + Vector2(-1.0, 3.5), c + Vector2(5.0, -4.0)]),
				text_color, 2.2, true)
	_pill.draw_string(font, Vector2(x + check_width, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1,
			PILL_FONT_SIZE, text_color)


## Seviye (altın) ya da stok (turkuaz) noktaları; yeni dolan nokta kısa bir an büyür.
func _draw_pips() -> void:
	var gold: bool = item["category"] == ShopCatalog.UPGRADE
	var color: Color = UiStyle.COMBO if gold else UiStyle.ACCENT
	var middle: float = _pips.size.y * 0.5
	for i: int in _pip_count:
		var center := Vector2(PIP_RADIUS + 2.0 + i * PIP_GAP, middle)
		if i < _pip_filled:
			var radius: float = PIP_RADIUS * (1.0 + (0.7 * _pip_pop if i == _pip_filled - 1 else 0.0))
			if i == _pip_filled - 1 and _pip_pop > 0.0:
				_pips.draw_circle(center, radius * 1.9, Color(color, 0.25 * _pip_pop), true, -1.0, true)
			_pips.draw_circle(center, radius, color, true, -1.0, true)
		else:
			_pips.draw_arc(center, PIP_RADIUS - 0.5, 0.0, TAU, 20, UiStyle.TRACK.lightened(0.3), 1.5, true)


func _restart_anim() -> void:
	if _anim != null:
		_anim.kill()
	_body.position = Vector2.ZERO
	_body.scale = Vector2.ONE
	_body.modulate = Color.WHITE
	_anim = create_tween()
