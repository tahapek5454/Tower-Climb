class_name MagnetRules
extends RefCounted
## Mıknatısın saf kuralları: çıkma koşulları, etki sırasında elmas olasılığı, çekim menzili ve hızı,
## arka arkaya toplanan elmasların ses perdesi. Sahneye dokunmaz, test edilebilir.


## Bu katta mıknatıs çıkabilir mi? (Olasılıktan bağımsız ön koşullar.)
## last_spawn_floor: en son mıknatıs çıkan kat (hiç çıkmadıysa çok küçük bir sayı).
static func can_spawn(floor_number: int, last_spawn_floor: int) -> bool:
	if not Tuning.MAGNET_ENABLED or floor_number < Tuning.MAGNET_MIN_FLOOR:
		return false
	return floor_number - last_spawn_floor >= Tuning.MAGNET_MIN_FLOOR_GAP


## roll: 0..1. Nadirlik Tuning.MAGNET_SPAWN_CHANCE ile yönetilir.
static func should_spawn(floor_number: int, last_spawn_floor: int, roll: float) -> bool:
	return can_spawn(floor_number, last_spawn_floor) and roll < Tuning.MAGNET_SPAWN_CHANCE


## Bu katta elmas çıkar mı? magnet_active: mıknatıs etkisi sürüyor (olasılık MAGNET_DIAMOND_CHANCE olur).
## Elmasın kendi koşulları (DIAMOND_ENABLED, DIAMOND_MIN_FLOOR) her durumda geçerli.
static func should_spawn_diamond(floor_number: int, roll: float, magnet_active: bool) -> bool:
	if not magnet_active:
		return PickupRules.should_spawn_diamond(floor_number, roll)
	if not Tuning.DIAMOND_ENABLED or floor_number < Tuning.DIAMOND_MIN_FLOOR:
		return false
	return roll < Tuning.MAGNET_DIAMOND_CHANCE


## Nesne mıknatısın menzilinde mi?
static func in_range(item_position: Vector2, magnet_position: Vector2) -> bool:
	return item_position.distance_squared_to(magnet_position) <= Tuning.MAGNET_RADIUS * Tuning.MAGNET_RADIUS


## Çekilen nesnenin hızı (px/s): yavaş başlar, hızlanır, üst sınırda kalır. elapsed: çekim başlayalı (s).
static func pull_speed(elapsed: float) -> float:
	var speed: float = Tuning.MAGNET_PULL_START_SPEED + Tuning.MAGNET_PULL_ACCEL * maxf(elapsed, 0.0)
	return minf(speed, Tuning.MAGNET_PULL_MAX_SPEED)


## Çekilen nesnenin bir adım sonraki konumu: hedefe doğru pull_speed ile ilerler, hedefi geçmez.
static func pull_step(item_position: Vector2, target: Vector2, elapsed: float, delta: float) -> Vector2:
	return item_position.move_toward(target, pull_speed(elapsed) * delta)


## Hedefe toplanacak kadar yakın mı?
static func reached(item_position: Vector2, target: Vector2) -> bool:
	return item_position.distance_to(target) <= Tuning.MAGNET_COLLECT_DISTANCE


## Arka arkaya toplanan elmasın zincir sırası: since_last (s) pencere içindeyse bir artar, değilse 0'a döner.
static func next_chain(chain: int, since_last: float) -> int:
	if since_last > Tuning.MAGNET_SFX_CHAIN_WINDOW:
		return 0
	return mini(chain + 1, Tuning.MAGNET_SFX_CHAIN_MAX)


## Zincirdeki elmas sesinin perdesi (0 → 1; her adım MAGNET_SFX_CHAIN_SEMITONES yarım ton yukarı).
static func chain_pitch(chain: int) -> float:
	var steps: int = clampi(chain, 0, Tuning.MAGNET_SFX_CHAIN_MAX)
	return pow(2.0, steps * Tuning.MAGNET_SFX_CHAIN_SEMITONES / 12.0)
