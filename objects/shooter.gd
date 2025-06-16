extends Marker3D

@export var ProjectileScene: PackedScene

enum Tools {
	PARTICLE_COLLISION,
	PARTICLE_CONTINUOUS,
	POLYGON,
	RAY,
	REMOVE
}

var speed := 20.0
const scaling_factor := 1.1
const min_speed := 1.0
const max_speed := 50.0

var size := 1.0
const min_size := 0.1
const max_size := 5.0

var time := 60.0
const min_time := 1.0
const max_time := 300.0

var is_continuous : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func handleInput(event: InputEvent, type: Tools = Tools.PARTICLE_COLLISION) -> void:
	var ctrl_held := Input.is_key_pressed(KEY_CTRL)
	var shift_held := Input.is_key_pressed(KEY_SHIFT)
	
	if type == Tools.PARTICLE_CONTINUOUS:
		is_continuous = true
	else:
		is_continuous = false
	
	if event.is_action_pressed("incr"):
		if ctrl_held:
			size *= scaling_factor
		elif shift_held:
			time *= scaling_factor
		else:
			speed *= scaling_factor
	elif event.is_action_pressed("decr"):
		if ctrl_held:
			size /= scaling_factor
		elif shift_held:
			time /= scaling_factor
		else:
			speed /= scaling_factor
	
	speed = clamp(speed, min_speed, max_speed)
	size = clamp(size, min_size, max_size)
	time = clamp(time, min_time, max_time)
	
	if event.is_action_pressed("shoot"):
		shoot_projectile()
		
func shoot_projectile() -> void:
	var projectile := ProjectileScene.instantiate()
	var particles_group = get_tree().current_scene.find_child("Particles")
	particles_group.add_child(projectile)
	projectile.body_entered.connect(particles_group._on_particle_collision.bind(projectile))
	projectile.position = global_position
	if Input.is_key_pressed(KEY_ALT):
		projectile.shoot(-global_transform.basis.z, randf_range(min_speed, max_speed), randf_range(min_size, max_size), randf_range(min_time, max_time), is_continuous)
	else:
		projectile.shoot(-global_transform.basis.z, speed, size, time, is_continuous)
