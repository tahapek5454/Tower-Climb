class_name Hud
extends CanvasLayer
## HUD: kulenin sol dışında, sol üstte küçük bir kart (radyo paneliyle aynı genişlik ve stil, UiStyle).
## Satırlar: KAT (büyük), SKOR (sayarak artar, bonusla kısa büyür), EN İYİ, ELMAS, CAN (kalpler); kombo sürerken altın
## renkli kombo satırı ve kalan süre çubuğu açılır. Değerleri GameState/Events'ten okur.
## Ana menüde gizli; oyun başlayınca yukarıdan süzülerek belirir.

const FLOOR_FONT_SIZE: int = 22
const SCORE_FONT_SIZE: int = 16
const BEST_FONT_SIZE: int = 12
const CAPTION_FONT_SIZE: int = 10
const COMBO_FONT_SIZE: int = 13
const PADDING: float = 8.0
const COMBO_BAR_HEIGHT: float = 3.0
const SHOW_TIME: float = 0.35
const SHOW_SLIDE: float = 14.0

var _card: PanelContainer

var _floor_label: Label
var _score_label: Label
## Skor yazısını container'ın ölçek sıfırlamasından korur (bkz. _build).
var _score_holder: Control
var _best_label: Label
var _combo_box: VBoxContainer
var _combo_label: Label
var _combo_floors: Label
var _combo_bar: Control
## Skor yazısı anında atlamaz; gösterilen değer hedefe doğru sayar.
var _shown_score: float = 0.0
var _target_score: int = 0
var _score_pulse: Tween
## Süreli güçlendirme satırları (Pickup türü → PowerupRow): etki sürerken açılır, çubuk kalan süreyi gösterir.
var _powerup_rows: Dictionary = {}


func _ready() -> void:
	_build()
	Events.powerup_started.connect(_on_powerup_started)
	Events.powerup_ended.connect(_on_powerup_ended)
	Events.game_started.connect(_stop_powerups)
	Events.floor_changed.connect(_on_floor_changed)
	Events.score_changed.connect(_on_score_changed)
	Events.high_score_changed.connect(_on_high_score_changed)
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_ended.connect(_on_combo_ended)
	_on_floor_changed(GameState.floor_number)
	_on_score_changed(GameState.score)
	_shown_score = GameState.score
	_update_score_text()
	_on_high_score_changed(GameState.high_score)
	_combo_box.visible = false
	_card.visible = GameFlow.state != FlowRules.State.MENU
	Events.flow_changed.connect(_on_flow_changed)


func _process(delta: float) -> void:
	if _combo_box.visible:
		_combo_bar.queue_redraw()
	if _shown_score != _target_score:
		_shown_score = PopupRules.count_toward(_shown_score, _target_score, delta)
		_update_score_text()


## Testler ve debug için: ekranda gösterilen skor.
func shown_score() -> int:
	return roundi(_shown_score)


func _update_score_text() -> void:
	_score_label.text = "%d" % roundi(_shown_score)
	var text_size: Vector2 = _score_label.get_minimum_size()
	_score_label.size = text_size
	_score_holder.custom_minimum_size = Vector2(0.0, text_size.y)
	_align_score()


## Skor yazısı ara katmanın sağ kenarına yaslanır (ara katman container değil, elle hizalanır).
func _align_score() -> void:
	_score_label.position.x = _score_holder.size.x - _score_label.size.x


