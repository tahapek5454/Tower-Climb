extends Node
## Oyun durumu: skor, kat, kombo, en yüksek skor.
## Değerler setter'lar üzerinden değişir ve Events ile duyurulur.
## Skor/kombo kuralları ileride ayrı bir saf-mantık sınıfında olacak; burası sadece durumu tutar.

var score: int = 0:
	set(value):
		if value == score:
			return
		score = value
		Events.score_changed.emit(score)
		if score > high_score:
			high_score = score

## Ulaşılan en yüksek kat.
var floor_number: int = 0:
	set(value):
		if value == floor_number:
			return
		floor_number = value
		Events.floor_changed.emit(floor_number)

## Aktif kombodaki zıplayış sayısı (0 = kombo yok).
var combo_jumps: int = 0

## Aktif komboda atlanan toplam kat.
var combo_floors: int = 0

## Oturum boyunca en yüksek skor (kalıcı kayıt Aşama 5'te).
var high_score: int = 0:
	set(value):
		if value == high_score:
			return
		high_score = value
		Events.high_score_changed.emit(high_score)

var is_game_over: bool = false


## Yeni oyun için her şeyi sıfırlar (en yüksek skor hariç).
func reset() -> void:
	is_game_over = false
	combo_jumps = 0
	combo_floors = 0
	score = 0
	floor_number = 0
	Events.game_started.emit()


func end_game() -> void:
	if is_game_over:
		return
	is_game_over = true
	Events.game_over.emit(score, floor_number)
