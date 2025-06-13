#@tool
#extends EditorScenePostImport
#
#var material = preload("res://polywar-texture.tres")
#
#func _post_import(scene):
	#scene.get_children()[0].set_surface_override_material(0, material)
	#return scene 
	
# This script is used to re-import gltf assets to make rigidbody objects with custom collosion meshes.
# It also saves the rigidbody with collisions as a *.tscn in res://
# 
# Your gltf should have exactly one mesh with multiple children
# The root mesh is used for the MeshInstance3D of the RigidBody3D
# the child meshes are turned into CollisionShape3Ds for the RigidBody3D
#
# To use:
# 1) Import gltf normally into Godot 4
# 2) Select the resource in the FileSystem pane
# 3) Select the Import pane
# 4) Scroll down and load this script as the "Import Script"
# 5) Select re-import

@tool
extends EditorScenePostImport

#signal finished_scene_import
#const SceneViewer = preload("res://addons/scene_snap/scripts/scene_viewer.gd")
#var main_collection_tab: TabBar = SceneViewer.new_main_collection_tab

#var material = preload("res://materials/new_standard_material_3d.tres")
#var new_texture = preload("res://textures/Synty Dungeon Pack/Textures/Dungeons_Texture_01.png")
#var new_texture = preload("res://textures/PolygonHorror_Texture_01_A.png")

# NOTE IF SYNTY ROOT SCALE NEEDS TO BE X 100

# NOTE Will return the first MeshInstance3D that is found from parent down to grandchildren
func find_mesh_instance_3d_child(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
		
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
			
	for child in node.get_children():
		var grandchild = find_mesh_instance_3d_child(child)
		if grandchild:
			return grandchild
			
	return null




var new_fbx_state = FBXState.new()
var new_object = Object.new()

func _post_import(scene: Node):

	var fbx_file_path: String

	#print(get_all_in_folder("res://"))
	var fbx_files_in_project: Array = get_all_in_folder("res://")
	for file_path: String in fbx_files_in_project:
		#print(full_path_split(file_path, true))
		var fbx_file: Array = full_path_split(file_path, true)
		if fbx_file[0] == scene.name + ".fbx":
			#print("YES IT DOES: ", file_path)
			fbx_file_path = file_path
		#print(fbx_file_path)
	#if fbx_files_in_project.has(scene.name + ".fbx"):
		#print("YES IT DOES")

	#var new_dir = EditorFileSystemDirectory.new()
	#print(new_dir.get_path())
	#var res_dir = DirAccess.open("res://")
	#print(res_dir.get_files())
	#print("scene_name: ", scene.name + ".fbx")
	#print(new_dir.find_file_index(scene.name + ".fbx"))
	##new_dir.find_file_index(scene.name)
#
	##print("scene: ", scene.get_property_list())
	#for property in scene.get_property_list():
		#var property_name = property.name
		#print(str(property_name) + ": ", scene.get(property_name))  # Use get() to access the property by name
		##print(scene.property_name)
	#print("scene_file_path: ", scene.scene_file_path)








	# Reference: https://docs.godotengine.org/en/latest/tutorials/io/runtime_file_loading_and_saving.html#d-scenes
	# Load an existing glTF scene.
	# GLTFState is used by GLTFDocument to store the loaded scene's state.
	# GLTFDocument is the class that handles actually loading glTF data into a Godot node tree,
	# which means it supports glTF features such as lights and cameras.
	var fbx_document_load = FBXDocument.new()
	var fbx_state_load = FBXState.new()
	var error = fbx_document_load.append_from_file(fbx_file_path, fbx_state_load)
	if error == OK:
	#FBXDocument::_parse(Ref<FBXState> p_state, String p_path, Ref<FileAccess> p_file)
	#var error = fbx_document_load._parse_images(fbx_state_load, fbx_file_path)
	#if error == OK:
		print("Great!!")
		
		
		
		#print("fbx_document_load: ", fbx_document_load)
		#print("fbx_state_load: ", fbx_state_load.get_textures())
		#var fbx_state_load_properties = fbx_state_load.get_property_list()
		for item in fbx_state_load.get_property_list():
			pass
			#print(item)
			#print(item.get(item.name))
		
		var textures = fbx_state_load.get_textures()
		for texture in textures:
			#print("list: ", texture.get_property_list())
			for item in texture.get_property_list():
				pass
				#print(texture.get(item.name))
			#print("texture resource path: ", texture.resource_path)
			#print("texture resource image: ", texture.src_image)

		#var gltf_scene_root_node = fbx_document_load.generate_scene(gltf_state_load)
		#add_child(gltf_scene_root_node)
	else:
		print("oops")
		#show_error("Couldn't load glTF scene (error code: %s)." % error_string(error))









	#print("new_fbx_state:", new_fbx_state)
	#
	#print("new_fbx_state.get_textures(): ", new_fbx_state.get_textures())
	
	#print("THIS IS THE SCENE: ", scene)
	#print("THESE ARE THE DEPENDENCIES FOR THIS SCENE: ", ResourceLoader.get_dependencies(scene.get_scene_file_path().get_file()))



	#var new_standard_material: StandardMaterial3D = StandardMaterial3D.new()
	#new_standard_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, new_texture)


	var mesh_node: MeshInstance3D
	mesh_node = find_mesh_instance_3d_child(scene)
	
	#print("mesh_node: ", mesh_node)

	if mesh_node == null:
		printerr("The imported scene does have a MeshInstance3D child or grandchild")

	var tscn_static_body = StaticBody3D.new()

	var tscn_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()


	# Rename StaticBody3D to MeshInstance3D Name
	tscn_static_body.name = mesh_node.name# + "--Tags"

	tscn_mesh_instance_3d = mesh_node.duplicate()

	
	tscn_static_body.add_child(tscn_mesh_instance_3d)
	tscn_mesh_instance_3d.set_owner(tscn_static_body)


	# Iterate through MeshInstance3D children to create individual collision shapes
	for child in tscn_static_body.get_children():

		#if child is MeshInstance3D and child.mesh:
			#child.set_surface_override_material(0, new_standard_material)

		var mesh_shape = child.mesh.create_trimesh_shape()
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = mesh_shape
		collision_shape.name = child.name + "_collision"
		# Apply the original mesh child's transform to the collision shape
		collision_shape.transform = child.transform
		# Add the collision shape to the RigidBody3D
		tscn_static_body.add_child(collision_shape)
		# Set the owner to ensure it's saved with the rigid_body # scene
		collision_shape.set_owner(tscn_static_body)
		#print("Added CollisionShape3D for: ", child.name)

	
	
	
	# Free the original scene root, as it's no longer needed
	scene.queue_free()


	## Create and save scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(tscn_static_body)
	var save_path = "res://scenes/" + tscn_static_body.name + ".tscn"
	#print("Saving scene... " + save_path)
	ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)

	#var editor_filesystem = EditorInterface.get_resource_filesystem()
	#editor_filesystem.scan()

	#emit_signal("finished_scene_import")
	return tscn_static_body





