class_name PlayerVisual
extends Node2D
## Karakterin görüntüsü ve efektleri. Player'ın sinyallerini dinler; fiziğe karışmaz.
## Şimdilik kutu; Aşama 3'te 3D model buraya takılacak.

const BODY_COLOR := Color(1.0, 0.55, 0.15)
const EYE_COLOR := Color(0.12, 0.08, 0.05)
const EYE_SIZE := Vector2(8.0, 10.0)
## Gözün gövde ortasından yatay uzaklığı ve ayaklardan yüksekliği.
const EYE_OFFSET := Vector2(8.0, -36.0)

var _eye: Polygon2D
var _facing: float = 1.0

@onready var _player: Player = get_parent() as Player


func _ready() -> void:
	var body_size := Vector2(Tuning.PLAYER_WIDTH, Tuning.PLAYER_HEIGHT)
	add_child(_make_rect(Vector2(0.0, -body_size.y * 0.5), body_size, BODY_COLOR))
	_eye = _make_rect(Vector2.ZERO, EYE_SIZE, EYE_COLOR)
	add_child(_eye)
	_update_eye()
	_player.state_changed.connect(_on_state_changed)


func _process(_delta: float) -> void:
	var vx: float = _player.velocity.x
	if absf(vx) > Tuning.RUN_STATE_MIN_SPEED and signf(vx) != _facing:
		_facing = signf(vx)
		_update_eye()


func _update_eye() -> void:
	_eye.position = Vector2(EYE_OFFSET.x * _facing, EYE_OFFSET.y)


func _on_state_changed(_new_state: Player.State, _old_state: Player.State) -> void:
	# Animasyonlar Aşama 2'de buraya bağlanacak.
	pass


func _make_rect(center: Vector2, size: Vector2, color: Color) -> Polygon2D:
	var half: Vector2 = size * 0.5
	var polygon := Polygon2D.new()
	polygon.color = color
	polygon.position = center
	polygon.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	return polygon
