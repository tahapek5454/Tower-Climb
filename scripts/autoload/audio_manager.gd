extends Node
## Ses yöneticisi (autoload): ses kanallarını (Master, SFX, Music) kurar, ses efektlerini bir oynatıcı
## havuzundan çalar. Ses ayarları (Aşama 5) bu kanalların seviyesini değiştirir.
## Sesler assets/audio/sfx/*.wav (tools/sfx/generate_sfx.py üretir); dosyası olmayan ses sessizce atlanır.

const SFX_DIR: String = "res://assets/audio/sfx/"
const SOUNDS: Array[StringName] = [&"jump", &"land", &"wall", &"combo", &"combo_end", &"section",
		&"game_over", &"whoosh"]
const SFX_BUS: StringName = &"SFX"
const MUSIC_BUS: StringName = &"Music"
## Aynı anda çalabilecek en fazla efekt sayısı.
const POOL_SIZE: int = 10

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


## Efekt çalar. pitch: perde çarpanı (1 = normal), volume_db: ses yüksekliği.
func play(sound: StringName, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var stream: AudioStream = _streams.get(sound)
	if stream == null:
		return
	var player: AudioStreamPlayer = _free_player()
	player.stream = stream
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


## Ses kanalı yoksa oluşturur ve Master'a bağlar.
func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")
