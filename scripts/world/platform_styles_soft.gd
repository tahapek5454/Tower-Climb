class_name PlatformStylesSoft
extends RefCounted
## Yumuşak / doğal platform stilleri: karlı kaya, bulut, parlayan karolar.
## Koyu dış çizgili, düz renkli (toon). Her biri rng ile kendi içinde de çeşitlenir.

const OUTLINE_WIDTH: float = 1.6


## Karlı kaya: koyu kaya levhanın üstünde kalın, dalgalı alt kenarlı kar örtüsü (yer yer damlar).
static func snowdrift(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	PlatformStylesStone.rock(canvas, width, color.darkened(0.42), rng)
	var left: float = -width * 0.5 + 3.0
	var right: float = width * 0.5 - 3.0
	var steps: int = maxi(4, int(width / 14.0))
	var cap := PackedVector2Array()
	for i: int in steps + 1:
		var bump: float = 0.0 if i == 0 or i == steps else rng.randf_range(-3.0, -0.5)
		cap.append(Vector2(lerpf(left, right, float(i) / steps), bump))
	for i: int in range(steps, -1, -1):
		var u: float = float(i) / steps
		var edge_fade: float = minf(u, 1.0 - u) * 2.0
		var depth: float = 4.0 + edge_fade * rng.randf_range(3.0, 8.0)
		if rng.randf() < 0.15 and i > 0 and i < steps:
			depth += rng.randf_range(4.0, 8.0)
		cap.append(Vector2(lerpf(left, right, u), depth))
	var snow: Color = color.lightened(0.55)
	PlatformDraw.shape(canvas, cap, snow, OUTLINE_WIDTH)
	for i: int in int(width / 50.0):
		var glint := Vector2(rng.randf_range(left + 8.0, right - 8.0), rng.randf_range(1.0, 3.0))
		canvas.draw_circle(glint, 1.2, snow.lightened(0.5), true, -1.0, true)


## Bulut: yan yana kabarık daireler; alt kısım gölgeli, üstte açık parıltı. Üstü neredeyse düz.
static func cloud(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var left: float = -width * 0.5
	var puffs: Array[Vector3] = []
	var x: float = left + 10.0
	while x < -left - 9.0:
		var radius: float = rng.randf_range(9.0, 14.0)
		puffs.append(Vector3(x, radius - rng.randf_range(0.0, 2.0), radius))
		x += radius * rng.randf_range(1.0, 1.4)
	puffs.append(Vector3(-left - 10.0, 9.0, 10.0))
	for puff: Vector3 in puffs:
		canvas.draw_circle(Vector2(puff.x, puff.y), puff.z + OUTLINE_WIDTH, PlatformDraw.OUTLINE_COLOR, true, -1.0, true)
	var shade: Color = color.darkened(0.18)
	for puff: Vector3 in puffs:
		canvas.draw_circle(Vector2(puff.x, puff.y), puff.z, shade, true, -1.0, true)
	for puff: Vector3 in puffs:
		canvas.draw_circle(Vector2(puff.x, puff.y - 2.5), puff.z - 2.5, color, true, -1.0, true)
	for i: int in puffs.size():
		if i % 2 == 0:
			var puff: Vector3 = puffs[i]
			canvas.draw_circle(Vector2(puff.x - puff.z * 0.3, puff.y - puff.z * 0.45), puff.z * 0.25,
					color.lightened(0.35), true, -1.0, true)


## Parlayan karolar: koyu taban üstünde kare karolar; aralardaki derzler ve küçük rünler ışıldar.
static func glow_tiles(canvas: CanvasItem, width: float, color: Color, rng: RandomNumberGenerator) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS - 2.0
	var left: float = -width * 0.5
	var glow: Color = color.lightened(0.6)
	var base: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(left, 0.0, width, thickness), 5.0)
	PlatformDraw.shape(canvas, base, glow.lerp(color, 0.4))
	var tile_width: float = rng.randf_range(22.0, 34.0)
	var count: int = maxi(1, roundi((width - 4.0) / tile_width))
	tile_width = (width - 4.0) / count
	for i: int in count:
		var rect := Rect2(left + 2.0 + i * tile_width + 1.2, 1.5, tile_width - 2.4, thickness - 3.0)
		var tile_color: Color = PlatformDraw.tone(color.darkened(0.12), rng.randf_range(-0.06, 0.06))
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(rect, 3.0), tile_color)
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
				Rect2(rect.position, Vector2(rect.size.x, 3.0)), 1.5), tile_color.lightened(0.18))
		if rng.randf() < 0.35:
			PlatformDraw.sparkle(canvas, rect.get_center() + Vector2(0.0, 1.5), 3.5, glow)
	PlatformDraw.outline(canvas, base, OUTLINE_WIDTH)
