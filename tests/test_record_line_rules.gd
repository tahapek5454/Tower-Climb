extends GutTest


func test_hidden_below_min_floor() -> void:
	assert_false(RecordLineRules.should_show(Tuning.RECORD_LINE_MIN_FLOOR - 1))
	assert_false(RecordLineRules.should_show(0))


func test_shown_from_min_floor() -> void:
	assert_eq(RecordLineRules.should_show(Tuning.RECORD_LINE_MIN_FLOOR), Tuning.RECORD_LINE_ENABLED)
	assert_eq(RecordLineRules.should_show(Tuning.RECORD_LINE_MIN_FLOOR + 50), Tuning.RECORD_LINE_ENABLED)


func test_crossed_only_above_best() -> void:
	assert_false(RecordLineRules.is_crossed(12, 11))
	assert_false(RecordLineRules.is_crossed(12, 12))
	assert_true(RecordLineRules.is_crossed(12, 13))


func test_line_sits_on_record_floor_surface() -> void:
	assert_eq(RecordLineRules.line_y(12), PlatformRules.floor_y(12))
