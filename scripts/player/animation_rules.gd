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
const STAR: StringName = &"star"


## on_floor: yerde mi; velocity: px/s (yukarı = -y); flipping: takla sürüyor mu;
## landing: iniş animasyonunun süresi dolmadı mı; flapping: kanat çırpma süresi dolmadı mı;
## flip_animation: bu takla için seçilmiş poz (TUCK ya da STAR).
static func pick(on_floor: bool, velocity: Vector2, flipping: bool, landing: bool,
		flapping: bool, flip_animation: StringName = TUCK) -> StringName:
	if not on_floor:
		if flipping:
			return flip_animation
		if velocity.y > Tuning.MODEL_FALL_ANIM_MIN_SPEED:
			return FALL
		return FLAP if flapping else JUMP
	var speed: float = absf(velocity.x)
	if landing and speed < Tuning.MODEL_LAND_ANIM_MAX_RUN_SPEED:
		return LAND
	return RUN if speed > Tuning.RUN_STATE_MIN_SPEED else IDLE


## Yeni başlayan takla için poz seçer. roll: 0..1 rastgele sayı.
static func flip_animation(roll: float, from_wall: bool) -> StringName:
	if not from_wall and roll < Tuning.MODEL_STAR_FLIP_CHANCE:
		return STAR
	return TUCK


## Bu animasyonda model kameraya dönük mü durmalı? (Yıldız takla önden okunur.)
static func faces_camera(animation: StringName) -> bool:
	return animation == STAR


## Koşu animasyonunun oynatma hızı: yavaş yürüyüşte ağır, tam hızda çok hızlı adımlar.
static func run_speed_scale(run_speed: float) -> float:
	var t: float = clampf(absf(run_speed) / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
	return lerpf(Tuning.MODEL_RUN_ANIM_SPEED_MIN, Tuning.MODEL_RUN_ANIM_SPEED_MAX, t)


## Bu animasyona geçerken kullanılacak harmanlama süresi (ani olaylar hızlı girer).
static func blend_time(animation: StringName) -> float:
	if animation in [TUCK, STAR, LAND, JUMP, FLAP]:
		return Tuning.MODEL_ANIM_BLEND_TIME_FAST
	return Tuning.MODEL_ANIM_BLEND_TIME
