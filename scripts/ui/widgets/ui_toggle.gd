class_name UiToggle
extends Control
## Aç/kapa anahtarı (kodla çizilir): yuvarlak düğme kayarak yer değiştirir. Fare, Enter/Space ile
## değişir; fare üstünde hareket edince odak alır (UiButton ile aynı tek vurgu; durağan imleç odağı çalmaz). Değişince toggled yayınlanır;
## set_on sinyal yaymaz (ilk değer atamak için).

signal toggled(on: bool)

const TRACK_SIZE := Vector2(46.0, 24.0)
const KNOB_RADIUS: float = 9.0
const SLIDE_TIME: float = 0.14

var on: bool = false
## Düğmenin konumu (0 = kapalı, 1 = açık); animasyon için.
var _t: float = 0.0:
	set(value):
		_t = value
		queue_redraw()
var _tween: Tween


func _init(p_on: bool = false) -> void:
	on = p_on
	_t = 1.0 if p_on else 0.0
	custom_minimum_size = TRACK_SIZE + Vector2(10.0, 10.0)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


## Durumu sinyal yaymadan ayarlar.
func set_on(value: bool, animate: bool = true) -> void:
	on = value
	_move_knob(animate)


func toggle() -> void:
	on = not on
	_move_knob(true)
	AudioManager.play(&"ui_click", 1.12 if on else 0.9, Tuning.UI_CLICK_DB)
	toggled.emit(on)


func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion and not has_focus():
		grab_focus()
	var click := input_event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
		toggle()
		accept_event()
	elif input_event.is_action_pressed(&"ui_accept"):
		toggle()
		accept_event()


func _draw() -> void:
	var track_rect := Rect2((size - TRACK_SIZE) * 0.5, TRACK_SIZE)
	var track := StyleBoxFlat.new()
	track.bg_color = UiStyle.TRACK.lerp(UiStyle.ACCENT, _t)
	track.set_corner_radius_all(int(TRACK_SIZE.y * 0.5))
	if has_focus():
		track.border_color = UiStyle.TEXT
		track.set_border_width_all(2)
	draw_style_box(track, track_rect)
	var travel: float = TRACK_SIZE.x - TRACK_SIZE.y
	var knob_x: float = track_rect.position.x + TRACK_SIZE.y * 0.5 + travel * _t
	var knob_color: Color = UiStyle.TEXT_DIM.lerp(UiStyle.TEXT, _t)
	draw_circle(Vector2(knob_x, size.y * 0.5), KNOB_RADIUS, knob_color, true, -1.0, true)


func _move_knob(animate: bool) -> void:
	if _tween != null:
		_tween.kill()
	var target: float = 1.0 if on else 0.0
	if not animate:
		_t = target
		return
	_tween = create_tween()
	_tween.tween_property(self, ^"_t", target, SLIDE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
