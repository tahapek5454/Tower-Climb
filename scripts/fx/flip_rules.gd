class_name FlipRules
extends RefCounted
## Takla kuralları (görsel). Saf mantık, test edilebilir.

## Takla çeşitleri: öne takla (ekran düzleminde, gidilen yöne), ters takla (aynı eksende geriye),
## silindirik dönüş (gövde dik kalır, model dikey ekseninde döner).
const FRONT: StringName = &"front"
const BACK: StringName = &"back"
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


## Takla çeşidini ağırlıklara göre seçer. roll: 0..1 rastgele sayı; from_wall: duvar sekmesi mi.
## FLIP_BACK_ONLY_FROM_WALL açıkken platform zıplamasında ters takla payı öne taklaya geçer
## (silindirik dönüşün olasılığı değişmez).
static func pick_style(roll: float, from_wall: bool = false) -> StringName:
	var style: StringName = _weighted_style(roll)
	if style == BACK and Tuning.FLIP_BACK_ONLY_FROM_WALL and not from_wall:
		return FRONT
	return style


static func _weighted_style(roll: float) -> StringName:
	var front: float = maxf(Tuning.FLIP_STYLE_WEIGHT_FRONT, 0.0)
	var back: float = maxf(Tuning.FLIP_STYLE_WEIGHT_BACK, 0.0)
	var twist: float = maxf(Tuning.FLIP_STYLE_WEIGHT_TWIST, 0.0)
	var total: float = front + back + twist
	if total <= 0.0:
		return FRONT
	var r: float = clampf(roll, 0.0, 1.0) * total
	if r < front:
		return FRONT
	if r < front + back:
		return BACK
	return TWIST


## Ekran düzlemindeki takla dönüşünün yönü (Spin.rotation): ters takla hareketin tersine döner.
static func spin_direction(style: StringName, direction: float) -> float:
	return -direction if style == BACK else direction


## Silindirik dönüşün yönü (modelin dikey ekseni, Pivot.rotation.y): yüz önce kameraya döner,
## sonra sırt görünür. Sağa giderken model -Y yönünde (kameraya doğru) döner.
static func twist_direction(direction: float) -> float:
	return -direction
