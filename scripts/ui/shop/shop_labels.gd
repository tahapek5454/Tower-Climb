class_name ShopLabels
extends RefCounted
## Mağaza ekranının saf yardımcıları: ürün durumundan düğme yazısı ve eylem, sekme gezinmesi,
## önizlemede denenen kozmetikler. Autoload'a ve sahneye dokunmaz (GUT ile test edilir).

## Satıra basınca ne olacağı.
enum Action { BUY, EQUIP, DENY, NONE }


## Durumun düğme yazısı (yetmiyorsa da "Al" yazar; soluk gösterilir).
static func action_text(status: ShopRules.Status) -> String:
	match status:
		ShopRules.Status.BUYABLE, ShopRules.Status.TOO_EXPENSIVE:
			return "Al"
		ShopRules.Status.OWNED:
			return "Kuşan"
		ShopRules.Status.EQUIPPED:
			return "Kuşanıldı"
		ShopRules.Status.MAXED:
			return "Tam"
		ShopRules.Status.STOCK_FULL:
			return "Dolu"
	return ""


static func action_for(status: ShopRules.Status) -> Action:
	match status:
		ShopRules.Status.BUYABLE:
			return Action.BUY
		ShopRules.Status.OWNED:
			return Action.EQUIP
		ShopRules.Status.TOO_EXPENSIVE, ShopRules.Status.MAXED, ShopRules.Status.STOCK_FULL:
			return Action.DENY
	return Action.NONE


## Fiyat gösterilir mi (alınmamış / alınabilir ürünler).
static func shows_price(status: ShopRules.Status) -> bool:
	return status == ShopRules.Status.BUYABLE or status == ShopRules.Status.TOO_EXPENSIVE


## Sekme sırasında bir adım (dönerek): direction -1 sola, +1 sağa.
static func wrap_index(index: int, direction: int, count: int) -> int:
	if count <= 0:
		return 0
	return posmod(index + direction, count)


## Önizlemede modelde görünecek kozmetikler: odaktaki ürün bir model yuvasındaysa onun yerine o,
## diğer yuvalarda kuşanılı olan. equipped: {yuva: kimlik}; focused_id boşsa yalnız kuşanılılar.
static func try_on(equipped: Dictionary, focused_id: StringName) -> Dictionary:
	var result: Dictionary = {}
	var focused_slot: StringName = ShopCatalog.get_item(focused_id).get("category", &"")
	for slot: StringName in ShopCatalog.MODEL_SLOTS:
		result[slot] = focused_id if slot == focused_slot else equipped.get(slot, ShopCatalog.default_of(slot))
	return result


## Odaktaki üründen önizlemede gösterilecek efekt (iz) ürünü; efekt değilse kuşanılı olan.
static func trail_preview(equipped_trail: StringName, focused_id: StringName) -> StringName:
	if ShopCatalog.get_item(focused_id).get("category", &"") == ShopCatalog.TRAIL:
		return focused_id
	return equipped_trail
