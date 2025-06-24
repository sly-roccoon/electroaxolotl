extends RigidBody3D
class_name SoundParticle

@onready var collisionshape := $CollisionShape3D
@onready var meshinstance := $CollisionShape3D/MeshInstance3D
@onready var light := $CollisionShape3D/OmniLight3D

@onready var collision_sender := $CollisionChecker/CollisionShape3D

var player : CharacterBody3D
var camera : Camera3D

var just_spawned: bool = true

@onready var torus : CSGTorus3D = $Torus

var should_fizzle : bool
var timer : Timer

var continuous : bool = false

func getData() -> Array:
	var cam_pos = camera.global_position
	
	# var azim = camera.global_rotation.y
	# var elev = camera.global_rotation.x
	
	var dist = cam_pos.distance_to(global_position)
	var dir = (global_position - cam_pos).normalized()
	
	var local_dir = camera.global_transform.basis.inverse() * dir

	var azim = atan2(-local_dir.x, -local_dir.z)
	var elev = asin(local_dir.y)

	var size : float = collisionshape.scale.x
	var cur_speed : float = linear_velocity.length()
	return [get_instance_id(), azim, elev, dist, size, cur_speed]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	camera = player.get_node("Camera3D")
	
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
	collision_sender.scale = collisionshape.scale * 1.2
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
