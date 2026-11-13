extends GutTest
## Kombo elması: kural (saf) ve GameState'in ödülü.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
const TEMP_SAVE: String = "user://test_save_combo_diamond.cfg"

var _saved_path: String
var _earned: Array[int] = []


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	_earned = []


func after_each() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	SaveData.path = _saved_path


func test_no_diamond_below_min_floors() -> void:
	assert_eq(ComboDiamondRules.diamonds_for(Tuning.COMBO_DIAMOND_MIN_FLOORS - 1, 100), 0)


func test_no_diamond_without_bonus() -> void:
	assert_eq(ComboDiamondRules.diamonds_for(Tuning.COMBO_DIAMOND_MIN_FLOORS * 3, 0), 0)


func test_one_diamond_at_threshold_and_steps_up() -> void:
	var min_floors: int = Tuning.COMBO_DIAMOND_MIN_FLOORS
	var step: int = Tuning.COMBO_DIAMOND_STEP_FLOORS
	assert_eq(ComboDiamondRules.diamonds_for(min_floors, 1), 1)
	assert_eq(ComboDiamondRules.diamonds_for(min_floors + step - 1, 1), 1)
	assert_eq(ComboDiamondRules.diamonds_for(min_floors + step, 1), mini(2, Tuning.COMBO_DIAMOND_MAX))


func test_capped_at_max() -> void:
	assert_eq(ComboDiamondRules.diamonds_for(100000, 1), Tuning.COMBO_DIAMOND_MAX)


func test_game_state_awards_diamonds_when_big_combo_ends() -> void:
	var state: Node = _new_state()
	Events.combo_diamonds_earned.connect(_on_earned)
	var step: int = Tuning.COMBO_DIAMOND_MIN_FLOORS / 2
	state.register_landing(step)
	state.register_landing(step * 2)
	state.end_game()
	Events.combo_diamonds_earned.disconnect(_on_earned)
	var expected: int = ComboDiamondRules.diamonds_for(step * 2, step * 2 * step * 2)
	assert_eq(expected, 1)
	assert_eq(state.diamonds, 1)
	assert_eq(state.run_diamonds, 1, "oyun sonu ekranındaki elmas satırı bunu sayar")
	assert_eq(SaveData.load_diamonds(), 1, "kaydedilir")
	assert_eq(_earned, [1])


func test_small_combo_gives_no_diamond() -> void:
	var state: Node = _new_state()
	state.register_landing(2)
	state.register_landing(4)
	state.end_game()
	assert_eq(state.diamonds, 0)


func test_add_diamonds_batches_and_ignores_after_game_over() -> void:
	var state: Node = _new_state()
	state.add_diamonds(3)
	assert_eq(state.diamonds, 3)
	state.add_diamonds(0)
	assert_eq(state.diamonds, 3)
	state.end_game()
	state.add_diamonds(2)
	assert_eq(state.diamonds, 3)


func _on_earned(count: int) -> void:
	_earned.append(count)


func _new_state() -> Node:
	var state: Node = GameStateScript.new()
	state.set_physics_process(false)
	add_child_autofree(state)
	return state
