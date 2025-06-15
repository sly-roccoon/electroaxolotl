extends RayCast3D

var points := PackedVector3Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetPoints()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func resetPoints() -> void:
	points.clear()

func handleInput(event : InputEvent) -> void:

	pass
