@tool
extends Node3D

#NOTE LEFT OF GETTING RAY TO SCAN TOP TO BOTTOM OF SURFACE FOR COLLISION

#@onready var raycast_3d: RayCast3D = $RayCast3D
#@onready var raycast_3d_2: RayCast3D = $RayCast3D2
#@onready var raycast_3d_3: RayCast3D = $RayCast3D3



#var raycast_3d
var pivot_node_3d
var align_raycast: bool = true

var ray_dict: Dictionary = {1: [Vector3(0, 0, 0), Vector3(-20, 0, 0)], 2: [Vector3(0, 0, 0), Vector3(20, 0, 0)]}
var object_rotation: Vector3 = rotation
var object_position: Vector3 = position
var hit_point: Vector3
var unlock_hit_point: bool = true

var change_scene_pivot_point: bool = false
var raycast_active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_process_mode(Node.PROCESS_MODE_ALWAYS)
#func _enter_tree() -> void:











	print("starting")
	#raycast_3d = RayCast3D.new()
	#get_parent().add_child(raycast_3d)
	#raycast_3d.name = "SnapRayCast3D"
	#raycast_3d.owner = get_parent()
	#raycast_3d.exclude_parent = false
	
	#pivot_node_3d = Node3D.new()
	#get_parent().add_child(pivot_node_3d)
	#pivot_node_3d.name = "PivotNode3D"
	#pivot_node_3d.owner = get_parent()
	
	
	#get_tree().reload_current_scene()
	
	#var mesh_child = get_parent().get_child(0)
	#print(mesh_child.mesh.get_aabb())
	#aabb = mesh_child.mesh.get_aabb()
	#print(aabb.get_center())
	#print(aabb.get_support(Vector3(1,0,0)))
	#print(aabb.end)
	#print(aabb.position)
	#print(aabb.size)
	#pass # Replace with function body.


#
	#raycast_3d.position = aabb.end
	

	#var new_raycast_3d = raycast_3d.instantiat()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if raycast_3d.is_colliding():
		#print("colliding")
	#else:
		#print("not colliding")






  

























#var raycast_3d_x_offset: float
#var raycast_3d_y_offset: float


#func call_change_pivot_node_parent(value: bool) -> void:
	#change_scene_pivot_point = value



func _physics_process(delta):
	pass
	#get_parent().get_child(0).transform.origin
	#print("yes, yes")
	#var space_state = get_world_3d().direct_space_state
	#for ray in ray_dict.keys():
		##print(ray_dict[ray][0])
		#var ray_start = ray_dict[ray][0]
		#var ray_end = ray_dict[ray][1]
		#var raycast = PhysicsRayQueryParameters3D.create(ray_start, (ray_start + ray_end))
	###var raycast = PhysicsRayQueryParameters3D.create(Vector3(0, 0, 0), Vector3(-20, 0, 0),)
		#var collision = space_state.intersect_ray(raycast)


	#var mesh_child = get_parent().get_child(0)
	#var aabb = mesh_child.mesh.get_aabb()
	
	#var mesh_child = get_parent().get_child(0)
	#var aabb = mesh_child.get_aabb()
	#
	#
	#
	##var aabb = mesh_child.get_global_transform() * mesh_child.mesh.get_aabb()
	##print(aabb)
	#raycast_3d_x_offset = aabb.get_center().x - (aabb.size.x / 2)
	#
	## FIXME DOES NOT WORK
	##ray_scan_length(aabb)
	#raycast_3d_y_offset = aabb.get_center().y
	##var aabb = get_mesh_precise_aabb(mesh_child.mesh, get_parent().rotation)








	#if align_raycast:
		#raycast_3d.target_position = Vector3(-1.2, 0, 0)
		##raycast_3d.rotation_degrees.y += 90
		##if raycast_3d.is_colliding() or raycast_3d.rotation_degrees.y >= 360:
			##print(raycast_3d.get_collision_normal())
			##raycast_3d.rotation_degrees.y = 0
			##raycast_3d.target_position = raycast_3d.get_collision_normal()
			##align_raycast = false
		#align_raycast = false
	
	
	#var mesh_child = get_parent().get_child(0)
	#print(mesh_child.mesh.get_aabb())
	#var aabb = mesh_child.mesh.get_aabb()
	#print(aabb.get_center())
	#print(aabb.size.x)
		#if collision:
			#print(collision)
			
	#raycast_3d.position = aabb.get_center()
	
	#raycast_3d.position =  - Vector3(aabb.size.x / 2, - (aabb.get_center().y / 4), 0)
	#if raycast_3d:
		#raycast_3d.position =  - Vector3(aabb.size.x / 2, 0, 0)
		#raycast_3d.force_raycast_update()


	#if raycast_3d and raycast_active:
		## Get the aabb center and move half the size.x to the left
		#raycast_3d.position =  Vector3(raycast_3d_x_offset, raycast_3d_y_offset, aabb.get_center().z)
		#raycast_3d.force_raycast_update()
#
		## During alignment do not snap to location where raycast hits exclude parent does not seem to function
		#if raycast_3d.is_colliding() and not align_raycast:
			#if raycast_3d.get_collider() == get_parent():
				#pass
			#else:
				#
				##print(raycast_3d.get_collision_point())
				##if get_parent().rotation == Vector3.ZERO:
				#
					##get_parent().position = raycast_3d.get_collision_point() + Vector3( - aabb.get_center().x + (aabb.size.x / 2), - aabb.get_center().y, 0)
				#get_parent().position = raycast_3d.get_collision_point() + Vector3( - raycast_3d_x_offset, - raycast_3d_y_offset, 0)
				#
				#
				##pivot_node_3d.position = raycast_3d.position
