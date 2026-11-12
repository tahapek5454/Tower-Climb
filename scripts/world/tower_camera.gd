class_name TowerCamera
extends Camera2D
## Kule kamerası: CAMERA_START_FLOOR'a kadar bekler, sonra hızlanarak yukarı kayar.
## Oyuncu ekranın üst bölgesine çıkarsa onu yakalar. Asla aşağı inmez.
## Ekran sarsıntısı sadece `offset`'i değiştirir; oyun mantığı (kayma, oyun sonu) `position` kullanır.

## Takip edilen oyuncu (yakalama bölgesi için).
var target: Node2D
var is_scrolling: bool = false
## Şu anki kayma hızı (px/s); debug overlay için.
var speed: float = 0.0
var shake := CameraShake.new()
var _scroll_time: float = 0.0


func _ready() -> void:
	# Oyuncu fizik adımında hareket ettiği için kamera da fizik adımında güncellenir (titreme olmaz).
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	Events.floor_changed.connect(_on_floor_changed)
	Events.screen_shake.connect(_add_shake)
	Events.combo_ended.connect(_on_combo_ended)


func _physics_process(delta: float) -> void:
	if is_scrolling:
		_scroll_time += delta
		speed = CameraRules.scroll_speed(_scroll_time)
		position.y -= speed * delta
	if target != null:
		position.y = minf(position.y, CameraRules.catchup_center_y(target.global_position.y))


func _process(delta: float) -> void:
	offset = shake.update(delta)


## Kaymayı durdurur (oyun bitince).
func stop() -> void:
	is_scrolling = false
	speed = 0.0


## Oyuncu ekranın altından tamamen çıktı mı? (Sarsıntı kaydırması hesaba katılmaz.)
func is_below_screen(world_y: float) -> bool:
	return CameraRules.is_below_screen(world_y, global_position.y)


## Ekran sarsıntısı ayardan kapatılabilir.
func _add_shake(amount: float) -> void:
	if GameSettings.get_setting("screen_shake"):
		shake.add(amount)


func _on_floor_changed(floor_number: int) -> void:
	if not is_scrolling and CameraRules.should_start(floor_number):
		is_scrolling = true


func _on_combo_ended(_jumps: int, floors: int, bonus: int) -> void:
	_add_shake(CameraShake.combo_trauma(floors, bonus))
