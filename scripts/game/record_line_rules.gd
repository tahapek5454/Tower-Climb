class_name RecordLineRules
extends RefCounted
## Rekor çizgisinin kuralları (saf mantık): ne zaman gösterilir, ne zaman geçilmiş sayılır, nerede durur.


## Kayıtlı rekor çizgi koymaya değer mi?
static func should_show(best_floor: int) -> bool:
	return Tuning.RECORD_LINE_ENABLED and best_floor >= Tuning.RECORD_LINE_MIN_FLOOR


## Çizgi geçildi mi: ulaşılan kat rekoru aştıysa (eşitlik geçmek sayılmaz).
static func is_crossed(best_floor: int, current_floor: int) -> bool:
	return current_floor > best_floor


## Çizginin dünya y'si: rekor katın platform yüzeyi.
static func line_y(best_floor: int) -> float:
	return PlatformRules.floor_y(best_floor)
