extends Node3D

@onready var shooter := $SoundShooter
@onready var placer := $CollisionPlacer
@onready var raygun := $RayGun

enum Tools {
	PARTICLE_COLLISION,
	PARTICLE_CONTINUOUS,
	POLYGON,
	RAY,
	REMOVE
}

var cur_tool := Tools.PARTICLE_COLLISION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tool_particle_collision"):
		cur_tool = Tools.PARTICLE_COLLISION
	elif event.is_action_pressed("tool_particle_continuous"):
		cur_tool = Tools.PARTICLE_CONTINUOUS
	elif event.is_action_pressed("tool_polygon"):
		cur_tool = Tools.POLYGON
	elif event.is_action_pressed("tool_ray"):
		cur_tool = Tools.RAY
	elif event.is_action_pressed("tool_remove"):
		cur_tool = Tools.REMOVE
	
	if cur_tool == Tools.PARTICLE_COLLISION || cur_tool == Tools.PARTICLE_CONTINUOUS:
		shooter.handleInput(event, cur_tool)
	elif cur_tool == Tools.POLYGON:
		placer.resetPoints()
		placer.handleInput(event)
	elif cur_tool == Tools.RAY:
		pass
	elif cur_tool == Tools.REMOVE:
		pass
