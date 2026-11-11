extends GutTest
## AnimationRules testleri: duruma göre doğru animasyon ve koşu hızı.

const SLOW: Vector2 = Vector2(0.0, 0.0)
const RUNNING: Vector2 = Vector2(Tuning.MAX_RUN_SPEED, 0.0)
const RISING: Vector2 = Vector2(0.0, -Tuning.JUMP_BASE)
const FALLING: Vector2 = Vector2(0.0, Tuning.MODEL_FALL_ANIM_MIN_SPEED + 100.0)


func test_idle_when_standing() -> void:
	assert_eq(AnimationRules.pick(true, SLOW, false, false, false), AnimationRules.IDLE)


func test_run_when_moving_on_floor() -> void:
	assert_eq(AnimationRules.pick(true, RUNNING, false, false, false), AnimationRules.RUN)


func test_jump_while_rising_and_fall_while_falling() -> void:
	assert_eq(AnimationRules.pick(false, RISING, false, false, false), AnimationRules.JUMP)
	assert_eq(AnimationRules.pick(false, FALLING, false, false, false), AnimationRules.FALL)


func test_flap_only_while_rising() -> void:
	assert_eq(AnimationRules.pick(false, RISING, false, false, true), AnimationRules.FLAP)
	assert_eq(AnimationRules.pick(false, FALLING, false, false, true), AnimationRules.FALL)


func test_tuck_during_flip_in_air_only() -> void:
	assert_eq(AnimationRules.pick(false, RISING, true, false, true), AnimationRules.TUCK)
	assert_eq(AnimationRules.pick(false, FALLING, true, false, false), AnimationRules.TUCK)
	# İnişte açı sıfırlanırken (kısa tween) yerde topak pozu oynamaz.
	assert_ne(AnimationRules.pick(true, SLOW, true, false, false), AnimationRules.TUCK)


func test_land_when_slow_but_run_when_fast() -> void:
	assert_eq(AnimationRules.pick(true, SLOW, false, true, false), AnimationRules.LAND)
	assert_eq(AnimationRules.pick(true, RUNNING, false, true, false), AnimationRules.RUN)


func test_run_speed_scale_grows_with_speed() -> void:
	assert_almost_eq(AnimationRules.run_speed_scale(0.0), Tuning.MODEL_RUN_ANIM_SPEED_MIN, 0.001)
	assert_almost_eq(AnimationRules.run_speed_scale(-Tuning.MAX_RUN_SPEED),
			Tuning.MODEL_RUN_ANIM_SPEED_MAX, 0.001)
	assert_almost_eq(AnimationRules.run_speed_scale(Tuning.MAX_RUN_SPEED * 5.0),
			Tuning.MODEL_RUN_ANIM_SPEED_MAX, 0.001)
	assert_gt(AnimationRules.run_speed_scale(Tuning.MAX_RUN_SPEED * 0.5),
			AnimationRules.run_speed_scale(Tuning.MAX_RUN_SPEED * 0.1))


func test_sudden_animations_blend_faster() -> void:
	assert_lt(AnimationRules.blend_time(AnimationRules.TUCK), AnimationRules.blend_time(AnimationRules.RUN))
	assert_lt(AnimationRules.blend_time(AnimationRules.LAND), AnimationRules.blend_time(AnimationRules.IDLE))


func test_flip_uses_chosen_pose() -> void:
	assert_eq(AnimationRules.pick(false, RISING, true, false, false, AnimationRules.STAR), AnimationRules.STAR)
	assert_eq(AnimationRules.pick(false, RISING, true, false, false, AnimationRules.TUCK), AnimationRules.TUCK)
	# Takla yokken seçilmiş poz kullanılmaz.
	assert_eq(AnimationRules.pick(false, RISING, false, false, false, AnimationRules.STAR), AnimationRules.JUMP)


func test_flip_pose_is_random_for_jumps_and_tuck_for_walls() -> void:
	assert_eq(AnimationRules.flip_animation(0.0, false), AnimationRules.STAR)
	assert_eq(AnimationRules.flip_animation(0.999, false), AnimationRules.TUCK)
	assert_eq(AnimationRules.flip_animation(0.0, true), AnimationRules.TUCK)
	assert_eq(AnimationRules.flip_animation(0.999, true), AnimationRules.TUCK)


func test_only_star_faces_camera() -> void:
	assert_true(AnimationRules.faces_camera(AnimationRules.STAR))
	assert_false(AnimationRules.faces_camera(AnimationRules.TUCK))
	assert_false(AnimationRules.faces_camera(AnimationRules.RUN))
