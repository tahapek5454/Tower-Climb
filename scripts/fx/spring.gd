class_name Spring
extends RefCounted
## Sönümlü yay: görsel efektlerde (squash & stretch vb.) değeri hedefe "jöle" gibi döndürür.
## Saf mantık, test edilebilir.

## Büyük kare sürelerinde yay patlamasın diye adım bununla sınırlanır.
const MAX_STEP: float = 1.0 / 30.0


## Bir adım ilerletir. Dönen: Vector2(yeni_değer, yeni_hız).
static func step(value: float, velocity: float, target: float,
		stiffness: float, damping: float, delta: float) -> Vector2:
	var dt: float = minf(delta, MAX_STEP)
	var accel: float = -stiffness * (value - target) - damping * velocity
	var new_velocity: float = velocity + accel * dt
	return Vector2(value + new_velocity * dt, new_velocity)
