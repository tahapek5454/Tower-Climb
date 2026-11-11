class_name PlayerVisual
extends Node2D
## Karakterin görüntüsü ve efektleri. Player'ın sinyallerini dinler; fiziğe karışmaz.
## Şimdilik kutu; Aşama 3'te 3D model buraya takılacak.
##
## Yapı:
##   Visual (ayaklarda)
##    └─ Squash (ayaklarda; ölçeklenir → ayaklar yerde kalır)
##        └─ Spin (gövde ortasında; döner → takla)
##            ├─ gövde
##            └─ göz

const BODY_COLOR := Color(1.0, 0.55, 0.15)
const EYE_COLOR := Color(0.12, 0.08, 0.05)
const EYE_SIZE := Vector2(8.0, 10.0)
## Gözün gövde ortasına göre konumu (x yüz dönülen yöne göre çevrilir).
const EYE_OFFSET := Vector2(8.0, -12.0)

var _squash: Node2D
var _spin: Node2D
var _eye: Polygon2D
var _facing: float = 1.0
## + dikey uzama, - dikey ezilme.
var _stretch: float = 0.0
var _stretch_velocity: float = 0.0

@onready var _player: Player = get_parent() as Player


func _ready() -> void:
	_build()
	_update_eye()
	_player.state_changed.connect(_on_state_changed)
	_player.event.connect(_on_player_event)


func _process(delta: float) -> void:
	_update_facing()
	_update_squash(delta)


func _build() -> void:
	_squash = Node2D.new()
	_squash.name = "Squash"
	add_child(_squash)

	_spin = Node2D.new()
	_spin.name = "Spin"
	_spin.position = Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)
	_squash.add_child(_spin)

	var body_size := Vector2(Tuning.PLAYER_WIDTH, Tuning.PLAYER_HEIGHT)
	_spin.add_child(_make_rect(Vector2.ZERO, body_size, BODY_COLOR))
	_eye = _make_rect(Vector2.ZERO, EYE_SIZE, EYE_COLOR)
	_spin.add_child(_eye)


func _update_facing() -> void:
	var vx: float = _player.velocity.x
	if absf(vx) > Tuning.RUN_STATE_MIN_SPEED and signf(vx) != _facing:
		_facing = signf(vx)
		_update_eye()


func _update_eye() -> void:
	_eye.position = Vector2(EYE_OFFSET.x * _facing, EYE_OFFSET.y)


## Yay, havadayken dikey hıza göre hafif bir uzamaya, yerdeyken 0'a doğru çeker.
func _update_squash(delta: float) -> void:
	var target: float = 0.0
	if not _player.is_on_floor():
		target = absf(_player.velocity.y) / Tuning.MAX_FALL_SPEED * Tuning.AIR_STRETCH_MAX
	var result: Vector2 = Spring.step(_stretch, _stretch_velocity, target,
			Tuning.SQUASH_SPRING_STIFFNESS, Tuning.SQUASH_SPRING_DAMPING, delta)
	_stretch = result.x
	_stretch_velocity = result.y
	_apply_stretch()


## Gövde alanı korunur: boy (1 + s), en 1 / boy.
func _apply_stretch() -> void:
	var height_scale: float = 1.0 + clampf(_stretch, -Tuning.SQUASH_LIMIT, Tuning.SQUASH_LIMIT)
	_squash.scale = Vector2(1.0 / height_scale, height_scale)


## Uzamayı anında bu değere ayarlar; yay oradan geri döndürür.
func _kick(amount: float) -> void:
	_stretch = clampf(amount, -Tuning.SQUASH_LIMIT, Tuning.SQUASH_LIMIT)
	_stretch_velocity = 0.0
	_apply_stretch()


func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	match event_name:
		&"jumped":
			_kick(_jump_stretch(data["speed"]))
		&"landed":
			_kick(-_land_squash(data["speed"]))
		&"wall_bounce":
			var ratio: float = clampf(data["speed"] / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
			_kick(ratio * Tuning.WALL_SQUASH_MAX)


func _jump_stretch(jump_speed: float) -> float:
	var max_jump: float = Player.jump_speed_for(Tuning.MAX_RUN_SPEED)
	var t: float = clampf(inverse_lerp(Tuning.JUMP_BASE, max_jump, jump_speed), 0.0, 1.0)
	return lerpf(Tuning.JUMP_STRETCH_MIN, Tuning.JUMP_STRETCH_MAX, t)


func _land_squash(fall_speed: float) -> float:
	if fall_speed < Tuning.LAND_SQUASH_MIN_SPEED:
		return 0.0
	var t: float = clampf(inverse_lerp(Tuning.LAND_SQUASH_MIN_SPEED, Tuning.MAX_FALL_SPEED, fall_speed),
			0.0, 1.0)
	return t * Tuning.LAND_SQUASH_MAX


func _on_state_changed(_new_state: Player.State, _old_state: Player.State) -> void:
	# Takla ve diğer durum animasyonları sonraki maddelerde.
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
