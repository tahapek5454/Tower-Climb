class_name GameOverScreen
extends UiScreen
## Oyun sonu ekranı (GameOverLabel'in yerini aldı). Oyuncu düşünce kart belirir: zıplayan başlık
## ("OYUN BİTTİ" ya da rekor kırıldıysa altın "YENİ REKOR!"), sayarak artan Kat / Skor / En uzun kombo /
## Süre satırları (kırılan rekorun yanında altın rozet). Rekor varsa kart çerçevesi altın olur, konfeti
## yağar. Düğmeler: Tekrar (primary; R ve Space da) ve Ana menü. Yanlışlıkla atlanmasın diye
## GAME_OVER_RESTART_DELAY boyunca girişler kapalı. Esc bu ekranda bir şey yapmaz.

signal restart_requested
signal menu_requested

const CARD_WIDTH: float = 360.0
const TITLE_FONT_SIZE: int = 42
const SUBTITLE_FONT_SIZE: int = 14
const HINT_FONT_SIZE: int = 12
const GAME_OVER_DIM_ALPHA: float = 0.42
const COUNT_START_DELAY: float = 0.55
const COUNT_ROW_GAP: float = 0.45
const COUNT_BASE_PITCH: float = 0.9
const COUNT_PITCH_STEP: float = 0.1
const CONFETTI_DELAY: float = 0.45
const RECORD_BORDER_WIDTH: int = 2

var _title: BouncyTitle
var _subtitle: Label
var _rows_box: VBoxContainer
var _restart_button: UiButton
var _menu_button: UiButton
var _confetti: ConfettiRain
var _input_ready: bool = false


func _init() -> void:
	super()
	dim_alpha = GAME_OVER_DIM_ALPHA
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 8)
	_title = BouncyTitle.new(GameOverRules.TITLE_NORMAL, TITLE_FONT_SIZE)
	content.add_child(_title)
	_subtitle = UiStyle.label(SUBTITLE_FONT_SIZE, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_subtitle)
	content.add_child(UiStyle.spacer(8.0))
	_rows_box = VBoxContainer.new()
	_rows_box.add_theme_constant_override(&"separation", 6)
	content.add_child(_rows_box)
	content.add_child(UiStyle.spacer(8.0))

	_restart_button = UiButton.new("Tekrar", true)
	_restart_button.pressed.connect(_request_restart)
	content.add_child(_restart_button)
	first_focus = _restart_button
	_menu_button = UiButton.new("Ana menü", false, true)
	_menu_button.pressed.connect(_request_menu)
	content.add_child(_menu_button)
	var hint: Label = UiStyle.label(HINT_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	hint.text = "R  tekrar"
	content.add_child(hint)

	_confetti = ConfettiRain.new()
	add_child(_confetti)
	Events.game_over.connect(_on_game_over)


func open() -> void:
	if is_open:
		return
	super()
	_title.play()


func _unhandled_input(input_event: InputEvent) -> void:
	if is_open and _input_ready and input_event.is_action_pressed(&"restart"):
		get_viewport().set_input_as_handled()
		_request_restart()
		return
	super(input_event)


## Esc oyun sonunda bir şey yapmaz (yanlışlıkla menüye atmasın).
func _on_cancel() -> void:
	pass


func _on_game_over(_final_score: int, _final_floor: int) -> void:
	var records: Array = GameState.new_records
	var is_record: bool = not records.is_empty()
	_title.set_text(GameOverRules.headline(records))
	_title.base_color = UiStyle.COMBO if is_record else UiStyle.TEXT
	_subtitle.text = GameOverRules.subtitle(records)
	_subtitle.add_theme_color_override(&"font_color", UiStyle.COMBO if is_record else UiStyle.ACCENT)
	card.add_theme_stylebox_override(&"panel", _card_style(is_record))
	_build_rows(records)
	_input_ready = false
	_restart_button.disabled = true
	_menu_button.disabled = true
	open()
	if is_record:
		_play_confetti_later()
	await get_tree().create_timer(Tuning.GAME_OVER_RESTART_DELAY).timeout
	_input_ready = true
	_restart_button.disabled = false
	_menu_button.disabled = false
	_restart_button.focus_silently()


func _build_rows(records: Array) -> void:
	for old_row: Node in _rows_box.get_children():
		_rows_box.remove_child(old_row)
		old_row.queue_free()
	var combo_text: Callable = func(value: int) -> String: return str(value) if value > 0 else "–"
	var number_text: Callable = func(value: int) -> String: return str(value)
	var time_text: Callable = func(value: int) -> String: return GameOverRules.format_time(value)
	var entries: Array = [
		["Kat", GameState.floor_number, records.has(SaveData.BEST_FLOOR), number_text],
		["Skor", GameState.score, records.has(SaveData.BEST_SCORE), number_text],
		["En uzun kombo", GameState.run_best_combo, records.has(SaveData.BEST_COMBO), combo_text],
		["Süre", int(GameState.run_time), false, time_text],
	]
	for index: int in entries.size():
		var entry: Array = entries[index]
		var row := StatRow.new(entry[0], entry[2], entry[3])
		_rows_box.add_child(row)
		row.play(entry[1], COUNT_START_DELAY + index * COUNT_ROW_GAP, COUNT_BASE_PITCH + index * COUNT_PITCH_STEP)


func _play_confetti_later() -> void:
	await get_tree().create_timer(CONFETTI_DELAY).timeout
	_confetti.burst()


## Rekor varsa altın çerçeve.
func _card_style(is_record: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = UiStyle.panel_style(PADDING)
	if is_record:
		style.border_color = UiStyle.COMBO
		style.set_border_width_all(RECORD_BORDER_WIDTH)
	return style


func _request_restart() -> void:
	if not _input_ready:
		return
	_input_ready = false
	restart_requested.emit()


func _request_menu() -> void:
	if not _input_ready:
		return
	_input_ready = false
	menu_requested.emit()
