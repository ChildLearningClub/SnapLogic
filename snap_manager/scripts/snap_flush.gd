@tool
extends Node3D

# FIXME EITHER APPLY ONLY TO NEW SCENEPREVIEW OR MAKE ALSO WORK WITH OBJECTS PICKED UP IN EDITOR
#NOTE LEFT OFF SETTING UP STRUCTURE FOR MOVING OF RAYCAST AND STOPPING WHEN HAVE VALUE AND POSSIBLY
# REMOVING RAYCAST FOR OH WAIT NO NEED THAT FOR THE HIT OBJECT BUT SWITHCING ON AND OFF WHEN NEEDED EACH ONE

# NOTE LEFT off adjusting _mesh_snapping to get some results when on 90 angles

@onready var ray_origin_1m: RayCast3D = $RayOrigin1M



# TODO NOTE CREATE DICTIONARY AS A LOOK-UP TABLE FOR THE DIFFERENT RAYNORMALS AND CAMERA POSITION RELATIONSHIPS
var snap_lookup_table: Dictionary = {}

var mesh_aabb: AABB
var mesh_aabb_size: Vector3
var collision_body_result: bool = false
var mesh_body_result: bool = false
var origin_surface_position: Vector3
var global_offset: Vector3 

var make_it_flush: bool = false
var selected_object_local_snap_offset: Vector3 = Vector3.ZERO
var destination_global_flush_point: Vector3 = Vector3.ZERO
var clear_timer: float = 1.0
var reset: bool = false
var destination_surface_normal: Vector3 = Vector3.ZERO
var set_destination_scan_start: bool = true

var valid_normals: Array[Vector3] = [
	Vector3(0, 0, 1),
	Vector3(0, 0, -1),
	Vector3(1, 0, 0),
	Vector3(-1, 0, 0)
]

var visual_instances_data: Array[Dictionary] = []

# TODO WORK WITH MULTI-SELECT
var selection_has_collision: bool


var scan_along_x_axis: bool = true
var scan_along_y_axis: bool = false
var scan_along_z_axis: bool = true


var mesh_node: MeshInstance3D


@onready var reset_timer: Timer

func _ready() -> void:
	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.one_shot = true

	# FIXME STILL HAVING ISSUES GETTING res://addons/intelli_snap/scripts/snap_flush.gd:38 - Trying to assign value of type 'Node3D' to a variable of type 'MeshInstance3D'.
	if not selection_has_collision and get_parent_node_3d() is MeshInstance3D:
		#print("Snap flush created")
		mesh_node = get_parent_node_3d()
	
	# FIXME Adjust later for other node types
	if selection_has_collision and get_parent_node_3d() is StaticBody3D:
		#print("Snap flush created")
		ray_origin_1m.set_exclude_parent_body(false)
		mesh_node = get_parent_node_3d().get_child(0)


	if is_inside_tree():
		
		# NOTE Maybe can add to no collision function to avoid doing when not needed
		collect_global_tris(mesh_node)
		if mesh_node is MeshInstance3D:
			#print("Snap flush flush values")
			
			# Flush values ;)
			snap_lookup_table.clear()
			selected_object_local_snap_offset = Vector3.ZERO
			destination_global_flush_point = Vector3.ZERO
			ray_position_filter_from_aabb_position()



func ray_position_filter_from_aabb_position() -> void:
	mesh_aabb = mesh_node.mesh.get_aabb()
	mesh_aabb_size = mesh_aabb.size

	#print(mesh_aabb)
	#print(mesh_aabb.get_center())
	
	## FIXME WILL NEED TO FACTOR IN MOOSE HEAD MAYBE if mesh_aabb.get_center().z approx 0 then local_offset = 0 -> no scan needed?
	# MOOSE HEAD WAll Mount Exception:
	if is_zero_approx(mesh_aabb.position.z):
		print("Moose exception skipping hit position: ", mesh_node.global_transform.origin)
		mesh_body_result = true
		collision_body_result = true
	else:
		# Offset snapflush child node relative to ScenePreview AABB center and 1/4 up on y and extend .01 on z past surface
		var local_offset = Vector3(mesh_aabb.position.x, mesh_aabb.get_center().y / 8, (mesh_aabb.size.z / 2 + mesh_aabb.get_center().z) * 1.01) # Caculate the local offset
		global_offset = global_transform * local_offset # Convert local offset to global by * it by current global position/rotation etc.
		global_transform.origin = global_offset
		
		## Set target length to the entire length of the ScenePreview along its z axis * 1.01
		ray_origin_1m.target_position.z = -mesh_aabb.size.z * 1.01


