@tool
extends TextureButton

@onready var res_dir = DirAccess.open("res://")

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# How can I implement drag and drop into the scene from my EditorPlugin? (idbrii)
# REFERENCE: https://forum.godotengine.org/t/how-can-i-implement-drag-and-drop-into-the-scene-from-my-editorplugin/3804/2
func _get_drag_data(position: Vector2) -> Variant:

	create_scene_folder()
	# TODO Add check for project settings Custom user diretory name match before assigning var user_dir = DirAccess.open("user://scenes")
	#var res_dir = DirAccess.open("res://")
	if res_dir:
		# Skip reimporting if file exists # FIXME add option to skip this step if user wants to overwrite existing scenes
		if res_dir.file_exists("res://scenes/" + self.name + ".tscn"):
			pass
			#get_drag_data_forward()
			#return
		else:
			var result = res_dir.copy("user://scenes/" + self.name + ".tscn", "res://scenes/" + self.name + ".tscn")
			if result == OK:
				pass
				#print("File copied successfully.")
			else:
				print("Failed to copy file.")
			# Scan the filesystem to update
			var editor_filesystem = EditorInterface.get_resource_filesystem()
			editor_filesystem.scan()




	return {
		files = ["res://scenes/" + self.name + ".tscn"], # something like "res://assets/truck.tscn"
		type = "files",
	}


func create_scene_folder():
	if not res_dir.dir_exists_absolute("res://scenes"):
		res_dir.make_dir_absolute("res://scenes")
