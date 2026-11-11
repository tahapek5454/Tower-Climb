extends GutTest
## Spring testleri: squash & stretch yayı hedefe döner, sallanır ve patlamaz.

const DT: float = 1.0 / 60.0


func _simulate(value: float, target: float, seconds: float) -> Array[float]:
	var values: Array[float] = []
	var velocity: float = 0.0
	for i in int(seconds / DT):
		var r: Vector2 = Spring.step(value, velocity, target,
				Tuning.SQUASH_SPRING_STIFFNESS, Tuning.SQUASH_SPRING_DAMPING, DT)
		value = r.x
		velocity = r.y
		values.append(value)
	return values


func test_stays_at_target_when_resting() -> void:
	var values: Array[float] = _simulate(0.0, 0.0, 1.0)
	assert_eq(values[-1], 0.0)


func test_returns_to_target_after_kick() -> void:
	var values: Array[float] = _simulate(Tuning.JUMP_STRETCH_MAX, 0.0, 1.5)
	assert_almost_eq(values[-1], 0.0, 0.01)


func test_kick_overshoots_for_wobble() -> void:
	var values: Array[float] = _simulate(Tuning.LAND_SQUASH_MAX, 0.0, 1.0)
	assert_lt(values.min(), 0.0, "jöle hissi için hedefi bir kez geçmeli")


func test_large_delta_is_stable() -> void:
	var value: float = Tuning.SQUASH_LIMIT
	var velocity: float = 0.0
	for i in 60:
		var r: Vector2 = Spring.step(value, velocity, 0.0,
				Tuning.SQUASH_SPRING_STIFFNESS, Tuning.SQUASH_SPRING_DAMPING, 0.5)
		value = r.x
		velocity = r.y
	assert_lt(absf(value), Tuning.SQUASH_LIMIT, "kare takılsa bile yay patlamamalı")
