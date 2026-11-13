extends GutTest
## Giyilebilir kozmetikler: katalog ↔ model eşleşmesi, boyama verisi, geçersiz kimliklerin güvenli işlenmesi.


func test_every_hat_has_a_model_node() -> void:
	var names: PackedStringArray = HatModel.hat_names()
	for item: Dictionary in ShopCatalog.items_in(ShopCatalog.HAT):
		var node_name: String = CosmeticRules.hat_node_name(item["id"])
		if item["id"] == ShopCatalog.default_of(ShopCatalog.HAT):
			assert_eq(node_name, "", "şapkasız → düğüm yok")
		else:
			assert_true(names.has(node_name), "%s accessories.glb'de olmalı" % item["id"])


func test_unknown_or_wrong_slot_ids_fall_back_to_default() -> void:
	assert_eq(CosmeticRules.resolve(ShopCatalog.HAT, &"no_such_item"), ShopCatalog.default_of(ShopCatalog.HAT))
	assert_eq(CosmeticRules.resolve(ShopCatalog.HAT, &"shirt_red"), ShopCatalog.default_of(ShopCatalog.HAT))
	assert_eq(CosmeticRules.resolve(ShopCatalog.SHIRT, &""), ShopCatalog.default_of(ShopCatalog.SHIRT))
	assert_eq(CosmeticRules.hat_node_name(&"no_such_item"), "")
	assert_false(CosmeticRules.shirt_paint(&"pants_jeans")["enabled"], "pantolon kimliği tişörtü boyamaz")
	assert_false(CosmeticRules.pants_paint(&"nope")["enabled"])


func test_shirts_have_paint_fields() -> void:
	for item: Dictionary in ShopCatalog.items_in(ShopCatalog.SHIRT):
		assert_true(item.get("color") is Color, "%s color" % item["id"])
		assert_true(item.get("color2") is Color, "%s color2" % item["id"])
		assert_true(CosmeticRules.PATTERN_INDEX.has(item.get("pattern", &"")), "%s desen" % item["id"])
		var paint: Dictionary = CosmeticRules.shirt_paint(item["id"])
		assert_eq(paint["enabled"], item["id"] != ShopCatalog.default_of(ShopCatalog.SHIRT))
		assert_eq(paint["color"], item["color"])
		assert_eq(paint["pattern"], CosmeticRules.pattern_index(item["pattern"]))


func test_pants_have_paint_fields() -> void:
	for item: Dictionary in ShopCatalog.items_in(ShopCatalog.PANTS):
		assert_true(item.get("color") is Color, "%s color" % item["id"])
		var paint: Dictionary = CosmeticRules.pants_paint(item["id"])
		assert_eq(paint["enabled"], item["id"] != ShopCatalog.default_of(ShopCatalog.PANTS))
		assert_eq(paint["color"], item["color"])


func test_pattern_indices_are_distinct() -> void:
	var seen: Array = []
	for pattern: StringName in CosmeticRules.PATTERN_INDEX:
		var index: int = CosmeticRules.pattern_index(pattern)
		assert_false(seen.has(index))
		seen.append(index)
	assert_eq(CosmeticRules.pattern_index(&"unknown"), 0, "bilinmeyen desen → düz")


func test_hat_model_swaps_and_removes_hats() -> void:
	var hat := HatModel.new()
	add_child_autofree(hat)
	hat.show_hat(&"hat_propeller", false)
	assert_eq(hat.current_hat(), &"hat_propeller")
	assert_not_null(hat.get_node_or_null(^"hat_propeller"))
	hat.show_hat(&"hat_crown", false)
	assert_eq(hat.current_hat(), &"hat_crown")
	hat.show_hat(&"hat_none")
	assert_eq(hat.current_hat(), &"")
	hat.show_hat(&"no_such_hat")
	assert_eq(hat.current_hat(), &"")


func test_character_model_applies_cosmetics() -> void:
	if not CharacterModel.is_available():
		pass_test("model yok")
		return
	var model := CharacterModel.new()
	model.set_cosmetic(ShopCatalog.HAT, &"hat_santa")  # sahneye girmeden önce verilen de uygulanmalı
	add_child_autofree(model)
	var hat: HatModel = model.find_child("Hat", true, false) as HatModel
	assert_not_null(hat)
	assert_eq(hat.current_hat(), &"hat_santa" if Tuning.COSMETICS_ENABLED else &"")
	var material: ShaderMaterial = model._toon_materials[0]
	model.set_cosmetic(ShopCatalog.SHIRT, &"shirt_star")
	assert_eq(material.get_shader_parameter(&"shirt_enabled"), Tuning.COSMETICS_ENABLED)
	assert_eq(material.get_shader_parameter(&"shirt_pattern"), CosmeticRules.pattern_index(ShopCatalog.PATTERN_STAR))
	model.set_cosmetic(ShopCatalog.SHIRT, &"bogus")
	assert_false(material.get_shader_parameter(&"shirt_enabled"), "geçersiz → varsayılan (boyasız)")
	model.set_cosmetic(ShopCatalog.PANTS, &"pants_jeans")
	assert_eq(material.get_shader_parameter(&"pants_enabled"), Tuning.COSMETICS_ENABLED)
	model.set_cosmetic(ShopCatalog.PANTS, ShopCatalog.default_of(ShopCatalog.PANTS))
	assert_false(material.get_shader_parameter(&"pants_enabled"))
