extends GutTest
## Platform türleri (PlatformTypeRules) ve kayan platformla ulaşılabilirlik. Beklentiler Tuning'den.

const EPSILON: float = 0.001
const SIM_FLOORS: int = 3000
const RNG_SEED: int = 4242


func test_first_floors_and_sections_are_normal() -> void:
	var first_special: int = mini(Tuning.PLATFORM_CRUMBLE_MIN_FLOOR,
			mini(Tuning.PLATFORM_MOVING_MIN_FLOOR, Tuning.PLATFORM_ICE_MIN_FLOOR))
	for floor_number: int in range(1, first_special):
		assert_eq(PlatformTypeRules.pick(floor_number, 0.0), PlatformTypeRules.NORMAL)
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	for section: int in range(1, 6):
		assert_eq(PlatformTypeRules.pick(interval * section, 0.0), PlatformTypeRules.NORMAL,
				"bölüm platformu hep normal")


func test_types_unlock_in_order() -> void:
	assert_eq(PlatformTypeRules.chance(PlatformTypeRules.CRUMBLE, Tuning.PLATFORM_CRUMBLE_MIN_FLOOR - 1), 0.0)
	assert_gt(PlatformTypeRules.chance(PlatformTypeRules.CRUMBLE, Tuning.PLATFORM_CRUMBLE_MIN_FLOOR), 0.0)
	assert_eq(PlatformTypeRules.chance(PlatformTypeRules.MOVING, Tuning.PLATFORM_MOVING_MIN_FLOOR - 1), 0.0)
	assert_gt(PlatformTypeRules.chance(PlatformTypeRules.MOVING, Tuning.PLATFORM_MOVING_MIN_FLOOR), 0.0)
	assert_eq(PlatformTypeRules.chance(PlatformTypeRules.ICE, Tuning.PLATFORM_ICE_MIN_FLOOR - 1), 0.0)
	assert_gt(PlatformTypeRules.chance(PlatformTypeRules.ICE, Tuning.PLATFORM_ICE_MIN_FLOOR), 0.0)
	# İlk açılan katta yalnız çatlayan çıkabilir.
	var floor_number: int = Tuning.PLATFORM_CRUMBLE_MIN_FLOOR
	assert_eq(PlatformTypeRules.pick(floor_number, 0.0), PlatformTypeRules.CRUMBLE)
	assert_eq(PlatformTypeRules.pick(floor_number, 0.99), PlatformTypeRules.NORMAL)


func test_chance_grows_with_sections_and_is_capped() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var early: float = PlatformTypeRules.chance(PlatformTypeRules.CRUMBLE, interval - 1)
	var later: float = PlatformTypeRules.chance(PlatformTypeRules.CRUMBLE, interval + 1)
	assert_almost_eq(later - early, Tuning.PLATFORM_CRUMBLE_CHANCE_PER_SECTION, EPSILON)
	assert_almost_eq(PlatformTypeRules.chance(PlatformTypeRules.CRUMBLE, interval * 50 + 1),
			Tuning.PLATFORM_CRUMBLE_CHANCE_MAX, EPSILON)


func test_total_special_share_respects_cap() -> void:
	# Çok yüksek katta ham olasılıkların toplamı üst sınırı aşsa bile özel tür payı TOTAL_MAX'ı geçmez.
	var floor_number: int = Tuning.SECTION_FLOOR_INTERVAL * 30 + 1
	var steps: int = 1000
	var special: int = 0
	for i: int in steps:
		if PlatformTypeRules.pick(floor_number, (i + 0.5) / steps) != PlatformTypeRules.NORMAL:
			special += 1
	assert_almost_eq(float(special) / steps, Tuning.PLATFORM_TYPE_TOTAL_MAX, 0.002)


func test_no_two_crumbles_in_a_row() -> void:
	var floor_number: int = Tuning.PLATFORM_CRUMBLE_MIN_FLOOR + 1
	for i: int in 200:
		var roll: float = (i + 0.5) / 200.0
		assert_ne(PlatformTypeRules.pick(floor_number, roll, PlatformTypeRules.CRUMBLE), PlatformTypeRules.CRUMBLE)


