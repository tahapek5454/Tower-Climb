class_name GameSettings
extends RefCounted
## Oynanış/ekran ayarlarının kalıcı kaydı (user://settings.cfg, [game] bölümü; ses ayarları AudioSettings'te).
## Ayarlar ekranı (madde 5) aynı dosyayı kullanır. Varsayılanlar DEFAULTS'ta.

const SECTION: String = "game"
const DEFAULTS: Dictionary = {
	"pause_on_focus_loss": true,
}

## Dosya yolu (testlerde geçici bir dosyayla değiştirilebilir).
static var path: String = "user://settings.cfg"


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
