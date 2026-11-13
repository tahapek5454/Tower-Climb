extends GutTest
## ShopLabels: durum → düğme yazısı / eylem, sekme gezinmesi, önizlemede deneme.

const S := ShopRules.Status


func test_action_text_per_status() -> void:
	assert_eq(ShopLabels.action_text(S.BUYABLE), "Al")
	assert_eq(ShopLabels.action_text(S.TOO_EXPENSIVE), "Al")
	assert_eq(ShopLabels.action_text(S.OWNED), "Kuşan")
	assert_eq(ShopLabels.action_text(S.EQUIPPED), "Kuşanıldı")
	assert_eq(ShopLabels.action_text(S.MAXED), "Tam")
	assert_eq(ShopLabels.action_text(S.STOCK_FULL), "Dolu")
	assert_eq(ShopLabels.action_text(S.UNKNOWN), "")


func test_action_for_status() -> void:
	assert_eq(ShopLabels.action_for(S.BUYABLE), ShopLabels.Action.BUY)
	assert_eq(ShopLabels.action_for(S.OWNED), ShopLabels.Action.EQUIP)
	for status: S in [S.TOO_EXPENSIVE, S.MAXED, S.STOCK_FULL]:
		assert_eq(ShopLabels.action_for(status), ShopLabels.Action.DENY)
	assert_eq(ShopLabels.action_for(S.EQUIPPED), ShopLabels.Action.NONE)
	assert_eq(ShopLabels.action_for(S.UNKNOWN), ShopLabels.Action.NONE)


func test_price_shown_only_before_buying() -> void:
	assert_true(ShopLabels.shows_price(S.BUYABLE))
	assert_true(ShopLabels.shows_price(S.TOO_EXPENSIVE))
	for status: S in [S.OWNED, S.EQUIPPED, S.MAXED, S.STOCK_FULL]:
		assert_false(ShopLabels.shows_price(status))


func test_wrap_index_cycles_through_categories() -> void:
	var count: int = ShopCatalog.CATEGORIES.size()
	assert_eq(ShopLabels.wrap_index(0, 1, count), 1)
	assert_eq(ShopLabels.wrap_index(0, -1, count), count - 1)
	assert_eq(ShopLabels.wrap_index(count - 1, 1, count), 0)
	assert_eq(ShopLabels.wrap_index(3, 0, 0), 0)


func test_try_on_replaces_only_focused_slot() -> void:
	var equipped: Dictionary = {ShopCatalog.HAT: &"hat_cap", ShopCatalog.SHIRT: &"shirt_red"}
	var result: Dictionary = ShopLabels.try_on(equipped, &"hat_crown")
	assert_eq(result[ShopCatalog.HAT], &"hat_crown")
	assert_eq(result[ShopCatalog.SHIRT], &"shirt_red")
	assert_eq(result[ShopCatalog.PANTS], ShopCatalog.default_of(ShopCatalog.PANTS))
	assert_eq(result.size(), ShopCatalog.MODEL_SLOTS.size())


func test_try_on_ignores_non_model_items() -> void:
	var equipped: Dictionary = {ShopCatalog.HAT: &"hat_cap"}
	for id: StringName in [&"trail_gold", ShopCatalog.BOOST_HEART, ShopCatalog.UP_LUCK, &""]:
		var result: Dictionary = ShopLabels.try_on(equipped, id)
		assert_eq(result[ShopCatalog.HAT], &"hat_cap")
		assert_eq(result[ShopCatalog.SHIRT], ShopCatalog.default_of(ShopCatalog.SHIRT))


func test_trail_preview_follows_focused_trail() -> void:
	assert_eq(ShopLabels.trail_preview(&"trail_default", &"trail_rainbow"), &"trail_rainbow")
	assert_eq(ShopLabels.trail_preview(&"trail_gold", &"hat_cap"), &"trail_gold")
	assert_eq(ShopLabels.trail_preview(&"trail_gold", &""), &"trail_gold")
