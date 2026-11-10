extends Node
## Pencere modu yönetimi: tam ekran aç/kapat (F11 veya Alt+Enter).
## Oyun büyütülmüş pencerede başlar (project.godot: display/window/size/mode).
## Aşama 5'teki ayarlar menüsü de burayı kullanacak.

## Tam ekrandan çıkınca dönülecek mod.
var _windowed_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_MAXIMIZED


func _ready() -> void:
	# Duraklatılmışken de çalışsın.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_fullscreen"):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()


func is_fullscreen() -> bool:
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
			or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func set_fullscreen(enabled: bool) -> void:
	if enabled == is_fullscreen():
		return
	if enabled:
		_windowed_mode = DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(_windowed_mode)


func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen())
