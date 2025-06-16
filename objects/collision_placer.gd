extends Marker3D


var points := PackedVector3Array()
@export var player : CharacterBody3D
@export var polygon_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetPoints()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	DebugDraw3D.draw_points(points)


func resetPoints() -> void:
	points.clear()

func createShape() -> void:
	var polygon : StaticBody3D = polygon_scene.instantiate()
	get_tree().current_scene.find_child("Polygons").add_child(polygon)
	polygon.create(points)
	resetPoints()

func handleInput(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		points.append(player.global_position)
	if event.is_action_pressed("shoot_alt"):
		createShape()
	pass
