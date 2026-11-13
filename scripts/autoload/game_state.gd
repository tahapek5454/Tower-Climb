extends Node
## Oyun durumu: skor, kat, kombo, en yüksek skor ve kalıcı rekorlar (SaveData).
## Değerler setter'lar üzerinden değişir ve Events ile duyurulur.
## Skor = en yüksek kat x SCORE_PER_FLOOR + biten kombolardan kazanılan bonuslar.
## Kombo kuralları ComboCounter'da (saf mantık).

var score: int = 0:
	set(value):
		if value == score:
			return
		score = value
		Events.score_changed.emit(score)
		if score > high_score:
			high_score = score

## Ulaşılan en yüksek kat. Yeni bir bölüme geçilince kalp kazanılır.
var floor_number: int = 0:
	set(value):
		if value == floor_number:
			return
		var sections: int = PickupRules.sections_crossed(floor_number, value)
		floor_number = value
		Events.floor_changed.emit(floor_number)
		if sections > 0:
			add_hearts(sections * Tuning.HEART_SECTION_BONUS)

## Bu oyundaki kalpler (can): oyuncu düşünce biri harcanır ve roketle kurtarılır. Oyunlar arası birikmez.
var hearts: int = Tuning.HEART_START:
	set(value):
		if value == hearts:
			return
		var change: int = value - hearts
		hearts = value
		Events.hearts_changed.emit(hearts, change)

## En yüksek skor: kayıtlı rekorla başlar, oyun sırasında skor geçerse canlı artar.
var high_score: int = 0:
	set(value):
		if value == high_score:
			return
		high_score = value
		Events.high_score_changed.emit(high_score)

var is_game_over: bool = false

## Aktif kombodaki zıplayış sayısı (0 = kombo yok).
var combo_jumps: int:
	get: return _combo.jumps

## Aktif komboda kazanılan toplam kat.
var combo_floors: int:
	get: return _combo.floors

## Kombonun kalan süre oranı (0..1); HUD çubuğu için.
var combo_time_ratio: float:
	get: return _combo.time_ratio()

## Biten kombolardan toplanan puan.
var bonus_score: int = 0

## Kayıtlı rekorlar (SaveData.KEYS); oyun bitince güncellenir.
var records: Dictionary = {}
## Bu oyunun süresi (s): sadece oyun sürerken sayılır (menüde ve duraklatmada değil).
var run_time: float = 0.0
## Bu oyundaki en uzun kombo (puan kazandıran kombolarda kazanılan kat).
var run_best_combo: int = 0
## Son biten oyunda kırılan rekorlar (SaveData.KEYS'ten); oyun sonu ekranı için.
var new_records: Array[String] = []
## Biriken elmaslar (para; kalıcı, her alışta kaydedilir) ve bu oyunda toplananlar.
var diamonds: int = 0
var run_diamonds: int = 0

var _combo := ComboCounter.new()
## Oyuncunun en son indiği kat (zıplanan kat); kazanılan katı hesaplamak için.
var _current_floor: int = 0
## Roketle uçuluyor: kombo süresi durur (uçuş komboyu ne bozar ne uzatır).
var _flying: bool = false
## Uçuştan sonraki ilk iniş kombo için sayılmaz (roketin bıraktığı platform).
var _skip_combo_landing: bool = false


func _ready() -> void:
	records = SaveData.load_records()
	high_score = records[SaveData.BEST_SCORE]
	diamonds = SaveData.load_diamonds()
	_combo.changed.connect(_on_combo_changed)
	_combo.ended.connect(_on_combo_ended)


func _physics_process(delta: float) -> void:
	advance(delta)
	if GameFlow.is_playing():
		add_run_time(delta)


## Oyun süresini ilerletir (oyun bittiyse sayılmaz).
func add_run_time(delta: float) -> void:
	if not is_game_over:
		run_time += delta


## Kombo süresini ilerletir (testlerde elle çağrılabilir).
func advance(delta: float) -> void:
	if not is_game_over and not _flying:
		_combo.advance(delta)


