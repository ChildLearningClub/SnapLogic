# REFERENCE: https://www.youtube.com/watch?v=Gfpnxg-jne4 (Crigz Vs Game Dev)
# https://github.com/CBerry22/Path-Based-Mesh-Generation-YT (CBerry22) Thank you!
@tool
extends Path3D

#enum MeshOrientation { Y_UP, ALIGN_NORMAL, SKEW_TO_CURVE }

# TODO Expose create and expose Random Scale and random rotation and limits
# TODO Use code to place non multimesh assets along Path3D line
# TODO Find way to update number of points on curve when mesh count changes after placing. (keep points at mesh center?)
# TODO cleanup script
# FIXME When rotated SKEW_TO_CURVE is still skewed on the x axis or the non line aligned axis which if perpendicular is the z axis that should be skewed.
# FIXME Quaternius assets in multimesh issue see scene_snap_plugin.gd for fix.
# TODO Force non multimesh generation when Rigidbody3D selected. Same with Character body? or Exclude?
# TODO FIXME Possible to get surface normal rather then line normal for "ALIGN_NORMAL"?
# TODO V2 Create as box, create as circle pull from click position to make circle box expand? like box select works? circle expand from center?

##@export_category("Mesh Properties")
##signal get_xz_point_heights (xz_point_cache: Array[Vector2]) ## Pass up the points to calculate the top down collision heights.



@export_enum("Y_UP", "ALIGN_NORMAL", "SKEW_TO_CURVE") var mesh_orientation: String = "SKEW_TO_CURVE":
	set(value):
		mesh_orientation = value
		is_dirty = true

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var mesh_spacing = 0.0:
	set(value):
		mesh_spacing = value
		is_dirty = true
@export_custom(PROPERTY_HINT_LINK, "suffix:m") var instance_scale: Vector3 = Vector3.ONE:
	set(value):
		instance_scale = value
		is_dirty = true

##@export_custom(PROPERTY_HINT_LINK, "suffix:m") var instance_rotation: Quaternion:
#@export_custom(PROPERTY_HINT_LINK, "suffix:m") var instance_rotation: Vector3 = Vector3.ZERO:
	#set(value):
		#instance_rotation = value
		#is_dirty = true

@export_custom(PROPERTY_HINT_LINK, "suffix:f") var instance_rotation_y: float = 0.0:
	set(value):
		instance_rotation_y = value
		is_dirty = true



#@export var instance_scale: Vector3 = Vector3.ONE:
	#set(value):
		#instance_scale = value
		#is_dirty = true

@export var shape_3d: Shape3D = null
@export var collision_shapes: Array[Node] = []

#@export var mesh_collision: CollisionShape3D = null:
	#set(value):
		#mesh_collision = value
		##is_dirty = true




#@export var scene_preview: Node3D:
	#set(value):
		#scene_preview = value
		#print("scene_preivew changed")
		#is_dirty = true



var is_dirty = false ## Flag set to indicate when _update_multimesh() should be run within the process function.
#var add_start_point: bool = true
var collision_point: Vector3 = Vector3.ZERO
var line_start_point: Vector3 = Vector3.ZERO
var line_end_point: Vector3 = Vector3.ZERO
var terrain = null ## Reference to the Terrain3D node that is passed in from scene_snap_plugin.gd if Terrain3D plugin active and node in tree.
var terra_brush = null ## Reference to the TerraBrush node that is passed in from scene_snap_plugin.gd if TerraBrush plugin active and node in tree.
var set_start_point: bool = true
#var min_p: Vector3 = Vector3.ZERO

# TODO Adjust num_segments to match instance size line length/ aabb width. can this be updated when changing mesh density?
var num_segments = 100 # You can change this for more/less precision
var last_point_added: Vector3 = Vector3.INF
#var terrain
#var mesh_count: int
#var instance_scale: Vector3 = Vector3.ONE

