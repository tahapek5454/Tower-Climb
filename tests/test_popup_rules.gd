extends GutTest
## PopupRules testleri. Beklentiler Tuning'den türetilir.


func test_combo_popup_starts_at_min_jumps() -> void:
	assert_false(PopupRules.shows_combo(Tuning.COMBO_POPUP_MIN_JUMPS - 1))
	assert_true(PopupRules.shows_combo(Tuning.COMBO_POPUP_MIN_JUMPS))


func test_texts() -> void:
	assert_eq(PopupRules.combo_text(7), "x7")
	assert_eq(PopupRules.bonus_text(144), "+144")


func test_combo_font_grows_and_caps() -> void:
	assert_eq(PopupRules.combo_font_size(Tuning.COMBO_POPUP_MIN_JUMPS), Tuning.COMBO_POPUP_FONT_MIN)
	assert_eq(PopupRules.combo_font_size(Tuning.COMBO_POPUP_FONT_FULL_JUMPS), Tuning.COMBO_POPUP_FONT_MAX)
	assert_eq(PopupRules.combo_font_size(1000), Tuning.COMBO_POPUP_FONT_MAX)
	assert_gt(PopupRules.combo_font_size(6), PopupRules.combo_font_size(3))


func test_bonus_font_grows_and_caps() -> void:
	assert_eq(PopupRules.bonus_font_size(0), Tuning.BONUS_POPUP_FONT_MIN)
	assert_eq(PopupRules.bonus_font_size(1000), Tuning.BONUS_POPUP_FONT_MAX)


func test_score_counts_up_smoothly_and_lands_exactly() -> void:
	var shown: float = 0.0
	var dt: float = 1.0 / 60.0
	shown = PopupRules.count_toward(shown, 500, dt)
	assert_gt(shown, 0.0, "hemen saymaya başlamalı")
	assert_lt(shown, 500.0, "ama anında atlamamalı")
	for i in 120:
		shown = PopupRules.count_toward(shown, 500, dt)
	assert_eq(shown, 500.0, "2 saniyede tam hedefe oturmalı")
