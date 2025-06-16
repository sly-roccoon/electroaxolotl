extends Panel

@export var player : Node3D
var tools : Node3D

@onready var collision : Sprite2D	= $CollisionParticle
@onready var continuous : Sprite2D	= $ContinuousParticle
@onready var polygon : Sprite2D 	= $Polygon
@onready var remover : Sprite2D		= $Remover

const regular_scale  = Vector2.ONE * .3
const enlarged_scale = Vector2.ONE * .35

enum Tools {
	PARTICLE_COLLISION,
	PARTICLE_CONTINUOUS,
	POLYGON,
	REMOVE
}

var prev_tool : Tools

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tools = player.find_child("Tools")
	collision.scale = enlarged_scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	if tools.cur_tool == prev_tool: pass
	
	for icon in get_children():
		icon.scale = regular_scale
		
	if tools.cur_tool == Tools.PARTICLE_COLLISION:
		collision.scale = enlarged_scale
	elif tools.cur_tool == Tools.PARTICLE_CONTINUOUS:
		continuous.scale = enlarged_scale
	elif tools.cur_tool == Tools.POLYGON:
		polygon.scale = enlarged_scale
	elif tools.cur_tool == Tools.REMOVE:
		remover.scale = enlarged_scale
	prev_tool = tools.cur_tool
