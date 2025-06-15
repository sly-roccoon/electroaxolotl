extends CharacterBody3D

@export var regular_speed = 20
@export var fast_speed = 50

@onready var head := $Camera3D
@onready var shooter := $Camera3D/Tools/SoundShooter

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	var speed
	if Input.is_action_pressed("speed"):
		speed = fast_speed
	else:
		speed = regular_speed
	
	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_fwd"):
		dir -= head.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		dir += head.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += global_transform.basis.x

	if dir != Vector3.ZERO:
		dir = dir.normalized()
		velocity = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, fast_speed)
		velocity.y = move_toward(velocity.y, 0, fast_speed)
		velocity.z = move_toward(velocity.z, 0, fast_speed)
		
	move_and_slide()

func _process(_delta: float) -> void:
	pass
