class_name ShopCatalog
extends RefCounted
## Elmas mağazasının ürün tablosu: kimlik, tür, ad, fiyat ve görünüm verisi tek yerde.
## Türler: kozmetik yuvaları (şapka, tişört, pantolon, efekt — sahip olunur ve kuşanılır),
## takviye (tek kullanımlık, stoklanır) ve yükseltme (kalıcı, seviyeli).
## Kurallar ShopRules'ta (saf); durum Shop autoload'unda; kayıt SaveData [shop].

# --- Türler ---
const HAT: StringName = &"hat"
const SHIRT: StringName = &"shirt"
const PANTS: StringName = &"pants"
const TRAIL: StringName = &"trail"
const BOOST: StringName = &"boost"
const UPGRADE: StringName = &"upgrade"

## Kuşanılan yuvalar (her birinde aynı anda tek ürün).
const SLOTS: Array[StringName] = [HAT, SHIRT, PANTS, TRAIL]
## Karakter modeline uygulanan yuvalar (CharacterModel.set_cosmetic).
const MODEL_SLOTS: Array[StringName] = [HAT, SHIRT, PANTS]
## Mağaza sekmelerinin sırası ve başlıkları.
const CATEGORIES: Array[StringName] = [HAT, SHIRT, PANTS, TRAIL, BOOST, UPGRADE]
const CATEGORY_TITLES: Dictionary = {
	HAT: "Şapka", SHIRT: "Tişört", PANTS: "Pantolon", TRAIL: "Efekt", BOOST: "Takviye", UPGRADE: "Yükseltme",
}

## Her yuvanın ücretsiz, hep sahip olunan varsayılanı (hiçbir şey kuşanılmamışsa bu geçerlidir).
const DEFAULTS: Dictionary = {
	HAT: &"hat_none", SHIRT: &"shirt_default", PANTS: &"pants_default", TRAIL: &"trail_default",
}

# --- Desenler ve efekt biçimleri ---
const PATTERN_PLAIN: StringName = &"plain"
const PATTERN_STRIPES: StringName = &"stripes"
const PATTERN_DOTS: StringName = &"dots"
const PATTERN_STAR: StringName = &"star"
const STYLE_PLAIN: StringName = &"plain"
const STYLE_RAINBOW: StringName = &"rainbow"
const STYLE_SPARKLE: StringName = &"sparkle"

# --- Takviye ve yükseltme kimlikleri ---
const BOOST_HEART: StringName = &"boost_heart"
const BOOST_ROCKET: StringName = &"boost_rocket"
const UP_JETPACK: StringName = &"up_jetpack"
const UP_HOURGLASS: StringName = &"up_hourglass"
const UP_MAGNET: StringName = &"up_magnet"
const UP_HEARTS: StringName = &"up_hearts"
const UP_LUCK: StringName = &"up_luck"

