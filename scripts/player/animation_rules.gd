class_name AnimationRules
extends RefCounted
## Karakterin hangi animasyonu oynayacağına karar veren saf kurallar (görsel; fiziğe dokunmaz).

const IDLE: StringName = &"idle"
const RUN: StringName = &"run"
const JUMP: StringName = &"jump"
const FALL: StringName = &"fall"
const LAND: StringName = &"land"
const TUCK: StringName = &"tuck"
const FLAP: StringName = &"flap"


## on_floor: yerde mi; velocity: px/s (yukarı = -y); flipping: takla sürüyor mu;
## landing: iniş animasyonunun süresi dolmadı mı; flapping: kanat çırpma süresi dolmadı mı.
static func pick(on_floor: bool, velocity: Vector2, flipping: bool, landing: bool,
		flapping: bool) -> StringName:
	if not on_floor:
		if flipping:
			return TUCK
		if velocity.y > Tuning.MODEL_FALL_ANIM_MIN_SPEED:
			return FALL
		return FLAP if flapping else JUMP
	var speed: float = absf(velocity.x)
	if landing and speed < Tuning.MODEL_LAND_ANIM_MAX_RUN_SPEED:
		return LAND
	return RUN if speed > Tuning.RUN_STATE_MIN_SPEED else IDLE


## Koşu animasyonunun oynatma hızı: yavaş yürüyüşte ağır, tam hızda çok hızlı adımlar.
static func run_speed_scale(run_speed: float) -> float:
	var t: float = clampf(absf(run_speed) / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
	return lerpf(Tuning.MODEL_RUN_ANIM_SPEED_MIN, Tuning.MODEL_RUN_ANIM_SPEED_MAX, t)


## Bu animasyona geçerken kullanılacak harmanlama süresi (ani olaylar hızlı girer).
static func blend_time(animation: StringName) -> float:
	if animation == TUCK or animation == LAND or animation == JUMP or animation == FLAP:
		return Tuning.MODEL_ANIM_BLEND_TIME_FAST
	return Tuning.MODEL_ANIM_BLEND_TIME
