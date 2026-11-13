extends Node2D
## Ana sahne: kuleyi, oyuncuyu ve kamerayı kurar; oyun sonunu ve yeniden başlatmayı yönetir.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
## Oyun alanı dışında kalan şeritlerin rengi (16:9 olmayan ekranlarda).
const BACKDROP_COLOR := Color(0.05, 0.05, 0.08)
## Oyun sonundan "Tekrar"da kısa ekran kararması (s); hızlı yeniden başlama hissi korunur.
const RESTART_FADE_TIME: float = 0.14

var _player: Player
var _camera: TowerCamera
var _spawner: PlatformSpawner
var _menu: MainMenu
var _magnet: MagnetField
## Elmasla devam kartı (kapalıysa null).
var _revive: ReviveCard
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

	_add_record_line()

	_spawner = PlatformSpawner.new()
	_spawner.name = "Platforms"
	add_child(_spawner)

	_player = PLAYER_SCENE.instantiate() as Player
	_player.position = Vector2.ZERO
	_player.event.connect(_on_player_event)
	_player.platforms_above = _spawner.platforms_above
	add_child(_player)

	# Kamera oyuncudan sonra eklenir: oyuncu hareket ettikten sonra güncellenir.
	_camera = TowerCamera.new()
	_camera.name = "Camera"
	_camera.position = Vector2(0.0, Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT * 0.5)
	_camera.target = _player
	_camera.slow_ended.connect(func() -> void: Events.powerup_ended.emit(Pickup.HOURGLASS))
	add_child(_camera)

	_magnet = MagnetField.new()
	_magnet.name = "Magnet"
	_magnet.player = _player
	_magnet.spawner = _spawner
	_magnet.ended.connect(func() -> void: Events.powerup_ended.emit(Pickup.MAGNET))
	add_child(_magnet)

	var magnet_fx := MagnetFx.new()
	magnet_fx.name = "MagnetFx"
	magnet_fx.player = _player
	add_child(magnet_fx)

	var game_audio := GameAudio.new()
	game_audio.name = "GameAudio"
	game_audio.player = _player
	add_child(game_audio)

	var pickup_fx := PickupFx.new()
	pickup_fx.name = "PickupFx"
	pickup_fx.player = _player
	add_child(pickup_fx)

	var hit_stop := HitStop.new()
	hit_stop.name = "HitStop"
	add_child(hit_stop)

	var slow_time_fx := SlowTimeFx.new()
	slow_time_fx.name = "SlowTimeFx"
	add_child(slow_time_fx)

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

	if Tuning.ACHIEVEMENTS_ENABLED:
		_add_achievements()
	if Tuning.SHOP_ENABLED:
		_add_shop()

	if ReviveRules.is_enabled():
		_revive = ReviveCard.new()
		_revive.name = "ReviveCard"
		_revive.accepted.connect(_rescue_player.bind(&"revive"))
		_revive.declined.connect(GameState.end_game)
		add_child(_revive)

	var game_over_screen := GameOverScreen.new()
	game_over_screen.name = "GameOverScreen"
	game_over_screen.restart_requested.connect(_restart)
	game_over_screen.menu_requested.connect(_on_main_menu_requested)
	add_child(game_over_screen)

	Events.game_over.connect(_on_game_over)
	Events.pickup_collected.connect(_on_pickup_collected)
	if GameFlow.state == FlowRules.State.MENU:
		_menu.open()
		_schedule_hop()
	ScreenFade.reveal()


## Başarımlar: izleyici, bildirim ve ana menüdeki liste ekranı (Tuning.ACHIEVEMENTS_ENABLED ile kapanır).
func _add_achievements() -> void:
	var tracker := AchievementTracker.new()
	tracker.name = "AchievementTracker"
	add_child(tracker)
	tracker.watch_player(_player)
	var toast := AchievementToast.new()
	toast.name = "AchievementToast"
	add_child(toast)
	var achievements_menu := AchievementsMenu.new()
	achievements_menu.name = "AchievementsMenu"
	add_child(achievements_menu)
	_menu.link_child(achievements_menu, _menu.achievements_requested)


