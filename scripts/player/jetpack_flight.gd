class_name JetpackFlight
extends RefCounted
## Tek bir roket uçuşunun hareket kuralları (Player kullanır; sahneye dokunmaz, test edilebilir).
## Evreler: BOOST (süre boyunca hızla yukarı; oyuncu sağa/sola kayabilir) → APPROACH (roket oyuncuyu
## seçilen platformun üstüne taşır; tuşlar devre dışı) → DONE (bırakıldı).

enum Phase { BOOST, APPROACH, DONE }

var phase: Phase = Phase.BOOST
## BOOST evresinde geçen süre (s).
var elapsed: float = 0.0
## İnilecek platform (JetpackRules biçimi); APPROACH'ta geçerli.
var landing: Vector3 = JetpackRules.NO_LANDING
var _approach_time: float = 0.0


func is_done() -> bool:
	return phase == Phase.DONE


func fuel_ratio() -> float:
	return JetpackRules.fuel_ratio(elapsed)


## Bir fizik adımı: yeni hızı döndürür. input_dir: -1..1 (sol/sağ).
## platforms_above: Callable(y: float) -> Array[Vector3]; verilen y'nin üstündeki platformlar
## (aşağıdan yukarıya). Sadece süre dolduğunda bir kez çağrılır.
func step(position: Vector2, velocity: Vector2, input_dir: float, delta: float,
		platforms_above: Callable) -> Vector2:
	match phase:
		Phase.BOOST:
			return _boost(position, velocity, input_dir, delta, platforms_above)
		Phase.APPROACH:
			return _approach(position, delta)
	return velocity


func _boost(position: Vector2, velocity: Vector2, input_dir: float, delta: float,
		platforms_above: Callable) -> Vector2:
	elapsed += delta
	var result := Vector2(
		move_toward(velocity.x, input_dir * Tuning.JETPACK_STEER_SPEED, Tuning.JETPACK_STEER_ACCEL * delta),
		move_toward(velocity.y, -Tuning.JETPACK_SPEED, Tuning.JETPACK_ACCEL * delta))
	if elapsed >= Tuning.JETPACK_FLIGHT_TIME:
		_begin_approach(position, platforms_above)
	return result


func _begin_approach(position: Vector2, platforms_above: Callable) -> void:
	var platforms: Array[Vector3] = []
	if platforms_above.is_valid():
		platforms = platforms_above.call(position.y)
	landing = JetpackRules.pick_landing(position, platforms)
	phase = Phase.APPROACH if JetpackRules.has_landing(landing) else Phase.DONE


## Hedef noktaya (platformun üstü) yumuşakça yavaşlayarak gider; varınca biter.
func _approach(position: Vector2, delta: float) -> Vector2:
	_approach_time += delta
	var target := Vector2(JetpackRules.landing_x(position.x, landing), JetpackRules.release_y(landing))
	var offset: Vector2 = target - position
	var tolerance: float = Tuning.JETPACK_RELEASE_TOLERANCE
	if (absf(offset.x) <= tolerance and absf(offset.y) <= tolerance) \
			or _approach_time >= Tuning.JETPACK_APPROACH_TIMEOUT:
		phase = Phase.DONE
		return Vector2.ZERO
	var gain: float = Tuning.JETPACK_APPROACH_GAIN
	return Vector2(
		clampf(offset.x * gain, -Tuning.JETPACK_ALIGN_SPEED, Tuning.JETPACK_ALIGN_SPEED),
		clampf(offset.y * gain, -Tuning.JETPACK_APPROACH_SPEED, Tuning.JETPACK_APPROACH_SPEED))
