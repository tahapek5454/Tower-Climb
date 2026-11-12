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
## Birincil düğme (ana eylem) üzerindeki koyu yazı ve devre dışı yazı.
const TEXT_ON_ACCENT := Color(0.08, 0.12, 0.16)
const DISABLED := Color(0.45, 0.48, 0.56, 0.6)
## Düğme/anahtar yüzeyleri: sakin hâl, vurgulu (odak/üzerine gelme), basılı.
const BUTTON_IDLE := Color(1.0, 1.0, 1.0, 0.05)
const BUTTON_FOCUS := Color(0.42, 0.74, 0.76, 0.17)
const BUTTON_PRESSED := Color(0.42, 0.74, 0.76, 0.32)


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


## Düğme yüzeyi: dolgu + isteğe bağlı çerçeve, yuvarlak köşe.
static func button_style(fill: Color, border: Color = Color(0.0, 0.0, 0.0, 0.0), border_width: int = 0,
		h_margin: float = 20.0, v_margin: float = 9.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(CORNER_RADIUS)
	style.content_margin_left = h_margin
	style.content_margin_right = h_margin
	style.content_margin_top = v_margin
	style.content_margin_bottom = v_margin
	return style


## Küçük bölüm başlığı (soluk, büyük harf).
static func section_label(text: String) -> Label:
	var result: Label = label(11, TEXT_DIM)
	result.text = text.to_upper()
	return result


## Klavye tuşu kapağı (kontroller sayfası): küçük yuvarlak köşeli etiket.
static func key_cap(text: String) -> Control:
	var cap := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = BUTTON_IDLE
	style.border_color = Color(1.0, 1.0, 1.0, 0.22)
	style.set_border_width_all(1)
	style.border_width_bottom = 2
	style.set_corner_radius_all(6)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 3.0
	cap.add_theme_stylebox_override(&"panel", style)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption: Label = label(13, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	caption.text = text
	cap.add_child(caption)
	return cap


## Boş dikey aralık (fareyi engellemez).
static func spacer(height: float) -> Control:
	var result := Control.new()
	result.custom_minimum_size.y = height
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


## Ayar satırı: solda başlık, sağda denetim (anahtar, kaydırıcı...). Denetim genişliği min_width.
static func row(caption: String, control: Control, min_width: float = 0.0) -> HBoxContainer:
	var result := HBoxContainer.new()
	result.add_theme_constant_override(&"separation", 16)
	var title: Label = label(15, TEXT)
	title.text = caption
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	result.add_child(title)
	control.custom_minimum_size.x = maxf(control.custom_minimum_size.x, min_width)
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	result.add_child(control)
	return result
