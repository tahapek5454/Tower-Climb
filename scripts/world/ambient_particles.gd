class_name AmbientParticles
extends Node2D
## Ortam parçacıkları (sadece görüntü): temaya göre toz zerreleri, uçuşan yapraklar, kar, ateş böcekleri.
## Her tür ayrı bir CPUParticles2D (Compatibility/web uyumlu). Yayıcılar görüntüyü kaplar ve kamerayı
## izler; parçacıklar dünyada kalır (local_coords kapalı) → kamera kayınca gerçek bir ortam gibi geçerler.
## Tema geçişinde türlerin görünürlüğü tema ağırlıklarıyla yumuşakça değişir (kind_weights).

## Her temanın parçacık türü (WorldPalette tema sırasıyla).
const THEME_KIND: Array[StringName] = [&"dust", &"leaves", &"dust", &"snow", &"fireflies"]
const KINDS: Array[StringName] = [&"dust", &"leaves", &"snow", &"fireflies"]

var _emitters: Dictionary = {}
var _theme := ThemeTracker.new()


## Tema konumuna göre her türün görünürlük ağırlığı (0..1; geçişte iki tür karışır). Saf.
static func kind_weights(theme_position: float) -> Dictionary:
	var weights: Dictionary = {}
	for kind: StringName in KINDS:
		weights[kind] = 0.0
	var count: int = THEME_KIND.size()
	var blend: float = theme_position - floorf(theme_position)
	var from: StringName = THEME_KIND[ThemeRules.theme_index(theme_position, count)]
	var to: StringName = THEME_KIND[ThemeRules.theme_index(theme_position + 1.0, count)]
	weights[from] += 1.0 - blend
	weights[to] += blend
	return weights


func _ready() -> void:
	_emitters[&"dust"] = AmbientParticleFactory.dust()
	_emitters[&"leaves"] = AmbientParticleFactory.leaves()
	_emitters[&"snow"] = AmbientParticleFactory.snow()
	_emitters[&"fireflies"] = AmbientParticleFactory.fireflies()
	for kind: StringName in KINDS:
		var emitter: CPUParticles2D = _emitters[kind]
		emitter.name = String(kind).capitalize()
		add_child(emitter)
	_apply_weights(kind_weights(0.0))


func _process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	var center: Vector2 = camera.get_screen_center_position()
	position = center
	if _theme.update(center.y):
		_apply_weights(kind_weights(_theme.theme_position))


func _apply_weights(weights: Dictionary) -> void:
	for kind: StringName in KINDS:
		var emitter: CPUParticles2D = _emitters[kind]
		var weight: float = weights[kind]
		emitter.emitting = weight > 0.01
		emitter.modulate.a = weight