#
				#if change_scene_pivot_point:
					#change_scene_parent()
				
				
				
				
				
				#else:
					##hit_point = raycast_3d.get_collision_point()
					#if unlock_hit_point:
						#hit_point = raycast_3d.get_collision_point()
						#unlock_hit_point = false
						#
					#get_parent().global_position = Vector3(hit_point.x, hit_point.y, hit_point.z - (get_parent().global_rotation.y * 4)) + Vector3(aabb.size.x / 2, 0, 0)
					#position = Vector3(hit_point.x, hit_point.y, hit_point.z - (rotation.y * 4)) + Vector3(aabb.size.x / 2, 0, 0)
					#position = raycast_3d.get_collision_normal().round() + Vector3(aabb.size.x / 2, 0, 0)
					#raycast_3d.enabled = false
					#position = raycast_3d.get_collision_point() + Vector3(aabb.size.x / 2, - (aabb.get_center().y / 4), -rotation.y * 4)
					#position = raycast_3d.get_collision_point() + Vector3(0, - (aabb.get_center().y / 4), 0)
				#print(raycast_3d.get_collision_normal().round())


		# Adjust raycast angle to change with object angle of rotation
		#if get_parent().rotation != object_rotation:
			##unlock_hit_point = true
			##print("rotating")
			#raycast_3d.rotation.y = - get_parent().rotation.y
			#object_rotation = get_parent().rotation
			#
		#if get_parent().position != object_position:
			##unlock_hit_point = true
			##print("moving")
			#object_position = get_parent().position


#func change_scene_parent() -> void:
	#
	#pivot_node_3d = Node3D.new()
	## Add the pivot_node_3d to the scenes parent
	#get_parent().get_parent().add_child(pivot_node_3d)
	#pivot_node_3d.name = "PivotNode3D"
	#pivot_node_3d.owner = get_parent().get_parent()
	#
	#
	##pivot_node_3d.reparent(get_parent().get_parent(), true)
	##pivot_node_3d.owner = get_parent().get_parent()
	##pivot_node_3d.name = "PivotNode3D"
	#pivot_node_3d.position = raycast_3d.global_position
	## Put the scene under the pivot_node_3d
	#get_parent().reparent(get_parent().get_parent().find_child("PivotNode3D", false, true))
	##change_scene_pivot_point = false

#func remove_pivot_node_3d() -> void:
	#if get_parent().get_parent().name == "PivotNode3D":
		#get_parent().reparent(get_parent().get_parent().get_parent())
		# consider adding to group so can have multiple in group and reference the group name
		#get_tree().get_root().find.child("PivotNode3D", true, true).queue_free()
	
	
	
	

func ray_scan_length(aabb: AABB):
	#var y_offset: float = aabb.get_center().y
	#if y_offset < aabb.size.y and scan_up:
		#y_offset += .1
		#if y_offset
	#if y_offset > 0 and scan_down:
		#y_offset -= .1
#
	#return y_offset
	var move_speed = .1
	var start_y := 0
	var end_y := 0 + aabb.size.y
	var tween := create_tween().set_loops()
	tween.tween_property(get_parent(), "raycast_3d_y_offset", end_y, move_speed).from(start_y)
	tween.tween_property(get_parent(), "raycast_3d_y_offset", start_y, move_speed).from(end_y)




func get_mesh_precise_aabb(mesh : Mesh, rotation : Vector3) -> AABB:
	# Get the mesh's vertices
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(mesh, 0)
	var data : Array = surface_tool.commit_to_arrays()
	var vertices : Array = data[ArrayMesh.ARRAY_VERTEX]

	# Find the mesh's vertices that stick out the farthest
	var start := Vector3.ZERO
	var end := Vector3.ZERO
	for j in range(0, vertices.size()):
		# Rotate the vertex to match the mesh's rotation
		var vertex : Vector3 = vertices[j]
		vertex = vertex.rotated(Vector3(1, 0, 0), rotation.x)
		vertex = vertex.rotated(Vector3(0, 1, 0), rotation.y)
		vertex = vertex.rotated(Vector3(0, 0, 1), rotation.z)

		if vertex.x > start.x:
			start.x = vertex.x
		if vertex.y > start.y:
			start.y = vertex.y
		if vertex.z > start.z:
			start.z = vertex.z

		if vertex.x < end.x:
			end.x = vertex.x
		if vertex.y < end.y:
			end.y = vertex.y
		if vertex.z < end.z:
			end.z = vertex.z

	return AABB(start, -(end - start))




#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#print("unlocked")
		#unlock_hit_point = true
	#else:
		#unlock_hit_point = false

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#print("unlocked")
		#unlock_hit_point = true
	#else:
		#unlock_hit_point = false

	#if raycast_3d_3.is_colliding():
		#position = raycast_3d.get_collision_point() + Vector3(aabb.size.x / 2, - aabb.get_center().y / 2, 0)

	#if raycast_3d.is_colliding():
		#print(raycast_3d.get_collision_normal())
