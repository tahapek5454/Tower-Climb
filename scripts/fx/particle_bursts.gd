class_name ParticleBursts
extends Node2D
## Tek seferlik parçacık patlamaları: iniş tozu ve duvar kıvılcımı.
## top_level: parçacıklar dünyada kalır. Yayıcılar havuzdan tekrar kullanılır.
## Parçacık görüntüsü kodla üretilen yumuşak kenarlı daire (SoftTextures.dot, 64 px).
## Toz normal karışımla (toz gibi), kıvılcım toplamalı karışımla (ışık gibi) çizilir.

const DUST_COLOR := Color(0.85, 0.87, 0.95)
const SPARK_COLOR := Color(1.0, 0.82, 0.45)
const POOL_SIZE: int = 3
## Toz bulutu ölçeği (64 px dokuya oranla; 0,25 ≈ 16 px) ve ömrü boyunca büyümesi.
const DUST_SCALE_MIN: float = 0.175
const DUST_SCALE_MAX: float = 0.35
const DUST_GROWTH: float = 1.6
## Toz yana yayılır, hafifçe yükselir; sürtünmeyle yavaşlar.
const DUST_SPREAD_DEGREES: float = 75.0
const DUST_DAMPING: float = 380.0
const DUST_GRAVITY := Vector2(0.0, -40.0)
const SPARK_SCALE_MIN: float = 0.06
const SPARK_SCALE_MAX: float = 0.125
const SPARK_SPREAD_DEGREES: float = 35.0
const SPARK_GRAVITY := Vector2(0.0, 900.0)
const SPARK_DAMPING: float = 120.0
## Kıvılcımlar duvardan hafif yukarı doğru saçılır.
const SPARK_UP_TILT: float = -0.35

var _dust_pool: Array[CPUParticles2D] = []
var _spark_pool: Array[CPUParticles2D] = []
var _next_dust: int = 0
var _next_spark: int = 0


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	var dot: Texture2D = SoftTextures.dot()
	for i in POOL_SIZE:
		_dust_pool.append(_make_dust_emitter(dot))
		_spark_pool.append(_make_spark_emitter(dot))


## Ayakların iki yanından toz. strength: 0 (hafif) .. 1 (sert iniş).
func land_dust(feet: Vector2, strength: float) -> void:
	var emitter: CPUParticles2D = _dust_pool[_next_dust]
	_next_dust = (_next_dust + 1) % _dust_pool.size()
	emitter.amount = roundi(lerpf(Tuning.LAND_DUST_COUNT_MIN, Tuning.LAND_DUST_COUNT_MAX, strength))
	var speed: float = Tuning.LAND_DUST_SPEED * lerpf(0.5, 1.0, strength)
	emitter.initial_velocity_min = speed * 0.5
	emitter.initial_velocity_max = speed
	emitter.global_position = feet
	emitter.restart()


## Duvara çarpma noktasından, duvarın tersine (normal yönünde) kıvılcım.
func wall_sparks(contact: Vector2, normal_x: float, strength: float) -> void:
	var emitter: CPUParticles2D = _spark_pool[_next_spark]
	_next_spark = (_next_spark + 1) % _spark_pool.size()
	emitter.amount = roundi(lerpf(Tuning.WALL_SPARK_COUNT_MIN, Tuning.WALL_SPARK_COUNT_MAX, strength))
	emitter.direction = Vector2(signf(normal_x), SPARK_UP_TILT).normalized()
	var speed: float = Tuning.WALL_SPARK_SPEED * lerpf(0.6, 1.0, strength)
	emitter.initial_velocity_min = speed * 0.5
	emitter.initial_velocity_max = speed
	emitter.global_position = contact
	emitter.restart()


func dust_emitters() -> Array[CPUParticles2D]:
	return _dust_pool


func spark_emitters() -> Array[CPUParticles2D]:
	return _spark_pool


func _make_dust_emitter(dot: Texture2D) -> CPUParticles2D:
	var emitter: CPUParticles2D = _make_emitter(dot, Tuning.LAND_DUST_LIFETIME)
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emitter.emission_rect_extents = Vector2(Tuning.PLAYER_WIDTH * 0.5, 1.0)
	emitter.direction = Vector2.UP
	emitter.spread = DUST_SPREAD_DEGREES
	emitter.gravity = DUST_GRAVITY
	emitter.damping_min = DUST_DAMPING
	emitter.damping_max = DUST_DAMPING
	emitter.scale_amount_min = DUST_SCALE_MIN
	emitter.scale_amount_max = DUST_SCALE_MAX
	emitter.scale_amount_curve = _grow_curve(DUST_GROWTH)
	emitter.color_ramp = _fade_ramp(DUST_COLOR, Tuning.LAND_DUST_ALPHA)
	return emitter


func _make_spark_emitter(dot: Texture2D) -> CPUParticles2D:
	var emitter: CPUParticles2D = _make_emitter(dot, Tuning.WALL_SPARK_LIFETIME)
	emitter.spread = SPARK_SPREAD_DEGREES
	emitter.gravity = SPARK_GRAVITY
	emitter.damping_min = SPARK_DAMPING
	emitter.damping_max = SPARK_DAMPING
	emitter.scale_amount_min = SPARK_SCALE_MIN
	emitter.scale_amount_max = SPARK_SCALE_MAX
	emitter.color_ramp = _fade_ramp(SPARK_COLOR, Tuning.WALL_SPARK_ALPHA)
	emitter.material = SoftTextures.additive()
	return emitter


func _make_emitter(dot: Texture2D, lifetime: float) -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.texture = dot
	emitter.one_shot = true
	emitter.emitting = false
	emitter.explosiveness = 1.0
	emitter.lifetime = lifetime
	emitter.local_coords = false
	add_child(emitter)
	return emitter


## Renk sabit, saydamlık başlangıç değerinden 0'a iner.
func _fade_ramp(color: Color, start_alpha: float) -> Gradient:
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, start_alpha))
	ramp.set_color(1, Color(color, 0.0))
	return ramp


## Ömür boyunca 1'den `growth` katına büyüme.
func _grow_curve(growth: float) -> Curve:
	var curve := Curve.new()
	curve.max_value = growth
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, growth))
	return curve
