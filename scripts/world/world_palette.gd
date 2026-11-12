class_name WorldPalette
extends RefCounted
## Dünyanın renkleri tek yerde. İlke: orta parlaklık, düşük doygunluk; saf siyah, saf beyaz ve
## doygun turuncu dünyada kullanılmaz (karakter siyah-beyaz-turuncu, zeminde kaybolmamalı).
## Turuncu/altın ailesi dünyada sadece ödül anlamı taşır (bölüm platformu).
##
## Temalar: her bölümün (100 kat) renkleri; son temadan sonra başa dönülür. Geçişler ThemeRules'ta.
## Anahtarlar: interior_stone/joint (arka duvar taşı ve derzi), wall/wall_joint/wall_lip (yan duvar
## sütunu, derzi, iç kenar pervazı), platform (gövde; üst şerit ve alt kenar bundan türetilir),
## sky_top/bottom, hill_far/near (dağlar; sadece ilk katlarda görünür), cloud/cloud_shade.

const THEME_NAMES: PackedStringArray = ["Taş kule", "Yosunlu", "Alacakaranlık", "Buz", "Gece"]

## Her temanın platform stilleri ve ağırlıkları: [[stil, ağırlık], ...] (bkz. PlatformVisual).
## Büyük ağırlık = daha sık. Seçim ThemeRules.platform_style'da (aynı stil art arda gelmez).
const PLATFORM_STYLES: Array[Array] = [
	[[&"masonry", 3.0], [&"rock", 2.0], [&"cobble", 2.0], [&"arch", 2.0]],
	[[&"plank", 3.0], [&"log", 2.0], [&"rock", 2.0], [&"cobble", 1.0]],
	[[&"metal", 3.0], [&"truss", 2.0], [&"pipe", 2.0], [&"masonry", 1.0]],
	[[&"ice", 3.0], [&"snowdrift", 2.0], [&"crystal", 2.0], [&"rock", 1.0]],
	[[&"crystal", 3.0], [&"glow_tiles", 2.0], [&"cloud", 2.0], [&"rock", 1.0]],
]
## Bölüm platformunun stili (altın "kapı"; temadan bağımsız).
const SECTION_PLATFORM_STYLE: StringName = &"blocks"

## Bölüm platformu (her 100 kat): altın sarısı, temadan bağımsız.
const PLATFORM_SECTION := Color(0.95, 0.80, 0.35)
## Kulenin dibi (sadece başlangıçta görünür; temadan bağımsız): çimenli ova ve zemin.
const MEADOW := Color(0.40, 0.53, 0.33)
const MEADOW_LIGHT := Color(0.52, 0.64, 0.40)
const MEADOW_DARK := Color(0.30, 0.42, 0.27)
const GROUND := Color(0.36, 0.40, 0.53)
const GROUND_TOP := Color(0.50, 0.55, 0.70)
const GROUND_BASE := Color(0.21, 0.23, 0.33)

