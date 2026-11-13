class_name AchievementToast
extends CanvasLayer
## Başarım bildirimi: ekranın üst ortasından kayarak inen küçük kart. Solda altın kupa, üstte küçük
## "BAŞARIM", altında başlık, sağda "+N" ve elmas simgesi. Birkaç saniye kalır, yukarı kayıp söner;
## art arda gelenler sıraya girer. Duraklatmada ve oyun sonu ekranında da çalışır (katman 42).

const LAYER_INDEX: int = 42
const HIDDEN_OFFSET: float = -110.0
const GLOW_TIME: float = 1.0
const ICON_SIZE: float = 38.0

var _slide: Control
var _card: PanelContainer
var _icon: Control
var _caption: Label
var _title: Label
var _reward: Label
var _diamond: Control
var _queue: Array[StringName] = []
var _busy: bool = false
var _glow: float = 0.0:
	set(value):
		_glow = value
		if _icon != null:
			_icon.queue_redraw()
var _tween: Tween


func _init() -> void:
	layer = LAYER_INDEX
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()


func _ready() -> void:
	Events.achievement_unlocked.connect(show_achievement)


## Başarımı gösterir (başka bildirim sürüyorsa sıraya girer).
func show_achievement(id: StringName) -> void:
	_queue.append(id)
	if not _busy:
		_next()


func is_showing() -> bool:
	return _busy


func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_slide = VBoxContainer.new()
	_slide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_slide.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slide.visible = false
	root.add_child(_slide)
	_card = PanelContainer.new()
	_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = UiStyle.panel_style(0.0)
	style.border_color = Color(UiStyle.COMBO, 0.6)
	style.content_margin_left = 14.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	_card.add_theme_stylebox_override(&"panel", style)
	_slide.add_child(_card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(row)
	_icon = Control.new()
	_icon.custom_minimum_size = Vector2.ONE * ICON_SIZE
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.draw.connect(func() -> void: AchievementArt.draw_trophy(_icon, _icon.size * 0.5, 1.15, _glow))
	row.add_child(_icon)
	var texts := VBoxContainer.new()
	texts.add_theme_constant_override(&"separation", -2)
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption = UiStyle.label(10, UiStyle.COMBO)
	_caption.text = "BAŞARIM"
	texts.add_child(_caption)
	_title = UiStyle.label(17, UiStyle.TEXT)
	texts.add_child(_title)
	row.add_child(texts)
	var reward_box := HBoxContainer.new()
	reward_box.add_theme_constant_override(&"separation", 4)
	reward_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reward_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reward = UiStyle.label(17, DiamondArt.LIGHT)
	reward_box.add_child(_reward)
	_diamond = Control.new()
	_diamond.custom_minimum_size = Vector2(22.0, 24.0)
	_diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_diamond.draw.connect(func() -> void:
		DiamondArt.draw(_diamond, _diamond.size * 0.5 - Vector2(0.0, 2.0), 0.7))
	reward_box.add_child(_diamond)
	row.add_child(reward_box)


func _next() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	var def: Dictionary = AchievementRules.get_def(_queue.pop_front())
	if def.is_empty():
		_next()
		return
	_title.text = def["title"]
	_reward.text = "+%d" % int(def["reward"])
	_play(def)


func _play(_def: Dictionary) -> void:
	AudioManager.play(&"achievement", 1.0, Tuning.SFX_ACHIEVEMENT_DB)
	_slide.visible = true
	_slide.position.y = _rest_y() + HIDDEN_OFFSET
	_slide.modulate.a = 0.0
	_glow = 1.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel()
	var slide: float = Tuning.ACHIEVEMENT_TOAST_SLIDE
	_tween.tween_property(_slide, ^"position:y", _rest_y(), slide).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_slide, ^"modulate:a", 1.0, slide * 0.6)
	_tween.tween_property(self, ^"_glow", 0.0, GLOW_TIME).set_delay(slide * 0.5)
	_tween.chain().tween_interval(Tuning.ACHIEVEMENT_TOAST_HOLD)
	_tween.chain()
	_tween.tween_property(_slide, ^"position:y", _rest_y() + HIDDEN_OFFSET, slide).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_slide, ^"modulate:a", 0.0, slide)
	_tween.chain().tween_callback(_on_finished)


## Kartın durduğu yer: üst kenardan boşluk kadar aşağıda.
func _rest_y() -> float:
	return Tuning.ACHIEVEMENT_TOAST_TOP


func _on_finished() -> void:
	_slide.visible = false
	_next()
