extends GutTest
## Mağaza: ürün tablosu, saf kurallar, kayıt ve Shop autoload'u. Gerçek kayda dokunmamak için geçici dosya.

const TEMP_SAVE: String = "user://test_shop_save.cfg"

var _saved_path: String
var _saved_diamonds: int
var _saved_lifetime: int


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	_remove_temp()
	_saved_diamonds = GameState.diamonds
	_saved_lifetime = GameState.lifetime_diamonds
	GameState.diamonds = 0
	GameState.lifetime_diamonds = 0
	Shop.reload()


func after_each() -> void:
	GameState.diamonds = _saved_diamonds
	GameState.lifetime_diamonds = _saved_lifetime
	_remove_temp()
	SaveData.path = _saved_path
	Shop.reload()


func test_catalog_is_well_formed() -> void:
	var seen: Dictionary = {}
	for item: Dictionary in ShopCatalog.ITEMS:
		assert_false(seen.has(item["id"]), "kimlik tekrarı: %s" % item["id"])
		seen[item["id"]] = true
		assert_true(ShopCatalog.CATEGORIES.has(item["category"]), "bilinmeyen tür: %s" % item["id"])
		assert_ne(String(item["title"]), "")
		assert_gte(int(item["price"]), 0)
		if item["category"] == ShopCatalog.UPGRADE:
			assert_gt(ShopCatalog.max_level(item["id"]), 0, "yükseltmenin seviyesi olmalı")
			assert_eq(int(item["prices"][0]), int(item["price"]))
		elif item["category"] == ShopCatalog.BOOST:
			assert_gt(int(item["price"]), 0)


func test_every_slot_has_a_free_default() -> void:
	for slot: StringName in ShopCatalog.SLOTS:
		var item: Dictionary = ShopCatalog.get_item(ShopCatalog.default_of(slot))
		assert_eq(item.get("category"), slot)
		assert_eq(int(item.get("price", -1)), 0)
	for category: StringName in ShopCatalog.CATEGORIES:
		assert_true(ShopCatalog.CATEGORY_TITLES.has(category))
		assert_false(ShopCatalog.items_in(category).is_empty())


func test_defaults_are_owned_and_equipped_in_empty_state() -> void:
	var state: Dictionary = ShopRules.empty_state()
	assert_eq(ShopRules.equipped(state, ShopCatalog.HAT), &"hat_none")
	assert_eq(ShopRules.status(state, &"hat_none", 0), ShopRules.Status.EQUIPPED)
	assert_true(ShopRules.is_owned(state, &"shirt_default"))
	assert_false(ShopRules.is_owned(state, &"hat_cap"))


func test_status_depends_on_diamonds_and_ownership() -> void:
	var state: Dictionary = ShopRules.empty_state()
	var cost: int = ShopRules.price(state, &"hat_cap")
	assert_eq(ShopRules.status(state, &"hat_cap", cost - 1), ShopRules.Status.TOO_EXPENSIVE)
	assert_eq(ShopRules.status(state, &"hat_cap", cost), ShopRules.Status.BUYABLE)
	assert_eq(ShopRules.status(state, &"yok", 9999), ShopRules.Status.UNKNOWN)
	state = ShopRules.purchased(state, &"hat_cap")
	assert_eq(ShopRules.status(state, &"hat_cap", 0), ShopRules.Status.EQUIPPED, "alınan kozmetik kuşanılır")
	assert_eq(ShopRules.status(state, &"hat_none", 0), ShopRules.Status.OWNED)
	state = ShopRules.with_equipped(state, &"hat_none")
	assert_eq(ShopRules.status(state, &"hat_cap", 0), ShopRules.Status.OWNED)


func test_cannot_equip_unowned() -> void:
	var state: Dictionary = ShopRules.with_equipped(ShopRules.empty_state(), &"hat_crown")
	assert_eq(ShopRules.equipped(state, ShopCatalog.HAT), &"hat_none")


func test_purchase_does_not_mutate_input() -> void:
	var state: Dictionary = ShopRules.empty_state()
	ShopRules.purchased(state, &"hat_cap")
	assert_eq(state, ShopRules.empty_state())


func test_upgrade_levels_and_prices() -> void:
	var id: StringName = ShopCatalog.UP_MAGNET
	var prices: Array = ShopCatalog.get_item(id)["prices"]
	var state: Dictionary = ShopRules.empty_state()
	for index: int in prices.size():
		assert_eq(ShopRules.level(state, id), index)
		assert_eq(ShopRules.price(state, id), int(prices[index]))
		state = ShopRules.purchased(state, id)
	assert_eq(ShopRules.price(state, id), -1)
	assert_eq(ShopRules.status(state, id, 99999), ShopRules.Status.MAXED)
	assert_eq(ShopRules.level(ShopRules.purchased(state, id), id), prices.size(), "son seviye aşılmaz")


