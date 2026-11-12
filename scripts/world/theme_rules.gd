class_name ThemeRules
extends RefCounted
## Tema (bölüm) kuralları. Saf mantık: sahneye dokunmaz, test edilebilir.
## Her SECTION_FLOOR_INTERVAL katta bir bölüm başlar (altın bölüm platformu). Yeni bölümün teması
## bölüm platformundan sonra THEME_TRANSITION_FLOORS kat boyunca yumuşakça gelir.
##
## "Tema konumu" sürekli bir sayıdır: tam kısmı geçerli tema (sarmasız), kesirli kısmı bir sonrakine
## geçiş oranı. Örn. 1.25 = 1. temadan 2. temaya %25 geçilmiş. Renkler WorldPalette.colors_at'te.


## Kesirli kat değerinin (ör. kamera merkezinin yüksekliği) tema konumu.
static func position(floor_value: float) -> float:
	var interval: float = float(Tuning.SECTION_FLOOR_INTERVAL)
	var section: float = floorf(maxf(floor_value, 0.0) / interval)
	if section < 1.0:
		return 0.0
	var local: float = floor_value - section * interval
	var blend: float = smoothstep(0.0, Tuning.THEME_TRANSITION_FLOORS, local)
	return section - 1.0 + blend


## Dünya y'sinin kat değeri (yukarı = -y; kat 0 zemin).
static func floor_value_at(world_y: float) -> float:
	return -world_y / Tuning.FLOOR_SPACING


## Tema konumunun tam kısmının, count temalık döngüdeki sırası (son temadan sonra başa döner).
static func theme_index(theme_position: float, count: int) -> int:
	return posmod(floori(theme_position), count)
