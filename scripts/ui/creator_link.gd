class_name CreatorLink
extends Control
## Yapımcı kartındaki tek bağlantı satırı: kodla çizilen ikon (GitHub kedisi ya da küre) + yazı.
## Tıklanınca adres tarayıcıda açılır. Üzerine gelince ikon hafifçe büyür, yazı turkuaz olur.
## Klavye odağı almaz (menü klavyeyle düğmeler arasında gezilir).

const FONT_SIZE: int = 12
const MIN_FONT_SIZE: int = 9
const HEIGHT: float = 20.0
const ICON_RADIUS: float = 6.5
const TEXT_X: float = 18.0
const HOVER_TIME: float = 0.15

var icon_kind: StringName
var text: String
var url: String
var _hover_t: float = 0.0:
	set(value):
		_hover_t = value
		queue_redraw()
var _tween: Tween


func _init(p_icon: StringName = &"web", p_text: String = "", p_url: String = "") -> void:
	icon_kind = p_icon
	text = p_text
	url = p_url
	tooltip_text = url
	custom_minimum_size.y = HEIGHT
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_animate_hover.bind(1.0))
	mouse_exited.connect(_animate_hover.bind(0.0))


func _gui_input(input_event: InputEvent) -> void:
	var click := input_event as InputEventMouseButton
	if click != null and click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
		AudioManager.play(&"ui_click", 1.0, Tuning.UI_CLICK_DB)
		OS.shell_open(url)
		accept_event()


func _draw() -> void:
	var color: Color = UiStyle.TEXT_DIM.lerp(UiStyle.ACCENT, _hover_t)
	var center := Vector2(ICON_RADIUS + 1.0, size.y * 0.5)
	var radius: float = ICON_RADIUS * (1.0 + 0.18 * _hover_t)
	if icon_kind == &"github":
		draw_github(self, center, radius, color, UiStyle.PANEL)
	else:
		draw_globe(self, center, radius, color)
	var font: Font = get_theme_default_font()
	var font_size: int = _fitting_font_size(font)
	var baseline: float = (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	var at := Vector2(TEXT_X + 2.0 * _hover_t, baseline)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


## Uzun yazı kırpılmasın: sığana kadar puntoyu küçültür (en az MIN_FONT_SIZE).
func _fitting_font_size(font: Font) -> int:
	var available: float = size.x - TEXT_X - 3.0
	var font_size: int = FONT_SIZE
	while font_size > MIN_FONT_SIZE \
			and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > available:
		font_size -= 1
	return font_size


## GitHub işareti (sade): dolu daire içinde kedi başı silüeti (kulaklar, baş, aşağı inen gövde).
static func draw_github(canvas: CanvasItem, center: Vector2, r: float, color: Color, cut: Color) -> void:
	canvas.draw_circle(center, r, color, true, -1.0, true)
	var head := center + Vector2(0.0, -r * 0.05)
	canvas.draw_circle(head, r * 0.47, cut, true, -1.0, true)
	for side: float in [-1.0, 1.0]:
		canvas.draw_colored_polygon(PackedVector2Array([
			head + Vector2(side * r * 0.44, -r * 0.08),
			head + Vector2(side * r * 0.40, -r * 0.62),
			head + Vector2(side * r * 0.10, -r * 0.38),
		]), cut)
	canvas.draw_rect(Rect2(center + Vector2(-r * 0.17, r * 0.3), Vector2(r * 0.34, r * 0.62)), cut)
	canvas.draw_arc(center + Vector2(-r * 0.36, r * 0.38), r * 0.2, 0.0, PI, 6, cut, r * 0.12, true)


## Küre (web sitesi): çember, dikey elips (boylam), ekvator ve iki enlem çizgisi.
static func draw_globe(canvas: CanvasItem, center: Vector2, r: float, color: Color) -> void:
	var width: float = maxf(r * 0.17, 1.2)
	canvas.draw_arc(center, r, 0.0, TAU, 24, color, width, true)
	var meridian := PackedVector2Array()
	for i: int in 25:
		var angle: float = TAU * i / 24.0
		meridian.append(center + Vector2(cos(angle) * r * 0.45, sin(angle) * r))
	canvas.draw_polyline(meridian, color, width, true)
	canvas.draw_line(center + Vector2(-r, 0.0), center + Vector2(r, 0.0), color, width, true)
	for y: float in [-0.5, 0.5]:
		var half: float = sqrt(1.0 - y * y) * r
		canvas.draw_line(center + Vector2(-half, y * r), center + Vector2(half, y * r), color, width, true)


func _animate_hover(target: float) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"_hover_t", target, HOVER_TIME)
