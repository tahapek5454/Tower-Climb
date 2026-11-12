extends GutTest
## SfxRules testleri (saf ses kuralları). Beklentiler Tuning'den türetilir.

const EPSILON: float = 0.001


func test_jump_pitch_rises_with_speed() -> void:
	var max_jump: float = Tuning.JUMP_BASE + Tuning.MAX_RUN_SPEED * Tuning.JUMP_SPEED_BONUS
	assert_almost_eq(SfxRules.jump_pitch(Tuning.JUMP_BASE), Tuning.SFX_JUMP_PITCH_MIN, EPSILON)
	assert_almost_eq(SfxRules.jump_pitch(max_jump), Tuning.SFX_JUMP_PITCH_MAX, EPSILON)
	assert_lt(SfxRules.jump_volume_db(Tuning.JUMP_BASE), SfxRules.jump_volume_db(max_jump))


func test_soft_landings_are_silent_and_hard_ones_louder() -> void:
	assert_false(SfxRules.should_play_land(Tuning.SFX_LAND_MIN_SPEED - 1.0))
	assert_true(SfxRules.should_play_land(Tuning.SFX_LAND_MIN_SPEED))
	assert_lt(SfxRules.land_volume_db(400.0), SfxRules.land_volume_db(Tuning.MAX_FALL_SPEED))
	assert_gt(SfxRules.land_pitch(400.0), SfxRules.land_pitch(Tuning.MAX_FALL_SPEED), "sert iniş daha kalın")


func test_combo_pitch_climbs_major_scale_and_caps() -> void:
	assert_almost_eq(SfxRules.combo_pitch(1), 1.0, EPSILON, "ilk kombo zıplayışı temel nota")
	assert_almost_eq(SfxRules.combo_pitch(2), pow(2.0, 2.0 / 12.0), EPSILON, "bir tam ton yukarı")
	var prev: float = 0.0
	for jumps in range(1, 40):
		var pitch: float = SfxRules.combo_pitch(jumps)
		assert_true(pitch >= prev, "kombo perdesi düşmemeli (%d)" % jumps)
		prev = pitch
	assert_almost_eq(SfxRules.combo_pitch(100), 4.0, EPSILON, "iki oktavda sabit")


func test_big_jump_matches_flip_threshold() -> void:
	assert_false(SfxRules.is_big_jump(Tuning.FLIP_VELOCITY_THRESHOLD - 1.0))
	assert_true(SfxRules.is_big_jump(Tuning.FLIP_VELOCITY_THRESHOLD))


func test_jitter_stays_within_range() -> void:
	assert_almost_eq(SfxRules.jitter_pitch(1.0, 0.0), 1.0 - Tuning.SFX_PITCH_JITTER, EPSILON)
	assert_almost_eq(SfxRules.jitter_pitch(1.0, 1.0), 1.0 + Tuning.SFX_PITCH_JITTER, EPSILON)
	assert_almost_eq(SfxRules.jitter_pitch(1.0, 0.5), 1.0, EPSILON)
