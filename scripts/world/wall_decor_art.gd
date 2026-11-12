class_name WallDecorArt
extends RefCounted
## Duvar süslerinin çizimi (meşale, pencere, sancak, flama dizisi). Koyu dış çizgili, düz renkli.
## Orijin süsün asılı olduğu nokta. time: canlandırma (alev, dalgalanma). Işık veren parçalar
## `lights` dizisine [konum, boyut, renk] ekler (PlatformGlow çizer).

const OUTLINE := PlatformDraw.OUTLINE_COLOR
const IRON := Color(0.22, 0.21, 0.26)
const WOOD := Color(0.45, 0.33, 0.24)
const FLAME_OUTER := Color(0.98, 0.78, 0.42)
const FLAME_INNER := Color(1.0, 0.94, 0.72)
const ROPE := Color(0.56, 0.48, 0.38)
const CREAM := Color(0.86, 0.80, 0.66)
## Temalara göre sancak/flama renkleri (duvarla zıt, turuncu/altın değil: o renkler ödül anlamında).
const CLOTH_COLORS: Array[Array] = [
	[Color(0.62, 0.25, 0.30), Color(0.27, 0.55, 0.56)],
	[Color(0.62, 0.26, 0.28), CREAM],
	[Color(0.26, 0.52, 0.56), CREAM],
	[Color(0.62, 0.25, 0.32), Color(0.24, 0.32, 0.56)],
	[Color(0.27, 0.58, 0.64), Color(0.58, 0.24, 0.38)],
]


## Duvara takılı meşale: demir kelepçe, sap, titreşen alev; sıcak ışık.
static func torch(canvas: CanvasItem, time: float, phase: float, lights: Array) -> void:
	PlatformDraw.shape(canvas, PackedVector2Array([Vector2(-7.0, 6.0), Vector2(7.0, 6.0),
			Vector2(4.0, 14.0), Vector2(-4.0, 14.0)]), IRON, 1.4)
	var stick := PackedVector2Array([Vector2(-2.5, -8.0), Vector2(2.5, -8.0), Vector2(1.8, 22.0), Vector2(-1.8, 22.0)])
	PlatformDraw.shape(canvas, stick, WOOD, 1.4)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(-5.0, -11.0, 10.0, 6.0), 2.0), IRON, 1.3)
	var flicker: float = sin(time * 9.0 + phase) * 0.5 + sin(time * 13.7 + phase * 2.0) * 0.5
	_flame(canvas, Vector2(0.0, -11.0), 9.0, 20.0 + flicker * 3.0, flicker)
	lights.append([Vector2(0.0, -18.0), Tuning.LIGHT_TORCH_SIZE, Color(FLAME_OUTER, Tuning.LIGHT_TORCH_ALPHA)])


## Damla biçiminde alev: dış ve iç katman; tepe yana hafifçe sallanır.
static func _flame(canvas: CanvasItem, base: Vector2, width: float, height: float, sway: float) -> void:
	for layer: int in 2:
		var w: float = width * (1.0 if layer == 0 else 0.55)
		var h: float = height * (1.0 if layer == 0 else 0.6)
		var points := PlatformDraw.arc(base + Vector2(0.0, -w * 0.5), w * 0.5, 0.0, PI, 6)
		points.append(base + Vector2(sway * 3.0, -h))
		if layer == 0:
			PlatformDraw.shape(canvas, points, FLAME_OUTER, 1.3)
		else:
			canvas.draw_colored_polygon(points, FLAME_INNER)


