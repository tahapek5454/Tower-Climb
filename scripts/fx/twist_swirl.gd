class_name TwistSwirl
extends Node2D
## Silindirik dönüşte gövdenin çevresinde dönen silik burgu çizgileri: yandan bakılan iki basık
## halka yayı, dönüşle birlikte akar. Dönüş hızlıyken belirir, yavaşlayınca silinir.
## Orijin ayaklardadır (PlayerVisual her karede gövdenin x kaymasına taşır).

const POINTS: int = 24

var _angle: float = 0.0
var _last_angle: float = 0.0
var _strength: float = 0.0


## Her karede dönüş açısıyla çağrılır (radyan; FlipMotion.twist).
func track(angle: float, delta: float) -> void:
	var speed: float = absf(angle - _last_angle) / delta if delta > 0.0 else 0.0
	_last_angle = angle
	_angle = angle
	var target: float = clampf(speed / Tuning.TWIST_SWIRL_FULL_SPEED, 0.0, 1.0)
	_strength = lerpf(_strength, target, 1.0 - exp(-Tuning.TWIST_SWIRL_FADE_RATE * delta))
	visible = _strength > 0.01
	if visible:
		queue_redraw()


func _draw() -> void:
	var heights: Array[float] = Tuning.TWIST_SWIRL_HEIGHTS
	for i in heights.size():
		# Halkalar yarım tur kaydırılmış: biri öndeyken öteki arkada.
		_draw_arc(-heights[i], _angle + i * PI)


## Yayın ucu (en parlak) dönüş yönünde önde; kuyruk saydamlaşır. Arkada kalan kısım daha silik.
func _draw_arc(y: float, head: float) -> void:
	var radius: Vector2 = Tuning.TWIST_SWIRL_RADIUS
	var base: Color = Tuning.TWIST_SWIRL_COLOR
	var direction: float = 1.0 if _angle >= 0.0 else -1.0
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	for k in POINTS + 1:
		var t: float = float(k) / POINTS
		var u: float = head - direction * Tuning.TWIST_SWIRL_ARC * (1.0 - t)
		# Ekranda x = cos, önde (kameraya yakın) kalan kısım aşağıda çizilir.
		points.append(Vector2(radius.x * cos(u), y - radius.y * sin(u)))
		var behind: float = 0.35 if sin(u) > 0.0 else 1.0
		colors.append(Color(base, base.a * _strength * t * t * behind))
	draw_polyline_colors(points, colors, Tuning.TWIST_SWIRL_WIDTH, true)
