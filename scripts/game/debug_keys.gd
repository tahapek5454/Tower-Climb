class_name DebugKeys
extends Node
## Debug tuşları (yalnız oyun sürerken): F6 sonraki bölüme ışınlan; F7 roket, F8 kalp, F9 kum saati,
## F10 mıknatıs — oyuncunun üstündeki ilk platforma bir tane koyar. main kurar.

## Tuş eylemi → konacak toplanabilir.
const SPAWN_ACTIONS: Dictionary = {
	&"debug_spawn_jetpack": Pickup.JETPACK,
	&"debug_spawn_heart": Pickup.HEART,
	&"debug_spawn_hourglass": Pickup.HOURGLASS,
	&"debug_spawn_magnet": Pickup.MAGNET,
}

var player: Player
var camera: TowerCamera
var spawner: PlatformSpawner


func _unhandled_input(input_event: InputEvent) -> void:
	if not GameFlow.is_playing():
		return
	if input_event.is_action_pressed(&"debug_skip_section"):
		_skip_section()
		get_viewport().set_input_as_handled()
		return
	for action: StringName in SPAWN_ACTIONS:
		if input_event.is_action_pressed(action):
			spawner.debug_spawn(SPAWN_ACTIONS[action], player.global_position.y - Tuning.FLOOR_SPACING * 0.5)
			get_viewport().set_input_as_handled()
			return


## Oyuncuyu bir sonraki bölüm platformuna (tam genişlik, ortada) ışınlar; kamera başlangıçtaki gibi
## konumlanır. Temaları 100 kat tırmanmadan görmek için. Skor/kombo da atlar.
func _skip_section() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	var current: int = floori(ThemeRules.floor_value_at(player.position.y))
	var target: int = (floori(float(current) / interval) + 1) * interval
	spawner.spawn_through_floor(target)
	var target_y: float = PlatformRules.floor_y(target)
	player.position = Vector2(0.0, target_y)
	player.velocity = Vector2.ZERO
	camera.position.y = target_y + Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT * 0.5
