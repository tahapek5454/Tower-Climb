class_name WallDecor
extends Node2D
## Kule iç duvarındaki süsler (meşale, pencere, sancak, flama dizisi). Yerleşim WallDecorRules'ta,
## çizim WallDecorArt'ta. Süsler arka duvar deseniyle aynı parallax oranında kayar (duvara asılı
## görünsün): düğümün kendisi kaydırılır, çocuklar "duvar uzayında" durur. Sadece ekrana yakın
## yuvaların süsleri var; uzaklaşanlar silinir.

## Yuva -> süs düğümü.
var _items: Dictionary = {}


func _ready() -> void:
	# Arka plan öğesi: platformlardan ve karakterden hafifçe geri çekilsin.
	modulate = Tuning.WALL_DECOR_TINT


func _process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	var view_top: float = camera.get_screen_center_position().y - Tuning.VIEW_HEIGHT * 0.5
	var rest_top: float = Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT
	position.y = (view_top - rest_top) * (1.0 - Tuning.INTERIOR_PARALLAX)
	var margin: float = Tuning.WALL_DECOR_VIEW_MARGIN
	var range_slots: Vector2i = WallDecorRules.slots_between(view_top - position.y - margin,
			view_top + Tuning.VIEW_HEIGHT - position.y + margin)
	_remove_outside(range_slots)
	for slot: int in range(range_slots.x, range_slots.y + 1):
		if not _items.has(slot):
			_items[slot] = _make_item(slot)


func _make_item(slot: int) -> Node2D:
	var item: Dictionary = WallDecorRules.slot_item(slot)
	if item.is_empty():
		return null
	var node := WallDecorItem.new()
	node.setup(item)
	node.position = Vector2(item[&"x"], item[&"y"])
	add_child(node)
	return node


func _remove_outside(range_slots: Vector2i) -> void:
	for slot: int in _items.keys():
		if slot < range_slots.x or slot > range_slots.y:
			var node: Node2D = _items[slot]
			if node != null:
				node.queue_free()
			_items.erase(slot)
