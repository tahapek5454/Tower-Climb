class_name Smoothing
extends RefCounted
## Çizgi yumuşatma yardımcıları. Saf mantık, test edilebilir.


## Chaikin köşe kesme: her köşeyi iki noktaya bölerek yumuşatır; uç noktalar korunur.
static func chaikin(points: PackedVector2Array) -> PackedVector2Array:
	var count: int = points.size()
	if count < 3:
		return points
	var result := PackedVector2Array()
	result.append(points[0])
	for i in count - 1:
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		result.append(a.lerp(b, 0.25))
		result.append(a.lerp(b, 0.75))
	result.append(points[count - 1])
	return result