## Ürünler. Ortak alanlar: id, category, title, price. Ek alanlar türe göre:
##   tişört: color, color2, pattern · pantolon: color · efekt: color, color2, style
##   takviye / yükseltme: desc · yükseltme: prices (seviye başına; price = ilk seviye)
## Şapkaların modeli kimlikle eşleşir (assets/models/accessories.glb içinde aynı adlı düğüm).
const ITEMS: Array[Dictionary] = [
	# Şapkalar
	{"id": &"hat_none", "category": HAT, "title": "Şapkasız", "price": 0},
	{"id": &"hat_cap", "category": HAT, "title": "Kep", "price": 80},
	{"id": &"hat_beanie", "category": HAT, "title": "Bere", "price": 80},
	{"id": &"hat_party", "category": HAT, "title": "Parti külahı", "price": 100},
	{"id": &"hat_straw", "category": HAT, "title": "Hasır şapka", "price": 120},
	{"id": &"hat_fez", "category": HAT, "title": "Fes", "price": 140},
	{"id": &"hat_cowboy", "category": HAT, "title": "Kovboy şapkası", "price": 160},
	{"id": &"hat_propeller", "category": HAT, "title": "Pervaneli şapka", "price": 180},
	{"id": &"hat_top", "category": HAT, "title": "Silindir şapka", "price": 200},
	{"id": &"hat_santa", "category": HAT, "title": "Noel Baba şapkası", "price": 240},
	{"id": &"hat_crown", "category": HAT, "title": "Altın taç", "price": 400},
	# Tişörtler
	{"id": &"shirt_default", "category": SHIRT, "title": "Gri tişört", "price": 0,
		"color": Color(0.36, 0.38, 0.42), "color2": Color(0.36, 0.38, 0.42), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_red", "category": SHIRT, "title": "Kiremit", "price": 30,
		"color": Color(0.74, 0.33, 0.29), "color2": Color(0.74, 0.33, 0.29), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_teal", "category": SHIRT, "title": "Turkuaz", "price": 30,
		"color": Color(0.30, 0.62, 0.62), "color2": Color(0.30, 0.62, 0.62), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_mustard", "category": SHIRT, "title": "Hardal", "price": 30,
		"color": Color(0.80, 0.65, 0.30), "color2": Color(0.80, 0.65, 0.30), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_green", "category": SHIRT, "title": "Çam yeşili", "price": 30,
		"color": Color(0.36, 0.56, 0.40), "color2": Color(0.36, 0.56, 0.40), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_white", "category": SHIRT, "title": "Krem", "price": 40,
		"color": Color(0.90, 0.88, 0.82), "color2": Color(0.90, 0.88, 0.82), "pattern": PATTERN_PLAIN},
	{"id": &"shirt_sailor", "category": SHIRT, "title": "Denizci", "price": 60,
		"color": Color(0.90, 0.90, 0.86), "color2": Color(0.24, 0.33, 0.52), "pattern": PATTERN_STRIPES},
	{"id": &"shirt_bee", "category": SHIRT, "title": "Arı", "price": 60,
		"color": Color(0.86, 0.70, 0.28), "color2": Color(0.20, 0.20, 0.23), "pattern": PATTERN_STRIPES},
	{"id": &"shirt_dots", "category": SHIRT, "title": "Puantiyeli", "price": 70,
		"color": Color(0.62, 0.36, 0.48), "color2": Color(0.92, 0.88, 0.84), "pattern": PATTERN_DOTS},
	{"id": &"shirt_star", "category": SHIRT, "title": "Yıldızlı", "price": 90,
		"color": Color(0.26, 0.32, 0.50), "color2": Color(0.95, 0.80, 0.36), "pattern": PATTERN_STAR},
	# Pantolonlar
	{"id": &"pants_default", "category": PANTS, "title": "Koyu pantolon", "price": 0,
		"color": Color(0.16, 0.17, 0.20)},
	{"id": &"pants_jeans", "category": PANTS, "title": "Kot", "price": 30, "color": Color(0.29, 0.40, 0.58)},
	{"id": &"pants_khaki", "category": PANTS, "title": "Haki", "price": 30, "color": Color(0.62, 0.56, 0.40)},
	{"id": &"pants_olive", "category": PANTS, "title": "Zeytin", "price": 30, "color": Color(0.38, 0.44, 0.30)},
	{"id": &"pants_wine", "category": PANTS, "title": "Bordo", "price": 30, "color": Color(0.48, 0.24, 0.28)},
	{"id": &"pants_white", "category": PANTS, "title": "Krem", "price": 40, "color": Color(0.86, 0.84, 0.78)},
	# Efektler: koşu izi + iniş tozu + hâle aynı renk takımını kullanır
	{"id": &"trail_default", "category": TRAIL, "title": "Turuncu rüzgâr", "price": 0,
		"color": Color(1.0, 0.55, 0.15), "color2": Color(1.0, 0.55, 0.15), "style": STYLE_PLAIN},
	{"id": &"trail_teal", "category": TRAIL, "title": "Turkuaz rüzgâr", "price": 40,
		"color": Color(0.38, 0.82, 0.80), "color2": Color(0.38, 0.82, 0.80), "style": STYLE_PLAIN},
	{"id": &"trail_rose", "category": TRAIL, "title": "Gül", "price": 40,
		"color": Color(0.95, 0.56, 0.68), "color2": Color(0.95, 0.56, 0.68), "style": STYLE_PLAIN},
	{"id": &"trail_ice", "category": TRAIL, "title": "Buz", "price": 40,
		"color": Color(0.70, 0.86, 1.0), "color2": Color(0.92, 0.97, 1.0), "style": STYLE_PLAIN},
	{"id": &"trail_gold", "category": TRAIL, "title": "Altın toz", "price": 70,
		"color": Color(1.0, 0.82, 0.36), "color2": Color(1.0, 0.95, 0.70), "style": STYLE_SPARKLE},
	{"id": &"trail_rainbow", "category": TRAIL, "title": "Gökkuşağı", "price": 130,
		"color": Color(1.0, 0.50, 0.50), "color2": Color(0.50, 0.70, 1.0), "style": STYLE_RAINBOW},
	{"id": &"trail_stardust", "category": TRAIL, "title": "Yıldız tozu", "price": 160,
		"color": Color(0.74, 0.66, 1.0), "color2": Color(1.0, 1.0, 1.0), "style": STYLE_SPARKLE},
	# Takviyeler (tek kullanımlık; sonraki turun başında kendiliğinden kullanılır)
	{"id": BOOST_HEART, "category": BOOST, "title": "Yedek kalp", "price": 15,
		"desc": "Sonraki tura 1 kalple başla"},
	{"id": BOOST_ROCKET, "category": BOOST, "title": "Roketli çıkış", "price": 25,
		"desc": "Sonraki tura roketle başla"},
	# Yükseltmeler (kalıcı; etkileri UpgradeRules + Tuning.UPGRADE_*)
	{"id": UP_JETPACK, "category": UPGRADE, "title": "Büyük depo", "price": 60, "prices": [60, 120, 200],
		"desc": "Roket daha uzun uçar"},
	{"id": UP_HOURGLASS, "category": UPGRADE, "title": "İnce kum", "price": 60, "prices": [60, 120, 200],
		"desc": "Yavaş zaman daha uzun sürer"},
	{"id": UP_MAGNET, "category": UPGRADE, "title": "Güçlü mıknatıs", "price": 60, "prices": [60, 120, 200],
		"desc": "Elmas avı daha uzun sürer"},
	{"id": UP_HEARTS, "category": UPGRADE, "title": "Geniş yürek", "price": 80, "prices": [80, 160, 260],
		"desc": "Daha fazla kalp taşı"},
	{"id": UP_LUCK, "category": UPGRADE, "title": "Şans", "price": 80, "prices": [80, 160, 260],
		"desc": "Güçlendirmeler daha sık çıkar"},
]


## Ürün tanımı (yoksa boş sözlük).
static func get_item(id: StringName) -> Dictionary:
	for item: Dictionary in ITEMS:
		if item["id"] == id:
			return item
	return {}


static func has_item(id: StringName) -> bool:
	return not get_item(id).is_empty()


## Bir türün ürünleri (tablo sırasıyla).
static func items_in(category: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in ITEMS:
		if item["category"] == category:
			result.append(item)
	return result


## Kuşanılan bir yuva mı (kozmetik)?
static func is_slot(category: StringName) -> bool:
	return SLOTS.has(category)


## Yuvanın varsayılan (ücretsiz) ürünü; yuva değilse boş ad.
static func default_of(slot: StringName) -> StringName:
	return DEFAULTS.get(slot, &"")


## Yükseltmenin en yüksek seviyesi (yükseltme değilse 0).
static func max_level(id: StringName) -> int:
	return (get_item(id).get("prices", []) as Array).size()
