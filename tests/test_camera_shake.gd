extends GutTest
## CameraShake testleri. Beklentiler Tuning'den türetilir.

const DT: float = 1.0 / 60.0

var shake: CameraShake


func before_each() -> void:
	shake = CameraShake.new(7)


func test_no_shake_without_trauma() -> void:
	assert_eq(shake.update(DT), Vector2.ZERO)


func test_trauma_is_clamped() -> void:
	shake.add(0.8)
	shake.add(0.8)
	assert_eq(shake.trauma, 1.0)
	shake.add(-5.0)
	assert_eq(shake.trauma, 1.0, "negatif ekleme azaltmaz")


func test_trauma_decays_to_zero() -> void:
	shake.add(1.0)
	var seconds: float = 1.0 / Tuning.SHAKE_DECAY + 0.1
	for i in int(seconds / DT):
		shake.update(DT)
	assert_eq(shake.trauma, 0.0)
	assert_eq(shake.update(DT), Vector2.ZERO)


func test_offset_never_exceeds_max() -> void:
	shake.add(1.0)
	var biggest: float = 0.0
	for i in 60:
		biggest = maxf(biggest, shake.update(DT).length())
	assert_gt(biggest, 0.0, "sarsıntı olmalı")
	assert_true(biggest <= Tuning.SHAKE_MAX_OFFSET + 0.001)


func test_small_trauma_is_much_weaker() -> void:
	shake.add(0.3)
	assert_almost_eq(shake.intensity(), 0.09, 0.0001, "etki trauma'nın karesi")


func test_combo_trauma() -> void:
	assert_eq(CameraShake.combo_trauma(10, 0), 0.0, "puan kazandırmayan kombo sarsmaz")
	assert_almost_eq(CameraShake.combo_trauma(5, 25), 5 * Tuning.SHAKE_COMBO_TRAUMA_PER_FLOOR, 0.0001)
	assert_eq(CameraShake.combo_trauma(1000, 1), Tuning.SHAKE_COMBO_TRAUMA_MAX)


func test_land_trauma_only_for_big_landings() -> void:
	assert_eq(CameraShake.land_trauma(Tuning.SHAKE_LAND_MIN_SPEED - 1.0), 0.0)
	assert_gt(CameraShake.land_trauma(Tuning.SHAKE_LAND_MIN_SPEED), 0.0)
	assert_almost_eq(CameraShake.land_trauma(Tuning.MAX_FALL_SPEED), Tuning.SHAKE_LAND_TRAUMA_MAX, 0.0001)


func test_wall_trauma_grows_with_speed() -> void:
	assert_almost_eq(CameraShake.wall_trauma(Tuning.MAX_RUN_SPEED), Tuning.SHAKE_WALL_TRAUMA_MAX, 0.0001)
	assert_lt(CameraShake.wall_trauma(Tuning.MAX_RUN_SPEED * 0.5), Tuning.SHAKE_WALL_TRAUMA_MAX * 0.3)
