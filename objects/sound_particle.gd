extends RigidBody3D
class_name SoundParticle

@onready var collisionshape := $CollisionShape3D
@onready var meshinstance := $CollisionShape3D/MeshInstance3D
@onready var light := $CollisionShape3D/OmniLight3D

@onready var torus : CSGTorus3D = $Torus

var should_fizzle : bool
var timer : Timer

var continuous : bool = false

func getData() -> Array:
	var x = global_position.x
	var y = global_position.y
	var z = global_position.z
	
	var size : float = collisionshape.scale.x
	var cur_speed : float = linear_velocity.length()
	return [x, y, z, size, cur_speed]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var phys_mat = PhysicsMaterial.new()
	phys_mat.bounce = 1.0
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	angular_damp = 0.0
	physics_material_override = phys_mat

	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "fizzle"))

func fizzle() -> void:
	var mat : ORMMaterial3D = meshinstance.get_active_material(0)

	var tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "queue_free"))

func shoot(dir: Vector3, speed: float = 20.0, size: float = 1.0, time: float = 60.0, is_continuous: bool = false) -> void:
	continuous = is_continuous
	if !is_continuous: torus.queue_free()
	if is_continuous: assert(get_node("Torus") != null)
	
	randomize_color()
	collisionshape.scale = Vector3.ONE * size
	linear_velocity = dir * speed
	light.omni_range = size
	
	timer.wait_time = time
	timer.start()

func randomize_color() -> void:
	var material : ORMMaterial3D = ORMMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	material.albedo_color = Color(Color.WHITE, 0.8)
	material.emission_enabled = true
	material.emission = Color(randf(), randf(), randf(), 0.4)
	if continuous: torus.material_override = material
	meshinstance.material_override = material

func _on_body_entered(body: Node) -> void:
	print("yas")
	pass # Replace with function body.
