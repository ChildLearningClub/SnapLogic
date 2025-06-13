#@tool
#class_name TextureParsePrePass
#extends GLTFDocumentExtension
#
#
##func _get_saveable_image_formats() -> PackedStringArray:
	##print()
	##return ["image/png", "image/jpeg"]
##
### This function will be used to process the image import logic
##func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> Error:
	##print("")
	### Parse and process the image data here
	### You can decode image data, generate file paths, or handle the image as needed
	##if ret_image.load_png(image_data) != OK:
		##return FAILED
	##
	##return OK
##
### This function handles saving the image to the appropriate file path
##func _save_image_at_path(state: GLTFState, image: Image, file_path: String, image_format: String, lossy_quality: float) -> Error:
	### Save the image at the given file path
	### This can include specific logic for compression or saving to PNG, JPEG, etc.
	##return image.save_png(file_path)
#
#var count: int = 0
#var parsed_images: Array
#var parsed_images_mutex: Mutex
#
#var res_dir = DirAccess.open("res://")
#var process_single_threaded_list: Array[String] = []
#var collection_hased_images: Array[int] = []
#var collection_image_names: Array[String] = []
##var deduplicated_image_data: Array[int] = []
#var image_index: int = 0
#var last_state: GLTFState
#var glb_mesh_name: String = ""
#var state_instance_ids: Array = []
#
#func setup(mutex: Mutex, images: Array):
	#parsed_images_mutex = mutex
	#parsed_images = images
#
#
## TODO create material from textures and load that into cache lookup not the textures themselves they get copied in and material made and lookup created referencing material?
## TODO Need to create texture_lookup dictionary with mesh name as the key for texture quick scroll here and add to global cache? 
## NOTE: Will run one time for each image within a .glb file
#func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> int:
	#var image := Image.new()
#
	##var err := OK
##
	##if mime_type == "image/png":
		##err = image.load_png_from_buffer(image_data)
	##elif mime_type == "image/jpeg":
		##err = image.load_jpg_from_buffer(image_data)
	##else:
		##return ERR_PARSE_ERROR
##
	##if err != OK:
		##return ERR_PARSE_ERROR
#
#
	#ret_image.copy_from(image)
#
#
	#if not state_instance_ids.has(state.get_instance_id()):
		#state_instance_ids.append(state.get_instance_id())
#
		## Store for later processing
		#parsed_images_mutex.lock()
		#parsed_images.append({
			#"state": state,
			##"image": image.duplicate(),
			##"index": state.images.size() - 1,  # store texture index
			##"name": "texture_%s.png" % str(state.images.size() - 1)
		#})
		#parsed_images_mutex.unlock()
#
#
#
	##var json_data = state.get_json()
	##if json_data.has("meshes"):
		##for mesh_dict: Dictionary in json_data["meshes"]:
			##print(mesh_dict["name"])
			##
	##print("state: ", state.get_instance_id())
	#
##"meshes": [{ "name": "SM_Axe"
#
#
#
#
#
#
	##var image_hash: int = hash(image_data)
##
	##if not collection_hased_images.has(image_hash):
		##collection_hased_images.append(image_hash)
##
### Reset count when state changes? do they share the same state?
		##if state != last_state:
			##last_state == state
			##count += 1
			##print("reset count now this should print 40 times: ", count)
			##
		##var json_data = state.get_json()
		##print("json_data: ", json_data)
		###if json_data.has("images"):
			#### the first needs to match the first that goes through and the second the second
			###for glb_image in json_data["images"]:
				###if not collection_image_names.has(glb_image["name"]):
					###collection_image_names.append(glb_image["name"])
###
					###var image_save_path: String = "res://collections/test/textures/" + "_" + glb_image["name"] + ".png"
					###if not res_dir.file_exists(image_save_path):
						###
						###var err = image.load_png_from_buffer(image_data)
						###if err != OK:
							###return err
						###
						###image.save_png(image_save_path)
#
	#
	#return OK
#
#
#
#
#
#
#
#
#
##var image_index := 0  # Global or static counter (reset before each import if needed)
##
##func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> int:
	##var image := Image.new()
	##ret_image.copy_from(image)
##
	##var image_hash: int = hash(image_data)
##
	##if not collection_hased_images.has(image_hash):
		##collection_hased_images.append(image_hash)
##
		##var json_data = state.get_json()
		##if json_data.has("images") and image_index < json_data["images"].size():
			##var glb_image = json_data["images"][image_index]
##
			##var image_name = glb_image["name"] if glb_image.has("name") else "image_" + str(image_index)
			##if not collection_image_names.has(image_name):
				##collection_image_names.append(image_name)
