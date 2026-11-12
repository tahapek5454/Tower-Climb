class_name PlatformDraw
extends RefCounted
## Platform stillerinin ortak çizim yardımcıları (saf geometri + CanvasItem çizimi).
## Koordinatlar: x = -genişlik/2 .. +genişlik/2, y = 0 üst yüzey (ayakların bastığı yer), aşağı +y.

## Dış çizgi rengi: karakterin dış çizgisiyle aynı aile (koyu lacivert) — dünya ile karakter aynı dilde.
const OUTLINE_COLOR := Color(0.09, 0.10, 0.18)


## Yuvarlak köşeli dikdörtgenin çevresi (saat yönünde). radius küçükse düz dikdörtgen.
static func rounded_rect(rect: Rect2, radius: float, segments: int = 4) -> PackedVector2Array:
	# Yarıçap kenarın tam yarısı olursa çakışan noktalar çokgen üçgenlemesini bozar: biraz kıs.
	var r: float = minf(radius, minf(rect.size.x, rect.size.y) * 0.5 - 0.1)
	if r < 0.75:
		return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y),
				rect.end, Vector2(rect.position.x, rect.end.y)])
	var points := PackedVector2Array()
	var centers: Array[Vector2] = [
		Vector2(rect.end.x - r, rect.position.y + r), Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r), Vector2(rect.position.x + r, rect.position.y + r),
	]
	for corner: int in 4:
		var start_angle: float = -PI * 0.5 + corner * PI * 0.5
		for i: int in segments + 1:
			var angle: float = start_angle + PI * 0.5 * float(i) / segments
			points.append(centers[corner] + Vector2(cos(angle), sin(angle)) * r)
	return points


## Merkez etrafında yay noktaları (açılar radyan, başlangıçtan bitişe).
static func arc(center: Vector2, radius: float, from_angle: float, to_angle: float,
		segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in segments + 1:
		var angle: float = lerpf(from_angle, to_angle, float(i) / segments)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


## Elips çevresi.
static func ellipse(center: Vector2, radii: Vector2, segments: int = 16) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in segments:
		var angle: float = TAU * float(i) / segments
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points


## Yay şeridi (kalın kemer): iç ve dış yarıçap arasında, açılar radyan.
static func arc_band(center: Vector2, inner: float, outer: float, from_angle: float,
		to_angle: float, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = arc(center, outer, from_angle, to_angle, segments)
	var inner_points: PackedVector2Array = arc(center, inner, from_angle, to_angle, segments)
	inner_points.reverse()
	points.append_array(inner_points)
	return points


## Dolu şekil + isteğe bağlı koyu dış çizgi.
static func shape(canvas: CanvasItem, points: PackedVector2Array, fill: Color,
		outline_width: float = 0.0) -> void:
	canvas.draw_colored_polygon(points, fill)
	if outline_width > 0.0:
		outline(canvas, points, outline_width)


## Kapalı dış çizgi.
static func outline(canvas: CanvasItem, points: PackedVector2Array, width: float) -> void:
	var closed: PackedVector2Array = points.duplicate()
	closed.append(points[0])
	canvas.draw_polyline(closed, OUTLINE_COLOR, width, true)


## amount > 0 açar, < 0 koyulaştırır.
static func tone(color: Color, amount: float) -> Color:
	return color.lightened(amount) if amount >= 0.0 else color.darkened(-amount)


## Dört kollu küçük parıltı (kristal, buz).
static func sparkle(canvas: CanvasItem, center: Vector2, size: float, color: Color) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(0.0, -size), center + Vector2(size * 0.25, -size * 0.25),
		center + Vector2(size, 0.0), center + Vector2(size * 0.25, size * 0.25),
		center + Vector2(0.0, size), center + Vector2(-size * 0.25, size * 0.25),
		center + Vector2(-size, 0.0), center + Vector2(-size * 0.25, -size * 0.25),
	]), color)
