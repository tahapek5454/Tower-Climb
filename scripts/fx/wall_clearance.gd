class_name WallClearance
extends RefCounted
## Görüntü hitbox'tan geniş olduğunda duvara yaslanan karakterin duvarın içine çizilmemesi için
## görüntüye uygulanacak yatay kaydırmayı hesaplar. Saf kural; fiziğe dokunmaz.


## center_x: karakterin kule ortasına göre yatay konumu (px).
## visual_half_width: görüntünün yarı genişliği (px).
## tower_half_width: kule ortasından duvarın iç yüzüne uzaklık (px).
## Dönen değer görüntüye eklenir: duvardan uzakta 0, duvara yaklaştıkça içeri doğru iter.
static func offset_x(center_x: float, visual_half_width: float, tower_half_width: float) -> float:
	var limit: float = maxf(tower_half_width - visual_half_width, 0.0)
	return clampf(center_x, -limit, limit) - center_x
