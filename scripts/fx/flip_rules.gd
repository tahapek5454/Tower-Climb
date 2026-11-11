class_name FlipRules
extends RefCounted
## Takla kuralları (görsel). Saf mantık, test edilebilir.


## Zıplama takla tetikler mi? Büyük zıplama veya kombo sürerken yapılan zıplama.
static func jump_triggers_flip(jump_speed: float, combo_active: bool) -> bool:
	return combo_active or jump_speed >= Tuning.FLIP_VELOCITY_THRESHOLD


## Takla süresi: yukarı hıza göre yükselme süresinin biraz fazlası; en az FLIP_MIN_DURATION.
static func duration_for(up_speed: float) -> float:
	var rise_time: float = maxf(up_speed, 0.0) / Tuning.GRAVITY
	return maxf(rise_time * Tuning.FLIP_AIRTIME_FACTOR, Tuning.FLIP_MIN_DURATION)


## Süreye sığan tur sayısı (en az 1, en çok FLIP_MAX_TURNS).
static func turns_for(duration: float) -> int:
	return clampi(int(duration / Tuning.FLIP_TURN_TIME), 1, Tuning.FLIP_MAX_TURNS)


## Dönüş yönü: hareket yönü (sağa = saat yönü, +1); yatay hız yoksa bakılan yön.
static func direction_for(velocity_x: float, facing: float) -> float:
	if absf(velocity_x) > Tuning.RUN_STATE_MIN_SPEED:
		return signf(velocity_x)
	return signf(facing) if facing != 0.0 else 1.0
