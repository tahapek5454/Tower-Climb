extends Node
## Ses yöneticisi (autoload): ses kanallarını (Master, SFX, Music) kurar, ses efektlerini bir oynatıcı
## havuzundan çalar, oyuncunun müziklerini `music` (MusicPlayer) ile çalar. Efektleri aç/kapa ve
## tümünü sustur burada (ayarlar kaydedilir). Ses ayarları (Aşama 5) bu kanalları kullanır.
## Sesler assets/audio/sfx/*.wav (tools/sfx/generate_sfx.py üretir); dosyası olmayan ses sessizce atlanır.

const SFX_DIR: String = "res://assets/audio/sfx/"
const SOUNDS: Array[StringName] = [&"jump", &"land", &"wall", &"combo", &"combo_end", &"section",
		&"game_over", &"whoosh", &"ui_hover", &"ui_click", &"ui_back", &"record",
		&"pickup", &"jetpack", &"jetpack_end", &"diamond", &"heart", &"rescue",
		&"hourglass", &"hourglass_end"]
const SFX_BUS: StringName = &"SFX"
const MUSIC_BUS: StringName = &"Music"
## Aynı anda çalabilecek en fazla efekt sayısı.
const POOL_SIZE: int = 10

## Efekt sesleri açıldı/kapandı, tüm ses susturuldu/açıldı (panel ikonları güncellenir).
signal sfx_enabled_changed(enabled: bool)
signal muted_changed(muted: bool)
## Genel veya efekt ses seviyesi değişti (bus: &"Master" / &"SFX").
signal volume_changed(bus_name: StringName, value: float)

## Genel ve efekt ses seviyeleri (0..1, doğrusal). Sessize alma (mute) bundan bağımsızdır.
var master_volume: float = 1.0
var sfx_volume: float = 1.0
## Oyuncunun müzikleri (radyo paneli bunu kullanır).
var music: MusicPlayer
## Müzik kanalındaki alçak geçiren süzgeç (duraklatınca müzik boğuklaşır).
var _muffle: AudioEffectLowPassFilter
var _muffle_tween: Tween
var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0


func _ready() -> void:
	# Duraklatma ve oyun sonunda da sesler kesilmesin.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(SFX_BUS)
	_ensure_bus(MUSIC_BUS)
	for sound: StringName in SOUNDS:
		var path: String = SFX_DIR + String(sound) + ".wav"
		if ResourceLoader.exists(path):
			_streams[sound] = load(path)
	for i: int in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_players.append(player)
	var settings: Dictionary = AudioSettings.load_all()
	set_sfx_enabled(settings["sfx_enabled"], false)
	set_muted(settings["muted"], false)
	set_master_volume(settings["master_volume"], false)
	set_sfx_volume(settings["sfx_volume"], false)
	music = MusicPlayer.new()
	music.name = "Music"
	add_child(music)
	_setup_muffle()
	Events.flow_changed.connect(_on_flow_changed)


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_mute"):
		set_muted(not is_muted())
		get_viewport().set_input_as_handled()


## Genel ses seviyesi (0..1). save: kalıcı kaydet (sürüklerken her adımda kaydetmemek için).
func set_master_volume(value: float, save: bool = true) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volume(0, master_volume)
	if save:
		AudioSettings.save_value("master_volume", master_volume)
	volume_changed.emit(&"Master", master_volume)


## Efekt ses seviyesi (0..1).
func set_sfx_volume(value: float, save: bool = true) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_volume(AudioServer.get_bus_index(SFX_BUS), sfx_volume)
	if save:
		AudioSettings.save_value("sfx_volume", sfx_volume)
	volume_changed.emit(SFX_BUS, sfx_volume)


## Müziği boğuklaştırır / açar (kesim frekansı yumuşakça kayar).
func set_music_muffled(muffled: bool) -> void:
	var bus: int = AudioServer.get_bus_index(MUSIC_BUS)
	if bus == -1 or _muffle == null:
		return
	if _muffle_tween != null:
		_muffle_tween.kill()
	_muffle_tween = create_tween()
	if muffled:
		AudioServer.set_bus_effect_enabled(bus, 0, true)
		_muffle_tween.tween_property(_muffle, ^"cutoff_hz", Tuning.MUFFLE_CUTOFF_HZ, Tuning.MUFFLE_TIME)
	else:
		_muffle_tween.tween_property(_muffle, ^"cutoff_hz", Tuning.MUFFLE_CUTOFF_OPEN_HZ, Tuning.MUFFLE_TIME)
		_muffle_tween.tween_callback(AudioServer.set_bus_effect_enabled.bind(bus, 0, false))


## Efekt sesleri açık mı?
func is_sfx_enabled() -> bool:
	return not AudioServer.is_bus_mute(AudioServer.get_bus_index(SFX_BUS))


func set_sfx_enabled(enabled: bool, save: bool = true) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not enabled)
	if save:
		AudioSettings.save_value("sfx_enabled", enabled)
	sfx_enabled_changed.emit(enabled)


## Tüm ses kapalı mı? (Master kanalı.)
func is_muted() -> bool:
	return AudioServer.is_bus_mute(0)


func set_muted(muted: bool, save: bool = true) -> void:
	AudioServer.set_bus_mute(0, muted)
	if save:
		AudioSettings.save_value("muted", muted)
	muted_changed.emit(muted)


## Efekt çalar. pitch: perde çarpanı (1 = normal), volume_db: ses yüksekliği, bus: hangi kanaldan
## (varsayılan efekt; ayarlarda müzik seviyesini duyurmak için müzik kanalı).
func play(sound: StringName, pitch: float = 1.0, volume_db: float = 0.0, bus: StringName = SFX_BUS) -> void:
	var stream: AudioStream = _streams.get(sound)
	if stream == null:
		return
	var player: AudioStreamPlayer = _free_player()
	player.stream = stream
	player.bus = bus
	player.pitch_scale = maxf(pitch, 0.05)
	player.volume_db = volume_db
	player.play()


## Boşta bir oynatıcı; hepsi çalıyorsa en eskisi (sırayla) kesilir.
func _free_player() -> AudioStreamPlayer:
	for i: int in POOL_SIZE:
		var player: AudioStreamPlayer = _players[(_next + i) % POOL_SIZE]
		if not player.playing:
			_next = (_next + i + 1) % POOL_SIZE
			return player
	var oldest: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % POOL_SIZE
	return oldest


## Kanal seviyesini ayarlar (mute'tan bağımsız: sıfır = çok kısık).
func _apply_volume(bus: int, linear: float) -> void:
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(linear, 0.0001)))


## Müzik kanalına süzgeç ekler (kapalı başlar; efekt sırası 0).
func _setup_muffle() -> void:
	var bus: int = AudioServer.get_bus_index(MUSIC_BUS)
	_muffle = AudioEffectLowPassFilter.new()
	_muffle.cutoff_hz = Tuning.MUFFLE_CUTOFF_OPEN_HZ
	AudioServer.add_bus_effect(bus, _muffle, 0)
	AudioServer.set_bus_effect_enabled(bus, 0, false)


func _on_flow_changed(new_state: int, _old_state: int) -> void:
	set_music_muffled(new_state == FlowRules.State.PAUSED)


## Ses kanalı yoksa oluşturur ve Master'a bağlar.
func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")
