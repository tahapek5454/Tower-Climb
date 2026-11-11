class_name CharacterModel
extends Node2D
## 3D karakter modelini şeffaf bir SubViewport'ta yandan çizer ve 2D'de bir Sprite2D ile gösterir.
## Orijin modelin ayaklarındadır (PlayerVisual'daki Squash düğümüne takılır).
## Sadece görüntü: hangi animasyonun oynayacağına PlayerVisual karar verir.

const MODEL_PATH: String = "res://assets/models/eagle_hero.glb"
const TOON_SHADER: Shader = preload("res://assets/shaders/toon_character.gdshader")
const OUTLINE_SHADER: Shader = preload("res://assets/shaders/toon_outline.gdshader")
## Döngülü oynaması gereken animasyonlar (glb döngü bilgisini taşımıyor).
const LOOPING: Array[StringName] = [&"idle", &"run", &"fall"]
## Kamera modelin yanında, bu uzaklıkta durur (ortografik: uzaklık görüntüyü değiştirmez).
const CAMERA_DISTANCE: float = 5.0

var _pivot: Node3D
var _animation_player: AnimationPlayer
var _target_yaw: float = 0.0
var _requested: StringName = &""
var _facing: float = 1.0
var _front_view: bool = false


## Model dosyası projede var mı? Yoksa PlayerVisual kutu gövdeye döner.
static func is_available() -> bool:
	return ResourceLoader.exists(MODEL_PATH)


func _ready() -> void:
	_build()
	set_facing(1.0, true)
	play(&"idle")


func _process(delta: float) -> void:
	var weight: float = 1.0 - exp(-Tuning.MODEL_TURN_RATE * delta)
	_pivot.rotation.y = lerp_angle(_pivot.rotation.y, _target_yaw, weight)


## direction: +1 sağa, -1 sola bakar. Model kameraya doğru hafif dönük durur.
func set_facing(direction: float, instant: bool = false) -> void:
	_facing = 1.0 if direction >= 0.0 else -1.0
	_update_target_yaw()
	if instant:
		_pivot.rotation.y = _target_yaw


## true: model tam kameraya döner (önden görünüm); false: yön görünümüne geri döner.
func set_front_view(enabled: bool) -> void:
	if enabled == _front_view:
		return
	_front_view = enabled
	_update_target_yaw()


func _update_target_yaw() -> void:
	# Model +Z'ye bakar; kamera -X tarafında. Sola dönüş kameranın önünden geçer.
	var view_angle: float = deg_to_rad(Tuning.MODEL_VIEW_ANGLE_DEGREES)
	if _front_view:
		_target_yaw = -PI * 0.5
	else:
		_target_yaw = -view_angle if _facing > 0.0 else -(PI - view_angle)


func has_animation(animation: StringName) -> bool:
	return _animation_player != null and _animation_player.has_animation(animation)


func animation_length(animation: StringName) -> float:
	return _animation_player.get_animation(animation).length if has_animation(animation) else 0.0


## Aynı animasyon zaten istenmişse baştan başlatmaz (her karede çağrılabilir).
func play(animation: StringName, blend_time: float = Tuning.MODEL_ANIM_BLEND_TIME) -> void:
	if animation == _requested or not has_animation(animation):
		return
	_requested = animation
	_animation_player.play(animation, blend_time)


func set_speed(speed: float) -> void:
	if _animation_player != null:
		_animation_player.speed_scale = speed


func _build() -> void:
	var frame_px: float = Tuning.MODEL_HEIGHT * Tuning.MODEL_FRAME_RATIO
	var render_px: int = roundi(frame_px * Tuning.MODEL_RENDER_SCALE)

	var viewport := SubViewport.new()
	viewport.name = "ModelViewport"
	viewport.size = Vector2i(render_px, render_px)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	_pivot = Node3D.new()
	_pivot.name = "Pivot"
	viewport.add_child(_pivot)
	var scene: PackedScene = load(MODEL_PATH) as PackedScene
	var model: Node = scene.instantiate()
	_pivot.add_child(model)
	_animation_player = _find_animation_player(model)
	_setup_loops()
	_apply_toon_materials(model)

	_build_camera(viewport)

	var sprite := Sprite2D.new()
	sprite.name = "ModelSprite"
	sprite.texture = viewport.get_texture()
	sprite.scale = Vector2.ONE / Tuning.MODEL_RENDER_SCALE
	# Çerçevenin ortası modelin ortasına (boyun yarısı) denk gelir; ayaklar orijinde kalır.
	sprite.position = Vector2(0.0, -Tuning.MODEL_HEIGHT * 0.5)
	add_child(sprite)


## Model 1 birim boyundadır; çerçeve, kol/kuyruk hareketleri sığsın diye ondan büyüktür.
func _build_camera(viewport: SubViewport) -> void:
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = Tuning.MODEL_FRAME_RATIO
	camera.position = Vector3(-CAMERA_DISTANCE, 0.5, 0.0)
	camera.rotation.y = -PI * 0.5
	camera.near = 0.1
	camera.far = CAMERA_DISTANCE * 2.0
	viewport.add_child(camera)
	camera.make_current()


## Modelin kendi malzemesi yerine toon shader + dış çizgi geçişi kullanılır; doku aynı kalır.
func _apply_toon_materials(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		var outline := ShaderMaterial.new()
		outline.shader = OUTLINE_SHADER
		outline.set_shader_parameter(&"outline_color", Tuning.MODEL_OUTLINE_COLOR)
		outline.set_shader_parameter(&"outline_width", Tuning.MODEL_OUTLINE_WIDTH)
		for surface in mesh_instance.mesh.get_surface_count():
			var source: BaseMaterial3D = mesh_instance.mesh.surface_get_material(surface) as BaseMaterial3D
			var toon := ShaderMaterial.new()
			toon.shader = TOON_SHADER
			if source != null:
				toon.set_shader_parameter(&"albedo_texture", source.albedo_texture)
			toon.set_shader_parameter(&"rim_color", Tuning.MODEL_RIM_COLOR)
			toon.set_shader_parameter(&"rim_strength", Tuning.MODEL_RIM_STRENGTH)
			toon.set_shader_parameter(&"shadow_tint", Tuning.MODEL_SHADOW_TINT)
			toon.next_pass = outline
			mesh_instance.set_surface_override_material(surface, toon)
	for child in node.get_children():
		_apply_toon_materials(child)


func _setup_loops() -> void:
	if _animation_player == null:
		return
	for animation_name in LOOPING:
		if _animation_player.has_animation(animation_name):
			_animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found: AnimationPlayer = _find_animation_player(child)
		if found != null:
			return found
	return null
