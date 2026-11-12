class_name CreatorBadge
extends Control
## Yapımcı kartı (ana menüde, sağ dış alanın altı; radyo panelinin simetriği). Bilgiler CreatorInfo'da.
## Bağlantılar tıklanınca tarayıcıda açılır; üzerine gelince ikon hafifçe büyür, yazı turkuaza döner.
## Menü açılınca kart sağdan kayarak biraz gecikmeyle gelir.

const PADDING: float = 7.0
const CAPTION_FONT_SIZE: int = 10
const NAME_FONT_SIZE: int = 15
const ENTER_DELAY: float = 0.35
const ENTER_TIME: float = 0.4
const ENTER_SLIDE: float = 28.0

var _card: PanelContainer
## Kartın sağa kayma miktarı (giriş animasyonu); kart sağ alt köşeye yaslanır.
var _slide: float = 0.0:
	set(value):
		_slide = value
		_place_card()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Tutucu sıfır boyutlu bir noktadır: sağ dış alanın sağ alt köşesi (radyonun aynası).
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = -Tuning.RADIO_SIDE_PADDING
	offset_right = -Tuning.RADIO_SIDE_PADDING
	offset_top = -Tuning.RADIO_BOTTOM_OFFSET
	offset_bottom = -Tuning.RADIO_BOTTOM_OFFSET
	_build()


## Kartı sağdan kaydırarak getirir.
func play_enter() -> void:
	_card.modulate.a = 0.0
	_slide = ENTER_SLIDE
	var tween := create_tween().set_parallel()
	tween.tween_property(_card, ^"modulate:a", 1.0, ENTER_TIME).set_delay(ENTER_DELAY)
	tween.tween_property(self, ^"_slide", 0.0, ENTER_TIME).set_delay(ENTER_DELAY) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _build() -> void:
	var side: float = (Tuning.VIEW_WIDTH - Tuning.TOWER_WIDTH) * 0.5 - Tuning.WALL_THICKNESS
	_card = PanelContainer.new()
	_card.add_theme_stylebox_override(&"panel", UiStyle.panel_style(PADDING))
	_card.custom_minimum_size.x = side - Tuning.RADIO_SIDE_PADDING * 2.0
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.resized.connect(_place_card)
	add_child(_card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 2)
	_card.add_child(column)
	var caption: Label = UiStyle.label(CAPTION_FONT_SIZE, UiStyle.TEXT_DIM)
	caption.text = CreatorInfo.CAPTION.to_upper()
	column.add_child(caption)
	var person: Label = UiStyle.label(NAME_FONT_SIZE, UiStyle.TEXT)
	person.text = CreatorInfo.NAME
	column.add_child(person)
	var gap := Control.new()
	gap.custom_minimum_size.y = 3.0
	column.add_child(gap)
	for link: Dictionary in CreatorInfo.LINKS:
		column.add_child(CreatorLink.new(link["icon"], link["text"], link["url"]))


func _place_card() -> void:
	if _card != null:
		_card.position = Vector2(-_card.size.x + _slide, -_card.size.y)
