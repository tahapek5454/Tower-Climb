extends GutTest
## AmbientParticles.kind_weights testleri (saf).

const EPSILON: float = 0.001


func test_single_theme_uses_its_kind_only() -> void:
	for theme in AmbientParticles.THEME_KIND.size():
		var weights: Dictionary = AmbientParticles.kind_weights(float(theme))
		var kind: StringName = AmbientParticles.THEME_KIND[theme]
		assert_almost_eq(weights[kind], 1.0, EPSILON, "tema %d" % theme)


func test_weights_sum_to_one_and_blend() -> void:
	var weights: Dictionary = AmbientParticles.kind_weights(2.5)
	var total: float = 0.0
	for kind: StringName in weights:
		total += weights[kind]
	assert_almost_eq(total, 1.0, EPSILON)
	assert_almost_eq(weights[&"dust"], 0.5, EPSILON, "Alacakaranlık tozu yarı")
	assert_almost_eq(weights[&"snow"], 0.5, EPSILON, "Buz karı yarı")


func test_same_kind_neighbours_stay_full() -> void:
	# Taş kule ve Alacakaranlık ikisi de toz değil (arada Yosunlu var); döngü sonu Gece -> Taş kule.
	var weights: Dictionary = AmbientParticles.kind_weights(4.5)
	assert_almost_eq(weights[&"fireflies"] + weights[&"dust"], 1.0, EPSILON)


func test_every_theme_has_kind() -> void:
	assert_eq(AmbientParticles.THEME_KIND.size(), WorldPalette.theme_count())
