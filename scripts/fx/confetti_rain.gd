class_name ConfettiRain
extends CanvasLayer
## Konfeti yağmuru (yeni rekor kutlaması): ekranın üstünden dönerek ve salınarak düşen küçük renkli
## kâğıt parçaları. Renkler arayüz paletinden (altın, turkuaz, açık, gül, lavanta). burst() bir kez oynatır.
## Katman radyonun (50) altında, oyun sonu kartının (40) üstünde.

const CONFETTI_LAYER: int = 45
const AMOUNT: int = 150
const LIFETIME: float = 3.2
const PIECE_SIZE := Vector2i(7, 11)
const COLORS: Array[Color] = [
	UiStyle.COMBO,
	UiStyle.ACCENT,
	UiStyle.TEXT,
	Color(0.93, 0.58, 0.62),
	Color(0.70, 0.63, 0.95),
]

var _particles: CPUParticles2D


func _init() -> void:
	layer = CONFETTI_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	_particles = CPUParticles2D.new()
	_particles.position = Vector2(Tuning.VIEW_WIDTH * 0.5, -24.0)
	_particles.emitting = false
	_particles.one_shot = true
	_particles.amount = AMOUNT
	_particles.lifetime = LIFETIME
	_particles.explosiveness = 0.18
	_particles.local_coords = false
	_particles.texture = _piece_texture()
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(Tuning.VIEW_WIDTH * 0.5, 6.0)
	_particles.direction = Vector2.DOWN
	_particles.spread = 28.0
	_particles.initial_velocity_min = 110.0
	_particles.initial_velocity_max = 260.0
	_particles.gravity = Vector2(0.0, 340.0)
	_particles.damping_min = 25.0
	_particles.damping_max = 55.0
	_particles.tangential_accel_min = -45.0
	_particles.tangential_accel_max = 45.0
	_particles.angle_max = 360.0
	_particles.angular_velocity_min = -420.0
	_particles.angular_velocity_max = 420.0
	_particles.scale_amount_min = 0.75
	_particles.scale_amount_max = 1.35
	_particles.color_initial_ramp = _color_ramp()
	add_child(_particles)


## Konfeti yağmurunu bir kez başlatır.
func burst() -> void:
	_particles.restart()
	_particles.emitting = true


static func _piece_texture() -> Texture2D:
	var image := Image.create(PIECE_SIZE.x, PIECE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


## Parçacık başına rastgele bir renk (aralıksız gradyan değil, sert geçişli renk listesi).
static func _color_ramp() -> Gradient:
	var gradient := Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	for i: int in COLORS.size():
		offsets.append(float(i) / COLORS.size())
		colors.append(COLORS[i])
	gradient.offsets = offsets
	gradient.colors = colors
	return gradient
