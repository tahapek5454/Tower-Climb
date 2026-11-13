class_name BoostBadge
extends HBoxContainer
## Ana menüde stoktaki takviyeler: küçük kalp / roket simgesi + adet ("×2"). Stok yoksa görünmez.
## Satın alınca (Events.shop_purchased) kendini yeniler; kullanım tur başında olur (sahne zaten yenilenir).

const HEART_SCALE: float = 0.42
const ROCKET_SCALE: float = 0.42
## Elmas sayısından ayıran boşluk (px).
const LEAD_GAP: float = 10.0

var _font_size: int
var _counts: Dictionary = {}


func _init(font_size: int) -> void:
	_font_size = font_size
	add_theme_constant_override(&"separation", 3)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var gap := Control.new()
	gap.custom_minimum_size.x = LEAD_GAP
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gap)
	_add_entry(ShopCatalog.BOOST_HEART, _draw_heart)
	_add_entry(ShopCatalog.BOOST_ROCKET, _draw_rocket)


func _ready() -> void:
	refresh()
	Events.shop_purchased.connect(func(_id: StringName) -> void: refresh())


## Adetleri Shop'tan yeniden okur.
func refresh() -> void:
	var any: bool = false
	for id: StringName in _counts:
		var stock: int = Shop.boost_stock(id)
		var label: Label = _counts[id]
		label.text = "×%d" % stock
		label.get_parent().visible = stock > 0
		any = any or stock > 0
	visible = any


func shown_stock(id: StringName) -> String:
	var label: Label = _counts[id]
	return label.text if label.get_parent().visible else ""


func _add_entry(id: StringName, drawer: Callable) -> void:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override(&"separation", 1)
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := Control.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.custom_minimum_size = Vector2(18.0, 20.0)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.draw.connect(drawer.bind(icon))
	entry.add_child(icon)
	var label: Label = UiStyle.label(_font_size, UiStyle.TEXT_DIM)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	entry.add_child(label)
	add_child(entry)
	_counts[id] = label


func _draw_heart(icon: Control) -> void:
	HeartArt.draw(icon, icon.size * 0.5, HEART_SCALE)


func _draw_rocket(icon: Control) -> void:
	icon.draw_set_transform(icon.size * 0.5, 0.0, Vector2.ONE * ROCKET_SCALE)
	JetpackArt.draw(icon, 0.35)
	icon.draw_set_transform_matrix(Transform2D.IDENTITY)
