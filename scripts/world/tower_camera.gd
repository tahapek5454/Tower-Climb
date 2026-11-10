class_name TowerCamera
extends Camera2D
## Kule kamerası: CAMERA_START_FLOOR'a kadar bekler, sonra hızlanarak yukarı kayar.
## Oyuncu ekranın üst bölgesine çıkarsa onu yakalar. Asla aşağı inmez.

## Takip edilen oyuncu (yakalama bölgesi için).
var target: Node2D
var is_scrolling: bool = false
## Şu anki kayma hızı (px/s); debug overlay için.
var speed: float = 0.0
var _scroll_time: float = 0.0


func _ready() -> void:
	# Oyuncu fizik adımında hareket ettiği için kamera da fizik adımında güncellenir (titreme olmaz).
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	Events.floor_changed.connect(_on_floor_changed)


func _physics_process(delta: float) -> void:
	if is_scrolling:
		_scroll_time += delta
		speed = CameraRules.scroll_speed(_scroll_time)
		position.y -= speed * delta
	if target != null:
		position.y = minf(position.y, CameraRules.catchup_center_y(target.global_position.y))


## Kaymayı durdurur (oyun bitince).
func stop() -> void:
	is_scrolling = false
	speed = 0.0


## Oyuncu ekranın altından tamamen çıktı mı?
func is_below_screen(world_y: float) -> bool:
	return CameraRules.is_below_screen(world_y, get_screen_center_position().y)


func _on_floor_changed(floor_number: int) -> void:
	if not is_scrolling and CameraRules.should_start(floor_number):
		is_scrolling = true
