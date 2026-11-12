class_name GameOverLabel
extends CanvasLayer
## Geçici oyun sonu kartı (UiStyle) ve yeniden başlatma girişi. Asıl game over ekranı Aşama 5'te.
## Ortada küçük bir kart: "OYUN BİTTİ", kat ve skor, yeniden başlatma ipucu. Hafifçe büyüyerek belirir.

const TITLE_FONT_SIZE: int = 30
const STATS_FONT_SIZE: int = 16
const HINT_FONT_SIZE: int = 12
const PADDING: float = 22.0
const POP_TIME: float = 0.25

## Yeniden başlatma istendiğinde yayınlanır.
signal restart_requested

var _card: PanelContainer
var _stats: Label
var _restart_ready: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	# Container'lar çocuklarının ölçeğini sıfırlar; kart büyüyerek belirsin diye ara katmanda durur.
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(holder)
	_card = PanelContainer.new()
	_card.add_theme_stylebox_override(&"panel", UiStyle.panel_style(PADDING))
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 8)
	_card.add_child(column)
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "OYUN BİTTİ"
	column.add_child(title)
	_stats = UiStyle.label(STATS_FONT_SIZE, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_stats)
	var hint: Label = UiStyle.label(HINT_FONT_SIZE, UiStyle.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	hint.text = "Yeniden başlamak için R ya da Space"
	column.add_child(hint)
	visible = false
	Events.game_over.connect(_on_game_over)


func _unhandled_input(input_event: InputEvent) -> void:
	if not _restart_ready:
		return
	if input_event.is_action_pressed(&"restart") or input_event.is_action_pressed(&"jump"):
		_restart_ready = false
		get_viewport().set_input_as_handled()
		restart_requested.emit()


func _on_game_over(final_score: int, final_floor: int) -> void:
	_stats.text = "Kat %d  ·  Skor %d" % [final_floor, final_score]
	visible = true
	_card.reset_size()
	_card.position = -_card.size * 0.5
	_card.pivot_offset = _card.size * 0.5
	_card.scale = Vector2.ONE * 0.85
	_card.modulate.a = 0.0
	var pop := create_tween().set_parallel()
	pop.tween_property(_card, ^"scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(_card, ^"modulate:a", 1.0, POP_TIME)
	await get_tree().create_timer(Tuning.GAME_OVER_RESTART_DELAY).timeout
	_restart_ready = true
