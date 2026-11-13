extends GutTest
## Toplanabilir kuralları: elmasın çıkma koşulları ve havadaki yerleşim.


func test_diamond_not_before_min_floor() -> void:
	assert_false(PickupRules.should_spawn_diamond(Tuning.DIAMOND_MIN_FLOOR - 1, 0.0))
	assert_eq(PickupRules.should_spawn_diamond(Tuning.DIAMOND_MIN_FLOOR, 0.0), Tuning.DIAMOND_ENABLED)


func test_diamond_chance_decides() -> void:
	var floor_number: int = Tuning.DIAMOND_MIN_FLOOR + 10
	assert_eq(PickupRules.should_spawn_diamond(floor_number, Tuning.DIAMOND_SPAWN_CHANCE * 0.5),
			Tuning.DIAMOND_ENABLED)
	assert_false(PickupRules.should_spawn_diamond(floor_number, Tuning.DIAMOND_SPAWN_CHANCE + 0.01))


func test_diamond_is_rare() -> void:
	assert_lte(Tuning.DIAMOND_SPAWN_CHANCE, 0.15, "elmas nadir olmalı (kullanıcı isteği)")


func test_air_spawn_chance() -> void:
	assert_true(PickupRules.is_air_spawn(Tuning.PICKUP_AIR_CHANCE * 0.5))
	assert_false(PickupRules.is_air_spawn(Tuning.PICKUP_AIR_CHANCE + 0.01))


func test_air_offset_stays_inside_tower() -> void:
	var limit: float = Tuning.TOWER_WIDTH * 0.5 - Tuning.PICKUP_AIR_WALL_MARGIN
	var platform_x: float = 150.0
	assert_almost_eq(platform_x + PickupRules.air_offset_x(platform_x, 0.0), -limit, 0.01)
	assert_almost_eq(platform_x + PickupRules.air_offset_x(platform_x, 1.0), limit, 0.01)
	assert_almost_eq(platform_x + PickupRules.air_offset_x(platform_x, 0.5), 0.0, 0.01)


func test_air_pickup_sits_between_floors() -> void:
	assert_gt(Tuning.PICKUP_AIR_HEIGHT, Tuning.PICKUP_HOVER_HEIGHT, "platform üstündekinden yüksekte")
	assert_lt(Tuning.PICKUP_AIR_HEIGHT + Tuning.PICKUP_RADIUS, Tuning.FLOOR_SPACING,
			"bir üst katın yüzeyine taşmaz")
