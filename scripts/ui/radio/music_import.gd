class_name MusicImport
extends Node
## Oyuncunun müzik eklemesi (sadece masaüstü): "Müzik ekle" dosya seçicisi (birden çok parça),
## "Klasörü aç" (müzik klasörünü dosya gezgininde açar; oyuncu sürükle-bırak ile ekleyebilir) ve oyun
## penceresine bırakılan dosyalar. Eklenen parçalar MusicLibrary klasörüne kopyalanır, liste yenilenir.
## Dosya seçici açıkken oyun duraklar (karakter düşmesin). Pencereye dönülünce klasör yeniden taranır.

## Ekleme bitti: kopyalanan parça sayısı ve desteklenmeyen dosya sayısı.
signal imported(count: int, skipped: int)

var _dialog: FileDialog


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().files_dropped.connect(_import)


func _notification(what: int) -> void:
	# Oyuncu klasöre dışarıdan parça eklemiş olabilir: pencereye dönünce yeniden tara.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and AudioManager.music != null:
		AudioManager.music.rescan()


## Dosya seçiciyi açar (oyun duraklar).
func open_dialog() -> void:
	if _dialog == null:
		_dialog = FileDialog.new()
		_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
		_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_dialog.use_native_dialog = true
		_dialog.title = "Müzik ekle"
		_dialog.filters = PackedStringArray(["*.mp3, *.ogg, *.wav ; Müzik (mp3, ogg, wav)"])
		_dialog.files_selected.connect(_on_files_selected)
		_dialog.canceled.connect(_resume)
		add_child(_dialog)
	get_tree().paused = true
	_dialog.popup_centered_ratio(0.6)


## Müzik klasörünü dosya gezgininde açar.
func open_folder() -> void:
	MusicLibrary.ensure_dir()
	OS.shell_open(MusicLibrary.global_dir())


func _on_files_selected(paths: PackedStringArray) -> void:
	_resume()
	_import(paths)


## Dosya seçici kapandı: ağaç, akış durumunun gerektirdiği hâle döner (duraklatma menüsü açıksa donuk kalır).
func _resume() -> void:
	get_tree().paused = FlowRules.freezes_world(GameFlow.state)


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
