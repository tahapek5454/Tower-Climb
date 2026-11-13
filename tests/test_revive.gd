extends GutTest
## Elmasla devam: fiyat/hak kuralları (ReviveRules), GameState harcaması ve tur sayacı, kalple kurtulma
## başarımının elmasla devamda açılmaması. Gerçek kayda dokunmamak için geçici dosya kullanılır.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
const TEMP_SAVE: String = "user://test_revive_save.cfg"

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


func after_each() -> void:
	GameFlow.state = _saved_flow
	GameState.diamonds = _saved_diamonds
	GameState.lifetime_diamonds = _saved_lifetime
	_remove_temp()
	SaveData.path = _saved_path


func test_prices_follow_tuning_and_rise() -> void:
	var count: int = Tuning.REVIVE_PRICES.size()
	assert_eq(ReviveRules.max_revives(), count)
	for i: int in count:
		assert_eq(ReviveRules.price(i), Tuning.REVIVE_PRICES[i])
		if i > 0:
			assert_gt(ReviveRules.price(i), ReviveRules.price(i - 1), "fiyat her devamda artar")
	assert_eq(ReviveRules.price(count), -1, "haklar bitti")
	assert_eq(ReviveRules.price(-1), -1)


func test_can_offer_needs_rights_and_enough_diamonds() -> void:
	var first: int = ReviveRules.price(0)
	assert_true(ReviveRules.can_offer(0, first))
	assert_false(ReviveRules.can_offer(0, first - 1), "elmas yetmiyor")
	var last: int = ReviveRules.max_revives() - 1
	assert_true(ReviveRules.can_offer(last, ReviveRules.price(last)))
	assert_false(ReviveRules.can_offer(ReviveRules.max_revives(), 1000000), "haklar bitince kart yok")


func test_enabled_follows_both_switches() -> void:
	assert_eq(ReviveRules.is_enabled(), Tuning.REVIVE_ENABLED and Tuning.SHOP_ENABLED)


func test_time_left_ratio_and_urgency() -> void:
	var duration: float = Tuning.REVIVE_OFFER_TIME
	assert_almost_eq(ReviveRules.time_left_ratio(0.0), 1.0, 0.0001)
	assert_almost_eq(ReviveRules.time_left_ratio(duration * 0.5), 0.5, 0.0001)
	assert_eq(ReviveRules.time_left_ratio(duration + 1.0), 0.0)
	assert_eq(ReviveRules.time_left_ratio(1.0, 0.0), 0.0)
	assert_false(ReviveRules.is_urgent(1.0))
	assert_true(ReviveRules.is_urgent(Tuning.REVIVE_URGENT_RATIO * 0.5))


func test_use_revive_spends_rising_prices_until_rights_end() -> void:
	var state: Node = add_child_autofree(GameStateScript.new())
	var total: int = 0
	for price: int in Tuning.REVIVE_PRICES:
		total += price
	state.diamonds = total + 5
	for i: int in ReviveRules.max_revives():
		var before: int = state.diamonds
		assert_true(state.use_revive())
		assert_eq(state.diamonds, before - ReviveRules.price(i))
		assert_eq(state.revives_used, i + 1)
	assert_false(state.use_revive(), "haklar bitti")
	assert_eq(state.diamonds, 5, "başarısız denemede elmas düşmez")
	assert_eq(SaveData.load_diamonds(), 5, "harcama kaydedilir")
	state.reset()
	assert_eq(state.revives_used, 0, "yeni turda haklar yenilenir")


func test_use_revive_fails_without_enough_diamonds() -> void:
	var state: Node = add_child_autofree(GameStateScript.new())
	state.diamonds = ReviveRules.price(0) - 1
	assert_false(state.use_revive())
	assert_eq(state.diamonds, ReviveRules.price(0) - 1)
	assert_eq(state.revives_used, 0)


func test_revive_rescue_does_not_unlock_heart_achievement() -> void:
	GameState.diamonds = 0
	GameState.lifetime_diamonds = 0
	var tracker: AchievementTracker = add_child_autofree(AchievementTracker.new())
	GameFlow.state = FlowRules.State.PLAYING
	tracker._on_player_event(&"rescued", {"source": &"revive"})
	assert_false(tracker.is_unlocked(&"rescue_first"), "elmasla devam kalp değil")
	tracker._on_player_event(&"rescued", {"source": &"heart"})
	assert_true(tracker.is_unlocked(&"rescue_first"))


func _remove_temp() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
