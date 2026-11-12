class_name UiScreen
extends CanvasLayer
## Menü ekranlarının tabanı (ana menü, duraklatma, ayarlar, oyun sonu): arkası hafif karartılmış,
## ortada UiStyle kartı. Açılırken kart hafifçe büyüyüp yukarı süzülerek belirir, satırlar sırayla
## yükselir; kapanırken kısa bir solma. Klavye: ok tuşlarıyla gezinme (Godot odak sistemi), Esc ile
## back_requested. Radyo panelinin (katman 50) altında kalır; ağaç duraklatılmışken de çalışır.
## Alt sınıf/kullanıcı `content`'e satır ekler, `first_focus`'u belirler, open()/close() çağırır.

signal opened
signal closed
## Esc (ui_cancel) basıldı.
signal back_requested

const LAYER: int = 40
const PADDING: float = 26.0
const OPEN_TIME: float = 0.30
const CLOSE_TIME: float = 0.16
const SLIDE: float = 22.0
const START_SCALE: float = 0.94
const STAGGER_DELAY: float = 0.045
const STAGGER_TIME: float = 0.24

## Kartın içindeki dikey düzen; satırlar buraya eklenir.
var content: VBoxContainer
var card: PanelContainer
## Açılınca odağı alacak denetim (genelde ilk düğme).
var first_focus: Control
## Arkadaki oyunun ne kadar karartılacağı (0..1).
var dim_alpha: float = 0.5
## Bu ekranın açık olup olmadığı.
var is_open: bool = false

var _dim: ColorRect
var _root: Control
var _tween: Tween


func _init() -> void:
	layer = LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.pivot_offset = Vector2(Tuning.VIEW_WIDTH, Tuning.VIEW_HEIGHT) * 0.5
	_root.scale = Vector2.ONE * START_SCALE
	_root.position = Vector2(0.0, SLIDE)
	_root.modulate.a = 0.0
	_dim.color.a = 0.0
	_restart_tween()
	_tween.set_parallel()
	_tween.tween_property(_dim, ^"color:a", dim_alpha, OPEN_TIME)
	_tween.tween_property(_root, ^"modulate:a", 1.0, OPEN_TIME)
	_tween.tween_property(_root, ^"scale", Vector2.ONE, OPEN_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_root, ^"position", Vector2.ZERO, OPEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_stagger_rows()
	_focus_first()
	opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_restart_tween()
	_tween.set_parallel()
	_tween.tween_property(_dim, ^"color:a", 0.0, CLOSE_TIME)
	_tween.tween_property(_root, ^"modulate:a", 0.0, CLOSE_TIME)
	_tween.tween_property(_root, ^"position", Vector2(0.0, SLIDE * 0.5), CLOSE_TIME)
	_tween.chain().tween_callback(_finish_close)


func _unhandled_input(input_event: InputEvent) -> void:
	if not is_open:
		return
	if input_event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		back_requested.emit()
	elif get_viewport().gui_get_focus_owner() == null and _is_navigation_key(input_event):
		# Boş yere tıklanınca odak kaybolur; ilk gezinme tuşu odağı geri getirir.
		_focus_first()
		get_viewport().set_input_as_handled()


func _build() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(UiStyle.OUTLINE, 0.0)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	card = PanelContainer.new()
	card.add_theme_stylebox_override(&"panel", UiStyle.panel_style(PADDING))
	center.add_child(card)
	content = VBoxContainer.new()
	content.add_theme_constant_override(&"separation", 10)
	card.add_child(content)


## Satırlar sırayla yükselerek belirir (kart büyürken hepsi aynı anda gelmesin).
func _stagger_rows() -> void:
	var index: int = 0
	for row: Node in content.get_children():
		var control := row as Control
		if control == null:
			continue
		control.modulate.a = 0.0
		var rise := create_tween().set_parallel()
		rise.tween_property(control, ^"modulate:a", 1.0, STAGGER_TIME).set_delay(index * STAGGER_DELAY)
		index += 1


func _focus_first() -> void:
	if first_focus == null or not first_focus.is_inside_tree():
		return
	var button := first_focus as UiButton
	if button != null:
		button.focus_silently()
	else:
		first_focus.grab_focus()


func _finish_close() -> void:
	visible = false
	closed.emit()


func _restart_tween() -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()


func _is_navigation_key(input_event: InputEvent) -> bool:
	for action: StringName in [&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_accept"]:
		if input_event.is_action_pressed(action):
			return true
	return false
