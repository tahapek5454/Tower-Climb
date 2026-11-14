class_name GameOverRules
extends RefCounted
## Oyun sonu ekranının saf kuralları: başlık/alt yazı seçimi, süre biçimi, sayarak artan değer eğrisi.

const TITLE_NORMAL: String = "OYUN BİTTİ"
const TITLE_RECORD: String = "YENİ REKOR!"
const SUBTITLE_NORMAL: String = "Bir dahaki sefere daha yükseğe!"
const SUBTITLE_RECORD: String = "Yeni bir zirvedesin"


## Hiç rekor kırılmadıysa normal başlık, en az biri kırıldıysa rekor başlığı.
static func headline(new_records: Array) -> String:
	return TITLE_NORMAL if new_records.is_empty() else TITLE_RECORD


static func subtitle(new_records: Array) -> String:
	return SUBTITLE_NORMAL if new_records.is_empty() else SUBTITLE_RECORD


## Süre "d:ss" biçiminde (ör. 65 → "1:05"); negatif 0 sayılır.
static func format_time(seconds: float) -> String:
	var whole: int = maxi(int(seconds), 0)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]


## Sayarak artan değer: hızlı başlar, hedefe yaklaşırken yavaşlar (ease-out kübik). progress 0..1.
static func eased_count(target: int, progress: float) -> int:
	var p: float = clampf(progress, 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - p, 3.0)
	return int(round(target * eased))
