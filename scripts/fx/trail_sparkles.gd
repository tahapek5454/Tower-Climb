class_name TrailSparkles
extends CPUParticles2D
## Işıltı izi: oyuncu hızlı hareket ederken izin üstünde ara ara beliren küçük, yumuşak ışık noktaları.
## Parçacıklar dünyada kalır (local_coords kapalı) → hareket yolu boyunca geride kalırlar.

var player: Player


func _ready() -> void:
	top_level = true
	visible = false
	global_transform = Transform2D.IDENTITY
	texture = SoftTextures.dot()
	material = SoftTextures.additive()
	local_coords = false
	emitting = false
	amount = Tuning.TRAIL_SPARKLE_COUNT
	lifetime = Tuning.TRAIL_SPARKLE_LIFETIME
	emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	emission_sphere_radius = Tuning.TRAIL_SPARKLE_RADIUS
	gravity = Vector2(0.0, -20.0)
	initial_velocity_min = 0.0
	initial_velocity_max = 12.0
	scale_amount_min = Tuning.TRAIL_SPARKLE_SCALE_MIN
	scale_amount_max = Tuning.TRAIL_SPARKLE_SCALE_MAX
	# Belirip büyür, sonra yumuşakça söner.
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.35, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	scale_amount_curve = curve
	set_sparkle_color(Color.WHITE)


func set_sparkle_color(color: Color) -> void:
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, Tuning.TRAIL_SPARKLE_ALPHA))
	ramp.set_color(1, Color(color, 0.0))
	color_ramp = ramp


func _process(_delta: float) -> void:
	global_position = player.global_position + Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)
	# Dururken, uçarken ve oyun bitince çıkmaz.
	emitting = visible and player.is_physics_processing() and not player.is_flying() \
			and player.velocity.length() >= Tuning.TRAIL_MIN_SPEED
