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


## Katın platform stili: katın temasının (geçişin ortasında yenisine geçer) stillerinden, ağırlığa
## göre katın zarıyla (roll_of.call(kat) -> 0..1, kata bağlı sabit) seçilir. Alt katın stiliyle
## aynıysa listede bir sonraki stil alınır: aynı stil art arda gelmez. Alt katın stili de aynı kuralla
## hesaplanır; zincir `depth` kat aşağıda kesilir (orada nadiren tekrar kaçabilir).
## Bölüm platformu ayrı (Platform'da).
static func platform_style(floor_number: int, roll_of: Callable, depth: int = 4) -> StringName:
	var styles: Array = _styles_for_floor(floor_number)
	var index: int = _weighted_index(styles, roll_of.call(floor_number))
	if depth > 0 and styles[index][0] == platform_style(floor_number - 1, roll_of, depth - 1):
		index = (index + 1) % styles.size()
	return styles[index][0]


## Katın platformunun teması (stil ve süs için; geçişin ortasında yenisine geçer).
static func platform_theme(floor_number: int) -> int:
	return theme_index(roundf(position(float(floor_number))), WorldPalette.theme_count())


static func _styles_for_floor(floor_number: int) -> Array:
	return WorldPalette.PLATFORM_STYLES[platform_theme(floor_number)]


## Ağırlıklı seçim: roll (0..1) ağırlıkların toplamına göre ölçeklenir.
static func _weighted_index(styles: Array, roll: float) -> int:
	var total: float = 0.0
	for entry: Array in styles:
		total += entry[1]
	var target: float = clampf(roll, 0.0, 0.9999) * total
	for i: int in styles.size():
		target -= styles[i][1]
		if target < 0.0:
			return i
	return styles.size() - 1


## Tema konumunun tam kısmının, count temalık döngüdeki sırası (son temadan sonra başa döner).
static func theme_index(theme_position: float, count: int) -> int:
	return posmod(floori(theme_position), count)
