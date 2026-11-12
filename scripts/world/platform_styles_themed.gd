class_name PlatformStylesThemed
extends RefCounted
## Temaya özel platform stilleri: ahşap kalas, perçinli metal, buz, kristal.
## Koyu dış çizgili, düz renkli (toon). Rastgelelik verilen rng'den.

const OUTLINE_WIDTH: float = 1.6


## Ahşap kalas: tahta damarları, ek yerleri, çiviler, uçlarda halat sargısı.
static func plank(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS - 4.0
	var left: float = -width * 0.5
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, thickness), 3.0)
	PlatformDraw.shape(canvas, body, color)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(left + 1.0, 0.5, width - 2.0, 4.0), 2.0),
			color.lightened(0.2))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 1.0, thickness - 5.0, width - 2.0, 4.5), 2.0), color.darkened(0.25))
	for line: int in 2:
		var y: float = 8.0 + line * 5.5
		var grain := PackedVector2Array()
		for i: int in int(width / 12.0) + 1:
			var x: float = left + 4.0 + i * 12.0
			if x > -left - 4.0:
				break
			grain.append(Vector2(x, y + sin(x * 0.09 + line * 2.0) * 1.2))
		if grain.size() > 1:
			canvas.draw_polyline(grain, color.darkened(0.2), 1.0, true)
	var x_seam: float = left + rng.randf_range(60.0, 110.0)
	while x_seam < -left - 40.0:
		canvas.draw_line(Vector2(x_seam, 1.0), Vector2(x_seam, thickness - 1.0), color.darkened(0.45), 1.5, true)
		for side: float in [-5.0, 5.0]:
			canvas.draw_circle(Vector2(x_seam + side, 6.0), 1.6, color.darkened(0.6), true, -1.0, true)
		x_seam += rng.randf_range(70.0, 120.0)
	for side: float in [-1.0, 1.0]:
		_rope(canvas, -left * side - side * 16.0, thickness, color)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)


static func _rope(canvas: CanvasItem, center_x: float, thickness: float, wood: Color) -> void:
	var rope := Color(0.72, 0.64, 0.50).lerp(wood, 0.25)
	for i: int in 3:
		var x: float = center_x - 5.0 + i * 4.0
		var band := PackedVector2Array([Vector2(x, -1.0), Vector2(x + 3.0, -1.0),
				Vector2(x + 1.0, thickness + 1.0), Vector2(x - 2.0, thickness + 1.0)])
		PlatformDraw.shape(canvas, band, rope, 1.0)


## Perçinli metal levha: üstte parlak kenar, ortada perçin sırası, altta koyu dudak, uçlarda zincir.
static func metal(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS - 2.0
	var left: float = -width * 0.5
	for side: float in [-1.0, 1.0]:
		_chain(canvas, Vector2(-left * side - side * 22.0, thickness), color)
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, thickness), 4.0)
	PlatformDraw.shape(canvas, body, color.darkened(0.3))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 2.0, 2.0, width - 4.0, thickness - 8.0), 3.0), color)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(left + 2.0, 1.0, width - 4.0, 3.0), 1.5),
			color.lightened(0.3))
	var count: int = maxi(2, int(width / 30.0))
	for i: int in count:
		var x: float = lerpf(left + 12.0, -left - 12.0, float(i) / (count - 1))
		canvas.draw_circle(Vector2(x, 10.0), 2.6, color.darkened(0.45), true, -1.0, true)
		canvas.draw_circle(Vector2(x - 0.8, 9.2), 1.0, color.lightened(0.4), true, -1.0, true)
	if rng.randf() < 0.6:
		var seam: float = rng.randf_range(left + width * 0.3, -left - width * 0.3)
		canvas.draw_line(Vector2(seam, 3.0), Vector2(seam, thickness - 6.0), color.darkened(0.4), 1.4, true)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)


