class_name Pickup
extends Area2D
## Toplanabilir nesne (güçlendirme): bir platformun üstünde hafifçe süzülür; oyuncu dokununca
## Events.pickup_collected yayınlar ve büyüyerek kaybolur. Etkiyi dinleyen uygular (main → oyuncu).
## Yeni tür eklemek: buraya bir sabit + _draw_art'a çizim.

const JETPACK: StringName = &"jetpack"
const DIAMOND: StringName = &"diamond"
## Çevresinde dönen küçük parıltıların sayısı, yörünge yarıçapı ve boyutu (px).
const SPARKLE_COUNT: int = 3
const SPARKLE_ORBIT := Vector2(27.0, 30.0)
const SPARKLE_SIZE: float = 4.5
## Süzülürken sağa sola hafif yatma (radyan).
const SWAY_ANGLE: float = 0.10
## Elmas kendi ekseninde yavaşça döner gibi daralıp genişler (tur/s) ve hâlesi daha küçüktür.
const DIAMOND_SPIN_SPEED: float = 0.55
const DIAMOND_GLOW_SCALE: float = 0.75

var kind: StringName = JETPACK
var _art: Node2D
var _glow: Sprite2D
var _time: float = 0.0
var _collected: bool = false


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
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	var phase: float = TAU * _time / Tuning.PICKUP_BOB_TIME
	_art.position.y = sin(phase) * Tuning.PICKUP_BOB_HEIGHT
	_art.rotation = sin(phase * 0.5) * SWAY_ANGLE
	if not _collected:
		_glow.modulate.a = Tuning.PICKUP_GLOW_ALPHA * (0.8 + 0.2 * sin(phase * 2.0))
	_art.queue_redraw()


## Türün hâle ve parıltı rengi (toplama efekti de kullanır).
static func glow_color(pickup_kind: StringName) -> Color:
	match pickup_kind:
		DIAMOND:
			return DiamondArt.GLOW
	return JetpackArt.CAP


static func sparkle_color(pickup_kind: StringName) -> Color:
	match pickup_kind:
		DIAMOND:
			return DiamondArt.LIGHT
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
	_draw_sparkles()


## Nesnenin çevresinde dönen, yanıp sönen küçük parıltılar.
func _draw_sparkles() -> void:
	for i: int in SPARKLE_COUNT:
		var angle: float = _time * 1.4 + TAU * float(i) / SPARKLE_COUNT
		var twinkle: float = 0.5 + 0.5 * sin(_time * 5.0 + i * 2.1)
		var center := Vector2(cos(angle) * SPARKLE_ORBIT.x, sin(angle) * SPARKLE_ORBIT.y)
		PlatformDraw.sparkle(_art, center, SPARKLE_SIZE * (0.5 + 0.5 * twinkle),
				Color(sparkle_color(kind), 0.35 + 0.6 * twinkle))


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body is Player or not GameFlow.is_playing():
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
