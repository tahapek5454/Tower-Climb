class_name WorldPalette
extends RefCounted
## Dünyanın renkleri tek yerde. İlke: orta parlaklık, düşük doygunluk; saf siyah, saf beyaz ve
## doygun turuncu dünyada kullanılmaz (karakter siyah-beyaz-turuncu, zeminde kaybolmamalı).
## Şimdilik tek tema ("taş kule"); tema sistemi gelince (her 100 kat) temalar buradan okunacak.

## Kule içi arka duvar: taş ve derz.
const INTERIOR_STONE := Color(0.30, 0.33, 0.44)
const INTERIOR_JOINT := Color(0.255, 0.28, 0.38)
## Yan duvarlar: sütun gövdesi, yatay derz ve kule içine bakan kenardaki açık pervaz.
const WALL := Color(0.16, 0.18, 0.26)
const WALL_JOINT := Color(0.12, 0.135, 0.20)
const WALL_LIP := Color(0.27, 0.30, 0.42)
## Platformlar: gövde rengi (üst şerit ve alt kenar bundan türetilir). Bölüm platformu (her 100 kat)
## altın sarısı: turuncu/altın ailesi dünyada sadece ödül anlamı taşır.
const PLATFORM := Color(0.40, 0.66, 0.68)
const PLATFORM_SECTION := Color(0.95, 0.80, 0.35)
## Zemin: üst levha, üstündeki açık şerit ve altındaki dolu taban.
const GROUND := Color(0.36, 0.40, 0.53)
const GROUND_TOP := Color(0.50, 0.55, 0.70)
const GROUND_BASE := Color(0.21, 0.23, 0.33)