##
				##var image_save_path: String = "res://collections/test/textures/" + image_name + ".png"
				##if not res_dir.file_exists(image_save_path):
##
					##var err = image.load_png_from_buffer(image_data)
					##if err != OK:
						##return err
##
					##image.save_png(image_save_path)
##
	##image_index += 1  # Move to the next image on the next call
	##return OK
#
#
#
#
#
#
##func deferred_call(image_data: PackedByteArray) -> void:
	##print("Custom importer received image data of size: ", image_data.size())
	#
##func _get_image_file_extension()
##
##
##func _import_preflight(state: GLTFState, extensions: PackedStringArray) -> Error:
	##return OK
#
#
#
#func parse_glb_json(path: String) -> Dictionary:
	#var file := FileAccess.open(path, FileAccess.READ)
	#if file == null:
		#push_error("Cannot open GLB file")
		#return {}
#
	## Read GLB header (12 bytes)
	#var magic = file.get_32() # Should be 0x46546C67 ('glTF')
	#var version = file.get_32()
	#var length = file.get_32()
#
	#if magic != 0x46546C67:
		#push_error("Not a valid GLB file")
		#return {}
#
	## Read first chunk header (JSON chunk)
	#var chunk_length = file.get_32()
	#var chunk_type = file.get_32()
#
	#if chunk_type != 0x4E4F534A: # ASCII for 'JSON'
		#push_error("First chunk is not JSON")
		#return {}
#
	## Read JSON string
	#var json_bytes = file.get_buffer(chunk_length)
	#var json_text = json_bytes.get_string_from_utf8()
#
	## Parse JSON
	#var result = JSON.parse_string(json_text)
	#if typeof(result) != TYPE_DICTIONARY:
		#push_error("Failed to parse GLB JSON chunk")
		#return {}
#
	#return result
#
#
#
##func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> Error:
	##if mime_type == "image/png":
		##print("ret_image: ", ret_image.resource_name)
		### Process PNG images
		##return ret_image.load_png(image_data)
	##elif mime_type == "image/jpeg":
		### Process JPEG images
		##return ret_image.load_jpeg(image_data)
	##else:
		### Handle unsupported formats
		##return FAILED
#
##func _save_image_at_path(state: GLTFState, image: Image, file_path: String, image_format: String, lossy_quality: float) -> Error:
	##if image_format == "png":
		##return image.save_png(file_path)
	##elif image_format == "jpeg":
		##return image.save_jpeg(file_path, lossy_quality)
	##else:
		##return FAILED
#
#
#
#
#
#





# NOTE: Need to do importing here with call-deferred methods for single-threaded operations
#@tool
class_name TextureParsePrePass
#extends GLTFDocumentExtension
extends GLTFDocumentExtensionConvertImporterMesh

#var parsed_images: Array
var parsed_images_mutex: Mutex
#var state_instance_ids: Array = []
#var state_instance_ids: Array = []
#var state_image_data_array: Array[PackedByteArray] = []
var image_data_lookup: Dictionary[int, Array] = {}

## Pass variables to share between scene_viewer.gd
func setup(mutex: Mutex, lookup: Dictionary[int, Array]):
	parsed_images_mutex = mutex
	image_data_lookup = lookup

#func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> int:
	#var image := Image.new()
	#ret_image.copy_from(image)
#
	#parsed_images_mutex.lock()
	#var state_id: int = state.get_instance_id() # I think this also needs to be locked up to prevent duplicate entries
	#if not image_data_lookup.has(state_id):
		#image_data_lookup[state_id] = []
#
#
	##if image.load_png_from_buffer(image_data) != OK:
		##push_error("png could not be loaded from buffer.")
	##var image_dup: Image = image.duplicate()
	#var image_dup: PackedByteArray = image_data.duplicate()
	#image_data_lookup[state_id].append(image_dup)  # Append the parsed image to the array
	##image_data_lookup[state_id].append(image)
	#parsed_images_mutex.unlock()
#
	#return OK


func _save_image_at_path(state: GLTFState, image: Image, file_path: String, image_format: String, lossy_quality: float) -> int:
	# Implement your custom image saving logic here
	# For example, log the file path or perform checks before saving
	print("Attempting to save image to: ", file_path)
	# Optionally, you can prevent the actual saving by not calling the base method
	# super._save_image_at_path(state, image, file_path, image_format, lossy_quality)
	return OK








