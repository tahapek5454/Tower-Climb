class_name Hud
extends CanvasLayer
## Basit HUD: kat, skor, en iyi skor; kombo sürerken kombo sayacı ve kalan süre çubuğu.
## Değerleri GameState/Events'ten okur; oyun mantığına dokunmaz. Görsel cilası Aşama 2/5'te.

const MARGIN: int = 16
const FONT_SIZE: int = 24
const COMBO_FONT_SIZE: int = 28
const OUTLINE_SIZE: int = 6
const TEXT_COLOR := Color(1.0, 1.0, 1.0)
const COMBO_COLOR := Color(1.0, 0.8, 0.3)
const OUTLINE_COLOR := Color(0.0, 0.0, 0.0)
const COMBO_BAR_SIZE := Vector2(180.0, 10.0)

var _floor_label: Label
var _score_label: Label
## Skor yazısını container'ın ölçek sıfırlamasından korur (bkz. _build).
var _score_holder: Control
var _best_label: Label
var _combo_box: VBoxContainer
var _combo_label: Label
var _combo_bar: ProgressBar
## Skor yazısı anında atlamaz; gösterilen değer hedefe doğru sayar.
var _shown_score: float = 0.0
var _target_score: int = 0
var _score_pulse: Tween


func _ready() -> void:
	_build()
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


func _process(delta: float) -> void:
	if _combo_box.visible:
		_combo_bar.value = GameState.combo_time_ratio
	if _shown_score != _target_score:
		_shown_score = PopupRules.count_toward(_shown_score, _target_score, delta)
		_update_score_text()


## Testler ve debug için: ekranda gösterilen skor.
func shown_score() -> int:
	return roundi(_shown_score)


func _update_score_text() -> void:
	_score_label.text = "Skor: %d" % roundi(_shown_score)
	var text_size: Vector2 = _score_label.get_minimum_size()
	_score_label.size = text_size
	_score_holder.custom_minimum_size = text_size


## Skor yazısı kısa bir an büyüyüp yerine oturur.
func _pulse_score() -> void:
	if _score_pulse != null:
		_score_pulse.kill()
	_score_label.pivot_offset = Vector2(0.0, _score_label.size.y * 0.5)
	_score_label.scale = Vector2.ONE * Tuning.SCORE_PULSE_SCALE
	_score_pulse = create_tween()
	_score_pulse.tween_property(_score_label, ^"scale", Vector2.ONE, Tuning.SCORE_PULSE_TIME) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, MARGIN)
	add_child(margin)

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin.add_child(column)

	_floor_label = _make_label(FONT_SIZE, TEXT_COLOR)
	_score_label = _make_label(FONT_SIZE, TEXT_COLOR)
	_best_label = _make_label(FONT_SIZE, TEXT_COLOR)
	column.add_child(_floor_label)
	# Container'lar çocuklarının ölçeğini sıfırlar; skor yazısı büyüyebilsin diye ara katmanda durur.
	_score_holder = Control.new()
	_score_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_score_holder.add_child(_score_label)
	column.add_child(_score_holder)
	column.add_child(_best_label)

	_combo_box = VBoxContainer.new()
	_combo_label = _make_label(COMBO_FONT_SIZE, COMBO_COLOR)
	_combo_bar = ProgressBar.new()
	_combo_bar.min_value = 0.0
	_combo_bar.max_value = 1.0
	_combo_bar.show_percentage = false
	_combo_bar.custom_minimum_size = COMBO_BAR_SIZE
	_combo_box.add_child(_combo_label)
	_combo_box.add_child(_combo_bar)
	column.add_child(_combo_box)


func _make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	return label


func _on_floor_changed(floor_number: int) -> void:
	_floor_label.text = "Kat: %d" % floor_number


func _on_score_changed(score: int) -> void:
	_target_score = score
	if score < _shown_score:
		# Sıfırlamada geriye saymasın.
		_shown_score = score
		_update_score_text()


func _on_high_score_changed(high_score: int) -> void:
	_best_label.text = "En iyi: %d" % high_score


func _on_combo_changed(jumps: int, floors: int) -> void:
	_combo_label.text = "KOMBO x%d  (%d kat)" % [jumps, floors]
	_combo_bar.value = GameState.combo_time_ratio
	_combo_box.visible = true


func _on_combo_ended(_jumps: int, _floors: int, bonus: int) -> void:
	_combo_box.visible = false
	if bonus > 0:
		_pulse_score()