## Load files from directory | bcg-jackson
## REFERENCE: https://forum.godotengine.org/t/load-files-from-directory/13576/2
#func get_all_in_folder(path: String) -> Array:
	#var items: Array = []
	#var dir = DirAccess.open(path)
	#if not dir:
		#push_error("Invalid dir: " + path)
		#return items  # Return an empty list if the directory is invalid
#
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
		#if file_name.ends_with(".fbx"):
			#var full_path = path.path_join(file_name)
			##items.append(file_name)
			#items.append(full_path)
		#file_name = dir.get_next()
	#dir.list_dir_end()
	#return items


func get_all_in_folder(path: String) -> Array:
	var items: Array = []
	var dir = DirAccess.open(path)
	
	if not dir:
		push_error("Invalid dir: " + path)
		return items  # Return an empty list if the directory is invalid

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			# Recursively search in the subdirectory
			var subdirectory_path = path.path_join(file_name)
			items += get_all_in_folder(subdirectory_path)  # Append results from subdirectory
		elif file_name.ends_with(".fbx"):
			var full_path = path.path_join(file_name)
			items.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return items


func full_path_split(scene_full_path: String, get_scene_name: bool) -> PackedStringArray:
	var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 0)

	if get_scene_name:
		#var last_element: int = my_array[my_array.size() - 1]
		var index: int = scene_full_path_split.size() - 1
		var file_name: String = scene_full_path_split[index]
		var scene_name_split: PackedStringArray = file_name.split("--", false, 0)
		#print("scene_name_split: ", scene_name_split)
		return scene_name_split
	else:
		#print("scene_full_path_split: ", scene_full_path_split)
		return scene_full_path_split
