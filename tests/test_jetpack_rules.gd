extends GutTest
## Roket kuralları: çıkma koşulları, güvenli iniş platformu seçimi, uçuş evreleri.

const DT: float = 1.0 / 60.0


func _platform(center_x: float, floor_number: int, width: float) -> Vector3:
	return Vector3(center_x, PlatformRules.floor_y(floor_number), width)


func test_no_spawn_before_min_floor_or_on_section_floor() -> void:
	var far_back: int = -Tuning.JETPACK_MIN_FLOOR_GAP * 10
	assert_false(JetpackRules.can_spawn(Tuning.JETPACK_MIN_FLOOR - 1, far_back))
	assert_true(JetpackRules.can_spawn(Tuning.JETPACK_MIN_FLOOR, far_back))
	assert_false(JetpackRules.can_spawn(Tuning.SECTION_FLOOR_INTERVAL, far_back), "bölüm platformunda çıkmaz")


func test_min_gap_between_spawns() -> void:
	var last: int = Tuning.JETPACK_MIN_FLOOR + 50
	assert_false(JetpackRules.can_spawn(last + Tuning.JETPACK_MIN_FLOOR_GAP - 1, last))
	assert_true(JetpackRules.can_spawn(last + Tuning.JETPACK_MIN_FLOOR_GAP + 1, last))


func test_spawn_chance_decides() -> void:
	var floor_number: int = Tuning.JETPACK_MIN_FLOOR + 1
	var far_back: int = -Tuning.JETPACK_MIN_FLOOR_GAP * 10
	assert_true(JetpackRules.should_spawn(floor_number, far_back, Tuning.JETPACK_SPAWN_CHANCE * 0.5))
	assert_false(JetpackRules.should_spawn(floor_number, far_back, Tuning.JETPACK_SPAWN_CHANCE + 0.01))


func test_gap_is_longer_than_flight() -> void:
	var flight_floors: float = Tuning.JETPACK_SPEED * Tuning.JETPACK_FLIGHT_TIME / Tuning.FLOOR_SPACING
	assert_gt(float(Tuning.JETPACK_MIN_FLOOR_GAP), flight_floors, "uçarken ikinci rokete denk gelinmemeli")


func test_pickup_stays_inside_platform() -> void:
	var width: float = 200.0
	var limit: float = width * 0.5 - Tuning.PICKUP_EDGE_MARGIN
	assert_almost_eq(JetpackRules.pickup_offset_x(width, 0.0), -limit, 0.01)
	assert_almost_eq(JetpackRules.pickup_offset_x(width, 1.0), limit, 0.01)
	assert_eq(JetpackRules.pickup_offset_x(Tuning.PICKUP_EDGE_MARGIN, 1.0), 0.0, "dar platformda ortada")


func test_fuel_ratio_and_floor_passed() -> void:
	assert_eq(JetpackRules.fuel_ratio(0.0), 1.0)
	assert_almost_eq(JetpackRules.fuel_ratio(Tuning.JETPACK_FLIGHT_TIME * 0.5), 0.5, 0.001)
	assert_eq(JetpackRules.fuel_ratio(Tuning.JETPACK_FLIGHT_TIME * 2.0), 0.0)
	assert_eq(JetpackRules.floor_passed(10.0), 0, "zeminin altı kat 0")
	assert_eq(JetpackRules.floor_passed(PlatformRules.floor_y(7) - 1.0), 7)
	assert_eq(JetpackRules.floor_passed(PlatformRules.floor_y(7) + 1.0), 6)


func test_landing_x_stays_on_platform() -> void:
	var platform: Vector3 = _platform(100.0, 5, 200.0)
	var half: float = 100.0 - Tuning.JETPACK_LANDING_EDGE_MARGIN
	assert_eq(JetpackRules.landing_x(120.0, platform), 120.0, "zaten üstündeyse kaymaz")
	assert_almost_eq(JetpackRules.landing_x(900.0, platform), 100.0 + half, 0.01)
	assert_almost_eq(JetpackRules.landing_x(-900.0, platform), 100.0 - half, 0.01)


func test_pick_landing_skips_too_close_and_prefers_nearest() -> void:
	var player := Vector2(0.0, PlatformRules.floor_y(10) + 20.0)
	var platforms: Array[Vector3] = [
		_platform(0.0, 10, 200.0),  # çok yakın (MIN_RISE'tan az yukarıda)
		_platform(300.0, 11, 120.0),
		_platform(10.0, 12, 160.0),  # yatayda en yakın
		_platform(-350.0, 13, 120.0),
		_platform(0.0, 14, 400.0),  # aday sayısının dışında
	]
	var landing: Vector3 = JetpackRules.pick_landing(player, platforms)
	assert_eq(landing, platforms[2])
	assert_false(JetpackRules.has_landing(JetpackRules.pick_landing(player, [])))


## Tam bir uçuşu adım adım yürütür: süre boyunca yükselir, sonra seçilen platformun tam üstünde biter.
func test_flight_ends_above_a_platform() -> void:
	var platforms: Array[Vector3] = []
	for floor_number: int in range(1, 80):
		var side: float = 1.0 if floor_number % 2 == 0 else -1.0
		platforms.append(_platform(side * 300.0, floor_number, 140.0))
	var finder := func(world_y: float) -> Array[Vector3]:
		return platforms.filter(func(p: Vector3) -> bool: return p.y < world_y)
	var flight := JetpackFlight.new()
	var position := Vector2(0.0, PlatformRules.floor_y(20))
	var velocity := Vector2.ZERO
	var steps: int = 0
	var boost_steps: int = 0
	while not flight.is_done() and steps < 2000:
		velocity = flight.step(position, velocity, 0.0, DT, finder)
		position += velocity * DT
		steps += 1
		if flight.phase == JetpackFlight.Phase.BOOST:
			boost_steps += 1
	assert_true(flight.is_done(), "uçuş bitmeli")
	assert_almost_eq(boost_steps * DT, Tuning.JETPACK_FLIGHT_TIME, 0.05, "itiş süresi")
	var landing: Vector3 = flight.landing
	assert_true(JetpackRules.has_landing(landing))
	assert_lt(absf(position.x - landing.x), landing.z * 0.5, "platformun üstünde bırakılmalı")
	assert_almost_eq(position.y, JetpackRules.release_y(landing), Tuning.JETPACK_RELEASE_TOLERANCE + 1.0)
	assert_lt(position.y, PlatformRules.floor_y(35), "uçuş onlarca kat çıkarmalı")
