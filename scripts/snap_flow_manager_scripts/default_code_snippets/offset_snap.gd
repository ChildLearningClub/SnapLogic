extends TransformBase
# NOTE: object_to_snap is any mesh that has a tag
# that is connected to this Output
# Get scene_preview and other node from connections?
#var change_pivot: bool
var count: int = 0
func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:
	count += 1
	print("count: ", count)
	process = false
#	if change_pivot:
#		change_pivot = false
#	print("scene_preview children", object_to_snap.get_children())
#	object_to_snap.position += Vector3(1, 0, 0)
#	return object_to_snap.position

	# Assuming the first child is MeshInstance3D
	var child = object_to_snap.get_child(0) as MeshInstance3D
	
	# Check if the cast was successful
	if child:
		child.position += Vector3(5, 0, 0)
	else:
		print("The child is not a MeshInstance3D.")
		
	return process
