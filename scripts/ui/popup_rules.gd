class_name PopupRules
extends RefCounted
## Kombo/bonus yazılarının metni ve boyutu; skor sayacının adımı. Saf mantık, test edilebilir.


static func shows_combo(jumps: int) -> bool:
	return jumps >= Tuning.COMBO_POPUP_MIN_JUMPS


static func combo_text(jumps: int) -> String:
	return "COMBO x%d" % jumps


static func combo_font_size(jumps: int) -> int:
	var t: float = clampf(inverse_lerp(float(Tuning.COMBO_POPUP_MIN_JUMPS),
			float(Tuning.COMBO_POPUP_FONT_FULL_JUMPS), float(jumps)), 0.0, 1.0)
	return roundi(lerpf(Tuning.COMBO_POPUP_FONT_MIN, Tuning.COMBO_POPUP_FONT_MAX, t))


## Minimal: sadece kazanılan puan (kat sayısı HUD'daki kombo kutusunda zaten görünüyor).
static func bonus_text(bonus: int) -> String:
	return "+%d" % bonus


static func bonus_font_size(floors: int) -> int:
	var t: float = clampf(float(floors) / Tuning.BONUS_POPUP_FONT_FULL_FLOORS, 0.0, 1.0)
	return roundi(lerpf(Tuning.BONUS_POPUP_FONT_MIN, Tuning.BONUS_POPUP_FONT_MAX, t))


## Gösterilen skoru hedefe doğru yumuşakça ilerletir; yeterince yaklaşınca tam hedefe oturur.
static func count_toward(shown: float, target: int, delta: float) -> float:
	var next: float = lerpf(shown, float(target), 1.0 - exp(-Tuning.SCORE_COUNT_RATE * delta))
	if absf(target - next) < 0.5:
		return float(target)
	return next