## Oyuncu bir kata indi (zemin = 0).
func register_landing(landed_floor: int) -> void:
	if is_game_over:
		return
	var floors_gained: int = landed_floor - _current_floor
	_current_floor = landed_floor
	if _skip_combo_landing:
		_skip_combo_landing = false
	else:
		_combo.register_landing(floors_gained)
	floor_number = maxi(floor_number, landed_floor)
	_update_score()


## Roket uçuşu başladı: kombo süresi durur.
func begin_flight() -> void:
	_flying = true


## Uçarken geçilen kat: kat puanı kazandırır (kombo bonusu değil).
func register_flight_floor(passed_floor: int) -> void:
	if is_game_over or passed_floor <= floor_number:
		return
	_current_floor = passed_floor
	floor_number = passed_floor
	_update_score()


## Roket uçuşu bitti: kombo süresi yeniden işler; roketin bıraktığı platforma iniş komboyu etkilemez.
func end_flight() -> void:
	if not _flying:
		return
	_flying = false
	_skip_combo_landing = true


## Elmas alındı: toplam hemen kaydedilir (oyun yarıda kapansa da kaybolmaz).
func add_diamond() -> void:
	if is_game_over:
		return
	diamonds += 1
	run_diamonds += 1
	SaveData.save_diamonds(diamonds)
	Events.diamonds_changed.emit(diamonds)


## Kalp kazanıldı (toplanabilir veya bölüm geçişi); HEART_MAX'ı geçmez.
func add_hearts(amount: int) -> void:
	if not is_game_over:
		hearts = PickupRules.add_hearts(hearts, amount)


## Oyuncu düştü: kalp varsa biri harcanır ve true döner (oyun sürer); yoksa false.
func use_heart() -> bool:
	if is_game_over or hearts <= 0:
		return false
	hearts -= 1
	return true


## Yeni oyun için her şeyi sıfırlar (en yüksek skor ve elmaslar hariç).
func reset() -> void:
	is_game_over = false
	run_diamonds = 0
	hearts = Tuning.HEART_START
	_combo.clear()
	_current_floor = 0
	_flying = false
	_skip_combo_landing = false
	bonus_score = 0
	run_best_combo = 0
	run_time = 0.0
	new_records = []
	floor_number = 0
	score = 0
	Events.game_started.emit()


## Oyunu bitirir; aktif kombo varsa puanı sayılır.
func end_game() -> void:
	if is_game_over:
		return
	_combo.finish()
	is_game_over = true
	_save_records()
	Events.game_over.emit(score, floor_number)


## Kayıtlı tüm rekorları siler (ayarlardan, onaydan sonra). En iyi skor, oyundaki skora iner.
func reset_records() -> void:
	records = SaveData.empty()
	SaveData.save_records(records)
	high_score = score


## Oyunu sonuç ekranı göstermeden bırakır (duraklatma menüsünden ana menüye): puan ve rekorlar
## yine sayılır ama game_over sinyali yayınlanmaz.
func abandon_run() -> void:
	if is_game_over:
		return
	_combo.finish()
	is_game_over = true
	_save_records()


## Kırılan rekorları bulur ve kaydeder (rekor yoksa dosyaya yazmaz).
func _save_records() -> void:
	var run: Dictionary = {
		SaveData.BEST_SCORE: score,
		SaveData.BEST_FLOOR: floor_number,
		SaveData.BEST_COMBO: run_best_combo,
	}
	new_records = SaveData.improved(records, run)
	if not new_records.is_empty():
		records = SaveData.merged(records, run)
		SaveData.save_records(records)


func _update_score() -> void:
	score = floor_number * Tuning.SCORE_PER_FLOOR + bonus_score


func _on_combo_changed(jumps: int, floors: int) -> void:
	Events.combo_changed.emit(jumps, floors)


func _on_combo_ended(jumps: int, floors: int, bonus: int) -> void:
	bonus_score += bonus
	if bonus > 0:
		run_best_combo = maxi(run_best_combo, floors)
	_update_score()
	Events.combo_ended.emit(jumps, floors, bonus)
