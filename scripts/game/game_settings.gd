class_name GameSettings
extends RefCounted
## Oynanış/ekran ayarlarının kalıcı kaydı (user://settings.cfg, [game] bölümü; ses ayarları AudioSettings'te).
## Ayarlar ekranı (madde 5) aynı dosyayı kullanır. Varsayılanlar DEFAULTS'ta.

const SECTION: String = "game"
const DEFAULTS: Dictionary = {
	"pause_on_focus_loss": true,
	"screen_shake": true,
	"fullscreen": false,
}

## Dosya yolu (testlerde geçici bir dosyayla değiştirilebilir).
static var path: String = "user://settings.cfg"

## Oyun sırasında sık okunan ayarlar için önbellek (dosya her seferinde okunmaz).
static var _cache: Dictionary = {}


## Tek bir ayarın değeri (önbellekten; ilk çağrıda dosya okunur).
static func get_setting(key: String) -> Variant:
	if _cache.is_empty():
		_cache = load_all()
	return _cache[key]


## Önbelleği atar (testlerde dosya yolu değişince).
static func reset_cache() -> void:
	_cache = {}


## Kayıtlı ayarlar (eksikler varsayılanla doldurulur; tipi uymayan değer varsayılana döner).
static func load_all() -> Dictionary:
	var config := ConfigFile.new()
	config.load(path)
	var values: Dictionary = {}
	for key: String in DEFAULTS:
		var value: Variant = config.get_value(SECTION, key, DEFAULTS[key])
		values[key] = value if typeof(value) == typeof(DEFAULTS[key]) else DEFAULTS[key]
	return values


## Tek bir ayarı kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_value(key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(SECTION, key, value)
	config.save(path)
	if not _cache.is_empty():
		_cache[key] = value
