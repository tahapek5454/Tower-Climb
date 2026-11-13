class_name Player
extends CharacterBody2D
## Karakterin fiziği: hareket, çarpışma, durum. Görüntüye dokunmaz; sadece sinyal yayınlar.
## Orijin ayakların ortasındadır.

signal state_changed(new_state: State, old_state: State)
## Olaylar: &"jumped" {speed, run_speed}, &"jump_cut" {}, &"landed" {speed, floor},
## &"wall_bounce" {speed, normal_x, airborne}, &"jetpack_started" {duration}, &"jetpack_ended" {},
## &"rescued" {} (kalple ölümden kurtuldu; hemen ardından jetpack_started gelir).
signal event(name: StringName, data: Dictionary)

enum State { IDLE, RUN, JUMP, FALL, LAND, WALL_BOUNCE, FLIP }

var state: State = State.IDLE
## Roket süresi dolunca inilecek platformu bulmak için: Callable(y: float) -> Array[Vector3]
## (JetpackRules biçimi). Ana sahne bağlar; oyuncu platform üreticisini tanımaz.
var platforms_above: Callable

## Yerden ayrıldıktan sonra hâlâ zıplanabilecek kalan süre.
var _coyote_timer: float = 0.0
## Zıplama tuşuna basıldıktan sonra isteğin geçerli kaldığı süre.
var _jump_buffer_timer: float = 0.0
## Yükselirken tuş bırakılırsa hız bir kez kesilebilir.
var _can_cut_jump: bool = false
## Süren roket uçuşu (yoksa null). Uçarken normal hareket (yerçekimi, zıplama, duvar sekmesi) kapalı.
var _flight: JetpackFlight


func _physics_process(delta: float) -> void:
	if _flight != null:
		_fly(delta)
		return
	var was_on_floor: bool = is_on_floor()
	_update_jump_timers(delta)
	var input_dir: float = Input.get_axis(&"move_left", &"move_right") if _controls_enabled() else 0.0
	_apply_horizontal(input_dir, delta)
	_apply_gravity(delta)
	_try_jump()
	_try_cut_jump()

	var fall_speed: float = velocity.y
	var impact_vx: float = velocity.x
	move_and_slide()
	_try_wall_bounce(impact_vx)

	if is_on_floor() and not was_on_floor:
		_can_cut_jump = false
		event.emit(&"landed", {"speed": fall_speed, "floor": _floor_number_below()})
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

	if _controls_enabled() and Input.is_action_just_pressed(&"jump"):
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


## Kendiliğinden küçük zıplama (menüde, oyuncu kontrolü yokken canlılık için). Yerde değilse yok sayılır.
func hop(speed: float) -> void:
	if not is_on_floor():
		return
	velocity.y = -speed
	event.emit(&"jumped", {"speed": speed, "run_speed": 0.0})


# --- Roket ---

## Roketi takar ve uçuşu başlatır (uçarken yeniden alınırsa süre baştan başlar).
func start_jetpack(duration: float = Tuning.JETPACK_FLIGHT_TIME) -> void:
	_flight = JetpackFlight.new(duration)
	_can_cut_jump = false
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	event.emit(&"jetpack_started", {"duration": duration})


## Kalple kurtarma: düşen oyuncu verilen yükseklikte (ayaklar) durdurulur ve kısa bir roket uçuşu başlar.
func rescue(feet_y: float) -> void:
	global_position.y = feet_y
	velocity = Vector2.ZERO
	event.emit(&"rescued", {})
	start_jetpack(Tuning.HEART_RESCUE_FLIGHT_TIME)


func is_flying() -> bool:
	return _flight != null


## Roketin kalan yakıt oranı (0..1); uçmuyorsa 0.
func jetpack_fuel_ratio() -> float:
	return _flight.fuel_ratio() if _flight != null else 0.0


## Roket itişi tükendi mi (platforma taşınma evresi)? Görüntü alevi kısar.
func is_jetpack_landing() -> bool:
	return _flight != null and _flight.phase == JetpackFlight.Phase.APPROACH


## Uçuş adımı: hızı JetpackFlight belirler; bitince oyuncu platformun üstünde küçük bir sıçrayışla bırakılır.
func _fly(delta: float) -> void:
	var input_dir: float = Input.get_axis(&"move_left", &"move_right") if _controls_enabled() else 0.0
	velocity = _flight.step(global_position, velocity, input_dir, delta, platforms_above)
	move_and_slide()
	if _flight.is_done():
		_flight = null
		velocity = Vector2(0.0, -Tuning.JETPACK_RELEASE_HOP_SPEED)
		event.emit(&"jetpack_ended", {})
	_update_state()


## Oyuncu tuşları sadece oyun sürerken çalışır (menüde, duraklatmada kapalı).
func _controls_enabled() -> bool:
	return FlowRules.accepts_player_input(GameFlow.state)


## Değişken zıplama: yükselirken tuş basılı değilse yukarı hız bir kez kesilir.
func _try_cut_jump() -> void:
	if not _can_cut_jump or Input.is_action_pressed(&"jump"):
		return
	_can_cut_jump = false
	if velocity.y < 0.0:
		velocity.y *= Tuning.JUMP_CUT_MULTIPLIER
		event.emit(&"jump_cut", {})


## Üstünde durulan katın numarası; platform değilse (zemin) 0.
func _floor_number_below() -> int:
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var platform := collision.get_collider() as Platform
		if platform != null and collision.get_normal().y < 0.0:
			return platform.floor_number
	return 0


## Duvara yeterince hızlı çarpıldıysa yatay hızı ters çevirir; havadaysa yukarı iter.
## impact_vx: çarpışmadan önceki yatay hız (move_and_slide çarpınca sıfırlar).
func _try_wall_bounce(impact_vx: float) -> void:
	if not is_on_wall() or absf(impact_vx) < Tuning.WALL_BOUNCE_MIN_SPEED:
		return
	var normal_x: float = get_wall_normal().x
	# Sadece duvara doğru giderken sek.
	if normal_x * impact_vx >= 0.0:
		return
	velocity.x = -impact_vx * Tuning.WALL_BOUNCE_DAMPING
	var airborne: bool = not is_on_floor()
	if airborne:
		velocity.y -= Tuning.WALL_BOUNCE_UP_BOOST
	event.emit(&"wall_bounce", {"speed": absf(impact_vx), "normal_x": normal_x, "airborne": airborne})


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
