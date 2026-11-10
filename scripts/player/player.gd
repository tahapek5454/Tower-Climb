class_name Player
extends CharacterBody2D
## Karakterin fiziği: hareket, çarpışma, durum. Görüntüye dokunmaz; sadece sinyal yayınlar.
## Orijin ayakların ortasındadır.

signal state_changed(new_state: State, old_state: State)
## Olaylar: &"jumped" {speed, run_speed}, &"jump_cut" {}, &"landed" {speed}.
signal event(name: StringName, data: Dictionary)

enum State { IDLE, RUN, JUMP, FALL, LAND, WALL_BOUNCE, FLIP }

var state: State = State.IDLE

## Yerden ayrıldıktan sonra hâlâ zıplanabilecek kalan süre.
var _coyote_timer: float = 0.0
## Zıplama tuşuna basıldıktan sonra isteğin geçerli kaldığı süre.
var _jump_buffer_timer: float = 0.0
## Yükselirken tuş bırakılırsa hız bir kez kesilebilir.
var _can_cut_jump: bool = false


func _physics_process(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	_update_jump_timers(delta)
	_apply_horizontal(Input.get_axis(&"move_left", &"move_right"), delta)
	_apply_gravity(delta)
	_try_jump()
	_try_cut_jump()

	var fall_speed: float = velocity.y
	move_and_slide()

	if is_on_floor() and not was_on_floor:
		_can_cut_jump = false
		event.emit(&"landed", {"speed": fall_speed})
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


func _update_jump_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = Tuning.COYOTE_TIME
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_timer = Tuning.JUMP_BUFFER_TIME
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


## Tamponda zıplama isteği varsa ve yerdeysek (veya coyote süresi içindeysek) zıplar.
func _try_jump() -> void:
	if _jump_buffer_timer <= 0.0 or _coyote_timer <= 0.0:
		return
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_can_cut_jump = true
	var run_speed: float = absf(velocity.x)
	var jump_speed: float = jump_speed_for(run_speed)
	velocity.y = -jump_speed
	event.emit(&"jumped", {"speed": jump_speed, "run_speed": run_speed})


## Değişken zıplama: yükselirken tuş basılı değilse yukarı hız bir kez kesilir.
func _try_cut_jump() -> void:
	if not _can_cut_jump or Input.is_action_pressed(&"jump"):
		return
	_can_cut_jump = false
	if velocity.y < 0.0:
		velocity.y *= Tuning.JUMP_CUT_MULTIPLIER
		event.emit(&"jump_cut", {})


## Yatay hıza göre zıplama hızı: oyunun kalbi.
static func jump_speed_for(run_speed: float) -> float:
	return Tuning.JUMP_BASE + run_speed * Tuning.JUMP_SPEED_BONUS


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
