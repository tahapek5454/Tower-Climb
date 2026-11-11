extends Node
## Global sinyal otobüsü. Sistemler birbirini tanımadan buradan haberleşir.
## Sinyaller başka dosyalardan yayınlandığı için "unused" uyarıları bastırılır.

## Yeni bir oyun (veya yeniden başlatma) başladı.
@warning_ignore("unused_signal")
signal game_started

## Oyuncu ekranın altından düştü.
@warning_ignore("unused_signal")
signal game_over(final_score: int, final_floor: int)

@warning_ignore("unused_signal")
signal score_changed(score: int)

## Ulaşılan en yüksek kat değişti.
@warning_ignore("unused_signal")
signal floor_changed(floor_number: int)

## Kombo başladı veya devam etti.
@warning_ignore("unused_signal")
signal combo_changed(jumps: int, floors: int)

## Kombo bitti; bonus 0 ise kombo puan kazandırmadı.
@warning_ignore("unused_signal")
signal combo_ended(jumps: int, floors: int, bonus: int)

@warning_ignore("unused_signal")
signal high_score_changed(high_score: int)

## Ekran sarsıntısı iste (0..1 eklenir; kamera dinler).
@warning_ignore("unused_signal")
signal screen_shake(trauma: float)
