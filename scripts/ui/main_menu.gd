class_name MainMenu
extends UiScreen
## Ana menü: oyun dünyasının (başlangıç alanı) üstünde, hafif karartmayla. Zıplayan başlık, rekorlar,
## Oyna / Ayarlar / Çıkış (web'de Çıkış yok), tuş ipuçları; sağ altta yapımcı kartı (CreatorInfo).
## Ayarlar düğmesi ayarlar ekranı gelene kadar (madde 5) pasif.

signal play_requested
signal settings_requested

const CARD_WIDTH: float = 330.0
const TITLE_FONT_SIZE: int = 44
const RECORD_VALUE_FONT_SIZE: int = 20
const RECORD_CAPTION_FONT_SIZE: int = 10
const HINT_FONT_SIZE: int = 12

var _title: BouncyTitle
var _records: HBoxContainer
var _no_records: Label
var _record_values: Dictionary = {}
var _settings_button: UiButton
var _badge: CreatorBadge


func _init() -> void:
	super()
	dim_alpha = Tuning.MENU_DIM_ALPHA
	shift_card(Tuning.MENU_CARD_SHIFT)
	_build_menu()
	if CreatorInfo.ENABLED:
		_badge = CreatorBadge.new()
		add_free(_badge)


func open() -> void:
	if is_open:
		return
	_refresh_records()
	super()
	_title.play()
	if _badge != null:
		_badge.play_enter()


## Ayarlar ekranı hazır olunca açılır (madde 5).
func set_settings_available(available: bool) -> void:
	_settings_button.disabled = not available
	_settings_button.focus_mode = Control.FOCUS_ALL if available else Control.FOCUS_NONE
	_settings_button.tooltip_text = "" if available else "Yakında"


func _build_menu() -> void:
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 9)
	_title = BouncyTitle.new("TOWER CLIMB", TITLE_FONT_SIZE, 6)
	content.add_child(_title)
	content.add_child(_build_records())
	content.add_child(UiStyle.spacer(6.0))

	var play := UiButton.new("Oyna", true)
	play.pressed.connect(func() -> void: play_requested.emit())
	content.add_child(play)
	first_focus = play
	_settings_button = UiButton.new("Ayarlar")
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())
	content.add_child(_settings_button)
	set_settings_available(false)
	if not OS.has_feature("web"):
		var quit := UiButton.new("Çıkış", false, true)
		quit.pressed.connect(_quit)
		content.add_child(quit)

	content.add_child(UiStyle.spacer(4.0))
	var hint: Label = UiStyle.label(HINT_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	hint.text = "←  →  koş      Space  zıpla      Esc  duraklat"
	content.add_child(hint)


## Rekor satırı: üç sütun (değer + başlık). Hiç rekor yoksa yerine tek bir davet yazısı.
func _build_records() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 2)
	_records = HBoxContainer.new()
	_records.add_theme_constant_override(&"separation", 0)
	box.add_child(_records)
	for entry: Array in [[SaveData.BEST_SCORE, "EN İYİ SKOR"], [SaveData.BEST_FLOOR, "EN YÜKSEK KAT"],
			[SaveData.BEST_COMBO, "EN UZUN KOMBO"]]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override(&"separation", 0)
		var value: Label = UiStyle.label(RECORD_VALUE_FONT_SIZE,
				UiStyle.COMBO if entry[0] == SaveData.BEST_COMBO else UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(value)
		var caption: Label = UiStyle.label(RECORD_CAPTION_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
		caption.text = entry[1]
		column.add_child(caption)
		_records.add_child(column)
		_record_values[entry[0]] = value
	_no_records = UiStyle.label(13, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_no_records.text = "İlk tırmanışın seni bekliyor"
	box.add_child(_no_records)
	return box


func _refresh_records() -> void:
	var records: Dictionary = GameState.records
	var any: bool = false
	for key: String in _record_values:
		var value: int = int(records.get(key, 0))
		(_record_values[key] as Label).text = str(value)
		any = any or value > 0
	_records.visible = any
	_no_records.visible = not any


func _quit() -> void:
	# Tık sesi duyulsun diye kısa bekleme.
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()
