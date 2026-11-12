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


## Testler için kata bağlı sabit zar tablosu.
var _rolls: Dictionary = {}


func _roll_of(for_floor: int) -> float:
	if not _rolls.has(for_floor):
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(for_floor * 31 + 4242)
		_rolls[for_floor] = rng.randf()
	return _rolls[for_floor]


func test_platform_style_uses_all_theme_styles_and_rarely_repeats() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	for theme in WorldPalette.PLATFORM_STYLES.size():
		var expected: Dictionary = {}
		for entry: Array in WorldPalette.PLATFORM_STYLES[theme]:
			expected[entry[0]] = true
		var seen: Dictionary = {}
		var repeats: int = 0
		var previous_style: StringName = &""
		var first: int = theme * interval + ceili(Tuning.THEME_TRANSITION_FLOORS) + 1
		for f in range(first, (theme + 1) * interval):
			var style: StringName = ThemeRules.platform_style(f, _roll_of)
			assert_true(expected.has(style), "tema %d dışı stil: %s" % [theme, style])
			seen[style] = true
			if style == previous_style:
				repeats += 1
			previous_style = style
		assert_eq(seen.size(), expected.size(), "tema %d'nin tüm stilleri çıkmalı" % theme)
		assert_lt(repeats, 3, "tema %d'de art arda aynı stil" % theme)


func test_platform_style_follows_theme_and_wraps() -> void:
	var always_first: Callable = func(_f: int) -> float: return 0.0
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var count: int = WorldPalette.PLATFORM_STYLES.size()
	assert_eq(count, WorldPalette.theme_count(), "her temanın stil listesi var")
	var after_transition: int = interval + ceili(Tuning.THEME_TRANSITION_FLOORS) + 2
	var styles: Array = WorldPalette.PLATFORM_STYLES[1]
	var style: StringName = ThemeRules.platform_style(after_transition, always_first)
	assert_true(style == styles[0][0] or style == styles[1][0], "tema 1 stili: %s" % style)
	var wrapped: int = interval * count + ceili(Tuning.THEME_TRANSITION_FLOORS) + 2
	var wrapped_style: StringName = ThemeRules.platform_style(wrapped, always_first)
	var first_theme: Array = WorldPalette.PLATFORM_STYLES[0]
	assert_true(wrapped_style == first_theme[0][0] or wrapped_style == first_theme[1][0], "döngü")
