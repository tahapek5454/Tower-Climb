class_name WorldPalette
extends RefCounted
## Dünyanın renkleri tek yerde. İlke: orta parlaklık, düşük doygunluk; saf siyah, saf beyaz ve
## doygun turuncu dünyada kullanılmaz (karakter siyah-beyaz-turuncu, zeminde kaybolmamalı).
## Şimdilik tek tema ("taş kule"); tema sistemi gelince (her 100 kat) temalar buradan okunacak.

## Kule içi arka duvar: taş ve derz.
const INTERIOR_STONE := Color(0.30, 0.33, 0.44)
const INTERIOR_JOINT := Color(0.255, 0.28, 0.38)
## Yan duvarlar ve zemin.
const WALL := Color(0.16, 0.18, 0.26)
const GROUND := Color(0.35, 0.40, 0.55)