var scene_preview: Node3D
var scene_preview_basis: Basis
#var mesh_collision: CollisionShape3D
var scene_preview_collision_shape_3d: CollisionShape3D
#var line_point_cache: Dictionary[Vector2, float] = { }
#var line_point_cache: Array[float] = []
#var line_point_cache: Array[Vector3] = []
var xz_point_cache: Array[Vector2] = []
var xz_point_heights: Array[float] = []
#var collisions_enabled: bool = true
#@export var mesh_collision: CollisionShape3D
#var static_body: StaticBody3D
#var mesh_collision_count: int = 0

var scene_name: String = ""
@export var static_body_3d: StaticBody3D = null

var primitive_collision_shape: bool
#var collision_offset: Vector3 = Vector3.ZERO
@export var primitive_collision_offset: Vector3 = Vector3.ZERO
var point_count: int = 0
var last_position: Vector3
@export var mesh_count: int = 0
var randomize_scale: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#push_error("global_position at ready: ", global_position)
	#global_position = collision_point
	if not curve_changed.is_connected(_on_curve_changed):
		curve_changed.connect(_on_curve_changed)

	#var settings = EditorInterface.get_editor_settings()
#
	## Temporaryly disable unfolding selected in editor settings then reset back to user settings
	#if settings.has_setting("docks/scene_tree/auto_expand_to_selected"):
		#var expand_to_selected = settings.get_setting("docks/scene_tree/auto_expand_to_selected")
		#settings.set_setting("docks/scene_tree/auto_expand_to_selected", false)
		##push_error("expand_selected: ", expand_selected)
		#await get_tree().create_timer(1).timeout
		#push_error("resetting now")
		#settings.set_setting("docks/scene_tree/auto_expand_to_selected", expand_to_selected)


