class_name PickupFx
extends Node2D
## Toplanabilir efektleri (Events ve oyuncu olaylarını dinler):
## - alınınca nesnenin yerinde, türünün renginde kısa bir parıltı patlaması;
## - kalp kazanılınca oyuncunun başının üstünde belirip yükselen kalp;
## - kalple kurtarılınca başın üstünde beliren, ortadan ikiye kırılıp düşen kalp.
## top_level: efektler dünyada kalır. Yayıcılar havuzdan tekrar kullanılır.

## Kalp efektinin oyuncunun ayaklarına göre konumu (başın biraz üstü).
const HEART_OFFSET := Vector2(0.0, -96.0)
const HEART_RISE: float = 56.0
const HEART_RISE_TIME: float = 0.9
const HEART_FX_SCALE: float = 1.25
## Kırık kalp: bütün görünme süresi, yarımların ayrılma mesafesi, dönüşü (rad) ve düşme süresi.
const BREAK_HOLD_TIME: float = 0.22
const BREAK_SPREAD: float = 26.0
const BREAK_SPIN: float = 0.55
const BREAK_FALL: float = 46.0
const BREAK_TIME: float = 0.6

const POOL_SIZE: int = 3
const AMOUNT: int = 16
const LIFETIME: float = 0.45
const SPEED: float = 220.0
const DAMPING: float = 420.0
const SCALE_MIN: float = 0.08
const SCALE_MAX: float = 0.16

var player: Player
var _pool: Array[CPUParticles2D] = []
var _next: int = 0


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	var dot: Texture2D = SoftTextures.dot()
	for i: int in POOL_SIZE:
		_pool.append(_make_emitter(dot))
	Events.pickup_collected.connect(_on_pickup_collected)
	Events.hearts_changed.connect(_on_hearts_changed)
	if player != null:
		player.event.connect(_on_player_event)


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


func _on_hearts_changed(_hearts: int, change: int) -> void:
	if change > 0 and player != null and GameFlow.is_playing():
		_rising_heart()


func _on_player_event(event_name: StringName, _data: Dictionary) -> void:
	if event_name == &"rescued":
		_breaking_heart(player.global_position + HEART_OFFSET)


## Kazanılan kalp: oyuncunun başının üstünde büyüyerek belirir, yükselir ve solar (roketle uçarken de
## başın üstünde kalsın diye oyuncuyu izler).
func _rising_heart() -> void:
	var heart: Node2D = _drawn(player.global_position + HEART_OFFSET,
			func(canvas: Node2D) -> void: HeartArt.draw(canvas))
	heart.scale = Vector2.ONE * 0.3
	var follow := func(rise: float) -> void:
		if is_instance_valid(player):
			heart.position = player.global_position + HEART_OFFSET - Vector2(0.0, rise)
	var tween := heart.create_tween().set_parallel()
	tween.tween_property(heart, ^"scale", Vector2.ONE * HEART_FX_SCALE, 0.25) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_method(follow, 0.0, HEART_RISE, HEART_RISE_TIME) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(heart, ^"modulate:a", 0.0, HEART_RISE_TIME * 0.4).set_delay(HEART_RISE_TIME * 0.6)
	tween.chain().tween_callback(heart.queue_free)


## Harcanan kalp: bütün olarak belirir, sonra ortadan kırılır; yarımlar iki yana dönerek düşer ve solar.
func _breaking_heart(at: Vector2) -> void:
	burst(at, HeartArt.GLOW)
	var whole: Node2D = _drawn(at, func(canvas: Node2D) -> void: HeartArt.draw(canvas))
	whole.scale = Vector2.ONE * 0.4
	var pop := whole.create_tween()
	pop.tween_property(whole, ^"scale", Vector2.ONE * HEART_FX_SCALE, BREAK_HOLD_TIME * 0.6) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_interval(BREAK_HOLD_TIME * 0.4)
	pop.tween_callback(func() -> void:
		whole.queue_free()
		for side: float in [-1.0, 1.0]:
			_falling_half(at, side))


func _falling_half(at: Vector2, side: float) -> void:
	var half: Node2D = _drawn(at, func(canvas: Node2D) -> void: HeartArt.draw_half(canvas, side))
	half.scale = Vector2.ONE * HEART_FX_SCALE
	var tween := half.create_tween().set_parallel()
	tween.tween_property(half, ^"position", at + Vector2(side * BREAK_SPREAD, BREAK_FALL), BREAK_TIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(half, ^"rotation", side * BREAK_SPIN, BREAK_TIME)
	tween.tween_property(half, ^"modulate:a", 0.0, BREAK_TIME * 0.5).set_delay(BREAK_TIME * 0.5)
	tween.chain().tween_callback(half.queue_free)


## Verilen çizim fonksiyonuyla kendini çizen bir düğüm ekler.
func _drawn(at: Vector2, painter: Callable) -> Node2D:
	var node := Node2D.new()
	node.position = at
	node.draw.connect(painter.bind(node))
	add_child(node)
	return node


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
