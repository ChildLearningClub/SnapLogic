extends TransformBase

## Shape how objects with tags will interact with other tagged objects or directly with all other objects.
func transform(scene_preview: Node3D, scene_preview_aabb: AABB, snap_vector_normal: Vector3, snap_aabb: AABB, collision_point: Vector3, process: bool = true) -> bool:
	print("connect tag to me to run code that you place here")
	print("scene_preview: ", scene_preview) # The object/scene that you are placing within the 3D Viewport.
	print("scene_preview_aabb: ", scene_preview_aabb) # The AABB bounding box of the object that you are placing within the 3D Viewport.
	print("snap_vector_normal: ", snap_vector_normal) # The vector_normal of the object's surface the mouse pointer is hitting in the 3D Viewport.
	print("snap_aabb: ", snap_aabb) # The AABB bounding box of the object the mouse pointer is hitting in the 3D Viewport.
	#process = false # NOTE: to run code snippet once, uncomment this line. true(default) to run continuously.
	return process
