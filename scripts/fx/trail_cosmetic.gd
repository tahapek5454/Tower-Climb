class_name TrailCosmetic
extends RefCounted
## Efekt kozmetiği yardımcıları (saf): ürün alanlarından stil, gökkuşağı rengi ve renk boyama.


## Ürün sözlüğünden (bilinmeyen/boş → varsayılan ürün) stil.
static func style_of(item: Dictionary) -> StringName:
	return item.get("style", ShopCatalog.STYLE_PLAIN)


## Bilinmeyen kimlik varsayılan ürüne düşer.
static func resolve(id: StringName) -> Dictionary:
	if ShopCatalog.has_item(id) and ShopCatalog.get_item(id).get("category") == ShopCatalog.TRAIL:
		return ShopCatalog.get_item(id)
	return ShopCatalog.get_item(ShopCatalog.default_of(ShopCatalog.TRAIL))


## Gökkuşağı: zamanla dönen pastel ton. offset: ton kayması (tur cinsinden, iz boyunca).
static func rainbow_color(time: float, offset: float = 0.0) -> Color:
	var hue: float = fposmod(time / Tuning.TRAIL_RAINBOW_PERIOD + offset, 1.0)
	return Color.from_hsv(hue, Tuning.TRAIL_RAINBOW_SATURATION, Tuning.TRAIL_RAINBOW_VALUE)


## İzin (gövdedeki uç) rengi: gökkuşağında zamana bağlı, diğerlerinde `color`.
static func head_color(item: Dictionary, time: float) -> Color:
	if style_of(item) == ShopCatalog.STYLE_RAINBOW:
		return rainbow_color(time)
	return item["color"]


## Temel rengi hedef renge `amount` kadar boyar (amount 0 → değişmez).
static func tint(base: Color, target: Color, amount: float) -> Color:
	return base.lerp(target, amount)
