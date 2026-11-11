extends GutTest
## PlayerAura parlaklık kuralı testleri.


func test_idle_is_faint() -> void:
	assert_eq(PlayerAura.target_alpha(0.0, false), Tuning.GLOW_AURA_ALPHA_IDLE)


func test_fast_is_brighter() -> void:
	assert_eq(PlayerAura.target_alpha(Tuning.TRAIL_MIN_SPEED, false), Tuning.GLOW_AURA_ALPHA_FAST)
	assert_gt(Tuning.GLOW_AURA_ALPHA_FAST, Tuning.GLOW_AURA_ALPHA_IDLE)


func test_combo_is_brightest_even_when_slow() -> void:
	assert_eq(PlayerAura.target_alpha(0.0, true), Tuning.GLOW_AURA_ALPHA_COMBO)
	assert_gt(Tuning.GLOW_AURA_ALPHA_COMBO, Tuning.GLOW_AURA_ALPHA_FAST)
