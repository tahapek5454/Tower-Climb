class_name SaveData
extends RefCounted
## Kalıcı rekorlar (user://save.cfg, [records] bölümü; ayarlardan ayrı dosya).
## Rekorlar: en iyi skor, en yüksek kat, en uzun kombo (puan kazandıran bir komboda kazanılan kat).
## Ayrıca biriken elmaslar ([wallet] bölümü; rekor sıfırlama bunlara dokunmaz).
## Karşılaştırma/birleştirme saf fonksiyonlar (test edilebilir); dosya işlemleri ayrı.

const SECTION: String = "records"
const BEST_SCORE: String = "best_score"
const BEST_FLOOR: String = "best_floor"
const BEST_COMBO: String = "best_combo"
const KEYS: Array[String] = [BEST_SCORE, BEST_FLOOR, BEST_COMBO]
const WALLET_SECTION: String = "wallet"
const DIAMONDS: String = "diamonds"
## Bugüne dek kazanılan toplam elmas (harcama düşürmez; "toplam elmas" başarımları buna bakar).
const LIFETIME_DIAMONDS: String = "lifetime"
## Mağaza ([shop] bölümü: owned, equipped, levels, stock sözlükleri); rekor sıfırlama dokunmaz.
const SHOP_SECTION: String = "shop"
const SHOP_KEYS: Array[String] = ["owned", "equipped", "levels", "stock"]
## Açılmış başarımlar ([achievements] bölümü, id = true); rekor sıfırlama bunlara dokunmaz.
const ACHIEVEMENTS_SECTION: String = "achievements"

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


## Biriken elmas sayısı (dosya yoksa veya değer bozuksa 0).
static func load_diamonds() -> int:
	var config := ConfigFile.new()
	config.load(path)
	var value: Variant = config.get_value(WALLET_SECTION, DIAMONDS, 0)
	return maxi(int(value), 0) if value is int or value is float else 0


## Elmas sayısını kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_diamonds(count: int) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(WALLET_SECTION, DIAMONDS, maxi(count, 0))
	config.save(path)


## Bugüne dek kazanılan toplam elmas. Eski kayıtlarda yoksa eldeki elmas sayısı kabul edilir.
static func load_lifetime_diamonds() -> int:
	var config := ConfigFile.new()
	config.load(path)
	var value: Variant = config.get_value(WALLET_SECTION, LIFETIME_DIAMONDS, -1)
	return int(value) if (value is int or value is float) and value >= 0 else load_diamonds()


## Kazanılan elmas: eldeki sayı ve ömür boyu toplam tek yazışta kaydedilir.
static func save_wallet(count: int, lifetime: int) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(WALLET_SECTION, DIAMONDS, maxi(count, 0))
	config.set_value(WALLET_SECTION, LIFETIME_DIAMONDS, maxi(lifetime, 0))
	config.save(path)


## Mağaza durumu (ham; anlam denetimi ShopRules.sanitized). Sözlük olmayan değerler boş sayılır.
static func load_shop() -> Dictionary:
	var config := ConfigFile.new()
	config.load(path)
	var result: Dictionary = {}
	for key: String in SHOP_KEYS:
		var value: Variant = config.get_value(SHOP_SECTION, key, {})
		result[key] = value if value is Dictionary else {}
	return result


## Mağaza durumunu kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_shop(state: Dictionary) -> void:
	var config := ConfigFile.new()
	config.load(path)
	for key: String in SHOP_KEYS:
		var value: Variant = state.get(key, {})
		config.set_value(SHOP_SECTION, key, value if value is Dictionary else {})
	config.save(path)


## Açılmış başarımlar: {id (String) -> true}. Bozuk (true olmayan) değerler yok sayılır.
static func load_achievements() -> Dictionary:
	var config := ConfigFile.new()
	config.load(path)
	var result: Dictionary = {}
	if not config.has_section(ACHIEVEMENTS_SECTION):
		return result
	for key: String in config.get_section_keys(ACHIEVEMENTS_SECTION):
		var value: Variant = config.get_value(ACHIEVEMENTS_SECTION, key, false)
		if value is bool and value:
			result[key] = true
	return result


## Bir başarımı açılmış olarak kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_achievement(id: StringName) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(ACHIEVEMENTS_SECTION, String(id), true)
	config.save(path)
