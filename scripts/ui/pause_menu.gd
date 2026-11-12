class_name PauseMenu
extends UiScreen
## Duraklatma ekranı (Esc): dünya donar ve kararır, kart ortada. Devam / Ayarlar (madde 5'e kadar
## pasif) / Ana menü. Esc de "devam" sayılır (back_requested → PauseController). Kartta o anki
## kat ve skor gösterilir.

signal resume_requested
signal settings_requested
signal menu_requested

const CARD_WIDTH: float = 300.0
const TITLE_FONT_SIZE: int = 30
const STATS_FONT_SIZE: int = 15
const HINT_FONT_SIZE: int = 12
const PAUSE_DIM_ALPHA: float = 0.55

var _stats: Label
var _settings_button: UiButton


func _init() -> void:
	super()
	dim_alpha = PAUSE_DIM_ALPHA
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 9)
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "DURAKLATILDI"
	content.add_child(title)
	_stats = UiStyle.label(STATS_FONT_SIZE, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_stats)
	content.add_child(UiStyle.spacer(6.0))

	var resume := UiButton.new("Devam", true)
	resume.pressed.connect(func() -> void: resume_requested.emit())
	content.add_child(resume)
	first_focus = resume
	_settings_button = UiButton.new("Ayarlar")
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())
	content.add_child(_settings_button)
	set_settings_available(false)
	var to_menu := UiButton.new("Ana menü", false, true)
	to_menu.pressed.connect(func() -> void: menu_requested.emit())
	content.add_child(to_menu)

	content.add_child(UiStyle.spacer(4.0))
	var hint: Label = UiStyle.label(HINT_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	hint.text = "Esc  devam"
	content.add_child(hint)


func open() -> void:
	if is_open:
		return
	_stats.text = "Kat %d  ·  Skor %d" % [GameState.floor_number, GameState.score]
	super()


## Ayarlar ekranı hazır olunca açılır (madde 5).
func set_settings_available(available: bool) -> void:
	_settings_button.disabled = not available
	_settings_button.focus_mode = Control.FOCUS_ALL if available else Control.FOCUS_NONE
	_settings_button.tooltip_text = "" if available else "Yakında"
