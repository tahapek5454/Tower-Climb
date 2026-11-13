class_name HourglassArt
extends RefCounted
## Kum saatinin 2D çizimi ve ortak renkleri: ahşap üst/alt tabla, yan direkler, cam hazneler, akan kum.
## Toplanabilir nesne ve ekran efekti bunu kullanır. Orijin ortada (boyun); ölçek 1'de ~30 x 44 px.

const WOOD := Color(0.62, 0.42, 0.27)
const WOOD_LIGHT := Color(0.78, 0.56, 0.36)
const GLASS := Color(0.82, 0.92, 1.0, 0.38)
const SAND := Color(0.99, 0.82, 0.47)
const GLOW := Color(0.62, 0.68, 1.0)
const SPARKLE := Color(0.86, 0.90, 1.0)

## Cam haznenin yarı genişliği (y'ye göre, üst hazne için; alt hazne aynası): ağız, omuz, boyun.
const MOUTH := Vector2(10.0, 16.0)
const SHOULDER := Vector2(9.0, 8.0)
const NECK := Vector2(2.0, 1.0)
const BOARD := Rect2(-15.0, -22.0, 30.0, 5.5)
const POST_X: float = 12.5
const OUTLINE_WIDTH: float = 2.0


## sand_top: üst haznedeki kum oranı (1 = dolu, 0 = boş); kum ortadan aşağı akar.
static func draw(canvas: CanvasItem, sand_top: float = 0.6) -> void:
	var level: float = clampf(sand_top, 0.0, 1.0)
	# Yan direkler (arkada).
	for side: float in [-1.0, 1.0]:
		canvas.draw_line(Vector2(side * POST_X, -18.0), Vector2(side * POST_X, 18.0), WOOD, 3.0, true)
	var glass: PackedVector2Array = _glass_points()
	canvas.draw_colored_polygon(glass, GLASS)
	_draw_sand(canvas, level)
	PlatformDraw.outline(canvas, glass, OUTLINE_WIDTH)
	# Camda ince parlaklık.
	canvas.draw_line(Vector2(-6.5, -13.0), Vector2(-5.5, -7.0), Color(1.0, 1.0, 1.0, 0.6), 1.5, true)
	# Üst ve alt tabla.
	for flip: float in [1.0, -1.0]:
		var board := Rect2(BOARD.position.x, BOARD.position.y if flip > 0.0 else -BOARD.end.y,
				BOARD.size.x, BOARD.size.y)
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(board, 2.5), WOOD, OUTLINE_WIDTH)
		canvas.draw_line(board.position + Vector2(3.0, 1.6), Vector2(board.end.x - 3.0, board.position.y + 1.6),
				WOOD_LIGHT, 1.4, true)


## Camın dış çizgisi: üst ağızdan boyuna, boyundan alt ağza (sağ taraf), sonra sol taraf yukarı.
static func _glass_points() -> PackedVector2Array:
	var right := PackedVector2Array([
		Vector2(MOUTH.x, -MOUTH.y), Vector2(SHOULDER.x, -SHOULDER.y), Vector2(NECK.x, -NECK.y),
		Vector2(NECK.x, NECK.y), Vector2(SHOULDER.x, SHOULDER.y), Vector2(MOUTH.x, MOUTH.y),
	])
	var points := PackedVector2Array(right)
	for i: int in range(right.size() - 1, -1, -1):
		points.append(Vector2(-right[i].x, right[i].y))
	return points


## Haznenin y'deki yarı genişliği (y: 0 boyun, MOUTH.y ağız; iki hazne için |y|).
static func _half_width(depth: float) -> float:
	if depth <= NECK.y:
		return NECK.x
	if depth <= SHOULDER.y:
		return lerpf(NECK.x, SHOULDER.x, (depth - NECK.y) / (SHOULDER.y - NECK.y))
	return lerpf(SHOULDER.x, MOUTH.x, (depth - SHOULDER.y) / (MOUTH.y - SHOULDER.y))


const SAND_INSET: float = 1.2


static func _draw_sand(canvas: CanvasItem, level: float) -> void:
	if level > 0.02:
		canvas.draw_colored_polygon(top_sand_points(level), SAND)
		# Akan ince kum çizgisi.
		canvas.draw_line(Vector2(0.0, -NECK.y), Vector2(0.0, MOUTH.y - 1.0), SAND, 1.4)
	canvas.draw_colored_polygon(bottom_sand_points(level), SAND)


## Üst haznedeki kum: boyundan yukarı `level` oranında dolu, yüzeyi düz.
static func top_sand_points(level: float) -> PackedVector2Array:
	var surface: float = lerpf(NECK.y + 1.5, MOUTH.y - 2.5, clampf(level, 0.0, 1.0))
	var w: float = _half_width(surface) - SAND_INSET
	var points := PackedVector2Array([Vector2(-w, -surface), Vector2(w, -surface)])
	if surface > SHOULDER.y:
		points.append(Vector2(SHOULDER.x - SAND_INSET, -SHOULDER.y))
	points.append(Vector2(NECK.x - 0.6, -NECK.y))
	points.append(Vector2(-NECK.x + 0.6, -NECK.y))
	if surface > SHOULDER.y:
		points.append(Vector2(-SHOULDER.x + SAND_INSET, -SHOULDER.y))
	return points


## Alt haznedeki kum tepeciği: yüksekliği akan kumla (1 - level) büyür.
static func bottom_sand_points(level: float) -> PackedVector2Array:
	var mound: float = lerpf(2.0, 11.0, 1.0 - clampf(level, 0.0, 1.0))
	var base: float = MOUTH.y - 0.8
	var half: float = MOUTH.x - SAND_INSET
	return PackedVector2Array([
		Vector2(-half, base), Vector2(half, base), Vector2(half * 0.55, base - mound * 0.65),
		Vector2(0.0, base - mound), Vector2(-half * 0.55, base - mound * 0.65),
	])
