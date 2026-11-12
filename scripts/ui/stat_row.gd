class_name StatRow
extends HBoxContainer
## Oyun sonu istatistik satırı: solda başlık, sağda sayarak artan değer. Rekor kırıldıysa sayım
## bitince değer altına dönüşür ve değerin solunda küçük bir altın "REKOR" rozeti belirir.
## play() sayımı bekleme süresinden sonra başlatır; bitince finished yayınlanır (tık sesiyle).

signal finished

const CAPTION_FONT_SIZE: int = 14
const VALUE_FONT_SIZE: int = 22
const COUNT_TIME: float = 0.8
const TAG_FADE_TIME: float = 0.25
const TAG_TEXT: String = "REKOR"

var _is_record: bool
var _format: Callable
var _value: Label
var _tag: Control
var _tween: Tween


## format: tam sayıyı yazıya çeviren Callable (ör. süre için m:ss).
func _init(caption: String, is_record: bool, format: Callable) -> void:
	_is_record = is_record
	_format = format
	add_theme_constant_override(&"separation", 10)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title: Label = UiStyle.label(CAPTION_FONT_SIZE, UiStyle.TEXT_DIM)
	title.text = caption
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(title)
	if is_record:
		_tag = _make_tag()
		_tag.modulate.a = 0.0
		add_child(_tag)
	_value = UiStyle.label(VALUE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_RIGHT)
	_value.custom_minimum_size.x = 80.0
	_value.text = _format.call(0)
	add_child(_value)


## Sayımı başlatır. pitch: bitiş tıkının perdesi (satırlar yükselen perdeyle biter).
func play(target: int, delay: float, pitch: float = 1.0) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(delay)
	_tween.tween_method(func(progress: float) -> void:
		_value.text = _format.call(GameOverRules.eased_count(target, progress)), 0.0, 1.0, COUNT_TIME)
	_tween.tween_callback(_finish.bind(target, pitch))


func _finish(target: int, pitch: float) -> void:
	_value.text = _format.call(target)
	AudioManager.play(&"ui_click", pitch, Tuning.UI_CLICK_DB)
	if _is_record:
		_value.add_theme_color_override(&"font_color", UiStyle.COMBO)
		var fade := create_tween()
		fade.tween_property(_tag, ^"modulate:a", 1.0, TAG_FADE_TIME)
	finished.emit()


static func _make_tag() -> Control:
	var tag := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = UiStyle.COMBO
	style.set_corner_radius_all(8)
	style.content_margin_left = 7.0
	style.content_margin_right = 7.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 2.0
	tag.add_theme_stylebox_override(&"panel", style)
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption: Label = UiStyle.label(10, UiStyle.TEXT_ON_ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	caption.text = TAG_TEXT
	tag.add_child(caption)
	return tag
