extends GutTest
## Mıknatıs: çıkma koşulları, elmas avı olasılığı, çekim menzili/hızı, ses zinciri ve çizim çokgeni.


func test_spawn_conditions() -> void:
	var far_back: int = -Tuning.MAGNET_MIN_FLOOR_GAP * 10
	assert_false(MagnetRules.can_spawn(Tuning.MAGNET_MIN_FLOOR - 1, far_back))
	assert_eq(MagnetRules.can_spawn(Tuning.MAGNET_MIN_FLOOR, far_back), Tuning.MAGNET_ENABLED)
	var last: int = Tuning.MAGNET_MIN_FLOOR + 10
	assert_false(MagnetRules.can_spawn(last + Tuning.MAGNET_MIN_FLOOR_GAP - 1, last))
	var floor_number: int = last + Tuning.MAGNET_MIN_FLOOR_GAP
	assert_eq(MagnetRules.should_spawn(floor_number, last, Tuning.MAGNET_SPAWN_CHANCE * 0.5), Tuning.MAGNET_ENABLED)
	assert_false(MagnetRules.should_spawn(floor_number, last, Tuning.MAGNET_SPAWN_CHANCE + 0.01))


func test_gap_outlasts_effect() -> void:
	# Etki sürerken tırmanılan katlarda (koşarak ~3 kat/s; roketle daha çok) ikinci mıknatıs çıkmasın.
	assert_gt(float(Tuning.MAGNET_MIN_FLOOR_GAP), Tuning.MAGNET_DURATION * 3.0)


func test_diamond_rush_chance() -> void:
	var floor_number: int = Tuning.DIAMOND_MIN_FLOOR + 5
	var between: float = (Tuning.DIAMOND_SPAWN_CHANCE + Tuning.MAGNET_DIAMOND_CHANCE) * 0.5
	assert_gt(Tuning.MAGNET_DIAMOND_CHANCE, Tuning.DIAMOND_SPAWN_CHANCE, "etki sırasında elmas daha bol")
	assert_false(MagnetRules.should_spawn_diamond(floor_number, between, false))
	assert_eq(MagnetRules.should_spawn_diamond(floor_number, between, true), Tuning.DIAMOND_ENABLED)
	assert_false(MagnetRules.should_spawn_diamond(floor_number, Tuning.MAGNET_DIAMOND_CHANCE + 0.01, true))
	assert_false(MagnetRules.should_spawn_diamond(Tuning.DIAMOND_MIN_FLOOR - 1, 0.0, true), "elmasın alt katı geçerli")


func test_range() -> void:
	var center := Vector2(10.0, -500.0)
	assert_true(MagnetRules.in_range(center + Vector2(0.0, -Tuning.MAGNET_RADIUS), center))
	assert_false(MagnetRules.in_range(center + Vector2(Tuning.MAGNET_RADIUS + 1.0, 0.0), center))


func test_pull_speed_accelerates_and_caps() -> void:
	assert_eq(MagnetRules.pull_speed(0.0), Tuning.MAGNET_PULL_START_SPEED)
	assert_eq(MagnetRules.pull_speed(-1.0), Tuning.MAGNET_PULL_START_SPEED)
	assert_gt(MagnetRules.pull_speed(0.1), MagnetRules.pull_speed(0.0))
	assert_eq(MagnetRules.pull_speed(100.0), Tuning.MAGNET_PULL_MAX_SPEED)
	assert_gt(Tuning.MAGNET_PULL_MAX_SPEED, Tuning.JETPACK_SPEED, "roketle uçarken de yetişir")


func test_pull_step_reaches_without_overshoot() -> void:
	var target := Vector2(0.0, 0.0)
	var item := Vector2(Tuning.MAGNET_RADIUS, 0.0)
	var dt: float = 1.0 / 60.0
	var elapsed: float = 0.0
	var steps: int = 0
	while not MagnetRules.reached(item, target) and steps < 600:
		elapsed += dt
		var next: Vector2 = MagnetRules.pull_step(item, target, elapsed, dt)
		assert_lte(next.distance_to(target), item.distance_to(target))
		item = next
		steps += 1
	assert_true(MagnetRules.reached(item, target))
	assert_lt(steps * dt, 1.0, "menzilin ucundaki elmas bir saniyeden kısa sürede gelir")


func test_pull_step_chases_moving_target() -> void:
	# Roket hızında yukarı kaçan oyuncuya yetişir.
	var target := Vector2.ZERO
	var item := Vector2(0.0, -Tuning.MAGNET_RADIUS)
	var dt: float = 1.0 / 60.0
	var elapsed: float = 0.0
	for i: int in 300:
		target.y -= Tuning.JETPACK_SPEED * dt
		elapsed += dt
		item = MagnetRules.pull_step(item, target, elapsed, dt)
		if MagnetRules.reached(item, target):
			break
	assert_true(MagnetRules.reached(item, target))


func test_sound_chain() -> void:
	assert_eq(MagnetRules.next_chain(3, Tuning.MAGNET_SFX_CHAIN_WINDOW + 0.1), 0, "ara uzunsa baştan")
	assert_eq(MagnetRules.next_chain(3, Tuning.MAGNET_SFX_CHAIN_WINDOW * 0.5), 4)
	assert_eq(MagnetRules.next_chain(Tuning.MAGNET_SFX_CHAIN_MAX, 0.1), Tuning.MAGNET_SFX_CHAIN_MAX)
	assert_eq(MagnetRules.chain_pitch(0), 1.0)
	assert_gt(MagnetRules.chain_pitch(2), MagnetRules.chain_pitch(1))
	assert_eq(MagnetRules.chain_pitch(99), MagnetRules.chain_pitch(Tuning.MAGNET_SFX_CHAIN_MAX))
	assert_lt(MagnetRules.chain_pitch(Tuning.MAGNET_SFX_CHAIN_MAX), 2.0, "bir oktavı geçmez")


func test_body_polygon_is_valid() -> void:
	var points: PackedVector2Array = MagnetArt.body_points()
	assert_gt(points.size(), 10)
	assert_gt(Geometry2D.triangulate_polygon(points).size(), 0, "çokgen üçgenlenebilir")
