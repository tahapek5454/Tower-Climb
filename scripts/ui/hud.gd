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
var _best_label: Label
var _combo_box: VBoxContainer
var _combo_label: Label
var _combo_bar: ProgressBar


func _ready() -> void:
	_build()
	Events.floor_changed.connect(_on_floor_changed)
	Events.score_changed.connect(_on_score_changed)
	Events.high_score_changed.connect(_on_high_score_changed)
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_ended.connect(_on_combo_ended)
	_on_floor_changed(GameState.floor_number)
	_on_score_changed(GameState.score)
	_on_high_score_changed(GameState.high_score)
	_combo_box.visible = false


func _process(_delta: float) -> void:
	if _combo_box.visible:
		_combo_bar.value = GameState.combo_time_ratio


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
	column.add_child(_score_label)
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
	_score_label.text = "Skor: %d" % score


func _on_high_score_changed(high_score: int) -> void:
	_best_label.text = "En iyi: %d" % high_score


func _on_combo_changed(jumps: int, floors: int) -> void:
	_combo_label.text = "KOMBO x%d  (%d kat)" % [jumps, floors]
	_combo_bar.value = GameState.combo_time_ratio
	_combo_box.visible = true


func _on_combo_ended(_jumps: int, _floors: int, _bonus: int) -> void:
	_combo_box.visible = false