## Temporaryly disable unfolding selected in editor settings then reset back to user settings
func prevent_auto_expand_to_selected() -> void:
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("docks/scene_tree/auto_expand_to_selected"):
		var expand_to_selected = settings.get_setting("docks/scene_tree/auto_expand_to_selected")
		settings.set_setting("docks/scene_tree/auto_expand_to_selected", false)
		await get_tree().create_timer(3).timeout
		push_error("resetting now")
		settings.set_setting("docks/scene_tree/auto_expand_to_selected", expand_to_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#push_error("collision_point: ", collision_point)
	#set_display_folded(true)
	#if static_body_3d:
		#push_error("folding node")
		#static_body_3d.set_display_folded(true)
	###num_segments = mesh_count
	## FIXME Will revert point changes made by user.
	#if position != last_position and not is_dirty:
		#last_position = position
		#line_start_point = global_position
		##line_end_point = curve.get_point_position(mesh_count)
		#_update_multimesh()
		#multimesh_to_line()
		####var y_value = collision_point.y
		####var start_xz = Vector2(line_start_point.x, line_start_point.z)
		####var end_xz = Vector2(collision_point.x, collision_point.z)
		###
		###
		###is_dirty = true
	# FIXME Does not updated curve point mesh_count when increasing number of mesh after being placed
	# multimesh_to_line() will erase curve points on editor restart.?
	if is_dirty:
		is_dirty = false
		_update_multimesh()
		#multimesh_to_path()
		


#func get_forward(curve_distance: float) -> Vector3:
	#var position = curve.sample_baked(curve_distance, true)
	#return position.direction_to(curve.sample_baked(curve_distance + 0.1, true))


func get_new_rotation(curve_distance: float) -> Vector3:
	var tform: Transform3D = curve.sample_baked_with_rotation(curve_distance, true, false)
	return tform.basis.get_euler()


func _update_multimesh():
	var path_length: float = curve.get_baked_length()
	
	var mm: MultiMesh = get_child(0).multimesh
	var mesh_size = mm.mesh.get_aabb().size
	if mesh_spacing == 0.0:
		var base_spacing = mesh_size.x * instance_scale.x
		mesh_spacing = base_spacing + 0.001  # small epsilon to prevent overlap

	# NOTE: Must be set after mesh_spacing changed from 0 to prevent ERROR Condition "p_count < 0" is true.
	mesh_count = floor(path_length / mesh_spacing)
	mm.instance_count = mesh_count
	var offset = mesh_spacing/2.0
	#var total_curve_points: int = curve.point_count

	#var last_closest_point: Vector3 = Vector3.ZERO
	#var start_xz: Vector2 = Vector2.ZERO
	#var end_xz: Vector2 = Vector2.ZERO
	#var last_point: Vector3 = Vector3.ZERO
	#var next_point: Vector3 = Vector3.ZERO

	for i in range(0, mesh_count):
		var curve_distance = offset + mesh_spacing * i
		var position = curve.sample_baked(curve_distance, true)
		var forward = position.direction_to(curve.sample_baked(curve_distance + 0.1, true))
		var basis = Basis()
		var up = Vector3.UP

		if mesh_orientation == "Y_UP":
			basis = basis.rotated(Vector3.UP, deg_to_rad(90) + get_new_rotation(curve_distance).y + instance_rotation_y)

		if mesh_orientation == "ALIGN_NORMAL":
			var right = up.cross(forward).normalized()
			var corrected_up = forward.cross(right).normalized()  # re-orthonormalize

			basis.z = forward
			basis.x = right
			basis.y = corrected_up

			basis = basis.rotated(corrected_up, -deg_to_rad(90) + instance_rotation_y)

		elif mesh_orientation == "SKEW_TO_CURVE":
			basis.x = forward
			basis.y = up
			basis.z = forward.cross(up).normalized()
			basis = basis.rotated(Vector3.UP, instance_rotation_y)

		# Apply scale to the basis, initially using the scene_previews scale
		# NOTE: Without (and not instance_scale) becomes locked to scene_previews scale until editor restart.
		if scene_preview_basis and not instance_scale:
			instance_scale = scene_preview_basis.get_scale()

		if not randomize_scale:
			basis = basis.scaled(instance_scale)
		else:
			basis = basis.scaled(instance_scale * randf_range(instance_scale.x - 3, instance_scale.x + 3))

		var transform = Transform3D(basis, position)
		mm.set_instance_transform(i, transform)
		set_mesh_collisions()

	if mesh_count == 0 and collision_shapes.size() > 0:
		var extra_node: CollisionShape3D = collision_shapes.pop_back()
		extra_node.queue_free()
		static_body_3d.queue_free()

	for i in range(mm.instance_count):
		if collision_shapes.size() > i:
			if is_instance_valid(collision_shapes[i]):

				var inst_transform: Transform3D = mm.get_instance_transform(i)
				var world_base = get_child(0).global_transform * inst_transform

				var collision_shape: CollisionShape3D = collision_shapes[i]
				if collision_shape:
					if primitive_collision_offset != Vector3.ZERO:
						# Primitive shapes: need to shift origin
						# Build a translation transform from the primitive offset
						var offset_local = Transform3D(Basis(), primitive_collision_offset)
						# Combine offset with instance transform
						var local_with_offset = inst_transform * offset_local
						collision_shape.global_transform = get_child(0).global_transform * local_with_offset
					else:
						# Complex shapes: assume origin already correct
						collision_shape.global_transform = world_base


func set_mesh_collisions() -> void:
	if shape_3d or scene_preview_collision_shape_3d:
		if not static_body_3d:
			static_body_3d = StaticBody3D.new()
			static_body_3d.name = scene_name
			add_child(static_body_3d)
			static_body_3d.owner = EditorInterface.get_edited_scene_root()
			#static_body_3d.set_display_folded(true)
			static_body_3d.scale = instance_scale

		else:
			if collision_shapes.size() < mesh_count:
				var collision_shape_3d: CollisionShape3D = CollisionShape3D.new()
				if scene_preview_collision_shape_3d:
					shape_3d = scene_preview_collision_shape_3d.shape

				collision_shape_3d.shape = shape_3d
				static_body_3d.add_child(collision_shape_3d)
				collision_shape_3d.owner = EditorInterface.get_edited_scene_root()
				if not collision_shapes.has(collision_shape_3d):
					collision_shapes.append(collision_shape_3d)

			elif collision_shapes.size() > mesh_count: # Remove additional collisions when resizing.
				var extra_node = collision_shapes.pop_back() # NOTE: Leave untyped
				extra_node.queue_free()

		#static_body_3d.set_display_folded(true)


## Sets a point with (out: Vector3.LEFT) as the starting point for the line/path to avoid (ERROR: The target vector can't be zero.)
func set_first_point(line_start_point: Vector3) -> void:
	# NOTE: REFERENCE: https://github.com/godotengine/godot/issues/70047 (AndreSacilotto)
	curve.add_point(line_start_point, Vector3.ZERO, Vector3.LEFT)

#var factor: float = 5
## Create a multimesh line from line_start_point to mouse release.
#func multimesh_to_line(collision_point: Vector3, line_start_point: Vector3, terrain = null) -> void:
func multimesh_to_line() -> void:

	# FIXME Find way to not refresh every time line changes or cache points CAN'T BECAUSE ALWAYS CHANGING. BUT CALCULATING POINT
	# HEIGHT WILL BE A HEAVY OPERATION EVERY TIME THE MOUSE IS MOVED AND LINE REDRAWN. SOLUTION -> ON RELEASE DO HEAVY OPEARATION OF POINT HEIGHT.
	curve.clear_points()
	xz_point_cache.clear()

	# FIXME We need to store top down points from starting point to end point and get the heights at those points not collision point for this to work.
	# 
	#if not line_point_cache.has(collision_point):
		#line_point_cache.append(collision_point)
	var y_value = collision_point.y
	var start_xz: Vector2 = Vector2(line_start_point.x, line_start_point.z)
	var end_xz: Vector2 = Vector2(collision_point.x, collision_point.z)






	##var line_length = start_xz.distance_squared_to(end_xz)
	#var line_length = start_xz.distance_to(end_xz)
	#var mm: MultiMesh = get_child(0).multimesh
	#var mesh_size = mm.mesh.get_aabb().size
	
	# Feedback loop to adjust segment mesh_count to more closely match mesh mesh_count.
	#num_segments = line_length / (mesh_size.x * factor)


	if mesh_count > 0:
		num_segments = mesh_count
	#curve.clear_points()
	#await get_tree().process_frame
	#else:
		#var num_segments = 100
	#if mesh_count < num_segments:
		#factor += .1
	#elif mesh_count > num_segments:
		#factor -= .1
	#num_segments = line_length / (mesh_size.x * factor)
	##num_segments = line_length / (mesh_size.x * 5)
	#push_error("num_segments: ", num_segments)

	# TODO check if works with both Terrain3D and not should since using collision point
	for i in range(num_segments + 1):
		var t = float(i) / float(num_segments)
		var xz_point = start_xz.lerp(end_xz, t)

		## FIXME TODO We store the xz_points here in an array and for each point in the array get the surface collision top down.
		#if not xz_point_cache.has(xz_point):
			#xz_point_cache.append(xz_point)
		#push_error("xz_point: ", xz_point)
		# TODO FIXME if terrain:
		# else: ...... for min_p
		# NOTE TODO Consider storing curve point offsets like _forward_3d_gui_input
		if terrain or terra_brush:
			var point_height: float
			if terrain:
				point_height = terrain.data.get_height(Vector3(xz_point.x, y_value, xz_point.y))
			else:
				point_height = terra_brush.getHeightAtPosition(xz_point.x, xz_point.y, true)
			var global_point = Vector3(xz_point.x, point_height, xz_point.y)
			var local_point = to_local(global_point)
			curve.add_point(local_point)
		#if terra_brush:
			#var point_height: float = terra_brush.getHeightAtPosition(xz_point.x, xz_point.y, true)
			##var point_height: float = terrain.data.get_height(Vector3(xz_point.x, y_value, xz_point.y))
			#var global_point = Vector3(xz_point.x, point_height, xz_point.y)
			#var local_point = to_local(global_point)
			#curve.add_point(local_point)
		else:
			# FIXME TODO We store the xz_points here in an array and for each point in the array get the surface collision top down.
			if not xz_point_cache.has(xz_point):
				xz_point_cache.append(xz_point)


			##push_error("collision_point: ", collision_point)
			## FIXME Need to get height at the point cache points created and use those? Clear cache on left mouse button release
			#var global_point = Vector3(xz_point.x, y_value, xz_point.y)
			#var local_point = to_local(global_point)
			#curve.add_point(local_point)
			
			#push_error("y_value: ", y_value)
			#
			## WILL BE OFF BUT TEST
			## Cache y values and feed them back in pop.back
			## As point gets added add to cache
			#if not line_point_cache.has(local_point):
				#line_point_cache.append(local_point)
	if not terrain:
		#emit_signal("get_xz_point_heights", xz_point_cache)
		var xz_point_heights = await return_xz_point_heights(xz_point_cache)
		#await get_tree().process_frame
		#push_error("xz_point_heights: ", xz_point_heights)
		
		for point_height: float in xz_point_heights:
			var xz_point: Vector2 = xz_point_cache.pop_back()
			var global_point = Vector3(xz_point.x, point_height, xz_point.y)
			var local_point = to_local(global_point)
			
			curve.add_point(local_point)

		##curve.clear_points()
		###push_error("line_point_cache: ", line_point_cache)
		#for i: int in curve.size():
			#
			#var point: Vector3 = line_point_cache.pop_front()
			#var new_point: Vector3 = curve.get_closest_point(point)
			#var point_position: int = line_point_cache.find(new_point)
			#curve.add_point(line_point_cache.pop_at(point_position))
#
		###
			####if not line_point_cache.has(xz_point):
				####line_point_cache[xz_point] = y_value
			###push_error("line_point_cache: ", line_point_cache)
			###var global_point = Vector3(xz_point.x, line_point_cache.pop_front(), xz_point.y)
			###var local_point = to_local(global_point)
			##
			##curve.add_point(line_point_cache.pop_front())
			###if set_start_point:
				###set_start_point = false
				###curve.add_point(local_point)
			###if not curve.get_baked_points().has(local_point):
				###curve.add_point(local_point)
		###push_error("curve points: ", curve.get_baked_points())

var new_mesh_count: int = 0
#var intialize_path_first_point: bool = true
#var intialize_path_second_point: bool = true
## Create a multimesh along a drawn path. 
#func multimesh_to_path(collision_point: Vector3) -> void:
func multimesh_to_path() -> void:
	#curve.clear_points()

	# Place point every time mesh instance is created
	var mm: MultiMesh = get_child(0).multimesh
	var mesh_size = mm.mesh.get_aabb().size
	if mesh_spacing == 0.0:
		var base_spacing = mesh_size.x * instance_scale.x
		mesh_spacing = base_spacing + 0.001  # small epsilon to prevent overlap
		#mesh_spacing = base_spacing + 1  # small epsilon to prevent overlap






	var local_point = to_local(collision_point)
	if curve.point_count == 0:
		#push_error("self global poistion: ", global_position)
		#push_error("scene_preview.global_position: ", scene_preview.global_position)
		
		#curve.add_point(scene_preview.global_position - global_position)
		#curve.add_point(Vector3(-mesh_spacing /2, 0, 0))
		curve.add_point(Vector3.ZERO)

		#if local_point != Vector3.ZERO:
			#curve.add_point(local_point.normalized())
	
	
	
	if curve.point_count == 1 and local_point != Vector3.ZERO:
		curve.add_point(local_point)







	if curve.point_count >= 2:
		## Get the last point and set it to the mouse position
		curve.set_point_position(curve.get_point_count() - 1, local_point)


		var path_length: float = curve.get_baked_length()
		#push_error("path_length: ", path_length)

		## Place point every time mesh instance is created
		#var mm: MultiMesh = get_child(0).multimesh
		#var mesh_size = mm.mesh.get_aabb().size
		#if mesh_spacing == 0.0:
			#var base_spacing = mesh_size.x * instance_scale.x
			#mesh_spacing = base_spacing + 0.001  # small epsilon to prevent overlap
			##mesh_spacing = base_spacing + 1  # small epsilon to prevent overlap

		# NOTE: Must be set after mesh_spacing changed from 0 to prevent ERROR Condition "p_count < 0" is true.
		var mesh_count = floor(path_length / mesh_spacing)
		#push_error("mesh_count: ", mesh_count)
		#mm.instance_count = mesh_count
		#var offset = mesh_spacing/2.0
		#for i in range(0, mesh_count):
			#var curve_distance = offset + mesh_spacing * i
		if new_mesh_count != mesh_count:
			new_mesh_count = mesh_count
			if not collision_point == Vector3.ZERO and not collision_point.is_equal_approx(last_point_added):
				#var local_point = to_local(collision_point)
				curve.add_point(local_point)
				last_point_added = collision_point
				#point_count = 0







	#point_count += 1
	## TODO Consider setting 1 point for each mesh objects center along line for both path and line. 
	#if point_count >= 5: # Sets the gap between points (Example: for every 30 points add a point to the curve.)
		#if not collision_point == Vector3.ZERO and not collision_point.is_equal_approx(last_point_added):
			#var local_point = to_local(collision_point)
			#curve.add_point(local_point)
			#last_point_added = collision_point
			#point_count = 0

# NOTE: This is here because?? For each point in the line when no Terrain3D Terrain edited?
#region non_collision_object_snapping DUPLICATE CODE MODIFIED
var scenario_rid: RID
var filtered_object_ids2: Array
const FLOAT64_MAX = 1.79769e308
var object_tris: Dictionary
var closest_object: Object = null
var closest_object_scale: Vector3 = Vector3.ZERO
#endregion

func return_xz_point_heights(xz_point_cache: Array[Vector2]) -> Array[float]:
	xz_point_heights.clear()
	if not scenario_rid:
		if EditorInterface.get_edited_scene_root():
			scenario_rid = EditorInterface.get_edited_scene_root().get_viewport().find_world_3d().get_scenario()
	for point: Vector2 in xz_point_cache:
		var ray_origin = Vector3(point.x, 1000, point.y)
		var ray_direction = Vector3.DOWN
		var ray_end: Vector3 = ray_origin + ray_direction * 10000
		var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)


