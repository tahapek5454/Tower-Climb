class_name ModelAnimator
extends RefCounted
## CharacterModel animasyonlarını oyuncunun durumuna göre sürer.
## PlayerVisual olayları (zıplama, iniş) bildirir ve her karede update çağırır.

var _model: CharacterModel
var _land_time_left: float = 0.0
var _flap_time_left: float = 0.0
var _flip_animation: StringName = AnimationRules.TUCK


func _init(model: CharacterModel) -> void:
	_model = model


## strength: zıplama gücü (0 duran zıplama, 1 tam hızda zıplama).
func on_jumped(strength: float) -> void:
	_land_time_left = 0.0
	_flap_time_left = 0.0
	if strength >= Tuning.MODEL_FLAP_MIN_STRENGTH:
		_flap_time_left = _model.animation_length(AnimationRules.FLAP)


## Takla başlarken çağrılır; bu taklanın pozunu (topak / yıldız) rastgele seçer.
func on_flip_started(from_wall: bool) -> void:
	_flip_animation = AnimationRules.flip_animation(randf(), from_wall)


func on_landed(fall_speed: float) -> void:
	_flap_time_left = 0.0
	if fall_speed >= Tuning.LAND_SQUASH_MIN_SPEED:
		_land_time_left = _model.animation_length(AnimationRules.LAND)


func update(delta: float, on_floor: bool, velocity: Vector2, flipping: bool) -> void:
	_land_time_left = maxf(_land_time_left - delta, 0.0)
	_flap_time_left = maxf(_flap_time_left - delta, 0.0)
	var animation: StringName = AnimationRules.pick(on_floor, velocity, flipping,
			_land_time_left > 0.0, _flap_time_left > 0.0, _flip_animation)
	var speed: float = 1.0
	if animation == AnimationRules.RUN:
		speed = AnimationRules.run_speed_scale(velocity.x)
	_model.play(animation, AnimationRules.blend_time(animation))
	_model.set_speed(speed)
	_model.set_front_view(AnimationRules.faces_camera(animation))