func test_moving_travel_and_period_ramp() -> void:
	var start: int = Tuning.PLATFORM_MOVING_MIN_FLOOR
	assert_almost_eq(PlatformTypeRules.moving_travel(start), Tuning.PLATFORM_MOVING_TRAVEL_START, EPSILON)
	assert_almost_eq(PlatformTypeRules.moving_period(start), Tuning.PLATFORM_MOVING_PERIOD_START, EPSILON)
	var end: int = start + Tuning.PLATFORM_MOVING_RAMP_FLOORS + 50
	assert_almost_eq(PlatformTypeRules.moving_travel(end), Tuning.PLATFORM_MOVING_TRAVEL_END, EPSILON)
	assert_almost_eq(PlatformTypeRules.moving_period(end), Tuning.PLATFORM_MOVING_PERIOD_END, EPSILON)


func test_moving_offset_stays_within_travel() -> void:
	var travel: float = 80.0
	for i: int in 100:
		var offset: float = PlatformTypeRules.moving_offset(travel, 3.0, 1.2, i * 0.07)
		assert_true(absf(offset) <= travel + EPSILON)


func test_ice_reduces_ground_accel_and_friction() -> void:
	assert_eq(PlatformTypeRules.ground_friction_factor(PlatformTypeRules.NORMAL), 1.0)
	assert_eq(PlatformTypeRules.ground_accel_factor(PlatformTypeRules.MOVING), 1.0)
	assert_lt(PlatformTypeRules.ground_friction_factor(PlatformTypeRules.ICE), 1.0)
	assert_lt(PlatformTypeRules.ground_accel_factor(PlatformTypeRules.ICE), 1.0)
	# Durma mesafesi sürtünmeyle ters orantılı: v² / (2 · sürtünme).
	var normal_stop: float = pow(Tuning.MAX_RUN_SPEED, 2.0) / (2.0 * Tuning.GROUND_FRICTION)
	var ice_stop: float = normal_stop / Tuning.PLATFORM_ICE_FRICTION_FACTOR
	assert_gt(ice_stop, normal_stop)


func test_unsafe_types_are_not_landing_targets() -> void:
	assert_true(PlatformTypeRules.is_safe_landing(PlatformTypeRules.NORMAL))
	assert_true(PlatformTypeRules.is_safe_landing(PlatformTypeRules.ICE))
	assert_false(PlatformTypeRules.is_safe_landing(PlatformTypeRules.CRUMBLE))
	assert_false(PlatformTypeRules.is_safe_landing(PlatformTypeRules.MOVING))
	assert_false(PlatformTypeRules.allows_air_pickup(PlatformTypeRules.MOVING))


## Üretici gibi yüzlerce kat üret: kayan platformun hareket aralığının iki ucu da bir alt katın
## (o da kayıyorsa her iki ucunun) ulaşılabilir aralığında, platform hep duvarların içinde.
func test_generated_tower_stays_reachable_with_moving_platforms() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = RNG_SEED
	var prev_center: float = 0.0
	var prev_width: float = Tuning.TOWER_WIDTH
	var prev_travel: float = 0.0
	var prev_kind: StringName = PlatformTypeRules.NORMAL
	var moving_count: int = 0
	for floor_number: int in range(1, SIM_FLOORS):
		var width: float = PlatformRules.random_width(floor_number, rng)
		var kind: StringName = PlatformTypeRules.pick(floor_number, rng.randf(), prev_kind)
		var travel: float = 0.0
		if kind == PlatformTypeRules.MOVING:
			moving_count += 1
			travel = PlatformTypeRules.safe_travel(PlatformTypeRules.moving_travel(floor_number),
					prev_width, prev_travel, width)
			assert_gt(travel, 0.0, "kat %d kayıyor" % floor_number)
		var center: float = PlatformRules.next_center(floor_number, prev_center, prev_width, width, rng,
				prev_travel, travel)
		assert_true(absf(center) + travel + width * 0.5 <= Tuning.TOWER_WIDTH * 0.5 + EPSILON,
				"kat %d duvarların içinde" % floor_number)
		for a: float in [-prev_travel, prev_travel]:
			for b: float in [-travel, travel]:
				var gap: float = absf((center + b) - (prev_center + a)) - (width + prev_width) * 0.5
				assert_true(gap <= Tuning.PLATFORM_MAX_EDGE_GAP + EPSILON,
						"kat %d ulaşılabilir (boşluk %.1f)" % [floor_number, gap])
		prev_center = center
		prev_width = width
		prev_travel = travel
		prev_kind = kind
	assert_gt(moving_count, 0)
