class_name FlowRules
extends RefCounted
## Oyun akışının saf kuralları: hangi durumdan hangisine geçilebilir, hangi durumda oyun donar.
## MENU → PLAYING ⇄ PAUSED, PLAYING → GAME_OVER, PAUSED/GAME_OVER → MENU, GAME_OVER → PLAYING.

enum State { MENU, PLAYING, PAUSED, GAME_OVER }

const TRANSITIONS: Dictionary = {
	State.MENU: [State.PLAYING],
	State.PLAYING: [State.PAUSED, State.GAME_OVER],
	State.PAUSED: [State.PLAYING, State.MENU],
	State.GAME_OVER: [State.PLAYING, State.MENU],
}


static func can_transition(from: State, to: State) -> bool:
	return to in TRANSITIONS[from]


## Oyun dünyası (fizik, kamera, kombo süresi) bu durumda donar mı? Sadece duraklatmada.
## Menüde dünya canlı kalır (bulutlar, parçacıklar); oyuncuyu menü ekranı bekletir.
static func freezes_world(state: State) -> bool:
	return state == State.PAUSED


## Oyuncu karakteri bu durumda kontrol edilebilir mi?
static func accepts_player_input(state: State) -> bool:
	return state == State.PLAYING
