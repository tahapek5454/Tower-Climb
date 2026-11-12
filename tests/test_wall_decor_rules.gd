extends GutTest
## WallDecorRules testleri (saf yerleşim).

const SLOTS: int = 600


func test_items_are_deterministic_and_inside_tower() -> void:
	var half: float = Tuning.TOWER_WIDTH * 0.5
	var filled: int = 0
	for slot in SLOTS:
		var item: Dictionary = WallDecorRules.slot_item(slot)
		assert_eq(item, WallDecorRules.slot_item(slot), "yuva %d aynı kalmalı" % slot)
		if item.is_empty():
			continue
		filled += 1
		var reach: float = item[&"span"] * 0.5
		assert_true(item[&"x"] - reach >= -half and item[&"x"] + reach <= half, "yuva %d taşıyor" % slot)
		var kinds: Array = WallDecorRules.THEME_ITEMS[item[&"theme"]]
		assert_true(kinds.has(item[&"kind"]), "yuva %d temaya uymayan süs" % slot)
	assert_almost_eq(float(filled) / SLOTS, Tuning.WALL_DECOR_CHANCE, 0.07)


func test_slots_between_covers_range() -> void:
	var top: float = WallDecorRules.slot_y(10) - 1.0
	var bottom: float = WallDecorRules.slot_y(5) + 1.0
	assert_eq(WallDecorRules.slots_between(top, bottom), Vector2i(5, 10))
	var below_first: Vector2i = WallDecorRules.slots_between(-10.0, 500.0)
	assert_gt(below_first.x, below_first.y, "ilk yuvanın altı boş aralık")


func test_every_theme_has_items() -> void:
	assert_eq(WallDecorRules.THEME_ITEMS.size(), WorldPalette.theme_count())


func test_world_y_matches_parallax_at_start_and_runs_ahead_higher_up() -> void:
	var rest_top: float = Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT
	assert_almost_eq(WallDecorRules.world_y_of(rest_top), rest_top, 0.01, "başlangıçta kayma yok")
	var high: float = -20000.0
	assert_lt(WallDecorRules.world_y_of(high), high, "yükseklerde dünya y'si duvar uzayından ileride")
