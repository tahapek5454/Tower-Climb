class_name SaveData
extends RefCounted
## Kalıcı rekorlar (user://save.cfg, [records] bölümü; ayarlardan ayrı dosya).
## Rekorlar: en iyi skor, en yüksek kat, en uzun kombo (puan kazandıran bir komboda kazanılan kat).
## Karşılaştırma/birleştirme saf fonksiyonlar (test edilebilir); dosya işlemleri ayrı.

const SECTION: String = "records"
const BEST_SCORE: String = "best_score"
const BEST_FLOOR: String = "best_floor"
const BEST_COMBO: String = "best_combo"
const KEYS: Array[String] = [BEST_SCORE, BEST_FLOOR, BEST_COMBO]

## Dosya yolu (testlerde geçici bir dosyayla değiştirilir).
static var path: String = "user://save.cfg"


## Hiç oynanmamış hâl: tüm rekorlar 0.
static func empty() -> Dictionary:
	var records: Dictionary = {}
	for key: String in KEYS:
		records[key] = 0
	return records


## Bu oyunda kırılan rekorların anahtarları (eşitlik rekor sayılmaz).
static func improved(old: Dictionary, run: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key: String in KEYS:
		if int(run.get(key, 0)) > int(old.get(key, 0)):
			result.append(key)
	return result


## Eski rekorlarla bu oyunun değerlerinin en iyisi.
static func merged(old: Dictionary, run: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in KEYS:
		result[key] = maxi(int(old.get(key, 0)), int(run.get(key, 0)))
	return result


## Kayıtlı rekorlar (dosya yoksa veya eksikse 0; bozuk/negatif değerler 0'a çekilir).
static func load_records() -> Dictionary:
	var config := ConfigFile.new()
	config.load(path)
	var records: Dictionary = {}
	for key: String in KEYS:
		var value: Variant = config.get_value(SECTION, key, 0)
		records[key] = maxi(int(value), 0) if value is int or value is float else 0
	return records


## Rekorları kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_records(records: Dictionary) -> void:
	var config := ConfigFile.new()
	config.load(path)
	for key: String in KEYS:
		config.set_value(SECTION, key, int(records.get(key, 0)))
	config.save(path)
