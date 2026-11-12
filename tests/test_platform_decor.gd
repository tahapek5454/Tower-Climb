extends GutTest
## PlatformDecor.pick testleri (saf süs seçimi).

const SAMPLES: int = 400


func test_decor_comes_from_theme_list_and_skips_redundant() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for theme in PlatformDecor.THEME_DECOR.size():
		var allowed: Array = PlatformDecor.THEME_DECOR[theme]
		for style: StringName in [&"rock", &"snowdrift", &"ice", &"crystal"]:
			for i in 40:
				var kinds: Array[StringName] = PlatformDecor.pick(theme, style, rng)
				assert_lte(kinds.size(), 2)
				for kind: StringName in kinds:
					assert_true(allowed.has(kind), "tema %d dışı süs: %s" % [theme, kind])
					assert_ne(PlatformDecor.REDUNDANT.get(style, &""), kind, "%s stiline gereksiz %s" % [style, kind])
				if kinds.size() == 2:
					assert_ne(kinds[0], kinds[1], "aynı süs iki kez")


func test_decor_chance_roughly_matches_tuning() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var decorated: int = 0
	for i in SAMPLES:
		if not PlatformDecor.pick(0, &"rock", rng).is_empty():
			decorated += 1
	var ratio: float = float(decorated) / SAMPLES
	assert_almost_eq(ratio, Tuning.PLATFORM_DECOR_CHANCE, 0.08)


func test_every_theme_has_decor() -> void:
	assert_eq(PlatformDecor.THEME_DECOR.size(), WorldPalette.theme_count())
