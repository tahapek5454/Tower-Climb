extends GutTest
## Efekt kozmetikleri: gökkuşağı rengi, boyama ve katalog alanları.


func test_rainbow_changes_over_time() -> void:
	var a: Color = TrailCosmetic.rainbow_color(0.0)
	var b: Color = TrailCosmetic.rainbow_color(Tuning.TRAIL_RAINBOW_PERIOD * 0.5)
	assert_ne(a, b)


func test_rainbow_loops_after_one_period() -> void:
	var a: Color = TrailCosmetic.rainbow_color(1.3)
	var b: Color = TrailCosmetic.rainbow_color(1.3 + Tuning.TRAIL_RAINBOW_PERIOD)
	assert_almost_eq(a.h, b.h, 0.001)


func test_rainbow_is_pastel_and_valid() -> void:
	for i in 20:
		var c: Color = TrailCosmetic.rainbow_color(float(i) * 0.7, 0.05 * i)
		assert_almost_eq(c.s, Tuning.TRAIL_RAINBOW_SATURATION, 0.01)
		assert_almost_eq(c.v, Tuning.TRAIL_RAINBOW_VALUE, 0.01)
		assert_between(c.h, 0.0, 1.0)


func test_plain_color_is_constant() -> void:
	var item: Dictionary = ShopCatalog.get_item(&"trail_teal")
	assert_eq(TrailCosmetic.head_color(item, 0.0), item["color"])
	assert_eq(TrailCosmetic.head_color(item, 37.5), item["color"])


func test_tint_zero_keeps_base() -> void:
	var base := Color(0.2, 0.4, 0.6)
	assert_eq(TrailCosmetic.tint(base, Color.RED, 0.0), base)


func test_unknown_id_resolves_to_default() -> void:
	var item: Dictionary = TrailCosmetic.resolve(&"yok_boyle_urun")
	assert_eq(item["id"], ShopCatalog.default_of(ShopCatalog.TRAIL))
	assert_eq(TrailCosmetic.resolve(&"")["id"], ShopCatalog.default_of(ShopCatalog.TRAIL))


func test_every_trail_item_has_fields_and_known_style() -> void:
	var styles: Array = [ShopCatalog.STYLE_PLAIN, ShopCatalog.STYLE_RAINBOW, ShopCatalog.STYLE_SPARKLE]
	var items: Array[Dictionary] = ShopCatalog.items_in(ShopCatalog.TRAIL)
	assert_gt(items.size(), 0)
	for item in items:
		assert_true(item.has("color") and item.has("color2") and item.has("style"), str(item["id"]))
		assert_true(styles.has(item["style"]), str(item["id"]))
