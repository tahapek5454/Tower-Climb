class_name MusicLibrary
extends RefCounted
## Oyuncunun müzik klasörü (sadece masaüstü; web'de müzik yok). Oyun müzik getirmez: oyuncu kendi
## parçalarını ekler (müzik klasörüne kopyalayarak ya da dosyaları oyun penceresine bırakarak).
## Desteklenen biçimler: mp3, ogg, wav (çalışma zamanında yüklenir; projeye gömülmez).

const SUPPORTED: PackedStringArray = ["mp3", "ogg", "wav"]

## Klasör (testlerde geçici bir klasörle değiştirilebilir).
## Windows'ta: %APPDATA%/Godot/app_userdata/Tower Climb/music
static var music_dir: String = "user://music"


## Bu platformda müzik var mı? (Web'de yok.)
static func is_available() -> bool:
	return not OS.has_feature("web")


static func ensure_dir() -> void:
	DirAccess.make_dir_recursive_absolute(music_dir)


## Klasörün işletim sistemindeki tam yolu (dosya gezgininde açmak için).
static func global_dir() -> String:
	return ProjectSettings.globalize_path(music_dir)


## Müzik klasörünü dosya gezgininde açar (oyuncu parçaları oraya kopyalar).
static func open_dir() -> void:
	ensure_dir()
	OS.shell_open(global_dir())


static func is_supported(file_name: String) -> bool:
	return SUPPORTED.has(file_name.get_extension().to_lower())


## Klasördeki desteklenen parçaların yolları, ada göre sıralı.
static func list_tracks() -> PackedStringArray:
	ensure_dir()
	var names: Array[String] = []
	for file_name: String in DirAccess.get_files_at(music_dir):
		if is_supported(file_name):
			names.append(file_name)
	names.sort_custom(func(a: String, b: String) -> bool: return a.naturalnocasecmp_to(b) < 0)
	var paths := PackedStringArray()
	for file_name: String in names:
		paths.append(music_dir.path_join(file_name))
	return paths


## Parçanın gösterilecek adı: uzantısız dosya adı, alt çizgiler boşluk.
static func title_of(path: String) -> String:
	return path.get_file().get_basename().replace("_", " ").strip_edges()


## Parçayı yükler; okunamazsa null.
static func load_stream(path: String) -> AudioStream:
	match path.get_extension().to_lower():
		"mp3": return AudioStreamMP3.load_from_file(path)
		"ogg": return AudioStreamOggVorbis.load_from_file(path)
		"wav": return AudioStreamWAV.load_from_file(path)
	return null


## Dışarıdaki dosyaları klasöre kopyalar. Desteklenmeyen ve aynı adla zaten var olanlar atlanır.
## Dönüş: kopyalanan dosya sayısı.
static func import_files(source_paths: PackedStringArray) -> int:
	ensure_dir()
	var copied: int = 0
	for source: String in source_paths:
		if not is_supported(source):
			continue
		var target: String = music_dir.path_join(source.get_file())
		if FileAccess.file_exists(target):
			continue
		if DirAccess.copy_absolute(source, target) == OK:
			copied += 1
	return copied
