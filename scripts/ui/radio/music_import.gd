class_name MusicImport
extends Node
## Oyuncunun müzik eklemesi (sadece masaüstü): "Klasörü aç" (müzik klasörünü dosya gezgininde açar;
## oyuncu dosyaları oraya kopyalar) ve oyun penceresine bırakılan dosyalar. Eklenen parçalar
## MusicLibrary klasörüne kopyalanır, liste yenilenir. Pencereye dönülünce klasör yeniden taranır.
## Dosya seçici yok (oyunu bozuyordu; kullanıcı kararıyla kaldırıldı).

## Ekleme bitti: kopyalanan parça sayısı ve desteklenmeyen dosya sayısı.
signal imported(count: int, skipped: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().files_dropped.connect(_import)


func _notification(what: int) -> void:
	# Oyuncu klasöre dışarıdan parça eklemiş olabilir: pencereye dönünce yeniden tara.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and AudioManager.music != null:
		AudioManager.music.rescan()


## Müzik klasörünü dosya gezgininde açar.
func open_folder() -> void:
	MusicLibrary.open_dir()


func _import(paths: PackedStringArray) -> void:
	var count: int = MusicLibrary.import_files(paths)
	var skipped: int = 0
	for path: String in paths:
		if not MusicLibrary.is_supported(path):
			skipped += 1
	var music: MusicPlayer = AudioManager.music
	var was_empty: bool = music.playlist.is_empty()
	music.rescan()
	if was_empty and count > 0:
		music.play()
	imported.emit(count, skipped)
