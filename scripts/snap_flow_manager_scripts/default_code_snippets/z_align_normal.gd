extends TransformBase

func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:
	var vector_normal_normalized = vector_normal.normalized()
	if vector_normal_normalized.y == 1 or vector_normal_normalized.y == -1:
		print("on top")
	else:
		# Extract the original global transform (position, rotation, scale)
		var original_global_transform: Transform3D = object_to_snap.global_transform

		# Create the new rotation using looking_at
		var new_basis: Basis = Basis().looking_at(vector_normal, Vector3.UP, true)

	#	var original_origin: Vector3 = original_global_transform.origin as Vector3
		# Apply the new basis (rotation)
		var new_transform: Transform3D = Transform3D(new_basis, original_global_transform.origin)

	#	var original_basis: Basis = original_global_transform.basis as Basis
		# Preserve the original scale by multiplying the new basis with the scale
		new_transform.basis = new_transform.basis.scaled(original_global_transform.basis.get_scale())

		# Set the global transform to the new transform (with the new rotation and preserved scale)
		object_to_snap.global_transform = new_transform
	return process
