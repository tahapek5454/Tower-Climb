class_name PlatformRules
extends RefCounted
## Platform üretim kuralları. Saf mantık: sahneye dokunmaz, test edilebilir.
## Kat 0 zemindir; platformlar kat 1'den başlar.


## Katın üst yüzeyinin dünya y'si (yukarı = -y).
static func floor_y(floor_number: int) -> float:
	return -floor_number * Tuning.FLOOR_SPACING


## Her SECTION_FLOOR_INTERVAL katta bir tam genişlikte bölüm platformu.
static func is_section_floor(floor_number: int) -> bool:
	return floor_number > 0 and floor_number % Tuning.SECTION_FLOOR_INTERVAL == 0


## Yükseldikçe daralan genişlik; kule genişliğini asla aşmaz.
static func width_for_floor(floor_number: int) -> float:
	if is_section_floor(floor_number):
		return Tuning.TOWER_WIDTH
	var t: float = clampf(float(floor_number - 1) / Tuning.PLATFORM_NARROW_FLOORS, 0.0, 1.0)
	var width: float = lerpf(Tuning.PLATFORM_WIDTH_MAX, Tuning.PLATFORM_WIDTH_MIN, t)
	return minf(width, Tuning.TOWER_WIDTH)


## Platform merkezinin duvarlara taşmadan alabileceği en büyük |x|.
static func center_limit(width: float) -> float:
	return maxf((Tuning.TOWER_WIDTH - width) * 0.5, 0.0)


## Önceki platformdan ulaşılabilir merkez aralığı: Vector2(en_az, en_çok).
## Kenarlar arası boşluk PLATFORM_MAX_EDGE_GAP'i geçmez; aralık asla boş değildir.
static func reachable_center_range(prev_center: float, prev_width: float, width: float) -> Vector2:
	var reach: float = (prev_width + width) * 0.5 + Tuning.PLATFORM_MAX_EDGE_GAP
	var limit: float = center_limit(width)
	return Vector2(maxf(prev_center - reach, -limit), minf(prev_center + reach, limit))


## Yeni platformun merkezi: bölüm platformu ortada, diğerleri ulaşılabilir aralıkta rastgele.
static func next_center(floor_number: int, prev_center: float, prev_width: float,
		width: float, rng: RandomNumberGenerator) -> float:
	if is_section_floor(floor_number):
		return 0.0
	var range_x: Vector2 = reachable_center_range(prev_center, prev_width, width)
	return rng.randf_range(range_x.x, range_x.y)
