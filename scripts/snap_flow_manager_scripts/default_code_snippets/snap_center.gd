extends TransformBase
# Snap Center

func transform(scene_preview: Node3D, scene_preview_aabb: AABB, snap_vector_normal: Vector3, snap_aabb: AABB, collision_point: Vector3, process: bool = true) -> bool:
#func transform(scene_preview: Node3D, scene_preview_aabb: AABB, vector_normal: Vector3, process: bool = true) -> bool:
#func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:
	var vector_normal_normalized = snap_vector_normal.normalized()
	if vector_normal_normalized.y == 1 or vector_normal_normalized.y == -1:
		# Point the Z Axis of scene_preview towards the dest vector normal
		scene_preview.global_transform.basis = Basis().looking_at(snap_vector_normal, Vector3.RIGHT)
		# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
		var rotation_90: Basis = scene_preview.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)
		# Apply the rotation
		scene_preview.global_transform.basis = rotation_90
	else:
		scene_preview.position = collision_point - Vector3(0, scene_preview_aabb.size.y, 0)
		#scene_preview_mesh.global_position = collision_point

	return process
