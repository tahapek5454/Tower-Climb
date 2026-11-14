class_name HeartArt
extends RefCounted
## Kalbin (can) 2D çizimi ve ortak renkleri. Toplanabilir nesne, HUD ve kurtarma efekti bunu çizer.
## Biçim klasik kalp eğrisinden; kırılınca ortadaki zikzak çatlaktan iki yarıma ayrılır.
## Orijin kalbin ortasında; ölçek 1'de ~30 x 27 px.

const RED := Color(0.96, 0.34, 0.45)
const SHADE := Color(0.80, 0.22, 0.36)
const SHINE := Color(1.0, 0.86, 0.88)
const GLOW := Color(1.0, 0.45, 0.55)
const EMPTY := Color(0.30, 0.32, 0.42)

## Eğri birimini piksele çeviren katsayı ve eğrinin dikey ortası (eğri y: -5..17 arası, tepe -12).
const UNIT: float = 0.95
const CENTER_Y: float = 2.5
const SEGMENTS: int = 40
const OUTLINE_WIDTH: float = 2.0
## Çatlak: alttan üste zikzak (eğri biriminde). Alt uçtan önce dikey çıkar: eğri uca neredeyse dikey
## indiği için eğik başlayan çatlak eğriyi keser (çokgen bozulur).
const CRACK: Array[Vector2] = [Vector2(0.0, 17.0), Vector2(0.0, 13.0), Vector2(1.6, 9.0),
		Vector2(-1.6, 4.5), Vector2(1.2, 0.0), Vector2(0.0, -5.0)]


static func draw(canvas: CanvasItem, center: Vector2 = Vector2.ZERO, scale: float = 1.0,
		fill: Color = RED) -> void:
	var points: PackedVector2Array = outline_points(center, scale)
	if fill == EMPTY:
		canvas.draw_colored_polygon(points, fill)
	else:
		# Hacim: koyu tam kalbin üstüne biraz küçük, sol üste kaymış açık kalp (sağ altta gölge şeridi kalır).
		canvas.draw_colored_polygon(points, Color(SHADE, fill.a))
		canvas.draw_colored_polygon(outline_points(center + Vector2(-1.2, -1.4) * scale, scale * 0.86), fill)
		canvas.draw_circle(center + Vector2(-7.5, -7.0) * scale, 2.6 * scale, Color(SHINE, 0.9 * fill.a))
	PlatformDraw.outline(canvas, points, maxf(OUTLINE_WIDTH * scale, 1.0))


## Kırık kalbin bir yarısı. side: -1 sol, 1 sağ (orijin yine bütün kalbin ortası).
static func draw_half(canvas: CanvasItem, side: float, center: Vector2 = Vector2.ZERO,
		scale: float = 1.0) -> void:
	var points: PackedVector2Array = half_points(side, center, scale)
	canvas.draw_colored_polygon(points, RED)
	PlatformDraw.outline(canvas, points, maxf(OUTLINE_WIDTH * scale, 1.0))


## Yarım kalbin çokgeni: üst çukurdan kenar boyunca alt uca, sonra çatlaktan yukarı geri. Çatlağın uçları
## eğrinin uçlarıyla aynı nokta olduğu için atlanır (çakışan nokta çokgen hatası verir).
static func half_points(side: float, center: Vector2 = Vector2.ZERO, scale: float = 1.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	var half: int = floori(SEGMENTS / 2.0)
	for i: int in half + 1:
		points.append(_curve(PI * i / half, side, center, scale))
	for j: int in range(1, CRACK.size() - 1):
		points.append(center + Vector2(CRACK[j].x, CRACK[j].y - CENTER_Y) * UNIT * scale)
	return points


static func outline_points(center: Vector2, scale: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in SEGMENTS:
		points.append(_curve(TAU * i / SEGMENTS, 1.0, center, scale))
	return points


## Klasik kalp eğrisi: t = 0 üst orta çukur, t = π alt uç. side = -1 aynalar.
static func _curve(t: float, side: float, center: Vector2, scale: float) -> Vector2:
	var x: float = 16.0 * pow(sin(t), 3.0) * side
	var y: float = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
	return center + Vector2(x, y - CENTER_Y) * UNIT * scale

