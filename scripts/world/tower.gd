class_name Tower
extends Node2D
## Kule: sol/sağ duvarlar ve zemin. Dünya orijini: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y.
## Duvarlar kamerayı dikeyde takip eder; böylece kule sonsuz görünür.

const WALL_COLOR := Color(0.16, 0.18, 0.26)
const GROUND_COLOR := Color(0.35, 0.40, 0.55)
const INTERIOR_COLOR := Color(0.09, 0.10, 0.15)

var _walls: Node2D


func _ready() -> void:
	_walls = Node2D.new()
	_walls.name = "Walls"
	add_child(_walls)

	var interior_size := Vector2(Tuning.TOWER_WIDTH, Tuning.WALL_HEIGHT)
	_walls.add_child(_make_rect_visual(interior_size, INTERIOR_COLOR))

	var wall_size := Vector2(Tuning.WALL_THICKNESS, Tuning.WALL_HEIGHT)
	var wall_x: float = (Tuning.TOWER_WIDTH + Tuning.WALL_THICKNESS) * 0.5
	_walls.add_child(_make_body("LeftWall", Vector2(-wall_x, 0.0), wall_size, WALL_COLOR))
	_walls.add_child(_make_body("RightWall", Vector2(wall_x, 0.0), wall_size, WALL_COLOR))

	var ground_size := Vector2(Tuning.TOWER_WIDTH, Tuning.PLATFORM_THICKNESS)
	var ground_pos := Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	add_child(_make_body("Ground", ground_pos, ground_size, GROUND_COLOR))


func _physics_process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		_walls.position.y = camera.get_screen_center_position().y


## Ortalanmış dikdörtgen çarpışma gövdesi + görseli.
func _make_body(body_name: String, pos: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = pos

	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)

	body.add_child(_make_rect_visual(size, color))
	return body


func _make_rect_visual(size: Vector2, color: Color) -> Polygon2D:
	var half: Vector2 = size * 0.5
	var polygon := Polygon2D.new()
	polygon.color = color
	polygon.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	return polygon
