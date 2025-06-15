extends Marker3D

var points := PackedVector3Array()
@export var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetPoints()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func resetPoints() -> void:
	points.clear()

func handleInput(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		points.append(player.global_position)
	if event.is_action_pressed("shoot_alt"):
		resetPoints()
	pass
