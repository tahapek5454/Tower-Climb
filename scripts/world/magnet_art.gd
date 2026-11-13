class_name MagnetArt
extends RefCounted
## Mıknatısın 2D çizimi ve ortak renkleri: ağzı yukarı bakan at nalı, mercan-kırmızısı gövde, gümüş uçlar.
## Toplanabilir nesne, çekim halkası ve HUD bunu kullanır. Orijin ortada; ölçek 1'de ~30 x 34 px.

const BODY := Color(0.85, 0.46, 0.43)
const BODY_SHADE := Color(0.70, 0.35, 0.36)
const SILVER := Color(0.80, 0.83, 0.88)
const SILVER_LIGHT := Color(0.94, 0.96, 0.99)
const GLOW := Color(0.96, 0.58, 0.55)
const SPARKLE := Color(0.95, 0.90, 0.92)

## Kemerin merkezi, iç/dış yarıçapı; kolların üst ucu ve gümüş uçların boyu (px).
const ARC_CENTER := Vector2(0.0, 3.0)
const INNER: float = 5.5
const OUTER: float = 15.0
const ARM_TOP: float = -9.0
const TIP_TOP: float = -16.0
const TIP_HEIGHT: float = 8.5
const OUTLINE_WIDTH: float = 2.0
## Çekim halkaları: uçlardan yukarı açılan yaylar; sayı, en büyük yarıçap ve yay açıklığı (rad).
const RING_COUNT: int = 2
const RING_REACH: float = 13.0
const RING_SPREAD: float = 1.1


static func draw(canvas: CanvasItem, center: Vector2 = Vector2.ZERO, scale: float = 1.0) -> void:
	var body: PackedVector2Array = body_points(center, scale)
	canvas.draw_colored_polygon(body, BODY)
	# Kemerin alt-sağında hafif gölge, sol-üstte ince parlaklık (ışık soldan-üstten).
	var c: Vector2 = center + ARC_CENTER * scale
	canvas.draw_colored_polygon(PlatformDraw.arc_band(c, INNER * scale, OUTER * scale, 0.15, 1.2, 6), BODY_SHADE)
	canvas.draw_polyline(PlatformDraw.arc(c, (OUTER - 3.0) * scale, PI * 0.62, PI * 0.95, 5),
			Color(1.0, 0.86, 0.82, 0.7), maxf(1.6 * scale, 1.0), true)
	PlatformDraw.outline(canvas, body, maxf(OUTLINE_WIDTH * scale, 1.0))
	for side: float in [-1.0, 1.0]:
		var rect := Rect2(center + Vector2(minf(side * INNER, side * OUTER), TIP_TOP) * scale,
				Vector2(OUTER - INNER, TIP_HEIGHT) * scale)
		var x0: float = rect.position.x
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(rect, 2.5 * scale), SILVER,
				maxf(OUTLINE_WIDTH * scale, 1.0))
		canvas.draw_line(Vector2(x0 + 2.2 * scale, rect.position.y + 2.0 * scale),
				Vector2(x0 + 2.2 * scale, rect.end.y - 2.2 * scale), SILVER_LIGHT, maxf(1.4 * scale, 1.0), true)


## Gövdenin (kemer + iki kol) çevresi; gümüş uçlar ayrı çizilir.
static func body_points(center: Vector2 = Vector2.ZERO, scale: float = 1.0) -> PackedVector2Array:
	var c: Vector2 = center + ARC_CENTER * scale
	var top: float = center.y + ARM_TOP * scale
	var points := PackedVector2Array([Vector2(c.x + OUTER * scale, top)])
	points.append_array(PlatformDraw.arc(c, OUTER * scale, 0.0, PI, 12))
	points.append(Vector2(c.x - OUTER * scale, top))
	points.append(Vector2(c.x - INNER * scale, top))
	points.append_array(PlatformDraw.arc(c, INNER * scale, PI, 0.0, 8))
	points.append(Vector2(c.x + INNER * scale, top))
	return points


## Uçlardan yukarı doğru açılıp solan çekim yayları. phase: 0..1 döngü.
static func draw_pull_rings(canvas: CanvasItem, phase: float, center: Vector2 = Vector2.ZERO) -> void:
	for side: float in [-1.0, 1.0]:
		var tip := center + Vector2(side * (INNER + OUTER) * 0.5, TIP_TOP - 1.0)
		for i: int in RING_COUNT:
			var t: float = fmod(phase + float(i) / RING_COUNT, 1.0)
			var radius: float = lerpf(3.0, RING_REACH, t)
			var alpha: float = sin(t * PI) * 0.75
			canvas.draw_polyline(PlatformDraw.arc(tip, radius, -PI * 0.5 - RING_SPREAD * 0.5,
					-PI * 0.5 + RING_SPREAD * 0.5, 6), Color(SPARKLE, alpha), 1.6, true)
