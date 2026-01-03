extends TransformBase

func transform(scene_preview: Node3D, scene_preview_aabb: AABB, snap_vector_normal: Vector3, snap_aabb: AABB, collision_point: Vector3, process: bool = true) -> bool:
	var vector_normal_normalized = snap_vector_normal.normalized()
	if vector_normal_normalized.y == 1 or vector_normal_normalized.y == -1:
		scene_preview.global_position = collision_point
		# Reset rotation of x and z axis while keeping y.
		scene_preview.rotation = Vector3(0.0, scene_preview.rotation.y, 0.0)

	else:
		var scaled_offset: float = (scene_preview_aabb.size.z / 2) * scene_preview.scale.z
		# Offset the object from the collision_point 1/2 its size * its scale.
		var offset_local: Vector3 = Vector3(0, 0, scaled_offset)

		#print("scene_preview scale: ", scene_preview.scale)
		# Extract the original global transform (position, rotation, scale)
		var original_global_transform: Transform3D = scene_preview.global_transform

		# Create the new rotation using looking_at and the snap surface vector normal
		var new_basis: Basis = Basis().looking_at(snap_vector_normal, Vector3.UP, true)
		var offset_rotated: Vector3 = new_basis * offset_local
	#	var original_origin: Vector3 = original_global_transform.origin as Vector3
		# Apply the new basis (rotation)
		var new_transform: Transform3D = Transform3D(new_basis, collision_point + offset_rotated)

	#	var original_basis: Basis = original_global_transform.basis as Basis
		# Preserve the original scale by multiplying the new basis with the scale
		new_transform.basis = new_transform.basis.scaled(original_global_transform.basis.get_scale())

		# Set the global transform to the new transform (with the new rotation and preserved scale)
		scene_preview.global_transform = new_transform
	return process
