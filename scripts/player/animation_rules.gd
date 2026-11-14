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
## Roketle uçuş: kollar yukarıda (süpermen).
const FLY: StringName = &"fly"
## Silindirik dönüş: dizler kırık, kollar göğüste kapalı (FlipRules.TWIST).
const TWIST: StringName = &"twist"


## on_floor: yerde mi; velocity: px/s (yukarı = -y); flipping: takla sürüyor mu;
## landing: iniş animasyonunun süresi dolmadı mı; flapping: kanat çırpma süresi dolmadı mı;
## flip_pose: bu takla için seçilmiş poz (TUCK ya da STAR); flying: roketle uçuyor mu.
static func pick(on_floor: bool, velocity: Vector2, flipping: bool, landing: bool,
		flapping: bool, flip_pose: StringName = TUCK, flying: bool = false) -> StringName:
	if flying:
		return FLY
	if not on_floor:
		if flipping:
			return flip_pose
		if velocity.y > Tuning.MODEL_FALL_ANIM_MIN_SPEED:
			return FALL
		return FLAP if flapping else JUMP
	var speed: float = absf(velocity.x)
	if landing and speed < Tuning.MODEL_LAND_ANIM_MAX_RUN_SPEED:
		return LAND
	return RUN if speed > Tuning.RUN_STATE_MIN_SPEED else IDLE


## Yeni başlayan takla için poz seçer. roll: 0..1 rastgele sayı; style: FlipRules çeşidi.
## Öne takla topak ya da yıldız (yıldız yalnız platformdan); burgu kendi pozuyla.
static func flip_animation(roll: float, from_wall: bool, style: StringName = FlipRules.FRONT) -> StringName:
	if style == FlipRules.TWIST:
		return TWIST
	if not from_wall and roll < Tuning.MODEL_STAR_FLIP_CHANCE:
		return STAR
	return TUCK


## Bu animasyonda model kameraya dönük mü durmalı? (Yıldız takla önden okunur.)
static func faces_camera(animation: StringName) -> bool:
	return animation == STAR


## Modelin profilden kameraya dönüklüğü (derece). Uçuşta daha çok döner: kalkık kollar yüzü
## kapatmaz, sırttaki roket de görünür.
static func view_angle_degrees(animation: StringName) -> float:
	return Tuning.JETPACK_VIEW_ANGLE_DEGREES if animation == FLY else Tuning.MODEL_VIEW_ANGLE_DEGREES


## Koşu animasyonunun oynatma hızı: yavaş yürüyüşte ağır, tam hızda çok hızlı adımlar.
static func run_speed_scale(run_speed: float) -> float:
	var t: float = clampf(absf(run_speed) / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
	return lerpf(Tuning.MODEL_RUN_ANIM_SPEED_MIN, Tuning.MODEL_RUN_ANIM_SPEED_MAX, t)


## Bu animasyona geçerken kullanılacak harmanlama süresi (ani olaylar hızlı girer).
static func blend_time(animation: StringName) -> float:
	if animation in [TUCK, STAR, TWIST, LAND, JUMP, FLAP, FLY]:
		return Tuning.MODEL_ANIM_BLEND_TIME_FAST
	return Tuning.MODEL_ANIM_BLEND_TIME
