class_name PlatformGlow
extends Node2D
## Platformun ışık hâleleri ("sahte ışık"): toplamalı karışımla çizilen yumuşak daireler.
## Light2D kullanılmaz (Compatibility/web renderer'da pahalı; karakter unshaded).
## Işıklar PlatformVisual çizilirken toplanır ve set_lights ile verilir. Fenerler hafifçe titreşir.

## Her ışık: [konum (Vector2), boyut (float ya da Vector2), renk (alfa = parlaklık)].
var _lights: Array = []
var _phase: float = 0.0
var _time: float = 0.0


func _init() -> void:
	material = SoftTextures.additive()
	set_process(false)


## Işıkları ayarlar. flicker: hafif titreşim (fener gibi alev ışıkları).
func set_lights(lights: Array, flicker: bool, phase: float) -> void:
	_lights = lights
	_phase = phase
	set_process(flicker and not lights.is_empty())
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var wave: float = sin(_time * Tuning.LIGHT_FLICKER_SPEED + _phase) \
			+ 0.5 * sin(_time * Tuning.LIGHT_FLICKER_SPEED * 2.3 + _phase * 1.7)
	modulate.a = 1.0 + wave * Tuning.LIGHT_FLICKER_AMOUNT / 1.5


func _draw() -> void:
	var texture: Texture2D = SoftTextures.dot()
	for light: Array in _lights:
		var size: Vector2 = light[1] if light[1] is Vector2 else Vector2.ONE * float(light[1])
		draw_texture_rect(texture, Rect2((light[0] as Vector2) - size * 0.5, size), false, light[2])
