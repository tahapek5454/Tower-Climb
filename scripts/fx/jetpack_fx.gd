class_name JetpackFx
extends Node2D
## Roket uçuşunun 2D efektleri: memeden çıkan alev (gövdeye bağlı kısa jet), dünyada kalan ateş/duman izi,
## sıcak ışık hâlesi ve uçuş bitince düşüp kaybolan boş roket. Oyuncunun olaylarını kendisi dinler.
## PlayerVisual'ın çocuğudur (gövdeden önce eklenir → karakterin arkasında çizilir); PlayerVisual her
## karede `facing` ve `body_offset_x` verir.

## Alevin çıktığı yer: ayaklara göre (x: sırt tarafına, yüz yönünün tersine).
const NOZZLE_OFFSET := Vector2(15.0, -24.0)
const SMOKE_COLOR := Color(0.86, 0.88, 0.95)
## Gövdeye bağlı jet: parçacık sayısı, ömrü (s), hızı (px/s).
const JET_AMOUNT: int = 26
const JET_LIFETIME: float = 0.16
const JET_SPEED: float = 300.0
## Dünyada kalan iz: ateş kıvılcımları ve duman.
const TRAIL_AMOUNT: int = 48
const TRAIL_LIFETIME: float = 0.45
const SMOKE_AMOUNT: int = 30
const SMOKE_LIFETIME: float = 0.7
## Işık hâlesi çapı (px) ve saydamlığı.
const GLOW_SIZE: float = 130.0
const GLOW_ALPHA: float = 0.42
## İtiş tükenince (platforma taşınırken) alevin gücü.
const LANDING_POWER: float = 0.45
## Boş roket: düşme süresi (s), ilk hızı, dönüşü (rad/s), yerçekimi.
const SPENT_TIME: float = 0.75
const SPENT_VELOCITY := Vector2(150.0, -230.0)
const SPENT_SPIN: float = 7.0
const SPENT_GRAVITY: float = 1500.0

var player: Player
## PlayerVisual günceller: yüz yönü (±1) ve gövdenin duvar payı kayması (px).
var facing: float = 1.0
var body_offset_x: float = 0.0

var _jet: CPUParticles2D
var _trail: CPUParticles2D
var _smoke: CPUParticles2D
var _glow: Sprite2D
var _power: float = 0.0


func _ready() -> void:
	var dot: Texture2D = SoftTextures.dot()
	_glow = Sprite2D.new()
	_glow.texture = dot
	_glow.material = SoftTextures.additive()
	_glow.scale = Vector2.ONE * GLOW_SIZE / SoftTextures.DOT_SIZE
	_glow.modulate = Color(JetpackArt.FLAME_OUTER, 0.0)
	add_child(_glow)
	_smoke = _make_smoke(dot)
	_trail = _make_fire(dot, TRAIL_AMOUNT, TRAIL_LIFETIME, 120.0, false)
	_jet = _make_fire(dot, JET_AMOUNT, JET_LIFETIME, JET_SPEED, true)
	if player != null:
		player.event.connect(_on_player_event)


func _process(delta: float) -> void:
	var nozzle := Vector2(-facing * NOZZLE_OFFSET.x + body_offset_x, NOZZLE_OFFSET.y)
	for node: Node2D in [_jet, _trail, _smoke, _glow]:
		node.position = nozzle
	var target: float = 0.0
	if player != null and player.is_flying():
		target = LANDING_POWER if player.is_jetpack_landing() else 1.0
	_power = move_toward(_power, target, delta * 6.0)
	# Alev titreşimi: iki sinüsle hafif nabız.
	var time: float = Time.get_ticks_msec() * 0.001
	var flicker: float = 0.85 + 0.15 * sin(time * 37.0) * sin(time * 23.0)
	_glow.modulate.a = GLOW_ALPHA * _power * flicker
	_jet.scale = Vector2(1.0, lerpf(0.5, 1.0, _power) * flicker)


func _set_emitting(emitting: bool) -> void:
	for emitter: CPUParticles2D in [_jet, _trail, _smoke]:
		emitter.emitting = emitting