func test_boost_stock_fills_and_drains() -> void:
	var id: StringName = ShopCatalog.BOOST_HEART
	var state: Dictionary = ShopRules.empty_state()
	for count: int in Tuning.SHOP_BOOST_MAX_STOCK:
		assert_eq(ShopRules.stock(state, id), count)
		state = ShopRules.purchased(state, id)
	assert_eq(ShopRules.status(state, id, 99999), ShopRules.Status.STOCK_FULL)
	state = ShopRules.with_boost_used(state, id)
	assert_eq(ShopRules.stock(state, id), Tuning.SHOP_BOOST_MAX_STOCK - 1)
	assert_eq(ShopRules.stock(ShopRules.with_boost_used(ShopRules.empty_state(), id), id), 0)


func test_sanitized_drops_junk() -> void:
	var raw: Dictionary = {
		"owned": {"hat_cap": true, "yok": true, "up_magnet": true},
		"equipped": {"hat": "hat_crown", "shirt": "hat_cap", "pants": 5},
		"levels": {"up_magnet": 99, "up_luck": "çok", "hat_cap": 2},
		"stock": {"boost_heart": 99, "boost_rocket": -3, "hat_cap": 1},
	}
	var state: Dictionary = ShopRules.sanitized(raw)
	assert_eq(state["owned"], {"hat_cap": true})
	assert_eq(state["equipped"], {}, "sahip olunmayan ya da yanlış yuvadaki ürün kuşanılmaz")
	assert_eq(state["levels"], {"up_magnet": ShopCatalog.max_level(&"up_magnet")})
	assert_eq(state["stock"], {"boost_heart": Tuning.SHOP_BOOST_MAX_STOCK})
	assert_eq(ShopRules.sanitized({"owned": 3, "levels": []}), ShopRules.empty_state())


func test_save_roundtrip_keeps_other_sections() -> void:
	assert_eq(ShopRules.sanitized(SaveData.load_shop()), ShopRules.empty_state(), "dosya yoksa boş")
	SaveData.save_diamonds(7)
	SaveData.save_achievement(&"floor_50")
	var state: Dictionary = ShopRules.purchased(ShopRules.empty_state(), &"hat_cap")
	state = ShopRules.purchased(state, ShopCatalog.UP_LUCK)
	state = ShopRules.purchased(state, ShopCatalog.BOOST_ROCKET)
	SaveData.save_shop(state)
	assert_eq(ShopRules.sanitized(SaveData.load_shop()), state)
	assert_eq(SaveData.load_diamonds(), 7)
	assert_true(SaveData.load_achievements().has("floor_50"))
	SaveData.save_records(SaveData.empty())
	assert_eq(ShopRules.sanitized(SaveData.load_shop()), state, "rekor sıfırlama mağazaya dokunmaz")


func test_shop_buy_spends_saves_and_announces() -> void:
	var cost: int = Shop.price(&"hat_cap")
	GameState.diamonds = cost + 5
	watch_signals(Events)
	assert_true(Shop.buy(&"hat_cap"))
	assert_eq(GameState.diamonds, 5)
	assert_eq(SaveData.load_diamonds(), 5)
	assert_eq(Shop.equipped(ShopCatalog.HAT), &"hat_cap")
	assert_signal_emitted_with_parameters(Events, "shop_purchased", [&"hat_cap"])
	assert_signal_emitted_with_parameters(Events, "shop_equipped", [ShopCatalog.HAT, &"hat_cap"])
	assert_false(Shop.buy(&"hat_cap"), "ikinci kez alınmaz")
	assert_eq(GameState.diamonds, 5)
	Shop.reload()
	assert_eq(Shop.equipped(ShopCatalog.HAT), &"hat_cap", "kayıttan geri gelir")


func test_shop_refuses_when_too_expensive() -> void:
	GameState.diamonds = Shop.price(&"hat_crown") - 1
	assert_false(Shop.buy(&"hat_crown"))
	assert_eq(GameState.diamonds, Shop.price(&"hat_crown") - 1)
	assert_false(Shop.equip(&"hat_crown"))
	assert_eq(Shop.equipped(ShopCatalog.HAT), &"hat_none")


func test_shop_boost_is_consumed_once() -> void:
	GameState.diamonds = Shop.price(ShopCatalog.BOOST_HEART)
	assert_true(Shop.buy(ShopCatalog.BOOST_HEART))
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 1)
	assert_true(Shop.consume_boost(ShopCatalog.BOOST_HEART))
	assert_false(Shop.consume_boost(ShopCatalog.BOOST_HEART))
	Shop.reload()
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 0)


func test_spending_keeps_lifetime_total() -> void:
	GameState.grant_reward_diamonds(10)
	assert_eq(GameState.lifetime_diamonds, 10)
	assert_false(GameState.spend_diamonds(11))
	assert_false(GameState.spend_diamonds(-1))
	assert_true(GameState.spend_diamonds(4))
	assert_eq(GameState.diamonds, 6)
	assert_eq(GameState.lifetime_diamonds, 10, "harcama kazanılan toplamı düşürmez")
	assert_eq(SaveData.load_diamonds(), 6)
	assert_eq(SaveData.load_lifetime_diamonds(), 10)


func test_lifetime_falls_back_to_wallet_for_old_saves() -> void:
	SaveData.save_diamonds(35)
	assert_eq(SaveData.load_lifetime_diamonds(), 35)


func _remove_temp() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
