extends Camera3D

const SENSITIVITY = 0.01

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var body:= get_parent_node_3d()
		# Rotate yaw (around Y axis)
		body.rotate_y(-event.relative.x * SENSITIVITY)
		
		# Rotate pitch (around X axis)
		rotate_x(-event.relative.y * SENSITIVITY)
		
		# Optional: clamp pitch to avoid flipping upside down
		var pitch = rotation_degrees.x
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.x = pitch
