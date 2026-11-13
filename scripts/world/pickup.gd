class_name Pickup
extends Area2D
## Toplanabilir nesne (güçlendirme): bir platformun üstünde hafifçe süzülür; oyuncu dokununca
## Events.pickup_collected yayınlar ve büyüyerek kaybolur. Etkiyi dinleyen uygular (main → oyuncu).
## Yeni tür eklemek: buraya bir sabit + _draw_art'a çizim + glow_color/sparkle_color.

const JETPACK: StringName = &"jetpack"
const DIAMOND: StringName = &"diamond"
const HEART: StringName = &"heart"
const HOURGLASS: StringName = &"hourglass"
const MAGNET: StringName = &"magnet"
## Tüm toplanabilirlerin grubu (mıknatıs elmasları buradan bulur).
const GROUP: StringName = &"pickups"
## Bekleyen kum saatinde kumun üstten alta akma süresi (s; sonra baştan).
const HOURGLASS_SAND_CYCLE: float = 5.0
## Çevresinde dönen küçük parıltıların sayısı, yörünge yarıçapı ve boyutu (px).
const SPARKLE_COUNT: int = 3
const SPARKLE_ORBIT := Vector2(27.0, 30.0)
const SPARKLE_SIZE: float = 4.5
## Süzülürken sağa sola hafif yatma (radyan).
const SWAY_ANGLE: float = 0.10
## Elmas kendi ekseninde yavaşça döner gibi daralıp genişler (tur/s) ve hâlesi daha küçüktür.
const DIAMOND_SPIN_SPEED: float = 0.55
const DIAMOND_GLOW_SCALE: float = 0.75
## Kalp kalp atışı gibi çift vuruşla atar: vuruş aralığı (s) ve büyüme oranı.
const HEARTBEAT_TIME: float = 1.1
const HEARTBEAT_SCALE: float = 0.14
## Bekleyen mıknatısın uçlarındaki çekim yaylarının döngü süresi (s).
const MAGNET_RING_CYCLE: float = 1.2
## Mıknatısla çekilen elmasın arkasındaki parıltı izi: nokta sayısı, kalınlık (px) ve saydamlık.
const TRAIL_POINTS: int = 16
const TRAIL_WIDTH: float = 5.0
const TRAIL_ALPHA: float = 0.9

var kind: StringName = JETPACK
var _art: Node2D
var _glow: Sprite2D
var _time: float = 0.0
var _collected: bool = false
## Mıknatıs çekimi: hedef (oyuncu), hedefteki nokta (oyuncuya göre), çekim başlayalı geçen süre, iz.
var _pull_target: Node2D
var _pull_offset := Vector2.ZERO
var _pull_elapsed: float = 0.0
var _trail: Node2D
var _trail_points := PackedVector2Array()


## add_child'dan önce çağrılır.
func setup(p_kind: StringName) -> void:
	kind = p_kind


func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = Tuning.PICKUP_RADIUS
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	_glow = Sprite2D.new()
	_glow.texture = SoftTextures.dot()
	_glow.material = SoftTextures.additive()
	_glow.modulate = Color(glow_color(kind), Tuning.PICKUP_GLOW_ALPHA)
	var glow_size: float = Tuning.PICKUP_GLOW_SIZE * (DIAMOND_GLOW_SCALE if kind == DIAMOND else 1.0)
	_glow.scale = Vector2.ONE * glow_size / SoftTextures.DOT_SIZE
	add_child(_glow)

	_art = Node2D.new()
	_art.draw.connect(_draw_art)
	add_child(_art)

	# Yan yana nesneler aynı anda sallanmasın.
	_time = randf() * Tuning.PICKUP_BOB_TIME
	add_to_group(GROUP)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	var phase: float = TAU * _time / Tuning.PICKUP_BOB_TIME
	_art.position.y = sin(phase) * Tuning.PICKUP_BOB_HEIGHT
	_art.rotation = sin(phase * 0.5) * SWAY_ANGLE
	if not _collected:
		_glow.modulate.a = Tuning.PICKUP_GLOW_ALPHA * (0.8 + 0.2 * sin(phase * 2.0))
	_art.queue_redraw()


func _physics_process(delta: float) -> void:
	if _pull_target == null:
		return
	if not is_instance_valid(_pull_target):
		_pull_target = null
		return
	if _collected:
		# Toplandıktan sonra iz kuyruğundan kısalarak kaybolur.
		if not _trail_points.is_empty():
			_trail_points.remove_at(0)
		_trail.queue_redraw()
		return
	_pull_elapsed += delta
	var target: Vector2 = _pull_target.global_position + _pull_offset
	global_position = MagnetRules.pull_step(global_position, target, _pull_elapsed, delta)
	_trail_points.append(global_position)
	if _trail_points.size() > TRAIL_POINTS:
		_trail_points.remove_at(0)
	_trail.queue_redraw()
	if MagnetRules.reached(global_position, target):
		collect()