#region non_collision_object_snapping DUPLICATE CODE MODIFIED
		filtered_object_ids2.clear()
		var min_t: float = FLOAT64_MAX
		var min_p = Vector3.ZERO # Expose min_p for Terrain3D support
		var min_n = Vector3.ZERO # Expose Min_n for Terrain3D Support
		var closest_object_id: int = -1

		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		if not scenario_rid:
			await get_tree().process_frame
			#scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()

		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)

		for object_id: int in object_ids:
			# Filter out duplicate ids
			if not filtered_object_ids2.has(object_id):
				filtered_object_ids2.append(object_id)


			# FIXME if subtract find way to only snap to inside of overlapping area?
			# Example Box with anoher subtract box inside and snapping to inside wall of "Room"
			# NOTE: Above will work easily with collision shape and raycast since collision shape is auto generated that has cutout
			# Exclude CSGShape3D that have operation subtract
			if instance_from_id(object_id) is CSGShape3D and instance_from_id(object_id).get_operation() == 2: #instance_from_id(object_id).OPERATION_SUBTRACTION:
				filtered_object_ids2.erase(object_id)


			# Exclude all objects that are not either MeshInstance3D or CSGShape3D
			filtered_object_ids2 = filtered_object_ids2.filter(
				func (object_id) -> bool: 
					return instance_from_id(object_id) is CSGShape3D or instance_from_id(object_id) is MeshInstance3D
			)


		## FIXME TODO CSGTerrain Support: CSGTerrain Node when selected and child line or scg edited then CSGTerrain node needs to be filtered out to recalculate collisions.
		## Also add support for when Terrain changed that objects follow edit. so we need height y at object position within area of edit like Terrain3D support adds.
		## FIXME not excluding csg shape3d
		## Exclude the scene_preview or selected node to reposition
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
		filter_out_object_ids(scene_preview)

		#idle = false

		if filtered_object_ids2:
			for object_id: int in filtered_object_ids2:
				if object_tris.keys().has(object_id):

					var tris: PackedVector3Array = object_tris[object_id]
					#if debug: print("tris: ", tris)
					for i: int in range(0, tris.size(), 3):
						var v0: Vector3 = tris[i + 0]
						var v1: Vector3 = tris[i + 1]
						var v2: Vector3 = tris[i + 2]
						# NOTE: The speed bottleneck is here running ray_intersects_triangle in rust within same script is much faster
						var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
						if res is Vector3:
							var len: float = ray_origin.distance_squared_to(res)

							if len < min_t:
								min_t = len
								min_p = res
								var v0v1: Vector3 = v1 - v0
								var v0v2: Vector3 = v2 - v0
								min_n = v0v2.cross(v0v1).normalized()
								closest_object_id = object_id

				else:
					var object = instance_from_id(object_id)
					var tris: PackedVector3Array = []
					if object is MeshInstance3D:
						var verts: PackedVector3Array = object.mesh.get_faces()
						for vert: Vector3 in verts:
							tris.append(object.global_transform * vert)

					else: # it is a CSGShape3D:
						var meshes: Array = object.get_meshes()
						var verts: PackedVector3Array = (meshes[1] as ArrayMesh).get_faces()
						for vert: Vector3 in verts:
							tris.append(object.global_transform * vert)
					object_tris[object_id] = tris

			if min_t < FLOAT64_MAX:
				closest_object = instance_from_id(closest_object_id)
				#if debug: print("object name: ", closest_object.name)
				#if debug: print("Snapping to object: ", closest_object.get_parent().name)
				closest_object_scale = closest_object.get_scale()
					#
				##if debug: print("closest_object scale: ", closest_object.get_scale())
				##if debug: print("object property list: ", closest_object.get_property_list())
				#if closest_object.has_meta("extras"):
					#var metadata: Dictionary = closest_object.get_meta("extras")
#
				## Support for Terrain3D
				#if not terrain_3d_plugin_active or terrain == null:
				xz_point_heights.append(min_p.y)

	return xz_point_heights


#endregion

## Filter out specific MeshInstance3D and CSGShape3D node and all its children MeshInstance3D and CSGShape3D nodes
func filter_out_object_ids(node: Node3D) -> void:
	if node:
		filtered_object_ids2.erase(node.get_instance_id())

		var mesh_node_instances: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
		for mesh_node: MeshInstance3D in mesh_node_instances:
			filtered_object_ids2.erase(mesh_node.get_instance_id())

		var csg_node_instances: Array[Node] = node.find_children("*", "CSGShape3D", true, false)
		for mesh_node: CSGShape3D in csg_node_instances:
			filtered_object_ids2.erase(mesh_node.get_instance_id())




func _on_curve_changed():
	is_dirty = true
