class_name PauseController
extends Node
## Duraklatma düzenleyicisi: Esc (veya pencere odağı kaybı, ayardan kapatılabilir) oyunu duraklatır,
## PauseMenu'yü açar; "Devam" menüyü kapatıp 3-2-1 saydıktan sonra oyunu sürdürür. Esc menüdeyken de
## devam eder. Ana menüye dönüş isteği main_menu_requested ile main'e iletilir.
## Dosya seçici gibi başka bir yer ağacı zaten dondurduysa (paused) odak kaybı duraklatma açmaz.

signal main_menu_requested

var _menu: PauseMenu
var _countdown: ResumeCountdown
var _resuming: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_menu = PauseMenu.new()
	_menu.name = "PauseMenu"
	_menu.resume_requested.connect(_resume)
	_menu.back_requested.connect(_resume)
	_menu.menu_requested.connect(func() -> void: main_menu_requested.emit())
	add_child(_menu)
	_countdown = ResumeCountdown.new()
	_countdown.name = "ResumeCountdown"
	add_child(_countdown)
	Events.flow_changed.connect(_on_flow_changed)


## Duraklatma menüsü (ayarlar ekranını bağlamak için).
func get_menu() -> PauseMenu:
	return _menu


func _unhandled_input(input_event: InputEvent) -> void:
	if not input_event.is_action_pressed(&"pause"):
		return
	if GameFlow.is_playing():
		get_viewport().set_input_as_handled()
		GameFlow.request(FlowRules.State.PAUSED)
	elif GameFlow.state == FlowRules.State.PAUSED and _menu.is_open:
		get_viewport().set_input_as_handled()
		_resume()


func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_FOCUS_OUT:
		return
	if GameFlow.is_playing() and not get_tree().paused and GameSettings.get_setting("pause_on_focus_loss"):
		GameFlow.request(FlowRules.State.PAUSED)


func _resume() -> void:
	if _resuming or GameFlow.state != FlowRules.State.PAUSED:
		return
	_resuming = true
	_menu.close()
	await _countdown.run()
	GameFlow.request(FlowRules.State.PLAYING)
	_resuming = false


func _on_flow_changed(new_state: int, _old_state: int) -> void:
	if new_state == FlowRules.State.PAUSED:
		_menu.open()
	elif _menu.is_open:
		_menu.close()
