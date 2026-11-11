class_name CameraShake
extends RefCounted
## Ekran sarsıntısı: birikip azalan "trauma" ve yumuşak gürültüden kaydırma.
## Rastgele titreme yerine akıcı gürültü (FastNoiseLite) izlenir → sert değil, dalgalı his.
## Saf mantık (zaman dışarıdan verilir), test edilebilir.

## y ekseni gürültüsünü x'ten ayırmak için gürültüde uzak bir nokta.
const NOISE_Y_OFFSET: float = 1000.0
## Yumuşak gürültü pratikte yaklaşık ±0,6 üretir; tam ±1 aralığına ölçeklemek için.
const NOISE_GAIN: float = 1.7

## 0..1; olaylar ekler, zamanla azalır.
var trauma: float = 0.0

var _noise := FastNoiseLite.new()
var _time: float = 0.0


func _init(noise_seed: int = 0) -> void:
	_noise.seed = noise_seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	_noise.frequency = 1.0


func add(amount: float) -> void:
	trauma = clampf(trauma + maxf(amount, 0.0), 0.0, 1.0)


## Etki gücü: trauma²; küçük sarsıntılar çok hafif, büyükler belirgin.
func intensity() -> float:
	return trauma * trauma


## Zamanı ilerletir, trauma'yı azaltır ve o anki kamera kaydırmasını döner.
func update(delta: float) -> Vector2:
	_time += delta
	trauma = maxf(trauma - Tuning.SHAKE_DECAY * delta, 0.0)
	var strength: float = intensity() * Tuning.SHAKE_MAX_OFFSET
	if strength <= 0.0:
		return Vector2.ZERO
	var t: float = _time * Tuning.SHAKE_NOISE_SPEED
	var wave := Vector2(_noise.get_noise_1d(t), _noise.get_noise_1d(t + NOISE_Y_OFFSET))
	return (wave * NOISE_GAIN).limit_length(1.0) * strength


## Kombo bitişinin sarsıntısı: puan kazandırmadıysa yok.
static func combo_trauma(floors: int, bonus: int) -> float:
	if bonus <= 0:
		return 0.0
	return minf(floors * Tuning.SHAKE_COMBO_TRAUMA_PER_FLOOR, Tuning.SHAKE_COMBO_TRAUMA_MAX)


## Büyük inişin sarsıntısı: SHAKE_LAND_MIN_SPEED altında yok.
static func land_trauma(fall_speed: float) -> float:
	if fall_speed < Tuning.SHAKE_LAND_MIN_SPEED:
		return 0.0
	var t: float = clampf(inverse_lerp(Tuning.SHAKE_LAND_MIN_SPEED, Tuning.MAX_FALL_SPEED, fall_speed),
			0.0, 1.0)
	return lerpf(Tuning.SHAKE_LAND_TRAUMA_MAX * 0.4, Tuning.SHAKE_LAND_TRAUMA_MAX, t)


## Duvar sekmesinin sarsıntısı: çarpma hızının karesiyle.
static func wall_trauma(impact_speed: float) -> float:
	var t: float = clampf(impact_speed / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
	return t * t * Tuning.SHAKE_WALL_TRAUMA_MAX
