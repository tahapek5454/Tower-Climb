class_name MusicPlayer
extends Node
## Oyuncunun müziklerini çalar (Music kanalında). AudioManager'ın çocuğu; sahne yeniden yüklense de
## müzik kesilmez. Parça bitince sonrakine geçer (döngüsel). Seviye ve son parça AudioSettings ile
## kaydedilir. Oyun açılınca müzik kendiliğinden başlamaz (kullanıcı kararı); oyuncu radyodan başlatır,
## sonra yeniden başlatma/menü geçişlerinde kesilmeden sürer. Web'de devre dışı (MusicLibrary.is_available).

signal track_changed(title: String, position: String)
signal playing_changed(playing: bool)
signal library_changed(count: int)

var playlist := Playlist.new()
## Müzik seviyesi (0..1, doğrusal).
var volume: float = 0.6
var _player: AudioStreamPlayer
var _paused_at: float = 0.0
var _is_playing: bool = false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"Music"
	_player.finished.connect(_on_finished)
	add_child(_player)
	if not MusicLibrary.is_available():
		return
	var settings: Dictionary = AudioSettings.load_all()
	set_volume(settings["music_volume"], false)
	rescan(settings["last_track"])


## Klasörü yeniden tarar; çalan parça listede kalırsa kesilmez.
func rescan(keep_path: String = "") -> void:
	var previous: String = playlist.current()
	playlist.set_tracks(MusicLibrary.list_tracks(), keep_path if keep_path != "" else previous)
	library_changed.emit(playlist.size())
	if playlist.current() != previous:
		_paused_at = 0.0
		_player.stop()
		_player.stream = null
		if _is_playing and not _start_current():
			_is_playing = false
			playing_changed.emit(false)
	_emit_track()


func is_playing() -> bool:
	return _is_playing


func current_title() -> String:
	return MusicLibrary.title_of(playlist.current()) if not playlist.is_empty() else ""


## Geçerli parçanın ilerlemesi (0..1).
func progress() -> float:
	if _player.stream == null:
		return 0.0
	var length: float = _player.stream.get_length()
	var position: float = _player.get_playback_position() if _player.playing else _paused_at
	return clampf(position / length, 0.0, 1.0) if length > 0.0 else 0.0


func play() -> void:
	if playlist.is_empty():
		return
	if _player.stream != null and not _player.playing and _paused_at > 0.0:
		_player.play(_paused_at)
	elif not _start_current():
		return
	_set_playing(true)


func pause() -> void:
	_paused_at = _player.get_playback_position()
	_player.stop()
	_set_playing(false)


func toggle_play() -> void:
	if _is_playing:
		pause()
	else:
		play()


func next_track() -> void:
	playlist.next()
	_change_track()


func previous_track() -> void:
	playlist.previous()
	_change_track()


## Müzik seviyesi (0..1). save: kalıcı kaydet (kaydırıcı sürüklenirken her adımda kaydetmemek için).
func set_volume(value: float, save: bool = true) -> void:
	volume = clampf(value, 0.0, 1.0)
	var bus: int = AudioServer.get_bus_index(&"Music")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)))
		AudioServer.set_bus_mute(bus, volume <= 0.001)
	if save:
		AudioSettings.save_value("music_volume", volume)


func _change_track() -> void:
	_paused_at = 0.0
	if _is_playing:
		if not _start_current():
			_set_playing(false)
	else:
		_player.stop()
		_player.stream = null
		AudioSettings.save_value("last_track", playlist.current())
		_emit_track()


## Geçerli parçayı baştan çalar; okunamayan parçaları atlar (en fazla liste boyu kadar).
## Hiçbiri okunamazsa false.
func _start_current() -> bool:
	_paused_at = 0.0
	for attempt: int in playlist.size():
		var stream: AudioStream = MusicLibrary.load_stream(playlist.current())
		if stream != null:
			_player.stream = stream
			_player.play()
			AudioSettings.save_value("last_track", playlist.current())
			_emit_track()
			return true
		push_warning("Müzik okunamadı, atlanıyor: %s" % playlist.current())
		playlist.next()
	_player.stream = null
	return false


func _set_playing(playing: bool) -> void:
	if playing == _is_playing:
		return
	_is_playing = playing
	playing_changed.emit(playing)


func _emit_track() -> void:
	track_changed.emit(current_title(), playlist.position_text())


func _on_finished() -> void:
	if _is_playing:
		playlist.next()
		if not _start_current():
			_set_playing(false)
