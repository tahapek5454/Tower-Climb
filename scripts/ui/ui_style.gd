class_name UiStyle
extends RefCounted
## Arayüzün ortak görünümü (HUD, radyo, oyun sonu): koyu arduvaz yarı saydam kart, ince soluk turkuaz
## çerçeve, yuvarlak köşe; açık yazı, soluk başlık, turkuaz vurgu, altın kombo (ödül rengi).
## Neon/parlak renk yok; dünya paletiyle uyumlu.

const PANEL := Color(0.09, 0.10, 0.15, 0.85)
const BORDER := Color(0.40, 0.66, 0.68, 0.45)
const TEXT := Color(0.88, 0.90, 0.95)
const TEXT_DIM := Color(0.60, 0.65, 0.76)
const ACCENT := Color(0.42, 0.74, 0.76)
const COMBO := Color(0.98, 0.84, 0.45)
const TRACK := Color(1.0, 1.0, 1.0, 0.14)
## Ekrandaki (dünya üstü) yazıların dış çizgisi: karakter ve platformlarla aynı koyu lacivert.
const OUTLINE := Color(0.09, 0.10, 0.18)
const CORNER_RADIUS: int = 10


## Kart zemini. padding: iç boşluk (px).
static func panel_style(padding: float = 0.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(CORNER_RADIUS)
	style.set_content_margin_all(padding)
	return style


## Yazı etiketi (dış çizgisiz; kartın üstünde okunur).
static func label(font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var result := Label.new()
	result.add_theme_font_size_override(&"font_size", font_size)
	result.add_theme_color_override(&"font_color", color)
	result.horizontal_alignment = align
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result
