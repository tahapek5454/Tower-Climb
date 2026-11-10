extends GutTest
## GameState skor hesabı testleri. Global autoload'a dokunmamak için taze bir örnek kullanılır.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")

var state: Node


func before_each() -> void:
	state = GameStateScript.new()
	# _physics_process kendi kendine süre ilerletmesin; testte advance() elle çağrılır.
	state.set_physics_process(false)
	add_child_autofree(state)


func test_score_is_highest_floor_times_points() -> void:
	state.register_landing(1)
	assert_eq(state.score, Tuning.SCORE_PER_FLOOR)
	state.register_landing(0)
	assert_eq(state.floor_number, 1, "aşağı inmek en yüksek katı düşürmez")
	assert_eq(state.score, Tuning.SCORE_PER_FLOOR)


func test_combo_bonus_added_when_combo_ends() -> void:
	var step: int = Tuning.COMBO_MIN_FLOORS
	state.register_landing(step)
	state.register_landing(step * 2)
	state.register_landing(step * 3)
	assert_eq(state.combo_jumps, 3)
	var top: int = step * 3
	assert_eq(state.score, top * Tuning.SCORE_PER_FLOOR, "kombo bitmeden bonus yok")
	state.register_landing(top + 1)
	assert_eq(state.combo_jumps, 0)
	assert_eq(state.score, (top + 1) * Tuning.SCORE_PER_FLOOR + top * top)


func test_combo_bonus_added_on_timeout() -> void:
	var step: int = Tuning.COMBO_MIN_FLOORS
	state.register_landing(step)
	state.register_landing(step * 2)
	state.advance(Tuning.COMBO_TIMEOUT + 0.1)
	var top: int = step * 2
	assert_eq(state.score, top * Tuning.SCORE_PER_FLOOR + top * top)


func test_active_combo_counts_at_game_over() -> void:
	var step: int = Tuning.COMBO_MIN_FLOORS
	state.register_landing(step)
	state.register_landing(step * 2)
	state.end_game()
	var top: int = step * 2
	assert_eq(state.score, top * Tuning.SCORE_PER_FLOOR + top * top)


func test_reset_clears_score_but_keeps_high_score() -> void:
	state.register_landing(5)
	var best: int = state.score
	state.end_game()
	state.reset()
	assert_eq(state.score, 0)
	assert_eq(state.floor_number, 0)
	assert_eq(state.combo_jumps, 0)
	assert_eq(state.high_score, best)
