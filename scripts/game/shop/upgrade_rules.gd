class_name UpgradeRules
extends RefCounted
## Kalıcı yükseltmelerin etkileri (saf): seviye → etkin değer. Taban değerler Tuning'de yerinde kalır
## (JETPACK_FLIGHT_TIME, HOURGLASS_DURATION, MAGNET_DURATION, HEART_MAX, *_SPAWN_CHANCE); seviye başına
## artış Tuning.UPGRADE_*. Seviyeyi çağıran taraf verir (çalışma zamanında Upgrades → Shop.upgrade_level).
## Seviye 0..ShopCatalog.max_level(id) aralığına sıkıştırılır; UPGRADES_ENABLED kapalıysa hep 0 sayılır.


## Etkin seviye: aralığa sıkıştırılmış, özellik kapalıysa 0.
static func effective_level(id: StringName, level: int) -> int:
	if not Tuning.UPGRADES_ENABLED:
		return 0
	return clampi(level, 0, ShopCatalog.max_level(id))


## Roket uçuşunun itiş süresi (s). Kalple kurtarma uçuşu bundan etkilenmez (HEART_RESCUE_FLIGHT_TIME).
static func jetpack_time(level: int) -> float:
	return Tuning.JETPACK_FLIGHT_TIME + Tuning.UPGRADE_JETPACK_STEP * effective_level(ShopCatalog.UP_JETPACK, level)


## Kum saati etkisinin süresi (s).
static func hourglass_duration(level: int) -> float:
	return Tuning.HOURGLASS_DURATION \
			+ Tuning.UPGRADE_HOURGLASS_STEP * effective_level(ShopCatalog.UP_HOURGLASS, level)


## Mıknatıs etkisinin süresi (s).
static func magnet_duration(level: int) -> float:
	return Tuning.MAGNET_DURATION + Tuning.UPGRADE_MAGNET_STEP * effective_level(ShopCatalog.UP_MAGNET, level)


## Bir turda taşınabilecek en fazla kalp.
static func heart_max(level: int) -> int:
	return Tuning.HEART_MAX + Tuning.UPGRADE_HEARTS_STEP * effective_level(ShopCatalog.UP_HEARTS, level)


## "Şans" yükseltmesiyle bir güçlendirmenin çıkma olasılığı (roket, kalp, kum saati, mıknatıs; elmas değil).
## base: Tuning'deki taban olasılık. Sonuç 0..1.
static func spawn_chance(base: float, level: int) -> float:
	var factor: float = 1.0 + Tuning.UPGRADE_LUCK_STEP * effective_level(ShopCatalog.UP_LUCK, level)
	return clampf(base * factor, 0.0, 1.0)
