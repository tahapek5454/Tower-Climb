extends GutTest
## Oyun akışı kuralları (FlowRules) ve GameFlow geçişleri.

const GameFlowScript: GDScript = preload("res://scripts/autoload/game_flow.gd")
const S := FlowRules.State


func test_every_state_has_transition_entry() -> void:
	for state: int in S.values():
		assert_true(FlowRules.TRANSITIONS.has(state), "geçiş tablosunda yok: %d" % state)


func test_allowed_transitions() -> void:
	assert_true(FlowRules.can_transition(S.MENU, S.PLAYING))
	assert_true(FlowRules.can_transition(S.PLAYING, S.PAUSED))
	assert_true(FlowRules.can_transition(S.PAUSED, S.PLAYING))
	assert_true(FlowRules.can_transition(S.PAUSED, S.MENU))
	assert_true(FlowRules.can_transition(S.PLAYING, S.GAME_OVER))
	assert_true(FlowRules.can_transition(S.GAME_OVER, S.PLAYING))
	assert_true(FlowRules.can_transition(S.GAME_OVER, S.MENU))
	assert_true(FlowRules.can_transition(S.PLAYING, S.REVIVE), "düşünce devam kartı")
	assert_true(FlowRules.can_transition(S.REVIVE, S.PLAYING), "kabul: oyun sürer")
	assert_true(FlowRules.can_transition(S.REVIVE, S.GAME_OVER), "ret / süre doldu")


func test_forbidden_transitions() -> void:
	assert_false(FlowRules.can_transition(S.MENU, S.PAUSED), "menüden duraklatılamaz")
	assert_false(FlowRules.can_transition(S.MENU, S.GAME_OVER))
	assert_false(FlowRules.can_transition(S.PAUSED, S.GAME_OVER), "duraklatılmışken oyun bitmez")
	assert_false(FlowRules.can_transition(S.GAME_OVER, S.PAUSED))
	assert_false(FlowRules.can_transition(S.PLAYING, S.MENU), "oyundan önce duraklatılır")
	assert_false(FlowRules.can_transition(S.REVIVE, S.PAUSED), "devam kartında duraklatma yok")
	assert_false(FlowRules.can_transition(S.REVIVE, S.MENU))
	assert_false(FlowRules.can_transition(S.PAUSED, S.REVIVE))
	assert_false(FlowRules.can_transition(S.MENU, S.REVIVE))
	assert_false(FlowRules.can_transition(S.GAME_OVER, S.REVIVE))
	for state: int in S.values():
		assert_false(FlowRules.can_transition(state, state), "aynı duruma geçiş yok")


func test_pause_and_revive_freeze_world() -> void:
	assert_true(FlowRules.freezes_world(S.PAUSED))
	assert_true(FlowRules.freezes_world(S.REVIVE), "devam kartı beklerken dünya donar")
	for state: int in [S.MENU, S.PLAYING, S.GAME_OVER]:
		assert_false(FlowRules.freezes_world(state))


func test_only_playing_accepts_player_input() -> void:
	assert_true(FlowRules.accepts_player_input(S.PLAYING))
	for state: int in [S.MENU, S.PAUSED, S.GAME_OVER, S.REVIVE]:
		assert_false(FlowRules.accepts_player_input(state))


func test_game_flow_follows_rules_and_announces() -> void:
	var flow: Node = GameFlowScript.new()
	add_child_autofree(flow)
	var seen: Array = []
	var listener: Callable = func(new_state: int, old_state: int) -> void: seen.append([new_state, old_state])
	Events.flow_changed.connect(listener)
	assert_eq(flow.state, S.MENU, "oyun menüyle açılır")
	assert_false(flow.request(S.PAUSED), "menüden duraklatılamaz")
	assert_true(flow.request(S.PLAYING))
	assert_false(flow.request(S.MENU), "oyundan doğrudan menüye geçilemez")
	assert_true(flow.request(S.PAUSED))
	assert_true(get_tree().paused, "duraklatınca ağaç donar")
	assert_true(flow.request(S.PLAYING))
	assert_false(get_tree().paused)
	Events.flow_changed.disconnect(listener)
	assert_eq(seen, [[S.PLAYING, S.MENU], [S.PAUSED, S.PLAYING], [S.PLAYING, S.PAUSED]])
	assert_true(flow.is_playing())
