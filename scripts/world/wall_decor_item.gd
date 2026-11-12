class_name WallDecorItem
extends Node2D
## Tek bir duvar süsü. Hareketli olanlar (meşale alevi, sancak, flama) her karede yeniden çizilir;
## pencere bir kez. Işıklar PlatformGlow çocuğuna verilir.

const ANIMATED: Array[StringName] = [&"torch", &"banner", &"bunting"]

var _kind: StringName
var _theme: int = 0
var _seed: int = 0
var _span: float = 0.0
var _time: float = 0.0
var _glow: PlatformGlow
var _lights_set: bool = false


## add_child'dan önce çağrılır (WallDecorRules.slot_item sözlüğü).
func setup(item: Dictionary) -> void:
	_kind = item[&"kind"]
	_theme = item[&"theme"]
	_seed = item[&"seed"]
	_span = item[&"span"]
	_time = float(_seed % 97)
	_glow = PlatformGlow.new()
	_glow.name = "Glow"
	add_child(_glow)
	set_process(ANIMATED.has(_kind))


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_seed * 131 + 17)
	var lights: Array = []
	match _kind:
		&"torch": WallDecorArt.torch(self, _time, float(_seed), lights)
		&"window": WallDecorArt.window(self, _theme, rng, lights)
		&"banner": WallDecorArt.banner(self, _theme, rng, _time, lights)
		&"bunting": WallDecorArt.bunting(self, _theme, _span, rng, _time, lights)
	# Meşale ve pencere ışığı bir kez verilir (meşaleninki titrer); ampuller her karede nabız gibi atar.
	if lights.is_empty():
		return
	if _kind == &"bunting" or not _lights_set:
		_lights_set = true
		_glow.set_lights(lights, _kind == &"torch", float(_seed))
