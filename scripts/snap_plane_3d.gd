@tool
extends MeshInstance3D

func _ready() -> void:
	mesh.material.set_shader_parameter("grid_width", .5)


func _physics_process(delta: float) -> void:
	var editor_viewport: SubViewport = EditorInterface.get_editor_viewport_3d(0)
	var camera_3d: Camera3D = editor_viewport.get_camera_3d()
	var cam_pos: Vector3 = camera_3d.position
	var mouse_pos: Vector2 =  editor_viewport.get_mouse_position()
	var camera_projection: Vector3 = camera_3d.project_ray_normal(mouse_pos).snappedf(0.1)


#region Soft Axis Snapping
	if camera_projection.x == -1:
		set_global_rotation_degrees(Vector3(0, 90, 0))

	elif camera_projection.x == 1:
		set_global_rotation_degrees(Vector3(0, -90, 0))

	elif camera_projection.z == -1:
		set_global_rotation_degrees(Vector3.ZERO)

	elif camera_projection.z == 1:
		set_global_rotation_degrees(Vector3(0, -180, 0))

	elif camera_projection.y == -1:
		set_global_rotation_degrees(Vector3(-90, 0, 0))

	elif camera_projection.y == 1:
		set_global_rotation_degrees(Vector3(90, 0, 0))

	else:
		look_at(cam_pos, Vector3.UP, true)
#endregion

	


	#print("rotation: ", global_rotation_degrees)