## Elmas mağazası: yalnız ana menüden açılır (Tuning.SHOP_ENABLED ile kapanır).
func _add_shop() -> void:
	var shop_menu := ShopMenu.new()
	shop_menu.name = "ShopMenu"
	add_child(shop_menu)
	_menu.link_child(shop_menu, _menu.shop_requested)


## Rekor çizgisi: tur başındaki kayıtlı en yüksek kata konur (rekor küçükse ya da kapalıysa yok).
func _add_record_line() -> void:
	var best: int = int(GameState.records.get(SaveData.BEST_FLOOR, 0))
	if not RecordLineRules.should_show(best):
		return
	var line := RecordLine.new()
	line.name = "RecordLine"
	line.best_floor = best
	add_child(line)


func _physics_process(_delta: float) -> void:
	if _player.is_flying():
		# Roketle geçilen katlar da puan kazandırır.
		GameState.register_flight_floor(JetpackRules.floor_passed(_player.global_position.y))
	elif not GameState.is_game_over and _camera.is_below_screen(_player.global_position.y):
		_on_player_fell()


## Oyuncu ekranın altından düştü: kalp varsa biri harcanır ve roket onu ekranın altından yukarı taşır;
## yoksa (koşullar uygunsa) elmasla devam kartı çıkar; o da yoksa oyun biter.
func _on_player_fell() -> void:
	if GameState.use_heart():
		_rescue_player(&"heart")
	elif _revive == null or not _revive.offer():
		GameState.end_game()


## Kalp ya da elmasla kurtarma: oyuncu ekranın altından kısa bir roket uçuşuyla yukarı taşınır.
func _rescue_player(source: StringName) -> void:
	_player.rescue(_camera.global_position.y + Tuning.VIEW_HEIGHT * 0.5 - Tuning.HEART_RESCUE_RISE, source)


func _unhandled_input(input_event: InputEvent) -> void:
	if not GameFlow.is_playing():
		return
	if input_event.is_action_pressed(&"debug_skip_section"):
		_debug_skip_section()
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"debug_spawn_jetpack"):
		# Debug (F7 roket, F8 kalp): denemek için oyuncunun üstündeki ilk platforma bir tane koyar.
		_spawner.debug_spawn(Pickup.JETPACK, _player.global_position.y - Tuning.FLOOR_SPACING * 0.5)
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"debug_spawn_heart"):
		_spawner.debug_spawn(Pickup.HEART, _player.global_position.y - Tuning.FLOOR_SPACING * 0.5)
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"debug_spawn_hourglass"):
		_spawner.debug_spawn(Pickup.HOURGLASS, _player.global_position.y - Tuning.FLOOR_SPACING * 0.5)
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"debug_spawn_magnet"):
		_spawner.debug_spawn(Pickup.MAGNET, _player.global_position.y - Tuning.FLOOR_SPACING * 0.5)
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
	match event_name:
		&"landed":
			GameState.register_landing(data["floor"])
		&"jetpack_started":
			GameState.begin_flight()
			Events.powerup_started.emit(Pickup.JETPACK, data["duration"])
		&"jetpack_ended":
			GameState.end_flight()
			Events.powerup_ended.emit(Pickup.JETPACK)


func _on_pickup_collected(kind: StringName, _world_position: Vector2) -> void:
	match kind:
		Pickup.JETPACK:
			_player.start_jetpack()
		Pickup.DIAMOND:
			GameState.add_diamond()
		Pickup.HEART:
			GameState.add_hearts(1)
		Pickup.HOURGLASS:
			_camera.slow_down()
			Events.powerup_started.emit(Pickup.HOURGLASS, _camera.slow_time_left())
		Pickup.MAGNET:
			_magnet.activate()
			Events.powerup_started.emit(Pickup.MAGNET, _magnet.time_left())


func _on_game_over(_final_score: int, _final_floor: int) -> void:
	_player.set_physics_process(false)
	_camera.stop()


## Durumu sıfırlar ve sahneyi baştan yükler (platformlar, kamera, oyuncu yeniden kurulur).
func _restart() -> void:
	await ScreenFade.cover(RESTART_FADE_TIME)
	GameFlow.request(FlowRules.State.PLAYING)
	GameState.reset()
	get_tree().reload_current_scene()
