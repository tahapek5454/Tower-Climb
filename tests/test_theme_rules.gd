extends GutTest
## ThemeRules ve WorldPalette.colors_at testleri. Beklentiler Tuning'den türetilir.

const EPSILON: float = 0.001


func test_first_section_is_theme_zero() -> void:
	assert_eq(ThemeRules.position(0.0), 0.0)
	assert_eq(ThemeRules.position(float(Tuning.SECTION_FLOOR_INTERVAL) - 0.5), 0.0)


func test_transition_starts_at_section_floor_and_completes() -> void:
	var interval: float = float(Tuning.SECTION_FLOOR_INTERVAL)
	var transition: float = Tuning.THEME_TRANSITION_FLOORS
	assert_almost_eq(ThemeRules.position(interval), 0.0, EPSILON, "bölüm platformunda geçiş başlar")
	var middle: float = ThemeRules.position(interval + transition * 0.5)
	assert_true(middle > 0.0 and middle < 1.0, "geçişin ortasında iki tema arası")
	assert_almost_eq(ThemeRules.position(interval + transition), 1.0, EPSILON)
	assert_almost_eq(ThemeRules.position(interval * 2.0 - 0.5), 1.0, EPSILON)
	assert_almost_eq(ThemeRules.position(interval * 3.0 + transition), 3.0, EPSILON)


func test_position_is_continuous_and_never_decreases() -> void:
	var prev: float = -1.0
	var step: float = 0.05
	var value: float = 0.0
	var end: float = Tuning.SECTION_FLOOR_INTERVAL * 6.0
	while value < end:
		var current: float = ThemeRules.position(value)
		assert_true(current >= prev - EPSILON, "kat %.2f'de tema geri gitti" % value)
		assert_true(current - prev <= 0.1 or prev < 0.0, "kat %.2f'de tema sıçradı" % value)
		prev = current
		value += step


func test_theme_index_wraps_after_last_theme() -> void:
	var count: int = WorldPalette.theme_count()
	assert_eq(ThemeRules.theme_index(0.0, count), 0)
	assert_eq(ThemeRules.theme_index(float(count - 1) + 0.5, count), count - 1)
	assert_eq(ThemeRules.theme_index(float(count), count), 0)
	assert_eq(ThemeRules.theme_index(float(count) + 1.2, count), 1)


func test_floor_value_matches_floor_spacing() -> void:
	assert_almost_eq(ThemeRules.floor_value_at(PlatformRules.floor_y(37)), 37.0, EPSILON)


func test_colors_blend_between_neighbour_themes() -> void:
	var start: Dictionary = WorldPalette.colors_at(0.0)
	var next: Dictionary = WorldPalette.colors_at(1.0)
	var half: Dictionary = WorldPalette.colors_at(0.5)
	for key: StringName in start:
		var expected: Color = (start[key] as Color).lerp(next[key], 0.5)
		assert_almost_eq((half[key] as Color).r, expected.r, EPSILON, "%s yarı geçiş" % key)
		assert_almost_eq((half[key] as Color).b, expected.b, EPSILON, "%s yarı geçiş" % key)


func test_all_themes_have_same_keys() -> void:
	var keys: Array = WorldPalette.colors_at(0.0).keys()
	for i in WorldPalette.theme_count():
		var colors: Dictionary = WorldPalette.colors_at(float(i))
		assert_eq(colors.size(), keys.size(), "tema %d anahtar sayısı" % i)
		for key in keys:
			assert_true(colors.has(key), "tema %d'de %s yok" % [i, key])


func test_world_colors_avoid_pure_black_and_white() -> void:
	# Palet ilkesi: karakter siyah-beyaz; dünya renkleri uç değerlere gitmesin.
	for i in WorldPalette.theme_count():
		var colors: Dictionary = WorldPalette.colors_at(float(i))
		for key: StringName in colors:
			var luminance: float = (colors[key] as Color).get_luminance()
			assert_true(luminance > 0.05 and luminance < 0.92, "tema %d %s çok uç: %.2f" % [i, key, luminance])


func test_platform_style_mixes_primary_and_secondary() -> void:
	var chance: float = Tuning.PLATFORM_SECONDARY_STYLE_CHANCE
	var styles: Array = WorldPalette.PLATFORM_STYLES[0]
	assert_eq(ThemeRules.platform_style(5, chance - 0.01), styles[1], "düşük zar ikinci stil")
	assert_eq(ThemeRules.platform_style(5, chance + 0.01), styles[0], "yüksek zar ana stil")


func test_platform_style_follows_theme() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var after_transition: int = interval + ceili(Tuning.THEME_TRANSITION_FLOORS) + 1
	assert_eq(ThemeRules.platform_style(after_transition, 0.99), WorldPalette.PLATFORM_STYLES[1][0])
	var count: int = WorldPalette.PLATFORM_STYLES.size()
	assert_eq(count, WorldPalette.theme_count(), "her temanın stil listesi var")
	var wrapped: int = interval * count + ceili(Tuning.THEME_TRANSITION_FLOORS) + 1
	assert_eq(ThemeRules.platform_style(wrapped, 0.99), WorldPalette.PLATFORM_STYLES[0][0], "döngü")