#func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> int:
	##print("state id: ", state.get_instance_id())
	##print("state: ", state)
	##print("image_data: ", image_data.size())
	##return OK
	#var image := Image.new()
	#ret_image.copy_from(image)
	## This is adding a small delay between threads to prevent overlap
	##print("image_data.size: ", image_data.size())
	##print("image_data: ", image_data.size())
	#
	#
	#
	#
	##var state_id: int = state.get_instance_id()
	###var err = image.load_png_from_buffer(image_data)
	###if err != OK:
		###return err
## # NOTE: Can duplicate images be lookuped up by using image_data_lookup[state_id].append(image_data_lookup[state_id_of_ref_state][index of dup image])
	##var state_id: int = state.get_instance_id()
	##var err = image.load_png_from_buffer(image_data)
	##if err != OK:
		##return err
	#parsed_images_mutex.lock()
	#var state_id: int = state.get_instance_id() # I think this also needs to be locked up to prevent duplicate entries
	#if not image_data_lookup.has(state_id):
		#image_data_lookup[state_id] = []
	#image_data_lookup[state_id].append(image_data)  # Append the parsed image to the array
	#parsed_images_mutex.unlock()
#
#
	##### Check and set a flag within the GLTFState to indicate it has been processed
	###var processed_flag = state.get_additional_data("processed_flag")
	###if processed_flag == null:
		###state.set_additional_data("processed_flag", true)
	##### This is the first time processing this GLTFState instance
##
##
##
	##### Check and set a flag within the GLTFState to indicate it has been processed
	##var processed_flag = state.get_additional_data("processed_flag")
	##if processed_flag == null:
		##state.set_additional_data("processed_flag", true)
	##else:
		##print("this is the same state")
	##### This is the first time processing this GLTFState instance
##
##
##
	##var processed_flag = state.get_additional_data("processed_flag")
	##if state.get_additional_data("processed_flag"):
		##print("this is the same state")
		##state.set_additional_data("processed_flag", true)
	##else:
#
#
#
#
#
#
	### Safely append to parsed_images using the mutex
	##parsed_images_mutex.lock()
	##
	##state_image_data_array.append(image_data)
	##
	##image_data_lookup[state.get_instance_id()] = state_image_data_array
	##
	###print(state.get_json())
	##parsed_images.append({
		##"state": state,
		##"image": image_data,
	##})
	##parsed_images_mutex.unlock()
##
	#
##
	###if not state_instance_ids.has(state.get_instance_id()):
		###state_instance_ids.append(state.get_instance_id())
###
		#### Store for later processing
		###parsed_images_mutex.lock()
		###parsed_images.append({
			###"state": state,
###
		###})
		###parsed_images_mutex.unlock()
#
	#return OK


#func _parse_image_data(state: GLTFState, image_data: PackedByteArray, mime_type: String, ret_image: Image) -> int:
	##print("state: ", state)
	##print("image_data: ", image_data)
	#var image := Image.new()
	#ret_image.copy_from(image)
	#
	#
	#parsed_images.append(image_data)
	#
	##var json_data = state.get_json()
	##print("json_data: ", json_data)
	###if json_data.has("images"):
		#### the first needs to match the first that goes through and the second the second
		###for glb_image in json_data["images"]:
			###if not collection_image_names.has(glb_image["name"]):
				###collection_image_names.append(glb_image["name"])
###
				###var image_save_path: String = "res://collections/test/textures/" + "_" + glb_image["name"] + ".png"
				###if not res_dir.file_exists(image_save_path):
					###
					###var err = image.load_png_from_buffer(image_data)
					###if err != OK:
						###return err
					###
					###image.save_png(image_save_path)
	#
	#
	#return OK


#func _import_preflight(state: GLTFState, extensions: PackedStringArray) -> Error:
	#print("json: ", state.get_json())
	##print("state: ", state)
	#return OK





#func _parse_texture_json(state: GLTFState, texture_json: Dictionary, ret_gltf_texture: GLTFTexture) -> int:
	##var texture := GLTFTexture.new()
	##ret_gltf_texture.copy_from(texture)
	#print("texture_json: ", texture_json.size())
	#return OK




## NOTE: Will be required to relink .glb state to image textures paths before generating scene from gltfstate
func _import_pre_generate(state: GLTFState) -> int:
	#var material_array: Array[Material] = state.get_materials()
	#for material: Material in material_array:
		#print("material: ", material)
	# NOTE: print the source of extracted textures here to see what says?
	var textures_array: Array[GLTFTexture] = state.get_textures()
	for texture: GLTFTexture in textures_array:
		print("texture source image: ", texture.get_src_image())
		
	var image_array: Array[Texture2D] = state.get_images()
	for image: Texture2D in image_array:
		print("image.get_size(): ", image.get_size())
	
	return OK
