extends GutTest
## ComboCounter testleri. Beklentiler Tuning'den türetilir.

const EPSILON: float = 0.001

var combo: ComboCounter


func before_each() -> void:
	combo = ComboCounter.new()
	watch_signals(combo)


func _big() -> int:
	return Tuning.COMBO_MIN_FLOORS


func test_bonus_is_square_of_floors() -> void:
	assert_eq(ComboCounter.bonus_for(Tuning.COMBO_MIN_JUMPS, 10), 100)
	assert_eq(ComboCounter.bonus_for(Tuning.COMBO_MIN_JUMPS + 3, 7), 49)


func test_bonus_needs_min_jumps() -> void:
	assert_eq(ComboCounter.bonus_for(Tuning.COMBO_MIN_JUMPS - 1, 50), 0)


func test_small_landing_does_not_start_combo() -> void:
	combo.register_landing(_big() - 1)
	assert_false(combo.is_active())
	assert_signal_not_emitted(combo, "changed")
	assert_signal_not_emitted(combo, "ended")


func test_big_landing_starts_combo_and_refreshes_timer() -> void:
	combo.register_landing(_big())
	assert_true(combo.is_active())
	assert_eq(combo.jumps, 1)
	assert_eq(combo.floors, _big())
	assert_almost_eq(combo.time_left, Tuning.COMBO_TIMEOUT, EPSILON)
	assert_signal_emitted_with_parameters(combo, "changed", [1, _big()])


func test_big_landings_accumulate() -> void:
	combo.register_landing(_big())
	combo.advance(Tuning.COMBO_TIMEOUT * 0.5)
	combo.register_landing(_big() + 3)
	assert_eq(combo.jumps, 2)
	assert_eq(combo.floors, _big() * 2 + 3)
	assert_almost_eq(combo.time_left, Tuning.COMBO_TIMEOUT, EPSILON, "süre yenilenmeli")


func test_small_landing_ends_combo_with_bonus() -> void:
	combo.register_landing(_big())
	combo.register_landing(_big() + 1)
	var total: int = _big() * 2 + 1
	combo.register_landing(1)
	assert_false(combo.is_active())
	assert_signal_emitted_with_parameters(combo, "ended", [2, total, total * total])


func test_falling_down_ends_combo() -> void:
	combo.register_landing(_big())
	combo.register_landing(-3)
	assert_false(combo.is_active())
	assert_signal_emitted(combo, "ended")


func test_single_jump_combo_gives_no_bonus() -> void:
	combo.register_landing(_big() + 5)
	combo.register_landing(0)
	assert_signal_emitted_with_parameters(combo, "ended", [1, _big() + 5, 0])


func test_timeout_ends_combo() -> void:
	combo.register_landing(_big())
	combo.register_landing(_big())
	combo.advance(Tuning.COMBO_TIMEOUT - 0.1)
	assert_true(combo.is_active(), "süre dolmadan bitmemeli")
	combo.advance(0.2)
	assert_false(combo.is_active())
	var total: int = _big() * 2
	assert_signal_emitted_with_parameters(combo, "ended", [2, total, total * total])


func test_clear_ends_without_signal() -> void:
	combo.register_landing(_big())
	combo.register_landing(_big())
	combo.clear()
	assert_false(combo.is_active())
	assert_signal_not_emitted(combo, "ended")


func test_time_ratio() -> void:
	assert_eq(combo.time_ratio(), 0.0)
	combo.register_landing(_big())
	assert_almost_eq(combo.time_ratio(), 1.0, EPSILON)
	combo.advance(Tuning.COMBO_TIMEOUT * 0.25)
	assert_almost_eq(combo.time_ratio(), 0.75, EPSILON)
