extends GutTest
## Oyun sonu kuralları (GameOverRules) ve GameState oyun süresi.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")


func test_headline_depends_on_records() -> void:
	assert_eq(GameOverRules.headline([]), GameOverRules.TITLE_NORMAL)
	assert_eq(GameOverRules.headline([SaveData.BEST_FLOOR]), GameOverRules.TITLE_RECORD)
	assert_ne(GameOverRules.subtitle([]), GameOverRules.subtitle([SaveData.BEST_SCORE]))


func test_format_time() -> void:
	assert_eq(GameOverRules.format_time(0.0), "0:00")
	assert_eq(GameOverRules.format_time(9.9), "0:09")
	assert_eq(GameOverRules.format_time(65.0), "1:05")
	assert_eq(GameOverRules.format_time(3600.0), "60:00")
	assert_eq(GameOverRules.format_time(-5.0), "0:00", "negatif süre sıfır sayılır")


func test_eased_count_endpoints_and_monotonic() -> void:
	assert_eq(GameOverRules.eased_count(250, 0.0), 0)
	assert_eq(GameOverRules.eased_count(250, 1.0), 250)
	assert_eq(GameOverRules.eased_count(250, 2.0), 250, "ilerleme 1'e sıkıştırılır")
	assert_eq(GameOverRules.eased_count(0, 0.5), 0)
	var previous: int = -1
	for step: int in 21:
		var value: int = GameOverRules.eased_count(250, step / 20.0)
		assert_true(value >= previous, "azalmaz")
		previous = value


func test_eased_count_is_fast_at_start() -> void:
	assert_gt(GameOverRules.eased_count(100, 0.3), 30, "ease-out: ilk üçte birde yarıdan fazlası değil ama hızlı başlar")


func test_run_time_counts_until_game_over_and_resets() -> void:
	var state: Node = GameStateScript.new()
	state.set_physics_process(false)
	add_child_autofree(state)
	state.add_run_time(1.5)
	state.add_run_time(2.0)
	assert_almost_eq(state.run_time, 3.5, 0.0001)
	state.is_game_over = true
	state.add_run_time(10.0)
	assert_almost_eq(state.run_time, 3.5, 0.0001, "oyun bittikten sonra sayılmaz")
	state.reset()
	assert_eq(state.run_time, 0.0)
