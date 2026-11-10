class_name GameOverLabel
extends CanvasLayer
## Geçici oyun sonu yazısı ve yeniden başlatma girişi. Asıl game over ekranı Aşama 5'te.

const FONT_SIZE: int = 40
const TEXT_COLOR := Color(1.0, 0.92, 0.8)
const OUTLINE_COLOR := Color(0.0, 0.0, 0.0)
const OUTLINE_SIZE: int = 8

## Yeniden başlatma istendiğinde yayınlanır.
signal restart_requested

var _label: Label
var _restart_ready: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	_label.add_theme_color_override(&"font_color", TEXT_COLOR)
	_label.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	_label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	add_child(_label)
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
	_label.text = "OYUN BİTTİ\n\nKat: %d    Skor: %d\n\nYeniden başlamak için R veya Space" \
			% [final_floor, final_score]
	visible = true
	await get_tree().create_timer(Tuning.GAME_OVER_RESTART_DELAY).timeout
	_restart_ready = true
