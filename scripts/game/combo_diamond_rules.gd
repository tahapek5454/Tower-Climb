class_name ComboDiamondRules
extends RefCounted
## Büyük kombonun elmas ödülü (saf mantık).


## Biten kombonun elması: puan kazandırmadıysa (bonus 0) ya da yeterince kat kazandırmadıysa 0; yoksa
## 1 + (kat - eşik) / adım, en çok COMBO_DIAMOND_MAX.
static func diamonds_for(floors: int, bonus: int) -> int:
	if not Tuning.COMBO_DIAMOND_ENABLED or bonus <= 0 or floors < Tuning.COMBO_DIAMOND_MIN_FLOORS:
		return 0
	var extra: int = (floors - Tuning.COMBO_DIAMOND_MIN_FLOORS) / Tuning.COMBO_DIAMOND_STEP_FLOORS
	return mini(1 + extra, Tuning.COMBO_DIAMOND_MAX)
