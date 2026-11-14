extends GutTest
## FlipRules testleri. Beklentiler Tuning'den türetilir.


func test_big_jump_triggers_flip() -> void:
	assert_true(FlipRules.jump_triggers_flip(Tuning.FLIP_VELOCITY_THRESHOLD, false))
	assert_false(FlipRules.jump_triggers_flip(Tuning.FLIP_VELOCITY_THRESHOLD - 1.0, false))


func test_combo_jump_triggers_flip_even_if_small() -> void:
	assert_true(FlipRules.jump_triggers_flip(Tuning.JUMP_BASE, true))


func test_standing_jump_does_not_flip() -> void:
	assert_false(FlipRules.jump_triggers_flip(Tuning.JUMP_BASE, false))


func test_duration_grows_with_speed_and_has_minimum() -> void:
	assert_eq(FlipRules.duration_for(0.0), Tuning.FLIP_MIN_DURATION)
	assert_eq(FlipRules.duration_for(-500.0), Tuning.FLIP_MIN_DURATION, "düşerken de en az süre")
	var slow: float = FlipRules.duration_for(Tuning.FLIP_VELOCITY_THRESHOLD)
	var fast: float = FlipRules.duration_for(Player.jump_speed_for(Tuning.MAX_RUN_SPEED))
	assert_gt(fast, slow)
	assert_almost_eq(slow, Tuning.FLIP_VELOCITY_THRESHOLD / Tuning.GRAVITY * Tuning.FLIP_AIRTIME_FACTOR, 0.001)


func test_turns_at_least_one_and_capped() -> void:
	assert_eq(FlipRules.turns_for(0.0), 1)
	assert_eq(FlipRules.turns_for(Tuning.FLIP_TURN_TIME * 2.0 + 0.01), 2)
	assert_eq(FlipRules.turns_for(100.0), Tuning.FLIP_MAX_TURNS)


func test_direction_follows_movement() -> void:
	assert_eq(FlipRules.direction_for(500.0, -1.0), 1.0, "sağa gidiyor → saat yönü")
	assert_eq(FlipRules.direction_for(-500.0, 1.0), -1.0)
	assert_eq(FlipRules.direction_for(0.0, -1.0), -1.0, "duruyorsa bakılan yön")


func test_twist_turn_time_param() -> void:
	assert_eq(FlipRules.turns_for(Tuning.FLIP_TWIST_TURN_TIME * 2.0 + 0.01, Tuning.FLIP_TWIST_TURN_TIME), 2)
	assert_eq(FlipRules.turns_for(0.0, Tuning.FLIP_TWIST_TURN_TIME), 1)


func test_pick_style_follows_weights() -> void:
	var total: float = Tuning.FLIP_STYLE_WEIGHT_FRONT + Tuning.FLIP_STYLE_WEIGHT_TWIST
	var front_end: float = Tuning.FLIP_STYLE_WEIGHT_FRONT / total
	if Tuning.FLIP_STYLE_WEIGHT_FRONT > 0.0:
		assert_eq(FlipRules.pick_style(0.0), FlipRules.FRONT)
		assert_eq(FlipRules.pick_style(front_end - 0.001), FlipRules.FRONT)
	if Tuning.FLIP_STYLE_WEIGHT_TWIST > 0.0:
		assert_eq(FlipRules.pick_style(front_end + 0.001), FlipRules.TWIST)
		assert_eq(FlipRules.pick_style(1.0), FlipRules.TWIST)


func test_twist_turns_face_toward_camera_first() -> void:
	# Sağa giderken model -Y yönünde döner (yön görünümü -25° → önden görünüm -90°).
	assert_eq(FlipRules.twist_direction(1.0), -1.0)
	assert_eq(FlipRules.twist_direction(-1.0), 1.0)



func test_twist_adds_to_facing_turn_on_wall_bounce() -> void:
	# Aynı yöne devam: yüz önce kameraya (eski davranış).
	assert_eq(FlipRules.twist_direction(1.0, 1.0), -1.0)
	assert_eq(FlipRules.twist_direction(-1.0, -1.0), 1.0)
	# Yön değişiyor (sağ duvardan sola seke): model sola dönerken (-) burgu da (-) döner.
	assert_eq(FlipRules.twist_direction(-1.0, 1.0), -1.0)
	assert_eq(FlipRules.twist_direction(1.0, -1.0), 1.0)
