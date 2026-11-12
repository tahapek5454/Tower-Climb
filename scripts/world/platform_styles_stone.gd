class_name PlatformStylesStone
extends RefCounted
## Taş platform stilleri: düzensiz taş örgü ve kaya levha. Hepsi koyu dış çizgili, düz renkli
## (toon). Rastgelelik verilen rng'den: aynı kat hep aynı görünür.

const OUTLINE_WIDTH: float = 1.6


## Düzensiz taş örgü: farklı boyda, hafif farklı yükseklik ve tonda, köşeleri farklı yuvarlak taşlar;
## aralarında koyu harç, bazılarında çatlak.
static func masonry(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var left: float = -width * 0.5
	var mortar: PackedVector2Array = PlatformDraw.rounded_rect(
			Rect2(left + 2.0, 3.0, width - 4.0, thickness - 4.0), 4.0)
	PlatformDraw.shape(canvas, mortar, color.darkened(0.55))

	var x: float = left
	while x < -left - 1.0:
		var length: float = rng.randf_range(26.0, 66.0)
		if -left - (x + length) < 22.0:
			length = -left - x
		var top: float = rng.randf_range(-1.5, 0.8)
		var bottom: float = thickness + rng.randf_range(-3.5, 2.5)
		var rect := Rect2(x + 1.2, top, length - 2.4, bottom - top)
		_stone(canvas, rect, PlatformDraw.tone(color, rng.randf_range(-0.09, 0.09)), rng)
		x += length


static func _stone(canvas: CanvasItem, rect: Rect2, color: Color, rng: RandomNumberGenerator) -> void:
	var radius: float = rng.randf_range(3.0, 8.0)
	var body: PackedVector2Array = PlatformDraw.rounded_rect(rect, radius)
	PlatformDraw.shape(canvas, body, color.darkened(0.22))
	var face := Rect2(rect.position + Vector2(1.5, 4.5), rect.size - Vector2(3.0, 9.0))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(face, radius * 0.6), color)
	var cap := Rect2(rect.position + Vector2(1.5, 1.0), Vector2(rect.size.x - 3.0, 4.5))
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(cap, minf(radius, 2.5)), color.lightened(0.2))
	if rng.randf() < 0.3:
		var start := Vector2(rng.randf_range(rect.position.x + 6.0, rect.end.x - 6.0), rect.position.y + 5.0)
		canvas.draw_polyline(PackedVector2Array([start, start + Vector2(2.5, 4.0),
				start + Vector2(0.5, 7.5), start + Vector2(3.0, 11.0)]), color.darkened(0.45), 1.2, true)
	PlatformDraw.outline(canvas, body, OUTLINE_WIDTH)


## Kaya levha: tek parça, organik biçim. Üstü neredeyse düz (hafif tümsekli), altı ortada sarkan
## yumru; açık üst yüz, koyu gövde, birkaç leke ve altında sarkan küçük çakıllar.
static func rock(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var end_radius: float = thickness * 0.5
	var half: float = width * 0.5 - end_radius
	var steps: int = maxi(3, int(width / 18.0))
	var bulge: float = rng.randf_range(7.0, 15.0)

	var top := PackedVector2Array()
	for i: int in steps + 1:
		var bump: float = 0.0 if i == 0 or i == steps else rng.randf_range(-1.2, 0.5)
		top.append(Vector2(lerpf(-half, half, float(i) / steps), bump))
	var bottom := PackedVector2Array()
	for i: int in steps + 1:
		var u: float = float(i) / steps
		var depth: float = thickness * 0.85 + sin(PI * u) * bulge + rng.randf_range(-2.5, 2.5)
		bottom.append(Vector2(lerpf(half, -half, u), depth))

	var outline := PackedVector2Array(top)
	outline.append_array(PlatformDraw.arc(Vector2(half, end_radius), end_radius, -PI * 0.5, PI * 0.35, 4))
	outline.append_array(bottom)
	outline.append_array(PlatformDraw.arc(Vector2(-half, end_radius), end_radius, PI * 0.65, PI * 1.5, 4))

	_hanging_pebbles(canvas, bottom, color, rng)
	PlatformDraw.shape(canvas, outline, color.darkened(0.28))
	var face := PackedVector2Array(top)
	for i: int in range(top.size() - 1, -1, -1):
		face.append(top[i] + Vector2(0.0, 7.0 + sin(float(i) * 1.7) * 1.2))
	PlatformDraw.shape(canvas, face, color)
	var rim := PackedVector2Array(top)
	for i: int in range(top.size() - 1, -1, -1):
		rim.append(top[i] + Vector2(0.0, 2.5))
	PlatformDraw.shape(canvas, rim, color.lightened(0.22))
	for i: int in int(width / 60.0):
		var spot := Vector2(rng.randf_range(-half, half), rng.randf_range(11.0, thickness))
		canvas.draw_circle(spot, rng.randf_range(1.5, 3.0), color.darkened(0.42), true, -1.0, true)
	PlatformDraw.outline(canvas, outline, OUTLINE_WIDTH)


static func _hanging_pebbles(canvas: CanvasItem, bottom: PackedVector2Array, color: Color,
		rng: RandomNumberGenerator) -> void:
	for i: int in rng.randi_range(1, 3):
		var anchor: Vector2 = bottom[rng.randi_range(1, bottom.size() - 2)]
		var radius: float = rng.randf_range(2.5, 4.5)
		var center: Vector2 = anchor + Vector2(rng.randf_range(-4.0, 4.0), radius + 0.5)
		canvas.draw_circle(center, radius, color.darkened(0.35), true, -1.0, true)
		canvas.draw_circle(center, radius, PlatformDraw.OUTLINE_COLOR, false, 1.3, true)
