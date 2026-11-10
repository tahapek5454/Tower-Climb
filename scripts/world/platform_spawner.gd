class_name PlatformSpawner
extends Node2D
## Kamerayı izler: ekranın üstünde platformları hazır tutar, altta kalanları siler.

var _rng := RandomNumberGenerator.new()
## Üretilecek bir sonraki kat (kat 0 zemin).
var _next_floor: int = 1
var _prev_center: float = 0.0
## Zemin tam genişlikte olduğu için ilk platform her yere konabilir.
var _prev_width: float = Tuning.TOWER_WIDTH
## Aşağıdan yukarıya sıralı (eski olan başta).
var _platforms: Array[Platform] = []


func _ready() -> void:
	_rng.randomize()


func _physics_process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	var center_y: float = camera.get_screen_center_position().y
	var half_height: float = Tuning.VIEW_HEIGHT * 0.5
	_spawn_up_to(center_y - half_height - Tuning.PLATFORM_SPAWN_AHEAD)
	_despawn_below(center_y + half_height + Tuning.PLATFORM_DESPAWN_MARGIN)


func platform_count() -> int:
	return _platforms.size()


func _spawn_up_to(top_y: float) -> void:
	while PlatformRules.floor_y(_next_floor) > top_y:
		_spawn(_next_floor)
		_next_floor += 1


func _spawn(floor_number: int) -> void:
	var width: float = PlatformRules.width_for_floor(floor_number)
	var center: float = PlatformRules.next_center(floor_number, _prev_center, _prev_width, width, _rng)
	var platform := Platform.new()
	platform.name = "Floor%d" % floor_number
	platform.setup(floor_number, width)
	platform.position = Vector2(center, PlatformRules.floor_y(floor_number))
	add_child(platform)
	_platforms.append(platform)
	_prev_center = center
	_prev_width = width


func _despawn_below(bottom_y: float) -> void:
	while not _platforms.is_empty() and _platforms[0].position.y > bottom_y:
		_platforms.pop_front().queue_free()
