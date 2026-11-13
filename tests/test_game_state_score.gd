extends GutTest
## GameState skor hesabı testleri. Global autoload'a dokunmamak için taze bir örnek kullanılır.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
## Gerçek rekor kaydına dokunmamak için geçici dosya.
const TEMP_SAVE: String = "user://test_save_score.cfg"

var state: Node
var _saved_path: String


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	state = GameStateScript.new()
	# _physics_process kendi kendine süre ilerletmesin; testte advance() elle çağrılır.
	state.set_physics_process(false)
	add_child_autofree(state)


func after_each() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	SaveData.path = _saved_path


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


func test_flight_floors_score_without_combo_bonus() -> void:
	state.register_landing(1)
	state.begin_flight()
	state.register_flight_floor(30)
	state.register_flight_floor(12)
	assert_eq(state.floor_number, 30, "uçarken geçilen en yüksek kat sayılır")
	assert_eq(state.score, 30 * Tuning.SCORE_PER_FLOOR)
	state.end_flight()
	state.register_landing(31)
	assert_eq(state.combo_jumps, 0, "roketin bıraktığı iniş kombo başlatmaz")
	assert_eq(state.score, 31 * Tuning.SCORE_PER_FLOOR, "uçuş kombo bonusu vermez")


func test_flight_freezes_and_keeps_combo() -> void:
	var step: int = Tuning.COMBO_MIN_FLOORS
	state.register_landing(step)
	state.register_landing(step * 2)
	state.begin_flight()
	state.advance(Tuning.COMBO_TIMEOUT + 1.0)
	assert_eq(state.combo_jumps, 2, "uçarken kombo süresi durur")
	state.register_flight_floor(40)
	state.end_flight()
	state.register_landing(41)
	assert_eq(state.combo_jumps, 2, "roket inişi komboyu bozmaz")
	state.register_landing(41 + step)
	assert_eq(state.combo_jumps, 3, "sonraki büyük zıplama komboyu sürdürür")


func test_reset_clears_score_but_keeps_high_score() -> void:
	state.register_landing(5)
	var best: int = state.score
	state.end_game()
	state.reset()
	assert_eq(state.score, 0)
	assert_eq(state.floor_number, 0)
	assert_eq(state.combo_jumps, 0)
	assert_eq(state.high_score, best)
