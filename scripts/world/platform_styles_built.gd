class_name PlatformStylesBuilt
extends RefCounted
## "Yapılmış" platform stilleri: yuvarlak taş dizisi, taş köprü (kemerli), kütük, kafes köprü, boru.
## Koyu dış çizgili, düz renkli (toon). Her biri rng ile kendi içinde de çeşitlenir.

const OUTLINE_WIDTH: float = 1.6


## Yuvarlak taş dizisi: farklı boyda iri çakıllar yan yana; arkada koyu harç.
static func cobble(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var left: float = -width * 0.5
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 3.0, 4.0, width - 6.0, thickness - 6.0), 6.0), color.darkened(0.5))
	var size_min: float = rng.randf_range(14.0, 20.0)
	var x: float = left
	while x < -left - 2.0:
		var stone_width: float = minf(rng.randf_range(size_min, size_min + 18.0), -left - x)
		if -left - (x + stone_width) < size_min * 0.7:
			stone_width = -left - x
		var height: float = rng.randf_range(thickness - 6.0, thickness + 2.0)
		var center := Vector2(x + stone_width * 0.5, height * 0.5 + rng.randf_range(-1.0, 0.5))
		var radii := Vector2(stone_width * 0.5 + 0.8, height * 0.5)
		var stone_color: Color = PlatformDraw.tone(color, rng.randf_range(-0.1, 0.1))
		var body: PackedVector2Array = PlatformDraw.ellipse(center, radii, 18)
		PlatformDraw.shape(canvas, body, stone_color.darkened(0.2))
		PlatformDraw.shape(canvas, PlatformDraw.ellipse(center - Vector2(0.0, 2.0), radii - Vector2(2.5, 3.0), 18),
				stone_color)
		canvas.draw_circle(center + Vector2(-radii.x * 0.35, -radii.y * 0.45), minf(radii.x, radii.y) * 0.28,
				stone_color.lightened(0.25), true, -1.0, true)
		PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)
		x += stone_width


## Taş köprü: üstte taş döşeme, altında bir veya iki kemer, kemerlerin ortasında kilit taşı.
static func arch(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var deck_height: float = 13.0
	var left: float = -width * 0.5
	var arches: int = 2 if width > 260.0 and rng.randf() < 0.6 else 1
	var span: float = width / arches
	for i: int in arches:
		var center := Vector2(left + span * (i + 0.5), deck_height - 1.0)
		var outer: float = minf(span * 0.5 - 4.0, rng.randf_range(26.0, 40.0))
		var band: PackedVector2Array = PlatformDraw.arc_band(center, outer - 7.0, outer, 0.0, PI, 12)
		PlatformDraw.shape(canvas, band, color.darkened(0.22), OUTLINE_WIDTH)
		var key := Rect2(center + Vector2(-4.0, outer - 9.0), Vector2(8.0, 11.0))
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(key, 2.0), color.lightened(0.08), 1.2)
	var deck: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, deck_height), 4.0)
	PlatformDraw.shape(canvas, deck, color.darkened(0.12))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(left + 1.5, 0.5, width - 3.0, 4.0), 2.0),
			color.lightened(0.2))
	var x: float = left + rng.randf_range(20.0, 40.0)
	while x < -left - 16.0:
		canvas.draw_line(Vector2(x, 4.5), Vector2(x, deck_height - 1.0), color.darkened(0.45), 1.3, true)
		x += rng.randf_range(24.0, 44.0)
	PlatformDraw.outline(canvas, deck, OUTLINE_WIDTH)


