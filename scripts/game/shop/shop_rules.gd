class_name ShopRules
extends RefCounted
## Mağaza kuralları (saf): sahiplik, fiyat, satın alınabilirlik, kuşanma. Dosyaya ve autoload'a dokunmaz.
## Durum sözlüğü: {"owned": {id: true}, "equipped": {yuva: id}, "levels": {id: seviye}, "stock": {id: adet}}
## (anahtarlar String; ConfigFile'a olduğu gibi yazılır).

enum Status { BUYABLE, TOO_EXPENSIVE, OWNED, EQUIPPED, MAXED, STOCK_FULL, UNKNOWN }

const OWNED: String = "owned"
const EQUIPPED: String = "equipped"
const LEVELS: String = "levels"
const STOCK: String = "stock"


## Hiçbir şey alınmamış hâl.
static func empty_state() -> Dictionary:
	return {OWNED: {}, EQUIPPED: {}, LEVELS: {}, STOCK: {}}


## Kayıttan gelen ham veriyi temizler: bilinmeyen ürünler atılır, seviyeler/stoklar sınırlanır,
## sahip olunmayan ürün kuşanılmış sayılmaz.
static func sanitized(raw: Dictionary) -> Dictionary:
	var state: Dictionary = empty_state()
	for key: Variant in _dict(raw.get(OWNED)):
		var item: Dictionary = ShopCatalog.get_item(StringName(str(key)))
		if not item.is_empty() and ShopCatalog.is_slot(item["category"]):
			state[OWNED][str(key)] = true
	var levels: Dictionary = _dict(raw.get(LEVELS))
	for key: Variant in levels:
		var id := StringName(str(key))
		var item_level: int = clampi(_int(levels[key]), 0, ShopCatalog.max_level(id))
		if item_level > 0:
			state[LEVELS][str(key)] = item_level
	var stocks: Dictionary = _dict(raw.get(STOCK))
	for key: Variant in stocks:
		var count: int = clampi(_int(stocks[key]), 0, Tuning.SHOP_BOOST_MAX_STOCK)
		if count > 0 and ShopCatalog.get_item(StringName(str(key))).get("category", &"") == ShopCatalog.BOOST:
			state[STOCK][str(key)] = count
	var equipped_map: Dictionary = _dict(raw.get(EQUIPPED))
	for slot: StringName in ShopCatalog.SLOTS:
		var id := StringName(str(equipped_map.get(String(slot), "")))
		if ShopCatalog.get_item(id).get("category", &"") == slot and is_owned(state, id):
			state[EQUIPPED][String(slot)] = String(id)
	return state


## Kozmetik ürüne sahip mi? Ücretsiz varsayılanlar hep sahip olunur.
static func is_owned(state: Dictionary, id: StringName) -> bool:
	var item: Dictionary = ShopCatalog.get_item(id)
	if item.is_empty() or not ShopCatalog.is_slot(item["category"]):
		return false
	return int(item["price"]) == 0 or _dict(state.get(OWNED)).has(String(id))


## Yükseltmenin seviyesi (0 = alınmamış).
static func level(state: Dictionary, id: StringName) -> int:
	return _int(_dict(state.get(LEVELS)).get(String(id), 0))


## Takviyenin stoktaki adedi.
static func stock(state: Dictionary, id: StringName) -> int:
	return _int(_dict(state.get(STOCK)).get(String(id), 0))


## Yuvada kuşanılan ürün (seçilmemişse ya da geçersizse varsayılan).
static func equipped(state: Dictionary, slot: StringName) -> StringName:
	var id := StringName(str(_dict(state.get(EQUIPPED)).get(String(slot), "")))
	if ShopCatalog.get_item(id).get("category", &"") == slot and is_owned(state, id):
		return id
	return ShopCatalog.default_of(slot)


## Şimdi ödenecek fiyat: kozmetik/takviye sabit; yükseltmede sıradaki seviyenin fiyatı (son seviyedeyse -1).
static func price(state: Dictionary, id: StringName) -> int:
	var item: Dictionary = ShopCatalog.get_item(id)
	if item.is_empty():
		return -1
	if item["category"] == ShopCatalog.UPGRADE:
		var prices: Array = item["prices"]
		var current: int = level(state, id)
		return int(prices[current]) if current < prices.size() else -1
	return int(item["price"])


## Ürünün mağazadaki durumu (düğme yazısı ve satın alma denetimi bundan çıkar).
static func status(state: Dictionary, id: StringName, diamonds: int) -> Status:
	var item: Dictionary = ShopCatalog.get_item(id)
	if item.is_empty():
		return Status.UNKNOWN
	var category: StringName = item["category"]
	if ShopCatalog.is_slot(category):
		if equipped(state, category) == id:
			return Status.EQUIPPED
		if is_owned(state, id):
			return Status.OWNED
	elif category == ShopCatalog.UPGRADE and level(state, id) >= ShopCatalog.max_level(id):
		return Status.MAXED
	elif category == ShopCatalog.BOOST and stock(state, id) >= Tuning.SHOP_BOOST_MAX_STOCK:
		return Status.STOCK_FULL
	return Status.BUYABLE if diamonds >= price(state, id) else Status.TOO_EXPENSIVE


static func can_buy(state: Dictionary, id: StringName, diamonds: int) -> bool:
	return status(state, id, diamonds) == Status.BUYABLE


## Satın alma sonrası durum (elmas denetimi yapılmaz; önce can_buy). Kozmetik alınınca kuşanılır.
static func purchased(state: Dictionary, id: StringName) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	var item: Dictionary = ShopCatalog.get_item(id)
	if item.is_empty():
		return result
	var category: StringName = item["category"]
	if ShopCatalog.is_slot(category):
		result[OWNED][String(id)] = true
		result[EQUIPPED][String(category)] = String(id)
	elif category == ShopCatalog.UPGRADE:
		result[LEVELS][String(id)] = mini(level(state, id) + 1, ShopCatalog.max_level(id))
	elif category == ShopCatalog.BOOST:
		result[STOCK][String(id)] = mini(stock(state, id) + 1, Tuning.SHOP_BOOST_MAX_STOCK)
	return result


## Sahip olunan kozmetiği kuşanır (sahip değilse durum değişmez).
static func with_equipped(state: Dictionary, id: StringName) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	if is_owned(state, id):
		result[EQUIPPED][String(ShopCatalog.get_item(id)["category"])] = String(id)
	return result


## Stoktan bir takviye düşer (yoksa durum değişmez).
static func with_boost_used(state: Dictionary, id: StringName) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	var left: int = stock(state, id) - 1
	if left > 0:
		result[STOCK][String(id)] = left
	else:
		result[STOCK].erase(String(id))
	return result


static func _dict(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


static func _int(value: Variant) -> int:
	return int(value) if value is int or value is float else 0
