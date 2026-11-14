class_name FlipRules
extends RefCounted
## Takla kuralları (görsel). Saf mantık, test edilebilir.

## Takla çeşitleri: öne takla (ekran düzleminde, gidilen yöne), silindirik dönüş (gövde dik kalır,
## model dikey ekseninde döner).
const FRONT: StringName = &"front"
const TWIST: StringName = &"twist"


## Zıplama takla tetikler mi? Büyük zıplama veya kombo sürerken yapılan zıplama.
static func jump_triggers_flip(jump_speed: float, combo_active: bool) -> bool:
	return combo_active or jump_speed >= Tuning.FLIP_VELOCITY_THRESHOLD


## Takla süresi: yukarı hıza göre yükselme süresinin biraz fazlası; en az FLIP_MIN_DURATION.
static func duration_for(up_speed: float) -> float:
	var rise_time: float = maxf(up_speed, 0.0) / Tuning.GRAVITY
	return maxf(rise_time * Tuning.FLIP_AIRTIME_FACTOR, Tuning.FLIP_MIN_DURATION)


## Süreye sığan tur sayısı (en az 1, en çok FLIP_MAX_TURNS). turn_time: bir turun süresi.
static func turns_for(duration: float, turn_time: float = Tuning.FLIP_TURN_TIME) -> int:
	return clampi(int(duration / turn_time), 1, Tuning.FLIP_MAX_TURNS)


## Dönüş yönü: hareket yönü (sağa = saat yönü, +1); yatay hız yoksa bakılan yön.
static func direction_for(velocity_x: float, facing: float) -> float:
	if absf(velocity_x) > Tuning.RUN_STATE_MIN_SPEED:
		return signf(velocity_x)
	return signf(facing) if facing != 0.0 else 1.0


## Takla çeşidini ağırlıklara göre seçer. roll: 0..1 rastgele sayı.
static func pick_style(roll: float) -> StringName:
	var front: float = maxf(Tuning.FLIP_STYLE_WEIGHT_FRONT, 0.0)
	var twist: float = maxf(Tuning.FLIP_STYLE_WEIGHT_TWIST, 0.0)
	var total: float = front + twist
	if total <= 0.0:
		return FRONT
	return FRONT if clampf(roll, 0.0, 1.0) * total < front else TWIST


## Silindirik dönüşün yönü (modelin dikey ekseni, Pivot.rotation.y): yüz önce kameraya döner,
## sonra sırt görünür. Sağa giderken model -Y yönünde (kameraya doğru) döner.
static func twist_direction(direction: float) -> float:
	return -direction