## Kütük: yan yatmış yuvarlak gövde, kabuk çizgileri, budaklar, bir ucunda yıllık halkalar.
static func wood_log(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var height: float = rng.randf_range(20.0, 26.0)
	var left: float = -width * 0.5
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, height), height * 0.5, 6)
	PlatformDraw.shape(canvas, body, color.darkened(0.15))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 2.0, 1.0, width - 4.0, height * 0.55), height * 0.27, 5), color)
	for i: int in int(width / 14.0):
		var start := Vector2(rng.randf_range(left + 10.0, -left - 24.0), rng.randf_range(5.0, height - 5.0))
		canvas.draw_line(start, start + Vector2(rng.randf_range(8.0, 18.0), 0.0), color.darkened(0.4), 1.2, true)
	for i: int in rng.randi_range(0, 2):
		var knot := Vector2(rng.randf_range(left + 20.0, -left - 30.0), height * 0.55)
		PlatformDraw.shape(canvas, PlatformDraw.ellipse(knot, Vector2(4.0, 3.0), 10), color.darkened(0.35), 1.0)
	var end_side: float = 1.0 if rng.randf() < 0.5 else -1.0
	var ring_center := Vector2((width * 0.5 - height * 0.32) * end_side, height * 0.5)
	var ring_radii := Vector2(height * 0.32, height * 0.48)
	var rings := Color(0.80, 0.70, 0.52).lerp(color, 0.35)
	PlatformDraw.shape(canvas, PlatformDraw.ellipse(ring_center, ring_radii, 16), rings, 1.2)
	for scale: float in [0.62, 0.3]:
		PlatformDraw.outline(canvas, PlatformDraw.ellipse(ring_center, ring_radii * scale, 14), 0.9)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)


## Kafes köprü: üstte ince döşeme, altta ince kiriş, aralarında zikzak çubuklar; uçlarda cıvata.
static func truss(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var left: float = -width * 0.5
	var bottom_y: float = rng.randf_range(18.0, 24.0)
	var bay: float = rng.randf_range(16.0, 26.0)
	var bars := PackedVector2Array()
	var count: int = maxi(2, int(width / bay))
	for i: int in count + 1:
		var x: float = lerpf(left + 6.0, -left - 6.0, float(i) / count)
		bars.append(Vector2(x, 6.0 if i % 2 == 0 else bottom_y))
	canvas.draw_polyline(bars, PlatformDraw.OUTLINE_COLOR, 5.0, true)
	canvas.draw_polyline(bars, color.darkened(0.2), 2.6, true)
	var beam: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left + 4.0, bottom_y - 2.0, width - 8.0, 5.0), 2.0)
	PlatformDraw.shape(canvas, beam, color.darkened(0.3), 1.3)
	var deck: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, 8.0), 3.0)
	PlatformDraw.shape(canvas, deck, color)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(left + 1.5, 0.5, width - 3.0, 2.5), 1.2),
			color.lightened(0.3))
	PlatformDraw.outline(canvas, deck, OUTLINE_WIDTH)
	for side: float in [-1.0, 1.0]:
		canvas.draw_circle(Vector2((width * 0.5 - 7.0) * side, 4.0), 2.0, color.darkened(0.5), true, -1.0, true)


## Boru: kalın yatay boru, parlak çizgi, aralıklı flanşlar (cıvatalı); bazen altında vana.
static func pipe(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var height: float = rng.randf_range(16.0, 20.0)
	var left: float = -width * 0.5
	if rng.randf() < 0.5:
		var valve := Vector2(rng.randf_range(left + 30.0, -left - 30.0), height + 7.0)
		canvas.draw_line(valve - Vector2(0.0, 7.0), valve, PlatformDraw.OUTLINE_COLOR, 4.0, true)
		PlatformDraw.shape(canvas, PlatformDraw.ellipse(valve, Vector2(7.0, 2.5), 12), color.darkened(0.35), 1.2)
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 1.0, width, height), height * 0.5, 6)
	PlatformDraw.shape(canvas, body, color.darkened(0.15))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 3.0, 2.0, width - 6.0, height * 0.5), height * 0.25, 5), color)
	canvas.draw_line(Vector2(left + 8.0, 4.5), Vector2(-left - 8.0, 4.5), color.lightened(0.35), 1.8, true)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)
	var x: float = left + rng.randf_range(24.0, 50.0)
	while x < -left - 20.0:
		var flange: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(x - 4.0, -1.0, 8.0, height + 4.0), 2.0)
		PlatformDraw.shape(canvas, flange, color.darkened(0.3), 1.3)
		canvas.draw_circle(Vector2(x, 3.5), 1.3, color.lightened(0.3), true, -1.0, true)
		canvas.draw_circle(Vector2(x, height - 1.0), 1.3, color.lightened(0.3), true, -1.0, true)
		x += rng.randf_range(60.0, 110.0)
