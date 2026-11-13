extends GutTest
## CameraRules testleri. Beklentiler Tuning'den türetilir.

const EPSILON: float = 0.001


func test_starts_only_at_start_floor() -> void:
	assert_false(CameraRules.should_start(0))
	assert_false(CameraRules.should_start(Tuning.CAMERA_START_FLOOR - 1))
	assert_true(CameraRules.should_start(Tuning.CAMERA_START_FLOOR))
	assert_true(CameraRules.should_start(Tuning.CAMERA_START_FLOOR + 10))


func test_speed_starts_at_start_speed() -> void:
	assert_eq(CameraRules.scroll_speed(0.0), Tuning.CAMERA_START_SPEED)
	var just_before: float = Tuning.CAMERA_SPEED_STEP_INTERVAL - EPSILON
	assert_eq(CameraRules.scroll_speed(just_before), Tuning.CAMERA_START_SPEED)


func test_speed_steps_up_each_interval() -> void:
	var interval: float = Tuning.CAMERA_SPEED_STEP_INTERVAL
	assert_almost_eq(CameraRules.scroll_speed(interval),
			Tuning.CAMERA_START_SPEED + Tuning.CAMERA_SPEED_STEP, EPSILON)
	assert_almost_eq(CameraRules.scroll_speed(interval * 3.5),
			Tuning.CAMERA_START_SPEED + Tuning.CAMERA_SPEED_STEP * 3.0, EPSILON)


func test_speed_is_capped() -> void:
	assert_eq(CameraRules.scroll_speed(1.0e6), Tuning.CAMERA_MAX_SPEED)


func test_section_adds_speed() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	assert_eq(CameraRules.section_of(interval - 1), 0)
	assert_eq(CameraRules.section_of(interval), 1)
	assert_eq(CameraRules.section_of(interval * 3 + 5), 3)
	assert_eq(CameraRules.section_bonus(0), 0.0)
	assert_eq(CameraRules.section_bonus(2), Tuning.CAMERA_SECTION_SPEED_BONUS * 2.0)
	assert_almost_eq(CameraRules.scroll_speed(0.0, CameraRules.section_bonus(1)),
			Tuning.CAMERA_START_SPEED + Tuning.CAMERA_SECTION_SPEED_BONUS, EPSILON)
	assert_eq(CameraRules.scroll_speed(1.0e6, CameraRules.section_bonus(50)), Tuning.CAMERA_MAX_SPEED,
			"toplam üst sınırı aşmaz")


func test_camera_speeds_up_on_new_section() -> void:
	var camera := TowerCamera.new()
	add_child_autofree(camera)
	camera.set_physics_process(false)
	var sections: Array = []
	var listener := func(section: int) -> void: sections.append(section)
	Events.speed_increased.connect(listener)
	Events.floor_changed.emit(Tuning.SECTION_FLOOR_INTERVAL)
	Events.floor_changed.emit(Tuning.SECTION_FLOOR_INTERVAL + 3)
	Events.speed_increased.disconnect(listener)
	assert_eq(sections, [1], "bölüm başına bir kez duyurulur")
	var dt: float = 1.0 / 60.0
	camera._physics_process(dt)
	assert_lt(camera.speed, Tuning.CAMERA_START_SPEED + Tuning.CAMERA_SECTION_SPEED_BONUS, "ek hız yumuşak gelir")
	for i: int in ceili(Tuning.CAMERA_SECTION_RAMP_TIME / dt) + 2:
		camera._physics_process(dt)
	assert_almost_eq(camera.speed, Tuning.CAMERA_START_SPEED + Tuning.CAMERA_SECTION_SPEED_BONUS, 0.5)


func test_speed_never_decreases() -> void:
	var prev: float = 0.0
	for i in 200:
		var speed: float = CameraRules.scroll_speed(i * 5.0)
		assert_true(speed >= prev, "%f saniyede hız düşmüş" % (i * 5.0))
		prev = speed


func test_below_screen_only_when_fully_out() -> void:
	var center_y: float = -500.0
	var screen_bottom: float = center_y + Tuning.VIEW_HEIGHT * 0.5
	assert_false(CameraRules.is_below_screen(screen_bottom, center_y), "ayaklar alt kenarda: hâlâ görünüyor")
	assert_false(CameraRules.is_below_screen(screen_bottom + Tuning.PLAYER_HEIGHT - 1.0, center_y),
			"kafası hâlâ ekranda")
	assert_true(CameraRules.is_below_screen(screen_bottom + Tuning.PLAYER_HEIGHT + 1.0, center_y))


func test_catchup_keeps_player_at_zone_edge() -> void:
	var player_y: float = -1000.0
	var center_y: float = CameraRules.catchup_center_y(player_y)
	var screen_top: float = center_y - Tuning.VIEW_HEIGHT * 0.5
	assert_almost_eq(player_y - screen_top, Tuning.VIEW_HEIGHT * Tuning.CAMERA_CATCHUP_ZONE, EPSILON)