static func _chain(canvas: CanvasItem, top: Vector2, color: Color) -> void:
	for i: int in 3:
		var center: Vector2 = top + Vector2(0.0, 3.0 + i * 6.0)
		var link := PlatformDraw.rounded_rect(Rect2(center - Vector2(2.5, 3.5), Vector2(5.0, 7.0)), 2.5)
		PlatformDraw.outline(canvas, link, 1.4)
		canvas.draw_polyline(link + PackedVector2Array([link[0]]), color.darkened(0.2), 0.8, true)


## Buz levhası: yuvarlak hatlı, üstü kırağılı, parlak yansıma çizgileri, altında sarkan saçaklar.
static func ice(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS - 2.0
	var left: float = -width * 0.5
	var x: float = left + rng.randf_range(10.0, 22.0)
	while x < -left - 10.0:
		var length: float = rng.randf_range(7.0, 20.0)
		var half_width: float = rng.randf_range(3.0, 6.0)
		var icicle := PackedVector2Array([Vector2(x - half_width, thickness - 3.0),
				Vector2(x + half_width, thickness - 3.0), Vector2(x + 0.5, thickness + length)])
		PlatformDraw.shape(canvas, icicle, color.lightened(0.12), 1.3)
		x += rng.randf_range(14.0, 34.0)
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, thickness), 9.0)
	PlatformDraw.shape(canvas, body, color.darkened(0.12))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
			Rect2(left + 2.0, 0.5, width - 4.0, thickness - 7.0), 7.0), color)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(left + 3.0, 0.5, width - 6.0, 4.5), 2.5),
			color.lightened(0.45))
	var glint: Color = color.lightened(0.55)
	for i: int in int(width / 70.0) + 1:
		var gx: float = rng.randf_range(left + 14.0, -left - 20.0)
		canvas.draw_line(Vector2(gx, 13.0), Vector2(gx + 5.0, 7.0), glint, 2.0, true)
		canvas.draw_line(Vector2(gx + 5.0, 14.0), Vector2(gx + 8.0, 10.5), glint, 1.5, true)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)


## Kristal: sivri uçlu, alt kenarı kırık kırık; yüzeyler sırayla açık/koyu, küçük parıltılar.
static func crystal(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var left: float = -width * 0.5
	var steps: int = maxi(3, int(width / 34.0))
	var bottom := PackedVector2Array()
	for i: int in steps + 1:
		var u: float = float(i) / steps
		var depth: float = thickness * (0.7 if i % 2 == 0 else 1.15) + rng.randf_range(-2.0, 3.0)
		bottom.append(Vector2(lerpf(-left - 10.0, left + 10.0, u), depth))
	var outline := PackedVector2Array([Vector2(left + 8.0, 0.0), Vector2(-left - 8.0, 0.0),
			Vector2(-left, thickness * 0.35)])
	outline.append_array(bottom)
	outline.append(Vector2(left, thickness * 0.35))
	PlatformDraw.shape(canvas, outline, color.darkened(0.2))
	# Yüzeyler: üst kenardaki noktalardan alt köşelere üçgenler, sırayla açık/koyu.
	for i: int in steps:
		var a: Vector2 = bottom[i]
		var b: Vector2 = bottom[i + 1]
		var top_point := Vector2((a.x + b.x) * 0.5, 5.0)
		var facet_tone: float = 0.14 if i % 2 == 0 else -0.06
		canvas.draw_colored_polygon(PackedVector2Array([top_point, a, b]), PlatformDraw.tone(color, facet_tone))
	PlatformDraw.shape(canvas, PackedVector2Array([Vector2(left + 8.0, 0.0), Vector2(-left - 8.0, 0.0),
			Vector2(-left - 6.0, 5.0), Vector2(left + 6.0, 5.0)]), color.lightened(0.35))
	for i: int in int(width / 90.0) + 1:
		PlatformDraw.sparkle(canvas, Vector2(rng.randf_range(left + 16.0, -left - 16.0),
				rng.randf_range(9.0, 18.0)), rng.randf_range(3.0, 5.0), color.lightened(0.7))
	PlatformDraw.outline(canvas, outline, OUTLINE_WIDTH)
