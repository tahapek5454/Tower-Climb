extends GutTest
## MaÄŸaza yÃ¼kseltmeleri ve takviyeleri: seviye â†’ etkin deÄŸer (UpgradeRules), kalp sÄ±nÄ±rÄ±, Shop seviyesinin
## oyuna yansÄ±masÄ± (Upgrades), maÄŸaza boÅŸken taban davranÄ±ÅŸ, takviyenin turda bir kez kullanÄ±lmasÄ± (RunBoosts).

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
const TEMP_SAVE: String = "user://test_upgrades_save.cfg"
const UPGRADE_IDS: Array[StringName] = [ShopCatalog.UP_JETPACK, ShopCatalog.UP_HOURGLASS,
	ShopCatalog.UP_MAGNET, ShopCatalog.UP_HEARTS, ShopCatalog.UP_LUCK]

var _saved_path: String


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	Shop.reload()


func after_each() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	SaveData.path = _saved_path
	Shop.reload()


## Kayda verilen seviyeler ve stoklarla maÄŸaza durumu yazar ve Shop'u yeniden yÃ¼kler.
func _set_shop(levels: Dictionary, stock: Dictionary = {}) -> void:
	var state: Dictionary = ShopRules.empty_state()
	for id: StringName in levels:
		state[ShopRules.LEVELS][String(id)] = levels[id]
	for id: StringName in stock:
		state[ShopRules.STOCK][String(id)] = stock[id]
	SaveData.save_shop(state)
	Shop.reload()


func _expected_level(level: int) -> int:
	return level if Tuning.UPGRADES_ENABLED else 0


func test_every_level_adds_one_step() -> void:
	for level: int in range(0, 4):
		var steps: int = _expected_level(level)
		assert_almost_eq(UpgradeRules.jetpack_time(level),
				Tuning.JETPACK_FLIGHT_TIME + Tuning.UPGRADE_JETPACK_STEP * steps, 0.0001)
		assert_almost_eq(UpgradeRules.hourglass_duration(level),
				Tuning.HOURGLASS_DURATION + Tuning.UPGRADE_HOURGLASS_STEP * steps, 0.0001)
		assert_almost_eq(UpgradeRules.magnet_duration(level),
				Tuning.MAGNET_DURATION + Tuning.UPGRADE_MAGNET_STEP * steps, 0.0001)
		assert_eq(UpgradeRules.heart_max(level), Tuning.HEART_MAX + Tuning.UPGRADE_HEARTS_STEP * steps)
		assert_almost_eq(UpgradeRules.spawn_chance(Tuning.JETPACK_SPAWN_CHANCE, level),
				Tuning.JETPACK_SPAWN_CHANCE * (1.0 + Tuning.UPGRADE_LUCK_STEP * steps), 0.00001)


func test_levels_are_clamped() -> void:
	for id: StringName in UPGRADE_IDS:
		var top: int = ShopCatalog.max_level(id)
		assert_eq(UpgradeRules.effective_level(id, -2), 0, "negatif seviye 0 sayÄ±lÄ±r")
		assert_eq(UpgradeRules.effective_level(id, top + 5), _expected_level(top), "en yÃ¼ksek seviyeyi geÃ§mez")
	var top_jetpack: int = ShopCatalog.max_level(ShopCatalog.UP_JETPACK)
	assert_eq(UpgradeRules.jetpack_time(99), UpgradeRules.jetpack_time(top_jetpack))
	assert_eq(UpgradeRules.heart_max(-1), Tuning.HEART_MAX)
	assert_lte(UpgradeRules.spawn_chance(0.9, 99), 1.0, "olasÄ±lÄ±k 1'i geÃ§mez")


func test_upgrades_only_improve() -> void:
	for level: int in range(0, 3):
		assert_gte(UpgradeRules.jetpack_time(level + 1), UpgradeRules.jetpack_time(level))
		assert_gte(UpgradeRules.hourglass_duration(level + 1), UpgradeRules.hourglass_duration(level))
		assert_gte(UpgradeRules.magnet_duration(level + 1), UpgradeRules.magnet_duration(level))
		assert_gte(UpgradeRules.heart_max(level + 1), UpgradeRules.heart_max(level))
		assert_gte(UpgradeRules.spawn_chance(0.02, level + 1), UpgradeRules.spawn_chance(0.02, level))


