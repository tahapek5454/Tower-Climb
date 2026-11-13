class_name HatModel
extends Node3D
## Kafaya takılan şapka (CharacterModel bunu `head` kemiğine bağlar). Şapkalar Blender'da kodla
## modellenir (tools/blender/accessories.py → assets/models/accessories.glb); her şapka kimliğiyle aynı adlı
## düğümdür, orijini kafa kemiğinin başında. Burada karakterle aynı çizgi film gölgelemesi + dış çizgi
## verilir; renk glb'deki malzemenin taban rengidir.
## Canlılık: takılırken büyüyerek belirir, "_spin" parçalar döner, "_sway" parçalar yayla sallanır.

const SCENE_PATH: String = "res://assets/models/accessories.glb"
const FLAT_SHADER: Shader = preload("res://assets/shaders/toon_flat.gdshader")
const OUTLINE_SHADER: Shader = preload("res://assets/shaders/toon_outline.gdshader")

var _hat_id: StringName = &""
var _hat: Node3D
var _pop: Tween
var _spinners: Array[Node3D] = []
var _swingers: Array[Node3D] = []
var _sway_rest: Array[Basis] = []
## Her sallanan parça için açı (x: öne-arkaya, y: yana) ve açısal hız.
var _sway_angle: Array[Vector2] = []
var _sway_velocity: Array[Vector2] = []
var _last_position: Vector3
var _last_velocity: Vector3
var _time: float = 0.0


static func is_available() -> bool:
	return ResourceLoader.exists(SCENE_PATH)


## glb'deki şapka düğümlerinin adları (test ve doğrulama için).
static func hat_names() -> PackedStringArray:
	var names := PackedStringArray()
	var library: Node = _instantiate_library()
	if library == null:
		return names
	for child in library.get_children():
		names.append(String(child.name))
	library.free()
	return names


## glb sahnesinin bir kopyası (çağıran serbest bırakır); dosya yoksa null.
static func _instantiate_library() -> Node:
	if not is_available():
		return null
	var scene: PackedScene = load(SCENE_PATH) as PackedScene
	return scene.instantiate() if scene != null else null


## Şapkayı değiştirir (boş ad / şapkasız → çıkarır). animate: küçükten büyüyerek belirsin.
func show_hat(id: StringName, animate: bool = true) -> void:
	var node_name: String = CosmeticRules.hat_node_name(id)
	if StringName(node_name) == _hat_id:
		return
	_hat_id = StringName(node_name)
	_clear()
	if node_name.is_empty():
		return
	var library: Node = _instantiate_library()
	if library == null:
		return
	var source: Node3D = library.get_node_or_null(NodePath(node_name)) as Node3D
	if source != null:
		library.remove_child(source)
		_set_owner_recursive(source)
		_hat = source
		add_child(_hat)
	library.free()
	if _hat == null:
		return
	_prepare(_hat)
	_pop_in(animate)


static func _set_owner_recursive(node: Node) -> void:
	node.owner = null
	for child in node.get_children():
		_set_owner_recursive(child)


func current_hat() -> StringName:
	return _hat_id


func _process(delta: float) -> void:
	if _hat == null or delta <= 0.0:
		return
	_time += delta
	var spin: float = TAU * Tuning.HAT_PROPELLER_SPEED * delta
	for spinner in _spinners:
		spinner.rotate_object_local(Vector3.UP, spin)
	if not _swingers.is_empty():
		_update_sway(delta)


func _clear() -> void:
	if _pop != null:
		_pop.kill()
	if _hat != null:
		_hat.queue_free()
		_hat = null
	_spinners.clear()
	_swingers.clear()
	_sway_rest.clear()
	_sway_angle.clear()
	_sway_velocity.clear()
	_time = 0.0


func _pop_in(animate: bool) -> void:
	# Şapkanın orijini kafanın içinde (kemik başı): şapka kafadan "fışkırır".
	if not animate:
		return
	_hat.scale = Vector3.ONE * 0.01
	_pop = create_tween()
	_pop.tween_property(_hat, ^"scale", Vector3.ONE, Tuning.HAT_POP_TIME) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Malzemeleri çizgi film gölgelemesine çevirir, hareketli parçaları toplar.
func _prepare(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		for surface in mesh_instance.mesh.get_surface_count():
			var source: BaseMaterial3D = mesh_instance.mesh.surface_get_material(surface) as BaseMaterial3D
			var color: Color = source.albedo_color if source != null else Color.WHITE
			mesh_instance.set_surface_override_material(surface, _toon_material(color))
	var node_name: String = String(node.name)
	if node_name.ends_with(CosmeticRules.SPIN_SUFFIX):
		_spinners.append(node as Node3D)
	elif node_name.ends_with(CosmeticRules.SWAY_SUFFIX):
		_swingers.append(node as Node3D)
		_sway_rest.append((node as Node3D).basis)
		_sway_angle.append(Vector2.ZERO)
		_sway_velocity.append(Vector2.ZERO)
	for child in node.get_children():
		_prepare(child)


func _toon_material(color: Color) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter(&"outline_color", Tuning.MODEL_OUTLINE_COLOR)
	outline.set_shader_parameter(&"outline_width", Tuning.MODEL_OUTLINE_WIDTH)
	var material := ShaderMaterial.new()
	material.shader = FLAT_SHADER
	material.set_shader_parameter(&"base_color", color)
	material.set_shader_parameter(&"rim_color", Tuning.MODEL_RIM_COLOR)
	material.set_shader_parameter(&"rim_strength", Tuning.MODEL_RIM_STRENGTH)
	material.set_shader_parameter(&"shadow_tint", Tuning.MODEL_SHADOW_TINT)
	material.next_pass = outline
	return material


## İkincil hareket: şapkanın ivmesi sallanan parçayı ters yöne iter, yay geri çeker; boşta hafif salınır.
func _update_sway(delta: float) -> void:
	# Şapkanın orijini kafa kemiğinin başında: kafanın hareketi ölçülür.
	var position_now: Vector3 = _hat.global_position
	var velocity: Vector3 = (position_now - _last_position) / delta
	var acceleration: Vector3 = (velocity - _last_velocity) / delta
	if _time <= delta * 2.0:
		acceleration = Vector3.ZERO
	_last_position = position_now
	_last_velocity = velocity
	var local: Vector3 = _hat.global_basis.orthonormalized().inverse() * acceleration
	var push := Vector2(-local.z, local.x) * Tuning.HAT_SWAY_RESPONSE * 0.01
	var idle: float = sin(_time * TAU / Tuning.HAT_SWAY_IDLE_PERIOD) * Tuning.HAT_SWAY_IDLE_ANGLE
	for i in _swingers.size():
		var target := Vector2(idle, idle * 0.5)
		var force: Vector2 = (target - _sway_angle[i]) * Tuning.HAT_SWAY_STIFFNESS \
				- _sway_velocity[i] * Tuning.HAT_SWAY_DAMPING + push * Tuning.HAT_SWAY_STIFFNESS
		_sway_velocity[i] += force * delta
		_sway_angle[i] = (_sway_angle[i] + _sway_velocity[i] * delta).limit_length(Tuning.HAT_SWAY_MAX_ANGLE)
		var swing := Basis(Vector3.RIGHT, _sway_angle[i].x) * Basis(Vector3.BACK, _sway_angle[i].y)
		_swingers[i].basis = swing * _sway_rest[i]
