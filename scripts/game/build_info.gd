class_name BuildInfo
extends RefCounted
## Sürüm ve yapı bilgisi. Sürüm numarası tek yerde: project.godot → application/config/version
## (Godot dışa aktarımı da bunu kullanır). Yeni sürümde yalnız orayı değiştir.

const VERSION_SETTING: String = "application/config/version"
## Ayar boşsa gösterilecek sürüm.
const FALLBACK_VERSION: String = "0.0.0"


## Sürüm numarası (ör. "1.0.0").
static func version() -> String:
	var value: String = str(ProjectSettings.get_setting(VERSION_SETTING, ""))
	return value if value != "" else FALLBACK_VERSION


## Ekranda gösterilen biçim (ör. "v1.0.0").
static func version_text() -> String:
	return "v" + version()


## Debug araçları (F3 panel, F4 yavaş çekim, F6 bölüm atlama, F7–F10 güçlendirme koyma) yalnız
## editörde ve debug dışa aktarımında çalışır; yayın (release) sürümünde hile olmasın diye kapalıdır.
static func debug_tools_enabled() -> bool:
	return OS.is_debug_build()