func _on_player_event(event_name: StringName, _data: Dictionary) -> void:
	match event_name:
		&"jetpack_started":
			_set_emitting(true)
		&"jetpack_ended":
			_set_emitting(false)
			_drop_spent_pack()


## Boş roket sırttan kopar: arkaya doğru fırlar, dönerek düşer ve solar.
func _drop_spent_pack() -> void:
	var pack := Node2D.new()
	pack.top_level = true
	pack.global_position = global_position + Vector2(-facing * NOZZLE_OFFSET.x, NOZZLE_OFFSET.y - 14.0)
	pack.draw.connect(func() -> void: JetpackArt.draw(pack))
	add_child(pack)
	var start: Vector2 = pack.global_position
	var velocity := Vector2(-facing * SPENT_VELOCITY.x, SPENT_VELOCITY.y)
	var spin: float = -facing * SPENT_SPIN
	var move := func(t: float) -> void:
		pack.global_position = start + velocity * t + Vector2(0.0, 0.5 * SPENT_GRAVITY * t * t)
		pack.rotation = spin * t
	var tween := pack.create_tween().set_parallel()
	tween.tween_method(move, 0.0, SPENT_TIME, SPENT_TIME)
	tween.tween_property(pack, ^"modulate:a", 0.0, SPENT_TIME * 0.5).set_delay(SPENT_TIME * 0.5)
	tween.chain().tween_callback(pack.queue_free)


## Ateş parçacıkları (toplamalı): açık sarıdan turuncuya, sonra saydam. local: gövdeyle birlikte hareket.
func _make_fire(dot: Texture2D, amount: int, lifetime: float, speed: float, local: bool) -> CPUParticles2D:
	var emitter: CPUParticles2D = _make_emitter(dot, amount, lifetime, local)
	emitter.material = SoftTextures.additive()
	emitter.spread = 9.0 if local else 22.0
	emitter.initial_velocity_min = speed * 0.7
	emitter.initial_velocity_max = speed
	emitter.scale_amount_min = 0.22 if local else 0.10
	emitter.scale_amount_max = 0.34 if local else 0.22
	emitter.scale_amount_curve = _shrink_curve()
	var ramp := Gradient.new()
	ramp.set_color(0, Color(JetpackArt.FLAME_INNER, 0.95))
	ramp.add_point(0.35, Color(JetpackArt.FLAME_OUTER, 0.8))
	ramp.set_color(2, Color(0.9, 0.25, 0.12, 0.0))
	emitter.color_ramp = ramp
	return emitter


## Duman: normal karışımla yumuşak açık gri bulutlar; büyüyerek solar, dünyada kalır.
func _make_smoke(dot: Texture2D) -> CPUParticles2D:
	var emitter: CPUParticles2D = _make_emitter(dot, SMOKE_AMOUNT, SMOKE_LIFETIME, false)
	emitter.spread = 30.0
	emitter.initial_velocity_min = 40.0
	emitter.initial_velocity_max = 110.0
	emitter.scale_amount_min = 0.25
	emitter.scale_amount_max = 0.45
	var grow := Curve.new()
	grow.max_value = 2.0
	grow.add_point(Vector2(0.0, 0.6))
	grow.add_point(Vector2(1.0, 2.0))
	emitter.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.set_color(0, Color(SMOKE_COLOR, 0.0))
	ramp.add_point(0.2, Color(SMOKE_COLOR, 0.30))
	ramp.set_color(2, Color(SMOKE_COLOR, 0.0))
	emitter.color_ramp = ramp
	return emitter


func _make_emitter(dot: Texture2D, amount: int, lifetime: float, local: bool) -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.texture = dot
	emitter.amount = amount
	emitter.lifetime = lifetime
	emitter.local_coords = local
	emitter.emitting = false
	emitter.direction = Vector2.DOWN
	emitter.gravity = Vector2.ZERO
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emitter.emission_rect_extents = Vector2(7.0, 1.0)
	add_child(emitter)
	return emitter


func _shrink_curve() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.25))
	return curve
