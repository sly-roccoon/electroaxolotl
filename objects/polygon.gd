extends StaticBody3D
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var mesh : MeshInstance3D = $MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create(points : PackedVector3Array) -> void:
	if points.size() <= 2: pass
	
	var convex_shape = ConvexPolygonShape3D.new()
	convex_shape.points = points
	collision.shape = convex_shape
	
	mesh.mesh = convex_shape.get_debug_mesh()
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color.from_hsv(randf(), .9, 1.0, .9)
	mesh.material_override = material

func fizzle() -> void:
	var mat : StandardMaterial3D = mesh.get_active_material(0)

	var tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(Callable(self, "queue_free"))