## Kemerli pencere: taş çerçeve, camda temanın gökyüzü, kayıt (haç), denizlik. Gece'de ay ve yıldız.
static func window(canvas: CanvasItem, theme: int, rng: RandomNumberGenerator, lights: Array) -> void:
	var colors: Dictionary = WorldPalette.colors_at(float(theme))
	var size := Vector2(rng.randf_range(38.0, 52.0), rng.randf_range(58.0, 80.0))
	var frame := _arched(Rect2(Vector2(-size.x * 0.5 - 6.0, -6.0), size + Vector2(12.0, 10.0)))
	PlatformDraw.shape(canvas, frame, (colors[&"interior_stone"] as Color).lightened(0.12), 1.6)
	var glass_rect := Rect2(Vector2(-size.x * 0.5, 0.0), size)
	var glass := _arched(glass_rect)
	canvas.draw_colored_polygon(glass, colors[&"sky_top"])
	var lower := Rect2(glass_rect.position + Vector2(0.0, size.y * 0.55), Vector2(size.x, size.y * 0.45))
	canvas.draw_colored_polygon(PlatformDraw.rounded_rect(lower, 0.0), colors[&"sky_bottom"])
	if theme == 4:
		canvas.draw_circle(Vector2(size.x * 0.15, size.y * 0.3), 6.0, Color(0.92, 0.92, 0.84), true, -1.0, true)
		for i: int in 4:
			var star := Vector2(rng.randf_range(-size.x * 0.4, size.x * 0.4), rng.randf_range(6.0, size.y * 0.6))
			canvas.draw_circle(star, 1.0, Color(0.9, 0.9, 1.0), true, -1.0, true)
	else:
		var cloud := Vector2(rng.randf_range(-size.x * 0.2, size.x * 0.2), size.y * 0.5)
		canvas.draw_circle(cloud, 5.0, colors[&"cloud"], true, -1.0, true)
		canvas.draw_circle(cloud + Vector2(6.0, 1.5), 4.0, colors[&"cloud"], true, -1.0, true)
	canvas.draw_line(Vector2(0.0, size.x * 0.25), Vector2(0.0, size.y), IRON, 2.5, true)
	canvas.draw_line(Vector2(-size.x * 0.5, size.y * 0.5), Vector2(size.x * 0.5, size.y * 0.5), IRON, 2.5, true)
	PlatformDraw.outline(canvas, glass, 1.6)
	var sill := PlatformDraw.rounded_rect(Rect2(-size.x * 0.5 - 9.0, size.y + 2.0, size.x + 18.0, 6.0), 2.0)
	PlatformDraw.shape(canvas, sill, (colors[&"interior_stone"] as Color).lightened(0.18), 1.4)
	lights.append([Vector2(0.0, size.y * 0.5), Vector2(size.x * 2.6, size.y * 1.8),
			Color(colors[&"sky_bottom"], Tuning.LIGHT_WINDOW_ALPHA)])


## Üstü yarım daire, altı düz dikdörtgen.
static func _arched(rect: Rect2) -> PackedVector2Array:
	var radius: float = rect.size.x * 0.5
	var center := Vector2(rect.get_center().x, rect.position.y + radius)
	var points := PlatformDraw.arc(center, radius, PI, TAU, 10)
	points.append(rect.end)
	points.append(Vector2(rect.position.x, rect.end.y))
	return points


