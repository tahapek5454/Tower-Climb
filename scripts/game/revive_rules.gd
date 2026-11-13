class_name ReviveRules
extends RefCounted
## "Elmasla devam" kartının saf kuralları: açık mı, bu turdaki sıradaki fiyat, kart çıkar mı, kalan süre.
## Fiyatlar Tuning.REVIVE_PRICES'ta (sırayla artar; dizinin uzunluğu = turdaki hak sayısı).

## Özellik açık mı? Mağaza kapalıyken de kart çıkmaz.
static func is_enabled() -> bool:
	return Tuning.REVIVE_ENABLED and Tuning.SHOP_ENABLED


## Bir turdaki en fazla devam hakkı.
static func max_revives() -> int:
	return Tuning.REVIVE_PRICES.size()


## Bu turda `used` kez devam edildiyse sıradaki devamın fiyatı; hak kalmadıysa -1.
static func price(used: int) -> int:
	if used < 0 or used >= max_revives():
		return -1
	return Tuning.REVIVE_PRICES[used]


## Kart gösterilir mi: hak kalmış ve elmas fiyata yetiyor olmalı (özelliğin açık olması ayrıca is_enabled).
static func can_offer(used: int, diamonds: int) -> bool:
	var cost: int = price(used)
	return cost >= 0 and diamonds >= cost


## Sayımın kalan oranı (1 = dolu, 0 = bitti). elapsed: giriş kilidinden sonra geçen süre.
static func time_left_ratio(elapsed: float, duration: float = Tuning.REVIVE_OFFER_TIME) -> float:
	if duration <= 0.0:
		return 0.0
	return clampf(1.0 - elapsed / duration, 0.0, 1.0)


## Süre azaldı mı (halka kızarır, kalp hızlanır)?
static func is_urgent(ratio: float) -> bool:
	return ratio < Tuning.REVIVE_URGENT_RATIO
