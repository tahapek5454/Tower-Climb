class_name UiButton
extends Button
## Menü düğmesi (UiStyle): sade yuvarlak yüzey. Fare üstünde HAREKET edince odak alır (durağan imleç
## odağı çalmaz: imleç "Çıkış"ın üstünde dururken menü açılırsa Space/Enter yine "Oyna"yı seçer),
## yani fare ve klavye aynı tek vurguyu kullanır; vurgulu düğmede soldan turkuaz bir çizgi uzayarak belirir.
## Odak (üzerine gelme / ok tuşları) "hover" sesi, basma "click" (is_back ise "back") sesi çalar.
## primary: ana eylem (turkuaz dolu).

const FONT_SIZE: int = 18
const MIN_HEIGHT: float = 44.0
## Kompakt düğme (yan yana küçük eylemler): daha küçük yazı, boşluk ve yükseklik.
const COMPACT_FONT_SIZE: int = 14
const COMPACT_MIN_HEIGHT: float = 38.0
const COMPACT_H_MARGIN: float = 10.0
const COMPACT_V_MARGIN: float = 6.0
const BAR_WIDTH: float = 3.0
const BAR_INSET: float = 10.0
## Kompakt düğmede yazı kenara yakın: çizgi daha dışarıda durur.
const COMPACT_BAR_INSET: float = 4.0
const BAR_TIME: float = 0.16

var primary: bool = false
var is_back: bool = false
var compact: bool = false

var _bar_t: float = 0.0:
	set(value):
		_bar_t = value
		queue_redraw()
var _bar_tween: Tween
var _silent_focus: bool = false


func _init(p_text: String = "", p_primary: bool = false, p_back: bool = false, p_compact: bool = false) -> void:
	text = p_text
	primary = p_primary
	is_back = p_back
	compact = p_compact
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size.y = COMPACT_MIN_HEIGHT if compact else MIN_HEIGHT
	add_theme_font_size_override(&"font_size", COMPACT_FONT_SIZE if compact else FONT_SIZE)
	_apply_styles()
	gui_input.connect(_on_gui_input)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	pressed.connect(_on_pressed)


## Ses çalmadan odak alır (ekran açılırken ilk düğme).
func focus_silently() -> void:
	_silent_focus = true
	grab_focus()
	_silent_focus = false


func _draw() -> void:
	if _bar_t <= 0.0:
		return
	var half: float = size.y * 0.25 * _bar_t
	var x: float = COMPACT_BAR_INSET if compact else BAR_INSET
	var middle: float = size.y * 0.5
	var color: Color = UiStyle.TEXT_ON_ACCENT if primary else UiStyle.ACCENT
	draw_line(Vector2(x, middle - half), Vector2(x, middle + half), color, BAR_WIDTH, true)
	draw_circle(Vector2(x, middle - half), BAR_WIDTH * 0.5, color, true, -1.0, true)
	draw_circle(Vector2(x, middle + half), BAR_WIDTH * 0.5, color, true, -1.0, true)


func _apply_styles() -> void:
	var idle: StyleBoxFlat
	var focus: StyleBoxFlat
	var pressed_style: StyleBoxFlat
	var text_color: Color
	var h: float = COMPACT_H_MARGIN if compact else 20.0
	var v: float = COMPACT_V_MARGIN if compact else 9.0
	if primary:
		idle = UiStyle.button_style(UiStyle.ACCENT, Color(0.0, 0.0, 0.0, 0.0), 0, h, v)
		focus = UiStyle.button_style(UiStyle.ACCENT.lightened(0.18), UiStyle.TEXT, 2, h, v)
		pressed_style = UiStyle.button_style(UiStyle.ACCENT.darkened(0.12), Color(0.0, 0.0, 0.0, 0.0), 0, h, v)
		text_color = UiStyle.TEXT_ON_ACCENT
	else:
		idle = UiStyle.button_style(UiStyle.BUTTON_IDLE, Color(0.0, 0.0, 0.0, 0.0), 0, h, v)
		focus = UiStyle.button_style(UiStyle.BUTTON_FOCUS, UiStyle.ACCENT, 2, h, v)
		pressed_style = UiStyle.button_style(UiStyle.BUTTON_PRESSED, Color(0.0, 0.0, 0.0, 0.0), 0, h, v)
		text_color = UiStyle.TEXT
	add_theme_stylebox_override(&"normal", idle)
	add_theme_stylebox_override(&"hover", idle)
	add_theme_stylebox_override(&"pressed", pressed_style)
	add_theme_stylebox_override(&"focus", focus)
	add_theme_stylebox_override(&"disabled", UiStyle.button_style(UiStyle.BUTTON_IDLE, Color(0.0, 0.0, 0.0, 0.0), 0, h, v))
	for color_name: StringName in [&"font_color", &"font_hover_color", &"font_focus_color",
			&"font_pressed_color", &"font_hover_pressed_color"]:
		add_theme_color_override(color_name, text_color)
	add_theme_color_override(&"font_disabled_color", UiStyle.DISABLED)


## Fare düğmenin üstünde gerçekten hareket ettiyse odağı alır.
func _on_gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion and not disabled and not has_focus():
		grab_focus()


func _on_focus_entered() -> void:
	_animate_bar(1.0)
	if not _silent_focus:
		AudioManager.play(&"ui_hover", 1.0, Tuning.UI_HOVER_DB)


func _on_focus_exited() -> void:
	_animate_bar(0.0)


func _on_pressed() -> void:
	if is_back:
		AudioManager.play(&"ui_back", 1.0, Tuning.UI_BACK_DB)
	else:
		AudioManager.play(&"ui_click", 1.0, Tuning.UI_CLICK_DB)


func _animate_bar(target: float) -> void:
	if _bar_tween != null:
		_bar_tween.kill()
	_bar_tween = create_tween()
	_bar_tween.tween_property(self, ^"_bar_t", target, BAR_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
