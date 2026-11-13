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
## En son roket / kalp çıkan kat (başta: ilk uygun katta çıkabilsin diye yeterince geride).
var _last_jetpack_floor: int = -Tuning.JETPACK_MIN_FLOOR_GAP
var _last_heart_floor: int = -Tuning.HEART_MIN_FLOOR_GAP
var _last_hourglass_floor: int = -Tuning.HOURGLASS_MIN_FLOOR_GAP


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


## Verilen kata kadar (dahil) platformları hemen üretir (debug: bölüm atlama).
func spawn_through_floor(floor_number: int) -> void:
	while _next_floor <= floor_number:
		_spawn(_next_floor)
		_next_floor += 1


## Verilen y'nin üstündeki platformlar, aşağıdan yukarıya (JetpackRules biçimi: merkez x, üst y, genişlik).
func platforms_above(world_y: float) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for platform: Platform in _platforms:
		if platform.position.y < world_y:
			result.append(Vector3(platform.position.x, platform.position.y, platform.width))
	return result


## Debug (F7 roket, F8 kalp, F9 kum saati): oyuncunun üstündeki ilk platforma verilen türde toplanabilir koyar.
func debug_spawn(kind: StringName, above_y: float) -> void:
	for platform: Platform in _platforms:
		if platform.position.y < above_y and not PlatformRules.is_section_floor(platform.floor_number):
			_add_pickup(platform, kind)
			return


func _spawn_up_to(top_y: float) -> void:
	while PlatformRules.floor_y(_next_floor) > top_y:
		_spawn(_next_floor)
		_next_floor += 1


func _spawn(floor_number: int) -> void:
	var width: float = PlatformRules.random_width(floor_number, _rng)
	var center: float = PlatformRules.next_center(floor_number, _prev_center, _prev_width, width, _rng)
	var platform := Platform.new()
	platform.name = "Floor%d" % floor_number
	platform.setup(floor_number, width)
	platform.position = Vector2(center, PlatformRules.floor_y(floor_number))
	add_child(platform)
	_platforms.append(platform)
	_prev_center = center
	_prev_width = width
	# Bir katta en fazla bir toplanabilir; öncelik: roket, kalp, kum saati, elmas.
	if JetpackRules.should_spawn(floor_number, _last_jetpack_floor, _rng.randf()):
		_last_jetpack_floor = floor_number
		_add_pickup(platform, Pickup.JETPACK)
	elif PickupRules.should_spawn_heart(floor_number, _last_heart_floor, _rng.randf()):
		_last_heart_floor = floor_number
		_add_pickup(platform, Pickup.HEART, PickupRules.is_air_spawn(_rng.randf()))
	elif PickupRules.should_spawn_hourglass(floor_number, _last_hourglass_floor, _rng.randf()):
		_last_hourglass_floor = floor_number
		_add_pickup(platform, Pickup.HOURGLASS, PickupRules.is_air_spawn(_rng.randf()))
	elif PickupRules.should_spawn_diamond(floor_number, _rng.randf()):
		_add_pickup(platform, Pickup.DIAMOND, PickupRules.is_air_spawn(_rng.randf()))


## Toplanabiliri platformun çocuğu olarak koyar (platformla birlikte silinir). in_air: yüzeyin üstünde
## değil, bir üst kata giden yolda, kulenin herhangi bir yerinde süzülür.
func _add_pickup(platform: Platform, kind: StringName, in_air: bool = false) -> void:
	var pickup := Pickup.new()
	pickup.setup(kind)
	if in_air:
		pickup.position = Vector2(PickupRules.air_offset_x(platform.position.x, _rng.randf()),
				-Tuning.PICKUP_AIR_HEIGHT)
	else:
		pickup.position = Vector2(JetpackRules.pickup_offset_x(platform.width, _rng.randf()),
				-Tuning.PICKUP_HOVER_HEIGHT)
	platform.add_child(pickup)


func _despawn_below(bottom_y: float) -> void:
	while not _platforms.is_empty() and _platforms[0].position.y > bottom_y:
		_platforms.pop_front().queue_free()
