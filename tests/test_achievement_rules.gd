extends GutTest
## Başarım kuralları (saf), kayıt ve izleyici. Gerçek kayda dokunmamak için geçici dosya kullanılır.

const TEMP_SAVE: String = "user://test_achievements_save.cfg"

var _saved_path: String
var _saved_flow: FlowRules.State
var _saved_diamonds: int
var _saved_lifetime: int


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	_remove_temp()
	_saved_flow = GameFlow.state
	_saved_diamonds = GameState.diamonds
	_saved_lifetime = GameState.lifetime_diamonds
	# Gerçek cüzdan testi etkilemesin (toplam elmas başarımları kendiliğinden açılmasın).
	GameState.diamonds = 0
	GameState.lifetime_diamonds = 0


func after_each() -> void:
	GameFlow.state = _saved_flow
	GameState.diamonds = _saved_diamonds
	GameState.lifetime_diamonds = _saved_lifetime
	_remove_temp()
	SaveData.path = _saved_path


func test_definitions_are_well_formed_and_unique() -> void:
	var seen: Dictionary = {}
	for def: Dictionary in AchievementRules.all_defs():
		assert_false(seen.has(def["id"]), "kimlik tekrarı: %s" % def["id"])
		seen[def["id"]] = true
		assert_gt(int(def["reward"]), 0)
		assert_gt(int(def["target"]), 0)
		assert_false(String(def["title"]).is_empty())
		assert_false(String(def["desc"]).is_empty())
	assert_eq(AchievementRules.total(), AchievementRules.all_defs().size())


func test_get_def_known_and_unknown() -> void:
	assert_eq(AchievementRules.get_def(&"floor_100")["target"], 100)
	assert_true(AchievementRules.get_def(&"yok").is_empty())


func test_newly_unlocked_returns_every_reached_target_once() -> void:
	var got: Array[StringName] = AchievementRules.newly_unlocked(AchievementRules.FLOOR, 120, {})
	assert_eq(got, [&"floor_50", &"floor_100"] as Array[StringName])
	var rest: Array[StringName] = AchievementRules.newly_unlocked(AchievementRules.FLOOR, 120, {"floor_50": true})
	assert_eq(rest, [&"floor_100"] as Array[StringName])
	assert_true(AchievementRules.newly_unlocked(AchievementRules.FLOOR, 49, {}).is_empty())


func test_newly_unlocked_ignores_other_stats() -> void:
	assert_true(AchievementRules.newly_unlocked(AchievementRules.COMBO_FLOORS, 9, {}).is_empty())
	assert_eq(AchievementRules.newly_unlocked(AchievementRules.COMBO_FLOORS, 10, {}), [&"combo_10"] as Array[StringName])


func test_count_unlocked_ignores_unknown_ids() -> void:
	assert_eq(AchievementRules.count_unlocked({"floor_50": true, "combo_10": true, "eski_basarim": true}), 2)


func test_save_roundtrip_and_other_sections_untouched() -> void:
	assert_true(SaveData.load_achievements().is_empty(), "dosya yoksa boş")
	SaveData.save_diamonds(7)
	SaveData.save_records({SaveData.BEST_SCORE: 5, SaveData.BEST_FLOOR: 2, SaveData.BEST_COMBO: 1})
	SaveData.save_achievement(&"floor_50")
	SaveData.save_achievement(&"combo_10")
	assert_eq(SaveData.load_achievements(), {"floor_50": true, "combo_10": true})
	assert_eq(SaveData.load_diamonds(), 7)
	assert_eq(SaveData.load_records()[SaveData.BEST_SCORE], 5)


func test_corrupt_achievement_values_are_ignored() -> void:
	var config := ConfigFile.new()
	config.set_value(SaveData.ACHIEVEMENTS_SECTION, "floor_50", "evet")
	config.set_value(SaveData.ACHIEVEMENTS_SECTION, "combo_10", 3)
	config.set_value(SaveData.ACHIEVEMENTS_SECTION, "floor_100", true)
	config.save(TEMP_SAVE)
	assert_eq(SaveData.load_achievements(), {"floor_100": true})


func test_reset_records_keeps_achievements() -> void:
	SaveData.save_achievement(&"floor_50")
	SaveData.save_records(SaveData.empty())
	assert_true(SaveData.load_achievements().has("floor_50"))


func test_tracker_unlocks_once_saves_and_pays_reward() -> void:
	# Ödül elmasları da toplam sayılır; "ilk elmas" önceden açık olsun ki sayım karışmasın.
	SaveData.save_achievement(&"diamond_1")
	var tracker: AchievementTracker = add_child_autofree(AchievementTracker.new())
	GameFlow.state = FlowRules.State.PLAYING
	var before: int = GameState.diamonds
	watch_signals(Events)
	tracker.report(AchievementRules.FLOOR, 60)
	tracker.report(AchievementRules.FLOOR, 61)
	assert_signal_emit_count(Events, "achievement_unlocked", 1)
	assert_true(tracker.is_unlocked(&"floor_50"))
	assert_eq(GameState.diamonds, before + int(AchievementRules.get_def(&"floor_50")["reward"]))
	assert_true(SaveData.load_achievements().has("floor_50"))


func test_tracker_ignores_reports_outside_play() -> void:
	var tracker: AchievementTracker = add_child_autofree(AchievementTracker.new())
	GameFlow.state = FlowRules.State.MENU
	tracker.report(AchievementRules.FLOOR, 500)
	assert_false(tracker.is_unlocked(&"floor_50"))
	assert_true(SaveData.load_achievements().is_empty())


func test_tracker_loads_saved_state() -> void:
	SaveData.save_achievement(&"floor_50")
	SaveData.save_achievement(&"diamond_1")
	var tracker: AchievementTracker = add_child_autofree(AchievementTracker.new())
	GameFlow.state = FlowRules.State.PLAYING
	var before: int = GameState.diamonds
	tracker.report(AchievementRules.FLOOR, 60)
	assert_eq(GameState.diamonds, before, "zaten açık başarım ikinci kez ödül vermez")


func test_grant_reward_diamonds_saves_and_ignores_non_positive() -> void:
	GameState.diamonds = 3
	GameState.grant_reward_diamonds(0)
	GameState.grant_reward_diamonds(-2)
	assert_eq(GameState.diamonds, 3)
	GameState.grant_reward_diamonds(4)
	assert_eq(GameState.diamonds, 7)
	assert_eq(SaveData.load_diamonds(), 7)


func _remove_temp() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(TEMP_SAVE)
