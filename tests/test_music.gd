extends GutTest
## Müzik altyapısı testleri: Playlist (saf), MusicLibrary (geçici klasörde), AudioSettings (geçici dosyada).

const TEMP_DIR: String = "user://test_tmp_music"
const TEMP_SOURCE: String = "user://test_tmp_source"
const TEMP_SETTINGS: String = "user://test_tmp_settings.cfg"

var _saved_music_dir: String
var _saved_settings_path: String


func before_each() -> void:
	_saved_music_dir = MusicLibrary.music_dir
	_saved_settings_path = AudioSettings.path
	MusicLibrary.music_dir = TEMP_DIR
	AudioSettings.path = TEMP_SETTINGS
	_remove_dir(TEMP_DIR)
	_remove_dir(TEMP_SOURCE)
	DirAccess.remove_absolute(TEMP_SETTINGS)


func after_each() -> void:
	_remove_dir(TEMP_DIR)
	_remove_dir(TEMP_SOURCE)
	DirAccess.remove_absolute(TEMP_SETTINGS)
	MusicLibrary.music_dir = _saved_music_dir
	AudioSettings.path = _saved_settings_path


func test_playlist_wraps_and_keeps_current() -> void:
	var playlist := Playlist.new()
	assert_eq(playlist.current(), "")
	assert_eq(playlist.position_text(), "")
	playlist.set_tracks(PackedStringArray(["a", "b", "c"]))
	assert_eq(playlist.current(), "a")
	assert_eq(playlist.previous(), "c", "başta geri gidince sona sarar")
	assert_eq(playlist.next(), "a", "sonda ileri gidince başa sarar")
	playlist.next()
	assert_eq(playlist.position_text(), "2/3")
	playlist.set_tracks(PackedStringArray(["x", "b", "y"]), playlist.current())
	assert_eq(playlist.current(), "b", "yeniden taramada çalan parça korunur")
	playlist.set_tracks(PackedStringArray(["x", "y"]), "b")
	assert_eq(playlist.current(), "x", "çalan parça silindiyse ilk parça")


func test_library_lists_supported_files_sorted() -> void:
	DirAccess.make_dir_recursive_absolute(TEMP_DIR)
	for file_name: String in ["parça 10.mp3", "parça 2.OGG", "notlar.txt", "kapak.jpg", "a_b.wav"]:
		_touch(TEMP_DIR.path_join(file_name))
	var tracks: PackedStringArray = MusicLibrary.list_tracks()
	assert_eq(tracks.size(), 3, "sadece mp3/ogg/wav")
	assert_eq(tracks[0].get_file(), "a_b.wav")
	assert_eq(tracks[1].get_file(), "parça 2.OGG", "doğal sıralama: 2 < 10")
	assert_eq(MusicLibrary.title_of(tracks[0]), "a b", "alt çizgi boşluk olur")


func test_import_copies_supported_and_skips_duplicates() -> void:
	DirAccess.make_dir_recursive_absolute(TEMP_SOURCE)
	var sources := PackedStringArray()
	for file_name: String in ["şarkı.mp3", "resim.png"]:
		var path: String = ProjectSettings.globalize_path(TEMP_SOURCE.path_join(file_name))
		_touch(path)
		sources.append(path)
	assert_eq(MusicLibrary.import_files(sources), 1, "png atlanır")
	assert_eq(MusicLibrary.import_files(sources), 0, "aynı ad ikinci kez kopyalanmaz")
	assert_eq(MusicLibrary.list_tracks().size(), 1)


func test_settings_default_and_persist() -> void:
	var defaults: Dictionary = AudioSettings.load_all()
	assert_eq(defaults["music_volume"], AudioSettings.DEFAULTS["music_volume"])
	AudioSettings.save_value("music_volume", 0.25)
	AudioSettings.save_value("muted", true)
	var loaded: Dictionary = AudioSettings.load_all()
	assert_almost_eq(float(loaded["music_volume"]), 0.25, 0.0001)
	assert_true(loaded["muted"])
	assert_eq(loaded["sfx_enabled"], AudioSettings.DEFAULTS["sfx_enabled"], "kaydedilmeyen varsayılan kalır")


func _touch(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("x")
	file.close()


func _remove_dir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	DirAccess.remove_absolute(path)
