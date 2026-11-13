class_name CosmeticRules
extends RefCounted
## Giyilebilir kozmetiklerin saf kuralları: kimliği doğrulama, şapka düğümü adı, kıyafet boyama verisi.
## Renk/desen verisi ShopCatalog'dan okunur (kodda renk tekrarı yok).

## Shader'daki desen numaraları (toon_character.gdshader: shirt_pattern).
const PATTERN_INDEX: Dictionary = {
	ShopCatalog.PATTERN_PLAIN: 0, ShopCatalog.PATTERN_STRIPES: 1,
	ShopCatalog.PATTERN_DOTS: 2, ShopCatalog.PATTERN_STAR: 3,
}
## Şapkanın hareketli parçalarının ad sonekleri (accessories.glb; tools/blender/accessories.py).
const SPIN_SUFFIX: String = "_spin"
const SWAY_SUFFIX: String = "_sway"


## Yuvaya uygun kimliği döndürür: bilinmeyen ya da başka yuvanın ürünü → yuvanın varsayılanı.
static func resolve(slot: StringName, id: StringName) -> StringName:
	var item: Dictionary = ShopCatalog.get_item(id)
	if item.is_empty() or item["category"] != slot:
		return ShopCatalog.default_of(slot)
	return id


static func is_default(slot: StringName, id: StringName) -> bool:
	return resolve(slot, id) == ShopCatalog.default_of(slot)


## accessories.glb içindeki şapka düğümünün adı; şapkasız (ya da geçersiz) için boş.
static func hat_node_name(id: StringName) -> String:
	var hat: StringName = resolve(ShopCatalog.HAT, id)
	if hat == ShopCatalog.default_of(ShopCatalog.HAT):
		return ""
	return String(hat)


static func pattern_index(pattern: StringName) -> int:
	return PATTERN_INDEX.get(pattern, 0)


## Tişört boyama verisi: {enabled, color, color2, pattern}. Varsayılan üründe boyama kapalı
## (özgün doku olduğu gibi görünür).
static func shirt_paint(id: StringName) -> Dictionary:
	var shirt: StringName = resolve(ShopCatalog.SHIRT, id)
	var item: Dictionary = ShopCatalog.get_item(shirt)
	var color: Color = item.get("color", Color.WHITE)
	return {
		"enabled": shirt != ShopCatalog.default_of(ShopCatalog.SHIRT),
		"color": color,
		"color2": item.get("color2", color),
		"pattern": pattern_index(item.get("pattern", ShopCatalog.PATTERN_PLAIN)),
	}


## Pantolon boyama verisi: {enabled, color}. Varsayılanda kapalı.
static func pants_paint(id: StringName) -> Dictionary:
	var pants: StringName = resolve(ShopCatalog.PANTS, id)
	return {
		"enabled": pants != ShopCatalog.default_of(ShopCatalog.PANTS),
		"color": ShopCatalog.get_item(pants).get("color", Color.WHITE),
	}
