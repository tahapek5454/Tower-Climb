class_name Player
extends CharacterBody2D
## Karakterin fiziği: hareket, çarpışma, durum. Görüntüye dokunmaz; sadece sinyal yayınlar.
## Orijin ayakların ortasındadır.

signal state_changed(new_state: State, old_state: State)
@warning_ignore("unused_signal")
signal event(name: StringName, data: Dictionary)

enum State { IDLE, RUN, JUMP, FALL, LAND, WALL_BOUNCE, FLIP }

var state: State = State.IDLE


func _physics_process(delta: float) -> void:
	var input_dir: float = Input.get_axis(&"move_left", &"move_right")
	_apply_horizontal(input_dir, delta)
	_apply_gravity(delta)
	move_and_slide()
	_update_state()


func _apply_horizontal(input_dir: float, delta: float) -> void:
	if is_on_floor():
		velocity.x = _ground_velocity(velocity.x, input_dir, delta)
	elif input_dir != 0.0:
		# Havada sürtünme yok; momentum korunur, kontrol zayıftır.
		velocity.x = move_toward(velocity.x, input_dir * Tuning.MAX_RUN_SPEED, Tuning.AIR_ACCEL * delta)


func _ground_velocity(vx: float, input_dir: float, delta: float) -> float:
	if input_dir == 0.0:
		return move_toward(vx, 0.0, Tuning.GROUND_FRICTION * delta)
	var rate: float = Tuning.GROUND_ACCEL
	# Ters yöne basılınca sürtünme de yardım eder: daha keskin dönüş.
	if signf(vx) == -signf(input_dir):
		rate += Tuning.GROUND_FRICTION
	return move_toward(vx, input_dir * Tuning.MAX_RUN_SPEED, rate * delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	velocity.y = minf(velocity.y + Tuning.GRAVITY * delta, Tuning.MAX_FALL_SPEED)


func _update_state() -> void:
	if not is_on_floor():
		_set_state(State.JUMP if velocity.y < 0.0 else State.FALL)
	elif absf(velocity.x) > Tuning.RUN_STATE_MIN_SPEED:
		_set_state(State.RUN)
	else:
		_set_state(State.IDLE)


func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	var old_state: State = state
	state = new_state
	state_changed.emit(new_state, old_state)
