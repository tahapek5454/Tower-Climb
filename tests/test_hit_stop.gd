extends GutTest
## HitStop süre kuralı testleri.


func test_small_combo_gets_min_duration() -> void:
	assert_almost_eq(HitStop.duration_for(0), Tuning.HITSTOP_DURATION_MIN, 0.0001)


func test_big_combo_gets_max_duration() -> void:
	assert_almost_eq(HitStop.duration_for(Tuning.HITSTOP_FULL_FLOORS), Tuning.HITSTOP_DURATION_MAX, 0.0001)
	assert_almost_eq(HitStop.duration_for(Tuning.HITSTOP_FULL_FLOORS * 10), Tuning.HITSTOP_DURATION_MAX, 0.0001)


func test_duration_grows_with_floors() -> void:
	assert_gt(HitStop.duration_for(10), HitStop.duration_for(4))
