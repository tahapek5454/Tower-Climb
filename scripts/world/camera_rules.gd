class_name CameraRules
extends RefCounted
## Kamera kuralları. Saf mantık: sahneye dokunmaz, test edilebilir.


## Bu kata ulaşılınca kamera kaymaya başlar.
static func should_start(floor_number: int) -> bool:
	return floor_number >= Tuning.CAMERA_START_FLOOR


## Kayma başladıktan `elapsed` saniye sonraki hız: basamaklı artar, üst sınırı var.
static func scroll_speed(elapsed: float) -> float:
	var steps: float = floorf(maxf(elapsed, 0.0) / Tuning.CAMERA_SPEED_STEP_INTERVAL)
	return minf(Tuning.CAMERA_START_SPEED + steps * Tuning.CAMERA_SPEED_STEP, Tuning.CAMERA_MAX_SPEED)


## Oyuncuyu yakalama bölgesinin alt sınırında tutan kamera merkezi y'si.
## Kamera merkezi bundan daha aşağıdaysa oyuncu bölgeye girmiş demektir.
static func catchup_center_y(player_y: float) -> float:
	return player_y + Tuning.VIEW_HEIGHT * (0.5 - Tuning.CAMERA_CATCHUP_ZONE)
