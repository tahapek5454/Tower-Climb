class_name AchievementRules
extends RefCounted
## Başarımlar: sabit tanım tablosu ve saf kurallar. Tüm sayılar (hedef, ödül) bu tabloda, tek yerde.
## Her tanım: id, title (kısa ad), desc (kısa açıklama), reward (elmas), stat (izlenen değer), target.
## Değer türleri (stat): FLOOR ulaşılan kat, COMBO_FLOORS tek komboda kazanılan kat, DIAMONDS bugüne
## dek kazanılan elmas toplamı (harcama düşürmez), HEARTS bir turda aynı anda taşınan kalp, olay sayaçları (ilk roket vb.) için 1.

const FLOOR: StringName = &"floor"
const COMBO_FLOORS: StringName = &"combo_floors"
const DIAMONDS: StringName = &"diamonds_total"
const HEARTS: StringName = &"hearts"
const PICKUP_JETPACK: StringName = &"pickup_jetpack"
const PICKUP_HOURGLASS: StringName = &"pickup_hourglass"
const RESCUE: StringName = &"rescue"

const DEFS: Array[Dictionary] = [
	{"id": &"floor_50", "title": "İlk Adımlar", "desc": "50. kata ulaş", "reward": 1, "stat": FLOOR, "target": 50},
	{"id": &"floor_100", "title": "Yüzler Kulübü", "desc": "100. kata ulaş", "reward": 2, "stat": FLOOR, "target": 100},
	{"id": &"floor_250", "title": "Bulutların Üstünde", "desc": "250. kata ulaş", "reward": 4, "stat": FLOOR, "target": 250},
	{"id": &"floor_500", "title": "Yarı Yol", "desc": "500. kata ulaş", "reward": 6, "stat": FLOOR, "target": 500},
	{"id": &"floor_1000", "title": "Kulenin Tepesi", "desc": "1000. kata ulaş", "reward": 10, "stat": FLOOR, "target": 1000},
	{"id": &"combo_10", "title": "Seri Zıplayış", "desc": "Tek komboda 10 kat kazan", "reward": 1, "stat": COMBO_FLOORS, "target": 10},
	{"id": &"combo_25", "title": "Kombo Ustası", "desc": "Tek komboda 25 kat kazan", "reward": 3, "stat": COMBO_FLOORS, "target": 25},
	{"id": &"combo_50", "title": "Durdurulamaz", "desc": "Tek komboda 50 kat kazan", "reward": 6, "stat": COMBO_FLOORS, "target": 50},
	{"id": &"diamond_1", "title": "İlk Parıltı", "desc": "İlk elmasını topla", "reward": 1, "stat": DIAMONDS, "target": 1},
	{"id": &"diamond_25", "title": "Elmas Avcısı", "desc": "Toplam 25 elmasa ulaş", "reward": 2, "stat": DIAMONDS, "target": 25},
	{"id": &"diamond_100", "title": "Hazine Sandığı", "desc": "Toplam 100 elmasa ulaş", "reward": 5, "stat": DIAMONDS, "target": 100},
	{"id": &"jetpack_first", "title": "Havalan!", "desc": "İlk roketini topla", "reward": 1, "stat": PICKUP_JETPACK, "target": 1},
	{"id": &"hourglass_first", "title": "Zamanı Eğ", "desc": "İlk kum saatini topla", "reward": 1, "stat": PICKUP_HOURGLASS, "target": 1},
	{"id": &"rescue_first", "title": "Son Anda", "desc": "Bir kalple ölümden dön", "reward": 2, "stat": RESCUE, "target": 1},
	{"id": &"hearts_3", "title": "Yedek Canlar", "desc": "Tek turda 3 kalp biriktir", "reward": 2, "stat": HEARTS, "target": 3},
]


## Tüm tanımlar (sırayla).
static func all_defs() -> Array[Dictionary]:
	return DEFS


## Tanım (yoksa boş sözlük).
static func get_def(id: StringName) -> Dictionary:
	for def: Dictionary in DEFS:
		if def["id"] == id:
			return def
	return {}


static func total() -> int:
	return DEFS.size()


## Açılmış başarım sayısı (tabloda olmayan eski/bilinmeyen kayıtlar sayılmaz).
static func count_unlocked(unlocked: Dictionary) -> int:
	var count: int = 0
	for def: Dictionary in DEFS:
		if unlocked.has(String(def["id"])):
			count += 1
	return count


## Bu değer türünün yeni değeriyle şimdi açılması gereken, daha önce açılmamış başarımlar.
## unlocked: {id (String) -> true}.
static func newly_unlocked(stat: StringName, value: int, unlocked: Dictionary) -> Array[StringName]:
	var result: Array[StringName] = []
	for def: Dictionary in DEFS:
		if def["stat"] == stat and value >= int(def["target"]) and not unlocked.has(String(def["id"])):
			result.append(def["id"])
	return result
