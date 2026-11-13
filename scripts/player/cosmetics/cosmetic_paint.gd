class_name CosmeticPaint
extends RefCounted
## Tişört ve pantolonu karakterin toon malzemesinde boyar (toon_character.gdshader uniform'ları).
## Model tek parça / tek dokulu: kesim değişmez, bölge maskesi + dinlenme konumu haritasıyla renk ve
## desen değişir (iki doku tools/blender/cosmetic_maps.py ile üretilir, eagle_hero.glb ile aynı UV).

const MASK_PATH: String = "res://assets/models/eagle_hero_cosmetic_mask.png"
const POSITION_PATH: String = "res://assets/models/eagle_hero_rest_position.png"


static func is_available() -> bool:
	return ResourceLoader.exists(MASK_PATH) and ResourceLoader.exists(POSITION_PATH)


## Malzemeye maske ve konum dokularını verir; boyama kapalı başlar (özgün görünüm).
static func setup(material: ShaderMaterial) -> void:
	if not is_available():
		return
	material.set_shader_parameter(&"cosmetic_mask", load(MASK_PATH))
	material.set_shader_parameter(&"rest_position", load(POSITION_PATH))


## Yuvanın ürününü uygular (SHIRT / PANTS; diğer yuvalar yok sayılır).
static func apply(material: ShaderMaterial, slot: StringName, id: StringName) -> void:
	var usable: bool = Tuning.COSMETICS_ENABLED and is_available()
	match slot:
		ShopCatalog.SHIRT:
			var shirt: Dictionary = CosmeticRules.shirt_paint(id)
			material.set_shader_parameter(&"shirt_enabled", usable and shirt["enabled"])
			material.set_shader_parameter(&"shirt_color", shirt["color"])
			material.set_shader_parameter(&"shirt_color2", shirt["color2"])
			material.set_shader_parameter(&"shirt_pattern", shirt["pattern"])
		ShopCatalog.PANTS:
			var pants: Dictionary = CosmeticRules.pants_paint(id)
			material.set_shader_parameter(&"pants_enabled", usable and pants["enabled"])
			material.set_shader_parameter(&"pants_color", pants["color"])
