extends GutTest
## Kum saati: çıkma koşulları, kamera yavaşlatma çarpanı ve çizim çokgenleri.


func test_spawn_conditions() -> void:
	var far_back: int = -Tuning.HOURGLASS_MIN_FLOOR_GAP * 10
	assert_false(PickupRules.can_spawn_hourglass(Tuning.HOURGLASS_MIN_FLOOR - 1, far_back))
	assert_eq(PickupRules.can_spawn_hourglass(Tuning.HOURGLASS_MIN_FLOOR, far_back), Tuning.HOURGLASS_ENABLED)
	var last: int = Tuning.HOURGLASS_MIN_FLOOR + 10
	assert_false(PickupRules.can_spawn_hourglass(last + Tuning.HOURGLASS_MIN_FLOOR_GAP - 1, last))
	var floor_number: int = last + Tuning.HOURGLASS_MIN_FLOOR_GAP
	assert_eq(PickupRules.should_spawn_hourglass(floor_number, last, Tuning.HOURGLASS_SPAWN_CHANCE * 0.5),
			Tuning.HOURGLASS_ENABLED)
	assert_false(PickupRules.should_spawn_hourglass(floor_number, last, Tuning.HOURGLASS_SPAWN_CHANCE + 0.01))


func test_starts_after_camera_scrolls() -> void:
	assert_gt(Tuning.HOURGLASS_MIN_FLOOR, Tuning.CAMERA_START_FLOOR, "kamera kaymadan yavaşlatmanın anlamı yok")


func test_multiplier_ramps_holds_and_returns() -> void:
	var duration: float = Tuning.HOURGLASS_DURATION
	var ramp: float = Tuning.HOURGLASS_RAMP_TIME
	assert_eq(PickupRules.hourglass_multiplier(-1.0), 1.0, "etki yok")
	assert_almost_eq(PickupRules.hourglass_multiplier(0.0), 1.0, 0.001, "yumuşak başlar")
	assert_almost_eq(PickupRules.hourglass_multiplier(duration * 0.5), Tuning.HOURGLASS_SCROLL_FACTOR, 0.001)
	var mid_ramp: float = PickupRules.hourglass_multiplier(ramp * 0.5)
	assert_lt(mid_ramp, 1.0)
	assert_gt(mid_ramp, Tuning.HOURGLASS_SCROLL_FACTOR)
	assert_almost_eq(PickupRules.hourglass_multiplier(duration - 0.001), 1.0, 0.01, "sonda normale döner")
	assert_eq(PickupRules.hourglass_multiplier(duration), 1.0)


func test_camera_slows_and_recovers() -> void:
	var camera := TowerCamera.new()
	add_child_autofree(camera)
	camera.set_physics_process(false)
	camera.is_scrolling = true
	var dt: float = 1.0 / 60.0
	camera._physics_process(dt)
	var normal: float = camera.speed
	var ended: Array = []
	camera.slow_ended.connect(func() -> void: ended.append(true))
	camera.slow_down()
	var t: float = 0.0
	while t < Tuning.HOURGLASS_DURATION * 0.5:
		camera._physics_process(dt)
		t += dt
	assert_almost_eq(camera.speed, normal * Tuning.HOURGLASS_SCROLL_FACTOR, normal * 0.05, "yavaşladı")
	assert_true(camera.is_slowed())
	while t < Tuning.HOURGLASS_DURATION + 0.1:
		camera._physics_process(dt)
		t += dt
	assert_false(camera.is_slowed())
	assert_eq(ended.size(), 1, "bitiş bir kez duyurulur")
	assert_almost_eq(camera.speed, normal, normal * 0.05, "normal hıza döndü")


func test_sand_polygons_are_valid() -> void:
	for level: float in [0.05, 0.3, 0.55, 0.8, 1.0]:
		assert_false(Geometry2D.triangulate_polygon(HourglassArt.top_sand_points(level)).is_empty(), "üst %.2f" % level)
		assert_false(Geometry2D.triangulate_polygon(HourglassArt.bottom_sand_points(level)).is_empty(), "alt %.2f" % level)
	assert_false(Geometry2D.triangulate_polygon(HourglassArt._glass_points()).is_empty(), "cam")
