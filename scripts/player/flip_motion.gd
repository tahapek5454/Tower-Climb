class_name FlipMotion
extends RefCounted
## Takla hareketi (görsel): ekran düzleminde dönüş (Spin.rotation: öne takla) ve
## silindirik dönüş (twist açısı: model dikey ekseninde döner, gövde dik kalır).
## Tween'leri sahibinin (PlayerVisual) üzerinde kurar; twist açısını geri çağırımla bildirir.

## Silindirik dönüşün o anki açısı (radyan; 0 = dönüş yok).
var twist: float = 0.0

var _owner: Node
var _spin: Node2D
var _on_twist: Callable
var _tween: Tween


## owner: tween'i taşıyan düğüm; spin: döndürülen gövde; on_twist: func(angle: float).
func _init(owner: Node, spin: Node2D, on_twist: Callable) -> void:
	_owner = owner
	_spin = spin
	_on_twist = on_twist


func is_running() -> bool:
	return _tween != null and _tween.is_running()


## Taklayı başlatır. style: FlipRules çeşidi; direction: gidilen yön (+1 sağ); duration: saniye.
## Öteki eksende yarım kalmış dönüş varsa hızla dik konuma toplanır.
## facing: başlarken bakılan yön (yön değişecekse burgu yön dönüşüyle aynı yönde döner).
func start(style: StringName, direction: float, duration: float, facing: float = 0.0) -> void:
	_kill()
	var spin_from: float = wrapf(_spin.rotation, -PI, PI)
	_spin.rotation = spin_from
	var twist_from: float = wrapf(twist, -PI, PI)
	_set_twist(twist_from)
	_tween = _owner.create_tween().set_parallel(true)
	if style == FlipRules.TWIST:
		var turns: int = FlipRules.turns_for(duration, Tuning.FLIP_TWIST_TURN_TIME)
		# Bitiş tam tura denk gelir: model yine yön görünümünde durur.
		var twist_to: float = FlipRules.twist_direction(direction, facing) * turns * TAU
		_tween.tween_method(_set_twist, twist_from, twist_to, duration) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_spin, ^"rotation", 0.0, Tuning.FLIP_LAND_RESET_TIME)
	else:
		var turns: int = FlipRules.turns_for(duration)
		var spin_to: float = spin_from + direction * turns * TAU
		_tween.tween_property(_spin, ^"rotation", spin_to, duration) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_method(_set_twist, twist_from, 0.0, Tuning.FLIP_LAND_RESET_TIME)


## İnişte (ya da roket takılınca): takla bitmediyse iki eksen de en yakın dik konuma hızla döner.
func settle() -> void:
	_kill()
	var spin_angle: float = wrapf(_spin.rotation, -PI, PI)
	_spin.rotation = spin_angle
	var twist_angle: float = wrapf(twist, -PI, PI)
	_set_twist(twist_angle)
	if is_zero_approx(spin_angle) and is_zero_approx(twist_angle):
		return
	_tween = _owner.create_tween().set_parallel(true)
	_tween.tween_property(_spin, ^"rotation", 0.0, Tuning.FLIP_LAND_RESET_TIME)
	_tween.tween_method(_set_twist, twist_angle, 0.0, Tuning.FLIP_LAND_RESET_TIME)


func _set_twist(angle: float) -> void:
	twist = angle
	_on_twist.call(angle)


func _kill() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
