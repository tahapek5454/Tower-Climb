class_name BouncyTitle
extends Control
## Zıplayan başlık: play() ile harfler sırayla yukarıdan düşüp hafifçe sekerek yerine oturur, sonra
## harflerin üzerinden yavaş bir dalga geçer ("nefes alır"). Harfler kodla tek tek çizilir.
## accent_from: bu sıradan itibaren harfler vurgu renginde (ör. "TOWER CLIMB" → CLIMB turkuaz).

const DROP: float = 34.0
const LETTER_DELAY: float = 0.055
const DROP_TIME: float = 0.5
const WAVE_AMPLITUDE: float = 2.6
const WAVE_SPEED: float = 2.2
const WAVE_SPREAD: float = 0.5
## Dalganın girişten sonra yavaşça devreye girme süresi (s).
const WAVE_FADE_IN: float = 0.8
const OUTLINE_SIZE: int = 8

var text: String
var font_size: int
var accent_from: int
## Harf renkleri: genel renk ve (accent_from'dan sonraki harfler için) vurgu rengi.
var base_color: Color = UiStyle.TEXT
var accent_color: Color = UiStyle.ACCENT
var _font: Font
var _time: float = 0.0


func _init(p_text: String = "", p_font_size: int = 40, p_accent_from: int = -1) -> void:
	text = p_text
	font_size = p_font_size
	accent_from = p_accent_from
	_font = ThemeDB.fallback_font
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_size()
	set_process(false)


## Yazıyı değiştirir (boyut yeniden hesaplanır); animasyon play() ile baştan oynar.
func set_text(new_text: String) -> void:
	text = new_text
	_update_size()
	queue_redraw()


func _update_size() -> void:
	var width: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	custom_minimum_size = Vector2(width + OUTLINE_SIZE, font_size * 1.25 + WAVE_AMPLITUDE * 2.0)


## Giriş animasyonunu baştan oynatır.
func play() -> void:
	_time = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var total: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x: float = (size.x - total) * 0.5
	var baseline: float = (size.y + _font.get_ascent(font_size) - _font.get_descent(font_size)) * 0.5
	var entry_end: float = text.length() * LETTER_DELAY + DROP_TIME
	var wave_weight: float = clampf((_time - entry_end) / WAVE_FADE_IN, 0.0, 1.0)
	for i: int in text.length():
		var letter: String = text[i]
		var k: float = clampf((_time - i * LETTER_DELAY) / DROP_TIME, 0.0, 1.0)
		var offset: float = -DROP * (1.0 - _ease_out_back(k))
		offset += sin(_time * WAVE_SPEED - i * WAVE_SPREAD) * WAVE_AMPLITUDE * wave_weight
		var color: Color = accent_color if accent_from >= 0 and i >= accent_from else base_color
		var alpha: float = clampf(k * 2.5, 0.0, 1.0)
		var at := Vector2(x, baseline + offset)
		draw_char_outline(_font, at, letter, font_size, OUTLINE_SIZE, Color(UiStyle.OUTLINE, alpha * 0.8))
		draw_char(_font, at, letter, font_size, Color(color, alpha))
		x += _font.get_char_size(letter.unicode_at(0), font_size).x


## Hedefi biraz aşıp geri gelen yumuşama (harf yere "oturur").
static func _ease_out_back(k: float) -> float:
	var c1: float = 1.70158
	var c3: float = c1 + 1.0
	return 1.0 + c3 * pow(k - 1.0, 3.0) + c1 * pow(k - 1.0, 2.0)
