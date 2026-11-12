class_name AudioSettings
extends RefCounted
## Ses ayarlarının kalıcı kaydı (user://settings.cfg, [audio] bölümü). Aşama 5'teki ayarlar menüsü
## aynı dosyayı kullanacak. Varsayılanlar DEFAULTS'ta.

const SECTION: String = "audio"
const DEFAULTS: Dictionary = {
	"music_volume": 0.6,
	"last_track": "",
	"sfx_enabled": true,
	"muted": false,
}

## Dosya yolu (testlerde geçici bir dosyayla değiştirilebilir).
static var path: String = "user://settings.cfg"


## Kayıtlı ayarlar (eksikler varsayılanla doldurulur).
static func load_all() -> Dictionary:
	var config := ConfigFile.new()
	config.load(path)
	var values: Dictionary = {}
	for key: String in DEFAULTS:
		values[key] = config.get_value(SECTION, key, DEFAULTS[key])
	return values


## Tek bir ayarı kaydeder (dosyadaki diğer bölümlere dokunmaz).
static func save_value(key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(SECTION, key, value)
	config.save(path)
