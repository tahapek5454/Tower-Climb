extends Node
## Elmas mağazasının durumu: sahip olunanlar, kuşanılanlar, yükseltme seviyeleri, takviye stoğu.
## Kurallar ShopRules'ta (saf), ürünler ShopCatalog'da, kayıt SaveData [shop], elmas GameState'te.
## Tuning.SHOP_ENABLED kapalıysa her şey varsayılana döner (kozmetik yok, seviye 0, stok 0).

var _state: Dictionary = ShopRules.empty_state()


func _ready() -> void:
	reload()


## Durumu kayıttan yeniden okur (testlerde SaveData.path değiştirildikten sonra çağrılır).
func reload() -> void:
	_state = ShopRules.sanitized(SaveData.load_shop())


## Mağaza ekranı için durumun kopyası (ShopRules fonksiyonlarına verilir).
func state() -> Dictionary:
	return _state.duplicate(true) if Tuning.SHOP_ENABLED else ShopRules.empty_state()


func status(id: StringName) -> ShopRules.Status:
	return ShopRules.status(state(), id, GameState.diamonds)


## Şimdi ödenecek fiyat (yükseltmede sıradaki seviye; son seviyedeyse -1).
func price(id: StringName) -> int:
	return ShopRules.price(state(), id)


## Yuvada kuşanılan ürünün kimliği / tanımı.
func equipped(slot: StringName) -> StringName:
	return ShopRules.equipped(state(), slot)


func equipped_item(slot: StringName) -> Dictionary:
	return ShopCatalog.get_item(equipped(slot))


func upgrade_level(id: StringName) -> int:
	return ShopRules.level(state(), id)


func boost_stock(id: StringName) -> int:
	return ShopRules.stock(state(), id)


## Satın alır: elmas düşer, durum kaydedilir, kozmetik hemen kuşanılır. Alınamadıysa false.
func buy(id: StringName) -> bool:
	if not Tuning.SHOP_ENABLED or not ShopRules.can_buy(_state, id, GameState.diamonds):
		return false
	if not GameState.spend_diamonds(ShopRules.price(_state, id)):
		return false
	_state = ShopRules.purchased(_state, id)
	SaveData.save_shop(_state)
	Events.shop_purchased.emit(id)
	_announce_equipped(id)
	return true


## Sahip olunan kozmetiği kuşanır. Kuşanılamadıysa false.
func equip(id: StringName) -> bool:
	if not Tuning.SHOP_ENABLED or not ShopRules.is_owned(_state, id):
		return false
	_state = ShopRules.with_equipped(_state, id)
	SaveData.save_shop(_state)
	_announce_equipped(id)
	return true


## Stoktan bir takviye kullanır (tur başında). Stok yoksa false.
func consume_boost(id: StringName) -> bool:
	if boost_stock(id) <= 0:
		return false
	_state = ShopRules.with_boost_used(_state, id)
	SaveData.save_shop(_state)
	return true


func _announce_equipped(id: StringName) -> void:
	var category: StringName = ShopCatalog.get_item(id)["category"]
	if ShopCatalog.is_slot(category):
		Events.shop_equipped.emit(category, id)
