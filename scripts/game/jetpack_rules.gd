class_name JetpackRules
extends RefCounted
## Roket (jetpack) kuralları. Saf mantık: sahneye dokunmaz, test edilebilir.
## Platformlar Vector3 ile anlatılır: x = merkez x, y = üst yüzeyin dünya y'si, z = genişlik.

## "Uygun platform yok" değeri (pick_landing).
const NO_LANDING := Vector3(INF, INF, INF)


## Bu katta roket çıkabilir mi? (Olasılıktan bağımsız ön koşullar.)
## last_spawn_floor: en son roket çıkan kat (hiç çıkmadıysa çok küçük bir sayı).
static func can_spawn(floor_number: int, last_spawn_floor: int) -> bool:
	if not Tuning.JETPACK_ENABLED or floor_number < Tuning.JETPACK_MIN_FLOOR:
		return false
	if PlatformRules.is_section_floor(floor_number):
		return false
	return floor_number - last_spawn_floor >= Tuning.JETPACK_MIN_FLOOR_GAP


## roll: 0..1 rastgele sayı. Nadirlik Tuning.JETPACK_SPAWN_CHANCE ile yönetilir.
static func should_spawn(floor_number: int, last_spawn_floor: int, roll: float) -> bool:
	return can_spawn(floor_number, last_spawn_floor) and roll < Tuning.JETPACK_SPAWN_CHANCE


## Toplanabilirin platform merkezine göre x'i. roll: 0..1. Kenarlara PICKUP_EDGE_MARGIN'den yakın durmaz.
static func pickup_offset_x(platform_width: float, roll: float) -> float:
	var half: float = maxf(platform_width * 0.5 - Tuning.PICKUP_EDGE_MARGIN, 0.0)
	return lerpf(-half, half, clampf(roll, 0.0, 1.0))


## Kalan yakıt oranı (1 = yeni alındı, 0 = bitti); HUD çubuğu için.
static func fuel_ratio(elapsed: float, duration: float = Tuning.JETPACK_FLIGHT_TIME) -> float:
	return clampf(1.0 - elapsed / maxf(duration, 0.001), 0.0, 1.0)


## Bu yükseklikte (ayakların y'si) geçilmiş en yüksek kat: uçarken skor bununla artar.
static func floor_passed(world_y: float) -> int:
	return maxi(floori(-world_y / Tuning.FLOOR_SPACING), 0)


## Oyuncunun platform üstünde bırakılacağı x: kendi x'ine en yakın, kenardan içeride kalan nokta.
static func landing_x(player_x: float, platform: Vector3) -> float:
	var half: float = maxf(platform.z * 0.5 - Tuning.JETPACK_LANDING_EDGE_MARGIN, 0.0)
	return clampf(player_x, platform.x - half, platform.x + half)


## Oyuncunun bırakılacağı y (ayaklar): platform yüzeyinin biraz üstü.
static func release_y(platform: Vector3) -> float:
	return platform.y - Tuning.JETPACK_RELEASE_HEIGHT


## Süre dolunca inilecek platformu seçer. platforms: aşağıdan yukarıya sıralı.
## Oyuncudan en az LANDING_MIN_RISE yukarıdaki ilk LANDING_CANDIDATES platform arasından, yatayda
## en az kayma gerektireni (eşitlikte alttaki). Uygun platform yoksa NO_LANDING.
static func pick_landing(player_position: Vector2, platforms: Array[Vector3]) -> Vector3:
	var best: Vector3 = NO_LANDING
	var best_distance: float = INF
	var considered: int = 0
	for platform: Vector3 in platforms:
		if platform.y > player_position.y - Tuning.JETPACK_LANDING_MIN_RISE:
			continue
		var distance: float = absf(landing_x(player_position.x, platform) - player_position.x)
		if distance < best_distance:
			best = platform
			best_distance = distance
		considered += 1
		if considered >= Tuning.JETPACK_LANDING_CANDIDATES:
			break
	return best


static func has_landing(platform: Vector3) -> bool:
	return platform != NO_LANDING