## Skor yazısı kısa bir an büyüyüp yerine oturur (sağ kenarından).
func _pulse_score() -> void:
	if _score_pulse != null:
		_score_pulse.kill()
	_score_label.pivot_offset = Vector2(_score_label.size.x, _score_label.size.y * 0.5)
	_score_label.scale = Vector2.ONE * Tuning.SCORE_PULSE_SCALE
	_score_pulse = create_tween()
	_score_pulse.tween_property(_score_label, ^"scale", Vector2.ONE, Tuning.SCORE_PULSE_TIME) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build() -> void:
	var side: float = (Tuning.VIEW_WIDTH - Tuning.TOWER_WIDTH) * 0.5 - Tuning.WALL_THICKNESS
	_card = PanelContainer.new()
	_card.add_theme_stylebox_override(&"panel", UiStyle.panel_style(PADDING))
	_card.position = Vector2.ONE * Tuning.RADIO_SIDE_PADDING
	_card.custom_minimum_size.x = side - Tuning.RADIO_SIDE_PADDING * 2.0
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)

	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 1)
	_card.add_child(column)

	_floor_label = _add_row(column, "KAT", FLOOR_FONT_SIZE, UiStyle.TEXT)
	# Container'lar çocuklarının ölçeğini sıfırlar; skor yazısı büyüyebilsin diye ara katmanda durur.
	var score_row: HBoxContainer = _row(column, "SKOR")
	_score_holder = Control.new()
	_score_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_score_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_score_label = UiStyle.label(SCORE_FONT_SIZE, UiStyle.TEXT)
	_score_holder.add_child(_score_label)
	_score_holder.resized.connect(_align_score)
	score_row.add_child(_score_holder)
	_best_label = _add_row(column, "EN İYİ", BEST_FONT_SIZE, UiStyle.TEXT_DIM)
	var diamonds := DiamondCounter.new(SCORE_FONT_SIZE)
	diamonds.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_row(column, "ELMAS").add_child(diamonds)
	var hearts := HeartMeter.new()
	hearts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_row(column, "CAN").add_child(hearts)

	_combo_box = VBoxContainer.new()
	_combo_box.add_theme_constant_override(&"separation", 3)
	var separator := HSeparator.new()
	separator.add_theme_color_override(&"separator", UiStyle.TRACK)
	_combo_box.add_child(separator)
	var combo_row := HBoxContainer.new()
	_combo_label = UiStyle.label(COMBO_FONT_SIZE, UiStyle.COMBO)
	_combo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_combo_floors = UiStyle.label(CAPTION_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	combo_row.add_child(_combo_label)
	combo_row.add_child(_combo_floors)
	_combo_box.add_child(combo_row)
	_combo_bar = Control.new()
	_combo_bar.custom_minimum_size.y = COMBO_BAR_HEIGHT + 2.0
	_combo_bar.draw.connect(_draw_combo_bar)
	_combo_box.add_child(_combo_bar)
	column.add_child(_combo_box)
	_powerup_rows[Pickup.JETPACK] = PowerupRow.new("ROKET", JetpackArt.CAP, JetpackArt.BODY)
	_powerup_rows[Pickup.HOURGLASS] = PowerupRow.new("YAVAŞ ZAMAN", HourglassArt.GLOW, HourglassArt.SAND)
	for row: PowerupRow in _powerup_rows.values():
		column.add_child(row)


func _on_powerup_started(kind: StringName, duration: float) -> void:
	if _powerup_rows.has(kind):
		(_powerup_rows[kind] as PowerupRow).start(duration)


func _on_powerup_ended(kind: StringName) -> void:
	if _powerup_rows.has(kind):
		(_powerup_rows[kind] as PowerupRow).stop()


func _stop_powerups() -> void:
	for row: PowerupRow in _powerup_rows.values():
		row.stop()


## Başlık (solda, soluk) + değer (sağda) satırı; değer etiketini döndürür.
func _add_row(column: VBoxContainer, caption: String, font_size: int, color: Color) -> Label:
	var row: HBoxContainer = _row(column, caption)
	var value: Label = UiStyle.label(font_size, color, HORIZONTAL_ALIGNMENT_RIGHT)
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value)
	return value


func _row(column: VBoxContainer, caption: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var caption_label: Label = UiStyle.label(CAPTION_FONT_SIZE, UiStyle.TEXT_DIM)
	caption_label.text = caption
	row.add_child(caption_label)
	column.add_child(row)
	return row


func _draw_combo_bar() -> void:
	var y: float = _combo_bar.size.y * 0.5
	var width: float = _combo_bar.size.x
	_combo_bar.draw_line(Vector2(0.0, y), Vector2(width, y), UiStyle.TRACK, COMBO_BAR_HEIGHT, true)
	_combo_bar.draw_line(Vector2(0.0, y), Vector2(width * GameState.combo_time_ratio, y), UiStyle.COMBO,
			COMBO_BAR_HEIGHT, true)


func _on_floor_changed(floor_number: int) -> void:
	_floor_label.text = "%d" % floor_number


func _on_score_changed(score: int) -> void:
	_target_score = score
	if score < _shown_score:
		# Sıfırlamada geriye saymasın.
		_shown_score = score
		_update_score_text()


## Menüden oyuna geçince kart yukarıdan süzülerek belirir.
func _on_flow_changed(new_state: int, old_state: int) -> void:
	if old_state != FlowRules.State.MENU or new_state != FlowRules.State.PLAYING:
		return
	_card.visible = true
	_card.modulate.a = 0.0
	_card.position.y = Tuning.RADIO_SIDE_PADDING - SHOW_SLIDE
	var tween := create_tween().set_parallel()
	tween.tween_property(_card, ^"modulate:a", 1.0, SHOW_TIME)
	tween.tween_property(_card, ^"position:y", Tuning.RADIO_SIDE_PADDING, SHOW_TIME) 			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_high_score_changed(high_score: int) -> void:
	_best_label.text = "%d" % high_score


func _on_combo_changed(jumps: int, floors: int) -> void:
	_combo_label.text = "KOMBO x%d" % jumps
	_combo_floors.text = "%d kat" % floors
	_combo_box.visible = true


func _on_combo_ended(_jumps: int, _floors: int, bonus: int) -> void:
	_combo_box.visible = false
	if bonus > 0:
		_pulse_score()
