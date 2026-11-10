extends Node2D
## Ana sahne: kuleyi, oyuncuyu ve kamerayı kurar; oyun sonunu ve yeniden başlatmayı yönetir.

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

	var hud := Hud.new()
	hud.name = "Hud"
	add_child(hud)

	var debug_overlay := DebugOverlay.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.player = _player
	debug_overlay.camera = _camera
	add_child(debug_overlay)

	var game_over_label := GameOverLabel.new()
	game_over_label.name = "GameOverLabel"
	game_over_label.restart_requested.connect(_restart)
	add_child(game_over_label)

	Events.game_over.connect(_on_game_over)


func _physics_process(_delta: float) -> void:
	if not GameState.is_game_over and _camera.is_below_screen(_player.global_position.y):
		GameState.end_game()


func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	if event_name == &"landed":
		GameState.register_landing(data["floor"])


func _on_game_over(_final_score: int, _final_floor: int) -> void:
	_player.set_physics_process(false)
	_camera.stop()


## Durumu sıfırlar ve sahneyi baştan yükler (platformlar, kamera, oyuncu yeniden kurulur).
func _restart() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
