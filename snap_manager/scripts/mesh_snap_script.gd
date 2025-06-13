@tool
extends Node3D

@onready var ray_cast = $RayCast3D
@onready var mesh_instance = $MeshInstance3D2
@onready var mesh = $MeshInstance3D.mesh
@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"



func _physics_process(delta: float) -> void:
	if get_hit_mesh_triangle_face_index(ray_cast.target_position, ray_cast.global_transform.origin) < 0:
		pass
	else:
		var hit_face_index: int = get_hit_mesh_triangle_face_index(ray_cast.target_position, ray_cast.global_transform.origin)
		mesh_instance_3d.global_position = get_face_global_position(hit_face_index)



#Gets the face index player is activating
func get_hit_mesh_triangle_face_index(hitVector, currentCamera):
	#var cubeMeshInstance = get_child(0)
	
	var cubeMeshInstance = mesh_instance
	var cubeMesh = cubeMeshInstance.get_mesh()
	var vertices = cubeMesh.get_faces()
	var arrayMesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var meshDataTool = MeshDataTool.new()
	meshDataTool.create_from_surface(arrayMesh, 0)
	var camera_origin = currentCamera#.global_transform.origin
	var purple_arrow = hitVector - camera_origin
	var i = 0
	while i < vertices.size():
		var face_index = i / 3
		var a = cubeMeshInstance.to_global(vertices[i])
		var b = cubeMeshInstance.to_global(vertices[i + 1])
		var c = cubeMeshInstance.to_global(vertices[i + 2])

		var intersects_triangle = Geometry3D.ray_intersects_triangle(camera_origin, purple_arrow, a, b, c)

		if intersects_triangle != null:
			var angle = rad_to_deg(purple_arrow.angle_to(meshDataTool.get_face_normal(face_index)))
			if angle > 90 and angle < 180:
				return face_index

		i += 3

	return -1




func get_face_global_position(face_index: int) -> Vector3:
	# Ensure we have a mesh and it has faces
	var mesh = mesh_instance.mesh
	if not mesh:
		return Vector3.ZERO

	var vertices = mesh.get_faces()
	if vertices.size() < 3 * (face_index + 1):
		return Vector3.ZERO

	# Create and set up a MeshDataTool
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(array_mesh, 0)

	# Get the local space vertices of the face
	var a = mesh_data_tool.get_vertex(face_index * 3)
	var b = mesh_data_tool.get_vertex(face_index * 3 + 1)
	var c = mesh_data_tool.get_vertex(face_index * 3 + 2)

	# Transform vertices to global space
	var transform = mesh_instance.global_transform
	# NOTE Later replace mesh_instance with aabb position
	# NOTE average results or pick one?
	var global_a = mesh_instance.to_global(a)
	var global_b = mesh_instance.to_global(b)
	var global_c = mesh_instance.to_global(c)

	#return [global_a, global_b, global_c]
	var centroid = (global_a + global_b + global_c) / 3
	#return Vector3(-centroid.x, -centroid.y, centroid.z)
	return centroid