# NOTE CAN POSSIBLY COMBINE FUNCTIONS get_mesh_origin_surface AND get_collision_origin_surface
func _process(delta: float) -> void:
	#print(clear_timer)
	#print(snapped(ray_origin_1m.get_collision_normal(), Vector3(0.01, 0.01, 0.01)).normalized().round())
	#print("origin_surface_position: ", origin_surface_position)
	
	if not destination_global_flush_point == Vector3.ZERO:
		mesh_node.global_transform.origin.z = (destination_global_flush_point.z - mesh_aabb.size.z/2) + selected_object_local_snap_offset.z
	#print("selected_object_local_snap_offset.z: ", selected_object_local_snap_offset.z)
	
	
	if make_it_flush:
		pass
		#selection_has_collision = true
		#mesh_body_result = false
		#collision_body_result = false
		#reset_timer.start(0.1)
		#reset = true
#
	#else:
		#if reset_timer.time_left == 0:
			#if reset:
				#destination_global_flush_point = Vector3.ZERO
				#ray_origin_1m.position.z = 0.0
				#reset = false

	

	# Selected node is MeshInstance3D w/o collision or StaticBody3D w/o collision and there is no result back yet 
	if not selection_has_collision and not mesh_body_result:# and selection_is_valid:
		#print("running mesh")
		origin_surface_position = get_mesh_origin_surface()
		if not origin_surface_position == Vector3.ZERO:
			#print("mesh hit position: ", origin_surface_position)
			#print("local: ", to_local(origin_surface_position))
			if selected_object_local_snap_offset == Vector3.ZERO: # Store the selected objects snap offset
				selected_object_local_snap_offset = to_local(origin_surface_position)
				#print("storing selected_object_local_snap_offset: ", selected_object_local_snap_offset)
			else:
				#print("getting dest point")
				destination_global_flush_point = origin_surface_position

	# Selected node is StaticBody3D with collision and there is no result back yet 
	if selection_has_collision and not collision_body_result: # or make_it_flush:# and selection_is_valid:
		#print("running collision")
		ray_origin_1m.force_raycast_update()
		origin_surface_position = get_collision_origin_surface()
		if not origin_surface_position == Vector3.ZERO:
			#print("collision hit position: ", origin_surface_position)
			#print("local: ", to_local(origin_surface_position))
			if selected_object_local_snap_offset == Vector3.ZERO: # Store the selected objects snap offset
				selected_object_local_snap_offset = to_local(origin_surface_position)
			else:
				#print("getting dest point")
				destination_global_flush_point = origin_surface_position
			# If ScenePreview convert to local store it and when placing convert back to global and use as snap offset




func get_mesh_origin_surface() -> Vector3:
	var mesh_body_origin_ray = _mesh_snapping(ray_origin_1m.position, ray_origin_1m.target_position.normalized())
	if mesh_body_origin_ray:
		var collision_point_normal: Vector3 = snapped(mesh_body_origin_ray[1].normalized(), Vector3(0.01, 0.01, 0.01)).normalized().round()
		if valid_normals.has(collision_point_normal):
			mesh_body_result = true
			var mesh_body_collision_point: Vector3 = mesh_body_origin_ray[0]
			return mesh_body_collision_point

		else:
			if selected_object_local_snap_offset == Vector3.ZERO:
				scan_selected_object()
			elif make_it_flush: # and destination_global_flush_point == Vector3.ZERO:
				scan_destination_object()
	else:
		if selected_object_local_snap_offset == Vector3.ZERO:
			scan_selected_object()
		elif make_it_flush: # and destination_global_flush_point == Vector3.ZERO:
			scan_destination_object()
	return Vector3.ZERO