## Tam seviyede de oyunun eski kurallarÄ± korunur: uÃ§arken ikinci rokete, etki sÃ¼rerken ikinci mÄ±knatÄ±sa denk
## gelinmez; taban kalp sÄ±nÄ±rÄ±yla "tek turda 3 kalp" baÅŸarÄ±mÄ±na ulaÅŸÄ±labilir.
func test_max_level_keeps_spawn_gaps_and_achievements() -> void:
	var top_flight: float = UpgradeRules.jetpack_time(ShopCatalog.max_level(ShopCatalog.UP_JETPACK))
	assert_gt(float(Tuning.JETPACK_MIN_FLOOR_GAP), Tuning.JETPACK_SPEED * top_flight / Tuning.FLOOR_SPACING)
	var top_magnet: float = UpgradeRules.magnet_duration(ShopCatalog.max_level(ShopCatalog.UP_MAGNET))
	assert_gt(float(Tuning.MAGNET_MIN_FLOOR_GAP), top_magnet * 3.0)
	assert_gt(Tuning.HOURGLASS_DURATION, Tuning.HOURGLASS_RAMP_TIME * 2.0, "taban kum saati yavaÅŸlamaya yetiÅŸir")
	var target: int = int(AchievementRules.get_def(&"hearts_3").get("target", 0))
	assert_gte(Tuning.HEART_MAX, target, "baÅŸarÄ±m yÃ¼kseltmesiz de aÃ§Ä±labilir")


func test_add_hearts_uses_given_cap() -> void:
	assert_eq(PickupRules.add_hearts(Tuning.HEART_MAX, 1, Tuning.HEART_MAX + 1), Tuning.HEART_MAX + 1)
	assert_eq(PickupRules.add_hearts(Tuning.HEART_MAX, 5, Tuning.HEART_MAX + 1), Tuning.HEART_MAX + 1)
	assert_eq(PickupRules.add_hearts(0, 1, 0), 0)


func test_spawn_rules_take_luck_chance() -> void:
	var floor_number: int = 501  # bölüm katı değil
	var far_back: int = -10000
	var base: float = Tuning.JETPACK_SPAWN_CHANCE
	var lucky: float = UpgradeRules.spawn_chance(base, 3)
	var roll: float = (base + lucky) * 0.5
	assert_false(JetpackRules.should_spawn(floor_number, far_back, roll), "taban olasÄ±lÄ±kla Ã§Ä±kmaz")
	assert_eq(JetpackRules.should_spawn(floor_number, far_back, roll, lucky),
			Tuning.JETPACK_ENABLED and Tuning.UPGRADES_ENABLED)
	var heart_roll: float = Tuning.HEART_SPAWN_CHANCE * 1.1
	assert_eq(PickupRules.should_spawn_heart(floor_number, far_back, heart_roll, Tuning.HEART_SPAWN_CHANCE * 1.2),
			Tuning.HEART_ENABLED)
	assert_eq(MagnetRules.should_spawn(floor_number, far_back, 0.0, 0.01), Tuning.MAGNET_ENABLED)


func test_empty_shop_gives_base_values() -> void:
	_set_shop({})
	assert_eq(Upgrades.jetpack_time(), Tuning.JETPACK_FLIGHT_TIME)
	assert_eq(Upgrades.hourglass_duration(), Tuning.HOURGLASS_DURATION)
	assert_eq(Upgrades.magnet_duration(), Tuning.MAGNET_DURATION)
	assert_eq(Upgrades.heart_max(), Tuning.HEART_MAX)
	assert_eq(Upgrades.luck_level(), 0)


func test_bought_levels_reach_the_game() -> void:
	_set_shop({ShopCatalog.UP_JETPACK: 2, ShopCatalog.UP_HEARTS: 3, ShopCatalog.UP_LUCK: 1})
	var enabled: bool = Tuning.SHOP_ENABLED
	assert_eq(Upgrades.jetpack_time(), UpgradeRules.jetpack_time(2 if enabled else 0))
	assert_eq(Upgrades.heart_max(), UpgradeRules.heart_max(3 if enabled else 0))
	assert_eq(Upgrades.luck_level(), 1 if enabled else 0)
	assert_eq(Upgrades.magnet_duration(), Tuning.MAGNET_DURATION, "alÄ±nmayan yÃ¼kseltme taban")


func test_game_state_heart_cap_follows_upgrade() -> void:
	_set_shop({ShopCatalog.UP_HEARTS: 3})
	var state: Node = autofree(GameStateScript.new())
	state.add_hearts(99)
	assert_eq(state.hearts, Upgrades.heart_max())
	_set_shop({})
	var plain: Node = autofree(GameStateScript.new())
	plain.add_hearts(99)
	assert_eq(plain.hearts, Tuning.HEART_MAX, "yÃ¼kseltmesiz taban sÄ±nÄ±r")


