extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func handleInput(event : InputEvent) -> void:
	if event.is_action("shoot"):
		var polygon : StaticBody3D = get_overlapping_bodies().front()
		if polygon:
			polygon.fizzle()
