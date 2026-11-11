class_name SmoothTrail
extends Line2D
## Hareket izi: hızlı hareket ederken gövde merkezinin geçtiği yoldan yumuşak, solan bir şerit.
## Gövdeye yakın uç kalın ve hafif saydam, kuyruk incelip kaybolur. Köşeler Chaikin ile yumuşatılır.
## top_level: noktalar dünyada kalır.

## Şeridin rengi (saydamlık TRAIL_ALPHA'dan gelir).
var trail_color: Color = Color.WHITE
var player: Player

## Ham noktalar (dünya koordinatı) ve eklendikleri an.
var _raw: PackedVector2Array = []
var _times: PackedFloat32Array = []
var _clock: float = 0.0


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	width = Tuning.TRAIL_WIDTH
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	antialiased = true
	# Toplamalı karışım: karanlık zeminde ışık izi gibi parlar.
	material = SoftTextures.additive()

	# Nokta 0 = en eski (kuyruk), son nokta = gövde.
	var fade := Gradient.new()
	fade.set_color(0, Color(trail_color, 0.0))
	fade.set_color(1, Color(trail_color, Tuning.TRAIL_ALPHA))
	gradient = fade
	var taper := Curve.new()
	taper.add_point(Vector2(0.0, 0.0))
	taper.add_point(Vector2(1.0, 1.0))
	width_curve = taper


func _process(delta: float) -> void:
	_clock += delta
	var emitting: bool = _should_emit()
	var head: Vector2 = _body_center()
	if emitting:
		_add_point(head)
	_drop_old_points()
	_render(head, emitting)


func point_count() -> int:
	return _raw.size()


func _should_emit() -> bool:
	# Oyun bitince oyuncu donar ama hızı kalır; iz bırakmasın.
	return player.is_physics_processing() and player.velocity.length() >= Tuning.TRAIL_MIN_SPEED


func _body_center() -> Vector2:
	return player.global_position + Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)


## Son sabit noktadan yeterince ilerlediyse yeni sabit nokta ekler.
## (Görüntü fizikten sık güncellenince aynı nokta tekrar eklenmesin: üst üste noktalar yumuşatmayı bozar.)
func _add_point(head: Vector2) -> void:
	if not _raw.is_empty() and _raw[_raw.size() - 1].distance_to(head) < Tuning.TRAIL_POINT_SPACING:
		return
	_raw.append(head)
	_times.append(_clock)


## Sabit noktalar + (iz sürüyorsa) gövdeye bağlanan canlı uç, yumuşatılarak çizilir.
func _render(head: Vector2, emitting: bool) -> void:
	var line_points: PackedVector2Array = _raw.duplicate()
	if emitting and not line_points.is_empty() and line_points[line_points.size() - 1].distance_to(head) > 0.5:
		line_points.append(head)
	if line_points.size() < 2:
		points = PackedVector2Array()
		return
	# İki tur köşe kesme: koşudan zıplamaya geçişteki ani yön değişimi de yumuşak bir kıvrım olur.
	points = Smoothing.chaikin(Smoothing.chaikin(line_points))


func _drop_old_points() -> void:
	var cutoff: float = _clock - Tuning.TRAIL_LIFETIME
	var drop: int = 0
	while drop < _times.size() and _times[drop] < cutoff:
		drop += 1
	if drop > 0:
		_raw = _raw.slice(drop)
		_times = _times.slice(drop)
