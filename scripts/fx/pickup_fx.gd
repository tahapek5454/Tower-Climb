class_name PickupFx
extends Node2D
## Toplanabilir alınınca nesnenin yerinde, türünün renginde kısa bir parıltı patlaması (Events dinler).
## top_level: parçacıklar dünyada kalır. Yayıcılar havuzdan tekrar kullanılır.

const POOL_SIZE: int = 3
const AMOUNT: int = 16
const LIFETIME: float = 0.45
const SPEED: float = 220.0
const DAMPING: float = 420.0
const SCALE_MIN: float = 0.08
const SCALE_MAX: float = 0.16

var _pool: Array[CPUParticles2D] = []
var _next: int = 0


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	var dot: Texture2D = SoftTextures.dot()
	for i: int in POOL_SIZE:
		_pool.append(_make_emitter(dot))
	Events.pickup_collected.connect(_on_pickup_collected)


func burst(world_position: Vector2, color: Color) -> void:
	var emitter: CPUParticles2D = _pool[_next]
	_next = (_next + 1) % _pool.size()
	var ramp := Gradient.new()
	ramp.set_color(0, Color(Color.WHITE, 1.0))
	ramp.add_point(0.25, Color(color, 0.9))
	ramp.set_color(2, Color(color, 0.0))
	emitter.color_ramp = ramp
	emitter.global_position = world_position
	emitter.restart()


func _on_pickup_collected(kind: StringName, world_position: Vector2) -> void:
	burst(world_position, Pickup.glow_color(kind))


func _make_emitter(dot: Texture2D) -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.texture = dot
	emitter.material = SoftTextures.additive()
	emitter.one_shot = true
	emitter.emitting = false
	emitter.explosiveness = 1.0
	emitter.amount = AMOUNT
	emitter.lifetime = LIFETIME
	emitter.local_coords = false
	emitter.spread = 180.0
	emitter.gravity = Vector2.ZERO
	emitter.initial_velocity_min = SPEED * 0.4
	emitter.initial_velocity_max = SPEED
	emitter.damping_min = DAMPING
	emitter.damping_max = DAMPING
	emitter.scale_amount_min = SCALE_MIN
	emitter.scale_amount_max = SCALE_MAX
	add_child(emitter)
	return emitter