func test_hourglass_uses_given_duration() -> void:
	var camera := TowerCamera.new()
	add_child_autofree(camera)
	camera.set_physics_process(false)
	var duration: float = UpgradeRules.hourglass_duration(3)
	camera.slow_down(duration)
	assert_almost_eq(camera.slow_time_left(), duration, 0.001)
	var t: float = 0.0
	var dt: float = 1.0 / 60.0
	while t < Tuning.HOURGLASS_DURATION + 0.1:
		camera._physics_process(dt)
		t += dt
	assert_eq(camera.is_slowed(), duration > Tuning.HOURGLASS_DURATION + 0.1, "uzun sÃ¼re tabanÄ± aÅŸar")


func test_magnet_uses_given_duration() -> void:
	var magnet := MagnetField.new()
	add_child_autofree(magnet)
	magnet.activate(UpgradeRules.magnet_duration(2))
	assert_almost_eq(magnet.time_left(), UpgradeRules.magnet_duration(2), 0.001)


# --- Takviyeler ---

func _new_boosts(state: Node) -> RunBoosts:
	var boosts := RunBoosts.new()
	boosts.game_state = state
	boosts.heart_delay = 0.0
	boosts.rocket_delay = 0.0
	add_child_autofree(boosts)
	return boosts


func test_boosts_are_used_once_per_run() -> void:
	_set_shop({}, {ShopCatalog.BOOST_HEART: 2, ShopCatalog.BOOST_ROCKET: 1})
	var state: Node = autofree(GameStateScript.new())
	var launches: Array[float] = []
	var boosts: RunBoosts = _new_boosts(state)
	boosts.rocket_launch.connect(func(duration: float) -> void: launches.append(duration))
	boosts.begin_run()
	boosts.begin_run()
	boosts._on_flow_changed(FlowRules.State.PLAYING, FlowRules.State.MENU)
	if not (Tuning.SHOP_ENABLED and Tuning.BOOSTS_ENABLED):
		assert_eq(state.hearts, Tuning.HEART_START, "maÄŸaza/takviye kapalÄ±yken hiÃ§bir ÅŸey olmaz")
		assert_eq(launches.size(), 0)
		return
	assert_eq(state.hearts, Tuning.HEART_START + 1, "yedek kalp: +1")
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 1, "turda yalnÄ±z bir kalp takviyesi")
	assert_eq(launches, [Upgrades.jetpack_time()] as Array[float], "tek roket, yÃ¼kseltmeli sÃ¼re")
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_ROCKET), 0)
	# Yeni tur (sahne yenilenir â†’ yeni dÃ¼ÄŸÃ¼m): kalan kalp kullanÄ±lÄ±r, roket stoÄŸu boÅŸ.
	var next_state: Node = autofree(GameStateScript.new())
	var next_boosts: RunBoosts = _new_boosts(next_state)
	next_boosts.rocket_launch.connect(func(duration: float) -> void: launches.append(duration))
	next_boosts.begin_run()
	assert_eq(next_state.hearts, Tuning.HEART_START + 1)
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 0)
	assert_eq(launches.size(), 1, "stok yokken roket yok")


func test_resume_from_pause_does_not_start_run() -> void:
	_set_shop({}, {ShopCatalog.BOOST_HEART: 1})
	var boosts: RunBoosts = _new_boosts(autofree(GameStateScript.new()))
	boosts._on_flow_changed(FlowRules.State.PLAYING, FlowRules.State.PAUSED)
	boosts._on_flow_changed(FlowRules.State.PLAYING, FlowRules.State.GAME_OVER)
	assert_false(boosts.has_started(), "yalnÄ±z menÃ¼den ya da sahne aÃ§Ä±lÄ±ÅŸÄ±nda")
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 1 if Tuning.SHOP_ENABLED else 0)


func test_boost_is_kept_when_run_is_over() -> void:
	_set_shop({}, {ShopCatalog.BOOST_HEART: 1})
	var state: Node = autofree(GameStateScript.new())
	state.end_game()
	_new_boosts(state).begin_run()
	assert_eq(Shop.boost_stock(ShopCatalog.BOOST_HEART), 1 if Tuning.SHOP_ENABLED else 0, "harcanmaz")
