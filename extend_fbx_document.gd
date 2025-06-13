@tool
extends FBXDocument

## This is a public method that safely uses the private method
#func get_texture_path(base_dir: String, source_file_path: String) -> String:
	## Call the private method, or handle logic here as needed
	#return generate_scene(base_dir, source_file_path)
	
var editor_filesystem = EditorInterface.get_resource_filesystem()
var settings = EditorInterface.get_editor_settings()
	
func _init() -> void:
	check_filesystem()
	
	#settings.erase("scene_snap_plugin/panel_position")
	# `settings.set("some/property", 10)` also works as this class overrides `_set()` internally.
	#settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
	#settings.set_setting("scene_snap_plugin/panel_position", scene_viewer_panel_instance.global_position)
	# `settings.get("some/property")` also works as this class overrides `_get()` internally.
	#panel_floating_on_start = settings.get_setting("scene_snap_plugin/panel_floating_on_start")
#
	#editor_filesystem.filesystem_changed.connect(check_filesystem)
#
#
	##settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
	#settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.get_parent().size)
	#settings.set_setting("scene_snap_plugin/panel_window_position", scene_viewer_panel_instance.get_parent().position)


func check_filesystem():
	print("Lets Rock")
	var fbx_file_path: String
	var current_fbx_files: Array[PackedStringArray] = []
	#print(get_all_in_folder("res://"))
	var fbx_files_in_project: Array = get_all_in_folder("res://")
	for file_path: String in fbx_files_in_project:
		print(full_path_split(file_path, true))
		var fbx_file: PackedStringArray = full_path_split(file_path, true)
		current_fbx_files.append(fbx_file)
		
	
	if settings.get_setting("scene_snap_plugin/project_fbx_files"):
		var previous_fbx_files: Array[PackedStringArray] = settings.get_setting("scene_snap_plugin/project_fbx_files")
		print("previous_fbx_files: ", previous_fbx_files)
		for file in current_fbx_files:
			if previous_fbx_files.has(file):
				print("This file was already here: ", file)
			else:
				print("This is a new file: ", file)

	else:
		pass

	settings.set_setting("scene_snap_plugin/project_fbx_files", current_fbx_files)
	
		#var fbx_file: Array = full_path_split(file_path, true)
		#if fbx_file[0] == scene.name + ".fbx":
			##print("YES IT DOES: ", file_path)
			#fbx_file_path = file_path


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