func get_collision_origin_surface() -> Vector3:
	# NOTE TEST Will need to see how this handles surfaces 
	var collision_point_normal: Vector3 = snapped(ray_origin_1m.get_collision_normal(), Vector3(0.01, 0.01, 0.01)).normalized().round()
	if ray_origin_1m.is_colliding() and valid_normals.has(collision_point_normal):
			collision_body_result = true
			var collision_body_collision_point: Vector3 = ray_origin_1m.get_collision_point()
			return collision_body_collision_point

	else:
		if selected_object_local_snap_offset == Vector3.ZERO:
			scan_selected_object()
		elif make_it_flush: # and destination_global_flush_point == Vector3.ZERO:
			scan_destination_object()
	return Vector3.ZERO



func scan_selected_object() -> void:#Vector3:
	# FIXME Set position.x rate of change based on size of object example thin door may be missed
	if scan_along_x_axis:
		ray_origin_1m.position.x += .05# TEST .001
	if mesh_aabb:
		if ray_origin_1m.position.x >= mesh_aabb.size.x:
			scan_along_x_axis = false
			# Set ray to bottom center and scan to top
			ray_origin_1m.position.x = mesh_aabb.size.x / 2 + .01
			ray_origin_1m.position.y = 0
			scan_along_y_axis = true
	if scan_along_y_axis:
		ray_origin_1m.position.y += .05
	if ray_origin_1m.position.y >= mesh_aabb.size.y:
		scan_along_y_axis = false
		push_warning("make this message better no flat surface found or not on 90 angles surface aligning to aabb: ", mesh_aabb)
		selected_object_local_snap_offset = mesh_aabb.position
		# Set flags to prevent furture processing
		mesh_body_result = true
		collision_body_result = true
	#return Vector3.ZERO


func scan_destination_object() -> void:#Vector3:
	if set_destination_scan_start:
		ray_origin_1m.position.x = -.05
		ray_origin_1m.position.y = mesh_aabb.get_center().y
		set_destination_scan_start = false
	#print("scan destination raycast movement now")
	if scan_along_z_axis and destination_global_flush_point == Vector3.ZERO:

		ray_origin_1m.position.z += 0.5# TEST .001
		ray_origin_1m.target_position.z = -ray_origin_1m.position.z
	#if not destination_global_flush_point == Vector3.ZERO:
		#mesh_node.global_transform.origin.z = destination_global_flush_point.z#q + selected_object_local_snap_offset.z
		
		
	
	
	
	await get_tree().create_timer(3).timeout
	make_it_flush = false
	mesh_body_result = true
	collision_body_result = true
	
	
	
	
	
	
	
	
	
	#return Vector3.ZERO



#region #### MODIFIED EXTRASNAPS PLUGIN CODE ####


# BEST VERSION
const FLOAT64_MAX = 1.79769e308
const RAY_LENGTH = 10000.0  # Maximum length of the ray in meters
##func _mesh_snapping(viewport_camera: Camera3D, event: InputEventMouseMotion) -> void:
func _mesh_snapping(ray_position: Vector3, ray_target: Vector3) -> Array[Vector3]:


	## NOTE SEEMS PRETTY SOLID DO NOT CHANGE
	var global_ray_position: Vector3 = to_global(ray_position)
	var global_ray_target: Vector3 = to_global(ray_target)
	var from = global_ray_position
	var direction: Vector3 = (global_ray_target - global_ray_position)#.normalized()#.round()
	#var to = (from + direction - global_offset) * RAY_LENGTH  # Define the ray end position in global space and reverse global_offset
	var to = from + direction - global_offset # ray end position in global space undo global_offset

	var min_target: float = FLOAT64_MAX
	var min_position: Vector3 = Vector3.INF
	var min_normal: Vector3

	
	var min_position_min_normal : Array[Vector3] = []

	for data: Dictionary in visual_instances_data:
		var tris: PackedVector3Array = data['tris']
		for i: int in range(0, tris.size(), 3):
			var v0: Vector3 = tris[i + 0]
			var v1: Vector3 = tris[i + 1]
			var v2: Vector3 = tris[i + 2]
			var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			if res is Vector3:
				var len: float = from.distance_to(res)
				if len < min_target:
					min_target = len
					#print(min_target)
					min_position = res
					var v0v1: Vector3 = v1 - v0
					var v0v2: Vector3 = v2 - v0
					min_normal = v0v2.cross(v0v1)#.normalized()
					#min_normal = v0v1.cross(v0v2)

	if min_target >= FLOAT64_MAX: 
		return []


	min_position_min_normal.append(min_position)
	min_position_min_normal.append(min_normal)
	return min_position_min_normal



