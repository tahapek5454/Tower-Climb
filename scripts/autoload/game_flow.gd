extends Node
## Oyun akışı (autoload): MENU, PLAYING, PAUSED, GAME_OVER, REVIVE (devam kartı; dünya donar). Geçiş kuralları FlowRules'ta (saf).
## Durum değişince Events.flow_changed yayınlanır; duraklatmada ağaç donar (arayüz ekranları
## PROCESS_MODE_ALWAYS olduğu için çalışmaya devam eder). Oyun bitince Events.game_over'ı dinleyip
## kendiliğinden GAME_OVER'a geçer.

## Oyun ana menüyle açılır.
var state: FlowRules.State = FlowRules.State.MENU


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.game_over.connect(_on_game_over)


## Geçiş izinliyse durumu değiştirir ve true döner; değilse hiçbir şey yapmaz.
func request(new_state: FlowRules.State) -> bool:
	if not FlowRules.can_transition(state, new_state):
		return false
	var old_state: FlowRules.State = state
	state = new_state
	get_tree().paused = FlowRules.freezes_world(new_state)
	Events.flow_changed.emit(new_state, old_state)
	return true


func is_playing() -> bool:
	return state == FlowRules.State.PLAYING


func _on_game_over(_final_score: int, _final_floor: int) -> void:
	request(FlowRules.State.GAME_OVER)
