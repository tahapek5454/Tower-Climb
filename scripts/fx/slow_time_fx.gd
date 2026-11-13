class_name SlowTimeFx
extends CanvasLayer
## Kum saati etkisi sürerken ekran kenarlarında yumuşak mavi-mor gölge (vinyet): zamanın yavaşladığını
## hissettirir. Events.powerup_started/ended dinler. HUD ile aynı katmanda, HUD'dan önce eklenir (altında kalır).

const LAYER: int = 1
const FADE_IN_TIME: float = 0.5
const FADE_OUT_TIME: float = 0.7
## Gölgenin başladığı yer (merkezden kenara oran) ve rengi.
const INNER: float = 0.38
const TINT := Color(0.36, 0.38, 0.85)

var _vignette: TextureRect
var _fade: Tween


func _ready() -> void:
	layer = LAYER
	var gradient := Gradient.new()
	gradient.set_color(0, Color(TINT, 0.0))
	gradient.set_offset(0, INNER)
	gradient.set_color(1, Color(TINT, 1.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 1.0)
	texture.width = 256
	texture.height = 256
	_vignette = TextureRect.new()
	_vignette.texture = texture
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.modulate.a = 0.0
	add_child(_vignette)
	Events.powerup_started.connect(_on_powerup_started)
	Events.powerup_ended.connect(_on_powerup_ended)


func _on_powerup_started(kind: StringName, _duration: float) -> void:
	if kind == Pickup.HOURGLASS:
		_fade_to(Tuning.HOURGLASS_VIGNETTE_ALPHA, FADE_IN_TIME)


func _on_powerup_ended(kind: StringName) -> void:
	if kind == Pickup.HOURGLASS:
		_fade_to(0.0, FADE_OUT_TIME)


func _fade_to(alpha: float, time: float) -> void:
	if _fade != null:
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(_vignette, ^"modulate:a", alpha, time)
