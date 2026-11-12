extends Node2D
## Ana sahne: kuleyi, oyuncuyu ve kamerayı kurar; oyun sonunu ve yeniden başlatmayı yönetir.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
## Oyun alanı dışında kalan şeritlerin rengi (16:9 olmayan ekranlarda).
const BACKDROP_COLOR := Color(0.05, 0.05, 0.08)

var _player: Player
var _camera: TowerCamera
var _spawner: PlatformSpawner
var _menu: MainMenu
## Menüde kartalın arada bir kendiliğinden zıplaması.
var _hop_timer: Timer


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKDROP_COLOR)

	var backdrop := Backdrop.new()
	backdrop.name = "Backdrop"
	add_child(backdrop)

	var tower := Tower.new()
	tower.name = "Tower"
	add_child(tower)

	var wall_decor := WallDecor.new()
	wall_decor.name = "WallDecor"
	add_child(wall_decor)

	var start_area := StartArea.new()
	start_area.name = "StartArea"
	add_child(start_area)

	var ambient := AmbientParticles.new()
	ambient.name = "Ambient"
	add_child(ambient)

	_spawner = PlatformSpawner.new()
	_spawner.name = "Platforms"
	add_child(_spawner)

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

	var game_audio := GameAudio.new()
	game_audio.name = "GameAudio"
	game_audio.player = _player
	add_child(game_audio)

	var hit_stop := HitStop.new()
	hit_stop.name = "HitStop"
	add_child(hit_stop)

	var hud := Hud.new()
	hud.name = "Hud"
	add_child(hud)

	var combo_popups := ComboPopups.new()
	combo_popups.name = "ComboPopups"
	combo_popups.player = _player
	add_child(combo_popups)

	# Radyo: oyuncunun müzikleri (web'de müzik yok).
	if MusicLibrary.is_available():
		var radio := RadioPanel.new()
		radio.name = "Radio"
		add_child(radio)

	var debug_overlay := DebugOverlay.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.player = _player
	debug_overlay.camera = _camera
	add_child(debug_overlay)

	_menu = MainMenu.new()
	_menu.name = "MainMenu"
	_menu.play_requested.connect(_on_play_requested)
	add_child(_menu)

	_hop_timer = Timer.new()
	_hop_timer.one_shot = true
	_hop_timer.timeout.connect(_on_hop_timer)
	add_child(_hop_timer)

	var pause_controller := PauseController.new()
	pause_controller.name = "PauseController"
	pause_controller.main_menu_requested.connect(_on_main_menu_requested)
	add_child(pause_controller)

	# Ayarlar: hem ana menüden hem duraklatma menüsünden açılır.
	var settings := SettingsMenu.new()
	settings.name = "SettingsMenu"
	add_child(settings)
	var pause_menu: PauseMenu = pause_controller.get_menu()
	for screen: UiScreen in [_menu, pause_menu]:
		screen.link_child(settings, screen.settings_requested)
		screen.set_settings_available(true)

	var game_over_label := GameOverLabel.new()
	game_over_label.name = "GameOverLabel"
	game_over_label.restart_requested.connect(_restart)
	add_child(game_over_label)

	Events.game_over.connect(_on_game_over)
	if GameFlow.state == FlowRules.State.MENU:
		_menu.open()
		_schedule_hop()
	ScreenFade.reveal()


func _physics_process(_delta: float) -> void:
	if not GameState.is_game_over and _camera.is_below_screen(_player.global_position.y):
		GameState.end_game()


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"debug_skip_section") and GameFlow.is_playing():
		_debug_skip_section()
		get_viewport().set_input_as_handled()


## Debug (F6): oyuncuyu bir sonraki bölüm platformuna (tam genişlik, ortada) ışınlar; kamera
## başlangıçtaki gibi konumlanır. Temaları 100 kat tırmanmadan görmek için. Skor/kombo da atlar.
func _debug_skip_section() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var current: int = floori(ThemeRules.floor_value_at(_player.position.y))
	var target: int = (floori(float(current) / interval) + 1) * interval
	_spawner.spawn_through_floor(target)
	var target_y: float = PlatformRules.floor_y(target)
	_player.position = Vector2(0.0, target_y)
	_player.velocity = Vector2.ZERO
	_camera.position.y = target_y + Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT * 0.5


func _on_play_requested() -> void:
	_menu.close()
	GameFlow.request(FlowRules.State.PLAYING)


## Duraklatma menüsünden ana menüye: oyun bırakılır (rekorlar kaydedilir), ekran kararır, sahne yenilenir.
func _on_main_menu_requested() -> void:
	GameState.abandon_run()
	await ScreenFade.cover()
	GameFlow.request(FlowRules.State.MENU)
	GameState.reset()
	get_tree().reload_current_scene()


func _schedule_hop() -> void:
	_hop_timer.start(randf_range(Tuning.MENU_HOP_INTERVAL_MIN, Tuning.MENU_HOP_INTERVAL_MAX))


func _on_hop_timer() -> void:
	if GameFlow.state != FlowRules.State.MENU:
		return
	_player.hop(Tuning.MENU_HOP_SPEED)
	_schedule_hop()


func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	if event_name == &"landed":
		GameState.register_landing(data["floor"])


func _on_game_over(_final_score: int, _final_floor: int) -> void:
	_player.set_physics_process(false)
	_camera.stop()


## Durumu sıfırlar ve sahneyi baştan yükler (platformlar, kamera, oyuncu yeniden kurulur).
func _restart() -> void:
	GameFlow.request(FlowRules.State.PLAYING)
	GameState.reset()
	get_tree().reload_current_scene()
