@tool
class_name GLTFLoader
extends Thread

var scene_full_path: String
var scene_instance: Node
var is_loaded: bool = false  # Flag to track loading state

func _init(path: String):
	scene_full_path = path

func _run(userdata) -> void:
	var gltf := GLTFDocument.new()
	gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
	
	var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	if scene_file:
		var file_bytes = scene_file.get_buffer(scene_file.get_length())
		scene_file.close()
		
		var gltf_state := GLTFState.new()
		gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
		
		var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
		for mesh in meshes:
			print("mesh: ", mesh)
		
		scene_instance = gltf.generate_scene(gltf_state)
		is_loaded = true  # Set the loading flag when done

# Function to start the thread and load the GLTF file
func load_gltf_async(priority: int = Thread.PRIORITY_NORMAL) -> int:
	return start(self._run.bind(self), priority)  # Ensure you're binding the run method

# Function to retrieve the loaded scene instance
func get_scene_instance() -> Node:
	if is_loaded:
		return scene_instance
	return null  # Return null if the scene isn't loaded yet
	#return scene_instance

# Function to wait for the thread to finish and retrieve the result
func wait_for_result() -> Variant:
	return wait_to_finish()
