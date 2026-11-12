class_name SfxRules
extends RefCounted
## Ses efekti kuralları (saf): perde ve ses yüksekliği oyun değerlerinden türetilir.

## Kombo seslerinin perdesi majör gamda yükselir (yarım ton adımları).
const MAJOR_SCALE: Array[int] = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24]


## Zıplama perdesi: yavaş zıplama alçak, tam hızda zıplama ince.
static func jump_pitch(jump_speed: float) -> float:
	return lerpf(Tuning.SFX_JUMP_PITCH_MIN, Tuning.SFX_JUMP_PITCH_MAX, _jump_strength(jump_speed))


## Zıplama ses yüksekliği (dB): güçlü zıplama biraz daha yüksek.
static func jump_volume_db(jump_speed: float) -> float:
	return Tuning.SFX_JUMP_DB + lerpf(-4.0, 0.0, _jump_strength(jump_speed))


## Büyük zıplamada (taklalı) "vuuş" sesi çalar mı?
static func is_big_jump(jump_speed: float) -> bool:
	return jump_speed >= Tuning.FLIP_VELOCITY_THRESHOLD


## İniş sesi çalar mı? (Çok yumuşak inişler sessiz.)
static func should_play_land(fall_speed: float) -> bool:
	return fall_speed >= Tuning.SFX_LAND_MIN_SPEED


## İniş ses yüksekliği (dB) ve perdesi: sert iniş daha yüksek ve daha kalın.
static func land_volume_db(fall_speed: float) -> float:
	return Tuning.SFX_LAND_DB + lerpf(-12.0, 0.0, _land_strength(fall_speed))


static func land_pitch(fall_speed: float) -> float:
	return lerpf(1.12, 0.85, _land_strength(fall_speed))


## Duvar sekmesi ses yüksekliği (dB): hızla çarpınca daha yüksek.
static func wall_volume_db(impact_speed: float) -> float:
	var strength: float = clampf(inverse_lerp(Tuning.WALL_BOUNCE_MIN_SPEED, Tuning.MAX_RUN_SPEED, impact_speed),
			0.0, 1.0)
	return Tuning.SFX_WALL_DB + lerpf(-8.0, 0.0, strength)


## Kombo zıplayışının perdesi: ilk kombo zıplayışı (COMBO_MIN_JUMPS'ın bir altı) temel nota,
## sonrakiler majör gamda birer basamak yükselir; gamın sonunda sabit kalır.
static func combo_pitch(jumps: int) -> float:
	var step: int = clampi(jumps - 1, 0, MAJOR_SCALE.size() - 1)
	return pow(2.0, MAJOR_SCALE[step] / 12.0)


## Aynı ses art arda çaldığında makineli tüfek gibi duyulmasın: küçük rastgele perde sapması.
static func jitter_pitch(pitch: float, roll: float) -> float:
	return pitch * (1.0 + (roll * 2.0 - 1.0) * Tuning.SFX_PITCH_JITTER)


static func _jump_strength(jump_speed: float) -> float:
	var max_jump: float = Tuning.JUMP_BASE + Tuning.MAX_RUN_SPEED * Tuning.JUMP_SPEED_BONUS
	return clampf(inverse_lerp(Tuning.JUMP_BASE, max_jump, jump_speed), 0.0, 1.0)


static func _land_strength(fall_speed: float) -> float:
	return clampf(inverse_lerp(Tuning.SFX_LAND_MIN_SPEED, Tuning.MAX_FALL_SPEED, fall_speed), 0.0, 1.0)