static var _themes: Array[Dictionary] = [
	# 0 — Taş kule: gri-mavi arduvaz taş, soluk turkuaz platform, mavi gökyüzü, kahve dağlar.
	{
		&"interior_stone": Color(0.30, 0.33, 0.44), &"interior_joint": Color(0.255, 0.28, 0.38),
		&"wall": Color(0.16, 0.18, 0.26), &"wall_joint": Color(0.12, 0.135, 0.20),
		&"wall_lip": Color(0.27, 0.30, 0.42),
		&"platform": Color(0.40, 0.66, 0.68),
		&"sky_top": Color(0.36, 0.45, 0.62), &"sky_bottom": Color(0.60, 0.66, 0.77),
		&"hill_far": Color(0.55, 0.51, 0.55), &"hill_near": Color(0.45, 0.37, 0.32),
		&"cloud": Color(0.80, 0.84, 0.90), &"cloud_shade": Color(0.67, 0.72, 0.82),
	},
	# 1 — Yosunlu: adaçayı-yeşil taş, koyu çam duvar, soluk kum platform, yeşilimsi açık gökyüzü.
	{
		&"interior_stone": Color(0.29, 0.37, 0.35), &"interior_joint": Color(0.24, 0.31, 0.29),
		&"wall": Color(0.14, 0.20, 0.18), &"wall_joint": Color(0.10, 0.15, 0.135),
		&"wall_lip": Color(0.25, 0.34, 0.31),
		&"platform": Color(0.66, 0.62, 0.48),
		&"sky_top": Color(0.38, 0.52, 0.60), &"sky_bottom": Color(0.66, 0.74, 0.72),
		&"hill_far": Color(0.50, 0.54, 0.50), &"hill_near": Color(0.38, 0.40, 0.30),
		&"cloud": Color(0.84, 0.88, 0.86), &"cloud_shade": Color(0.70, 0.77, 0.76),
	},
	# 2 — Alacakaranlık: mürdüm/gül kurusu taş, koyu erik duvar, soluk lila platform, şeftali ufuk.
	{
		&"interior_stone": Color(0.40, 0.31, 0.38), &"interior_joint": Color(0.33, 0.25, 0.31),
		&"wall": Color(0.21, 0.14, 0.20), &"wall_joint": Color(0.16, 0.10, 0.15),
		&"wall_lip": Color(0.37, 0.26, 0.34),
		&"platform": Color(0.64, 0.57, 0.76),
		&"sky_top": Color(0.30, 0.28, 0.48), &"sky_bottom": Color(0.78, 0.60, 0.58),
		&"hill_far": Color(0.52, 0.42, 0.50), &"hill_near": Color(0.38, 0.28, 0.32),
		&"cloud": Color(0.84, 0.72, 0.72), &"cloud_shade": Color(0.64, 0.53, 0.61),
	},
	# 3 — Buz: soluk çelik mavisi taş, koyu petrol duvar, buz mavisi platform, açık soğuk gökyüzü.
	{
		&"interior_stone": Color(0.39, 0.47, 0.54), &"interior_joint": Color(0.32, 0.39, 0.46),
		&"wall": Color(0.15, 0.23, 0.29), &"wall_joint": Color(0.11, 0.17, 0.22),
		&"wall_lip": Color(0.31, 0.41, 0.49),
		&"platform": Color(0.64, 0.80, 0.88),
		&"sky_top": Color(0.50, 0.62, 0.74), &"sky_bottom": Color(0.78, 0.85, 0.90),
		&"hill_far": Color(0.62, 0.68, 0.76), &"hill_near": Color(0.48, 0.54, 0.62),
		&"cloud": Color(0.86, 0.90, 0.94), &"cloud_shade": Color(0.72, 0.80, 0.87),
	},
	# 4 — Gece: lacivert-mor taş (siyaha inmeden), koyu indigo duvar, soluk mor platform, gece gökyüzü.
	{
		&"interior_stone": Color(0.28, 0.28, 0.44), &"interior_joint": Color(0.22, 0.22, 0.37),
		&"wall": Color(0.12, 0.11, 0.22), &"wall_joint": Color(0.085, 0.075, 0.16),
		&"wall_lip": Color(0.25, 0.24, 0.42),
		&"platform": Color(0.58, 0.52, 0.80),
		&"sky_top": Color(0.09, 0.10, 0.22), &"sky_bottom": Color(0.22, 0.22, 0.40),
		&"hill_far": Color(0.20, 0.20, 0.32), &"hill_near": Color(0.15, 0.14, 0.24),
		&"cloud": Color(0.32, 0.33, 0.50), &"cloud_shade": Color(0.24, 0.25, 0.40),
	},
]


static func theme_count() -> int:
	return _themes.size()


## Tema konumundaki renkler (ThemeRules.position): iki komşu tema arasında doğrusal karışım.
static func colors_at(theme_position: float) -> Dictionary:
	var count: int = theme_count()
	var from: Dictionary = _themes[ThemeRules.theme_index(theme_position, count)]
	var to: Dictionary = _themes[ThemeRules.theme_index(theme_position + 1.0, count)]
	var weight: float = theme_position - floorf(theme_position)
	var colors: Dictionary = {}
	for key: StringName in from:
		colors[key] = (from[key] as Color).lerp(to[key], weight)
	return colors


## Tema konumundaki temanın adı (debug).
static func theme_name(theme_position: float) -> String:
	return THEME_NAMES[ThemeRules.theme_index(theme_position, theme_count())]
