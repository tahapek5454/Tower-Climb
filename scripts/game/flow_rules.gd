class_name FlowRules
extends RefCounted
## Oyun akışının saf kuralları: hangi durumdan hangisine geçilebilir, hangi durumda oyun donar.
## MENU → PLAYING ⇄ PAUSED, PLAYING → GAME_OVER, PAUSED/GAME_OVER → MENU, GAME_OVER → PLAYING.
## REVIVE: oyuncu düştü, "elmasla devam" kartı bekliyor (dünya donuk): kabul → PLAYING, ret/süre → GAME_OVER.

enum State { MENU, PLAYING, PAUSED, GAME_OVER, REVIVE }

const TRANSITIONS: Dictionary = {
	State.MENU: [State.PLAYING],
	State.PLAYING: [State.PAUSED, State.GAME_OVER, State.REVIVE],
	State.PAUSED: [State.PLAYING, State.MENU],
	State.GAME_OVER: [State.PLAYING, State.MENU],
	State.REVIVE: [State.PLAYING, State.GAME_OVER],
}


static func can_transition(from: State, to: State) -> bool:
	return to in TRANSITIONS[from]


## Oyun dünyası (fizik, kamera, kombo süresi) bu durumda donar mı? Duraklatmada ve devam kartında.
## Menüde dünya canlı kalır (bulutlar, parçacıklar); oyuncuyu menü ekranı bekletir.
static func freezes_world(state: State) -> bool:
	return state == State.PAUSED or state == State.REVIVE


## Oyuncu karakteri bu durumda kontrol edilebilir mi?
static func accepts_player_input(state: State) -> bool:
	return state == State.PLAYING