## Mıknatıs: nesneyi target'a (dünya konumu + offset) doğru hızlanarak uçurur; değince toplanır.
func attract(target: Node2D, offset: Vector2 = Vector2.ZERO) -> void:
	if _collected or _pull_target != null:
		return
	_pull_target = target
	_pull_offset = offset
	_trail = Node2D.new()
	_trail.top_level = true
	_trail.material = SoftTextures.additive()
	_trail.draw.connect(_draw_trail)
	add_child(_trail)
	_trail.global_transform = Transform2D.IDENTITY


func is_attracted() -> bool:
	return _pull_target != null


func is_collected() -> bool:
	return _collected


## Türün hâle ve parıltı rengi (toplama efekti de kullanır).
static func glow_color(pickup_kind: StringName) -> Color:
	match pickup_kind:
		DIAMOND:
			return DiamondArt.GLOW
		HEART:
			return HeartArt.GLOW
		HOURGLASS:
			return HourglassArt.GLOW
		MAGNET:
			return MagnetArt.GLOW
	return JetpackArt.CAP


static func sparkle_color(pickup_kind: StringName) -> Color:
	match pickup_kind:
		DIAMOND:
			return DiamondArt.LIGHT
		HEART:
			return HeartArt.SHINE
		HOURGLASS:
			return HourglassArt.SPARKLE
		MAGNET:
			return MagnetArt.SPARKLE
	return JetpackArt.BAND


func _draw_art() -> void:
	match kind:
		JETPACK:
			# Bekleyen roketin memesinde küçük, titreşen pilot alevi.
			JetpackArt.draw(_art, 0.45 + 0.2 * sin(_time * 21.0))
		DIAMOND:
			# Döner gibi: genişlik kosinüsle daralıp açılır (hiç sıfıra inmez).
			var spin: float = absf(cos(TAU * DIAMOND_SPIN_SPEED * _time))
			_art.draw_set_transform(Vector2.ZERO, 0.0, Vector2(0.35 + 0.65 * spin, 1.0))
			DiamondArt.draw(_art)
			_art.draw_set_transform(Vector2.ZERO)
		HEART:
			# Çift vuruş: döngünün başında iki kısa büyüme ("tuk-tuk"), sonra dinlenme.
			var beat: float = fmod(_time, HEARTBEAT_TIME) / HEARTBEAT_TIME
			var pulse: float = maxf(sin(beat * TAU * 4.0), 0.0) if beat < 0.5 else 0.0
			HeartArt.draw(_art, Vector2.ZERO, 1.0 + HEARTBEAT_SCALE * pulse)
		HOURGLASS:
			HourglassArt.draw(_art, 1.0 - fmod(_time / HOURGLASS_SAND_CYCLE, 1.0))
		MAGNET:
			MagnetArt.draw_pull_rings(_art, fmod(_time / MAGNET_RING_CYCLE, 1.0))
			MagnetArt.draw(_art)
	_draw_sparkles()


## Nesnenin çevresinde dönen, yanıp sönen küçük parıltılar.
func _draw_sparkles() -> void:
	for i: int in SPARKLE_COUNT:
		var angle: float = _time * 1.4 + TAU * float(i) / SPARKLE_COUNT
		var twinkle: float = 0.5 + 0.5 * sin(_time * 5.0 + i * 2.1)
		var center := Vector2(cos(angle) * SPARKLE_ORBIT.x, sin(angle) * SPARKLE_ORBIT.y)
		PlatformDraw.sparkle(_art, center, SPARKLE_SIZE * (0.5 + 0.5 * twinkle),
				Color(sparkle_color(kind), 0.35 + 0.6 * twinkle))


## Çekilen elmasın arkasında, başa doğru kalınlaşan ve parlaklaşan ince iz.
func _draw_trail() -> void:
	var count: int = _trail_points.size()
	if count < 2:
		return
	var color: Color = glow_color(kind)
	var colors := PackedColorArray()
	var soft := PackedColorArray()
	for i: int in count:
		var t: float = float(i + 1) / count
		colors.append(Color(color, TRAIL_ALPHA * t * t))
		soft.append(Color(color, TRAIL_ALPHA * 0.35 * t))
	_trail.draw_polyline_colors(_trail_points, soft, TRAIL_WIDTH * 3.0, true)
	_trail.draw_polyline_colors(_trail_points, colors, TRAIL_WIDTH, true)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()


## Toplar: Events.pickup_collected yayınlar, büyüyerek kaybolur. Oyun sürmüyorsa ya da zaten alındıysa bir şey yapmaz.
func collect() -> void:
	if _collected or not GameFlow.is_playing():
		return
	_collected = true
	set_deferred(&"monitoring", false)
	Events.pickup_collected.emit(kind, global_position)
	var tween := create_tween().set_parallel()
	tween.tween_property(_art, ^"scale", Vector2.ONE * 1.7, Tuning.PICKUP_COLLECT_TIME) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_art, ^"modulate:a", 0.0, Tuning.PICKUP_COLLECT_TIME)
	tween.tween_property(_glow, ^"scale", _glow.scale * 2.0, Tuning.PICKUP_COLLECT_TIME)
	tween.tween_property(_glow, ^"modulate:a", 0.0, Tuning.PICKUP_COLLECT_TIME)
	tween.chain().tween_callback(queue_free)
