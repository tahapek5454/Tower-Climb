class_name ComboCounter
extends RefCounted
## Kombo sayacı. Saf mantık: sahneye dokunmaz, zamanı dışarıdan alır (advance), test edilebilir.
## Kural: tek inişte COMBO_MIN_FLOORS veya daha fazla kat kazanmak komboyu başlatır/sürdürür
## ve süreyi yeniler. Daha az kazanılan bir inişte veya süre dolunca kombo biter.

## Kombo başladı veya bir zıplayış daha eklendi.
signal changed(jumps: int, floors: int)
## Kombo bitti; bonus 0 ise puan kazandırmadı.
signal ended(jumps: int, floors: int, bonus: int)

## Komboya sayılan zıplayış sayısı (0 = kombo yok).
var jumps: int = 0
## Komboda kazanılan toplam kat.
var floors: int = 0
## Kombonun bitmesine kalan süre (s).
var time_left: float = 0.0


## Kombo bittiğinde verilecek puan: en az COMBO_MIN_JUMPS zıplayış varsa toplam katın karesi.
static func bonus_for(combo_jumps: int, combo_floors: int) -> int:
	if combo_jumps < Tuning.COMBO_MIN_JUMPS:
		return 0
	return combo_floors * combo_floors


func is_active() -> bool:
	return jumps > 0


## Kalan süre oranı (1 = yeni yenilendi, 0 = bitti); HUD çubuğu için.
func time_ratio() -> float:
	return clampf(time_left / Tuning.COMBO_TIMEOUT, 0.0, 1.0)


## Bir iniş bildirir. floors_gained: inilen kat - zıplanan kat (aşağı inişte negatif).
func register_landing(floors_gained: int) -> void:
	if floors_gained >= Tuning.COMBO_MIN_FLOORS:
		jumps += 1
		floors += floors_gained
		time_left = Tuning.COMBO_TIMEOUT
		changed.emit(jumps, floors)
	else:
		finish()


## Zamanı ilerletir; süre dolarsa kombo biter.
func advance(delta: float) -> void:
	if not is_active():
		return
	time_left -= delta
	if time_left <= 0.0:
		finish()


## Aktif komboyu bitirir ve puanını duyurur.
func finish() -> void:
	if not is_active():
		return
	var bonus: int = bonus_for(jumps, floors)
	var ended_jumps: int = jumps
	var ended_floors: int = floors
	clear()
	ended.emit(ended_jumps, ended_floors, bonus)


## Komboyu puan vermeden siler (yeniden başlatmada).
func clear() -> void:
	jumps = 0
	floors = 0
	time_left = 0.0
