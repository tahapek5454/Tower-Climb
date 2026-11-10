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


func _on_floor_changed(floor_number: int) -> void:
	if not is_scrolling and CameraRules.should_start(floor_number):
		is_scrolling = true
