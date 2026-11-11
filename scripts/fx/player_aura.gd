class_name PlayerAura
extends Sprite2D
## Karakterin arkasındaki yumuşak ışık hâlesi ("sahte glow"): toplamalı karışımlı yumuşak daire.
## Dururken çok hafif, hızlanınca belirgin; kombo sürerken altın sarısına döner. Geçişler yumuşak.

const IDLE_COLOR := Color(1.0, 0.55, 0.2)
const COMBO_COLOR := Color(1.0, 0.85, 0.35)

var player: Player

## 0 = turuncu, 1 = kombo rengi.
var _combo_mix: float = 0.0
var _alpha: float = Tuning.GLOW_AURA_ALPHA_IDLE


## Hedef parlaklık: kombo > hızlı > durgun.
static func target_alpha(speed: float, combo_active: bool) -> float:
	if combo_active:
		return Tuning.GLOW_AURA_ALPHA_COMBO
	if speed >= Tuning.TRAIL_MIN_SPEED:
		return Tuning.GLOW_AURA_ALPHA_FAST
	return Tuning.GLOW_AURA_ALPHA_IDLE


func _ready() -> void:
	texture = SoftTextures.dot()
	material = SoftTextures.additive()
	scale = Vector2.ONE * (Tuning.GLOW_AURA_SIZE / SoftTextures.DOT_SIZE)
	position = Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)
	_apply()


func _process(delta: float) -> void:
	var combo_active: bool = GameState.combo_jumps > 0
	var weight: float = 1.0 - exp(-Tuning.GLOW_AURA_SMOOTHING * delta)
	_alpha = lerpf(_alpha, target_alpha(player.velocity.length(), combo_active), weight)
	_combo_mix = lerpf(_combo_mix, 1.0 if combo_active else 0.0, weight)
	_apply()


func current_alpha() -> float:
	return _alpha


func _apply() -> void:
	modulate = Color(IDLE_COLOR.lerp(COMBO_COLOR, _combo_mix), _alpha)
