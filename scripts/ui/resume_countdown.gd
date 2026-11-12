class_name ResumeCountdown
extends CanvasLayer
## "Devam"dan sonraki 3-2-1 sayımı: dünya hâlâ donukken ekranın ortasında büyük sayılar belirir
## (büyükten gelip yerine oturur, sonra solar), her adımda yükselen bir tık sesi çalar. run() sayım
## bitince döner. Ağaç donukken de çalışır.

const COUNTDOWN_LAYER: int = 41
const FONT_SIZE: int = 120
const OUTLINE_SIZE: int = 14
const START_SCALE: float = 1.7
const POP_TIME: float = 0.28
const BASE_PITCH: float = 0.9
const PITCH_STEP: float = 0.12

var _label: Label


func _init() -> void:
	layer = COUNTDOWN_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	var holder := Control.new()
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	_label = UiStyle.label(FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	_label.add_theme_color_override(&"font_outline_color", UiStyle.OUTLINE)
	_label.visible = false
	holder.add_child(_label)


## Sayımı oynatır; bitince döner.
func run() -> void:
	_label.pivot_offset = Vector2(Tuning.VIEW_WIDTH, Tuning.VIEW_HEIGHT) * 0.5
	_label.visible = true
	for step: int in Tuning.PAUSE_COUNTDOWN_STEPS:
		var number: int = Tuning.PAUSE_COUNTDOWN_STEPS - step
		_show_number(number, step)
		await get_tree().create_timer(Tuning.PAUSE_COUNTDOWN_STEP_TIME).timeout
	_label.visible = false


func _show_number(number: int, step: int) -> void:
	_label.text = str(number)
	_label.scale = Vector2.ONE * START_SCALE
	_label.modulate.a = 0.0
	var fade_out_time: float = maxf(Tuning.PAUSE_COUNTDOWN_STEP_TIME - POP_TIME, 0.05)
	var pop := create_tween()
	pop.set_parallel()
	pop.tween_property(_label, ^"scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(_label, ^"modulate:a", 1.0, POP_TIME * 0.5)
	pop.chain().tween_property(_label, ^"modulate:a", 0.0, fade_out_time)
	AudioManager.play(&"ui_click", BASE_PITCH + PITCH_STEP * step, Tuning.UI_CLICK_DB)