#func _mesh_snapping(ray_position: Vector3, ray_target: Vector3) -> Array[Vector3]:
	## Get the parent mesh's global transform
	#var mesh_global_transform = get_parent().global_transform
	#
	## Convert the ray's position and direction from local to global coordinates
	#var from: Vector3 = mesh_global_transform * ray_position  # Transform ray start
	#print("from: ", from)
	#var direction: Vector3 = (ray_target - ray_position).normalized()  # Calculate direction
	#var to: Vector3 = from + Vector3(-1, 0, 0) * RAY_LENGTH  # Define ray end position in global space
	##var to: Vector3 = from + direction * RAY_LENGTH  # Define ray end position in global space
	#
	#var min_distance: float = FLOAT64_MAX
	#var closest_point: Vector3 = Vector3.ZERO
	#var closest_normal: Vector3 = Vector3.ZERO
#
	## Iterate over each mesh's triangles
	#for data in visual_instances_data:
		#var tris: PackedVector3Array = data['tris']
		#for i in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
			#
			## Check intersection with the current triangle
			#var intersection: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			#if intersection is Vector3:
				#var distance: float = from.distance_to(intersection)
				#if distance < min_distance:
					#min_distance = distance
					#closest_point = intersection
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#closest_normal = v0v1.cross(v0v2).normalized()  # Calculate and normalize the normal
#
	## If no intersection found, return an empty array
	#if min_distance >= FLOAT64_MAX:
		#return []
#
	#return [closest_point, closest_normal]


#func _mesh_snapping(ray_position: Vector3, ray_target: Vector3) -> Array[Vector3]:
	## Convert ray position and target to global space
	#var global_ray_position: Vector3 = to_global(ray_position)
	#var global_ray_target: Vector3 = to_global(ray_target)
	#
	## Calculate the ray direction
	##var direction: Vector3 = (global_ray_target - global_ray_position).normalized()
	#var direction: Vector3 = (global_ray_target - global_ray_position).normalized().round()
	#from = global_ray_position
	#to = from + direction * RAY_LENGTH  # Define the ray end position in global space
	#
	##var global_ray_position: Vector3 = to_global(ray_position)
	##var global_ray_target: Vector3 = to_global(ray_target)
	##var from: Vector3 = global_ray_position
	##var direction: Vector3 = (global_ray_target - from).normalized().round()
	##to = Vector3(direction) * RAY_LENGTH
	#
	#
	#
	#
	#var min_distance: float = FLOAT64_MAX
	#var closest_point: Vector3 = Vector3.ZERO
	#var closest_normal: Vector3 = Vector3.ZERO
#
	## Iterate over each mesh's triangles
	#for data in visual_instances_data:
		#var tris: PackedVector3Array = data['tris']
		#for i in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
			#
			## Check intersection with the current triangle
			#var intersection: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			#if intersection is Vector3:
				#var distance: float = from.distance_to(intersection)
				#if distance < min_distance:
					#min_distance = distance
					#closest_point = intersection
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#closest_normal = v0v1.cross(v0v2).normalized()  # Calculate and normalize the normal
#
#
	## If no intersection found, return an empty array
	#if min_distance >= FLOAT64_MAX:
		#return []
#
	#return [closest_point, closest_normal]



## Get global triangle of all nodes in the scene, except the [exclude] node and its children.
func collect_global_tris(node) -> void:
	if node is MeshInstance3D:
		var mesh: Mesh = node.mesh
		#if !mesh: continue
		
		var aabb: AABB = node.global_transform * node.get_aabb()
		var tris: PackedVector3Array = []
		
		var verts: PackedVector3Array = mesh.get_faces()
		for vert: Vector3 in verts:
			tris.append(node.global_transform * vert)

		visual_instances_data.append({ "node": node, "aabb": aabb, "tris": tris })

	elif node is CSGShape3D:
		var meshes: Array = node.get_meshes()


		var aabb: AABB = node.global_transform * node.get_aabb()
		var tris: PackedVector3Array = []

		var verts: PackedVector3Array = (meshes[1] as ArrayMesh).get_faces()
		for vert: Vector3 in verts:
			tris.append(node.global_transform * vert)

		visual_instances_data.append({ "node": node, "aabb": aabb, "tris": tris })

#endregion
