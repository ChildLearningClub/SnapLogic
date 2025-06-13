@tool
extends Camera3D

var rot =  false
var node = null

var _rotation: Vector3
# Called when the node enters the scene tree for the first time.

func _ready() -> void:

	await get_tree().create_timer(1).timeout

	var node = get_parent().get_child(1).get_child(0)
	_focus_camera_on_node_3d(node)
	
	#call_deferred("get_node3d")
	#var node = get_parent().get_child(1).get_child(0)
	
	#new_scene_view.name = new_scene_view.get_child(0).get_child(1).name
	#pass
	#_rotation = _anchor_node.transform.basis.get_rotation_quaternion().get_euler()
	#await get_tree().create_timer(5).timeout
	#rot = true

	
	
#func get_node3d() -> void:
	#var node = get_parent().get_child(1).get_child(0)
	##print(get_parent().get_child(1).get_child(0))
	#_focus_camera_on_node_3d(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if rot:
		#position.x += 1 * delta
		#print(position)



# REFERENCE Mansur Isaev and Contributors Scene Library Plugin
@warning_ignore("unsafe_method_access")
func _calculate_node_aabb(node: Node) -> AABB:
	var aabb := AABB()

	if node is Node3D and not node.is_visible():
		return aabb
	# NOTE: If the node is not MeshInstance3D, the AABB is not calculated correctly.
	# The camera may have incorrect distances to objects in the scene.
	elif node is MeshInstance3D:
		aabb = node.get_global_transform() * node.get_aabb()

	#for i: int in node.get_child_count():
		#aabb = aabb.merge(_calculate_node_aabb(node.get_child(i)))

	return aabb


#func _focus_camera_on_node_2d(node: Node) -> void:
	#var rect: Rect2 = _calculate_node_rect(node)
	#_camera_2d.set_position(rect.get_center())
#
	#var zoom_ratio: float = THUMB_GRID_SIZE / maxf(rect.size.x, rect.size.y)
	#_camera_2d.set_zoom(Vector2(zoom_ratio, zoom_ratio))

func _focus_camera_on_node_3d(node: Node) -> void:
	var transform := Transform3D.IDENTITY
	# TODO: Add a feature to configure the rotation of the camera.
	transform.basis *= Basis(Vector3.UP, deg_to_rad(40.0))
	transform.basis *= Basis(Vector3.LEFT, deg_to_rad(22.5))

	var aabb: AABB = _calculate_node_aabb(node)
	var distance: float = aabb.get_longest_axis_size() / tan(deg_to_rad(get_fov()) * 0.5)
	#var distance: float = aabb.get_longest_axis_size() / tan(deg_to_rad(_camera_3d.get_fov()) * 0.75)
	#var distance: float = aabb.get_longest_axis_size() / tan(deg_to_rad(get_fov()) * 0.75)
	transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()

	#_camera_3d.set_global_transform(transform.orthonormalized())
	set_global_transform(transform.orthonormalized())
