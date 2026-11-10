extends Node2D
## Ana sahne: kuleyi, oyuncuyu ve kamerayı kurar.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
## Duvarların dışındaki dekor alanının rengi.
const BACKDROP_COLOR := Color(0.05, 0.05, 0.08)

var _player: Player
var _camera: Camera2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKDROP_COLOR)

	var tower := Tower.new()
	tower.name = "Tower"
	add_child(tower)

	var spawner := PlatformSpawner.new()
	spawner.name = "Platforms"
	add_child(spawner)

	_player = PLAYER_SCENE.instantiate() as Player
	_player.position = Vector2.ZERO
	add_child(_player)

	_camera = Camera2D.new()
	_camera.name = "Camera"
	_camera.position = Vector2(0.0, Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT * 0.5)
	add_child(_camera)


func _physics_process(_delta: float) -> void:
	# GEÇİCİ: kamera oyuncuyu sadece yukarı doğru, ekran ortasında izler.
	# Gerçek davranış (bekleme, hızlanan kayma, yakalama bölgesi) kamera maddesinde.
	_camera.position.y = minf(_camera.position.y, _player.position.y)
