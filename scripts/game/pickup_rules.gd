class_name PickupRules
extends RefCounted
## Toplanabilirlerin (elmas vb.) çıkma ve yerleşme kuralları. Saf mantık: sahneye dokunmaz, test edilebilir.
## Roketin kendi kuralları JetpackRules'ta.


## Bu katta elmas çıkar mı? roll: 0..1 rastgele sayı. Nadirlik Tuning.DIAMOND_SPAWN_CHANCE ile yönetilir.
static func should_spawn_diamond(floor_number: int, roll: float) -> bool:
	if not Tuning.DIAMOND_ENABLED or floor_number < Tuning.DIAMOND_MIN_FLOOR:
		return false
	return roll < Tuning.DIAMOND_SPAWN_CHANCE


## Toplanabilir havada mı duracak (yoksa platformun üstünde mi)? roll: 0..1.
static func is_air_spawn(roll: float) -> bool:
	return roll < Tuning.PICKUP_AIR_CHANCE


## Havadaki toplanabilirin platform merkezine göre x'i: kulenin içinde, duvarlardan PICKUP_AIR_WALL_MARGIN
## uzakta, rastgele bir yer. roll: 0..1.
static func air_offset_x(platform_center_x: float, roll: float) -> float:
	var half: float = maxf(Tuning.TOWER_WIDTH * 0.5 - Tuning.PICKUP_AIR_WALL_MARGIN, 0.0)
	return lerpf(-half, half, clampf(roll, 0.0, 1.0)) - platform_center_x
