extends GutTest
## PlatformRules testleri. Beklentiler Tuning'den türetilir; ayarlar değişse de geçerli kalır.

const RNG_SEED: int = 12345
const SIM_FLOORS: int = 3000
const EPSILON: float = 0.001


func test_floor_y_goes_up_by_spacing() -> void:
	assert_eq(PlatformRules.floor_y(0), 0.0)
	assert_eq(PlatformRules.floor_y(1), -Tuning.FLOOR_SPACING)
	assert_eq(PlatformRules.floor_y(10), -10.0 * Tuning.FLOOR_SPACING)


func test_section_floors() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	assert_false(PlatformRules.is_section_floor(0), "zemin bölüm platformu değil")
	assert_false(PlatformRules.is_section_floor(interval - 1))
	assert_true(PlatformRules.is_section_floor(interval))
	assert_true(PlatformRules.is_section_floor(interval * 3))


func test_width_starts_at_max_and_ends_at_min() -> void:
	assert_eq(PlatformRules.width_for_floor(1), minf(Tuning.PLATFORM_WIDTH_MAX, Tuning.TOWER_WIDTH))
	var narrow_end: int = Tuning.PLATFORM_NARROW_FLOORS + 1
	assert_almost_eq(PlatformRules.width_for_floor(narrow_end), Tuning.PLATFORM_WIDTH_MIN, EPSILON)
	assert_almost_eq(PlatformRules.width_for_floor(narrow_end * 5 + 1), Tuning.PLATFORM_WIDTH_MIN, EPSILON)


func test_width_never_grows_except_section_floors() -> void:
	var prev: float = INF
	for f in range(1, SIM_FLOORS):
		if PlatformRules.is_section_floor(f):
			continue
		var width: float = PlatformRules.width_for_floor(f)
		assert_true(width <= prev + EPSILON, "kat %d genişlemiş" % f)
		prev = width


func test_section_floor_is_full_width_and_centered() -> void:
	var f: int = Tuning.SECTION_FLOOR_INTERVAL
	var rng := RandomNumberGenerator.new()
	assert_eq(PlatformRules.width_for_floor(f), Tuning.TOWER_WIDTH)
	assert_eq(PlatformRules.next_center(f, 100.0, 200.0, Tuning.TOWER_WIDTH, rng), 0.0)


func test_reachable_range_never_empty_at_extremes() -> void:
	var width: float = Tuning.PLATFORM_WIDTH_MIN
	var prev_width: float = Tuning.PLATFORM_WIDTH_MIN
	var limit: float = PlatformRules.center_limit(prev_width)
	for prev_center in [-limit, 0.0, limit]:
		var r: Vector2 = PlatformRules.reachable_center_range(prev_center, prev_width, width)
		assert_true(r.x <= r.y, "önceki merkez %f için aralık boş" % prev_center)


func test_generated_tower_is_inside_walls_and_reachable() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = RNG_SEED
	var half_tower: float = Tuning.TOWER_WIDTH * 0.5
	var prev_center: float = 0.0
	var prev_width: float = Tuning.TOWER_WIDTH
	var failures: int = 0
	for f in range(1, SIM_FLOORS + 1):
		var width: float = PlatformRules.width_for_floor(f)
		var center: float = PlatformRules.next_center(f, prev_center, prev_width, width, rng)
		var inside: bool = center - width * 0.5 >= -half_tower - EPSILON \
				and center + width * 0.5 <= half_tower + EPSILON
		var gap: float = absf(center - prev_center) - (width + prev_width) * 0.5
		if not inside or gap > Tuning.PLATFORM_MAX_EDGE_GAP + EPSILON:
			failures += 1
		prev_center = center
		prev_width = width
	assert_eq(failures, 0, "duvar dışına taşan veya ulaşılamayan platform sayısı")
