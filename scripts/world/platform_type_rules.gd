class_name PlatformTypeRules
extends RefCounted
## Platform türü kuralları (normal / çatlayan / kayan / buz). Saf mantık: sahneye dokunmaz, test edilebilir.

const NORMAL: StringName = &"normal"
const CRUMBLE: StringName = &"crumble"
const MOVING: StringName = &"moving"
const ICE: StringName = &"ice"


## Bu katın türü. roll: 0..1 rastgele sayı; prev_kind: bir alt katın türü (üst üste iki çatlayan yok).
## Bölüm platformları ve ilk katlar hep normal.
static func pick(floor_number: int, roll: float, prev_kind: StringName = NORMAL) -> StringName:
	if not Tuning.PLATFORM_TYPES_ENABLED or PlatformRules.is_section_floor(floor_number):
		return NORMAL
	var kinds: Array[StringName] = [CRUMBLE, MOVING, ICE]
	var chances: Array[float] = []
	var total: float = 0.0
	for kind: StringName in kinds:
		var c: float = 0.0 if kind == CRUMBLE and prev_kind == CRUMBLE else chance(kind, floor_number)
		chances.append(c)
		total += c
	var scale: float = minf(1.0, Tuning.PLATFORM_TYPE_TOTAL_MAX / total) if total > 0.0 else 0.0
	var cumulative: float = 0.0
	for i: int in kinds.size():
		cumulative += chances[i] * scale
		if roll < cumulative:
			return kinds[i]
	return NORMAL


## Türün bu kattaki ham olasılığı (toplam üst sınırdan önce): MIN_FLOOR'dan önce 0, sonra bölüm başına artar.
static func chance(kind: StringName, floor_number: int) -> float:
	var min_floor: int = 0
	var base: float = 0.0
	var per_section: float = 0.0
	var max_chance: float = 0.0
	match kind:
		CRUMBLE:
			min_floor = Tuning.PLATFORM_CRUMBLE_MIN_FLOOR
			base = Tuning.PLATFORM_CRUMBLE_CHANCE
			per_section = Tuning.PLATFORM_CRUMBLE_CHANCE_PER_SECTION
			max_chance = Tuning.PLATFORM_CRUMBLE_CHANCE_MAX
		MOVING:
			min_floor = Tuning.PLATFORM_MOVING_MIN_FLOOR
			base = Tuning.PLATFORM_MOVING_CHANCE
			per_section = Tuning.PLATFORM_MOVING_CHANCE_PER_SECTION
			max_chance = Tuning.PLATFORM_MOVING_CHANCE_MAX
		ICE:
			min_floor = Tuning.PLATFORM_ICE_MIN_FLOOR
			base = Tuning.PLATFORM_ICE_CHANCE
			per_section = Tuning.PLATFORM_ICE_CHANCE_PER_SECTION
			max_chance = Tuning.PLATFORM_ICE_CHANCE_MAX
		_:
			return 0.0
	if floor_number < min_floor:
		return 0.0
	var section: int = floori(float(floor_number) / Tuning.SECTION_FLOOR_INTERVAL)
	return minf(base + per_section * section, max_chance)


## Katla ilerleme oranı (0..1): kayan platformun genliği ve hızı bununla artar.
static func moving_progress(floor_number: int) -> float:
	var t: float = float(floor_number - Tuning.PLATFORM_MOVING_MIN_FLOOR) / Tuning.PLATFORM_MOVING_RAMP_FLOORS
	return clampf(t, 0.0, 1.0)


## İstenen salınım genliği (px, merkezden bir yana).
static func moving_travel(floor_number: int) -> float:
	return lerpf(Tuning.PLATFORM_MOVING_TRAVEL_START, Tuning.PLATFORM_MOVING_TRAVEL_END,
			moving_progress(floor_number))


## Tam salınım süresi (s).
static func moving_period(floor_number: int) -> float:
	return lerpf(Tuning.PLATFORM_MOVING_PERIOD_START, Tuning.PLATFORM_MOVING_PERIOD_END,
			moving_progress(floor_number))


## Adalet: genliği, platform duvarların içinde kalacak ve hareket aralığının her ucu bir alt kattan
## (o da kayıyorsa onun her ucundan) ulaşılabilir kalacak kadar küçültür. Bu sınırlar içinde
## PlatformRules.reachable_center_range boş olmaz (bkz. testler).
static func safe_travel(desired: float, prev_width: float, prev_travel: float, width: float) -> float:
	var reach: float = (prev_width + width) * 0.5 + Tuning.PLATFORM_MAX_EDGE_GAP
	var limit: float = minf(PlatformRules.center_limit(width), (prev_width + Tuning.PLATFORM_MAX_EDGE_GAP) * 0.5)
	return clampf(minf(desired, minf(limit, reach - prev_travel)), 0.0, desired)


## x konumu: merkez + genlik x sin(faz + 2π t / süre). Yumuşak, uçlarda yavaşlayan salınım.
static func moving_offset(travel: float, period: float, phase: float, elapsed: float) -> float:
	return travel * sin(phase + TAU * elapsed / maxf(period, 0.001))


## Yerdeki ivme çarpanı (buzda azalır).
static func ground_accel_factor(kind: StringName) -> float:
	return Tuning.PLATFORM_ICE_ACCEL_FACTOR if kind == ICE else 1.0


## Yerdeki sürtünme çarpanı (buzda azalır: daha uzun kayar).
static func ground_friction_factor(kind: StringName) -> float:
	return Tuning.PLATFORM_ICE_FRICTION_FACTOR if kind == ICE else 1.0


## Roket / kalp kurtarma uçuşu bu türe oyuncu bırakabilir mi? Çatlayan çöker, kayan kayar → hayır.
static func is_safe_landing(kind: StringName) -> bool:
	return kind == NORMAL or kind == ICE


## Havadaki toplanabilir bu türde platforma bağlanabilir mi? Kayan platform havadakini duvara taşıyabilir.
static func allows_air_pickup(kind: StringName) -> bool:
	return kind != MOVING
