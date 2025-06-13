@tool
extends EditorScenePostImport

# Reference: https://www.reddit.com/r/godot/comments/1j40ebq/why_are_so_few_people_talking_about_how_bad_the/ (HornyForMeowstic)


var folder: String

var mesh_counter: int = 1
var material_counter: int = 1
var shape_counter: int = 1

func _post_import(scene: Node) -> Object:
	# locate file and folder
	var file: String = get_source_file()
	folder = file.left(file.rfind("/") + 1)
	# start iteration
	iterate(scene)
	return scene

# Can the speed of scene_view button scrolling between meshes be inscreased by creating a dictionary 
# of all the meshinstance3d nodes rather then instancing them everytime? Seems yes. 
# If scene file changes externally would need to be rebuilt and over write existing mesh
func iterate(node: Node) -> void:
	# mesh # NOTE keep material in mesh and use surface material override for shared 
	if node is MeshInstance3D:
		var number: String
		if mesh_counter > 1:
			number = str(mesh_counter)
		#var path: String = folder + "mesh" + number + ".res"
		var path: String = folder + node.name + "_mesh" + number + ".res"
		ResourceSaver.save(node.mesh, path)
		prints("Mesh found and saved as", path)
		mesh_counter += 1
		#for surface_idx in range(node.mesh.surface_count):

		# material
		for material_index: int in node.mesh.get_surface_count():
			var count: String
			if material_counter > 1:
				count = str(material_counter)
			var material_path: String = folder + node.name + "_material" + number + ".res"
			var material =  node.mesh.surface_get_material(material_index)
			ResourceSaver.save(material, material_path)
			prints("Material found and saved as", path)
			material_counter += 1



	# shape
	elif node is CollisionShape3D:
		var number: String
		if shape_counter > 1:
			number = str(shape_counter)
		var path: String = folder + node.name + "_shape" + number + ".res"
		ResourceSaver.save(node.shape, path)
		prints("Shape found and saved as", path)
		shape_counter += 1
	# iterate over all nodes in the scene
	for child: Node in node.get_children():
		iterate(child)



#@tool
#extends EditorScenePostImport
#
#var folder: String
#
#var mesh_counter: int = 1
#var material_counter: int = 1
#var shape_counter: int = 1
#var animation_player_counter: int = 1
#var animation_counter: int = 1
#var light_counter: int = 1
#var camera_counter: int = 1
#var particle_counter: int = 1
#var audio_counter: int = 1
#var shader_counter: int = 1
#var skeleton_counter: int = 1
#var script_counter: int = 1
#var animation_tree_counter: int = 1
#
#func _post_import(scene: Node) -> Object:
	## Locate file and folder
	#var file: String = get_source_file()
	#folder = file.left(file.rfind("/") + 1)
	#
	## Start iteration
	#iterate(scene)
	#return scene
#
#func iterate(node: Node) -> void:
	## Mesh
	#if node is MeshInstance3D:
		#var mesh_number: String = str(mesh_counter)
		#var mesh_path: String = folder + node.name + "_mesh" + mesh_number + ".res"
		#ResourceSaver.save(node.mesh, mesh_path)
		#prints("Mesh found and saved as", mesh_path)
		#mesh_counter += 1
		#
		## Material extraction
		#for material_index in range(node.mesh.get_surface_count()):
			#var material_path: String = folder + node.name + "_material" + str(material_counter) + ".res"
			#var material = node.mesh.surface_get_material(material_index)
			#ResourceSaver.save(material, material_path)
			#prints("Material found and saved as", material_path)
			#material_counter += 1
#
	## Shape
	#elif node is CollisionShape3D:
		#var shape_number: String = str(shape_counter)
		#var shape_path: String = folder + node.name + "_shape" + shape_number + ".res"
		#ResourceSaver.save(node.shape, shape_path)
		#prints("Shape found and saved as", shape_path)
		#shape_counter += 1
		#
	## AnimationPlayer extraction
	#elif node is AnimationPlayer:
		#var anim_player_number: String = str(animation_player_counter)
		#var anim_player_path: String = folder + node.name + "_animation_player" + anim_player_number + ".res"
		#ResourceSaver.save(node, anim_player_path)
		#prints("AnimationPlayer found and saved as", anim_player_path)
		#animation_player_counter += 1
		#
		## Extract animations
		#for anim_name in node.get_animation_names():
			#var anim: Animation = node.get_animation(anim_name)
			#var anim_path: String = folder + node.name + "_" + anim_name + "_animation" + str(animation_counter) + ".res"
			#ResourceSaver.save(anim, anim_path)
			#prints("Animation found and saved as", anim_path)
			#animation_counter += 1
	#
	## Light
	#elif node is Light3D:
		#var light_number: String = str(light_counter)
		#var light_path: String = folder + node.name + "_light" + light_number + ".res"
		#ResourceSaver.save(node, light_path)
		#prints("Light found and saved as", light_path)
		#light_counter += 1
		#
	## Camera
	#elif node is Camera3D:
		#var camera_number: String = str(camera_counter)
		#var camera_path: String = folder + node.name + "_camera" + camera_number + ".res"
		#ResourceSaver.save(node, camera_path)
		#prints("Camera found and saved as", camera_path)
		#camera_counter += 1
		#
	## Particle Systems
	#elif node is CPUParticles3D or node is GPUParticles3D:
		#var particle_number: String = str(particle_counter)
		#var particle_path: String = folder + node.name + "_particle" + particle_number + ".res"
		#ResourceSaver.save(node, particle_path)
		#prints("Particle system found and saved as", particle_path)
		#particle_counter += 1
	#
	## Audio
	#elif node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		#var audio_number: String = str(audio_counter)
		#var audio_path: String = folder + node.name + "_audio" + audio_number + ".res"
		#ResourceSaver.save(node.stream, audio_path)
		#prints("Audio found and saved as", audio_path)
		#audio_counter += 1
		#
	## ShaderMaterial
	#elif node is ShaderMaterial:
		#var shader_number: String = str(shader_counter)
		#var shader_path: String = folder + node.name + "_shader_material" + shader_number + ".res"
		#ResourceSaver.save(node, shader_path)
		#prints("Shader material found and saved as", shader_path)
		#shader_counter += 1
		#
	## Skeleton (if applicable)
	#elif node is Skeleton3D:
		#var skeleton_number: String = str(skeleton_counter)
		#var skeleton_path: String = folder + node.name + "_skeleton" + skeleton_number + ".res"
		#ResourceSaver.save(node, skeleton_path)
		#prints("Skeleton found and saved as", skeleton_path)
		#skeleton_counter += 1
		#
	## Script attached to node
	#elif node is Node:
		#if node.script:
			#var script_number: String = str(script_counter)
			#var script_path: String = folder + node.name + "_script" + script_number + ".gd"
			#ResourceSaver.save(node.script, script_path)
			#prints("Script found and saved as", script_path)
			#script_counter += 1
		#
	## AnimationTree
	#elif node is AnimationTree:
		#var animation_tree_number: String = str(animation_tree_counter)
		#var animation_tree_path: String = folder + node.name + "_animation_tree" + animation_tree_number + ".res"
		#ResourceSaver.save(node, animation_tree_path)
		#prints("AnimationTree found and saved as", animation_tree_path)
		#animation_tree_counter += 1
	#
	## Iterate over all nodes in the scene
	#for child in node.get_children():
		#iterate(child)
