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

## Oyun akışı durumu değişti (FlowRules.State değerleri; GameFlow yayınlar).
@warning_ignore("unused_signal")
signal flow_changed(new_state: int, old_state: int)

## Oyuncu bir toplanabiliri aldı (kind: Pickup.JETPACK vb.; world_position: nesnenin dünya konumu).
@warning_ignore("unused_signal")
signal pickup_collected(kind: StringName, world_position: Vector2)

## Biriken elmas sayısı değişti (total: kayıtlı toplam).
@warning_ignore("unused_signal")
signal diamonds_changed(total: int)

## Bu oyundaki kalp sayısı değişti (change: + kazanıldı, - harcandı; yeni oyunda sıfırlanınca da yayınlanır).
@warning_ignore("unused_signal")
signal hearts_changed(hearts: int, change: int)

## Süreli bir güçlendirme başladı / bitti (kind: Pickup türü; duration: saniye). HUD ve ses dinler.
@warning_ignore("unused_signal")
signal powerup_started(kind: StringName, duration: float)
@warning_ignore("unused_signal")
signal powerup_ended(kind: StringName)

## Yeni bölüme geçildi, kamera kalıcı olarak hızlandı (section: ulaşılan bölüm, 1'den başlar).
@warning_ignore("unused_signal")
signal speed_increased(section: int)

## Ekran sarsıntısı iste (0..1 eklenir; kamera dinler).
@warning_ignore("unused_signal")
signal screen_shake(trauma: float)
