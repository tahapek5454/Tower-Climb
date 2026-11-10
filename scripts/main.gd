extends Node2D
## Ana sahne: kuleyi, oyuncuyu ve kamerayı kurar.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
## Duvarların dışındaki dekor alanının rengi.
const BACKDROP_COLOR := Color(0.05, 0.05, 0.08)

var _player: Player
var _camera: TowerCamera


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
	_player.event.connect(_on_player_event)
	add_child(_player)

	# Kamera oyuncudan sonra eklenir: oyuncu hareket ettikten sonra güncellenir.
	_camera = TowerCamera.new()
	_camera.name = "Camera"
	_camera.position = Vector2(0.0, Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT * 0.5)
	_camera.target = _player
	add_child(_camera)


func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	if event_name == &"landed":
		# Ulaşılan en yüksek kat; skor/kombo maddesinde skor sistemi de bunu kullanacak.
		GameState.floor_number = maxi(GameState.floor_number, data["floor"])
