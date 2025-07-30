@tool
extends Node3D

func center_scene_preview(scene_preview: Node3D) -> void:
	var aabb_center: Vector3 = get_scene_aabb(scene_preview).get_center()
	aabb_center = Vector3(aabb_center.x, 0.0, aabb_center.z) # Set origin to center bottom
	#print("aabb center: ", aabb_center)
	scene_preview.position -= aabb_center

func get_scene_aabb(scene_preview: Object) -> AABB:
	var scene_aabb: AABB
	var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
	for mesh_node: MeshInstance3D in mesh_node_instances:
		scene_aabb = scene_aabb.merge(mesh_node.mesh.get_aabb())
	#scene_aabb.position = scene_aabb.get_center()
	#scene_aabb.position = scene_preview.position
	#scene_aabb.size = scene_preview.scale
	return scene_aabb
