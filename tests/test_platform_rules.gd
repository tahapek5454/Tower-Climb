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


func test_base_width_starts_wide_and_trends_to_min() -> void:
	var expected_first: float = minf(
			Tuning.PLATFORM_WIDTH_MAX + Tuning.PLATFORM_SECTION_START_BONUS
			* (1.0 - 1.0 / Tuning.SECTION_FLOOR_INTERVAL), Tuning.TOWER_WIDTH)
	assert_almost_eq(PlatformRules.base_width(1), expected_first, EPSILON)
	# Bölümün son katında bonus neredeyse erimiştir; eğilim MIN'e oturur.
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var far_last: int = interval * 20 - 1
	var expected_far: float = Tuning.PLATFORM_WIDTH_MIN + Tuning.PLATFORM_SECTION_START_BONUS / interval
	assert_almost_eq(PlatformRules.base_width(far_last), expected_far, EPSILON)


func test_base_width_narrows_within_section_and_resets_wider() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	for section in range(0, 5):
		var first: int = section * interval + 1
		var last: int = (section + 1) * interval - 1
		var prev: float = INF
		for f in range(first, last + 1):
			var width: float = PlatformRules.base_width(f)
			assert_true(width <= prev + EPSILON, "kat %d bölüm içinde genişlemiş" % f)
			prev = width
		if section > 0:
			var before: float = PlatformRules.base_width(first - 2)
			assert_true(PlatformRules.base_width(first) > before, "bölüm %d geniş başlamamış" % section)


func test_surprise_chance_grows_with_height() -> void:
	assert_almost_eq(PlatformRules.surprise_narrow_chance(1), Tuning.PLATFORM_SURPRISE_CHANCE_START, EPSILON)
	var end_floor: int = Tuning.PLATFORM_NARROW_FLOORS + 1
	assert_almost_eq(PlatformRules.surprise_narrow_chance(end_floor), Tuning.PLATFORM_SURPRISE_CHANCE_END, EPSILON)
	assert_almost_eq(PlatformRules.surprise_narrow_chance(end_floor * 4), Tuning.PLATFORM_SURPRISE_CHANCE_END, EPSILON)


func test_random_width_stays_in_bounds_and_varies() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = RNG_SEED
	var surprises: int = 0
	var out_of_bounds: int = 0
	for f in range(1, SIM_FLOORS + 1):
		if PlatformRules.is_section_floor(f):
			assert_eq(PlatformRules.random_width(f, rng), Tuning.TOWER_WIDTH)
			continue
		var base: float = PlatformRules.base_width(f)
		var width: float = PlatformRules.random_width(f, rng)
		if width < Tuning.PLATFORM_WIDTH_ABS_MIN - EPSILON or width > Tuning.TOWER_WIDTH + EPSILON:
			out_of_bounds += 1
		var normal_min: float = maxf(base * Tuning.PLATFORM_WIDTH_JITTER_MIN, Tuning.PLATFORM_WIDTH_ABS_MIN)
		if width < normal_min - EPSILON:
			surprises += 1
	assert_eq(out_of_bounds, 0, "sınır dışı genişlik sayısı")
	# Sürpriz dar platformlar gerçekten çıkıyor ama nadir.
	assert_gt(surprises, 0, "hiç sürpriz dar platform çıkmadı")
	assert_lt(float(surprises) / SIM_FLOORS, Tuning.PLATFORM_SURPRISE_CHANCE_END * 1.5, "sürpriz çok sık")


func test_section_floor_is_full_width_and_centered() -> void:
	var f: int = Tuning.SECTION_FLOOR_INTERVAL
	var rng := RandomNumberGenerator.new()
	assert_eq(PlatformRules.base_width(f), Tuning.TOWER_WIDTH)
	assert_eq(PlatformRules.next_center(f, 100.0, 200.0, Tuning.TOWER_WIDTH, rng), 0.0)


func test_reachable_range_never_empty_at_extremes() -> void:
	var width: float = Tuning.PLATFORM_WIDTH_ABS_MIN
	var prev_width: float = Tuning.PLATFORM_WIDTH_ABS_MIN
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
		var width: float = PlatformRules.random_width(f, rng)
		var center: float = PlatformRules.next_center(f, prev_center, prev_width, width, rng)
		var inside: bool = center - width * 0.5 >= -half_tower - EPSILON \
				and center + width * 0.5 <= half_tower + EPSILON
		var gap: float = absf(center - prev_center) - (width + prev_width) * 0.5
		if not inside or gap > Tuning.PLATFORM_MAX_EDGE_GAP + EPSILON:
			failures += 1
		prev_center = center
		prev_width = width
	assert_eq(failures, 0, "duvar dışına taşan veya ulaşılamayan platform sayısı")
