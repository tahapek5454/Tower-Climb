class_name Upgrades
extends RefCounted
## Satın alınmış yükseltmelerin şu anki etkin değerleri (Shop autoload'undan seviyeyi okur, UpgradeRules'a verir).
## Saf kural sınıfları autoload'a erişmez: bu değerleri main / PlatformSpawner / GameState alıp parametre geçer.
## SHOP_ENABLED kapalıysa Shop seviye 0 döner → taban değerler.


static func level(id: StringName) -> int:
	return Shop.upgrade_level(id)


static func jetpack_time() -> float:
	return UpgradeRules.jetpack_time(level(ShopCatalog.UP_JETPACK))


static func hourglass_duration() -> float:
	return UpgradeRules.hourglass_duration(level(ShopCatalog.UP_HOURGLASS))


static func magnet_duration() -> float:
	return UpgradeRules.magnet_duration(level(ShopCatalog.UP_MAGNET))


static func heart_max() -> int:
	return UpgradeRules.heart_max(level(ShopCatalog.UP_HEARTS))


static func luck_level() -> int:
	return level(ShopCatalog.UP_LUCK)
