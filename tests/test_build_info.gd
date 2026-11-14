extends GutTest
## Sürüm bilgisi ve debug araçlarının yalnız debug yapıda açık olması.


func test_version_comes_from_project_settings() -> void:
	var expected: String = str(ProjectSettings.get_setting(BuildInfo.VERSION_SETTING, ""))
	assert_ne(expected, "", "project.godot'ta sürüm tanımlı olmalı")
	assert_eq(BuildInfo.version(), expected)
	assert_eq(BuildInfo.version_text(), "v" + expected)


func test_version_looks_like_semver() -> void:
	var parts: PackedStringArray = BuildInfo.version().split(".")
	assert_eq(parts.size(), 3, "MAJOR.MINOR.PATCH")
	for part: String in parts:
		assert_true(part.is_valid_int(), "sayı olmalı: %s" % part)


func test_debug_tools_follow_build_type() -> void:
	assert_eq(BuildInfo.debug_tools_enabled(), OS.is_debug_build())
