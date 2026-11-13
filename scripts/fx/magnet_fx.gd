class_name MagnetFx
extends Node2D
## Mıknatıs etkisi sürerken oyuncunun çevresinde yumuşak, nabız gibi atan silik halka ve dışarıdan içeri
## doğru daralan ince çekim halkaları (toplamalı ışık). Events.powerup_started/ended dinler; oyuncuyu izler.
## Oyuncunun Visual katmanına dokunmaz: dünyada ayrı bir düğümdür.

const FADE_IN_TIME: float = 0.35
const FADE_OUT_TIME: float = 0.6
## Halkanın nabız genliği (yarıçap oranı), kalın yumuşak hâlenin kalınlığı ve ince çizginin kalınlığı (px).
const PULSE_AMOUNT: float = 0.08
const SOFT_WIDTH: float = 12.0
const LINE_WIDTH: float = 2.5
## Daralan çekim halkaları: sayı, başlangıç yarıçapı (aura yarıçapına oran), döngü süresi (s).
const INWARD_COUNT: int = 2
const INWARD_FROM: float = 2.1
const INWARD_CYCLE: float = 1.15
## Son saniyelerde nabız hızlanır (etki bitiyor uyarısı): süre (s) ve hız çarpanı.
const WARN_TIME: float = 1.5
const WARN_SPEED: float = 2.2
const COLOR := Color(0.98, 0.72, 0.68)
const SEGMENTS: int = 48

var player: Node2D
var _strength: float = 0.0
var _time: float = 0.0
var _left: float = 0.0
var _fade: Tween


func _ready() -> void:
	top_level = true
	material = SoftTextures.additive()
	visible = false
	Events.powerup_started.connect(_on_powerup_started)
	Events.powerup_ended.connect(_on_powerup_ended)


func _process(delta: float) -> void:
	if not visible:
		return
	_left -= delta
	_time += delta * (WARN_SPEED if _left < WARN_TIME else 1.0)
	if player != null and is_instance_valid(player):
		global_position = player.global_position + MagnetField.pull_offset()
	queue_redraw()


func _draw() -> void:
	var radius: float = Tuning.MAGNET_AURA_RADIUS
	var alpha: float = Tuning.MAGNET_AURA_ALPHA * _strength
	var beat: float = 0.5 + 0.5 * sin(TAU * _time / Tuning.MAGNET_AURA_PULSE_TIME)
	var r: float = radius * (1.0 + PULSE_AMOUNT * beat)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, SEGMENTS, Color(COLOR, alpha * 0.35), SOFT_WIDTH, true)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, SEGMENTS, Color(COLOR, alpha * (0.7 + 0.3 * beat)), LINE_WIDTH, true)
	for i: int in INWARD_COUNT:
		var t: float = fmod(_time / INWARD_CYCLE + float(i) / INWARD_COUNT, 1.0)
		var inward: float = radius * lerpf(INWARD_FROM, 1.05, t * t)
		draw_arc(Vector2.ZERO, inward, 0.0, TAU, SEGMENTS, Color(COLOR, alpha * 0.8 * sin(t * PI)), 1.8, true)


func _on_powerup_started(kind: StringName, duration: float) -> void:
	if kind != Pickup.MAGNET:
		return
	_left = duration
	visible = true
	_fade_to(1.0, FADE_IN_TIME)


func _on_powerup_ended(kind: StringName) -> void:
	if kind == Pickup.MAGNET:
		_fade_to(0.0, FADE_OUT_TIME).tween_callback(hide)


func _fade_to(strength: float, time: float) -> Tween:
	if _fade != null:
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(self, ^"_strength", strength, time)
	return _fade