## Sancak: demir çubuktan sarkan, alt ucu çatallı kumaş; ortasında arma; rüzgârda hafif dalgalanır.
static func banner(canvas: CanvasItem, theme: int, rng: RandomNumberGenerator, time: float, lights: Array) -> void:
	var palette: Array = CLOTH_COLORS[posmod(theme, CLOTH_COLORS.size())]
	var cloth_color: Color = palette[rng.randi_range(0, 1)]
	var width: float = rng.randf_range(30.0, 40.0)
	var length: float = rng.randf_range(60.0, 92.0)
	var phase: float = rng.randf_range(0.0, TAU)
	var steps: int = 8
	var left_edge := PackedVector2Array()
	var right_edge := PackedVector2Array()
	for i: int in steps + 1:
		var t: float = float(i) / steps
		var sway: float = sin(time * 1.6 + phase + t * 2.2) * t * 4.0
		left_edge.append(Vector2(-width * 0.5 + sway, t * length))
		right_edge.append(Vector2(width * 0.5 + sway, t * length))
	var tip_sway: float = sin(time * 1.6 + phase + 2.2) * 4.0
	var cloth := PackedVector2Array(left_edge)
	cloth.append(Vector2(tip_sway, length - 14.0))
	right_edge.reverse()
	cloth.append_array(right_edge)
	PlatformDraw.shape(canvas, cloth, cloth_color, 1.6)
	var band := cloth_color.lightened(0.3)
	canvas.draw_line(left_edge[1], right_edge[steps - 1], band, 3.0, true)
	var emblem_center: Vector2 = (left_edge[4] + right_edge[steps - 4]) * 0.5
	var emblem_kind: int = rng.randi_range(0, 2)
	match emblem_kind:
		0: canvas.draw_circle(emblem_center, 6.0, band, true, -1.0, true)
		1: PlatformDraw.shape(canvas, PackedVector2Array([emblem_center + Vector2(0.0, -8.0),
				emblem_center + Vector2(6.0, 0.0), emblem_center + Vector2(0.0, 8.0),
				emblem_center + Vector2(-6.0, 0.0)]), band, 1.0)
		2: PlatformDraw.sparkle(canvas, emblem_center, 8.0, band)
	var rod := PlatformDraw.rounded_rect(Rect2(-width * 0.5 - 7.0, -3.0, width + 14.0, 5.0), 2.5)
	PlatformDraw.shape(canvas, rod, IRON, 1.4)
	for side: float in [-1.0, 1.0]:
		canvas.draw_circle(Vector2((width * 0.5 + 8.0) * side, -0.5), 3.5, IRON, true, -1.0, true)


## Flama dizisi: iki uç arasında sarkan ip ve renkli üçgen bayrakçıklar; Gece'de ışıklı ampuller.
static func bunting(canvas: CanvasItem, theme: int, span: float, rng: RandomNumberGenerator,
		time: float, lights: Array) -> void:
	var sag: float = rng.randf_range(18.0, 36.0)
	var count: int = maxi(4, int(span / 26.0))
	var rope := PackedVector2Array()
	for i: int in count * 2 + 1:
		var t: float = float(i) / (count * 2)
		rope.append(Vector2(lerpf(-span * 0.5, span * 0.5, t), sin(PI * t) * sag))
	canvas.draw_polyline(rope, OUTLINE, 3.2, true)
	canvas.draw_polyline(rope, ROPE, 1.6, true)
	var palette: Array = CLOTH_COLORS[posmod(theme, CLOTH_COLORS.size())]
	var colors: Array = [palette[0], palette[1], CREAM]
	for i: int in count:
		var a: Vector2 = rope[i * 2 + 0]
		var b: Vector2 = rope[i * 2 + 1]
		var mid: Vector2 = (a + b) * 0.5
		if theme == 4:
			var glow: Color = Color(0.70, 0.92, 0.95) if i % 2 == 0 else Color(0.95, 0.84, 0.95)
			var bulb: Vector2 = mid + Vector2(0.0, 5.0)
			canvas.draw_circle(bulb, 4.0, OUTLINE, true, -1.0, true)
			canvas.draw_circle(bulb, 2.8, glow, true, -1.0, true)
			var pulse: float = 0.75 + 0.25 * sin(time * 2.0 + i * 1.3)
			lights.append([bulb, Tuning.LIGHT_BULB_SIZE, Color(glow, Tuning.LIGHT_BULB_ALPHA * pulse)])
		else:
			var flutter: float = sin(time * 2.4 + i * 0.9) * 2.0
			var flag := PackedVector2Array([a + Vector2(1.0, 0.0), b + Vector2(-1.0, 0.0),
					mid + Vector2(flutter, rng.randf_range(16.0, 20.0))])
			PlatformDraw.shape(canvas, flag, colors[i % colors.size()], 1.3)
	for end: Vector2 in [rope[0], rope[rope.size() - 1]]:
		canvas.draw_circle(end, 3.5, IRON, true, -1.0, true)
