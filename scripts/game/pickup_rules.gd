class_name PickupRules
extends RefCounted
## Toplanabilirlerin (elmas, kalp, kum saati) çıkma ve yerleşme kuralları; kalp ve kum saati etkileri. Saf mantık: sahneye dokunmaz, test edilebilir.
## Roketin kendi kuralları JetpackRules'ta.


## Bu katta elmas çıkar mı? roll: 0..1 rastgele sayı. Nadirlik Tuning.DIAMOND_SPAWN_CHANCE ile yönetilir.
static func should_spawn_diamond(floor_number: int, roll: float) -> bool:
	if not Tuning.DIAMOND_ENABLED or floor_number < Tuning.DIAMOND_MIN_FLOOR:
		return false
	return roll < Tuning.DIAMOND_SPAWN_CHANCE


## Bu katta kalp çıkabilir mi? (Olasılıktan bağımsız ön koşullar.)
## last_spawn_floor: en son kalp çıkan kat (hiç çıkmadıysa çok küçük bir sayı).
static func can_spawn_heart(floor_number: int, last_spawn_floor: int) -> bool:
	if not Tuning.HEART_ENABLED or floor_number < Tuning.HEART_MIN_FLOOR:
		return false
	return floor_number - last_spawn_floor >= Tuning.HEART_MIN_FLOOR_GAP


## roll: 0..1. Nadirlik Tuning.HEART_SPAWN_CHANCE ile yönetilir; chance: etkin olasılık ("Şans" yükseltmesi).
static func should_spawn_heart(floor_number: int, last_spawn_floor: int, roll: float,
		chance: float = Tuning.HEART_SPAWN_CHANCE) -> bool:
	return can_spawn_heart(floor_number, last_spawn_floor) and roll < chance


## Kat old_floor'dan new_floor'a çıkınca geçilen bölüm sayısı (her SECTION_FLOOR_INTERVAL kat bir bölüm).
static func sections_crossed(old_floor: int, new_floor: int) -> int:
	if new_floor <= old_floor:
		return 0
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	return floori(float(maxi(new_floor, 0)) / interval) - floori(float(maxi(old_floor, 0)) / interval)


## Kalp ekler; max_hearts'ı geçmez (taban HEART_MAX; "Geniş yürek" yükseltmesi UpgradeRules.heart_max).
static func add_hearts(current: int, amount: int, max_hearts: int = Tuning.HEART_MAX) -> int:
	return clampi(current + amount, 0, maxi(max_hearts, 0))


## Bu katta kum saati çıkabilir mi? (Olasılıktan bağımsız ön koşullar.)
static func can_spawn_hourglass(floor_number: int, last_spawn_floor: int) -> bool:
	if not Tuning.HOURGLASS_ENABLED or floor_number < Tuning.HOURGLASS_MIN_FLOOR:
		return false
	return floor_number - last_spawn_floor >= Tuning.HOURGLASS_MIN_FLOOR_GAP


## roll: 0..1. Nadirlik Tuning.HOURGLASS_SPAWN_CHANCE ile yönetilir; chance: etkin olasılık ("Şans").
static func should_spawn_hourglass(floor_number: int, last_spawn_floor: int, roll: float,
		chance: float = Tuning.HOURGLASS_SPAWN_CHANCE) -> bool:
	return can_spawn_hourglass(floor_number, last_spawn_floor) and roll < chance


## Kum saati etkisinde kamera hızı çarpanı. elapsed: etki başlayalı geçen süre (s). Başta RAMP_TIME içinde
## 1'den SCROLL_FACTOR'a iner, sonda RAMP_TIME içinde 1'e döner; etki dışında 1.
static func hourglass_multiplier(elapsed: float, duration: float = Tuning.HOURGLASS_DURATION) -> float:
	if elapsed < 0.0 or elapsed >= duration:
		return 1.0
	var ramp: float = maxf(Tuning.HOURGLASS_RAMP_TIME, 0.001)
	var depth: float = clampf(minf(elapsed, duration - elapsed) / ramp, 0.0, 1.0)
	return lerpf(1.0, Tuning.HOURGLASS_SCROLL_FACTOR, smoothstep(0.0, 1.0, depth))


## Toplanabilir havada mı duracak (yoksa platformun üstünde mi)? roll: 0..1.
static func is_air_spawn(roll: float) -> bool:
	return roll < Tuning.PICKUP_AIR_CHANCE


## Havadaki toplanabilirin platform merkezine göre x'i: kulenin içinde, duvarlardan PICKUP_AIR_WALL_MARGIN
## uzakta, rastgele bir yer. roll: 0..1.
static func air_offset_x(platform_center_x: float, roll: float) -> float:
	var half: float = maxf(Tuning.TOWER_WIDTH * 0.5 - Tuning.PICKUP_AIR_WALL_MARGIN, 0.0)
	return lerpf(-half, half, clampf(roll, 0.0, 1.0)) - platform_center_x
