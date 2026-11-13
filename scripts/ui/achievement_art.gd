class_name AchievementArt
extends RefCounted
## Başarım simgeleri (kodla çizilir): altın kupa, açık başarım tiki, kilit. Orijin simgenin ortasında;
## scale 1'de kupa ~26 x 28 px. Köşesiz, yumuşak; dış çizgi dünyayla aynı koyu lacivert.

const GOLD := Color(0.96, 0.82, 0.46)
const GOLD_DARK := Color(0.80, 0.60, 0.26)
const GOLD_LIGHT := Color(1.0, 0.95, 0.74)
const LOCK_COLOR := Color(0.55, 0.60, 0.72, 0.8)
const OUTLINE_WIDTH: float = 2.0


## Altın kupa. glow > 0: arkasında yumuşak bir altın hale (0..1).
static func draw_trophy(canvas: CanvasItem, center: Vector2, scale: float = 1.0, glow: float = 0.0) -> void:
	var p := func(x: float, y: float) -> Vector2: return center + Vector2(x, y) * scale
	var width: float = maxf(OUTLINE_WIDTH * scale, 1.0)
	if glow > 0.0:
		for i: int in 4:
			canvas.draw_circle(center, (18.0 + i * 5.0) * scale, Color(GOLD, 0.10 * glow))
	# Kulplar (önce koyu kalın, üstüne altın ince).
	for side: float in [-1.0, 1.0]:
		var handle_center: Vector2 = p.call(side * 9.0, -7.5)
		var from_angle: float = -PI * 0.5 if side > 0.0 else PI * 0.5
		canvas.draw_arc(handle_center, 5.0 * scale, from_angle, from_angle + PI, 14,
				PlatformDraw.OUTLINE_COLOR, 4.2 * scale, true)
		canvas.draw_arc(handle_center, 5.0 * scale, from_angle, from_angle + PI, 14, GOLD_DARK, 2.2 * scale, true)
	# Ayak: sap ve taban.
	PlatformDraw.shape(canvas, PackedVector2Array([p.call(-2.2, 3.0), p.call(2.2, 3.0), p.call(2.6, 9.0), p.call(-2.6, 9.0)]),
			GOLD_DARK, width)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(p.call(-7.5, 9.0), Vector2(15.0, 4.5) * scale), 2.0 * scale),
			GOLD, width)
	# Kase: üstü düz, altı yuvarlak.
	var bowl := PackedVector2Array()
	for i: int in 17:
		var angle: float = PI * float(i) / 16.0
		bowl.append(p.call(cos(angle) * 10.0, -11.0 + sin(angle) * 15.0))
	PlatformDraw.shape(canvas, bowl, GOLD, width)
	# Işık: sol yüzde yumuşak parlak çizgi.
	canvas.draw_arc(p.call(0.0, -11.0), 7.0 * scale, PI * 0.62, PI * 0.9, 8, GOLD_LIGHT, maxf(1.8 * scale, 1.0), true)


## Açık başarım işareti: altın daire içinde koyu tik.
static func draw_check(canvas: CanvasItem, center: Vector2, scale: float = 1.0) -> void:
	var width: float = maxf(OUTLINE_WIDTH * scale, 1.0)
	PlatformDraw.shape(canvas, PlatformDraw.ellipse(center, Vector2.ONE * 11.0 * scale, 20), GOLD, width)
	var tick := PackedVector2Array([center + Vector2(-5.0, 0.5) * scale, center + Vector2(-1.5, 4.0) * scale,
			center + Vector2(5.0, -3.5) * scale])
	canvas.draw_polyline(tick, PlatformDraw.OUTLINE_COLOR, 2.6 * scale, true)


## Kilitli başarım işareti: soluk asma kilit.
static func draw_lock(canvas: CanvasItem, center: Vector2, scale: float = 1.0) -> void:
	canvas.draw_arc(center + Vector2(0.0, -1.0) * scale, 5.0 * scale, PI, TAU, 12, LOCK_COLOR, 2.4 * scale, true)
	canvas.draw_line(center + Vector2(-5.0, -1.0) * scale, center + Vector2(-5.0, 1.0) * scale, LOCK_COLOR, 2.4 * scale)
	canvas.draw_line(center + Vector2(5.0, -1.0) * scale, center + Vector2(5.0, 1.0) * scale, LOCK_COLOR, 2.4 * scale)
	var body: PackedVector2Array = PlatformDraw.rounded_rect(Rect2(center + Vector2(-7.5, 0.0) * scale, Vector2(15.0, 10.0) * scale),
			3.0 * scale)
	canvas.draw_colored_polygon(body, LOCK_COLOR)
	canvas.draw_circle(center + Vector2(0.0, 4.5) * scale, 1.5 * scale, Color(UiStyle.PANEL, 0.9))
