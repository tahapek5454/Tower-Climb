extends GutTest
## Kalıcı rekor testleri: saf karşılaştırma/birleştirme, dosyaya kayıt ve GameState'in oyun sonunda
## rekorları kaydetmesi. Gerçek kayda dokunmamak için geçici dosya kullanılır.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
const TEMP_SAVE: String = "user://test_save.cfg"

var _saved_path: String


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE
	_remove_temp()


func after_each() -> void:
	_remove_temp()
	SaveData.path = _saved_path


func test_improved_lists_only_strictly_better_values() -> void:
	var old: Dictionary = {SaveData.BEST_SCORE: 100, SaveData.BEST_FLOOR: 10, SaveData.BEST_COMBO: 5}
	var run: Dictionary = {SaveData.BEST_SCORE: 150, SaveData.BEST_FLOOR: 10, SaveData.BEST_COMBO: 3}
	assert_eq(SaveData.improved(old, run), [SaveData.BEST_SCORE] as Array[String],
			"eşit kat ve düşük kombo rekor değil")


func test_merged_keeps_best_of_each() -> void:
	var old: Dictionary = {SaveData.BEST_SCORE: 100, SaveData.BEST_FLOOR: 10, SaveData.BEST_COMBO: 5}
	var run: Dictionary = {SaveData.BEST_SCORE: 50, SaveData.BEST_FLOOR: 12, SaveData.BEST_COMBO: 5}
	var result: Dictionary = SaveData.merged(old, run)
	assert_eq(result[SaveData.BEST_SCORE], 100)
	assert_eq(result[SaveData.BEST_FLOOR], 12)
	assert_eq(result[SaveData.BEST_COMBO], 5)


func test_missing_file_loads_zeros() -> void:
	assert_eq(SaveData.load_records(), SaveData.empty())


func test_save_and_load_round_trip_keeps_other_sections() -> void:
	var config := ConfigFile.new()
	config.set_value("other", "keep", 7)
	config.set_value(SaveData.SECTION, SaveData.BEST_FLOOR, "bozuk")
	config.save(TEMP_SAVE)
	assert_eq(SaveData.load_records()[SaveData.BEST_FLOOR], 0, "bozuk değer 0 sayılır")
	var records: Dictionary = {SaveData.BEST_SCORE: 900, SaveData.BEST_FLOOR: 42, SaveData.BEST_COMBO: 17}
	SaveData.save_records(records)
	assert_eq(SaveData.load_records(), records)
	config.load(TEMP_SAVE)
	assert_eq(config.get_value("other", "keep"), 7, "diğer bölümlere dokunulmaz")


func test_game_state_saves_records_at_game_over() -> void:
	SaveData.save_records({SaveData.BEST_SCORE: 1, SaveData.BEST_FLOOR: 999, SaveData.BEST_COMBO: 0})
	var state: Node = _new_state()
	assert_eq(state.high_score, 1, "en iyi skor kayıttan gelir")
	var step: int = Tuning.COMBO_MIN_FLOORS
	for i: int in range(1, Tuning.COMBO_MIN_JUMPS + 1):
		state.register_landing(step * i)
	state.end_game()
	var combo_floors: int = step * Tuning.COMBO_MIN_JUMPS
	assert_eq(state.run_best_combo, combo_floors, "oyun sonunda biten kombo sayılır")
	assert_eq(state.new_records, [SaveData.BEST_SCORE, SaveData.BEST_COMBO] as Array[String])
	var saved: Dictionary = SaveData.load_records()
	assert_eq(saved[SaveData.BEST_SCORE], state.score)
	assert_eq(saved[SaveData.BEST_FLOOR], 999, "kırılmayan rekor korunur")
	assert_eq(saved[SaveData.BEST_COMBO], combo_floors)


func test_short_combo_is_not_a_record() -> void:
	var state: Node = _new_state()
	state.register_landing(Tuning.COMBO_MIN_FLOORS)
	state.end_game()
	if Tuning.COMBO_MIN_JUMPS <= 1:
		pass_test("tek zıplayışlık kombo zaten puan kazandırıyor")
		return
	assert_eq(state.run_best_combo, 0, "puan kazandırmayan kombo rekor sayılmaz")
	assert_false(state.new_records.has(SaveData.BEST_COMBO))


func test_reset_clears_run_values() -> void:
	var state: Node = _new_state()
	state.register_landing(3)
	state.end_game()
	assert_false(state.new_records.is_empty())
	state.reset()
	assert_true(state.new_records.is_empty())
	assert_eq(state.run_best_combo, 0)


func test_abandon_run_saves_records_without_game_over_signal() -> void:
	var state: Node = _new_state()
	var fired: Array = []
	var listener: Callable = func(_score: int, _floor: int) -> void: fired.append(true)
	Events.game_over.connect(listener)
	state.register_landing(5)
	state.abandon_run()
	Events.game_over.disconnect(listener)
	assert_true(fired.is_empty(), "game_over yayınlanmaz")
	assert_true(state.is_game_over)
	assert_eq(SaveData.load_records()[SaveData.BEST_FLOOR], 5, "bırakılan oyunun rekoru yine kaydedilir")


func test_reset_records_clears_saved_and_lowers_high_score() -> void:
	SaveData.save_records({SaveData.BEST_SCORE: 900, SaveData.BEST_FLOOR: 42, SaveData.BEST_COMBO: 17})
	var state: Node = _new_state()
	assert_eq(state.high_score, 900)
	state.register_landing(2)
	state.reset_records()
	assert_eq(SaveData.load_records(), SaveData.empty(), "kayıt sıfırlanır")
	assert_eq(state.records, SaveData.empty())
	assert_eq(state.high_score, state.score, "en iyi skor oyundaki skora iner")


func _new_state() -> Node:
	var state: Node = GameStateScript.new()
	state.set_physics_process(false)
	add_child_autofree(state)
	return state


func _remove_temp() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
