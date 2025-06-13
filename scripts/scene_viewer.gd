@tool
extends Control

var debug = preload("uid://dfb5uhllrlnbf").new().run()

@export_tool_button("hello")  var hello_action = generate_scene_sub_meshinstance3d
#const GltfTextureImporter = preload("res://addons/scene_snap/scripts/gltf_texture_importer.gd")


# NOTE --TAGS currently not working
# NOTE IF SYNTY ROOT SCALE NEEDS TO BE X 100
#var new_texture = preload("res://textures/Synty Dungeon Pack/Textures/Dungeons_Texture_01.png")
#var new_texture = preload("res://textures/PolygonBattleRoyale_Texture_01_A.png")
#var new_texture = preload("res://imports/Textures/colormap.png")
var new_texture_path: String = ""


# NOTE left off thinking about visiblity notifier and hiding thumbnails not in view
# NOTE left off figuring out how to get .glb files recognized by resource loader and buttons created as well as errors with .glb import 

# TODO instantiate Texture rec for each viewport and assign viewport path to those viewports
# FIXME Viewport Texture must be set to use it.
# TODO Add check for project settings Custom user diretory name match before assigning var user_dir = DirAccess.open("user://scenes")




#region Signals
signal pass_current_scene_up
signal tab_scene_buttons_created
signal scenes_loaded
signal load_complete
signal make_floating_panel
signal do_file_copy
signal change_physics_body_type_2d
signal change_physics_body_type_3d
signal change_collision_shape_3d
signal gen_lods
signal instantiate_as_scene
signal visible_scene_preview_collisions
signal set_enable_collision
signal enable_node_pinning
signal make_resources_unique
signal bubble_up_selected_sub_tab_changed
signal enable_distraction_free_mode
signal match_target_scale(match_target_scale: bool)

signal update_selected_scene_view_button(scene_view_button: Button)
signal finished_processing_collection(collection_name: String)
signal finished_image_hashing
signal finished_collection_chunks
#signal process_next_collection(collection_file_names: PackedStringArray)
signal process_next_collection
signal get_current_scene_preview
signal initialize_filters
#signal update_mesh_material(current_scene_path: String, surface: int, material: StandardMaterial3D) ## Pass up StandardMaterial3D from pressed/cycled material Button. 
#signal finished_image_import
#endregion





#region Constants

const FILTER_2D_3D = preload("res://addons/scene_snap/icons/filter_2d3d.svg")
const FILTER_2D = preload("res://addons/scene_snap/icons/filter_2d.svg")
const FILTER_3D = preload("res://addons/scene_snap/icons/filter_3d.svg")



const SCENE_VIEW = preload("res://addons/scene_snap/plugin_scenes/scene_view.tscn")

const SCENE_VIEW_CLONE = preload("res://addons/scene_snap/plugin_scenes/scene_view_clone.tscn")

const MAIN_COLLECTION_TAB = preload("res://addons/scene_snap/plugin_scenes/main_collection_tab.tscn")
const MAIN_FAVORITES_TAB = preload("res://addons/scene_snap/plugin_scenes/main_favorites_tab.tscn")
const MAIN_PROJECT_SCENES_TAB = preload("res://addons/scene_snap/plugin_scenes/main_project_scenes_tab.tscn")
const MainCollectionTab = preload("res://addons/scene_snap/scripts/main_collection_tab.gd")
const SUB_COLLECTION_TAB = preload("res://addons/scene_snap/plugin_scenes/sub_collection_tab.tscn")
const SCENE_VIEW_CAMERA_3D = preload("res://addons/scene_snap/plugin_scenes/scene_view_camera_3d.tscn")
const TAG = preload("res://addons/scene_snap/icons/Tag.svg")


# Mesh icons
#const MULTI_CONVEX = preload("res://addons/scene_snap/icons/multi_convex.svg")
#const MULTI_CONVEX = preload("res://addons/scene_snap/icons/multi_convex.svg")
const SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D = preload("res://addons/scene_snap/icons/SimplifiedConvexPolygonShape3D.svg")
const SINGLE_CONVEX_POLYGON_SHAPE_3D = preload("res://addons/scene_snap/icons/SingleConvexPolygonShape3D.svg")
const MULTI_CONVEX_POLYGON_SHAPE_3D = preload("res://addons/scene_snap/icons/MultiConvexPolygonShape3D.svg")
#const SIMPLIFIED_CONVEX = preload("res://addons/scene_snap/icons/simplified_convex.svg")
#const SINGLE_CONVEX = preload("res://addons/scene_snap/icons/single_convex.svg")
#const TRIMESH = preload("res://addons/scene_snap/icons/trimesh.svg")
const NO_COLLISION = preload("res://addons/scene_snap/icons/no_collision.svg")



# TEST
#@onready var scene_creation_toggle_button_2: Button = $HBoxContainer/VBoxContainer/SceneCreationToggleButton2
#@onready var scene_state_number2: Label = $HBoxContainer/VBoxContainer/SceneCreationToggleButton2/SceneStateNumber
#@onready var enable_pinning_toggle_button2: TextureButton = $HBoxContainer/VBoxContainer/SceneCreationToggleButton2/EnablePinningToggleButton
#@onready var unique_sub_resources_toggle_button2: TextureButton = $HBoxContainer/VBoxContainer/SceneCreationToggleButton2/UniqueSubResourcesToggleButton

@onready var unique_sub_resources_toggle_button2: TextureButton = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/UniqueSubResourcesToggleButton
@onready var enable_pinning_toggle_button2: TextureButton = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/EnablePinningToggleButton
@onready var scene_creation_toggle_button_2: Button = $HBoxContainer/VBoxContainer/HBoxContainer/SceneCreationToggleButton

@onready var settings = EditorInterface.get_editor_settings()



#const H_SPLIT_CONTAINER = preload("res://addons/scene_snap/icons/HSplitContainer.svg")

const SceneSnapPlugin = preload("res://addons/scene_snap/scene_snap_plugin.gd")
@onready var scene_snap_plugin_ref = SceneSnapPlugin.new()

#endregion

#region Onready Varables
# TEST Distraction Free MODE
@onready var color_rect: ColorRect = $ColorRect
@onready var v_box_container: VBoxContainer = $HBoxContainer/VBoxContainer


@onready var h_box_container: HBoxContainer = $HBoxContainer


@onready var scene_state_number: Label = $HBoxContainer/VBoxContainer/SceneCreationToggleButton/SceneStateNumber

@onready var enable_pinning_toggle_button: TextureButton = $HBoxContainer/VBoxContainer/SceneCreationToggleButton/EnablePinningToggleButton

@onready var unique_sub_resources_toggle_button: TextureButton = $HBoxContainer/VBoxContainer/SceneCreationToggleButton/UniqueSubResourcesToggleButton

@onready var body_3d_number: Label = $HBoxContainer/VBoxContainer/ChangeBodyType3DButton/Body3DNumber
@onready var body_3d_warning: TextureRect = $HBoxContainer/VBoxContainer/ChangeBodyType3DButton/Body3DWarning


@onready var collision_3d_number: Label = $HBoxContainer/VBoxContainer/ChangeCollisionShape3DButton/Collision3DNumber
@onready var collision_3d_warning: TextureRect = $HBoxContainer/VBoxContainer/ChangeCollisionShape3DButton/Collision3DWarning
@onready var collision_visibility_toggle_button: TextureButton = $HBoxContainer/VBoxContainer/ChangeCollisionShape3DButton/CollisionVisibilityToggleButton


@onready var scene_creation_toggle_button: Button = $HBoxContainer/VBoxContainer/SceneCreationToggleButton




@onready var gen_lod_button: Button = $HBoxContainer/VBoxContainer/GenLODButton
@onready var main_tab_container: TabContainer = %MainTabContainer


@onready var change_body_type_2d_button: Button = %ChangeBodyType2DButton
@onready var change_body_type_3d_button: Button = %ChangeBodyType3DButton


@onready var scene_viewer: Control = $"."
@onready var res_dir = DirAccess.open("res://")
@onready var user_dir = DirAccess.open("user://")
@onready var h_split_container: HSplitContainer = %HSplitContainer

@onready var split_panel: TextureButton = %SplitPanel
@onready var zoom_v_slider: VSlider = %ZoomVSlider
@onready var make_floating: TextureButton = %MakeFloating
#@onready var pin_panel: TextureButton = %PinPanel

@onready var change_collision_shape_2d_button: Button = %ChangeCollisionShape2DButton
@onready var change_collision_shape_3d_button: Button = %ChangeCollisionShape3DButton


@onready var material_button_mesh_instance_3d: MeshInstance3D = %MaterialButtonMeshInstance3D
@onready var material_button_surface_selection: Button = $HBoxContainer/VBoxContainer/ChangeMaterialButton/MaterialButtonSurfaceSelection
@onready var favorite_material_button: TextureButton = %FavoriteMaterialButton
@onready var enable_favorites_cycle_button: TextureButton = $HBoxContainer/VBoxContainer/ChangeMaterialButton/EnableFavoritesCycleButton

@onready var material_3d_number: Label = $HBoxContainer/VBoxContainer/ChangeMaterialButton/Material3DNumber


@onready var path_to_thumbnail_cache_project: String = "user://project_scenes/thumbnail_cache_project/"
@onready var path_to_thumbnail_cache_global: String = "user://global_collections/thumbnail_cache_global/"
@onready var path_to_thumbnail_cache_shared: String = "user://shared_collections/thumbnail_cache_shared/"
#@onready var shared_collections_path: String = "user://shared_collections/scenes/"

@onready var scenes_paths: Array[String] = ["user://global_collections/scenes/", "user://shared_collections/scenes/"]

# FIXME UPDATE to use above
#@onready var shared_collections_path: String = "user://shared_collections/scenes/"
#@onready var project_scenes_path: String = "res://textures/"
@onready var project_scenes_path: String = "res://collections/"
#@onready var main_tab_paths: Array[String] = ["user://shared_collections/scenes/Shared Collections", "user://global_collections/scenes/Global Collections"]
#endregion

#region Variables

var new_main_project_scenes_tab: Control # Needed for scene_snap_plugin reference to update Project Scenes folder view

var rotate: bool = false

var setup_tabs: bool = true
var main_tab_clone

var all_scenes: Array = [] # NOTE NOT USED
var all_scenes_instances: Array = []
var all_scene_cameras: Array = []
var all_2d_scenes: Array[Node] = []
var all_3d_scenes: Array[Node] = []
var scene_view_instances: Array[Node] = []
var include_dir: bool = true

# Split container variables
var current_offset: int = 0
var min_max_offsets: int = 20
var create_duplicate: bool = true

@onready var thumbnail_size_value: float = zoom_v_slider.value#128

var scene_favorites: Array[String] = []
#var scene_has_animation: Array[String] = []
#var scene_favorites: Array = []
#var last_session_favorites: Array[String] = []
#var last_session_favorites: Array = []
#var favorites: Control = null
var new_favorites_tab: Control = null
var restore_data: bool = true
var open_favorites_tab: bool = true


var scene_path_button_id_match: Dictionary = {}
var current_scene_path: String = ""


var load_next_folder: bool = true
var loaded_scene_count: int = 0

var loading_index: int = 0
var previous_scenes_dir_path: String
var initialize_dir_path: bool = true
var atlas_texture_data: Array[Texture2D] = []
var tags: PackedStringArray = []

var last_scene_path: String # reset loaded_scene_count with new subfolder
var file_full_path: String
var thumbnail_lookup_dict: Dictionary = {}

#var create_2d_local_scenes_tab: bool = true
#var create_3d_local_scenes_tab: bool = true

var new_main_collection_tab: TabBar # global so that import script can use it

var await_on_startup: bool = true

var texture_file_names: Array[String] = []
var project_textures_full_path: String = ""

var saved_data_restored: bool = false

var one_time_scan: bool = true
var current_selected_directory: String = ""

var last_sub_collection_tab: Control
var initialize_last_sub_collection_tab: bool = true

var enable_panel_button_sizing: bool = false

var scenes_with_multiple_meshes: Dictionary[String, Array] = {} # Scene {Name: Array} of MeshInstance3D
var scenes_with_mesh_tag_data: Dictionary[String, Array] = {} # Scene {Name: Array} of Tags

#var global_and_shared_tags: Dictionary[Button, Dictionary] = {} # Scene view button {Button: [

var scenes_with_global_tags: Dictionary[String, Array] = {} # Scene {Name: Array} of Tags
#TEST
#var scenes_with_global_tags: Dictionary[String, Array] = {"altar-wood": ["panel", "church", "box"]} # Scene {Name: Array} of Tags
var scenes_with_shared_tags: Dictionary[String, Array] = {} # Scene {Name: Array} of Tags
var global_and_shared_tags: Dictionary[String, Dictionary] = {} # # Scene {Name: Dictionary} of {[shared_tags], [global_tags]}


var accepted_file_ext: Array[String] = ["fbx", "FBX", "obj", "blend", "gltf", "glb", "dae", "tscn", "scn"]

var clear_selected_enabled: bool = false
var main_collection_tabs: Array[Node] = []

var unused_collection_scenes_path: Array[String] = []
var remove_unused_collections: bool = true

# TODO Check if two arrays are required think can use just one and overwrite
var folder_project_scenes: Array[String] = []


var all_project_files: Array[String] = []
#var folder_project_files: Array[String] = []

var all_project_folders: Array[String] = []

var continue_load: bool = false
var active_material: StandardMaterial3D
#var set_default_material: bool = true
var hold_current_material: bool = true
var held_current_material_index: int = -1
var processed_collections: Array[String] = []

var scene_data_cache: SceneDataCache = SceneDataCache.new()
#var collection_ready_lookup: Dictionary[String, bool] = {}

#var closest_object_scale: Vector3 = Vector3.ZERO
var current_scene_preview: Node = null
var mesh_tag_import: bool = true
var sharing_disabled: bool = false

#endregion

const PROJECT_ICON = preload("res://addons/scene_snap/icons/project_icon.svg")

const GLOBAL_ICON = preload("res://addons/scene_snap/icons/GlobalIcon.svg")
const SHARED_ICON = preload("res://addons/scene_snap/icons/SharedIcon.svg")


const GREY_HEART = preload("res://addons/scene_snap/icons/grey_heart.svg")
const FAVORITES_ICON = preload("res://addons/scene_snap/icons/favorites_icon.svg")
const RED_HEART = preload("res://addons/scene_snap/icons/red_heart.svg")




#const ImportScript = preload("res://addons/scene_snap/scripts/import_script.gd")

#var settings
var theme_accent_color: Color
#var file_dialog : EditorFileDialog
#
#func hello(path: String):
	#if debug: print("Directory selected: ", path)
#TEST FIXME does not detect on start files that changed from last session
func on_files_modified(files: PackedStringArray) -> void:
	if debug: print("files: ", files)
	

#var user_favorites = Favorites.new()
#
#var favs: Array[String] = []






#var gltf_files_task_id: int
#var file_bytes_task_id: int

#var enemies := [0,1,2,3,4,5,6,7,8,9,10]
#
#var count: int = 100000000
#
#func process_ai(enemy):
	#pass
#
#
#func do_work():
	##for enemy in enemies:
		##process_ai(enemy)
	#for index: int in range(0, count):
		#count -= 1
		#if count == 0:
			#if debug: print("FINISH") 


#func delay():
	#OS.delay_msec(1000)
#
#func call_delay():
	#task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, gltf_file_paths.size())
	##var task_id := WorkerThreadPool.add_task(delay)
	##WorkerThreadPool.wait_for_task_completion(task_id)

func print_me() -> void:
	if debug: print("Still loading scenes")
	

var task_id1: int
var task_id2: int
#var ran_task_id2: bool = false
var cleanup_task_id1: bool = false
var cleanup_task_id2: bool = false
#
#func _exit_tree() -> void:
	#gltf.queue_free()
	#gltf_state.queue_free()
	#WorkerThreadPool.wait_for_group_task_completion(task_id)

#func refresh_collection_thumbnail_cache() -> void:
	#

# FIXME Adjust DirAccess.get_files_at(scenes_dir_path) for batched adding to same collection not entire collection each added batch
#func process_collection(collection_file_names: PackedStringArray) -> void:
func process_collection(filter_duplicates: bool = false) -> void:

	var collection_data = collection_queue.pop_back()

	var scenes_dir_path: String = collection_data[1].path_join(collection_data[0])
	var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	var file_names: Array[String]
	file_names.assign(collection_file_names)

	if filter_duplicates:
		var main_tab: Control = main_tab_container.get_current_tab_control()
		if main_tab:
			var scene_buttons: Array[Node]
			match main_tab.name:
				"Project Scenes", "Favorites":
					scene_buttons = main_tab.h_flow_container.get_children()

				_:  # NOTE: Or connect to selected_sub_tab_changed signal tab to replace main_tab.sub_tab_container.get_current_tab()
					if main_tab.sub_tab_container.get_current_tab() > -1:
						var current_sub_tab: Control = main_tab.sub_tab_container.get_child(main_tab.sub_tab_container.get_current_tab())
						if current_sub_tab:
							scene_buttons = current_sub_tab.h_flow_container.get_children()
							scene_buttons = scene_buttons.filter(func(button: Node) -> bool: return button is Button)

			if scene_buttons:
				for scene_button: Button in scene_buttons:
					if file_names.has(scene_button.scene_full_path.split("/")[-1]):
						file_names.erase(scene_button.scene_full_path.split("/")[-1])

	if debug: print("collection_data[0]: ", collection_data[0])
	add_scenes_to_collections(collection_data[0], collection_data[1], collection_data[2], file_names)



#func add_extension() -> void:
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
	#extension = GltfTextureImporter.new()
	##extension.setup(parsed_images_mutex, parsed_images)
	#extension.setup(parsed_images_mutex, image_data_lookup)
	#gltf.register_gltf_document_extension(extension)


var thread: Thread


#var parsed_images: Array = []
var parsed_images_mutex: Mutex = Mutex.new()
#var state_image_data_array: Array[PackedByteArray] = []
var image_data_lookup: Dictionary[int, Array] = {}



var gltf: GLTFDocument = GLTFDocument.new()

var gltf_semaphore := Semaphore.new()
const MAX_CONCURRENT_THREADS := 1

var main_collection_tab_script

# TEST
func test() -> void:
	if debug: print("the filesystem has changed")

#var extension: TextureParsePrePass
func _ready() -> void:

	# Restore sharing disabled setting
	if settings.has_setting("scene_snap_plugin/disable_sharing_functionality_shared_collections_and_shared_tags"):
		sharing_disabled = settings.get_setting("scene_snap_plugin/disable_sharing_functionality_shared_collections_and_shared_tags")
	#else:
		#settings.set_setting("scene_snap_plugin/disable_sharing_functionality_shared_collections_and_shared_tags", sharing_disabled)



	# TODO
	# NOTE: connect to new function that checks if all in folder_project_scenes bool file_exists(path: String and if not remove button and other data like thumbnail
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(test)
	
	
	
	#call_deferred("add_extension")
	gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new()) # NOTE: Will ERROR If inside threaded function 
	#extension = GltfTextureImporter.new()
	##extension.setup(parsed_images_mutex, parsed_images)
	#extension.setup(parsed_images_mutex, image_data_lookup)
	#gltf.register_gltf_document_extension(extension)

	#extension = GltfTextureImporter.new()
	#gltf.register_gltf_document_extension(GltfTextureImporter.new())


	# Pre-acquire the slots so only 24 threads can run concurrently
	for i in MAX_CONCURRENT_THREADS:
		gltf_semaphore.post()



	
	self.process_next_collection.connect(process_collection)
	#self.finished_processing_collection.connect(func(single_threaded_list: Array[String]) -> void: process_single_threaded_list = single_threaded_list)
	# Single thread used for scene loading on scene_view button hover 360 rotation
	thread = Thread.new()

	# NOTE: The UID randomly changed so using uid not stable.
	#scene_data_cache = ResourceLoader.load("uid://3as6dllcbl36")
	scene_data_cache = ResourceLoader.load("res://addons/scene_snap/resources/scene_data_cache.tres")
	# Create access to call update_scene_data_cache_paths() to cleanup empty entries on import_mesh_tags()
	main_collection_tab_script = MainCollectionTab.new() 
	
	#mutex.lock()
	## Clear scene_data_cache before importing tags # FIXME Need better solution. If tags not properly saved to extras will be lost (Think about two people saving to same file at different times second will overwrite first)
	#scene_data_cache.scene_data.clear()
	#ResourceSaver.save(scene_data_cache)
	#mutex.unlock()




	##var start_time = Time.get_ticks_msec()
	#collect_standard_material_3d("res://")
	#collect_gltf_files("user://") 
	## NOTE: Check against scene_data_cache and only process new paths
	#for gltf_scene_full_path: String in scene_data_cache.scene_data.keys():
		#if gltf_file_paths.has(gltf_scene_full_path):
			#gltf_file_paths.erase(gltf_scene_full_path)
	##var end_time = Time.get_ticks_msec()
	##var elapsed_time = end_time - start_time
	##if debug: print("Array restored in ", elapsed_time, " milliseconds")
	##if debug: print("gltf_file_paths.size(): ", gltf_file_paths.size())
	#if gltf_file_paths.size() == 0:
		#ran_task_id2 = false
#
	## FIXME Run task if gltf_file_paths.size() != 0 or thumbnails do not exist for collection
	#if debug: print("gltf_file_paths: ", gltf_file_paths)
	#if ran_task_id2: # Cache is built so will not run even though thumbnails no not exist so need to FIXME
		#await get_tree().process_frame # NOTE: Seems to sometimes crash on start without process_frame
		#if debug: print("running task")
		#task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, gltf_file_paths.size())






	#while not WorkerThreadPool.is_group_task_completed(task_id): 
		#if debug: print("Still loading scenes")
		#await get_tree().create_timer(5).timeout 
	#WorkerThreadPool.wait_for_group_task_completion(task_id)


	
	#var debug_print_setting: String = "scene_snap_plugin/enable_plugin_debug_print_statements"
	## Set the print_enabled flag to match what is in settings
	#if settings.has_setting(debug_print_setting):
		#print_enabled = settings.get_setting(debug_print_setting)


	update_box_select_color()
	settings.settings_changed.connect(update_box_select_color)





	#if debug: print("scene_favorites: ", scene_favorites)
	#var favorites_resource = ResourceLoader.load("res://addons/scene_snap/resources/user_favorites.tres")
	#if favorites_resource:
		#user_favorites = favorites_resource.duplicate(true)
	#if user_favorites.scene_favorites.is_read_only():
		#user_favorites.scene_favorites = user_favorites.scene_favorites.duplicate()
	#user_favorites.scene_favorites.append("test")
	#ResourceSaver.save(user_favorites, "res://addons/scene_snap/resources/user_favorites.tres")

	#user_favorites = ResourceLoader.load("res://addons/scene_snap/resources/user_favorites.tres").duplicate(true)
	#if debug: print("ready user_favorites.scene_favorites: ", user_favorites.scene_favorites)
	#favs = user_favorites.scene_favorites
	#if debug: print("favs: ", favs)

	#user_favorites.scene_favorites.append("walk")
	#ResourceSaver.save(user_favorites, "res://addons/scene_snap/resources/user_favorites.tres")



# CAUTION do not remove saved for later
	#var watcher = DirectoryWatcher.new()
	#add_child(watcher)
	#watcher.add_scan_directory("user://global_collections/scenes/Global Collections/New/")
	#watcher.files_modified.connect(on_files_modified)



	## Create the file dialog instance
	#file_dialog = EditorFileDialog.new()
	#
	#file_dialog.dir_selected.connect(hello)
	#add_child(file_dialog)
	#file_dialog.popup_file_dialog()
	## Initialize the button
	#change_collision_shape_3d_button.set_button_icon(NO_COLLISION)
	#change_collision_shape_3d_button.tooltip_text = "Place Scene With No Collisions"




	# Get all files and subdirectories starting from res://
	collect_files_and_dirs("res://", true)
	get_used_collection_scenes()
	#create_project_scene_buttons()



	#var scene_path: String = "res://test.tscn"
	#for dep in ResourceLoader.get_dependencies(scene_path):
		#if debug: print(dep)

	
	## Print the files found
	#if debug: print("All files found: ", all_files)
	##if debug: print(get_all_files("res://"))

	#if debug: print("scene_viewer_panel_instance.scene_favorites: ", scene_favorites)
	# Initialize Collision_3D_State()
	#toggle_2d_collision_state()
	#toggle_3d_collision_state_down()
	#_on_change_collision_shape_3d_button_pressed()
	
	#toggle_physics_body_type_2d()
	#toggle_physics_body_type_3d()
	###################################################################################KEEP 
	#sync_filter_2d_3d(false)
	###################################################################################KEEP 

	#if debug: print("test: ", test)
	#if debug: print("collision setting: ", scene_snap_settings.currently_selected_collision_state)
	##uid://dugt12tt8o04b
	##uid://dugt12tt8o04b
	##uid://bqthgfoavcj60
	#if debug: print("THIS IS THE RESOURCE UID: ",ResourceLoader.get_resource_uid( "res://collections/kenny_space_station_kit/textures/colormap.png"))
	#if debug: print("THIS IS THE RESOURCE UID 2: ",ResourceUID.text_to_id("uid://dugt12tt8o04b"))
	#if ResourceUID.has_id(ResourceUID.text_to_id("uid://dugt12tt8o04b")):
		#ResourceUID.remove_id(ResourceUID.text_to_id("uid://dugt12tt8o04b"))
		#if debug: print("IT IS ALREADY IN THE uid://dugt12tt8o04b in DICT WHY NOT LOADING")
	#var dep_uid: String = "uid://25e5riqybgvb"
	#if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
		#if debug: print("IT IS ALREADY IN THE DICT WHY NOT LOADING")
	## 8576626692258089695
	##ResourceUID.add_id(ResourceUID.text_to_id(dep_uid), "res://collections/kenny_space_station_kit/textures/colormap.png")
	##if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
		##if debug: print("IT HAS IT WHY NOT WORKING!!")
#
	#ResourceUID.add_id(8576626692258089695, "res://collections/kenny_space_station_kit/textures/colormap.png")
	#if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
		#if debug: print("IT HAS IT WHY NOT WORKING!!")



	#await get_tree().create_timer(5).timeout
	#var sub_folders_path: String = ""
	#match new_main_collection_tab.name:
		#"Global Collections":
			#sub_folders_path = scenes_paths[0].path_join("Global Collections/")
		#"Shared Collections":
			#sub_folders_path = scenes_paths[1].path_join("Shared Collections/")
	#
	#
	#
	#
	#
	#for scene_file: String in DirAccess.get_files_at("res://collections"):
		#if debug: print("scene_file: ", scene_file)
		#for dep in ResourceLoader.get_dependencies("res://scenes".path_join(scene_file)):
			#if debug: print(dep)
			#if debug: print(dep.get_slice("::", 0)) # Prints UID.
			#if debug: print(dep.get_slice("::", 2)) # Prints path.
			#var dep_path: String = dep.get_slice("::", 2)
			#var dep_uid: String = dep.get_slice("::", 0)
			#var dep_file_name: PackedStringArray = full_path_split(dep_path, true)
			#if debug: print("dep_file_name: ", dep_file_name)
			#if debug: print("texture_file_names: ", texture_file_names)
			#if texture_file_names.has(dep_file_name[0]):
				#if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
					#ResourceUID.set_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
					#if debug: print("ResourceUID has id: ", dep.get_slice("::", 0))
				#else:
					#ResourceUID.add_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
					#if debug: print("ResourceUID does not have id: ", dep.get_slice("::", 0))
	
	
	# Connect to editor filesystem changed signal to update scene view buttons within Project Scenes
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(file_added_or_removed)
	
	#EditorInterface.get_file_system_dock().file_removed.connect(file_removed)
	
	#if debug: print("This should be the second")
	#settings = EditorInterface.get_editor_settings()
	#var new_import = ImportScript.new()
	##if debug: print("ImportScript: ", new_import.get_source_file())
	#new_import.finished_scene_import.connect(print_me)

	body_3d_warning.set_texture(get_theme_icon("NodeWarning", "EditorIcons"))
	collision_3d_warning.set_texture(get_theme_icon("NodeWarning", "EditorIcons"))
	collision_visibility_toggle_button.set_texture_normal(get_theme_icon("GuiVisibilityVisible", "EditorIcons"))
	

	collision_visibility_toggle_button.set_tooltip_text("ACTIVE: Show collisions with scene preview. \
	\n\u2022 NOTE: Generation of the scene preview will be slower when active, especially for Multiple Convex collisions generation. \
	\n\u2022 NOTE: CollisionShape3D must also be set to visible under 3DViewport top toolbar View -> Gizmos -> CollisionShape3D.")

	#enable_pinning_toggle_button.set_button_icon(get_theme_icon("PinPressed", "EditorIcons"))
	# Initialize buttons TODO adjust default var values to match desired default ui
	_on_scene_creation_toggle_button_pressed()
	_on_change_body_type_3d_button_pressed()
	_on_change_collision_shape_3d_button_pressed()
	_on_enable_pinning_toggle_button_toggled(true)
	_on_unique_sub_resources_toggle_button_toggled(false)
	#_on_default_material_button_toggled(false)
	#enable_pinning_toggle_button.set_texture_normal(get_theme_icon("PinPressed", "EditorIcons"))
	unique_sub_resources_toggle_button.set_texture_normal(get_theme_icon("Duplicate", "EditorIcons"))


# TEST
	scene_creation_toggle_button_2.set_button_icon(get_theme_icon("InstanceOptions", "EditorIcons"))
	enable_pinning_toggle_button2.set_texture_normal(get_theme_icon("PinPressed", "EditorIcons"))
	unique_sub_resources_toggle_button2.set_texture_normal(get_theme_icon("Duplicate", "EditorIcons"))


	#favorite_material_button.set_texture_normal(get_theme_icon("NonFavorite", "EditorIcons"))
	#favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))

	#pin_panel.set_texture_normal(get_theme_icon("PinPressed", "EditorIcons"))
	
	scene_creation_toggle_button.set_button_icon(get_theme_icon("InstanceOptions", "EditorIcons"))
	make_floating.texture_normal = get_theme_icon("MakeFloating", "EditorIcons")
	split_panel.texture_normal = get_theme_icon("Panels2Alt", "EditorIcons")
	self.connect("scene_file_name", _on_scene_file_name)
	#configure_project_folder_structure()
	#create_folders("res://", "local_scenes")
	#create_folders("res://", "scenes")
	#create_folders("res://", "textures")
	create_folders("res://", "collections")
	
	## Prevent loading until restore of data from scene_snap_plugin.gd _set_window_layout
	#var start_time = Time.get_ticks_msec()
	#while not continue_load:
		#await get_tree().process_frame
	#var end_time = Time.get_ticks_msec()
	#var elapsed_time = end_time - start_time
	#if debug: print("Array restored in ", elapsed_time, " milliseconds")
	
	
	create_main_collection_tabs(true)
	create_main_collection_tabs(false)

	# Set icons for the Main Tabs
	for main_tab: Control in main_tab_container.get_children():
		var index: int = main_tab.get_index()
		match main_tab.name:
			"Project Scenes":
				main_tab_container.set_tab_button_icon(index, PROJECT_ICON)
				main_tab_container.set_tab_tooltip(index, "Scenes contained within this project.")
			"Global Collections":
				main_tab_container.set_tab_button_icon(index, GLOBAL_ICON)
				main_tab_container.set_tab_tooltip(index, "Collections available between personal projects on this device.")
			"Shared Collections":
				main_tab_container.set_tab_button_icon(index, SHARED_ICON)
				main_tab_container.set_tab_tooltip(index, "Collections shared within a local network or cloud storage. NOTE: network configuration required.")

	## Restore button animation icons
	#if settings.has_setting("scene_snap_plugin/scenes_with_animations"):
		#scene_has_animation = settings.get_setting("scene_snap_plugin/scenes_with_animations")


	#settings.erase("scene_snap_plugin/scenes_with_animations")

	## Restore collection cleanup setting
	#if settings.has_setting("scene_snap_plugin/remove_unused_collections_on_exit"):
		#remove_unused_collections = settings.get_setting("scene_snap_plugin/remove_unused_collections_on_exit")
	#else:
		#settings.set_setting("scene_snap_plugin/remove_unused_collections_on_exit", remove_unused_collections)



	# Restore collection cleanup setting
	if settings.has_setting("scene_snap_plugin/remove_unused_project_collection_scenes_on_start"):
		remove_unused_collections = settings.get_setting("scene_snap_plugin/remove_unused_project_collection_scenes_on_start")
	else:
		settings.set_setting("scene_snap_plugin/remove_unused_project_collection_scenes_on_start", remove_unused_collections)




 



# NOTE: DISABLING FOR IMPORT MULTI-THREADING MAY BREAK SOMETHING ELSE I HAVE TO CHECK
	# Wait for file system scan to finish
	var wait_count: int = 0
	while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
		await get_tree().create_timer(1).timeout
		wait_count += 1
		if debug: print("filesystem scanning wait_count: ", wait_count)
		if wait_count > 5:
			break
	for file_path: String in unused_collection_scenes_path:
		remove_file_from_collections(file_path)






# TODO Check if can be improved but working. will update even when not on tab and may do additional scans at startup
# FIXME removing rather then queue freeing them all and only removing the scene that was deleted
func file_added_or_removed() -> void:
	pass
	#if new_main_project_scenes_tab.filter_by_file_system_folder:
		#refresh_project_scenes(EditorInterface.get_current_directory())
	#else:
		#one_time_scan = true
		#refresh_project_scenes("res://")


#func file_removed(file: String) -> void:
	#all_project_files.erase(file)
	#if debug: print("all_project_files: ", all_project_files)
	#if debug: print("THIS IS THE FILE THAT WAS REMOVED: ", file)






# NOTE FIXME May need to change to for importing .glb to this directory for embeded .glb
func get_used_collection_scenes() -> void:
	var collection_scene_paths: Array[String] = []
	var used_collection_scenes_path: Array[String] = []

	# get all .tscn files in res:// dir and add scenes within "res://collections/" to collection_scene_paths
	for file_path: String in all_project_files:
		if file_path.ends_with(".tscn") or file_path.ends_with(".scn"):
			if file_path.begins_with(project_scenes_path):
				collection_scene_paths.append(file_path)

			# Get file_path to all scenes that are dependencies of other scenes in project
			for dep in ResourceLoader.get_dependencies(file_path):
				if dep.ends_with(".tscn") or dep.ends_with(".scn"):

					# Split dep to get just the file_path
					var dep_path: String = dep.get_slice("::", 2)
					used_collection_scenes_path.append(dep_path)

	# Create Array of scenes that are not used
	for file_path: String in collection_scene_paths:
		if not used_collection_scenes_path.has(file_path):
			unused_collection_scenes_path.append(file_path)


## Remove previously created scenes by scene_viewer instancing that are not used in any scenes
## but that are still in the collection folder taking up space. 
func remove_file_from_collections(file_path: String) -> void:
	if DirAccess.dir_exists_absolute(project_scenes_path):
		# Remove scenes that are not dependencies of other scenes in project
		if remove_unused_collections:
			var error = DirAccess.remove_absolute(file_path)
			if error != OK:
				if debug: print("Failed to remove scene at : ", file_path)

		# Scan the filesystem to update
		var editor_filesystem = EditorInterface.get_resource_filesystem()
		if editor_filesystem.is_scanning():
			return
		else:
			editor_filesystem.scan()




## FIXME initial scan and whole system scan can be removed use only for individual folder scanning
## Get all files and subdirectories recursively within res:// to create scene_view buttons
func collect_files_and_dirs(dir: String, intial_scan: bool) -> void:
	if dir.to_lower().contains("addon"): # Skip addon and addons folder
		return
	# Collect files in the current directory
	var files: PackedStringArray = res_dir.get_files_at(dir)
	for file in files:
		
		if accepted_file_ext.has(file.get_extension()):

			#folder_project_scenes.append(dir.path_join(file))
			### Only add if does not already exist in array
			##if not all_project_files.has(dir.path_join(file)):
			if intial_scan:
				all_project_files.append(dir.path_join(file))
			else:
				folder_project_scenes.append(dir.path_join(file))

	# Collect subdirectories and recurse into them
	var dirs: PackedStringArray = res_dir.get_directories_at(dir)
	for subdir in dirs:
		if not subdir.begins_with(".") and not subdir.contains("addons"):  # Ignore hidden directories and addons directory
			var subdir_path = dir.path_join(subdir)
			all_project_folders.append(subdir_path)  # Add subdirectory to the list
			collect_files_and_dirs(subdir_path, intial_scan)  # Recurse into the subdirectory



func create_project_scene_buttons() -> void:
	var wait_count: int = 0
	while not saved_data_restored: # Wait here until saved_data_restored set to true from scene_snap_plugin script
		if get_tree() != null:
			await get_tree().physics_frame
			wait_count += 1
			if wait_count > 1000:
				break
		else:
			return
	for scene_full_path: String in all_project_files:
	#for scene_full_path: String in all_project_files:
		#var loaded_scene: PackedScene = load(scene_full_path)
		#loaded_scene = load(scene_full_path)
		var new_scene_view: Button = null
		create_scene_buttons(scene_full_path, new_main_project_scenes_tab, new_scene_view, false)


## TODO Check if can replace full_path_split with this functionality since didn't know you could do it this way
#func get_project_file_names() -> Array[String]:
	#var project_file_names: Array[String] = []
#
	#for file: String in all_project_files:
		##if debug: print("file: ", file.get_file())
		#var file_name: String = file.get_file()
		#file_name = file_name.substr(0, file_name.length() - (file_name.get_extension().length() + 1)) # + 1 for the "."
		#project_file_names.append(file_name)
#
	#return project_file_names



########################################################KEEP
# TODO Check if can replace full_path_split with this functionality since didn't know you could do it this way
func get_project_file_names() -> Array[String]:
	var project_file_names: Array[String] = []

	for file: String in folder_project_scenes:
		#if debug: print("file: ", file.get_file())
		var file_name: String = file.get_file()
		file_name = file_name.substr(0, file_name.length() - (file_name.get_extension().length() + 1)) # + 1 for the "."
		project_file_names.append(file_name)

	return project_file_names
########################################################KEEP


var intialize_buttons: bool = true
### TODO Check if folder_project_scenes can just be all_project_files and overwrite and clear that? 
#func refresh_project_scenes(dir: String) -> void:
	#if EditorInterface.get_current_directory() != current_selected_directory or one_time_scan: # Allow scan when button toggled but still same folder is selected
		#one_time_scan = false
		#current_selected_directory = EditorInterface.get_current_directory()
		#if debug: print("current_selected_directory: ", current_selected_directory)
		#
#
		#if debug: print("clearing folder_project_scenes")
		## Clear last folder dir and files before running collect_files_and_dirs(dir)
		#folder_project_scenes.clear()
#
#
		## Get all scenes from the selected directory
		#collect_files_and_dirs(dir, false)
#
#
		## Show or hide buttons under Project Scenes Tab if match selected folder file names
		#var scene_buttons: Array[Node] = new_main_project_scenes_tab.h_flow_container.get_children()
		##if debug: print("scene_buttons: ", scene_buttons)
#
		##var current_buttons: Array[Node] = new_main_project_scenes_tab.find_child("HFlowContainer").get_children()
		#var project_file_names: Array[String] = get_project_file_names()
		#if debug: print("project_file_names: ", project_file_names)
#
		## Clear out any existing scene buttons before adding in
		#new_main_project_scenes_tab.filtered_scene_buttons.clear()
		#
		##TEST
		#var folder_buttons: Array[Node] = []
		##TEST
		#
		#for button in scene_buttons:
		##for button: Node in current_buttons:
			#
			#if button and button is Button and project_file_names.has(button.name):
				## Add to filtered scenes
				##new_main_project_scenes_tab.filtered_scene_buttons.append(button)
				#new_main_project_scenes_tab.filtered_scene_buttons.append(button)
				## TEST
				#folder_buttons.append(button)
				##TEST
				#if not folder_filtered_scene_buttons.has(button):
					#folder_filtered_scene_buttons.append(button)
				#button.show()
			#else:
				#button.hide()
		#
		#if new_main_project_scenes_tab.filtered_scene_buttons == []:
			#pass
			##push_warning("This filesystem folder does not appear to have any scenes. Please select a folder that has scenes in it.")
		## Re-apply filters
		##new_main_project_scenes_tab.apply_filters()
		##new_main_project_scenes_tab.filter_buttons()
#
		## TEST
		##new_main_project_scenes_tab.filterss["folder"] = folder_buttons
		#new_main_project_scenes_tab.filters_dict["folder"] = folder_buttons
		#
		##TEST
		#new_main_project_scenes_tab.filter_buttons()





# Store folder filtered scene buttons to later erase them from the filtered_scene_buttons without clearing all filtered objects
var folder_filtered_scene_buttons: Array[Node] = []




# ORIGNAL
		## Clear scene_view_instances array
		#scene_view_instances.clear()
		#
		## Clear last folder dir and files before running collect_files_and_dirs(dir)
		#all_project_files.clear()
#
		##if new_main_project_scenes_tab.filter_by_file_system_folder:
			### Clear last folder dir and files before running collect_files_and_dirs(dir)
			##all_project_files.clear()
#
		## Get all scenes from the selected directory
		#collect_files_and_dirs(dir)
#
#
		## Clear all current buttons under Project Scenes Tab
		#var current_buttons: Array[Node] = new_main_project_scenes_tab.find_child("HFlowContainer").get_children()
		##if debug: print("current_buttons: ", current_buttons)
		#var project_file_names: Array[String] = get_project_file_names()
		#for button: Node in current_buttons:
			#if project_file_names.has(button.name):
				#button.show()
			#else:
				#button.hide()
#
#
			##button.queue_free()
#
#
		## Create new buttons under Project Scenes Tab
		#create_project_scene_buttons()
# ORIGNAL


#var first_run_file_scan: bool = true
#func _process(delta: float) -> void:
	#var dir: String = "user://"
	#var gltf_files_task_id = WorkerThreadPool.add_task(collect_gltf_files.bind(dir))
	#if WorkerThreadPool.wait_for_task_completion(gltf_files_task_id) == OK:
		#file_bytes_task_id = WorkerThreadPool.add_group_task(load_scene_data.bind(gltf_files.pop_back()), gltf_files.size())


#func _process(delta: float) -> void:
	## Run on the main thread: safe to create nodes/resources
	#mutex.lock()
	#for path in states.keys():
		#var state = states[path]
		#var scene = gltf.generate_scene(state)
		#scene_lookup[path] = scene
	#states.clear()
	#mutex.unlock()


func _physics_process(delta: float) -> void:

	#await get_tree().create_timer(5).timeout
	#if new_main_project_scenes_tab and new_main_project_scenes_tab.filters.has("folder"):
		#refresh_project_scenes(EditorInterface.get_current_directory())
	#if debug: print("current_scene_path: ", current_scene_path)
	
	#if debug: print("new_main_collection_tab: ", new_main_collection_tab)
	#await get_tree().create_timer(5).timeout
	#var sub_tab_bar: TabBar = new_main_collection_tab.sub_tab_container.get_tab_bar()
	#var sub_tab_count: int = new_main_collection_tab.sub_tab_container.get_tab_count()
	#if debug: print("sub_tab_count: ", sub_tab_count)
	#sub_tab_bar.move_tab(sub_tab_count - 1, 0)
	#if debug: print("collection_queue: ", collection_queue)
	#if debug: print(selected_buttons_duplicate)
	#if debug: print(selected_buttons)
	#if debug: print("current_material_index: ", current_material_index)
	
	#if debug: print("processing_collection: ", processing_collection)
	#if debug: print("process_single_threaded_list: ", process_single_threaded_list)
	#if EditorInterface.get_resource_filesystem().is_scanning():
		#if debug: print("scanning filesystem")
	#pass


	#pass
	#if debug: print("scene_instance: ", scene_instance)
	#if debug: print("scene_view_buttons_with_tags_added: ", scene_view_buttons_with_tags_added_or_removed)
	#if debug: print("scenes_with_multiple_meshes: ", scenes_with_multiple_meshes)
	#if debug: print("selected_buttons: ", selected_buttons)
	#if debug: print("favorites: ", favorites)
	#if debug: print("clear_selected_enabled: ", clear_selected_enabled)

	#if debug: print("selected_buttons: ", selected_buttons)
	#if saved_data_restored:
		#saved_data_restored = false
		#restore_saved_data()


	#if debug: print("EditorInterface.get_current_directory(): ", EditorInterface.get_current_directory())
	#if debug: print("new_main_project_scenes_tab: ", new_main_project_scenes_tab)
	#if debug: print("new_main_project_scenes_tab.filters.has folder: ", new_main_project_scenes_tab.filters.has("folder"))
	## NOTE: Need to delay on start with multi-threading enabled 
	if new_main_project_scenes_tab and new_main_project_scenes_tab.filters.has("folder"):
		new_main_project_scenes_tab.get_scene_buttons()
		#refresh_project_scenes(EditorInterface.get_current_directory())



#get_tree().current_scene.scene_file_path
	#for dep in ResourceLoader.get_dependencies(EditorInterface.get_edited_scene_root().get_scene_file_path()):
		#if debug: print(dep)



func create_folders(dir: String, folder_path: String) -> void:
	var filesystem: = DirAccess.open(dir)
	if not filesystem.dir_exists_absolute(dir + folder_path):
		filesystem.make_dir_recursive_absolute(dir + folder_path)
	# Scan the filesystem to update
	var editor_filesystem = EditorInterface.get_resource_filesystem()
	if editor_filesystem.is_scanning():
		return
	else:
		editor_filesystem.scan()





## Control zoom with mouse scroll wheel
func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		clear_selected_buttons()
		
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_A):
		select_all_visible_buttons()
	
	
	## FIXME WORKS ALSO WHEN NOT OVER THE PANEL ALSO CANNOT SCALE SCRIPT TEXT SIZE AS A RESULT
	if event is InputEventMouseButton:
		## Remove selected items on mouse click unless CTL or SHIFT keys held down 
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			#if Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_SHIFT):
				#pass
			#elif clear_selected_enabled:
				#clear_selected_buttons()
			
		
		if enable_panel_button_sizing and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_CTRL):
			#get_tree().get_root().set_input_as_handled()
			zoom_v_slider.value -= 10
		if enable_panel_button_sizing and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_CTRL):
			#get_tree().get_root().set_input_as_handled()
			zoom_v_slider.value += 10

		# Quick favorite
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and Input.is_key_pressed(KEY_SHIFT):
			
			add_scene_button_to_favorites(current_scene_path, true)
			
			#quick_add_or_remove_from_favorites()

		# TODO ADD QUICK REMOVE FROM FAV
		


		## Quick scroll for collision shapes
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_C):
			#get_tree().get_root().set_input_as_handled()
			#toggle_3d_collision_state_down()
#
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_C):
			#get_tree().get_root().set_input_as_handled()
			#toggle_3d_collision_state_up()
#
		## Quick scroll for body types
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_B):
			#get_tree().get_root().set_input_as_handled()
			#toggle_physics_body_type_down()
#
#
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_B):
			#get_tree().get_root().set_input_as_handled()
			#toggle_physics_body_type_up()





func wait_ready(object) -> bool:
	var wait_time: int = 0
	while not object:
		if debug: print("waiting for ", object, " to be ready")
		await get_tree().process_frame
		wait_time += 1

		if wait_time >= 120:
			push_error(object, ": Failed to load")
			return false

	return true





## Restore values saved when editor closed favorites - thumbnail zoom - etc.
#func restore_saved_data() -> void:
	#pass
	##while not saved_data_restored:
		##await get_tree().process_frame
#
	## TODO FIXME ADD SIGNAL FROM SCENE SNAP PLUGIN WHEN FINISHED LOADING SAVED DATA TO RUN CODE BELOW
	##await get_tree().create_timer(0.3).timeout
	##await get_tree().create_timer(5).timeout
	##await Signal(self, "tab_scene_buttons_created")
	##await wait_ready(scene_favorites)
	### Create duplicate and clear scene_favorites array to not cause recursion
	#if restore_data:
		#restore_data = false
		##var start_time = Time.get_ticks_msec()
		###await get_tree().create_timer(5).timeout
		##while scene_favorites.is_empty():
			##await get_tree().process_frame
			##
			##
	### End timing
		##var end_time = Time.get_ticks_msec()
		##var elapsed_time = end_time - start_time
##
### Output the elapsed time
		##if debug: print("Array restored in ", elapsed_time, " milliseconds")
#
#
		##if debug: print("scene_favorites: ", scene_favorites)
		##last_session_favorites = scene_favorites.duplicate()
		###if debug: print("scene_favorites: ", scene_favorites)
		##if debug: print("last_session_favorites: ", last_session_favorites)
		##scene_favorites.clear()
#
		## Reference to Favorites Tab
		##await wait_ready(main_tab_container.find_child("Favorites"))
		## FIXME NOTE NOT SURE THE BEST WAY TO CLEAN THIS UP BUT IT IS MESSED UP
		#var favorites_tab = main_tab_container.find_child("Favorites")
		#if favorites_tab:
			#favorites = favorites_tab
			#apply_favorites_tab_icon(favorites)
			#
			#main_collection_tabs.append(favorites)
			####################################################################################KEEP 
			##favorites_tab.change_current_filter_2d_3d.connect(sync_filter_2d_3d)
			#favorites_tab.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)
			#
		#else:
			##if debug: print("last_session_favorites: ", last_session_favorites)
			##if last_session_favorites != []:
			#if scene_favorites != []:
				#favorites = MAIN_FAVORITES_TAB.instantiate()
				##apply_favorites_tab_icon(favorites)
				#main_collection_tabs.append(favorites)
				####################################################################################KEEP 
				##favorites.change_current_filter_2d_3d.connect(sync_filter_2d_3d)
				#favorites.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)
				##favorites_tab.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)

func apply_favorites_tab_icon(favorites_tab: Control) -> void:
	var main_tab_container: TabContainer = favorites_tab.get_parent()
	var index: int = favorites_tab.get_index()
	main_tab_container.set_tab_button_icon(index, FAVORITES_ICON)
	# TODO Implement sharing favorites between projects
	main_tab_container.set_tab_tooltip(index, "Favorite scenes. NOTE: Favorites are not shared between projects.")

#func quick_add_or_remove_from_favorites() -> void:
	#self.add_scene_button_to_favorites(current_scene_path, true)



func add_scene_button_to_favorites(scene_full_path: String, quick_add_favorite: bool ) -> void:

	#if not main_tab_container.has_child(new_favorites_tab):
	#var main_tab_container: TabContainer = new_favorites_tab.get_parent()
	#if not main_tab_container.find_child("Favorites"):
		#new_favorites_tab.set_owner(null)
		#main_tab_container.add_child(new_favorites_tab)

	#main_tab_container.remove_child(new_favorites_tab)
	##new_favorites_tab.hide()
	## Now re-add the tab
	#main_tab_container.add_child(new_favorites_tab)


		##new_favorites_tab.set_owner(null)
	#if debug: print("main_tab_container children: ", main_tab_container.get_children())
	#if not main_tab_container.get_children()("Favorites"):
		#pass
	#for main_tab: Control in main_tab_container.get_children():
		#if main_tab.name == "Favorites":
			
		#new_favorites_tab.reparent(main_tab_container)
	#main_tab_container.add_child(new_favorites_tab)

	selected_buttons_favorite_toggle(scene_full_path, true)



	if quick_add_favorite:
		modify_heart_from_matching_favorite(scene_full_path, true, true)
	
	## Add the Favorites Tab if it doesn't already exist
	#if scene_favorites.is_empty() and not main_tab_container.find_child("Favorites"):
		## Check if instance of Favotites TAb and if not instantiate
		#if favorites != null:
			#main_tab_container.add_child(favorites)
		#else:
			#favorites = MAIN_FAVORITES_TAB.instantiate()
			#main_tab_container.add_child(favorites)
		#favorites.owner = main_tab_container
		#apply_favorites_tab_icon(favorites)
		## Edit settings so that on startup know to show favorites tab or not
		## FIXME Will make open the default even when no favorites exists MOVE ME
		#settings.set_setting("scene_snap_plugin/show_favorites_tab_on_startup", true)
		#if open_favorites_tab: # This will open and change focus to the Favorites tab one time when first used only
			#favorites.show()
			#open_favorites_tab = false

	# Add scene to scene_favorites FIXME "" being added when reloading assume because there is now extra version created in favorites
	if scene_full_path != "":
		if not scene_favorites.has(scene_full_path):
			scene_favorites.append(scene_full_path) # This is why we need to make a duplicate of scene_favorites because we are adding to it as we are reading from it

		var existing_full_path_buttons: Array[String] = []
		# Either clear children or check if exists
		for button: Node in new_favorites_tab.h_flow_container.get_children():
			if button and button is Button and not existing_full_path_buttons.has(button.scene_full_path):
				existing_full_path_buttons.append(button.scene_full_path)
		
		if not existing_full_path_buttons.has(scene_full_path):
			var new_scene_view: Button = null
			create_scene_buttons(scene_full_path, new_favorites_tab, new_scene_view, false)



# scene_full_path: user://global_collections/scenes/Global Collections/New Collection/user://global_collections/scenes/Global Collections/New Collection/textures

#func add_scene_button_to_scene_has_animation(scene_full_path: String) -> void:
	#scene_has_animation.append(scene_full_path)




# TODO FIXME Replace with file_name_no_ext() NOTE but file_name_no_ext() does not give base path need later by .gltf import
#oh but that is only one line so maybe can replace with file_name_no_ext()
func full_path_split(scene_full_path: String, get_scene_name: bool) -> PackedStringArray:
	#if debug: print("scene_full_path: ", scene_full_path)
	var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 0)

	if get_scene_name:
		#var last_element: int = my_array[my_array.size() - 1]
		#if debug: print("scene_full_path_split: ", scene_full_path_split)
		var index: int = scene_full_path_split.size() - 1
		var file_name: String = scene_full_path_split[index]
		var scene_name_split: PackedStringArray = file_name.split("--", false, 0)

		# Get just the base name without extension
		if scene_name_split[0].ends_with(".tscn"):
			#scene_name_split[0] = scene_name_split[0].rstrip(".tscn")
			scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - 5) # The length of .tscn = 5

		# Get just the base name without extension
		if scene_name_split[0].ends_with(".obj") or scene_name_split[0].ends_with(".scn"):
			#scene_name_split[0] = scene_name_split[0].rstrip(".tscn")
			scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - 4) # The length of .obj = 4


		return scene_name_split
	else:
		#if debug: print("scene_full_path_split: ", scene_full_path_split)
		return scene_full_path_split


### Add or Remove selected buttons from favorites
#func selected_buttons_favorite_toggle(scene_full_path: String, toggled_on: bool) -> void:
	#var selected_buttons_names: Array[String] = []
	## Remove group selected to favorites when one selected is added
	## Check the favorited buttons name against the selected ones to make sure it is within the group
	#if selected_buttons:
		#if debug: print("selected_buttons: ", selected_buttons)
		## Add selected buttons names to array to run check
		##for button: Button in selected_buttons:
		#for button in selected_buttons:
			#if button and button is Button:
				#selected_buttons_names.append(button.name)
		## Do check of favorited buttons name to name of all selected buttons names
		##for button: Button in selected_buttons: # FIXME FIXME FIXME FIXME FIXME FIXME  NOT ALL SELECTED OBJECTS ARE BEING HANDLED SO TRYING WORK AROUND
		## if button and button is Button: BUT NOT A SOLUTION SINCE DOESNT FIX THE PROBLEM JUST HIDES IT
		#for button in selected_buttons:
			#if button and button is Button:
				#if selected_buttons_names.has(get_scene_name(scene_full_path, true)):
					#if not button.heart_texture_button.button_pressed == toggled_on and not scene_favorites.has(scene_full_path):
						#scene_favorites.append(scene_full_path)
						##button._on_heart_texture_button_toggled(toggled_on)
						#button.heart_texture_button.button_pressed = toggled_on


# TEST
var selected_buttons_duplicate: Array[Node]

# Refresh view of current button 
## Add or Remove selected buttons from favorites
func selected_buttons_favorite_toggle(scene_full_path: String, toggled_on: bool) -> void:
	#var selected_buttons_names: Array[String] = []
	# Remove group selected to favorites when one selected is added
	# Check the favorited buttons name against the selected ones to make sure it is within the group
	var selected_buttons_scene_full_path: Array[String] = []
	
	
	if selected_buttons:
		if debug: print("selected_buttons: ", selected_buttons)
		# Add selected buttons names to array to run check
		#for button: Button in selected_buttons:
		for button in selected_buttons:
			if button and button is Button:
				selected_buttons_scene_full_path.append(button.scene_full_path)
				#selected_buttons_names.append(button.name)
		# Do check of favorited buttons name to name of all selected buttons names
		#for button: Button in selected_buttons: # FIXME FIXME FIXME FIXME FIXME FIXME ***SOLUTION FIXED BELOW!!*** NOT ALL SELECTED OBJECTS ARE BEING HANDLED SO TRYING WORK AROUND
		# if button and button is Button: BUT NOT A SOLUTION SINCE DOESNT FIX THE PROBLEM JUST HIDES IT
		if selected_buttons_scene_full_path.has(scene_full_path): # Check if button pressed is part of the selected buttons group
			#var selected_buttons_duplicate: Array[Node] = selected_buttons.duplicate()
			selected_buttons_duplicate = selected_buttons.duplicate()
			for button in selected_buttons_duplicate:
				if toggled_on: # ON (True)
					if not button.heart_texture_button.button_pressed == toggled_on and not scene_favorites.has(scene_full_path):
							scene_favorites.append(scene_full_path)
							button.heart_texture_button.button_pressed = toggled_on
				else:
					# SEEMS TO ALL WORK NOW?
					# FIXME This removes button from selected buttons when favorite button toggled on and off
					# FIXME This is suppose to remove button from selected buttons when heart button toggled off
					# So it is doing what it is supposed to do, but that causes issues
					#if not button.visible:
						#selected_buttons_duplicate.erase(button)
					#selected_buttons.erase(button)
					#selected_buttons_duplicate.erase(button)
					scene_favorites.erase(scene_full_path)
					button.heart_texture_button.button_pressed = toggled_on # OFF

			#selected_buttons = selected_buttons_duplicate

					# if in favorites tab queue free

		
		#
		#for button in selected_buttons:
			#if button and button is Button:
				#
				#
				#
				#
				#if selected_buttons_names.has(get_scene_name(scene_full_path, true)):
					#if not button.heart_texture_button.button_pressed == toggled_on and not scene_favorites.has(scene_full_path):
						#scene_favorites.append(scene_full_path)
						##button._on_heart_texture_button_toggled(toggled_on)
						#button.heart_texture_button.button_pressed = toggled_on







func remove_scene_button_from_favorites(scene_full_path: String, scene_view_button: Button) -> void:
	selected_buttons_favorite_toggle(scene_full_path, false)

	# Remove the scene from favorites
	for button: Node in new_favorites_tab.h_flow_container.get_children():
		if button and button is Button and button.scene_full_path == scene_full_path: # NOTE is Button check because MultiSelectBox is child too.
			scene_favorites.erase(scene_full_path)
			# Used by slider to set size of all existing scene_view_instances
			scene_view_instances.erase(button)
			button.queue_free()

	if scene_full_path != "" and scene_favorites.has(scene_full_path):
		scene_favorites.erase(scene_full_path)


	modify_heart_from_matching_favorite(scene_full_path, false, false)

	# Remove Favorites Tab if empty FIXME DOES NOT WORK NOTE commented out main_tab_container.remove_child(new_favorites_tab)
	if scene_favorites.is_empty():
		#var favorites_tab = main_tab_container.find_child("Favorites")
		#if favorites_tab:
		if new_favorites_tab:
			#main_tab_container.remove_child(new_favorites_tab)
			# Edit settings so that on startup know to show favorites tab or not
			settings.set_setting("scene_snap_plugin/show_favorites_tab_on_startup", false)
			#favorites_tab.hide()
			#main_tab_container.remove_child(new_favorites_tab)

	# Re-apply filters to clear removed button from Project Scenes view
	#new_main_project_scenes_tab.apply_filters()
	new_main_project_scenes_tab.filter_buttons()



# TODO find all full_path_split(scene_full_path, true) and replace with below func

#func file_name_no_ext(scene_full_path: String) -> String:
	#var file_name: String = scene_full_path.get_file()
	#file_name = file_name.substr(0, file_name.length() - (file_name.get_extension().length() + 1)) # Remove extension + 1 for the "."
	#return file_name


func get_scene_name(scene_full_path: String, no_extension: bool) -> String:
	var scene_name: String = scene_full_path.get_file()
	if no_extension:
		scene_name = scene_name.substr(0, scene_name.length() - (scene_name.get_extension().length() + 1)) # Remove extension + 1 for the "."

	return scene_name


# FIXME BREAKS IF REMOVING COLLECTION AFTER CREATING FAVORITES ERROR: Cannot call method 'find_child' on a null value.
# FIXME TODO NEED BETTER SOLUTION MAYBE DICTIONARY LOOKUP AND RELINK WHEN COLLECTION REMOVED AND ADDED BACK IN? NEED TO KEEP FAVORITE SCENE IN collection_lookup[collection_name] WHEN COLLECTION REMOVED OR MOVED TO NEW LOOKUP?
## Change the state of the heart on the button that matches the one being changed
func modify_heart_from_matching_favorite(scene_full_path: String, light_up_heart: bool, flip_state: bool) -> void:
	var split: PackedStringArray = full_path_split(scene_full_path, false)
	var scene_button: Node

	match split[1]:

		"global_collections": # FIXME VERY FRAGILE, BREAKS IF COLLECTION NOT OPEN WHEN REMOVING MATCHING FAVORITE SCENE if favorite_lookup.keys().has(scene_view.scene_full_path) but this method will require going through all the buttons
			# But so does the below method which is actually probably much worse for performance and speed.
			# EXAMPLE ["user:", "global_collections", "scenes", "Global Collections", "New Collection", "SM_SFloorWindow300x450.tscn"] -> Global Collections/New Collection/SM_SFloorWindow300x450
			if main_tab_container.find_child("Global Collections", false, true).find_child(split[4], true, false).find_child(get_scene_name(scene_full_path, true), true, false):
				scene_button = main_tab_container.find_child("Global Collections", false, true).find_child(split[4], true, false).find_child(get_scene_name(scene_full_path, true), true, false)

		"shared_collections":
			# Do check if collection still open FIXME will not work for moved or removed nodes from tab
			if debug: print("scene_full_path: ", scene_full_path) 
			# for sub_tab: Tab in share_collections.get_children 
				# if split[4] == sub_tab:
					# for button in sub_tab.get_children
						# if file_name_no_ext(scene_full_path) == button:
							#scene_button = button
						# else:
					
				#else:
					#push_warning("the collection was closed, fav not fully removed")
					
			# EXAMPLE ["user:", "shared_collections", "scenes", "Shared Collections", "New Collection", "SM_SFloorMiddle150x450.tscn"] -> Shared Collections/New Collection/SM_SFloorWindow300x450
			# FIXME Favorite close collection then clear from fav tab res://addons/scene_snap/scripts/scene_viewer.gd:962 - Cannot call method 'find_child' on a null value.
			#if main_tab_container.find_child("Shared Collections", false, true).find_child(split[4], true, false).find_child(file_name_no_ext(scene_full_path), true, false) is Node:
			if main_tab_container.find_child("Shared Collections", false, true).find_child(split[4], true, false) != null:
				if main_tab_container.find_child("Shared Collections", false, true).find_child(split[4], true, false).find_child(get_scene_name(scene_full_path, true), true, false) != null:
					scene_button = main_tab_container.find_child("Shared Collections", false, true).find_child(split[4], true, false).find_child(get_scene_name(scene_full_path, true), true, false)
				#else:
					#push_warning("The buttons path has changed. I need to find a better way to handle this. :)")
			#else:
				#push_warning("The collection that contained this button was closed, This item was not removed from favorites. Please reopen collection and try again.")


		_: # Will match all paths in res:// dir including "collections"
			scene_button = main_tab_container.find_child("Project Scenes", false, true).find_child(get_scene_name(scene_full_path, true), true, false)

	if scene_button:
		if flip_state:
			scene_button.heart_texture_button.button_pressed = not scene_button.heart_texture_button.button_pressed
			return
		if light_up_heart:
			scene_button.heart_texture_button.button_pressed = true
		else:
			scene_button.heart_texture_button.button_pressed = false









func rotate_scenes(delta):
	for camera in all_scene_cameras:
		if camera.visible:
			#if debug: print(camera)
			#camera.rotation.y += 0.5 * delta
			camera.set_process(false)
		else:
			camera.set_process(false)
			#camera.rotation.y = camera.rotation.y
	#for scene_instance in all_scenes_instances:
		#scene_instance.rotation.y += 0.5 * delta


func get_scene_mesh_center_position(mesh):
	# Assuming you have a Mesh instance called `mesh`
	var center = Vector3(0, 0, 0) # initializing with zero values
	for i in mesh.get_surface(0).get_array("vertex"):
		center += i
		center /= float(mesh.get_surface(0).get_vertex_count())
		if debug: print(center)


#func load_scene_primer(scenes_path) -> void:
	#var scenes_to_load: Array = []
	#var dir = DirAccess.open(scenes_path)
	#
	#if not dir:
		#push_error("Invalid dir: " + scenes_path)
#
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
		#if file_name.ends_with(".tscn") or file_name.ends_with(".glb"): # NOTE As grows add to list array
#
			#var full_path = scenes_path + "/" + file_name
			#var thumbnail_cache_path: String
			#if full_path.ends_with(".tscn"):
				##get_thumbnail_cache_path(".tscn", scene_full_path)
				#thumbnail_cache_path = path_to_thumbnail_cache_shared + full_path.substr(14, full_path.length() - 18) + "png"
			#elif full_path.ends_with(".glb"):
				##get_thumbnail_cache_path(".glb", scene_full_path)
				#thumbnail_cache_path = path_to_thumbnail_cache_shared + full_path.substr(14, full_path.length() - 17) + "png"
			##var thumbnail_cache_path: String = "user://scenes_thumbnail_cache/" + full_path.substr(14, full_path.length() - 18) + "png"
#
			## FIXME MAYBE EXPENSIVE OPERATION??
			#if dir.file_exists(thumbnail_cache_path):
				##if debug: print("thumbnail cache exists: ", thumbnail_cache_path)
				#pass
			#elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
				##if ResourceLoader.exists(full_path) and full_path.ends_with(".tscn"):
					##ResourceLoader.load_threaded_request(full_path, "PackedScene", false, ResourceLoader.CACHE_MODE_IGNORE)
				#if ResourceLoader.exists(full_path):
					##if debug: print("Resource exists at: ", full_path)
					#if full_path.ends_with(".tscn") or full_path.ends_with(".glb"):
						## FIXME FIXME FIXME FIXME FIXME FIXME 
						#ResourceLoader.load_threaded_request(full_path, "PackedScene", false, ResourceLoader.CACHE_MODE_IGNORE)
						##ResourceLoader.load(full_path)
			#else:
				#pass
		#else:
			#pass
		#file_name = dir.get_next()
	#dir.list_dir_end()





signal scene_file_name(full_path)
var main_collection_tab_count: int = 0

## NOTE: Only used to get dir structure so TODO: Trim down for dir searching FIXME
## Load files from directory | bcg-jackson
## REFERENCE: https://forum.godotengine.org/t/load-files-from-directory/13576/2
#func get_all_in_folder(path: String) -> Array:
	#var items: Array = []
	#var dir = DirAccess.open(path)
	#if not dir:
		#push_error("Invalid dir: " + path)
		#return items  # Return an empty list if the directory is invalid
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
		##if debug: print("FILE_NAME!!: ", file_name)
		#if !file_name.begins_with(".") and !file_name.ends_with(".import"):
			#var full_path = path.path_join(file_name)
			#if ResourceLoader.exists(full_path):
				##if accepted_file_ext.has(full_path.get_extension()):
				#if full_path.ends_with(".tscn") or full_path.ends_with(".scn"):# or full_path.ends_with(".glb"):
					#items.append(file_name)
			#if full_path.ends_with(".remap"):
				#full_path = full_path.substr(0, full_path.length() - 6)
			#if dir.current_is_dir():# and scenes_paths.has(path): # and include_dir:
				#items.append(full_path)
			#else:
				#pass
		#file_name = dir.get_next()
	#dir.list_dir_end()
	#return items

# NOTE: Only used to get dir structure so TODO: Trim down for dir searching FIXME
# Load files from directory | bcg-jackson
# REFERENCE: https://forum.godotengine.org/t/load-files-from-directory/13576/2
func get_all_in_folder(path: String) -> Array:
	var items: Array = []
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Invalid dir: " + path)
		return items  # Return an empty list if the directory is invalid
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		#if debug: print("FILE_NAME!!: ", file_name)
		if !file_name.begins_with(".") and !file_name.ends_with(".import"):
			var full_path = path.path_join(file_name)
			if ResourceLoader.exists(full_path):
				#if accepted_file_ext.has(full_path.get_extension()):
				if full_path.ends_with(".gltf") or full_path.ends_with(".glb"):# or full_path.ends_with(".glb"):
					items.append(file_name)
			if full_path.ends_with(".remap"):
				full_path = full_path.substr(0, full_path.length() - 6)
			if dir.current_is_dir():# and scenes_paths.has(path): # and include_dir:
				items.append(full_path)
			else:
				pass
		file_name = dir.get_next()
	dir.list_dir_end()
	return items





# NOTE NOT USED | FIXME does not load .glb
# Function to load a .glb file from the user filesystem
# Reference: https://docs.godotengine.org/en/latest/tutorials/io/runtime_file_loading_and_saving.html#d-scenes
func load_glb_from_user_filesystem(full_path: String) -> PackedScene:
	# Load an existing glTF scene.
	# GLTFState is used by GLTFDocument to store the loaded scene's state.
	# GLTFDocument is the class that handles actually loading glTF data into a Godot node tree,
	# which means it supports glTF features such as lights and cameras.
	var gltf_document_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var error = gltf_document_load.append_from_file(full_path, gltf_state_load)
	if error == OK:
		var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
		#add_child(gltf_scene_root_node)
		return gltf_scene_root_node
	else:
		push_error("Couldn't load glTF scene (error code: %s)." % error_string(error))
		return


#region Create Folders and Subfolders

#var import_dialog = EditorScenePostImport.new()

#func update_scene_buttons() -> void:
	## Remove only folder objects from filtered_scene_buttons
	#for button in folder_filtered_scene_buttons:
		#if new_main_project_scenes_tab.filtered_scene_buttons.has(button):
			#new_main_project_scenes_tab.filtered_scene_buttons.erase(button)
	##var current_buttons: Array[Node] = new_main_project_scenes_tab.find_child("HFlowContainer").get_children()
	#var scene_buttons: Array[Node] = []
	#if new_main_project_scenes_tab.filtered_scene_buttons == []:
		#scene_buttons = new_main_project_scenes_tab.h_flow_container.get_children()
		#for button: Node in scene_buttons:
			#button.show()
	#else:
		#scene_buttons = new_main_project_scenes_tab.filtered_scene_buttons
		#for button: Node in scene_buttons:
			#button.show()


var create_favorite_buttons: bool = true

# FIXME Needs gates for files that are not .tscn will throw errors if other file types in folders
func create_main_collection_tabs(create_project_scenes_tab: bool) -> void:

	if create_project_scenes_tab: # Create Project Scenes Tab
		new_main_project_scenes_tab = MAIN_PROJECT_SCENES_TAB.instantiate() # FIXME 
		main_tab_container.add_child(new_main_project_scenes_tab)
		new_main_project_scenes_tab.name = "Project Scenes"
		new_main_project_scenes_tab.owner = self
		
		main_collection_tabs.append(new_main_project_scenes_tab)
		# Connect main_project_scene_tab signals
		###################################################################################KEEP 
		#new_main_project_scenes_tab.change_current_filter_2d_3d.connect(sync_filter_2d_3d)
		new_main_project_scenes_tab.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)
		new_main_project_scenes_tab.allow_one_time_scan.connect(func (): one_time_scan = true)


		## CAUTION DID I REPLACE THIS WITH filter_buttons() IN main_base_tab.gd?
		#new_main_project_scenes_tab.show_all_scenes.connect(func(): 
				#one_time_scan = true
				#refresh_project_scenes("res://"))

		#new_main_project_scenes_tab.show_all_scenes.connect(update_scene_buttons)





		var sub_folders_path: String = "res://collections"
		var collection_name: String = ""
		var new_sub_collection_tab: Control = new_main_project_scenes_tab
		
		
		# NOTE: Will always process first so do not add to queue and will trigger signal from add_scenes_to_collections
		## FIXME CREATE QUEUE AND ADD TO IT HERE
		#var collection_data: Array = []
		#collection_data.append(sub_folders_path)
		#collection_data.append(new_sub_collection_tab)
		#collection_queue[collection_name] = collection_data


		
		
		var scenes_dir_path: String = sub_folders_path.path_join(collection_name)
		var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
		var file_names: Array[String]
		file_names.assign(collection_file_names)
		#add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control, collection_file_names: PackedStringArray)
		add_scenes_to_collections(collection_name, sub_folders_path, new_sub_collection_tab, file_names)
		# Create buttons for all the generic scenes in the project
		create_project_scene_buttons()



	else: # Create the Global and Shared Collections Tabs
		for path: String in scenes_paths:
			for main_folder_path in get_all_in_folder(path):
				var main_folder_name: String = main_folder_path.get_file()
				print("main_folder_name: ", main_folder_name)
				if sharing_disabled and main_folder_name == "Shared Collections":
					print("skipping")
					continue
				var new_main_collection_tab = MAIN_COLLECTION_TAB.instantiate()
				#var settings = EditorInterface.get_editor_settings()
				var panel_floating_on_start = settings.get_setting("scene_snap_plugin/panel_floating_on_start")
				
				main_collection_tabs.append(new_main_collection_tab)
				# Connect main_collection_tab signals
				# When Tab is openned from UI create_sub_collection_tabs is run
				new_main_collection_tab.selected_collections_from_item_list.connect(create_sub_collection_tabs)
				###################################################################################KEEP 
				#new_main_collection_tab.change_current_filter_2d_3d.connect(sync_filter_2d_3d)
				new_main_collection_tab.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)


				#if main_folder_name and main_folder_name is String:
					#main_tab_container.add_child(new_main_collection_tab)
					#new_main_collection_tab.name = main_folder_name
					#new_main_collection_tab.owner = self


				## Reset first scene_view button selection to 0 when changing sub tabs
				#new_main_collection_tab.selected_sub_tab_changed.connect(
					#func (tab: int) -> void: scene_viewer_panel_instance.current_scene_path = current_visible_buttons[0].scene_full_path)
				#new_main_collection_tab.selected_sub_tab_changed.connect(func (tab: int) -> void: emit_signal("bubble_up_selected_sub_tab_changed", tab, self))
				new_main_collection_tab.selected_sub_tab_changed.connect(func (tab: int) -> void: emit_signal("bubble_up_selected_sub_tab_changed", tab, new_main_collection_tab))



				if main_folder_name and main_folder_name is String:
					main_tab_container.add_child(new_main_collection_tab)
					new_main_collection_tab.name = main_folder_name
					new_main_collection_tab.owner = self


	#TEST Create Favorites Tab
	new_favorites_tab = main_tab_container.find_child("Favorites")
	if not new_favorites_tab:
		new_favorites_tab = MAIN_FAVORITES_TAB.instantiate()
		main_tab_container.add_child(new_favorites_tab)
		new_favorites_tab.name = "Favorites"
		new_favorites_tab.owner = self
		
		apply_favorites_tab_icon(new_favorites_tab)
		main_collection_tabs.append(new_favorites_tab)
		new_favorites_tab.enable_panel_button_sizing.connect(func () -> void: enable_panel_button_sizing = true)
	if scene_favorites != []:
		if create_favorite_buttons:
			create_favorite_buttons = false

			for scene_full_path: String in scene_favorites:
				add_scene_button_to_favorites(scene_full_path, false)
	#else:
		#pass
		#main_tab_container.remove_child(new_favorites_tab)
		##new_favorites_tab.hide()
		## Now re-add the tab
		#main_tab_container.add_child(new_favorites_tab)






#func sync_filter_2d_3d(main_collection_tab: Control, current_filter: String) -> void:
##func sync_filter_2d_3d(current_filter: String) -> void:
	##if debug: print("main_collection_tab: ", main_collection_tab)
	##if debug: print("current_filter: ", current_filter)
	#if debug: print("main_collection_tabs: ", main_collection_tabs)
	#for collection_tab: Control in main_collection_tabs:
		##if debug: print("collection_tab: ", collection_tab)
		#if collection_tab == main_collection_tab:
			#pass
		#else:
			#collection_tab.current_filter = current_filter
			#collection_tab.toggle_filter_2d_3d()
			##




###################################################################################KEEP 
#region ###################################################################################KEEP 
#enum Toggle_Filter {
	#FILTER2D3D,
	#FILTER2D,
	#FILTER3D
#}
#
#var next_filter: int = Toggle_Filter.FILTER2D3D
##var next_filter: int
#
##func toggle_filter_2d_3d():
#func sync_filter_2d_3d(change_to_next_filter: bool) -> void:
	## NOTE Give Favorite Tab time to load
	#if await_on_startup:
		##await restore_saved_data()
		#if last_session_favorites != []:
			#wait_ready(favorites)
		#await get_tree().create_timer(2).timeout
		#await_on_startup = false
#
	#if change_to_next_filter:
		#match next_filter:
			#Toggle_Filter.FILTER2D3D:
				#next_filter = Toggle_Filter.FILTER2D
			#Toggle_Filter.FILTER2D:
				#next_filter = Toggle_Filter.FILTER3D
			#Toggle_Filter.FILTER3D:
				#next_filter = Toggle_Filter.FILTER2D3D
#
	#for collection_tab: Control in main_collection_tabs:
#
		#match next_filter:
			#Toggle_Filter.FILTER2D3D:
				#collection_tab.filter_2d_3d_button.set_button_icon(FILTER_2D_3D)
				#collection_tab.filter_2d_3d_button.tooltip_text = "ACTIVE: Show both 2D and 3D scenes."
				#
				### TODO ADD IN SHOW HIDE BASED ON FOCUSED BUTTON TYPE
				##if button is 2d:
					##change_body_type_2d_button.show()
					##change_body_type_3d_button.hide()
				##
				##if button is 3d:
					##change_body_type_3d_button.show()
					##change_body_type_2d_button.hide()
					#
				#
#
				#
				#
				##if change_to_next_filter:
					##next_filter = Toggle_Filter.FILTER2D
			#Toggle_Filter.FILTER2D:
				#collection_tab.filter_2d_3d_button.set_button_icon(FILTER_2D)
				#collection_tab.filter_2d_3d_button.tooltip_text = "ACTIVE: Show only 2D scenes."
				#change_body_type_2d_button.show()
				#change_body_type_3d_button.hide()
				##if change_to_next_filter:
					##next_filter = Toggle_Filter.FILTER3D
			#Toggle_Filter.FILTER3D:
				#collection_tab.filter_2d_3d_button.set_button_icon(FILTER_3D)
				#collection_tab.filter_2d_3d_button.tooltip_text = "ACTIVE: Show only 3D scenes."
				#change_body_type_3d_button.show()
				#change_body_type_2d_button.hide()
				#
				##if change_to_next_filter:
					##next_filter = Toggle_Filter.FILTER2D3D
#
	### Change to next_filter after going through each Main Tab
	##if change_to_next_filter:
		##if debug: print("FILTER!!: ", filter)
		##filter = next_filter
#endregion
###################################################################################KEEP 


# NOTE REVISED VERSION 2
# NOTE NEED TO ADD IN SCENE DEPENDENCY CHECKS AND TEXTURE IMPORT
# NOTE NEEDS TO BE RESTRUCTURED FOR IMPORT FUNCTIONALITY
# FIXME sometimes getting duplicate sub collection tabs made Maybe timer that regenerates collection when renamed?
#func create_sub_collection_tabs(main_folders_path: String, main_folder_name: String, new_main_collection_tab: Control) -> void:#, new_main_collection_tab_clone: TabBar) -> void:
# TODO Make newly added tab index 0 and focus
func create_sub_collection_tabs(selected_collections: Array[String], new_main_collection_tab: Control) -> void:#, new_main_collection_tab_clone: TabBar) -> void:
	if debug: print("opening collection")
	#new_main_collection_tab = main_collection_tab
	#if debug: print("new_main_collection_tab: ", new_main_collection_tab.name)
	var sub_folders_path: String = ""
	#match new_main_collection_tab.name:
		#"Global Collections":
			#sub_folders_path = scenes_paths[0].path_join("Global Collections/")
		#"Shared Collections":
			#sub_folders_path = scenes_paths[1].path_join("Shared Collections/")

	if new_main_collection_tab.name == "Global Collections":
		sub_folders_path = scenes_paths[0].path_join(new_main_collection_tab.name)
	if new_main_collection_tab.name == "Shared Collections":
		sub_folders_path = scenes_paths[1].path_join(new_main_collection_tab.name)

	#match new_main_collection_tab.name:
		#"Global Collections":
			#sub_folders_path = scenes_paths[0].path_join(new_main_collection_tab.name)
		#"Shared Collections":
			#sub_folders_path = scenes_paths[1].path_join(new_main_collection_tab.name)



	for collection_name: String in selected_collections:
		
		var new_sub_collection_tab: Control = SUB_COLLECTION_TAB.instantiate()
		
		# Connect signal
		new_sub_collection_tab.process_drop_data_from_tab.connect(parse_drop_file)
		#new_sub_collection_tab.rename_sub_collection_tabs.connect(rename_sub_collection_tab)

		if collection_name and collection_name is String:

			new_main_collection_tab.sub_tab_container.add_child(new_sub_collection_tab)


			#### NOTE: Seems to result in "ERROR: res://addons/scene_snap/scripts/main_base_tab.gd:445 - Trying to assign invalid previously freed instance."
			var sub_tab_bar: TabBar = new_main_collection_tab.sub_tab_container.get_tab_bar()
			var new_tab_index: int = new_main_collection_tab.sub_tab_container.get_tab_idx_from_control(new_sub_collection_tab)
			sub_tab_bar.current_tab = new_tab_index
			sub_tab_bar.current_tab# Force the TabBar to update its visual state
			#sub_tab_bar.queue_redraw()




# NOTE: WORKS SET TAB TO POSITION 0 AND FOCUS ON IT 
			## Get the TabContainer and the TabBar
			#var tab_container = new_main_collection_tab.sub_tab_container
			#var tab_bar = tab_container.get_tab_bar()
#
			## Get the tab index of the control you want to move
			#var from_index: int = tab_container.get_tab_idx_from_control(new_sub_collection_tab)
#
			## Ensure we're not already at the desired position
			#if from_index != 0:
				## Move the visual tab
				#tab_bar.move_tab(from_index, 0)
#
				## Move the actual child control
				#var control = tab_container.get_child(from_index)
				#tab_container.move_child(control, 0)
#
				## Optionally, make it the current tab
				#tab_container.current_tab = 0







## NOTE: Same result as above
			#var sub_tab_bar: TabBar = new_main_collection_tab.sub_tab_container.get_tab_bar()
			#var sub_tab_count: int = new_main_collection_tab.sub_tab_container.get_tab_count()
			#if debug: print("sub_tab_count: ", sub_tab_count)
			#sub_tab_bar.move_tab(sub_tab_count - 1, 0)


			new_sub_collection_tab.name = collection_name
			new_sub_collection_tab.owner = self

			# Pass sub_folders_path variable to sub collection tab so dropped data can get path_to_save_scene
			new_sub_collection_tab.sub_folders_path = sub_folders_path
			#new_sub_collection_tab.main_collection_tab_name = new_main_collection_tab.name
			new_sub_collection_tab.set_v_size_flags(SIZE_EXPAND_FILL)

		# Get the textures within the texture folder in the user:// dir
		var texture_files_path: String = sub_folders_path.path_join(collection_name.path_join("textures"))

		var collection_name_snake_case: String = collection_name.to_snake_case()

		# Copy the textures from user:// dir to the collections/collection_name/textures folder in the res:// dir
# FIXME Pass path over to .glb save path
		# FOR .GLTF

# FIXME if .glb textures are created in textures folder and textures folder copied in from user:// will cause issues
# FIXME For collection names with number at beginning or end will brake because space _ is added.

		create_folders("res://", "collections".path_join(collection_name_snake_case.path_join("textures")))

		# FIXME With mixed .glb and .gltf with textures in user:// textures folder will get errors on import 
		# because .glb append_from_buffer on import attempts to also write to the same res:// collections folder
		
		# Copy textures that exist in the user:// textures folder into the res:// collections textures folder
		if user_dir.dir_exists(texture_files_path):
			if not DirAccess.get_files_at(texture_files_path).is_empty():
				for texture_file_name: String in DirAccess.get_files_at(texture_files_path):
					texture_file_names.append(texture_file_name)
					var origin_texture_full_path: String = texture_files_path.path_join(texture_file_name)
					project_textures_full_path = project_scenes_path.path_join(collection_name_snake_case.path_join("textures".path_join(texture_file_name)))
					#create_folders("res://", "collections".path_join(collection_name_snake_case.path_join("textures")))
					#if debug: print("project_textures_full_path: ", project_textures_full_path)

					# Only do textures folder copy if .gltf or .obj
					
					emit_signal("do_file_copy", res_dir, origin_texture_full_path, project_textures_full_path)

		## FOR .GLB We will still want to create the directory for .glb files to copy in textures.
		#else: # .glb needs to be loaded in?
			#create_folders("res://", "collections".path_join(collection_name_snake_case.path_join("textures")))

## FIXME Find best approcah keep like this or display snake case but also have to adjust finding and filenameing in user:// to snakecase
## TEST Testing for changed collection_name_snake_case to collection_name FIXME why did I need to do this? oh yes because if there is a number in the name it will brake by adding _ when there is not one
		#if user_dir.dir_exists(texture_files_path):
			#for texture_file_name: String in DirAccess.get_files_at(texture_files_path):
				#texture_file_names.append(texture_file_name)
				#var origin_texture_full_path: String = texture_files_path.path_join(texture_file_name)
				#project_textures_full_path = project_scenes_path.path_join(collection_name.path_join("textures".path_join(texture_file_name)))
				#create_folders("res://", "collections".path_join(collection_name.path_join("textures")))
				##if debug: print("project_textures_full_path: ", project_textures_full_path)
#
				#emit_signal("do_file_copy", res_dir, origin_texture_full_path, project_textures_full_path )
#
		## FOR .GLB We will still want to create the directory for .glb files to copy in textures.
		#else: # .glb needs to be loaded in?
			#create_folders("res://", "collections".path_join(collection_name.path_join("textures")))


		## FIXME CREATE QUEUE AND ADD TO IT HERE
		
		# NOTE: When a collection tab is opened add it to the queue to be loaded
		var collection_data: Array = []
		if debug: print("collection_name: ", collection_name)
		collection_data.append(collection_name)
		#collection_data.append(collection_name_snake_case)
		collection_data.append(sub_folders_path)
		collection_data.append(new_sub_collection_tab)
		collection_queue.append(collection_data)

		if debug: print("collection_queue: ", collection_queue)

		# FIXME if collection opened after startup it does not get process because signal is no longer emiited for last collection process

		# If queue is 0 then add to queue and emit signal remove from queue after finished need process finished
		# FIXME Seems not always work?
		if debug: print("processing_collection: ", processing_collection)
		if debug: print("collection_queue.size(): ", collection_queue.size())
		while processing_collection:
			await get_tree().process_frame
		#var processed_collection: bool = not processing_collection
		#await wait_ready(processed_collection)
		if not processing_collection and collection_queue.size() >= 1:
			#var scenes_dir_path: String = collection_data[1].path_join(collection_data[0])
			#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
			#emit_signal("process_next_collection", collection_file_names)
			emit_signal("process_next_collection")

		### Create the scene buttons 
		#await get_tree().create_timer(2).timeout
		#if collection_queue.size() == 1:
			#if debug: print("processing collection outside of queue")
			#add_scenes_to_collections(collection_name, sub_folders_path, new_sub_collection_tab)





		#else: # If there is more then one collection being opened at the same time add it to the queue
			#var collection_data: Array = []
			#collection_data.append(collection_name)
			#collection_data.append(sub_folders_path)
			#collection_data.append(new_sub_collection_tab)
			#collection_queue.append(collection_data)







	#else:
		#var new_sub_collection_tab: Control = SUB_COLLECTION_TAB.instantiate()
		#new_main_collection_tab.find_child("SubTabContainer").add_child(new_sub_collection_tab)
		#new_sub_collection_tab.name = sub_folder_name
		#new_sub_collection_tab.owner = self

#func create_sub_collection_local_scenes_tabs(new_main_collection_tab: TabBar) -> void:
	#if create_2d_local_scenes_tab and new_main_collection_tab.name == "2D Scenes":
		#create_2d_local_scenes_tab = false
		#local_scenes_tabs(new_main_collection_tab)
		##sub_folder_name = "Local Scenes"
		##create_sub_collection_tabs("user://shared_collections/scenes/", "2D Scenes", "Local Scenes", new_main_collection_tab)
	#
	#if create_3d_local_scenes_tab and new_main_collection_tab.name == "3D Scenes":
		#create_3d_local_scenes_tab = false
		#local_scenes_tabs(new_main_collection_tab)
		##sub_folder_name = "Local Scenes"
		##create_sub_collection_tabs("user://shared_collections/scenes/", "3D Scenes", "Local Scenes", new_main_collection_tab)
#
#func local_scenes_tabs(new_main_collection_tab: TabBar) -> void:
	#var new_sub_collection_tab: Control = SUB_COLLECTION_TAB.instantiate()
	#new_main_collection_tab.find_child("SubTabContainer").add_child(new_sub_collection_tab)
	#new_sub_collection_tab.name = "Local Scenes"
	#new_sub_collection_tab.owner = self

#var total_count: int = 0
#
#func multi_test(index: int, scenes_dir_path: String, new_sub_collection_tab: Control, new_scene_view: Button, pass_cache: bool):
	#if debug: print("scene full path: ", scenes_dir_path.path_join(DirAccess.get_files_at(scenes_dir_path)[index]))
	#if debug: print("index: ", index)
	#for count: int in range(1000000):
		#total_count += count
	#if debug: print("total_count: ", total_count)
		#

#var thread: Thread
#var thread = Thread.new()
var pause_for_collection_finish: bool = true
var sub_collection_scene_count: int = 0
var count_finished :int = 0
var reload_scene_view_buttons_func: bool = false

var single_thread: bool = false
#var run_gltf_image_hash_check: bool = true





#region VERSION 8 DON'T KNOW BEST SOLUTION STARTING WITH MULTI-THREADED CHUNK, BUT FAILS WITH LARGE SYNTY COLLECTION WITHOUT HASHING AND NEEDING LONG SINGLE-THREADED IMPORT FOR EACH SCENE

# FIXME Will sometimes crash on start with large collection?
# FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
# FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
# FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
# FIXME button label not being updated to hide if below min size to hide label
#var collection_scene_full_paths: Array[String] = []



var collection_scene_full_paths: Dictionary[String, Array] = {}
var collection_scene_full_paths_array: Array[String] = []
var collection_textures_paths: Dictionary[String, String] = {} 
#var current_sub_folder_name: String = ""
var current_collection_name: String = ""

#var collection_processing_count: int = 0
#var collection_process_queue: Array[String] = []

#var collection_queue: Dictionary[int, Array] = {}
var collection_queue: Array[Array] = [] 
var collection_scenes_queue: Array[Array] = []
var processing_collection: bool = false
#var states: Dictionary = {}  # Thread-safe handoff
#var collection_count: int = 0

#var current_collection_id: int = -1

# NOTE: May need to be fixed or adjusted for when renaming collections?
# TODO Add folders if they do not exist? NOTE: Only create folders that will be populated
## Get the project collection base path if get_collection_base_path set to false will get the file_path
func get_collection_path(scene_full_path: String, get_collection_base_path: bool = true) -> String:
	var path: String = ""
	var project_collection_base_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case())
	if get_collection_base_path:
		path = project_collection_base_path
	else:
		path = project_collection_base_path.path_join(scene_full_path.split("/")[-1])
	#var file_path: String = project_collection_base_path.path_join(scene_full_path.split("/")[-1])
	return path

#func get_project_path(scene_full_path: String, folder_name: String) -> String:
	#var imported_base_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case())
	#return imported_base_path.path_join(folder_name.path_join("/"))




## TEST
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#pass

# FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
# FIXME closing a collection and re-opening will not open collection not being added to queue?
# TODO Make single threaded import run on background thread
# TODO Display button textures during multi-threaded loading time


# NOTE: Called when:
# 1. create_main_collection_tabs()
# 2. _ready() for any open tabs at start
# 3. create_sub_collection_tabs() when openning new collection from list collection gets added to queue and signal runs process_collection()















# FIXME OPENNING COLLECTION TAB DOES NOT ALWAYS TRIGGER COLLECTION IMPORT OF .GLB FILES TO BUFFER
#region refactored section
# FIXME ?? Pass in scene_full_paths array to only process new added scenes rather then DirAccess.get_files_at(scenes_dir_path)??
func add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control, collection_file_names: Array[String]) -> void:

	#if collection_file_names.is_empty():
		#if debug: print("collection_queue.size(): ", collection_queue.size())
		#if collection_queue.size() > 0:
			#if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			#emit_signal("process_next_collection")
		#else:
			## After all collections have been loaded then check filesystem for .tres material files
			#collect_standard_material_3d("res://")
			## initialize filtering if collections open
			#call_deferred("emit_initialize_filters")
#
		#if debug: print("FINISHED PROCESSING: ", collection_name.to_snake_case())
		#processed_collections.append(collection_name.to_snake_case())
#
		#return

	processing_collection = true
	print("Starting import process for1: ", collection_name)

	var scenes_dir_path: String = sub_folders_path.path_join(collection_name)

	# FIXME Setup signal for when finished
	if scenes_dir_path == project_scenes_path:
		while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			await get_tree().create_timer(1).timeout

	if debug: print("Starting import process for2: ", collection_name)
	if initialize_dir_path:
		previous_scenes_dir_path = scenes_dir_path
		initialize_dir_path = false
	sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()

	var create_buttons: bool = true
	var new_scene_view: Button = null
	scene_loading_complete = false # FIXME Maybe don't need?

	# TODO can subfoldername be used in place of collection_id?
	# FIXME Using collecton id issue is that if there is a gap between when this function is run the await finished_processing_collection is never
	# fired to allow it to progress past that point, await finished_processing_collection only works if there is a chain of collections openned at the same time
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	if debug: print("collection_file_names: ", collection_file_names)
	if debug: print("collection_file_names.size(): ", collection_file_names.size(), " for collection: ", collection_name)
	if collection_file_names.size() > 0:
		cleanup_task_id1 = true
		var imported_textures_path: String
		#var imported_materials_path: String

	################ SPLICED IN
		if debug: print("Starting image hashing and multi-threaded import stack for collection: ", collection_name)
		mutex.lock()
		collection_hased_images.clear()
		collection_images.clear()
		process_single_threaded_list.clear()
		## Clear scene_data_cache before importing tags # FIXME Need better solution. If tags not properly saved to extras will be lost (Think about two people saving to same file at different times second will overwrite first)
		#scene_data_cache.scene_data.clear()
		#ResourceSaver.save(scene_data_cache)
		mutex.unlock()
	################ SPLICED IN

		await get_tree().create_timer(1).timeout
		#if debug: print("ext: ", gltf.get_supported_gltf_extensions())

		var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].to_snake_case().path_join("textures".path_join("/")))
		collection_textures_paths[collection_name] = collection_textures_path # NOTE: Not needed with now having queue and only one collection running through stack at a time

		if debug: print("clearing collection_scene_full_paths_array for: ", collection_name)
		collection_scene_full_paths_array = []
		var post_create_buttons_array: Array[String] = []
		
		var thumbnail_cache_path: String
		
		#imported_textures_path = OS.get_temp_dir()
		#imported_textures_path = user_dir.create_temp("atempdir", true)
		
		#var snap_logic_temp: DirAccess = DirAccess.open(OS.get_temp_dir()).create_temp("snap_logic_temp", true)
		#var dummy_file_path: String = FileAccess.create_temp(FileAccess.WRITE_READ, "dummy_file", "png", true).get_path()
		#imported_textures_path = dummy_file_path
		var thumbnail_count: int = 0
		# FIXME TODO Hide buttons until all textures loaded
		for file_name: String in collection_file_names:
			if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				var scene_full_path: String = scenes_dir_path.path_join(file_name)
				thumbnail_cache_path = get_thumbnail_cache_path(scene_full_path)
				if user_dir.file_exists(thumbnail_cache_path):
					thumbnail_count += 1
					#post_create_buttons_array.append(scene_full_path)
					
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)

				#else: # To add thumbnails for initially imported scenes or scenes that get added to collection. 
					#post_create_buttons_array.append(scene_full_path)



				collection_scene_full_paths_array.append(scene_full_path)
				


				## NOTE: Path variables only need to be filled once per collection
				#if not current_collection_name == collection_name:
					#current_collection_name = collection_name
				var imported_base_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case())
				imported_textures_path = imported_base_path.path_join("textures".path_join("/"))
				#imported_materials_path = imported_base_path.path_join("materials".path_join("/"))

				#imported_textures_path = get_project_path(scene_full_path, "textures")
				#imported_materials_path = get_project_path(scene_full_path, "materials")

				# FIXME FIX THINGS THAT REFERENCE TEXTURES FOLDER TO USE COLLECTIONS FOLDER FOR ALL ASSETS
				#imported_textures_path = get_collection_path(scene_full_path)
				# TEMP
				#imported_textures_path = get_collection_path(scene_full_path).path_join("textures".path_join("/"))


		if debug: print("collection_scene_full_paths_array: ", collection_scene_full_paths_array)

	# FIXME NEED BETTER SOLUTION HERE FIXME CAUTION If items added to collection import will break | WILL BYPASS IMPORT IF TEXTURES FOLDER ALREADY CONTAINS OBJECTS IS THERE A QUICK WAY TO CHECK SIZE OF WHAT WILL BE IMPORTED
	# TO TEXTURES FOLDER CONTENT SIZE? WOULD REQUIRE RUNNING THROUGH multi_threaded_gltf_image_hashing EACH TIME. IS THERE A WAY TO BLOCK WRITES FROM multi_threaded_load_gltf_scene_instances AND SEND THEM TO SINGLE THREAD, NO TRIED THAT.

		var initial_import: bool = false
		# TODO Add execption for .obj scene files if .obj return false
		if run_gltf_image_hash_check(collection_textures_paths[collection_name]): # NOTE: If no textures (.png files) exist in the project collections then it's a new collection 
			initial_import = true

	# FIXME Several check s need to happen here need to check against cached collection size for when new items added to collection
	# When checks are needed
	# NOTE: Need most simple check that satifies all cases? 
	# --Most simple checks if folders contain textures or thumbnails but not good when adding new items after already created
	# -- Thumbnail size matches collection size great solution if all scenes generated thumbnails Actually this does work! simple and quick check and works for when refreshing thumbnails
	# Maybe collection_file_names? but useless because no reference

	# 1. res:// textures contains .png files # NOTE CAUTION Must be disabled for .obj with no textures
	# 2. Thumbnail size matches collection size. Are there cases where this could break? the small .glb files that did not generated .png will always trigger this to run so that one is an issue

	# Run only when new items added and if possible only for new items not for scenes already in the collection that have been processed?

		if initial_import or collection_file_names.size() != thumbnail_count: # FIXME Update for linking and updating based on DirectoryWatcher results
		##if true:
			#if debug: print("running initial_import for: ", collection_name)
			#if debug: print("collection_file_names.size(): ", collection_file_names.size())
			#if debug: print("thumbnail_count: ", thumbnail_count)
			## FIXME NON-CRITICAL Optimize for only processing newly added scenes or processing the scene_full_paths of the thumbnails that do not exist, not all which is what is the current.
			#if collection_file_names.size() != thumbnail_count:

				##var path_split: PackedStringArray = thumbnail_cache_path.split("/")
				##var thumbnail_cache_dir: String = "user://" + path_split[2].path_join(path_split[3].path_join(path_split[4].path_join(path_split[5])))
	##
	##
	##
	##
	##
	##
	################## SPLICED IN
				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths_array), collection_scene_full_paths_array.size())

				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_name, new_sub_collection_tab, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
				#await finished_image_hashing
	################## SPLICED IN

				multi_threaded_chunk_process(imported_textures_path, collection_name, initial_import, new_sub_collection_tab, new_scene_view)
				if debug: print("waiting for finished_collection_chunks signal")
				await finished_collection_chunks
				




				### NOTE: For creating thumbnails FIXME if import is interrupted then will need to delete files to retrigger thumbnail or not
				### NOTE: Only used to create thumbnails so if they exist then do not run
				##multi_threaded_chunk_process(imported_textures_path, collection_name, initial_import, new_sub_collection_tab, new_scene_view)
				##if debug: print("waiting for finished_collection_chunks signal")
				##await finished_collection_chunks
	##
				##while DirAccess.get_files_at(thumbnail_cache_dir).size() != collection_scene_full_paths_array.size():
					##await get_tree().process_frame 
	##
				##if debug: print("Finished multi-thread chunk processing for: ", collection_name)
	##
				#mutex.lock()
				##collection_lookup[collection_name.to_snake_case()].clear()
				#collection_lookup.clear()
				#mutex.unlock()







	####################### SPLICED IN
				#EditorInterface.get_resource_filesystem().scan()
				await get_tree().create_timer(5).timeout # Required to prevent generated thumbnails from preventing texture .import by engine in load_gltf_scene_instance()
				if scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
					if debug: print("scanning not proceed")
				else:
					if debug: print("not scanning")
				
				#await get_tree().process_frame # Required to prevent generated thumbnails from preventing texture .import by engine in load_gltf_scene_instance()
				# NOTE: Textures need to be imported and visible before multi_threaded_load_gltf_scene_instances runs to not Error
				if debug: print("process_single_threaded_list: ", process_single_threaded_list)
				for scene_full_path: String in process_single_threaded_list:
					#load_gltf_scene_instance(scene_full_path, imported_textures_path, collection_name)
					load_gltf_scene_instance(scene_full_path, imported_textures_path, true)
					#await get_tree().process_frame
					#await get_tree().create_timer(0.1).timeout
				## FIXME Put timeout in
				#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
					#await get_tree().process_frame
				#await get_tree().process_frame 
				# NOTE: Delay needed to give system time to trigger filesystem scan/import from generate_scene but thumbnail generation messes it up
				# EditorInterface.get_resource_filesystem().update_file(file) causes errors because system already has import scheduled and ERRORs when they start to run over EditorInterface.get_resource_filesystem().update_file(file)
				#await get_tree().create_timer(5).timeout
	####################### SPLICED IN

				#EditorInterface.get_resource_filesystem().scan_sources()
				#if debug: print(EditorInterface.get_resource_filesystem())

				#var filesystem = GetEditorInterface().GetResourceFilesystem();
	# NOTE NOTE NOTE NOTE  FIXME FIND OUT WHY THUMBNAIL GENERATION IS BLOCKING .IMPORT FROM HAPPENING!!!
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#EditorInterface.get_resource_filesystem().scan()
				#await get_tree().create_timer(5).timeout
				####EditorInterface.get_resource_filesystem().reimport_files(DirAccess.get_files_at(collection_textures_paths[collection_name]))
				#for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
					###if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
				#EditorInterface.get_resource_filesystem().reimport_files(DirAccess.get_files_at(collection_textures_paths[collection_name]))
				##EditorInterface.get_resource_filesystem().scan()
				###EditorInterface.get_resource_filesystem().scan()
				#while EditorInterface.get_resource_filesystem().is_scanning():
					#await get_tree().process_frame
					#if debug: print("scanning")
					###await get_tree().create_timer(1).timeout
				###await EditorInterface.get_resource_filesystem().resources_reimported
				#await get_tree().create_timer(30).timeout



				#for gltf_state: GLTFState in gltf_state_array:
					#var gltf_scene: Node = gltf.generate_scene(gltf_state)
					#gltf_scene.queue_free()
	#
				#await get_tree().create_timer(5).timeout
	#
				#for gltf_state: GLTFState in gltf_state_array:
					#for material in gltf_state.materials:
						#if material is Material:
							##if debug: print("Found material:", material)
							## Save it if needed
							#var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
							#ResourceSaver.save(material, save_path)







	 ###FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
	### NOTE:  MASSIVE BOTTLENECK NOT ONLY SINGLE THREADED BUT ALSO NEED 0.5 SEC FOR FILESYSTEM TO RECGNIZE AND IMPORT FILES!!
				#### NOTE: For loading textures into filesystem single threaded
				##for scene_full_path: String in collection_scene_full_paths_array:
					### NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
					### NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
					###await get_tree().create_timer(0.5).timeout 
					##call_deferred("load_gltf_scene_instance_test", scene_full_path, imported_textures_path, collection_name)
	##
				##
			#mutex.lock()
			#collection_lookup[collection_name] = scene_lookup
			#mutex.unlock()
	##
	##
	##
	##
	##
				##await get_tree().create_timer(5).timeout
	#
	#
	## TEST WRITE TO TEMP DIR MULTI-THREADED
				##user_dir.create_temp("atempdir")
				##if debug: print("OS.get_temp_dir(): ", OS.get_temp_dir())
				##OS.get_temp_dir()
	## TEST
	#
	#
	#
				#if debug: print("running multi-threaded re-import for collection: ", collection_name)
				## NOTE: Reload scenes multi-threaded referencing imported filesystem textures found in collections folder
				#initial_import = false
				#var chunk_lookup: Dictionary[String, Node] = {} # Dummy Dict
				#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, collection_scene_full_paths_array, initial_import), collection_scene_full_paths_array.size())
				#if debug: print("Awaiting finish of multi-threaded re-import for collection: ", collection_name)
				#await finished_processing_collection
				#if debug: print("Finished multi-threaded re-import for collection: ", collection_name)
	#
				#mutex.lock()
				#collection_lookup[collection_name] = scene_lookup
				#mutex.unlock()





	# TEST TEMP DEACTIVE
	# FIXME CAUTION HASH RESULT AND IMPORT IS NOT GETTING THE SAME AS SINGLE THREADED IMPORT ALL THE SCENES SO HASH IS MISSING SOME SCENES THAT NEED TO BE IMPORTED 
	# SO THAT WHEN MULTI-THREADED RUNS IT TRIES TO WRITE MORE TEXTURES TO THE FILESYSTEM CRASHING IT. SAME ISSUE AS BEFORE BUT THOUGHT SOLVED IT. SO MISSING SOMETHING? WHAT AM I MISSING?
		#else:
		# FIXME FIRST TIME AFTER INITIAL IMPORT CRASHES NOT SURE CAUSE? MAYBE SOMETHING TO DO WITH CREATING BUTTONS
		#await get_tree().process_frame # Seems to help with crashing on first start after initial import
		#await get_tree().create_timer(20).timeout
		if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
		#var chunk_lookup: Dictionary[String, Node] = {} # Dummy Dict # Check if can be put inside muti-thread
		#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
		#if mesh_tag_import:
			## Clear scene_data_cache before importing tags # FIXME Need better solution. If tags not properly saved to extras will be lost (Think about two people saving to same file at different times second will overwrite first)
			#scene_data_cache.scene_data.clear()
			#ResourceSaver.save(scene_data_cache)
		task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
		if debug: print("WAITING TO FINISH multi_threaded_load_gltf_scene_instances")
		await finished_processing_collection
		if debug: print("FINISHED multi_threaded_load_gltf_scene_instances")
		if debug: print("finished multi_threaded_load for: ", collection_name)



	## MODDED:
	## TEST TEMP DEACTIVE
	## FIXME CAUTION HASH RESULT AND IMPORT IS NOT GETTING THE SAME AS SINGLE THREADED IMPORT ALL THE SCENES SO HASH IS MISSING SOME SCENES THAT NEED TO BE IMPORTED 
	## SO THAT WHEN MULTI-THREADED RUNS IT TRIES TO WRITE MORE TEXTURES TO THE FILESYSTEM CRASHING IT. SAME ISSUE AS BEFORE BUT THOUGHT SOLVED IT. SO MISSING SOMETHING? WHAT AM I MISSING?
		##else:
		## FIXME FIRST TIME AFTER INITIAL IMPORT CRASHES NOT SURE CAUSE? MAYBE SOMETHING TO DO WITH CREATING BUTTONS
		#await get_tree().process_frame # Seems to help with crashing on first start after initial import
		#if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
		##var chunk_lookup: Dictionary[String, Node] = {} # Dummy Dict # Check if can be put inside muti-thread
		#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_populate_material_lookup.bind(imported_textures_path, gltf_state_lookup), gltf_state_lookup.size())
		#await finished_processing_collection





		mutex.lock()
		collection_lookup[collection_name.to_snake_case()] = scene_lookup
		mutex.unlock()


		if collection_scene_full_paths_array:
			for scene_full_path: String in collection_scene_full_paths_array:
				create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
		#if post_create_buttons_array:
			#for scene_full_path: String in post_create_buttons_array:
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)



		if collection_queue.size() > 0:
			if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			emit_signal("process_next_collection")

		if debug: print("FINISHED PROCESSING: ", collection_name.to_snake_case())
		processed_collections.append(collection_name.to_snake_case())

	if collection_queue.size() > 0:
		if debug: print("Finished processing project scenes, emitting signal to start processing collections.")
		emit_signal("process_next_collection")


	# Reset flag when finished to allow next collection to be processed
	processing_collection = false
	# After all collections have been loaded then check filesystem for .tres material files
	if collection_queue.size() == 0:
		collect_standard_material_3d("res://")
		# initialize filtering if collections open
		#new_main_project_scenes_tab.get_scene_buttons()
		call_deferred("emit_initialize_filters")
#
func emit_initialize_filters() -> void:
	 #HACK
	#await get_tree().create_timer(5).timeout
	#print("begin filter")
	# await visible buttons for active collection tab
	new_main_project_scenes_tab.get_scene_buttons()
	#emit_signal("initialize_filters")


# FIXME Crashing on large collections NOTE: Think fixed by adding timer between this and load_gltf_scene_instance()

# FIXME Issue where scenes saved within the collections folder not in a subtab named folder and emitting finished_collection_chunks

## In chunks by CPU thread count find the minimum number of scenes that need to be imported to get all the textures and materials from the collection. While also generating thumbnails.
func multi_threaded_chunk_process(imported_textures_path: String, collection_name: String, initial_import: bool, new_sub_collection_tab: Control, new_scene_view: Button) -> void:
	if debug: print("Starting multi-thread chunk processing for: ", collection_name)
	var processed_scene_count: int = 0
	var first_chunk: bool = true
	var chunk_size: int = 12

## FIXME CHANGE CHUNK SIZE TO MATCH PROCESSOR CORE SIZE? TEST 
	if OS.get_processor_count() > 0:
		chunk_size = OS.get_processor_count()

	if debug: print("collection_scene_full_paths_array size START: ", collection_scene_full_paths_array.size())
	for i in range(0, collection_scene_full_paths_array.size(), chunk_size):
		
		if debug: print("i: ", i)
		var chunk: Array[String] = collection_scene_full_paths_array.slice(i, i + chunk_size)
		#if debug: print("chunk size: ", chunk.size())

		#mutex.lock()
		#var chunk_lookup: Dictionary[String, Node] = {}
		#mutex.unlock()
		# FIXME Crashing after printing i and before printing starting next chunk for collection so assume related to the timer?
		# NOTE: 0.1 seems to be a good amout of time for system to free VRAM
		#await get_tree().create_timer(0.3).timeout # Seems system needs time to release VRAM TODO PLAY WITH TIME MORE TO SEE IF LARGER TIME FREES MORE MEMORY?
		#await get_tree().create_timer(1).timeout 
		# NOTE: Second collection getting stuck here or during multi-thread on first chunk.
		if debug: print("starting next chunk for collection: ", collection_name)

# FIXME NOT RELEASING VRAM AS MUCH AS I WOULD LIKE KEEP BELOW 4 GB
		#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, chunk, initial_import), chunk.size())
		#await finished_processing_collection
		#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing, chunk.size())
		task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(chunk), chunk.size())
		await finished_image_hashing
		if not WorkerThreadPool.is_group_task_completed(task_id2):
			WorkerThreadPool.wait_for_group_task_completion(task_id2)
		#await get_tree().process_frame
		#await get_tree().create_timer(0.5).timeout
		#if debug: print("finished chunk hash")

		if debug: print("finished next chunk for collection: ", collection_name)

		###collection_lookup[collection_name] = chunk_lookup
		###if debug: print("collection_lookup[collection_name] size: ", collection_lookup[collection_name].size())
		mutex.lock()
		collection_lookup[collection_name.to_snake_case()] = scene_lookup#.duplicate()
		mutex.unlock()
		#collection_lookup.clear()
		#scene_lookup.clear()

		for scene_full_path: String in chunk:
			processed_scene_count += 1
			#load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			################################################################################
			## NOTE: ENABLE FOR FINAL PROCESS STEP
			var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
			mutex.lock()
			if not user_dir.file_exists(thumbnail_cache_path):
				if scene_lookup.keys().has(scene_full_path) and is_instance_valid(scene_lookup[scene_full_path]):
					# NOTE: THIS IS BLOCKING SCENE .IMPORT LATER IN THE PROCESS WHY? HOW TO FIX?
					create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
					
				else:
					push_warning("the scene path: ", scene_full_path, "could not be found within the scene lookup table. The thumbnail may not have been generated.")
			# Clear generated nodes from last chunk from memory

			if scene_lookup.keys().has(scene_full_path) and scene_lookup[scene_full_path] is Node:
				scene_lookup[scene_full_path].queue_free()

			mutex.unlock()
			#await get_tree().process_frame
		
			
			

		#collection_lookup.clear()
		#scene_lookup.clear()





			## HACK To release memory
			#mutex.lock()
			#var gltf_state: GLTFState = gltf_state_lookup[scene_full_path]
#
			#gltf_state.images.clear()
			#gltf_state.materials.clear()
			#gltf_state.meshes.clear()
			#gltf_state.nodes.clear()
			#gltf_state.skins.clear()
			#gltf_state.animations.clear()
			#gltf_state.accessors.clear()
			#gltf_state.buffer_views.clear()
			#gltf_state.buffers.clear()
			#gltf_state.cameras.clear()
			#gltf_state.textures.clear()
			#gltf_state.lights.clear()
#
			#gltf_state = null
#
			#mutex.unlock()







			
			
			
			
			
			
			
			
#
		#mutex.lock()
		#collection_lookup[collection_name.to_snake_case()].clear()
		#mutex.unlock()

		#collection_lookup.clear()
		#scene_lookup.clear()
		#chunk.clear()






	if debug: print("processed_scene_count: ", processed_scene_count)
	if debug: print("collection_scene_full_paths_array.size(): ", collection_scene_full_paths_array.size())
	if processed_scene_count == collection_scene_full_paths_array.size():
		#scene_lookup.clear()
		emit_signal("finished_collection_chunks")


#func safe_parse_glb(file_bytes: PackedByteArray, scene_full_path: String) -> GLTFState:
	#var gltf_state := GLTFState.new()
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
	#var error = gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
	#if error != OK:
		#push_error("Failed to parse GLB: " + scene_full_path)
		#return null
	#return gltf_state


## TEST MOD
#func multi_threaded_gltf_image_hashing(index: int, collection_name: String, new_sub_collection_tab: Control, chunk: Array[String]) -> void:
	#var scene_full_path: String = chunk[index]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file == null:
		#push_error("Could not open file: " + scene_full_path)
		#return
#
	#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
	#scene_file.close()
#
	#var gltf_state := GLTFState.new()
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
	#if gltf.append_from_buffer(file_bytes, "", gltf_state, 8) != OK:
		#push_error("Failed to parse GLB: " + scene_full_path)
		#return
#
	#mutex.lock()
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	#mutex.unlock()
#
	#var json_data = gltf_state.get_json()
	#_process_gltf_metadata(json_data, scene_full_path)
#
	## Schedule thumbnail creation + memory management on the main thread
	#call_deferred("_finalize_scene_processing", scene_full_path, collection_name, new_sub_collection_tab)
#
#func _finalize_scene_processing(scene_full_path: String, collection_name: String, new_sub_collection_tab: Control) -> void:
	#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
#
	#if not user_dir.file_exists(thumbnail_cache_path):
		#create_scene_buttons(scene_full_path, new_sub_collection_tab, null, false)
#
	## Explicit cleanup
	#mutex.lock()
	#if scene_lookup.has(scene_full_path):
		#scene_lookup[scene_full_path].free()
		#scene_lookup.erase(scene_full_path)
	#mutex.unlock()
#
	## Give time for memory cleanup
	#await get_tree().create_timer(0.3).timeout
#
#func _process_gltf_metadata(json_data: Dictionary, scene_full_path: String) -> void:
	#if json_data.has("images"):
		#for image_entry: Dictionary in json_data["images"]:
			#var image_name: String = image_entry.get("name", "")
			#mutex.lock()
			#if image_name != "" and not collection_images.has(image_name):
				#collection_images.append(image_name)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if json_data.has("materials"):
		#for material_entry: Dictionary in json_data["materials"]:
			#var material_name: String = material_entry.get("name", "")
			#mutex.lock()
			#if material_name != "" and not collection_materials.has(material_name):
				#collection_materials.append(material_name)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()




# NOTE: MODIFIED FOR CHUNKING
## NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, chunk_lookup: Dictionary[String, Node], chunk: Array[String]) -> void:
#func multi_threaded_gltf_image_hashing(index: int, collection_name: String, new_sub_collection_tab: Control, chunk: Array[String]) -> void:
# FIXME Sometimes not catching all required scenes or it is and they are just not being imported?
# ERROR: Cannot open file 'res://collections/glb/textures/M_FX_Base.tres'.
# ERROR: Cannot open file 'res://collections/glb/textures/M_Portal.tres'.
# ERROR: Cannot open file 'res://collections/glb/textures/M_Gold.tres'.
# And they are not visible in project filesystem so definitly not imported
## Find the minimum number of scenes that need to be imported to get all the textures and materials from the collection.
func multi_threaded_gltf_image_hashing(index: int, chunk: Array[String]) -> void:
	# Wait until a thread slot is available
	#gltf_semaphore.wait()
	#await get_tree().create_timer(0.3).timeout
	#var gltf_states: Array[GLTFState]
	var scene_full_path: String = chunk[index]
	#mutex.lock()
	#scene_lookup[scene_full_path] = null
	#mutex.unlock()
	#if debug: print("scene_full_path: ", scene_full_path)


	#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
#if not user_dir.file_exists(thumbnail_cache_path):


	#var gltf_state: GLTFState = GLTFState.new()
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)

	#gltf_state_mutex.lock()
	#gltf_state_lookup[scene_full_path] = gltf_state
	#gltf_state_mutex.unlock()


	#gltf_state_mutex.lock()
	##if not gltf_state_array.has(gltf_state):
		##gltf_state_array.append(gltf_state)
	#gltf_state_lookup[scene_full_path] = gltf_state
	#gltf_state_mutex.unlock()
	
	# Add assumption that if thumbnail exists then scene has been parsed and can skip
	
	
	#var scene_full_path: String = paths_for_this_task[index]
	#if debug: print("scene_full_path: ", scene_full_path)

	var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	if scene_file == null:
		push_error("Could not open file: " + scene_full_path)
		return
	else:
		
		
		
	#if scene_file:
		#if debug: print("scene_file exists")
		var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		scene_file.close()

		#mutex.lock()
		

		var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new()) # NOTE: Will ERROR If inside threaded function 

		var gltf_state := GLTFState.new()
		# NOTE: When HANDLE_BINARY_EMBED_AS_BASISU causes issue with thumbnail genration? Why?
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
		#gltf_semaphore.wait()
		#mutex.lock()
		if gltf.append_from_buffer(file_bytes, "", gltf_state, 8) == OK:
			#gltf_semaphore.wait()
			#mutex.lock()
			#gltf_state_lookup[scene_full_path] = gltf_state
			#mutex.unlock()
			#gltf_semaphore.post()
			#if debug: print("hello")
			#mutex.lock()
			#gltf_semaphore.wait()
			mutex.lock()
			scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			#collection_lookup[collection_name.to_snake_case()] = scene_lookup
			mutex.unlock()
			##gltf_semaphore.post()
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, null, false)
			#if debug: print("hello")
			##await get_tree().process_frame
			##await get_tree().create_timer(0.1).timeout
			#scene_lookup[scene_full_path].free()
			#scene_lookup.erase(scene_full_path)
			#scene_lookup.clear()
			#collection_lookup.clear()
			#collection_lookup.clear()
			#await get_tree().process_frame
			#await get_tree().create_timer(0.1).timeout
			#push_error("Failed to parse GLB: " + scene_full_path)
		else:
			if debug: print("append_from_buffer not OK")
		#gltf_semaphore.post()
		#mutex.lock()
		#gltf_states.append(gltf_state)
		#mutex.unlock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#
#
#
#
		##mutex.lock()
		#collection_lookup[collection_name.to_snake_case()] = scene_lookup
		##mutex.unlock()
		###collection_lookup.clear()
		###scene_lookup.clear()
##
		###for scene_full_path: String in chunk:
			###processed_scene_count += 1
			###load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##################################################################################
			#### NOTE: ENABLE FOR FINAL PROCESS STEP
		#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
		#if not user_dir.file_exists(thumbnail_cache_path):
			##var new_scene_view: Button = null
			##gltf_semaphore.wait()
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, null, false)
			##gltf_semaphore.post()
		##mutex.lock()
		##scene_lookup[scene_full_path].queue_free()
		#scene_lookup[scene_full_path].free()
		#
		##await get_tree().process_frame
		#await get_tree().create_timer(0.3).timeout
		##mutex.unlock()
#
#
		#mutex.unlock()
		#gltf_semaphore.post()
		##var error = gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##if error != OK:
			##push_error("Failed to parse GLB: " + scene_full_path)
#
#
#
		##var gltf_state: GLTFState = safe_parse_glb(file_bytes, scene_full_path)
#
		##if gltf_state != null:
		##var gltf_state: GLTFState = GLTFState.new()
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
##
		##gltf_state_mutex.lock()
		##gltf_state_lookup[scene_full_path] = gltf_state
		##gltf_state_mutex.unlock()
#
#
		##gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
#
		# FIXME ALSO NEED UNQUE MATERIAL SCENES PROCESSED
		var json_data = gltf_state.get_json()
		#if debug: print("json_data: ", json_data)
		if json_data.has("images"):
			#if debug: print("json_data[images]: ", json_data["images"])
			for image_entry: Dictionary in json_data["images"]:
				if image_entry.has("name"):
					#if debug: print("image_entry[name]: ", image_entry["name"])
					mutex.lock()
					var image_name: String = image_entry["name"]
					#if image_name.is_empty():
						#if debug: print("the image has no name")
					
					if not collection_images.has(image_name):
						collection_images.append(image_name)
						if not process_single_threaded_list.has(scene_full_path):
							process_single_threaded_list.append(scene_full_path)
					mutex.unlock()
				else: # If there is no "name" entry for "images" in the json file then process it
					mutex.lock()
					if not process_single_threaded_list.has(scene_full_path):
						process_single_threaded_list.append(scene_full_path)
					mutex.unlock()
					#if debug: print("the image has no name")


		if json_data.has("materials"):
			#if debug: print("json_data[images]: ", json_data["images"])
			for material_entry: Dictionary in json_data["materials"]:
				if material_entry.has("name"):
					#if debug: print("material_entry[name]: ", material_entry["name"])
					mutex.lock()
					var material_name: String = material_entry["name"]
					#if material_name.is_empty():
						#if debug: print("the material has no name")
					
					if not collection_materials.has(material_name):
						collection_materials.append(material_name)
						if not process_single_threaded_list.has(scene_full_path):
							process_single_threaded_list.append(scene_full_path)
					mutex.unlock()
				else: # If there is no "name" entry for "materials" in the json file then process it
					mutex.lock()
					if not process_single_threaded_list.has(scene_full_path):
						process_single_threaded_list.append(scene_full_path)
					mutex.unlock()
	
		mutex.lock()
		mesh_tag_import = false # Set flag to not import mesh tags again in multi_threaded_load_gltf_scene_instances()
		call_thread_safe("import_mesh_tags", gltf_state, scene_full_path)
		#import_mesh_tags(gltf_state, scene_full_path)
		mutex.unlock()
	
	
	
	
	#
			##mutex.lock()
			##scene_lookup[scene_full_path].clear
			##mutex.unlock()
			##mutex.lock()
			##gltf_state.images.clear()
			##gltf_state.materials.clear()
			##gltf_state.meshes.clear()
			##gltf_state.nodes.clear()
			##gltf_state.skins.clear()
			##gltf_state.animations.clear()
			##gltf_state.accessors.clear()
			##gltf_state.buffer_views.clear()
			##gltf_state.buffers.clear()
			##gltf_state.cameras.clear()
			##gltf_state.textures.clear()
			##gltf_state.lights.clear()
			##gltf_state = null
			##mutex.unlock()
	#
	#
			######collection_lookup[collection_name] = chunk_lookup
			######if debug: print("collection_lookup[collection_name] size: ", collection_lookup[collection_name].size())
			##mutex.lock()
			##collection_lookup[collection_name.to_snake_case()] = scene_lookup
			###mutex.unlock()
			####collection_lookup.clear()
			####scene_lookup.clear()
	###
			####for scene_full_path: String in chunk:
				####processed_scene_count += 1
				####load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
				###################################################################################
				##### NOTE: ENABLE FOR FINAL PROCESS STEP
			##var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
			##if not user_dir.file_exists(thumbnail_cache_path):
				###var new_scene_view: Button = null
				##gltf_semaphore.wait()
				##create_scene_buttons(scene_full_path, new_sub_collection_tab, null, false)
				##gltf_semaphore.post()
			###mutex.lock()
			###scene_lookup[scene_full_path].queue_free()
			##scene_lookup[scene_full_path].free()
			##
			###await get_tree().process_frame
			##await get_tree().create_timer(0.3).timeout
			##mutex.unlock()
	#
		## Free up the semaphore slot
		##gltf_semaphore.post()
	#
	## TODO Add support for Unique Animation chekcing to schedule import here






	#if debug: print("index: ", index)
	#if debug: print("chunk.size(): ", chunk.size())
	mutex.lock()
	#if not scene_lookup.keys().has(scene_full_path):
		#scene_lookup[scene_full_path] = Node.new()
	if index == chunk.size() - 1:
		call_deferred("deferred_emit_signal")
	mutex.unlock()


func deferred_emit_signal() -> void:
	if debug: print("Finished processing collection")
	emit_signal("finished_image_hashing")






# NOTE ORIGINAL WORKS BUT NEED TO ADJUST FOR CHUNKING
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
	##if debug: print("scene_full_path: ", scene_full_path)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
#
		## FIXME ALSO NEED UNQUE MATERIAL SCENES PROCESSED
		#var json_data = gltf_state.get_json()
		#if json_data.has("images"):
			##if debug: print("json_data[images]: ", json_data["images"])
			#for image_entry: Dictionary in json_data["images"]:
				#if image_entry.has("name"):
					##if debug: print("image_entry[name]: ", image_entry["name"])
					#mutex.lock()
					#var image_name: String = image_entry["name"]
					##if image_name.is_empty():
						##if debug: print("the image has no name")
					#
					#if not collection_images.has(image_name):
						#collection_images.append(image_name)
						#if not process_single_threaded_list.has(scene_full_path):
							#process_single_threaded_list.append(scene_full_path)
					#mutex.unlock()
				#else: # If there is no "name" entry for "images" in the json file then process it
					#mutex.lock()
					#if not process_single_threaded_list.has(scene_full_path):
						#process_single_threaded_list.append(scene_full_path)
					#mutex.unlock()
					##if debug: print("the image has no name")
#
#
		#if json_data.has("materials"):
			##if debug: print("json_data[images]: ", json_data["images"])
			#for material_entry: Dictionary in json_data["materials"]:
				#if material_entry.has("name"):
					##if debug: print("material_entry[name]: ", material_entry["name"])
					#mutex.lock()
					#var material_name: String = material_entry["name"]
					##if material_name.is_empty():
						##if debug: print("the material has no name")
					#
					#if not collection_materials.has(material_name):
						#collection_materials.append(material_name)
						#if not process_single_threaded_list.has(scene_full_path):
							#process_single_threaded_list.append(scene_full_path)
					#mutex.unlock()
				#else: # If there is no "name" entry for "materials" in the json file then process it
					#mutex.lock()
					#if not process_single_threaded_list.has(scene_full_path):
						#process_single_threaded_list.append(scene_full_path)
					#mutex.unlock()
#
#
#
#
#
#
#
		#
		#
		#
		#
		#
		#
		##for texture: Texture2D in gltf_state.get_images():
			###if debug: print("image get_size(): ", texture["name"])
			##var image: Image = texture.get_image()
			###if debug: print("image get_size(): ", image[name])
			##var image_bytes: PackedByteArray = image.get_data()
			##var image_hash: int = hash(image_bytes)
##
			##mutex.lock()
			##if not collection_hased_images.has(image_hash):
				##collection_hased_images.append(image_hash)
				##if not process_single_threaded_list.has(scene_full_path):
					##process_single_threaded_list.append(scene_full_path)
			##mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")







## Initial single threaded loading of scenes with textures to import to filesystem
# This runs on main thread and is blocking run on single background thread?
# FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
# FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:

var gltf_state_array: Array[GLTFState] = []


## From the minimum number of scenes found from multi_threaded_gltf_image_hashing() bring the textures and materials into the filesystem single threaded
#func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String, collection_name: String) -> void:
func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String, free_scene: bool = false) -> Node:
	var gltf_scene: Node
	var gltf_state: GLTFState = GLTFState.new()
	
	# FIXME POSSIBLE BOOST IN INTIAL LOAD SPEED TEST IT
	if not file_bytes_lookup.is_empty():
		pass
		#gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	else:
		var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		if scene_file:
			var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			scene_file.close()

			gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
			#EditorInterface.get_resource_filesystem().scan()
			#await get_tree().process_frame
			
			## NOTE: HACK Need to generate_scene to push editor to import the textures to the filesystem. Seems to work better then manually through gdscript
			gltf_scene = gltf.generate_scene(gltf_state)
			#EditorInterface.get_resource_filesystem().scan()
			#await get_tree().create_timer(1).timeout
			if free_scene:
				gltf_scene.queue_free()
			##gltf_scene = gltf.generate_scene(gltf_state)
			#gltf_state_array.append(gltf_state)
			#EditorInterface.get_resource_filesystem().scan()
			#while EditorInterface.get_resource_filesystem().is_scanning():
				#await get_tree().process_frame
##
			# TODO Create material save path lookup tied to scene_full_path
			# NOTE: This will not get all scenes.
			for material in gltf_state.materials:
				if material is Material:
					#if debug: print("Found material:", material)
					# Save it if needed
					var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
					ResourceSaver.save(material, save_path)
					#await get_tree().process_frame
					
			#gltf_scene.queue_free()
	return gltf_scene


			#await get_tree().process_frame
			#var loaded_material = load(save_path)
			#if loaded_material is BaseMaterial3D:
#
				#if not material_lookup.has(scene_full_path):
					#material_lookup[scene_full_path] = []
#
## FIXME Does not contain scenes within the project need another separate solution for that. TODO just add project scenes into this when doing collect_standard_material_3d?
				#if not material_lookup[scene_full_path].has(loaded_material):
					#material_lookup[scene_full_path].append(loaded_material)









	#mutex.lock()
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	#mutex.unlock()




func multi_threaded_populate_material_lookup(index: int, imported_textures_path: String, gltf_state_lookup: Dictionary[String, GLTFState]) -> void:

	gltf_state_mutex.lock()
	var scene_full_path: String = gltf_state_lookup.keys()[index]
	#mutex.lock()
	
	#for gltf_state: GLTFState in gltf_state_lookup[scene_full_path]:
	for material: BaseMaterial3D in gltf_state_lookup[scene_full_path].materials:
		#if material is Material:
		var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
		var loaded_material = load(save_path)
		if loaded_material is BaseMaterial3D:
			if not material_lookup.has(scene_full_path):
				material_lookup[scene_full_path] = []

# FIXME Does not contain scenes within the project need another separate solution for that. TODO just add project scenes into this when doing collect_standard_material_3d?
			if not material_lookup[scene_full_path].has(loaded_material):
				material_lookup[scene_full_path].append(loaded_material)

	gltf_state_mutex.unlock()
	#mutex.unlock()


#var gltf_state: GLTFState = GLTFState.new()
# WORKS
# NOTE 1:10 to load ~ 1200 Synty assets
## Multi-threaded loading of scenes that already have textures imported to the collections textures folder
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
# NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 

# NOTE: Is there a way to know if it will write to the filesystem and before it does switch to single threaded?
# NOTE: Or run a pre-pass with something like a try and just record or keep track of what will be written to disk and then do that single threaded? 

	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EXTRACT_TEXTURES)
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)

# COMPACT
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, chunk_lookup: Dictionary[String, Node], chunk: Array[String]) -> void:
	#var scene_full_path: String = chunk[index]
func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, collection_scene_full_paths_array: Array[String]) -> void:
	var scene_full_path: String = collection_scene_full_paths_array[index]
	var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	if scene_file:
		var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		scene_file.close()
		
		#mutex.lock()
		var gltf: GLTFDocument = GLTFDocument.new()
		var gltf_state: GLTFState = GLTFState.new()
		# Required because with large collections with unnamed textures godot's built in append_from_buffer function will attempt to re copy to filesystem
		gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)

		if gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8) != OK:
			push_error("Failed to load GLTF: %s" % scene_full_path)
			#mutex.unlock()
			return

		mutex.lock()
		if is_instance_valid(gltf_state) and gltf_state.materials != null:
			for material in gltf_state.materials:
				if material is Material:
					var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
					var loaded_material = load(save_path)
					if loaded_material is BaseMaterial3D:
						if not material_lookup.has(scene_full_path):
							material_lookup[scene_full_path] = []
						if not material_lookup[scene_full_path].has(loaded_material):
							material_lookup[scene_full_path].append(loaded_material)

		scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)

		if mesh_tag_import:
			pass
			#call_thread_safe("import_mesh_tags", gltf_state, scene_full_path)
		import_mesh_tags(gltf_state, scene_full_path)

		#var tags: Array[String]
		#var shared_tags: Array[String]
		#var global_tags: Array[String]
#
		## NOTE: Since this happens after scene_view_buttons are created tags imported here will not be visible until after restart
		## TODO: Either run same code during initial import multi_threaded_gltf_image_hashing() or check dif of current update_scene_data_tags_cache 
		## and recreate dif scene_view_buttons?
		#for node in gltf_state.get_json()["nodes"]:
			#if node.has("extras") and node["extras"].has("global_tags") and not node["extras"]["global_tags"].is_empty():
				#var encrypted_json_global_tags = node["extras"]["global_tags"]
#
				#for encrypted_tag in encrypted_json_global_tags.keys():
					#var encrypted_tag_string = encrypted_json_global_tags[encrypted_tag]  # This is a string like "[6, 197, 85, ...]"
					#var tag_array = JSON.parse_string(encrypted_tag_string)
					#if typeof(tag_array) == TYPE_ARRAY:
						#var pba := PackedByteArray()
						#for byte in tag_array:
							#pba.append(byte)
						#var decrypted_json_global_tag: PackedStringArray = global_tags_aes_decryption(pba)
						#print("Decrypted tag:", decrypted_json_global_tag)
						#tags.append_array(decrypted_json_global_tag)
						#global_tags.append_array(decrypted_json_global_tag)
#
			#if node.has("extras") and node["extras"].has("shared_tags") and not node["extras"]["shared_tags"].is_empty():
				#var json_shared_tags = node["extras"]["shared_tags"]
				#print("shared tags: ", json_shared_tags)
				#tags.append_array(json_shared_tags)
				#shared_tags.append_array(json_shared_tags)
#
			## Need to store in cache to get back later when scene_view_buttons created. Otherwise could skip cache and store directly
			## Load imported scene tags data into scene_data_cache 
			#if not tags.is_empty() or not shared_tags.is_empty() or not global_tags.is_empty():
				#update_scene_data_tags_cache(scene_full_path, tags, shared_tags, global_tags)






		#for node in gltf_state.json["nodes"]:
			#if node.has("extras"):
				#if node["extras"].has("global_tags"):
					##print("global tags: ", node["extras"]["global_tags"])
					#var packed_byte_array: PackedByteArray = node["extras"]["global_tags"] as PackedByteArray
					#print("global tags: ", global_tags_aes_decryption(packed_byte_array))
#
				#if node["extras"].has("shared_tags"):
					#print("shared tags: ", node["extras"]["shared_tags"])
				#print("Node extras:", node["extras"])



		#var json_string: String = gltf_state.json
		#if gltf_state.json["nodes"].has("extras"):
		#print("gltf_state.json: ", gltf_state.json["nodes"])
		#var data = JSON.parse_string(str(gltf_state.json))
		#print("data: ", data)


		#if is_instance_valid(gltf_state) and gltf_state.nodes != null:
			#for node in gltf_state.nodes:
				#if node.extras.has("global_tags"):
					#print("Global Tags:", node.extras["global_tags"])
				#print("extra: ", node["extras"])
			#print("gltf_state json: ", gltf_state.json)
#import_mesh_tags(scene, scene_view_button)



		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		if index == collection_scene_full_paths_array.size() -1:
			if debug: print("index has reached collection size")
			call_deferred("deferred_finished_processing_collection_signal", collection_name)
		mutex.unlock()




		#for material in gltf_state.materials:
			#if material is Material:
				#var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
				#var loaded_material = load(save_path)
				#if loaded_material is BaseMaterial3D:
					#if not material_lookup.has(scene_full_path):
						#material_lookup[scene_full_path] = []
					#if not material_lookup[scene_full_path].has(loaded_material):
						#material_lookup[scene_full_path].append(loaded_material)



# ORIGINAL
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, chunk_lookup: Dictionary[String, Node], chunk: Array[String]) -> void:
	#var scene_full_path: String = chunk[index]
	#var gltf_state: GLTFState = GLTFState.new()
	##gltf_state_mutex.lock()
	##gltf_state_lookup[scene_full_path] = gltf_state
	##gltf_state_mutex.unlock()
#
#
#
	##if debug: print("start state id: ", gltf_state.get_instance_id())
	##var state_id: int = gltf_state.get_instance_id()
	## TODO Create gltf_state lookup that links gltf_state to scene_full_path
	##var dict: Dictionary[String, GLTFState] = {}
	##dict[scene_full_path] = gltf_state
#
#
#
#
#
	#
	#
	#
	#
	###if not gltf_state_lookup.has(state_id):
		###gltf_state_lookup[state_id] = {}
	##
	##
	###gltf_state_lookup[state_id] = dict
	###gltf_state_lookup[state_id].append({
		###scene_full_path: gltf_state,
	###})
##
##
##
	##gltf_state_lookup[scene_full_path] = gltf_state
	###scene_full_path_lookup[gltf_state.get_instance_id()] = scene_full_path
	##
	##gltf_state_mutex.unlock()
	###gltf_state = GLTFState.new()
	#
	##if initial_import:
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
	#
	##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DEFERRED_WRITE)
	#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
	##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
	##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EXTRACT_TEXTURES)
	##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
	#
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##if debug: print("file_bytes: ", file_bytes.size())
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
		#scene_file.close()
#
		##mutex.lock()
		##call_deferred("deferred_call_thread_group", file_bytes, imported_textures_path, gltf_state)
		## FIXME Large collections with images with no name will reimport to filesystem here either crashing or throwing errors
		## How to fix?
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##mutex.unlock()
#
#
#
		### TODO Create material save path lookup tied to scene_full_path
		### NOTE: This will not get all scenes.
		### NOTE: I don't think we can use the loaded material here since it references what is in memory and not what is in the filesystem?
		### TODO Update for multi-surface meshes and new dictionary? or add to existing dictionary?
		##mutex.lock()
		##for material in gltf_state.materials:
			##if material is Material:
				###if debug: print("Found material:", material)
				### Save it if needed
				##var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
##
				##var loaded_material = load(save_path)
				##if loaded_material is StandardMaterial3D:
##
					###var material_id: int = loaded_material.get_instance_id()
					### Ensure the key exists in the dictionary before appending
					##if not material_lookup.has(loaded_material):
						##material_lookup[loaded_material] = []
					### add all the scenes(scene_full_path) that share the same material to the dictionary lookup
					##if not material_lookup[loaded_material].has(scene_full_path):
						##material_lookup[loaded_material].append(scene_full_path)
#
## FIXME Need way yo know which material is assigned to which surface and keep track in dict lookup
#
#
					##var material_id: int = loaded_material.get_instance_id()
					### Ensure the key exists in the dictionary before appending
					##if not material_lookup.has(material_id):
						##material_lookup[material_id] = []
					### Now it's safe to append the scene_full_path
					##material_lookup[material_id].append(scene_full_path)
#
#
## MODIFIED
		#mutex.lock()
		###var surface_count: int = 0
		##for material in gltf_state.materials:
			##
			##if material is Material:
				###if debug: print("Found material:", material)
				### Save it if needed
				##var save_path = imported_textures_path + "/" + material.resource_name + ".tres"
##
				##var loaded_material = load(save_path)
				##if loaded_material is BaseMaterial3D:
##
					###var material_id: int = loaded_material.get_instance_id()
					### Ensure the key exists in the dictionary before appending
					###if not material_lookup.has(loaded_material):
						###material_lookup[loaded_material] = []
						##
					##if not material_lookup.has(scene_full_path):
						##material_lookup[scene_full_path] = []
##
### FIXME Does not contain scenes within the project need another separate solution for that. TODO just add project scenes into this when doing collect_standard_material_3d?
					##if not material_lookup[scene_full_path].has(loaded_material):
						##material_lookup[scene_full_path].append(loaded_material)
#
#
#
#
					### Dictionary[int: resource
					##var surface_material_reference: Dictionary[int, Resource] = {}
					##surface_material_reference[surface_count] = loaded_material
#
					##if not material_lookup[scene_full_path].has(surface_material_reference):
						##material_lookup[scene_full_path].append(surface_material_reference)
					##if not material_lookup[loaded_material].has(scene_full_path):
						##material_lookup[loaded_material].append(scene_full_path)
					##surface_count += 1
#
#
#
#
#
#
		## NOTE: scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state) WILL BE MOVED UNTIL AFTER SINGLE THREADED IMAGE PARSING
		##mutex.lock()
		##states[scene_full_path] = gltf_state
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#if index == chunk.size() -1:
			#if debug: print("index has reached collection size")
			#call_deferred("deferred_finished_processing_collection_signal", collection_name)
		#mutex.unlock()
#
#
#
#
#
		##mutex.lock()
		##if initial_import:
			##chunk_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			##if chunk_lookup.size() == chunk.size(): # Works because chunk_lookup gets cleared every loop
##
				##if debug: print("index has reached collection size")
				##call_deferred("deferred_finished_processing_collection_signal")
##
		##else:
			##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			##if index == chunk.size() -1:
				##if debug: print("index has reached collection size")
				##call_deferred("deferred_finished_processing_collection_signal")
		##mutex.unlock()


func deferred_finished_processing_collection_signal(collection_name: String) -> void:
	if debug: print("collection import stack finished for collection: ", collection_name)
	emit_signal("finished_processing_collection", collection_name)


func deferred_call_thread_group(file_bytes, imported_textures_path, gltf_state) -> void:
	pass
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
	#mutex.lock()
#endregion



















	
	
	
	
	#var temp_dir = OS.get_temp_dir()
	#var dir_access = DirAccess.open(temp_dir)
	#var temp_file_path = dir_access.create_temp("gltf_data", "gltf")
	
	#var temp_file_path: String = FileAccess.create_temp(FileAccess.WRITE_READ, "hello", "png", true).get_path()
	#if debug: print("temp_file_path: ", temp_file_path)
	
	#gltf.append_from_buffer(file_bytes, temp_file_path, gltf_state, 8)
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
	#mutex.unlock()




## Can I run a pre-pass with something like a try and just record or keep track of what will be written to disk and then do that single threaded? 
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, chunk_lookup: Dictionary[String, Node], chunk: Array[String]) -> void:
	#var scene_full_path: String = chunk[index]
	#var gltf_state: GLTFState = GLTFState.new()
	#gltf_state_mutex.lock()
	#gltf_state_lookup[scene_full_path] = gltf_state
	#gltf_state_mutex.unlock()
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		#mutex.lock()
		##states[scene_full_path] = gltf_state
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#if index == chunk.size() -1:
			#if debug: print("index has reached collection size")
			#call_deferred("deferred_finished_processing_collection_signal")
		#mutex.unlock()











####VERSION 2
### FIXME the GLTFState will need to be stored in the array
### Delay generation of scenes until after single threaded texture import 
## TODO SINGLE THREADED CONVERT BACK TO USING EXTENSION (MULTI-THREADED) IF HEAVY CALCULATIONS LIKE CRYPTO HASHING 
#func _save_images_and_relink(imported_textures_path: String) -> void:
	#gltf_state_mutex.lock()
	#for scene_full_path: String in gltf_state_lookup.keys():
		#var texture_index: int = 0
		#var gltf_state: GLTFState = gltf_state_lookup[scene_full_path]
		##if debug: print("gltf_state: ", gltf_state)
#
		#
		#var json_data = gltf_state.get_json()
		#
		#var materials: Array[Material] = gltf_state.get_materials()
		##if debug: print("gltf_state.get_materials() size: ", gltf_state.get_materials().size())
		#for material: Material in materials:
			#pass
		#
		#if gltf_state.get_images().size() > 0:
			#var textures: Array[Texture2D] = gltf_state.get_images()
			#if debug: print("gltf_state.get_images() size: ", gltf_state.get_images().size())
			#for texture: Texture2D in textures:
				#var image = texture.get_image()
				##var image_save_path: String = imported_textures_path + "_" + "test_name" + ".png"
				##if debug: print("image_save_path: ", image_save_path)
				### FIXME This will need to be disabled to allow updated .glb textures to be updated 
				### FIXME by disabling will overwrite all textures not just the changed ones engine does hash so maybe required here?
				##if not res_dir.file_exists(image_save_path): 
					##
					##if texture.get_image().save_png(image_save_path) != OK:
						##push_error("png was not saved to: ", image_save_path)
#
#
#
#
#
#
#
#
#
#
		##parsed_images_mutex.lock()
		## Get the textures for this gltf_state
		##var state_id: int = gltf_state_lookup[scene_full_path].get_instance_id()
		### NOTE: _parse_image_data() will not fire for .glb files with no textures, so check is required to avoid "out of bounds errors".
		##if image_data_lookup.has(state_id): 
			##for image_data: PackedByteArray in image_data_lookup[state_id]:
				##if debug: print("image_data size: ", image_data.size())
				##if debug: print("imported_textures_path: ", imported_textures_path)
##
				##var image_save_path: String = imported_textures_path + "_" + "test_name" + ".png"
				### FIXME This will need to be disabled to allow updated .glb textures to be updated 
				### FIXME by disabling will overwrite all textures not just the changed ones engine does hash so maybe required here?
				##if not res_dir.file_exists(image_save_path): 
					##var image := Image.new()
					##
					##if image.load_png_from_buffer(image_data) != OK:
						##push_error("png could not be loaded from buffer.")
					##
					##if image.save_png(image_save_path) != OK:
						##push_error("png was not saved to: ", image_save_path)
##
		##parsed_images_mutex.unlock()
#
#
#
#
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state_lookup[scene_full_path])
		#mutex.unlock()
	#gltf_state_mutex.unlock()






###VERSION 1 USES EXTENSION
### FIXME the GLTFState will need to be stored in the array
### Delay generation of scenes until after single threaded texture import 
## FIXME Add signal when loop complete
#func _save_images_and_relink(imported_textures_path: String, imported_materials_path: String) -> void:
	#gltf_state_mutex.lock()
	##var index_to_texture_path_array: Array[Dictionary] = []
	#var index_to_texture_path_map: Dictionary[int, Dictionary] = {}
	#
	##var image_ids: Dictionary[int, Image] = {}
	#var scene_index: int = 0
	#for scene_full_path: String in gltf_state_lookup.keys():
		#
		#var texture_index: int = 0
		#var gltf_state: GLTFState = gltf_state_lookup[scene_full_path]
		#var json_data = gltf_state.get_json()
		## Get the textures for this gltf_state
		#var state_id: int = gltf_state.get_instance_id()
		#var index_to_texture_path: Dictionary[int, String] = {}
		#
		#parsed_images_mutex.lock()
		## NOTE: _parse_image_data() will not fire for .glb files with no textures, so check is required to avoid "out of bounds errors".
		#if image_data_lookup.has(state_id):
			#var image_index: int = 0
			#for image_data: PackedByteArray in image_data_lookup[state_id]:
				##await get_tree().process_frame
			##for image_data: Image in image_data_lookup[state_id]:
				##if debug: print("image_data size: ", image_data.size())
				##if debug: print("imported_textures_path: ", imported_textures_path)
				##if debug: print("texture name: ", json_data["images"][texture_index]["name"])
				## FIXME ERROR: scene_viewer.gd:2606 - Invalid access of index '4' on a base object of type: 'Array'
				## FIXME after next run scene_viewer.gd:2607 - Invalid access of index '3' on a base object of type: 'Array'. with texture_index += 1 reduced 1 tab length
				#if json_data.has("images") and json_data["images"].size() >= texture_index + 1 and json_data["images"][texture_index].has("name"):
					#var texture_name: String = json_data["images"][texture_index]["name"]
					#
					##if debug: print("texture name: ", texture_name)
					##TODO add code for no name
#
					#var image_save_path: String = imported_textures_path + "_" + texture_name + ".png"
					## FIXME This will need to be disabled to allow updated .glb textures to be updated 
					## FIXME by disabling will overwrite all textures not just the changed ones engine does hash so maybe required here?
#
#
					##var image := Image.new()
					##
					##if image.load_png_from_buffer(image_data) != OK:
						##push_error("png could not be loaded from buffer.")
#
					##var texture = ImageTexture.new()
					##texture.create_from_image(image)
#
					##if not res_dir.file_exists(image_save_path): 
						##var image := Image.new()
						##
						##if image.load_png_from_buffer(image_data) != OK:
							##push_error("png could not be loaded from buffer.")
						##
						##if image.save_png(image_save_path) != OK:
							##push_error("png was not saved to: ", image_save_path)
#
					##var image := Image.new()
					##if image.load_png_from_buffer(image_data) != OK:
						##push_error("png could not be loaded from buffer.")
					##var texture = ImageTexture.new()
					##texture.create_from_image(image)
					#
#
					#index_to_texture_path[image_index] = image_save_path
					#
#
#
					#
#
					#if not res_dir.file_exists(image_save_path):
						#var image := Image.new()
						#
						#
						#if image.load_png_from_buffer(image_data) != OK:
							#push_error("png could not be loaded from buffer.")
						#
						##image_ids[image.get_instance_id()] = image
						#
						#if image.save_png(image_save_path) != OK:
							#push_error("png was not saved to: ", image_save_path)
						#
						##gltf_state.images[texture_index] = texture
						##gltf_state.textures[texture_index].src_image = texture_index
#
#
					#else:
						#if debug: print("Add link/unlink functionality here for updating textures from source .glb")
						##image = load(image_save_path)
						#
#
			###await get_tree().create_timer(5).timeout # FIXME images needed to be imported into filesystem before next loop runs
			##for image_data: PackedByteArray in image_data_lookup[state_id]:
				##if json_data.has("images") and json_data["images"].size() >= texture_index + 1 and json_data["images"][texture_index].has("name"):
					##var texture_name: String = json_data["images"][texture_index]["name"]
					##var image_save_path: String = imported_textures_path + "_" + texture_name + ".png"
					###else:
						###gltf_state.images[texture_index] = texture
						###gltf_state.textures[texture_index].src_image = texture_index
						#
						#
#
				#image_index += 1
				#texture_index += 1
#
			#for index in index_to_texture_path.keys():
				#var path = index_to_texture_path[index]
				#if debug: print("path: ", path)
				#var texture = load(path)
				#if texture is CompressedTexture2D:
					#gltf_state.images[index] = texture
					#
					## You must find the matching GLTFTexture and assign the index
					#if index < gltf_state.textures.size():
						#var gltf_texture: GLTFTexture = gltf_state.textures[index]
						#gltf_texture.src_image = index
#
#
#
				## Now apply textures to materials
				#for material in gltf_state.materials:
					#if material is StandardMaterial3D:
						## Example: Find the albedo texture index from the glTF texture array
						#if json_data.has("materials"):
							#var mat_idx = gltf_state.materials.find(material)
							#var mat_json = json_data["materials"][mat_idx]
							#
							#if mat_json.has("pbrMetallicRoughness"):
								#var pbr = mat_json["pbrMetallicRoughness"]
								#if pbr.has("baseColorTexture"):
									#var tex_idx = pbr["baseColorTexture"]["index"]
									#if tex_idx < gltf_state.textures.size():
										#var src_image_index = gltf_state.textures[tex_idx].src_image
										#if src_image_index < gltf_state.images.size():
											#var tex = gltf_state.images[src_image_index]
											#if tex:
												#material.albedo_texture = tex
#
#
#
#
#
#
			##for material: StandardMaterial3D in gltf_state.materials:
				##
				##emit_signal("do_file_copy", res_dir, origin_texture_full_path, project_textures_full_path)
#
#
#
			##for material in gltf_state.materials:
				##if material is StandardMaterial3D:
					### Optionally bind texture to material here
					##if 0 in gltf_state.images:
						##material.albedo_texture = gltf_state.images[0]
					##if 1 in gltf_state.images:
						##material.normal_texture = gltf_state.images[1]
#
#
#
#### FIXME Will need to be even for repeated textures so must happen outside if not res_dir.file_exists(image_save_path): 
#### But also don't want to duplicate each in memory so maybe also need to dedup by using if res_dir.file_exists(image_save_path): use this one
					##var texture: CompressedTexture2D = load(image_save_path)
					###var texture = ImageTexture.new()
					###texture.create_from_image(image)
##
					##gltf_state.images[texture_index] = texture
					##gltf_state.textures[texture_index].src_image = texture_index
					##gltf_state.materials[0].albedo_texture = texture
##
					####var material_index = 0  # Example material index
					####gltf_state.materials[material_index].albedo_texture_index = texture_index
					####if debug: print("gltf_state.materials: ", gltf_state.materials)
					###for material: StandardMaterial3D in gltf_state.materials:
						###if debug: print("gltf_state.materials: ", material._get_property_list())
#
#
#
#
#
#
#
					##if texture_index == 0:
						##gltf_state.materials[texture_index].normal_texture = texture
					##if texture_index == 1:
						##gltf_state.materials[texture_index].emission_texture = texture
					##if texture_index == 2:
						##gltf_state.materials[texture_index].albedo_texture = texture
#
#
					##gltf_state.materials["pbrMetallicRoughness"][material_index].index = texture_index
#
					###if debug: print("gltf_state images: ", gltf_state["images"])
					##var image_array: Array[Texture2D] = gltf_state.get_images()
					##for image: Texture2D in image_array:
						##if debug: print("image.get_size(): ", image.get_size())
#
#
## NOTE: Don't want to handle materials in extension because then they will not be in the preview. link .glb embeded material to textures in res:// dir
## and duplicate/copy materials from gltf_state to res://collections/"collection_name"/materials folder. Materials texture targets will remain the same ones in res:// dir. 
#
#
#
### Use json data to link to textures in res:// dir # 1: link embeded material to res:// texture and then Copy to materials folder TODO: check if copy is also linked to res:// version of textures. 
		##var material_array: Array[Material] = gltf_state.get_materials()
		##for material: Material in material_array:
			##if debug: print("material: ", material)
#
#
				#
		#parsed_images_mutex.unlock()
		#index_to_texture_path_map[scene_index] = index_to_texture_path
		#scene_index += 1
#
#
#
#
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state_lookup[scene_full_path])
		#mutex.unlock()
	#gltf_state_mutex.unlock()
#
#
#
#
#
#
#
	##if debug: print("index_to_texture_path_map: ", index_to_texture_path_map)
#
	##emit_signal("finished_image_import")
#
#
#
#
	##parsed_images_mutex.lock()
	##for data in image_data_lookup.keys(): # data is int of gltfstate id
##
		##var gltf_state: GLTFState
		##gltf_state_mutex.lock()
		##for scene_full_path: String in gltf_state_lookup[data].keys():
			##if debug: print("scene_full_path: ", scene_full_path)
			##gltf_state = gltf_state_lookup[data][scene_full_path]
			##
			##mutex.lock()
			##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			##mutex.unlock()
		##gltf_state_mutex.unlock()
#
#
#
#
#
		##gltf_state_lookup[scene_full_path] = gltf_state
		##gltf_state_mutex.lock()
		##var scene_full_path = scene_full_path_lookup[gltf_state.get_instance_id()]
		##gltf_state_mutex.unlock()
		##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
#
#
#
#
#
		#
		#
		#
	##for data in parsed_images:
		##var gltf_state: GLTFState = data["state"]
		##
		###if debug: print("state id: ", gltf_state.get_instance_id())
		##
##
##
##
##
##
##
		###
		##var image_data: PackedByteArray = data["image"]
		##if debug: print("image_data size: ", image_data.size())
		##
		##
		### NOTE: For each new state reset the index to 0 to get the matching name from json_data["images"] to path_join to imported_textures_path
		##imported_textures_path
		##
		####if debug: print("state read single threaded: ", state)
		###
		##var json_data = gltf_state.get_json()
		##if json_data.has("images"):
			##if debug: print("json_data[images]: ", json_data["images"])
			##for image_entry: Dictionary in json_data["images"]:
				##if image_entry.has("name"):
					##if debug: print("image_entry[name]: ", image_entry["name"])
##
##
##
##
##
			###for image_names: Array[String] in json_data["images"]["name"]:
				###if debug: print("image_names: ", image_names)
				###var image_name: String =  
		####await get_tree().process_frame
		###var image: Image
		###var err = image.load_png_from_buffer(image_data)
		###if err != OK:
			###return err
###
		###var image_save_path: String = "res://collections/test/textures/" + image_name + ".png"
		###image.save_png(image_save_path)
##
##
		###if json_data.has("images"):
			###var glb_image = json_data["images"][image_index]
###
			###var image_name = glb_image["name"] if glb_image.has("name") else "image_" + str(image_index)
			###if not collection_image_names.has(image_name):
				###collection_image_names.append(image_name)
###
				###var image_save_path: String = "res://collections/test/textures/" + image_name + ".png"
				###if not res_dir.file_exists(image_save_path):
####
					###var err = image.load_png_from_buffer(image_data)
					###if err != OK:
						###return err
###
					###image.save_png(image_save_path)
##
##
##
##
		##
		##
		##
		##
		##
		##
		##
		##if json_data.has("meshes"):
			##for mesh_dict: Dictionary in json_data["meshes"]:
				##if mesh_dict.has("name"):
					##if debug: print(mesh_dict["name"])
				##else:
					##if debug: print("data the mesh for this state has no name")
		##else:
			##if debug: print("data has no meshes")
		##
		###var image: Image = data["image"]
		###var path = "res://imported_textures/%s" % data["name"]
		###var file = ImageTexture.create_from_image(image)
		###ResourceSaver.save(file, path)
##
##
		##gltf_state_mutex.lock()
		##
		##var scene_full_path = scene_full_path_lookup[gltf_state.get_instance_id()]
		##gltf_state_mutex.unlock()
		##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
#
#
#
		### Replace the texture in the state with one that references the saved file
		##var tex := load(path)  # Will now be loaded as .stex or .res
		##state.textures[data["index"]].texture = tex
	##parsed_images_mutex.unlock()
#
#
#
	##var json_data = state.get_json()
	##if json_data.has("meshes"):
		##for mesh_dict: Dictionary in json_data["meshes"]:
			##if debug: print(mesh_dict["name"])
#
	##mutex.lock()
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	##mutex.unlock()





# TODO Add execption for .obj scene files if .obj return false
# FIXME Will not allow past on adding items, but if not using will break if user removes collection folder 
# Will just need to make clear in docs that if files are removed that clearing the thumbnails will retrigger the import and not use this
## Check if res:// textures contains .png files. Do not run image hash if .png exist
func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	if collection_textures_path == "res://collections/textures/":
		return false
	else:
		var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		var collection_textures: Array[String]
		collection_textures.assign(packed_collection_textures)
		collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")

		if collection_textures.size() > 0:
			return false

	return true


func wait_loop(task_id: int, wait_time: int, scenes_dir_path: String) -> void: 
	var wait_count: int = 0
	while not WorkerThreadPool.is_group_task_completed(task_id):
		await get_tree().process_frame
		wait_count += 1
		if debug: print("wait_count: ", wait_count)
		if wait_count > wait_time: # Consider a more robust timeout/error handling
			push_warning("Wait time exceded for: " + scenes_dir_path)
			break
	return
#endregion



#region Version 7 Multi-thread chunk WORKS FOR SMALLER COLLECTIONS, BUT NOT SO GOOD FOR LARGE SYNTY COLLECTION
#
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#
#
#
#var collection_scene_full_paths: Dictionary[String, Array] = {}
#var collection_scene_full_paths_array: Array[String] = []
#var collection_textures_paths: Dictionary[String, String] = {} 
##var current_sub_folder_name: String = ""
##var current_collection_name: String = ""
#
##var collection_processing_count: int = 0
##var collection_process_queue: Array[String] = []
#
##var collection_queue: Dictionary[int, Array] = {}
#var collection_queue: Array[Array] = [] 
#var collection_scenes_queue: Array[Array] = []
#var processing_collection: bool = false
#
##var collection_count: int = 0
#
##var current_collection_id: int = -1
#
#
### TEST
##func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##pass
#
## FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
## TODO Make single threaded import run on background thread
## TODO Display button textures during multi-threaded loading time
#
#
## NOTE: Called when:
## 1. create_main_collection_tabs()
## 2. _ready() for any open tabs at start
## 3. create_sub_collection_tabs() when openning new collection from list collection gets added to queue and signal runs process_collection()
#
#func add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control):
	#processing_collection = true
	#if debug: print("Starting import process for: ", collection_name)
	#
#
#
#
	#
	#
	##var info: Array = []
	##info.append(sub_folders_path)
	##info.append(new_sub_collection_tab)
	##collection_info[sub_folder_name] = info
	#
	#
	#var scenes_dir_path: String = sub_folders_path.path_join(collection_name)
	##push_error("scenes_dir_path: ", scenes_dir_path)
#
	## FIXME Setup signal for when finished
	#if scenes_dir_path == project_scenes_path:
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false # FIXME Maybe don't need?
#
	## This gets overwritten too so needs to be lower and have id with dic
	##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	##if collection_textures_path == "res://collections/textures/":
		##pass
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##run_gltf_image_hash_check = false
#
	## TODO can subfoldername can be used in place of collection_id
	## FIXME Using colleciton id issue is that if there is a gap between when this function is run the await finished_processing_collection is never
	## fired to allow it to progress past that point, await finished_processing_collection only works if there is a chain of collections openned at the same time
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		##collection_processing_count += 1
		##
		##var wait_count: int = 0
		##while collection_processing_count > 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				##break
#
#
#
#
		#cleanup_task_id1 = true
		##ran_task_id2 = true
		#var imported_textures_path: String
#
#
		##var gltf: GLTFDocument = GLTFDocument.new()
		##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
		##await get_tree().process_frame
		#await get_tree().create_timer(1).timeout
		#if debug: print("ext: ", gltf.get_supported_gltf_extensions())
#
		### 
		###var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		## Get the file paths to all the .png images within the res://collections/../textures folder
		#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].to_snake_case().path_join("textures".path_join("/")))
		#collection_textures_paths[collection_name] = collection_textures_path # NOTE: Not needed with now having queue and only one collection running through stack at a time
#
		## Get the file paths of all scenes in the collection and add them to an Array
		## FIXME A little off imported_textures_path calculated for every file when it remains the same? and run_gltf_image_hash_check() broken so maybe need above var collection_textures_path?
		##var collection_scene_full_paths_array: Array[String] = []
		## FIXME ALERT if collection_name the same then do not need to check thumbnail_cache_path and imported_textures_path
		#if debug: print("clearing collection_scene_full_paths_array for: ", collection_name)
		#collection_scene_full_paths_array = []
		##var thumbnail_cache: bool = false
		#var thumbnail_cache_path: String
		##var button_count: int = 0
		##var scene_full_path: String
		#
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path: String = scenes_dir_path.path_join(file_name)
				#
#
#
## FIXME CLEANUP TO ONLY SHOW THUMBNAILS AFTER FULLY LOADED AND DISABLE 360 ROTATION AND VIEWPORT SWITCHING ON BUTTON UNTIL PROCESSING FINISHED
				## TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
				#thumbnail_cache_path = get_thumbnail_cache_path(scene_full_path)
				#if user_dir.file_exists(thumbnail_cache_path):
					#
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
					##button_count += 1
					##if button_count == collection_scene_full_paths_array.size():
						##thumbnail_cache = true
						#
#
				#collection_scene_full_paths_array.append(scene_full_path)
#
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case().path_join("textures".path_join("/")))
				##imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		##await get_tree().create_timer(5).timeout # Add time for buttons to finish spawning
#
#
		### TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
		##for scene_full_path in collection_scene_full_paths_array:
			###await get_tree().process_frame
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
####  ALERT MAYBE NEEDED
		##if debug: print("imported_textures_path: ", imported_textures_path)
		##collection_scene_full_paths[collection_name] = collection_scene_full_paths_array.duplicate()
#
#
		##if collection_processing_count > 1: # Do not hold for first collection
			##if debug: print("Waiting to process ", collection_name, " collection")
			##await finished_processing_collection
			###await get_tree().process_frame
			##await get_tree().create_timer(5).timeout
			###if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		##if not imported_textures_path.is_empty():
		##if run_gltf_image_hash_check(imported_textures_path):
		#if debug: print("collection_scene_full_paths_array: ", collection_scene_full_paths_array)
## TEST skip and run direct multi-thread
		#if false:
		##if run_gltf_image_hash_check(collection_scene_full_paths_array):
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		#
			#
			#if collection_scene_full_paths_array.size() > 0:
			##if collection_scene_full_paths[collection_name].size() > 0:
				#cleanup_task_id2 = true
				##current_collection_name = collection_name # NOTE: To maintain same data through stack 
				#if debug: print("Starting image hashing and multi-threaded import stack for collection: ", collection_name)
				#mutex.lock()
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#mutex.unlock()
				##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths_array), collection_scene_full_paths_array.size())
#
				#if debug: print("waiting for image hashing to finish")
				##await wait_loop(task_id2, 10000, scenes_dir_path)
				#await finished_image_hashing
				#if debug: print("image hashing finished")
#
				##scene_loading_complete = true
				#
				#mutex.lock()
				#var process_single_threaded_list_duplicate: Array[String] = process_single_threaded_list.duplicate()
				#mutex.unlock()
## TEST Load all single threaded
				##for scene_full_path: String in collection_scene_full_paths_array:
## TEST
				#for scene_full_path: String in process_single_threaded_list_duplicate:
					##load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
					#load_gltf_scene_instance(scene_full_path, imported_textures_path)
#
#
				##if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
				##for file in collection_scene_full_paths_array:
				#for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
					#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
						#EditorInterface.get_resource_filesystem().update_file(file)
#
				#EditorInterface.get_resource_filesystem().scan()
#
				#await EditorInterface.get_resource_filesystem().resources_reimported # NOTE: This may need more time for collections with many textures?
				## FIXME dest_md5 must not be matching up for Carpenters-workshop collection appears to be reimporting after textures imported when multi-thread runs below.
				##if debug: print("reimport finished")
#
				#await get_tree().create_timer(60).timeout




				###FIXME Maybe more time needed here or something else ERROR: Can't find file 'res://collections/third/textures/_0.png' during file reimport.
				###await get_tree().create_timer(15).timeout
##
				###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
				##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
				##
				###await wait_loop(task_id1, 10000, scenes_dir_path)
				###var wait_count: int = 0
				###while not WorkerThreadPool.is_group_task_completed(task_id1):
					###await get_tree().process_frame
					###wait_count += 1
					###if wait_count > 10000: # Consider a more robust timeout/error handling
						###push_warning("Hashing task timed out for: " + scenes_dir_path)
						###break
##
				###emit_signal("finished_processing_collection")
##
##
		##else:
#
#
#
#
#
		##current_collection_name = collection_name # NOTE: To maintain same data through stack 
		##if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
		## TODO CHUNK PROCESS LARGE COLLECTIONS
		#var initial_import: bool = false
		#if run_gltf_image_hash_check(collection_textures_paths[collection_name]): # NOTE: If no textures exists in the project collections then it's a new collection 
			#initial_import = true
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
		## FIXME INTIAL IMPORT VRAM NOT RELEASED AND STUTTERS
		#if initial_import:
#
			### FIXME flag will get reset so need way to keep as initial import and loop through this section unto collection_scenes_queue empty
			##for i in range(0, collection_scene_full_paths_array.size(), 20):
				##var chunk = collection_scene_full_paths_array.slice(i, 20)
				###collection_scenes_queue.append(chunk)
				##if chunk.size() == 0:
					##return
			###var next_chunk = 0
			###if collection_scenes_queue.size() > 0:
				##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), chunk.size())
			##
				##await finished_processing_collection
			##
				##for scene_full_path: String in chunk:
					##var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
					##if user_dir.file_exists(thumbnail_cache_path):
						##thumbnail_cache = true
						##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
			#var path_split: PackedStringArray = thumbnail_cache_path.split("/")
			#var thumbnail_cache_dir: String = "user://" + path_split[2].path_join(path_split[3].path_join(path_split[4].path_join(path_split[5])))
###
			##if DirAccess.get_files_at(thumbnail_cache_dir).size() != collection_scene_full_paths_array.size(): # NOTE Brakes if multi_chunk_process not run
			##if not thumbnail_cache:
#
			##mutex.lock()
			##file_bytes_lookup.clear()
			##mutex.unlock()
#
#
			## NOTE: For creating thumbnails FIXME if import is interrupted then will need to delete files to retrigger thumbnail or not
			## NOTE: Only used to create thumbnails so if they exist then do not run
			#multi_threaded_chunk_process(imported_textures_path, collection_name, initial_import, new_sub_collection_tab, new_scene_view)
			#if debug: print("waiting for finished_collection_chunks signal")
			#await finished_collection_chunks
#
			## NOT awaiting as long as i want want until after all thumbnails generated
			##if debug: print("thumbnail_cache_path ", thumbnail_cache_path)
#
			##if debug: print("thumbnail_cache_path split: ", path_split)
			##
			##if debug: print("thumbnail_cache_path dir: ", thumbnail_cache_dir)
#
			#while DirAccess.get_files_at(thumbnail_cache_dir).size() != collection_scene_full_paths_array.size():
				#await get_tree().process_frame 
#
			#if debug: print("Finished multi-thread chunk processing for: ", collection_name)
#
			##else:
				##if debug: print("thumbnail cache size matches collection size skipping chunked scene loading for collection: ", collection_name)
#
#
### TEST Run entire stack in multi_threaded_chunk_process function
			#mutex.lock()
			##if debug: print("collection_lookup[collection_name] size before clear: ", collection_lookup[collection_name].size())
			##if debug: print("collection_lookup keys again: ", collection_lookup.keys())
#
			#collection_lookup[collection_name].clear()
			#
			### TEST do not reuse file_bytes_lookup
			##file_bytes_lookup.clear()
			##collection_lookup.clear()
			##scene_lookup.clear()
			#mutex.unlock()
#
#
#
## TEST Run entire stack in multi_threaded_chunk_process function
#
 ##FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
## NOTE:  MASSIVE BOTTLENECK NOT ONLY SINGLE THREADED BUT ALSO NEED 0.5 SEC FOR FILESYSTEM TO RECGNIZE AND IMPORT FILES!!
			### NOTE: For loading textures into filesystem single threaded
			##mutex.lock()
			#for scene_full_path: String in collection_scene_full_paths_array:
				## NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
				## NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
				##await get_tree().create_timer(0.5).timeout 
				##await get_tree().process_frame
				##await get_tree().process_frame
				#call_deferred("load_gltf_scene_instance_test", scene_full_path, imported_textures_path, collection_name)
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			#
			#mutex.lock()
			#collection_lookup[collection_name] = scene_lookup
			#mutex.unlock()
#
			##while collection_lookup[collection_name].size() != collection_scene_full_paths_array.size():
				##await get_tree().process_frame
#
#
#
#
#
 ##FIXME Intended purpose is to reload just like when reloading editor and drop VRAM but does not do that?
			##file_bytes_lookup.clear()
			##mutex.unlock()
#
			##await get_tree().create_timer(5).timeout 
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
			##await get_tree().process_frame
			#await get_tree().create_timer(5).timeout
			###await get_tree().create_timer(40).timeout 
			#if debug: print("running multi-threaded re-import for collection: ", collection_name)
			## NOTE: Reload scenes multi-threaded referencing imported filesystem textures found in collections folder
			#initial_import = false
			#var chunk_lookup: Dictionary[String, Node] = {} # Dummy Dict
			#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, collection_scene_full_paths_array, initial_import), collection_scene_full_paths_array.size())
			#if debug: print("Awaiting finish of multi-threaded re-import for collection: ", collection_name)
			#await finished_processing_collection
			#if debug: print("Finished multi-threaded re-import for collection: ", collection_name)
#
## TEST Run entire stack in multi_threaded_chunk_process function
#
			#mutex.lock()
			#collection_lookup[collection_name] = scene_lookup
			#mutex.unlock()
#
#
#
#
#
#
			### Create queue and process uncompressed based on set size maybe 10 run through stack without emitting process_next_collection % 20
			##if debug: print(OS.get_processor_count())
##
			##if collection_scene_full_paths_array.size() > 100:
				##pass
			##else:
				##if collection_scene_full_paths_array.size() >= 50: # FIXME Without VRAM and Texture sizes really no way to set this accordingly
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import, false), collection_scene_full_paths_array.size())
				##else: # collection_scene_full_paths_array.size() < 50:
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
				##await finished_processing_collection
#
#
#
#
#
#
		#else:
			## FIXME FIRST TIME AFTER INITIAL IMPORT CRASHES NOT SURE CAUSE? MAYBE SOMETHING TO DO WITH CREATING BUTTONS
			#await get_tree().process_frame # Seems to help with crashing on first start after initial import
			#if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
			#var chunk_lookup: Dictionary[String, Node] = {} # Dummy Dict # Check if can be put inside muti-thread
			#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, collection_scene_full_paths_array, initial_import), collection_scene_full_paths_array.size())
			#await finished_processing_collection
			#
			#mutex.lock()
			#collection_lookup[collection_name] = scene_lookup
			#mutex.unlock()
#
			##mutex.lock()
			##file_bytes_lookup.clear()
			##mutex.unlock()
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
#
		##await wait_loop(task_id1, 10000, scenes_dir_path)
		###var wait_count: int = 0
		###while not WorkerThreadPool.is_group_task_completed(task_id1):
			###await get_tree().process_frame
			###wait_count += 1
			###if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				###break
##
		###if debug: print("waiting for collection import stack to finish")
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###if debug: print("collection import stack finished")
		###call_deferred("deferred_finished_processing_collection_signal")
		##emit_signal("finished_processing_collection")
		###await get_tree().process_frame
##
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###call_deferred("deferred_finished_processing_collection_signal")
#
#
		### NOTE: WITH TWO COLLECTIONS THE FIRST WILL BE CREATING BUTTONS WHILE THE SECOND IS DOING MULTI-THREADED IMPORT IS THIS CAUSING CRASH?
		###if debug: print("Waiting for multi-threaded import for collection: ", current_sub_folder_name, " to finish.")
		##await finished_processing_collection
		#
#
		#
		##if debug: print("scene_lookup: ", scene_lookup.size())
		##if debug: print("finsihed waiting continuing process")
		##collection_processing_count -= 1 # Decrement count by 1 to allow collections opened after start to pass through import process
#
#
		##if not thumbnail_cache:
			##for scene_full_path in collection_scene_full_paths_array:
				###await get_tree().process_frame
				##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
### TEST NOTE: MAY WANT TO LEAVE IN BUT FIXME if not user_dir.file_exists(thumbnail_cache_path): NOT WORKING TO SEE IF FILE_EXISTS
		##while collection_lookup[collection_name].size() != collection_scene_full_paths_array.size():
			##await get_tree().process_frame
		##for scene_full_path in collection_scene_full_paths_array:
			##var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
			###if not user_dir.file_exists(thumbnail_cache_path):
				###var new_scene_view: Button = null
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
## NOTE: if implemented will want to run after all collections opened and will then need to have imported_textures_path in a lookup per collection 
#
#
#
#
#
#
#
### WORKS!!!!!!! Now single background thread loading
###TEST 1 loading in textures from mulit-threaded loaded .glb
		###if false:
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			##await get_tree().create_timer(5).timeout
			##mutex.lock()
			##for scene_full_path: String in scene_lookup.keys():
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			##mutex.unlock()
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 1 loading in textures from mulit-threaded loaded .glb
#
#
#
### FIXME NOTE Run here after each individual collection collection_scene_full_paths_array or after all on scene_lookup?
###TEST 2 loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			###initial_import = false # Set to import textures
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			###await get_tree().create_timer(5).timeout
			###mutex.lock()
			###for scene_full_path: String in scene_lookup.keys():
				###load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			###mutex.unlock()
##
##
### FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
			##await get_tree().create_timer(1).timeout
			###call_deferred("import_textures", collection_scene_full_paths_array, imported_textures_path)
			###call_thread_safe("import_textures", collection_scene_full_paths_array, imported_textures_path)
			##mutex.lock()
			##for scene_full_path: String in collection_scene_full_paths_array:
				###await get_tree().process_frame
				### NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
				### NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
				##await get_tree().create_timer(0.5).timeout 
				###var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
				####var wait_count: int = 0
				####while not WorkerThreadPool.is_task_completed(task):
					#####await get_tree().process_frame
					####await get_tree().create_timer(.1).timeout
					####wait_count += 1
					####if debug: print("wait_count: ", wait_count)
					####if wait_count > 100: # Consider a more robust timeout/error handling
						####push_warning("Wait time exceded for: " + scenes_dir_path)
						####break
				###WorkerThreadPool.wait_for_task_completion(task)
##
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##
			##file_bytes_lookup.clear()
			##mutex.unlock()
#
#
## FIXME CHECK IF NEEDED
## Reload scene buttons with lower vram
			##for button: Node in new_sub_collection_tab.h_flow_container.get_children():
				##if button and button is Button:
					##button.queue_free()
					#
#
#
			##for scene_view: Button in new_sub_collection_tab.h_flow_container.get_children():
				##scene_view.queue_free()
#
#
#
			##if not thumbnail_cache:
				##for scene_full_path in collection_scene_full_paths_array:
					###await get_tree().process_frame
					##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
			##mutex.lock()
			##for scene_full_path: String in collection_scene_full_paths_array:
				##await get_tree().process_frame
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##mutex.unlock()
#
#
#
#
#
			##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
#
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 2 loading in textures from mulit-threaded loaded .glb
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
		##await get_tree().process_frame
## FIXME FIXME  FIXME FIXME  FIXME FIXME 
		### NOTE: By this point there should be a thumbnail cache FIXME does not check for individual scene thumbnails so if initial import interrupted 
		### will not show all items? or if items added later on to collection?
		##if not thumbnail_cache:
			##for scene_full_path in collection_scene_full_paths_array:
				###await get_tree().process_frame
				##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
		#await get_tree().create_timer(5).timeout # NOTE: Add time between collections process
		#
		#if collection_queue.size() > 0:
			#if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			#emit_signal("process_next_collection")
		#processing_collection = false
#
	#if collection_name == "" and collection_queue.size() > 0:
		#if debug: print("Finished processing project scenes, emitting signal to start processing collections.")
		#emit_signal("process_next_collection")
		#processing_collection = false
#
#
#func multi_threaded_chunk_process(imported_textures_path: String, collection_name: String, initial_import: bool, new_sub_collection_tab: Control, new_scene_view: Button) -> void:
	#if debug: print("Starting multi-thread chunk processing for: ", collection_name)
	#var processed_scene_count: int = 0
	##var finished_chunks: bool = false
	#var first_chunk: bool = true
	#var chunk_size: int = 20
#
## FIXME CHANGE CHUNK SIZE TO MATCH PROCESSOR CORE SIZE? 
	#if OS.get_processor_count() > 0:
		#chunk_size = OS.get_processor_count()
#
	##if debug: print(OS.get_processor_count())
	#if debug: print("collection_scene_full_paths_array size START: ", collection_scene_full_paths_array.size())
	#for i in range(0, collection_scene_full_paths_array.size(), chunk_size):
		#
		#if debug: print("i: ", i)
		#var chunk: Array[String] = collection_scene_full_paths_array.slice(i, i + chunk_size)
		#if debug: print("chunk size: ", chunk.size())
#
		#mutex.lock()
		#var chunk_lookup: Dictionary[String, Node] = {}
		##scene_lookup.clear()
		##if collection_lookup.keys().has(collection_name):
			##collection_lookup[collection_name].clear()
			##if debug: print("collection_lookup keys: ", collection_lookup.keys())
		#mutex.unlock()
		##await get_tree().create_timer(1).timeout
		## NOTE: 0.1 seems to be a good amout of time for system to free VRAM
		#await get_tree().create_timer(0.1).timeout # Seems system needs time to release VRAM TODO PLAY WITH TIME MORE TO SEE IF LARGER TIME FREES MORE MEMORY?
		## NOTE: Second collection getting stuck here or during multi-thread on first chunk.
		#if debug: print("starting next chunk for collection: ", collection_name)
#
		##if chunk.size() < chunk_size:
			##finished_chunks = true
#
## FIXME NOT RELEASING VRAM AS MUCH AS I WOULD LIKE KEEP BELOW 4 GB
		#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk_lookup, chunk, initial_import), chunk.size())
	#
		#await finished_processing_collection
		##emit_finished = true # Reset flag for next chunk
		#if debug: print("finished next chunk for collection: ", collection_name)
#
		##mutex.lock()
		###if collection_lookup.keys().has(collection_name):
			###collection_lookup[collection_name].clear()
		##
##
		##while scene_lookup.size() != chunk.size():
			##if debug: print("scene_lookup.size() AFTER MULTI-THREADED: ", scene_lookup.size())
			##if debug: print("chunk.size(): ", chunk.size())
			###if debug: print("collection_lookup keys: ", collection_lookup.keys())
			##if debug: print("Waiting for collection_lookup[collection_name].size() to match chunk.size() for collection: ", collection_name)
			##await get_tree().process_frame
		##if debug: print("finished processing chunk")
		##mutex.unlock()
		#collection_lookup[collection_name] = chunk_lookup
		##collection_lookup[collection_name] = scene_lookup # Fill with just this chunks scene_lookup
		#if debug: print("collection_lookup[collection_name] size: ", collection_lookup[collection_name].size())
#
#
	## FIXME SOMETHING HAPPENING ON LAST CHUNK WHEN SMALLER THEN chunk_size. SEEMS TO BE PASSING THROUGH BEFORE scene_lookup FILLED SO ERROR WHEN create_scene_buttons CALLS get_camera_aabb_view
	## This was related to the await scene_lookup.clear() for the last collection while the next colleciton went through multi_threaded_load_gltf_scene_instances and started creating buttons for that when scene_lookup being cleared
	## but shouldn't go so maybe this is not the issue?
	#
		#for scene_full_path: String in chunk:
			#processed_scene_count += 1
			##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
			#if not user_dir.file_exists(thumbnail_cache_path):
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
				#
			##last_chunk_paths.append(scene_full_path)
			##await get_tree().create_timer(0.1).timeout
			##mutex.lock()
			##scene_lookup[scene_full_path].queue_free()
			##mutex.unlock()
#
##### TEST Combine
		###await get_tree().create_timer(10.0).timeout
		##await get_tree().create_timer(0.1).timeout # Seems system needs time to release VRAM
		##push_error("CLEARING ENTIRE scene_lookup ARRAY NOW")
		#
		### TEST Maybe not needed since after this function runs we run collection_lookup[collection_name].clear()
		### TODO Check if last thumbnails being generated?
		##mutex.lock()
		##chunk_lookup.clear() # Needed to clear last chunk of last collection to go through from memory. 
		##mutex.unlock()
		#
		#
		##scene_lookup.clear()
		##mutex.unlock()
		##await get_tree().create_timer(0.01).timeout # Seems system needs time to release VRAM
		###await get_tree().process_frame # Seems system needs time to release VRAM
####
##### TEST Combine
#
#
#
#
#
#
#
#### TEST Run entire stack in multi_threaded_chunk_process function
## RESULT Slow
###
 #####FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
##### MAYBE COMBINE WITH ABOVE?
		#### NOTE: For loading textures into filesystem single threaded
		###mutex.lock()
		##for scene_full_path: String in chunk:
			### NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
			### NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
			##await get_tree().create_timer(0.5).timeout
			###await get_tree().create_timer(0.1).timeout
			###await get_tree().process_frame
			##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
		###
		####file_bytes_lookup.clear()
		###mutex.unlock()
		### NOTE: Time needs to added between to give import time to finish
		##await get_tree().create_timer(1).timeout # Time between chunks 
##
#### FIXME Find best solution for waiting until above finished before reimporting!!
		###for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
			###if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
				###EditorInterface.get_resource_filesystem().update_file(file)
###
		###EditorInterface.get_resource_filesystem().scan()
###
		###await EditorInterface.get_resource_filesystem().resources_reimported
		###await get_tree().create_timer(5).timeout 
##
##
		###while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			###await get_tree().process_frame
			####await get_tree().create_timer(1).timeout
##
##
##
		###if debug: print("running multi-threaded re-import for collection: ", collection_name)
		#### NOTE: Reload scenes multi-threaded referencing imported filesystem textures found in collections folder
		###initial_import = false
		###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, chunk, initial_import), chunk.size())
		###if debug: print("Awaiting finish of multi-threaded re-import for collection: ", collection_name)
		###await finished_processing_collection # Check may conflict with above signal that is the same?
		###if debug: print("Finished multi-threaded re-import for collection: ", collection_name)
##
##
##
### TEST Run entire stack in multi_threaded_chunk_process function
#
#
#
#
#
#
#
#
#
	#if processed_scene_count == collection_scene_full_paths_array.size():
		##push_error("processed_scene_count == collection_scene_full_paths_array.size()")
##
	##if finished_chunks:
		#emit_signal("finished_collection_chunks")
#
#
		##multi_threaded_chunk_process(imported_textures_path, collection_name, initial_import, new_sub_collection_tab, new_scene_view)
#
#
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
##func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
#func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
#### Initial single threaded loading of scenes with textures to import to filesystem
### This runs on main thread and is blocking run on single background thread?
### FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
### FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
###func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
##func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String) -> void:
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
		###await get_tree().process_frame
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		###await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
##
##
### TEST
		#### ✅ Wrap the GLB scene in your own root node
		###var root_node := Node3D.new()
		###root_node.name = "WrappedGLBScene"
		###root_node.add_child(imported_scene)
		###imported_scene.owner = root_node  # Important for saving the scene later if needed
###
		###mutex.lock()
		###scene_lookup[scene_full_path] = root_node
		###mutex.unlock()
### TEST
##
##
##
		###call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##
###func import_textures(collection_scene_full_paths_array: Array[String], imported_textures_path: String) -> void:
	###mutex.lock()
	###for scene_full_path: String in collection_scene_full_paths_array:
		####var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
		####var wait_count: int = 0
		####while not WorkerThreadPool.is_task_completed(task):
			####await get_tree().process_frame
			####wait_count += 1
			####if debug: print("wait_count: ", wait_count)
			####if wait_count > 100: # Consider a more robust timeout/error handling
				####push_warning("Wait time exceded for: " + scenes_dir_path)
				####break
		####WorkerThreadPool.wait_for_task_completion(task)
###
		###load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
	###mutex.unlock()
###
	###
	###file_bytes_lookup.clear()
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance_test(scene_full_path: String, imported_textures_path: String, collection_name: String) -> void:
##func load_gltf_scene_instance_test(scene_full_path: String, imported_textures_path: String, collection_name: String, new_sub_collection_tab: Control) -> void:
	##var scene_lookup: Dictionary[String, Node] = {}
#
	#var gltf_state: GLTFState = GLTFState.new()
	#if not file_bytes_lookup.is_empty():
		#gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	#else:
		#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
#
			#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	#
	#mutex.lock()
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	##collection_lookup[collection_name][scene_full_path] = gltf.generate_scene(gltf_state)
	##collection_lookup[collection_name] = scene_lookup
	#mutex.unlock()
	#
#
	###TEST
	##var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
	##if not user_dir.file_exists(thumbnail_cache_path):
		##var new_scene_view: Button = null
		##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
	###create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#### FIXME reuse file_bytes from intial_import here 
	###var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	###if scene_file:
		###var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		###scene_file.close()
	###var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	###file_bytes_lookup[scene_full_path] = []
	###scene_lookup[scene_full_path].queue_free()
##
	###scene_lookup[scene_full_path].free()
	###scene_lookup.erase(scene_full_path)
	###await get_tree().process_frame
#
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	##await get_tree().process_frame
#
	##call_deferred("deferred_write_textures_to_filesystem", file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, scene_full_path)
#
#
#
#
#
		###await get_tree().process_frame
		###mutex.lock()
		##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
		###gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		####await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
###
###
#### TEST
		##### ✅ Wrap the GLB scene in your own root node
		####var root_node := Node3D.new()
		####root_node.name = "WrappedGLBScene"
		####root_node.add_child(imported_scene)
		####imported_scene.owner = root_node  # Important for saving the scene later if needed
####
		####mutex.lock()
		####scene_lookup[scene_full_path] = root_node
		####mutex.unlock()
#### TEST
###
###
###
		####call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
### OVERWRITE
		###mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
##
##
##
		###mutex.lock()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##
#### TEST OVERWRITE?
		###mutex.lock()
		###var scene_lookup_dup = scene_lookup.duplicate()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#
#
#
#
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
##
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
##
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
##
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
#
#
#
#
#
##func generate_scene_deferred(scene_full_path: String, gltf: GLTFDocument, gltf_state: GLTFState) -> void:
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
## TODO Added emit_signal("single_thread_process_finished") when count matches for loop size -1
#
#
## WORKS
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
##func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
## NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, chunk_lookup: Dictionary[String, Node], chunk: Array[String], initial_import: bool = false, uncompressed: bool = true) -> void:
	##var scene_lookup: Dictionary[String, Node] = {}
	#var scene_full_path: String = chunk[index]
#
	#var gltf_state: GLTFState = GLTFState.new()
	#if initial_import:
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#
		#mutex.lock()
		#file_bytes_lookup[scene_full_path] = file_bytes
		#mutex.unlock()
		#
		#
		#scene_file.close()
#
			##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
#
#
#
#
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
##
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
##
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
#
## TEST Copy textures to here and then combine after on single thread? will it work?
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##TEST loading in textures from mulit-threaded loaded .glb
		##if false:
		##if run_gltf_image_hash_check(collection_scene_full_paths_array):
		## FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		## Can we find if failed import and clear collections textures folder to reset this?
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
#
#
#
		##if initial_import:
			##if uncompressed: # If under 50
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else: # if under 100
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
#
		##if initial_import:
			##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
#
			## FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
			## Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
			## CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
			## NOTE: Throttle to allow memory to free up
			##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
			##for texture: Texture2D in gltf_state.get_images():
				##texture.free()
#
			##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		##else:
			#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
## NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
#
#
		#mutex.lock()
		#
		#if initial_import:
			#chunk_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			#if chunk_lookup.size() == chunk.size(): # Works because chunk_lookup gets cleared every loop
				##emit_finished = false
				#if debug: print("index has reached collection size")
				#call_deferred("deferred_finished_processing_collection_signal")
		#
		#
		#else:
			#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			#if index == chunk.size() -1:
			##if collection_lookup[collection_name].size() == chunk.size(): # This worked for intial_import because function before fills collection_lookup[collection_name] but not when just running this FIXME?
			##if scene_lookup.size() == chunk.size(): # Does not fire for second or more collection because sharing scene_lookup
				##emit_finished = false
				#if debug: print("index has reached collection size")
				#call_deferred("deferred_finished_processing_collection_signal")
				#
		##collection_lookup[collection_name][scene_full_path] = gltf.generate_scene(gltf_state)
		##collection_lookup[collection_name] = scene_lookup
		#mutex.unlock()
#
#
		##mutex.lock()
		##if initial_import:
			##chunk_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##else:
			##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
##
		##if index == chunk.size() -1:
			##if debug: print("index has reached collection size")
			##call_deferred("deferred_finished_processing_collection_signal")
		##mutex.unlock()
#
#
#
	## NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
#
	##if index == chunk.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#
#
#
#
### EDITED
### NOTE 1:10 to load ~ 1200 Synty assets
#### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
###func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
### NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	###if debug: print("current index: ", index)
	###if debug: print("collection_scene_full_paths[current_sub_folder_name].size() -1: ", collection_scene_full_paths[current_sub_folder_name].size() -1)
	##
##
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
### TEST Copy textures to here and then combine after on single thread? will it work?
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
###TEST loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_scene_full_paths_array):
		### FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		### Can we find if failed import and clear collections textures folder to reset this?
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		### FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
		### Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
		### CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		###await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
##
##
### NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
		##
		##
		###else: # For single threaded texture writes to filesystem
			###call_deferred("deferred_write_textures_to_filesystem", file_bytes, imported_textures_path, gltf_state, scene_full_path)
		##
		##
		##
		##
		##
		##
	### NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
##
		##
##
##
##func deferred_write_textures_to_filesystem(file_bytes: PackedByteArray, imported_textures_path: String, gltf_state: GLTFState, scene_full_path: String) -> void:
	##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
	###mutex.lock()
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	###mutex.unlock()
##
##
##func deferred_finished_processing_collection_signal() -> void:
	##if debug: print("collection import stack finished")
	##emit_signal("finished_processing_collection")
#
#
#
#
##● Error append_from_buffer(bytes: PackedByteArray, base_path: String, state: GLTFState, flags: int = 0)
##
##Takes a PackedByteArray defining a glTF and imports the data to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_buffer() where to find dependencies and can be empty.
##
##
##● Error append_from_file(path: String, state: GLTFState, flags: int = 0, base_path: String = "")
##
##Takes a path to a glTF file and imports the data at that file path to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_file() where to find dependencies and can be empty.
#
#
#
#
#
#
#
#
#
#
### Check if res:// textures contains .png files. Do not run image hash if .png exist
#func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	#if collection_textures_path == "res://collections/textures/":
		#return false
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#return false
#
	#return true
#
#
##func run_gltf_image_hash_check(collection_scene_full_paths_array: Array[String]) -> bool:
	##var collection_textures: Array[String] = collection_scene_full_paths_array.duplicate()
	##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
	##if collection_textures.size() > 0:
		##return false
##
	##return true
#
#
#
#
#func wait_loop(task_id: int, wait_time: int, scenes_dir_path: String) -> void: 
	#var wait_count: int = 0
	#while not WorkerThreadPool.is_group_task_completed(task_id):
		#await get_tree().process_frame
		#wait_count += 1
		#if debug: print("wait_count: ", wait_count)
		#if wait_count > wait_time: # Consider a more robust timeout/error handling
			#push_warning("Wait time exceded for: " + scenes_dir_path)
			#break
	#return
#endregion






#region Version G multi-thread starter to single thread import slow for large collection no image hash but does not brake for some collections
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#
#
#
#var collection_scene_full_paths: Dictionary[String, Array] = {}
#var collection_scene_full_paths_array: Array[String] = []
#var collection_textures_paths: Dictionary[String, String] = {} 
##var current_sub_folder_name: String = ""
##var current_collection_name: String = ""
#
##var collection_processing_count: int = 0
##var collection_process_queue: Array[String] = []
#
##var collection_queue: Dictionary[int, Array] = {}
#var collection_queue: Array[Array] = []
#var processing_collection: bool = false
#
##var collection_count: int = 0
#
##var current_collection_id: int = -1
#
#
### TEST
##func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##pass
#
## FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
## TODO Make single threaded import run on background thread
## TODO Display button textures during multi-threaded loading time
#
#
## NOTE: Called when:
## 1. create_main_collection_tabs()
## 2. _ready() for any open tabs at start
## 3. create_sub_collection_tabs() when openning new collection from list collection gets added to queue and signal runs process_collection()
#
#func add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control):
	#processing_collection = true
	#if debug: print("Starting import process for: ", collection_name)
	#
#
#
#
	#
	#
	##var info: Array = []
	##info.append(sub_folders_path)
	##info.append(new_sub_collection_tab)
	##collection_info[sub_folder_name] = info
	#
	#
	#var scenes_dir_path: String = sub_folders_path.path_join(collection_name)
	##push_error("scenes_dir_path: ", scenes_dir_path)
#
	## FIXME Setup signal for when finished
	#if scenes_dir_path == project_scenes_path:
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false # FIXME Maybe don't need?
#
	## This gets overwritten too so needs to be lower and have id with dic
	##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	##if collection_textures_path == "res://collections/textures/":
		##pass
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##run_gltf_image_hash_check = false
#
	## TODO can subfoldername can be used in place of collection_id
	## FIXME Using colleciton id issue is that if there is a gap between when this function is run the await finished_processing_collection is never
	## fired to allow it to progress past that point, await finished_processing_collection only works if there is a chain of collections openned at the same time
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		##collection_processing_count += 1
		##
		##var wait_count: int = 0
		##while collection_processing_count > 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				##break
#
#
#
#
		#cleanup_task_id1 = true
		##ran_task_id2 = true
		#var imported_textures_path: String
#
#
		##var gltf: GLTFDocument = GLTFDocument.new()
		##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
		##await get_tree().process_frame
		#await get_tree().create_timer(1).timeout
		#if debug: print("ext: ", gltf.get_supported_gltf_extensions())
#
		### 
		###var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		## Get the file paths to all the .png images within the res://collections/../textures folder
		#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].to_snake_case().path_join("textures".path_join("/")))
		#collection_textures_paths[collection_name] = collection_textures_path # NOTE: Not needed with now having queue and only one collection running through stack at a time
#
		## Get the file paths of all scenes in the collection and add them to an Array
		## FIXME A little off imported_textures_path calculated for every file when it remains the same? and run_gltf_image_hash_check() broken so maybe need above var collection_textures_path?
		##var collection_scene_full_paths_array: Array[String] = []
		## FIXME ALERT if collection_name the same then do not need to check thumbnail_cache_path and imported_textures_path
		#collection_scene_full_paths_array = []
		#var thumbnail_cache: bool = false
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#
#
#
## FIXME CLEANUP TO ONLY SHOW THUMBNAILS AFTER FULLY LOADED AND DISABLE 360 ROTATION AND VIEWPORT SWITCHING ON BUTTON UNTIL PROCESSING FINISHED
				## TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
				#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
				#if user_dir.file_exists(thumbnail_cache_path):
					#thumbnail_cache = true
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
				#collection_scene_full_paths_array.append(scene_full_path)
#
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case().path_join("textures".path_join("/")))
				##imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		### TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
		##for scene_full_path in collection_scene_full_paths_array:
			###await get_tree().process_frame
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
####  ALERT MAYBE NEEDED
		##if debug: print("imported_textures_path: ", imported_textures_path)
		##collection_scene_full_paths[collection_name] = collection_scene_full_paths_array.duplicate()
#
#
		##if collection_processing_count > 1: # Do not hold for first collection
			##if debug: print("Waiting to process ", collection_name, " collection")
			##await finished_processing_collection
			###await get_tree().process_frame
			##await get_tree().create_timer(5).timeout
			###if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		##if not imported_textures_path.is_empty():
		##if run_gltf_image_hash_check(imported_textures_path):
		#if debug: print("collection_scene_full_paths_array: ", collection_scene_full_paths_array)
### TEST skip and run direct multi-thread
		##if false:
		###if run_gltf_image_hash_check(collection_scene_full_paths_array):
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##
			##
			##if collection_scene_full_paths_array.size() > 0:
			###if collection_scene_full_paths[collection_name].size() > 0:
				##cleanup_task_id2 = true
				###current_collection_name = collection_name # NOTE: To maintain same data through stack 
				##if debug: print("Starting image hashing and multi-threaded import stack for collection: ", collection_name)
				##mutex.lock()
				##collection_hased_images.clear()
				##process_single_threaded_list.clear()
				##mutex.unlock()
				###task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
				##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths_array), collection_scene_full_paths_array.size())
##
				##if debug: print("waiting for image hashing to finish")
				###await wait_loop(task_id2, 10000, scenes_dir_path)
				##await finished_image_hashing
				##if debug: print("image hashing finished")
##
				###scene_loading_complete = true
				##
				##mutex.lock()
				##var process_single_threaded_list_duplicate: Array[String] = process_single_threaded_list.duplicate()
				##mutex.unlock()
### TEST Load all single threaded
				###for scene_full_path: String in collection_scene_full_paths_array:
### TEST
				##for scene_full_path: String in process_single_threaded_list_duplicate:
					###load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
					##load_gltf_scene_instance(scene_full_path, imported_textures_path)
##
##
				###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
				###for file in collection_scene_full_paths_array:
				##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
					##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
						##EditorInterface.get_resource_filesystem().update_file(file)
##
				##EditorInterface.get_resource_filesystem().scan()
##
				##await EditorInterface.get_resource_filesystem().resources_reimported # NOTE: This may need more time for collections with many textures?
				### FIXME dest_md5 must not be matching up for Carpenters-workshop collection appears to be reimporting after textures imported when multi-thread runs below.
				###if debug: print("reimport finished")
##
				##await get_tree().create_timer(60).timeout
##
##
##
##
				###FIXME Maybe more time needed here or something else ERROR: Can't find file 'res://collections/third/textures/_0.png' during file reimport.
				###await get_tree().create_timer(15).timeout
##
				###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
				##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
				##
				###await wait_loop(task_id1, 10000, scenes_dir_path)
				###var wait_count: int = 0
				###while not WorkerThreadPool.is_group_task_completed(task_id1):
					###await get_tree().process_frame
					###wait_count += 1
					###if wait_count > 10000: # Consider a more robust timeout/error handling
						###push_warning("Hashing task timed out for: " + scenes_dir_path)
						###break
##
				###emit_signal("finished_processing_collection")
##
##
		##else:
#
#
#
#
#
		##current_collection_name = collection_name # NOTE: To maintain same data through stack 
		#if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
		## TODO CHUNK PROCESS LARGE COLLECTIONS
		#var initial_import: bool = false
		#if run_gltf_image_hash_check(collection_textures_paths[collection_name]): # NOTE: If no textures exists in the project collections then it's a new collection 
			#initial_import = true
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
		#if initial_import:
#
			#if collection_scene_full_paths_array.size() > 100:
				#pass
			#else:
				#if collection_scene_full_paths_array.size() >= 50: # FIXME Without VRAM and Texture sizes really no way to set this accordingly
					#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import, false), collection_scene_full_paths_array.size())
				#else: # collection_scene_full_paths_array.size() < 50:
					#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
				#await finished_processing_collection
				#
		#else:
			#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
			#await finished_processing_collection
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
#
		##await wait_loop(task_id1, 10000, scenes_dir_path)
		###var wait_count: int = 0
		###while not WorkerThreadPool.is_group_task_completed(task_id1):
			###await get_tree().process_frame
			###wait_count += 1
			###if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				###break
##
		###if debug: print("waiting for collection import stack to finish")
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###if debug: print("collection import stack finished")
		###call_deferred("deferred_finished_processing_collection_signal")
		##emit_signal("finished_processing_collection")
		###await get_tree().process_frame
##
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###call_deferred("deferred_finished_processing_collection_signal")
#
#
		### NOTE: WITH TWO COLLECTIONS THE FIRST WILL BE CREATING BUTTONS WHILE THE SECOND IS DOING MULTI-THREADED IMPORT IS THIS CAUSING CRASH?
		###if debug: print("Waiting for multi-threaded import for collection: ", current_sub_folder_name, " to finish.")
		##await finished_processing_collection
		#
#
		#
		#if debug: print("scene_lookup: ", scene_lookup.size())
		#if debug: print("finsihed waiting continuing process")
		##collection_processing_count -= 1 # Decrement count by 1 to allow collections opened after start to pass through import process
#
		#if not thumbnail_cache:
			#for scene_full_path in collection_scene_full_paths_array:
				##await get_tree().process_frame
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
## NOTE: if implemented will want to run after all collections opened and will then need to have imported_textures_path in a lookup per collection 
#
#
#
#
#
#
#
### WORKS!!!!!!! Now single background thread loading
###TEST 1 loading in textures from mulit-threaded loaded .glb
		###if false:
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			##await get_tree().create_timer(5).timeout
			##mutex.lock()
			##for scene_full_path: String in scene_lookup.keys():
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			##mutex.unlock()
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 1 loading in textures from mulit-threaded loaded .glb
#
#
#
## FIXME NOTE Run here after each individual collection collection_scene_full_paths_array or after all on scene_lookup?
##TEST 2 loading in textures from mulit-threaded loaded .glb
		##if false:
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		#if initial_import:
			##initial_import = false # Set to import textures
		##if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			#
			##await get_tree().create_timer(5).timeout
			##mutex.lock()
			##for scene_full_path: String in scene_lookup.keys():
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			##mutex.unlock()
#
#
## FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
			#await get_tree().create_timer(1).timeout
			##call_deferred("import_textures", collection_scene_full_paths_array, imported_textures_path)
			##call_thread_safe("import_textures", collection_scene_full_paths_array, imported_textures_path)
			#mutex.lock()
			#for scene_full_path: String in collection_scene_full_paths_array:
				##await get_tree().process_frame
				## NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
				## NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
				#await get_tree().create_timer(0.5).timeout 
				##var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
				###var wait_count: int = 0
				###while not WorkerThreadPool.is_task_completed(task):
					####await get_tree().process_frame
					###await get_tree().create_timer(.1).timeout
					###wait_count += 1
					###if debug: print("wait_count: ", wait_count)
					###if wait_count > 100: # Consider a more robust timeout/error handling
						###push_warning("Wait time exceded for: " + scenes_dir_path)
						###break
				##WorkerThreadPool.wait_for_task_completion(task)
#
				#load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			#
			#file_bytes_lookup.clear()
			#mutex.unlock()
#
#
## FIXME CHECK IF NEEDED
## Reload scene buttons with lower vram
			##for button: Node in new_sub_collection_tab.h_flow_container.get_children():
				##if button and button is Button:
					##button.queue_free()
					#
#
#
			##for scene_view: Button in new_sub_collection_tab.h_flow_container.get_children():
				##scene_view.queue_free()
			#if not thumbnail_cache:
				#for scene_full_path in collection_scene_full_paths_array:
					##await get_tree().process_frame
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
			##mutex.lock()
			##for scene_full_path: String in collection_scene_full_paths_array:
				##await get_tree().process_frame
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##mutex.unlock()
#
#
#
#
#
			##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
#
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 2 loading in textures from mulit-threaded loaded .glb
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
		##await get_tree().process_frame
		#await get_tree().create_timer(5).timeout # NOTE: Add time between collections process
		#
		#if collection_queue.size() > 0:
			#if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			#emit_signal("process_next_collection")
		#processing_collection = false
#
	#if collection_name == "" and collection_queue.size() > 0:
		#if debug: print("Finished processing project scenes, emitting signal to start processing collections.")
		#emit_signal("process_next_collection")
		#processing_collection = false
#
#
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
##func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
#func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String) -> void:
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
#
## TEST
		### ✅ Wrap the GLB scene in your own root node
		##var root_node := Node3D.new()
		##root_node.name = "WrappedGLBScene"
		##root_node.add_child(imported_scene)
		##imported_scene.owner = root_node  # Important for saving the scene later if needed
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = root_node
		##mutex.unlock()
## TEST
#
#
#
		##call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#
#func import_textures(collection_scene_full_paths_array: Array[String], imported_textures_path: String) -> void:
	#mutex.lock()
	#for scene_full_path: String in collection_scene_full_paths_array:
		##var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
		##var wait_count: int = 0
		##while not WorkerThreadPool.is_task_completed(task):
			##await get_tree().process_frame
			##wait_count += 1
			##if debug: print("wait_count: ", wait_count)
			##if wait_count > 100: # Consider a more robust timeout/error handling
				##push_warning("Wait time exceded for: " + scenes_dir_path)
				##break
		##WorkerThreadPool.wait_for_task_completion(task)
#
		#load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
	#mutex.unlock()
#
	#
	#file_bytes_lookup.clear()
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance_test(scene_full_path: String, imported_textures_path: String) -> void:
	##var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	#var gltf_state: GLTFState = GLTFState.new()
	#if not file_bytes_lookup.is_empty():
		#gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	#else:
		#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
#
			#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
#
#### FIXME reuse file_bytes from intial_import here 
	###var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	###if scene_file:
		###var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		###scene_file.close()
	###var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	###file_bytes_lookup[scene_full_path] = []
	###scene_lookup[scene_full_path].queue_free()
##
	###scene_lookup[scene_full_path].free()
	###scene_lookup.erase(scene_full_path)
	###await get_tree().process_frame
#
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	##call_deferred("deferred_write_textures_to_filesystem", file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, scene_full_path)
#
#
#
#
#
		###await get_tree().process_frame
		###mutex.lock()
		##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
		###gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		####await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
###
###
#### TEST
		##### ✅ Wrap the GLB scene in your own root node
		####var root_node := Node3D.new()
		####root_node.name = "WrappedGLBScene"
		####root_node.add_child(imported_scene)
		####imported_scene.owner = root_node  # Important for saving the scene later if needed
####
		####mutex.lock()
		####scene_lookup[scene_full_path] = root_node
		####mutex.unlock()
#### TEST
###
###
###
		####call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
### OVERWRITE
		###mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
##
##
##
		###mutex.lock()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##
#### TEST OVERWRITE?
		###mutex.lock()
		###var scene_lookup_dup = scene_lookup.duplicate()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#
#
#
#
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
##
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
##
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
##
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
#
#
#
#
#
##func generate_scene_deferred(scene_full_path: String, gltf: GLTFDocument, gltf_state: GLTFState) -> void:
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
## TODO Added emit_signal("single_thread_process_finished") when count matches for loop size -1
#
#
## WORKS
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
##func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
## NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
#
	#var scene_full_path: String = collection_scene_full_paths_array[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
#
		#mutex.lock()
		#file_bytes_lookup[scene_full_path] = file_bytes
		#mutex.unlock()
#
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
## TEST Copy textures to here and then combine after on single thread? will it work?
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##TEST loading in textures from mulit-threaded loaded .glb
		##if false:
		##if run_gltf_image_hash_check(collection_scene_full_paths_array):
		## FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		## Can we find if failed import and clear collections textures folder to reset this?
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		#if initial_import:
			#if uncompressed: # If under 50
				#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			#else: # if under 100
				#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
#
#
			## FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
			## Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
			## CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
			## NOTE: Throttle to allow memory to free up
			##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
			##for texture: Texture2D in gltf_state.get_images():
				##texture.free()
#
			##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		##else:
			#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
## NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
#
	#
	#
	## NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	#if index == collection_scene_full_paths_array.size() -1:
		#if debug: print("index has reached collection size")
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#
#
#
#
### EDITED
### NOTE 1:10 to load ~ 1200 Synty assets
#### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
###func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
### NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	###if debug: print("current index: ", index)
	###if debug: print("collection_scene_full_paths[current_sub_folder_name].size() -1: ", collection_scene_full_paths[current_sub_folder_name].size() -1)
	##
##
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
### TEST Copy textures to here and then combine after on single thread? will it work?
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
###TEST loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_scene_full_paths_array):
		### FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		### Can we find if failed import and clear collections textures folder to reset this?
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		### FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
		### Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
		### CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		###await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
##
##
### NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
		##
		##
		###else: # For single threaded texture writes to filesystem
			###call_deferred("deferred_write_textures_to_filesystem", file_bytes, imported_textures_path, gltf_state, scene_full_path)
		##
		##
		##
		##
		##
		##
	### NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
##
		##
##
##
#func deferred_write_textures_to_filesystem(file_bytes: PackedByteArray, imported_textures_path: String, gltf_state: GLTFState, scene_full_path: String) -> void:
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
	##mutex.lock()
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	##mutex.unlock()
##
##
##func deferred_finished_processing_collection_signal() -> void:
	##if debug: print("collection import stack finished")
	##emit_signal("finished_processing_collection")
#
#
#
#
##● Error append_from_buffer(bytes: PackedByteArray, base_path: String, state: GLTFState, flags: int = 0)
##
##Takes a PackedByteArray defining a glTF and imports the data to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_buffer() where to find dependencies and can be empty.
##
##
##● Error append_from_file(path: String, state: GLTFState, flags: int = 0, base_path: String = "")
##
##Takes a path to a glTF file and imports the data at that file path to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_file() where to find dependencies and can be empty.
#
#
#
#
#
#
#
#
#
#
### Check if res:// textures contains .png files. Do not run image hash if .png exist
#func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	#if collection_textures_path == "res://collections/textures/":
		#return false
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#return false
#
	#return true
#
#
##func run_gltf_image_hash_check(collection_scene_full_paths_array: Array[String]) -> bool:
	##var collection_textures: Array[String] = collection_scene_full_paths_array.duplicate()
	##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
	##if collection_textures.size() > 0:
		##return false
##
	##return true
#
#
#
#
#func wait_loop(task_id: int, wait_time: int, scenes_dir_path: String) -> void: 
	#var wait_count: int = 0
	#while not WorkerThreadPool.is_group_task_completed(task_id):
		#await get_tree().process_frame
		#wait_count += 1
		#if debug: print("wait_count: ", wait_count)
		#if wait_count > wait_time: # Consider a more robust timeout/error handling
			#push_warning("Wait time exceded for: " + scenes_dir_path)
			#break
	#return

#endregion



#region  Version 5.5 hash with attempt to pull out images multi-thread and copy in to res:// single threaded
#
## TEST VERSION 5.5 copy .png to fileystem single threaded
#var tmp_path_base := "user://temp_image_%d.png"
#var dir := DirAccess.open("user://")
## TEST copy .png to fileystem single threaded
#
#
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#
#
#
#var collection_scene_full_paths: Dictionary[String, Array] = {}
#var collection_scene_full_paths_array: Array[String] = []
#var collection_textures_paths: Dictionary[String, String] = {} 
##var current_sub_folder_name: String = ""
##var current_collection_name: String = ""
#
##var collection_processing_count: int = 0
##var collection_process_queue: Array[String] = []
#
##var collection_queue: Dictionary[int, Array] = {}
#var collection_queue: Array[Array] = []
#var processing_collection: bool = false
#
##var collection_count: int = 0
#
##var current_collection_id: int = -1
#
#
### TEST
##func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##pass
#
## FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
## TODO Make single threaded import run on background thread
## TODO Display button textures during multi-threaded loading time
#
#
## NOTE: Called when:
## 1. create_main_collection_tabs()
## 2. _ready() for any open tabs at start
## 3. create_sub_collection_tabs() when openning new collection from list collection gets added to queue and signal runs process_collection()
#
#func add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control):
	#processing_collection = true
	#if debug: print("Starting import process for: ", collection_name)
#
	#var scenes_dir_path: String = sub_folders_path.path_join(collection_name)
#
	## FIXME Setup signal for when finished
	#if scenes_dir_path == project_scenes_path:
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false # FIXME Maybe don't need?
#
	## This gets overwritten too so needs to be lower and have id with dic
	##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	##if collection_textures_path == "res://collections/textures/":
		##pass
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##run_gltf_image_hash_check = false
#
	## TODO can subfoldername can be used in place of collection_id
	## FIXME Using colleciton id issue is that if there is a gap between when this function is run the await finished_processing_collection is never
	## fired to allow it to progress past that point, await finished_processing_collection only works if there is a chain of collections openned at the same time
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		##collection_processing_count += 1
		##
		##var wait_count: int = 0
		##while collection_processing_count > 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				##break
#
#
#
#
		#cleanup_task_id1 = true
		##ran_task_id2 = true
		#var imported_textures_path: String
#
#
		##var gltf: GLTFDocument = GLTFDocument.new()
		##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
		##await get_tree().process_frame
		#await get_tree().create_timer(1).timeout
		#if debug: print("ext: ", gltf.get_supported_gltf_extensions())
#
		### 
		###var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		## Get the file paths to all the .png images within the res://collections/../textures folder
		#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].to_snake_case().path_join("textures".path_join("/")))
		#collection_textures_paths[collection_name] = collection_textures_path # NOTE: Not needed with now having queue and only one collection running through stack at a time
#
		## Get the file paths of all scenes in the collection and add them to an Array
		## FIXME A little off imported_textures_path calculated for every file when it remains the same? and run_gltf_image_hash_check() broken so maybe need above var collection_textures_path?
		##var collection_scene_full_paths_array: Array[String] = []
		## FIXME ALERT if collection_name the same then do not need to check thumbnail_cache_path and imported_textures_path
		#collection_scene_full_paths_array = []
		#var thumbnail_cache: bool = false
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#
#
#
## FIXME CLEANUP TO ONLY SHOW THUMBNAILS AFTER FULLY LOADED AND DISABLE 360 ROTATION AND VIEWPORT SWITCHING ON BUTTON UNTIL PROCESSING FINISHED
				## TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
				#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
				#if user_dir.file_exists(thumbnail_cache_path):
					#thumbnail_cache = true
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
				#collection_scene_full_paths_array.append(scene_full_path)
#
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case().path_join("textures".path_join("/")))
				##imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		### TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
		##for scene_full_path in collection_scene_full_paths_array:
			###await get_tree().process_frame
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
####  ALERT MAYBE NEEDED
		##if debug: print("imported_textures_path: ", imported_textures_path)
		##collection_scene_full_paths[collection_name] = collection_scene_full_paths_array.duplicate()
#
#
		##if collection_processing_count > 1: # Do not hold for first collection
			##if debug: print("Waiting to process ", collection_name, " collection")
			##await finished_processing_collection
			###await get_tree().process_frame
			##await get_tree().create_timer(5).timeout
			###if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		##if not imported_textures_path.is_empty():
		##if run_gltf_image_hash_check(imported_textures_path):
		#if debug: print("collection_scene_full_paths_array: ", collection_scene_full_paths_array)
### TEST skip and run direct multi-thread
		##if false:
		###if run_gltf_image_hash_check(collection_scene_full_paths_array):
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		#if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
			#
			#if collection_scene_full_paths_array.size() > 0:
				#
				#
				##for scene_full_path: String in collection_scene_full_paths_array:
					###load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
					##load_gltf_scene_instance(scene_full_path, imported_textures_path)
				#
				#
				#
			##if collection_scene_full_paths[collection_name].size() > 0:
				#cleanup_task_id2 = true
				##current_collection_name = collection_name # NOTE: To maintain same data through stack 
				#if debug: print("Starting image hashing and multi-threaded import stack for collection: ", collection_name)
				#mutex.lock()
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#collection_images.clear()
				#mutex.unlock()
				##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths_array), collection_scene_full_paths_array.size())
#
				#if debug: print("waiting for image hashing to finish")
				##await wait_loop(task_id2, 10000, scenes_dir_path)
				#await finished_image_hashing
				#if debug: print("image hashing finished")
				##await get_tree().create_timer(15).timeout
				#
				##mutex.lock()
				##if debug: print("collection_images SIZE: ", collection_images.size())
				##var collection_images_dup = collection_images.duplicate()
				##mutex.unlock()
#
				##mutex.lock()
				##if debug: print("stored_images: ", stored_images.keys())
				##if debug: print("stored_images size: ", stored_images.size())
				##mutex.unlock()
#
#
#
## TEST copy .png to fileystem single threaded
				##for png: Image in collection_images:
					##DirAccess.open("res://").copy(png, imported_textures_path)
#
#
				##DirAccess.make_dir_recursive_absolute(imported_textures_path)
##
				##for i in collection_images_dup.size():
					##var png_bytes: PackedByteArray = collection_images[i]
					###var file_path := "user://exported_images/image_%d.png" % i
					##var path := "%s/image_%d.png" % [imported_textures_path, i]
##
					##var file := FileAccess.open(path, FileAccess.WRITE)
					##file.store_buffer(png_bytes)
					##file.close()
#
#
				#var base_path := imported_textures_path
				#DirAccess.make_dir_recursive_absolute(base_path)
#
#
#
				##for data in stored_images.keys():
					##var filename_base: String = "_" + data + ".png"
					##var file_path := base_path.path_join(filename_base)
					##var file_count := 0
##
					### If file exists, keep trying with _0, _1, etc.
					##while FileAccess.file_exists(file_path):
						##filename_base = "_" + str(file_count) + data + ".png"
						##file_path = base_path.path_join(filename_base)
						##file_count += 1
##
					##stored_images[data].save_png(file_path)
#
#
				##var used_names := {}
##
				##for i in stored_images.size():
					##var data = stored_images.keys()[i]
					##var image := stored_images[data]
					##var base_name: String = data.get_file().get_basename().validate_filename()
					##
					##if base_name.is_empty():
						##base_name = str(i)
##
					##var name = base_name
					##var name_attempt := 0
					##while used_names.has(name):
						###name = "%s_%d" % [base_name, name_attempt]
						##name = base_name.path_join(str(name_attempt))
						##name_attempt += 1
##
					##used_names[name] = true
##
					##var file_path := base_path.path_join(name + ".png")
					##image.save_png(file_path)
#
#
#
#
##region Test
				#var file_count := 0
				#for i in stored_images.size():
					#var image: Image = stored_images[i]["image"]
					#var name: String = stored_images[i]["name"]
					#var filename_base: String = "_" + name + ".png"
					#var file_path := base_path.path_join(filename_base)
					#if name == "":
						#if FileAccess.file_exists(file_path):
							#filename_base = "_" + str(file_count) + name + ".png"
							#file_path = base_path.path_join(filename_base)
							#file_count += 1
#
					#image.save_png(file_path)
##endregion
#
#
#
#
#
#
#
#
					##stored_images[name].save_png(file_path)
#
#
					##
					##while used_names.has(name):
						###name = "%s_%d" % [base_name, name_attempt]
						##name = base_name.path_join(str(name_attempt))
						##name_attempt += 1
##
					##used_names[name] = true
##
					##var file_path := base_path.path_join(name + ".png")
					##image.save_png(file_path)
#
#
#
#
#
#
#
				##var file_count: int = 0
				##for data in stored_images.keys():
					###var file_path := "%s/%s.png" % [base_path, data]
					##var file_path: String = base_path.path_join("_" + data + ".png")
					##if FileAccess.file_exists(file_path):
						##file_path = base_path.path_join("_" + str(file_count) + data + ".png")
						##file_count += 1
						##
##
					##stored_images[data].save_png(file_path)
#
#
#
#
					##var file := FileAccess.open(file_path, FileAccess.WRITE)
					##if file:
						##file.store_buffer(stored_images[data])
						##file.close()
#
#
#
#
#
#
#
				##for i in collection_images.size():
					##var image: Image = collection_images[i]
					##var tmp_path := tmp_path_base % i
					##var save_err := image.save_png(tmp_path)
##
					##if save_err == OK:
						##var final_path := imported_textures_path + "/image_%d.png" % i
						##var copy_err := dir.copy(tmp_path, final_path)
						##if copy_err != OK:
							##push_error("Failed to copy image %d to %s" % [i, final_path])
					##else:
						##push_error("Failed to save temp image %d to %s" % [i, tmp_path])
#
#
## TEST copy .png to fileystem single threaded
#
#
#
##
##
##
				###scene_loading_complete = true
				##
				##mutex.lock()
				##var process_single_threaded_list_duplicate: Array[String] = process_single_threaded_list.duplicate()
				##mutex.unlock()
### TEST Load all single threaded
				###for scene_full_path: String in collection_scene_full_paths_array:
### TEST
				##for scene_full_path: String in process_single_threaded_list_duplicate:
					###load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
					##load_gltf_scene_instance(scene_full_path, imported_textures_path)
##
##
				##if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
				##for file in collection_scene_full_paths_array:
				#for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
					#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
						#EditorInterface.get_resource_filesystem().update_file(file)
#
				#EditorInterface.get_resource_filesystem().scan()
#
				#await EditorInterface.get_resource_filesystem().resources_reimported # NOTE: This may need more time for collections with many textures?
				## FIXME dest_md5 must not be matching up for Carpenters-workshop collection appears to be reimporting after textures imported when multi-thread runs below.
				##if debug: print("reimport finished")
##
				###await get_tree().create_timer(60).timeout
##
##
##
##
				###FIXME Maybe more time needed here or something else ERROR: Can't find file 'res://collections/third/textures/_0.png' during file reimport.
				###await get_tree().create_timer(15).timeout
##
				###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
				##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
				##
				###await wait_loop(task_id1, 10000, scenes_dir_path)
				###var wait_count: int = 0
				###while not WorkerThreadPool.is_group_task_completed(task_id1):
					###await get_tree().process_frame
					###wait_count += 1
					###if wait_count > 10000: # Consider a more robust timeout/error handling
						###push_warning("Hashing task timed out for: " + scenes_dir_path)
						###break
#
				##emit_signal("finished_processing_collection")
#
#
		#else:
#
			#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
#
#
#
#
#
#
#
#
#
#
		###current_collection_name = collection_name # NOTE: To maintain same data through stack 
		##if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
##
		###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
		### TODO CHUNK PROCESS LARGE COLLECTIONS
		##var initial_import: bool = false
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]): # NOTE: If no textures exists in the project collections then it's a new collection 
			##initial_import = true
		###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
		##if initial_import:
##
			##if collection_scene_full_paths_array.size() > 200:
				##pass
			##else:
				##if collection_scene_full_paths_array.size() >= 100: # FIXME Without VRAM and Texture sizes really no way to set this accordingly
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import, false), collection_scene_full_paths_array.size())
				##else: # collection_scene_full_paths_array.size() < 50:
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
				##await finished_processing_collection
				##
		##else:
			##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
			##await finished_processing_collection
#
#
#
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
#
		##await wait_loop(task_id1, 10000, scenes_dir_path)
		###var wait_count: int = 0
		###while not WorkerThreadPool.is_group_task_completed(task_id1):
			###await get_tree().process_frame
			###wait_count += 1
			###if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				###break
##
		###if debug: print("waiting for collection import stack to finish")
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###if debug: print("collection import stack finished")
		###call_deferred("deferred_finished_processing_collection_signal")
		##emit_signal("finished_processing_collection")
		###await get_tree().process_frame
##
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###call_deferred("deferred_finished_processing_collection_signal")
#
#
		### NOTE: WITH TWO COLLECTIONS THE FIRST WILL BE CREATING BUTTONS WHILE THE SECOND IS DOING MULTI-THREADED IMPORT IS THIS CAUSING CRASH?
		###if debug: print("Waiting for multi-threaded import for collection: ", current_sub_folder_name, " to finish.")
		#await finished_processing_collection
		#
#
		#
		#if debug: print("scene_lookup: ", scene_lookup.size())
		#if debug: print("finsihed waiting continuing process")
		##collection_processing_count -= 1 # Decrement count by 1 to allow collections opened after start to pass through import process
#
		#if not thumbnail_cache:
			#for scene_full_path in collection_scene_full_paths_array:
				##await get_tree().process_frame
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
## NOTE: if implemented will want to run after all collections opened and will then need to have imported_textures_path in a lookup per collection 
#
#
#
#
#
#
#
### WORKS!!!!!!! Now single background thread loading
###TEST 1 loading in textures from mulit-threaded loaded .glb
		###if false:
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			##await get_tree().create_timer(5).timeout
			##mutex.lock()
			##for scene_full_path: String in scene_lookup.keys():
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			##mutex.unlock()
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 1 loading in textures from mulit-threaded loaded .glb
#
#
#
### FIXME NOTE Run here after each individual collection collection_scene_full_paths_array or after all on scene_lookup?
###TEST 2 loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			###initial_import = false # Set to import textures
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			###await get_tree().create_timer(5).timeout
			###mutex.lock()
			###for scene_full_path: String in scene_lookup.keys():
				###load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			###mutex.unlock()
##
##
### FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
			##await get_tree().create_timer(1).timeout
			###call_deferred("import_textures", collection_scene_full_paths_array, imported_textures_path)
			###call_thread_safe("import_textures", collection_scene_full_paths_array, imported_textures_path)
			##mutex.lock()
			##for scene_full_path: String in collection_scene_full_paths_array:
				###await get_tree().process_frame
				### NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
				### NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
				##await get_tree().create_timer(0.5).timeout 
				###var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
				####var wait_count: int = 0
				####while not WorkerThreadPool.is_task_completed(task):
					#####await get_tree().process_frame
					####await get_tree().create_timer(.1).timeout
					####wait_count += 1
					####if debug: print("wait_count: ", wait_count)
					####if wait_count > 100: # Consider a more robust timeout/error handling
						####push_warning("Wait time exceded for: " + scenes_dir_path)
						####break
				###WorkerThreadPool.wait_for_task_completion(task)
##
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##
			##file_bytes_lookup.clear()
			##mutex.unlock()
##
##
### FIXME CHECK IF NEEDED
### Reload scene buttons with lower vram
			###for button: Node in new_sub_collection_tab.h_flow_container.get_children():
				###if button and button is Button:
					###button.queue_free()
					##
##
##
			###for scene_view: Button in new_sub_collection_tab.h_flow_container.get_children():
				###scene_view.queue_free()
			##if not thumbnail_cache:
				##for scene_full_path in collection_scene_full_paths_array:
					###await get_tree().process_frame
					##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
##
##
##
##
##
			###mutex.lock()
			###for scene_full_path: String in collection_scene_full_paths_array:
				###await get_tree().process_frame
				###load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			###mutex.unlock()
##
##
##
##
##
			###task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
##
			###
#### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			####if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			####for file in collection_scene_full_paths_array:
			###for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				###if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					###EditorInterface.get_resource_filesystem().update_file(file)
###
			###EditorInterface.get_resource_filesystem().scan()
###
			###await EditorInterface.get_resource_filesystem().resources_reimported
####TEST 2 loading in textures from mulit-threaded loaded .glb
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
		##await get_tree().process_frame
		#await get_tree().create_timer(5).timeout # NOTE: Add time between collections process
		#
		#if collection_queue.size() > 0:
			#if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			#emit_signal("process_next_collection")
		#processing_collection = false
#
	#if collection_name == "" and collection_queue.size() > 0:
		#if debug: print("Finished processing project scenes, emitting signal to start processing collections.")
		#emit_signal("process_next_collection")
		#processing_collection = false
#
#
##const CHUNK_SIZE = 16
#
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
##func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
#func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
#
#
#
#
		##var md5 = Crypto.new()
#
##
		##var ctx = HashingContext.new()
		##ctx.start(HashingContext.HASH_MD5)
##
		#### Update the context after reading each chunk.
		###while file.get_position() < file.get_length():
			###var remaining = file.get_length() - file.get_position()
			###ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
		#### Get the computed hash.
		###var res = ctx.finish()
		#### Print the result as hex string and array.
		###printt(res.hex_encode(), Array(res))
##
##
##
##
		##var names = get_image_names_from_gltf(gltf_state.json)
##
		##for i in range(gltf_state.get_images().size()):
			##var texture := gltf_state.get_images()[i]
##
			##var image := texture.get_image()
			###var png_bytes := image.save_png_to_buffer()
			###var image_hash := hash(png_bytes)
			##var image_data := image.get_data()
			##var name = names[i]
##
			##if name == "":
##
##
##
				### Update the context after reading each chunk.
				##while file.get_position() < file.get_length():
					##var remaining = file.get_length() - file.get_position()
					##ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
				### Get the computed hash.
				##var res = ctx.finish()
				### Print the result as hex string and array.
				##printt(res.hex_encode(), Array(res))
##
##
##
				##var image_hash := FileAccess.get_md5(scene_full_path)
				###var png_bytes := image.save_png_to_buffer()
				###var image_hash := hash(png_bytes)
				###var image_hash: PackedByteArray = str(image_data).md5_buffer()
				##mutex.lock()
				##if not collection_hased_images.has(image_hash):
					##collection_hased_images.append(image_hash)
					##stored_images.append({
						##"name": name,
						##"image": image
					##})
				##mutex.unlock()
##
			##else:
				##mutex.lock()
				##stored_images.append({
					##"name": name,
					##"image": image
				##})
				##mutex.unlock()
#
#
#
##
				###var used_hashes := {}
				###var md5 = Crypto.new()
##
				##for key in stored_images:
					##var image := stored_images[key]
					##var image_data := image.get_data()
					##var hash := md5.md5_buffer(image_data)
##
					##if used_hashes.has(hash):
						##if debug: print("Skipping duplicate image")
						##continue
##
					##used_hashes[hash] = true
##
					##var filename := key.validate_filename() + ".png"
					##image.save_png(imported_textures_path.path_join(filename))
#
#
#
#
#
#
#
		##await get_tree().process_frame
#
		### NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		##for texture: Texture2D in gltf_state.get_images():
			##var image: Image = texture.get_image()
			##var image_bytes: PackedByteArray = image.get_data()
			##var image_hash: int = hash(image_bytes)
##
			##mutex.lock()
			##if not collection_hased_images.has(image_hash):
				##collection_hased_images.append(image_hash)
				##if not process_single_threaded_list.has(scene_full_path):
					##process_single_threaded_list.append(scene_full_path)
			##mutex.unlock()
#
#
#
#
		##for i in range(gltf_state.get_images().size()):
			##var texture := gltf_state.get_images()[i]
			##var image := texture.get_image()
			###var png_bytes := image.save_png_to_buffer()
			##var name = names[i]
##
			##mutex.lock()
			###stored_images[image] = name
			###stored_images[name] = png_bytes
##
			##stored_images.append({
				##"name": name,
				##"image": image
			##})
##
##
			##mutex.unlock()
#
#
#
#
		##var image_names = get_image_names_from_gltf(gltf_state.json)
##
		##for i in range(gltf_state.get_images().size()):
			##var texture := gltf_state.get_images()[i]
			##if texture == null:
				##continue
			##var image := texture.get_image()
			##var png_bytes := image.save_png_to_buffer()
			##var name
			##if image_names.size() > i and image_names[i] != "" and image_names[i]:
				##name = "image_%d" % i
			###var name := image_names.size() > i and image_names[i] != "" ? image_names[i] : "image_%d" % i
##
			##mutex.lock()
			##stored_images.append({
				##"bytes": png_bytes,
				##"name": name
			##})
			##mutex.unlock()
#
#
#
#
#
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
#var stored_images: Array[Dictionary] = []
##var stored_images: Dictionary[String, PackedByteArray] = {}
##var stored_images: Dictionary[String, Image] = {}
##var stored_images: Dictionary[Image, String] = {}
#
#func get_image_names_from_gltf(json: Dictionary) -> Array[String]:
	#var names: Array[String] = []
	#if json.has("images"):
		#for image_dict in json["images"]:
			#if image_dict.has("name"):
				#var raw_name = str(image_dict["name"])
				#var valid_name = raw_name.get_file().get_basename().validate_filename()
				##names.append("_" + valid_name)
				#names.append(valid_name)
			#else:
				#names.append("") # fallback
	#return names
#
#
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String) -> void:
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
#
		##var names = get_image_names_from_gltf(gltf_state.json)
		##if debug: print("names: ", names)
#
## TEST
		### ✅ Wrap the GLB scene in your own root node
		##var root_node := Node3D.new()
		##root_node.name = "WrappedGLBScene"
		##root_node.add_child(imported_scene)
		##imported_scene.owner = root_node  # Important for saving the scene later if needed
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = root_node
		##mutex.unlock()
## TEST
#
#
#
		##call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#
#func import_textures(collection_scene_full_paths_array: Array[String], imported_textures_path: String) -> void:
	#mutex.lock()
	#for scene_full_path: String in collection_scene_full_paths_array:
		##var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
		##var wait_count: int = 0
		##while not WorkerThreadPool.is_task_completed(task):
			##await get_tree().process_frame
			##wait_count += 1
			##if debug: print("wait_count: ", wait_count)
			##if wait_count > 100: # Consider a more robust timeout/error handling
				##push_warning("Wait time exceded for: " + scenes_dir_path)
				##break
		##WorkerThreadPool.wait_for_task_completion(task)
#
		#load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
	#mutex.unlock()
#
	#
	#file_bytes_lookup.clear()
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance_test(scene_full_path: String, imported_textures_path: String) -> void:
	##var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	#var gltf_state: GLTFState = GLTFState.new()
	#if not file_bytes_lookup.is_empty():
		#gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	#else:
		#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
#
			#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
#
#### FIXME reuse file_bytes from intial_import here 
	###var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	###if scene_file:
		###var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		###scene_file.close()
	###var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	###file_bytes_lookup[scene_full_path] = []
	###scene_lookup[scene_full_path].queue_free()
##
	###scene_lookup[scene_full_path].free()
	###scene_lookup.erase(scene_full_path)
	###await get_tree().process_frame
#
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	##call_deferred("deferred_write_textures_to_filesystem", file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, scene_full_path)
#
#
#
#
#
		###await get_tree().process_frame
		###mutex.lock()
		##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
		###gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		####await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
###
###
#### TEST
		##### ✅ Wrap the GLB scene in your own root node
		####var root_node := Node3D.new()
		####root_node.name = "WrappedGLBScene"
		####root_node.add_child(imported_scene)
		####imported_scene.owner = root_node  # Important for saving the scene later if needed
####
		####mutex.lock()
		####scene_lookup[scene_full_path] = root_node
		####mutex.unlock()
#### TEST
###
###
###
		####call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
### OVERWRITE
		###mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
##
##
##
		###mutex.lock()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##
#### TEST OVERWRITE?
		###mutex.lock()
		###var scene_lookup_dup = scene_lookup.duplicate()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#
#
#
#
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
##
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
##
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
##
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
#
#
#
#
#
##func generate_scene_deferred(scene_full_path: String, gltf: GLTFDocument, gltf_state: GLTFState) -> void:
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
## TODO Added emit_signal("single_thread_process_finished") when count matches for loop size -1
#
#
## WORKS
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
##func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
## NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String) -> void:
#
	#var scene_full_path: String = collection_scene_full_paths_array[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
#
		#mutex.lock()
		#file_bytes_lookup[scene_full_path] = file_bytes
		#mutex.unlock()
#
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
## NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
#
	#
	#
	## NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	#if index == collection_scene_full_paths_array.size() -1:
		#if debug: print("index has reached collection size")
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#
#
#
#
### EDITED
### NOTE 1:10 to load ~ 1200 Synty assets
#### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
###func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
### NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	##if debug: print("current index: ", index)
	##if debug: print("collection_scene_full_paths[current_sub_folder_name].size() -1: ", collection_scene_full_paths[current_sub_folder_name].size() -1)
	#
#
	#var scene_full_path: String = collection_scene_full_paths_array[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
## TEST Copy textures to here and then combine after on single thread? will it work?
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##TEST loading in textures from mulit-threaded loaded .glb
		##if false:
		##if run_gltf_image_hash_check(collection_scene_full_paths_array):
		## FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		## Can we find if failed import and clear collections textures folder to reset this?
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		#if initial_import:
			#if uncompressed:
				#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			#else:
				#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
#
		## FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
		## Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
		## CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
#
## NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
		#
		#
		##else: # For single threaded texture writes to filesystem
			##call_deferred("deferred_write_textures_to_filesystem", file_bytes, imported_textures_path, gltf_state, scene_full_path)
		#
		#
		#
		#
		#
		#
	## NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	#if index == collection_scene_full_paths_array.size() -1:
		#if debug: print("index has reached collection size")
		#call_deferred("deferred_finished_processing_collection_signal")
#
		#
#
#
#func deferred_write_textures_to_filesystem(file_bytes: PackedByteArray, imported_textures_path: String, gltf_state: GLTFState, scene_full_path: String) -> void:
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
	##mutex.lock()
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	##mutex.unlock()
##
##
##func deferred_finished_processing_collection_signal() -> void:
	##if debug: print("collection import stack finished")
	##emit_signal("finished_processing_collection")
#
#
#
#
##● Error append_from_buffer(bytes: PackedByteArray, base_path: String, state: GLTFState, flags: int = 0)
##
##Takes a PackedByteArray defining a glTF and imports the data to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_buffer() where to find dependencies and can be empty.
##
##
##● Error append_from_file(path: String, state: GLTFState, flags: int = 0, base_path: String = "")
##
##Takes a path to a glTF file and imports the data at that file path to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_file() where to find dependencies and can be empty.
#
#
#
#
#
#
#
#
#
#
### Check if res:// textures contains .png files. Do not run image hash if .png exist
#func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	#if collection_textures_path == "res://collections/textures/":
		#return false
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#return false
#
	#return true
#
#
##func run_gltf_image_hash_check(collection_scene_full_paths_array: Array[String]) -> bool:
	##var collection_textures: Array[String] = collection_scene_full_paths_array.duplicate()
	##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
	##if collection_textures.size() > 0:
		##return false
##
	##return true
#
#
#
#
#func wait_loop(task_id: int, wait_time: int, scenes_dir_path: String) -> void: 
	#var wait_count: int = 0
	#while not WorkerThreadPool.is_group_task_completed(task_id):
		#await get_tree().process_frame
		#wait_count += 1
		#if debug: print("wait_count: ", wait_count)
		#if wait_count > wait_time: # Consider a more robust timeout/error handling
			#push_warning("Wait time exceded for: " + scenes_dir_path)
			#break
	#return
#endregion





#region Verion 5 With Image hashing Works for synty but not for carpenters workshop
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#
#
#
#var collection_scene_full_paths: Dictionary[String, Array] = {}
#var collection_scene_full_paths_array: Array[String] = []
#var collection_textures_paths: Dictionary[String, String] = {} 
##var current_sub_folder_name: String = ""
##var current_collection_name: String = ""
#
##var collection_processing_count: int = 0
##var collection_process_queue: Array[String] = []
#
##var collection_queue: Dictionary[int, Array] = {}
#var collection_queue: Array[Array] = []
#var processing_collection: bool = false
#
##var collection_count: int = 0
#
##var current_collection_id: int = -1
#
#
### TEST
##func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##pass
#
## FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
## TODO Make single threaded import run on background thread
## TODO Display button textures during multi-threaded loading time
#
#
## NOTE: Called when:
## 1. create_main_collection_tabs()
## 2. _ready() for any open tabs at start
## 3. create_sub_collection_tabs() when openning new collection from list collection gets added to queue and signal runs process_collection()
#
#func add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control):
	#processing_collection = true
	#if debug: print("Starting import process for: ", collection_name)
#
	#var scenes_dir_path: String = sub_folders_path.path_join(collection_name)
#
	## FIXME Setup signal for when finished
	#if scenes_dir_path == project_scenes_path:
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false # FIXME Maybe don't need?
#
	## This gets overwritten too so needs to be lower and have id with dic
	##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	##if collection_textures_path == "res://collections/textures/":
		##pass
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##run_gltf_image_hash_check = false
#
	## TODO can subfoldername can be used in place of collection_id
	## FIXME Using colleciton id issue is that if there is a gap between when this function is run the await finished_processing_collection is never
	## fired to allow it to progress past that point, await finished_processing_collection only works if there is a chain of collections openned at the same time
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		##collection_processing_count += 1
		##
		##var wait_count: int = 0
		##while collection_processing_count > 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				##break
#
#
#
#
		#cleanup_task_id1 = true
		##ran_task_id2 = true
		#var imported_textures_path: String
#
#
		##var gltf: GLTFDocument = GLTFDocument.new()
		##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
		##await get_tree().process_frame
		#await get_tree().create_timer(1).timeout
		#if debug: print("ext: ", gltf.get_supported_gltf_extensions())
#
		### 
		###var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		## Get the file paths to all the .png images within the res://collections/../textures folder
		#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].to_snake_case().path_join("textures".path_join("/")))
		#collection_textures_paths[collection_name] = collection_textures_path # NOTE: Not needed with now having queue and only one collection running through stack at a time
#
		## Get the file paths of all scenes in the collection and add them to an Array
		## FIXME A little off imported_textures_path calculated for every file when it remains the same? and run_gltf_image_hash_check() broken so maybe need above var collection_textures_path?
		##var collection_scene_full_paths_array: Array[String] = []
		## FIXME ALERT if collection_name the same then do not need to check thumbnail_cache_path and imported_textures_path
		#collection_scene_full_paths_array = []
		#var thumbnail_cache: bool = false
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#
#
#
## FIXME CLEANUP TO ONLY SHOW THUMBNAILS AFTER FULLY LOADED AND DISABLE 360 ROTATION AND VIEWPORT SWITCHING ON BUTTON UNTIL PROCESSING FINISHED
				## TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
				#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
				#if user_dir.file_exists(thumbnail_cache_path):
					#thumbnail_cache = true
					#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
				#collection_scene_full_paths_array.append(scene_full_path)
#
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case().path_join("textures".path_join("/")))
				##imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		### TODO Check thumbnail cache and create buttons if exists before loading scenes multi-threaded
		##for scene_full_path in collection_scene_full_paths_array:
			###await get_tree().process_frame
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
#
#
####  ALERT MAYBE NEEDED
		##if debug: print("imported_textures_path: ", imported_textures_path)
		##collection_scene_full_paths[collection_name] = collection_scene_full_paths_array.duplicate()
#
#
		##if collection_processing_count > 1: # Do not hold for first collection
			##if debug: print("Waiting to process ", collection_name, " collection")
			##await finished_processing_collection
			###await get_tree().process_frame
			##await get_tree().create_timer(5).timeout
			###if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		##if not imported_textures_path.is_empty():
		##if run_gltf_image_hash_check(imported_textures_path):
		#if debug: print("collection_scene_full_paths_array: ", collection_scene_full_paths_array)
### TEST skip and run direct multi-thread
		##if false:
		#if run_gltf_image_hash_check(collection_scene_full_paths_array):
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
			#
			#if collection_scene_full_paths_array.size() > 0:
			##if collection_scene_full_paths[collection_name].size() > 0:
				#cleanup_task_id2 = true
				##current_collection_name = collection_name # NOTE: To maintain same data through stack 
				#if debug: print("Starting image hashing and multi-threaded import stack for collection: ", collection_name)
				#mutex.lock()
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#mutex.unlock()
				##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths_array), collection_scene_full_paths_array.size())
				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths_array), collection_scene_full_paths_array.size())
#
				#if debug: print("waiting for image hashing to finish")
				##await wait_loop(task_id2, 10000, scenes_dir_path)
				#await finished_image_hashing
				#if debug: print("image hashing finished")
				#await get_tree().create_timer(15).timeout
#
				##scene_loading_complete = true
				#
				#mutex.lock()
				#var process_single_threaded_list_duplicate: Array[String] = process_single_threaded_list.duplicate()
				#mutex.unlock()
## TEST Load all single threaded
				##for scene_full_path: String in collection_scene_full_paths_array:
## TEST
				#for scene_full_path: String in process_single_threaded_list_duplicate:
					##load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
					#load_gltf_scene_instance(scene_full_path, imported_textures_path)
#
#
				##if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
				##for file in collection_scene_full_paths_array:
				#for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
					#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
						#EditorInterface.get_resource_filesystem().update_file(file)
#
				#EditorInterface.get_resource_filesystem().scan()
#
				#await EditorInterface.get_resource_filesystem().resources_reimported # NOTE: This may need more time for collections with many textures?
				## FIXME dest_md5 must not be matching up for Carpenters-workshop collection appears to be reimporting after textures imported when multi-thread runs below.
				##if debug: print("reimport finished")
#
				##await get_tree().create_timer(60).timeout
#
#
#
#
				##FIXME Maybe more time needed here or something else ERROR: Can't find file 'res://collections/third/textures/_0.png' during file reimport.
				##await get_tree().create_timer(15).timeout
#
				##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
				#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
#
				#
				##await wait_loop(task_id1, 10000, scenes_dir_path)
				##var wait_count: int = 0
				##while not WorkerThreadPool.is_group_task_completed(task_id1):
					##await get_tree().process_frame
					##wait_count += 1
					##if wait_count > 10000: # Consider a more robust timeout/error handling
						##push_warning("Hashing task timed out for: " + scenes_dir_path)
						##break
#
				##emit_signal("finished_processing_collection")
#
#
		#else:
#
			#task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
#
#
#
#
#
		###current_collection_name = collection_name # NOTE: To maintain same data through stack 
		##if debug: print("Collection contains textures, skipping image hash, starting multi-threaded import for collection: ", collection_name)
##
		###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, collection_name), collection_scene_full_paths[collection_name].size())
		### TODO CHUNK PROCESS LARGE COLLECTIONS
		##var initial_import: bool = false
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]): # NOTE: If no textures exists in the project collections then it's a new collection 
			##initial_import = true
		###task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
		##if initial_import:
##
			##if collection_scene_full_paths_array.size() > 200:
				##pass
			##else:
				##if collection_scene_full_paths_array.size() >= 100: # FIXME Without VRAM and Texture sizes really no way to set this accordingly
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import, false), collection_scene_full_paths_array.size())
				##else: # collection_scene_full_paths_array.size() < 50:
					##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
				##await finished_processing_collection
				##
		##else:
			##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
			##await finished_processing_collection
#
#
#
#
		##task_id1 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name), collection_scene_full_paths_array.size())
##
#
		##await wait_loop(task_id1, 10000, scenes_dir_path)
		###var wait_count: int = 0
		###while not WorkerThreadPool.is_group_task_completed(task_id1):
			###await get_tree().process_frame
			###wait_count += 1
			###if wait_count > 10000: # Consider a more robust timeout/error handling
				###push_warning("Hashing task timed out for: " + scenes_dir_path)
				###break
##
		###if debug: print("waiting for collection import stack to finish")
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###if debug: print("collection import stack finished")
		###call_deferred("deferred_finished_processing_collection_signal")
		##emit_signal("finished_processing_collection")
		###await get_tree().process_frame
##
		###WorkerThreadPool.wait_for_group_task_completion(task_id1)
		###call_deferred("deferred_finished_processing_collection_signal")
#
#
		### NOTE: WITH TWO COLLECTIONS THE FIRST WILL BE CREATING BUTTONS WHILE THE SECOND IS DOING MULTI-THREADED IMPORT IS THIS CAUSING CRASH?
		###if debug: print("Waiting for multi-threaded import for collection: ", current_sub_folder_name, " to finish.")
		#await finished_processing_collection
		#
#
		#
		#if debug: print("scene_lookup: ", scene_lookup.size())
		#if debug: print("finsihed waiting continuing process")
		##collection_processing_count -= 1 # Decrement count by 1 to allow collections opened after start to pass through import process
#
		#if not thumbnail_cache:
			#for scene_full_path in collection_scene_full_paths_array:
				##await get_tree().process_frame
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
## NOTE: if implemented will want to run after all collections opened and will then need to have imported_textures_path in a lookup per collection 
#
#
#
#
#
#
#
### WORKS!!!!!!! Now single background thread loading
###TEST 1 loading in textures from mulit-threaded loaded .glb
		###if false:
		##if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			##await get_tree().create_timer(5).timeout
			##mutex.lock()
			##for scene_full_path: String in scene_lookup.keys():
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			##mutex.unlock()
			##
### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			###if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			###for file in collection_scene_full_paths_array:
			##for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				##if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					##EditorInterface.get_resource_filesystem().update_file(file)
##
			##EditorInterface.get_resource_filesystem().scan()
##
			##await EditorInterface.get_resource_filesystem().resources_reimported
###TEST 1 loading in textures from mulit-threaded loaded .glb
#
#
#
### FIXME NOTE Run here after each individual collection collection_scene_full_paths_array or after all on scene_lookup?
###TEST 2 loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			###initial_import = false # Set to import textures
		###if run_gltf_image_hash_check(collection_scene_full_paths_array): # FIXME Broken does not detect or read correct?
			##
			###await get_tree().create_timer(5).timeout
			###mutex.lock()
			###for scene_full_path: String in scene_lookup.keys():
				###load_gltf_scene_instance_test(scene_full_path, imported_textures_path) 
			###mutex.unlock()
##
##
### FIXME MEMORY NOT RELEASED AFTER OVERWRITE OF SCENE_LOOKUP NEED TO RELOAD BUTTONS
			##await get_tree().create_timer(1).timeout
			###call_deferred("import_textures", collection_scene_full_paths_array, imported_textures_path)
			###call_thread_safe("import_textures", collection_scene_full_paths_array, imported_textures_path)
			##mutex.lock()
			##for scene_full_path: String in collection_scene_full_paths_array:
				###await get_tree().process_frame
				### NOTE: Give time for the last import to finish before starting next .5 seems to be shortest possible
				### NOTE: No timer also works and is much faster but will freeze editors main thread until complete.
				##await get_tree().create_timer(0.5).timeout 
				###var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
				####var wait_count: int = 0
				####while not WorkerThreadPool.is_task_completed(task):
					#####await get_tree().process_frame
					####await get_tree().create_timer(.1).timeout
					####wait_count += 1
					####if debug: print("wait_count: ", wait_count)
					####if wait_count > 100: # Consider a more robust timeout/error handling
						####push_warning("Wait time exceded for: " + scenes_dir_path)
						####break
				###WorkerThreadPool.wait_for_task_completion(task)
##
				##load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			##
			##file_bytes_lookup.clear()
			##mutex.unlock()
##
##
### FIXME CHECK IF NEEDED
### Reload scene buttons with lower vram
			###for button: Node in new_sub_collection_tab.h_flow_container.get_children():
				###if button and button is Button:
					###button.queue_free()
					##
##
##
			###for scene_view: Button in new_sub_collection_tab.h_flow_container.get_children():
				###scene_view.queue_free()
			##if not thumbnail_cache:
				##for scene_full_path in collection_scene_full_paths_array:
					###await get_tree().process_frame
					##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
##
##
##
##
##
			###mutex.lock()
			###for scene_full_path: String in collection_scene_full_paths_array:
				###await get_tree().process_frame
				###load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
			###mutex.unlock()
##
##
##
##
##
			###task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(imported_textures_path, collection_name, initial_import), collection_scene_full_paths_array.size())
##
			###
#### FIXME Get ERROR: Attempted to call reimport_files() recursively, this is not allowed. so maybe below not needed
			####if debug: print("collection_textures_paths[sub_folder_name]: ", collection_textures_paths[collection_name])
			####for file in collection_scene_full_paths_array:
			###for file in DirAccess.get_files_at(collection_textures_paths[collection_name]):
				###if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					###EditorInterface.get_resource_filesystem().update_file(file)
###
			###EditorInterface.get_resource_filesystem().scan()
###
			###await EditorInterface.get_resource_filesystem().resources_reimported
####TEST 2 loading in textures from mulit-threaded loaded .glb
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
		##await get_tree().process_frame
		#await get_tree().create_timer(5).timeout # NOTE: Add time between collections process
		#
		#if collection_queue.size() > 0:
			#if debug: print("Finished processing ", collection_name, " collection, emitting signal to start processing next collection.")
			#emit_signal("process_next_collection")
		#processing_collection = false
#
	#if collection_name == "" and collection_queue.size() > 0:
		#if debug: print("Finished processing project scenes, emitting signal to start processing collections.")
		#emit_signal("process_next_collection")
		#processing_collection = false
#
#
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
##func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
#func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
#
#
		##for texture: Texture2D in gltf_state.get_images():
			##if texture:
				##var image := texture.get_image()
				###if image and image.is_valid():
				##var png_bytes := image.save_png_to_buffer()
				##var image_hash := hash(png_bytes)
##
				##mutex.lock()
				##if not collection_hased_images.has(image_hash):
					##collection_hased_images.append(image_hash)
					##if not process_single_threaded_list.has(scene_full_path):
						##process_single_threaded_list.append(scene_full_path)
				##mutex.unlock()
#
#
#
#
#
#
#
#
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance(scene_full_path: String, imported_textures_path: String) -> void:
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
#
## TEST
		### ✅ Wrap the GLB scene in your own root node
		##var root_node := Node3D.new()
		##root_node.name = "WrappedGLBScene"
		##root_node.add_child(imported_scene)
		##imported_scene.owner = root_node  # Important for saving the scene later if needed
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = root_node
		##mutex.unlock()
## TEST
#
#
#
		##call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#
#func import_textures(collection_scene_full_paths_array: Array[String], imported_textures_path: String) -> void:
	#mutex.lock()
	#for scene_full_path: String in collection_scene_full_paths_array:
		##var task: int = WorkerThreadPool.add_task(load_gltf_scene_instance_test.bind(scene_full_path, imported_textures_path))
		##var wait_count: int = 0
		##while not WorkerThreadPool.is_task_completed(task):
			##await get_tree().process_frame
			##wait_count += 1
			##if debug: print("wait_count: ", wait_count)
			##if wait_count > 100: # Consider a more robust timeout/error handling
				##push_warning("Wait time exceded for: " + scenes_dir_path)
				##break
		##WorkerThreadPool.wait_for_task_completion(task)
#
		#load_gltf_scene_instance_test(scene_full_path, imported_textures_path)
	#mutex.unlock()
#
	#
	#file_bytes_lookup.clear()
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
##func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#func load_gltf_scene_instance_test(scene_full_path: String, imported_textures_path: String) -> void:
	##var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	#var gltf_state: GLTFState = GLTFState.new()
	#if not file_bytes_lookup.is_empty():
		#gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	#else:
		#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
#
			#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
#
#### FIXME reuse file_bytes from intial_import here 
	###var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	###if scene_file:
		###var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		###scene_file.close()
	###var gltf_state: GLTFState = GLTFState.new()
	##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
	###file_bytes_lookup[scene_full_path] = []
	###scene_lookup[scene_full_path].queue_free()
##
	###scene_lookup[scene_full_path].free()
	###scene_lookup.erase(scene_full_path)
	###await get_tree().process_frame
#
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	##call_deferred("deferred_write_textures_to_filesystem", file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, scene_full_path)
#
#
#
#
#
		###await get_tree().process_frame
		###mutex.lock()
		##gltf.append_from_buffer(file_bytes_lookup[scene_full_path], imported_textures_path, gltf_state, 8)
		###gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		####await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
###
###
#### TEST
		##### ✅ Wrap the GLB scene in your own root node
		####var root_node := Node3D.new()
		####root_node.name = "WrappedGLBScene"
		####root_node.add_child(imported_scene)
		####imported_scene.owner = root_node  # Important for saving the scene later if needed
####
		####mutex.lock()
		####scene_lookup[scene_full_path] = root_node
		####mutex.unlock()
#### TEST
###
###
###
		####call_deferred("generate_scene_deferred", scene_full_path, gltf, gltf_state)
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
### OVERWRITE
		###mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
##
##
##
		###mutex.lock()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#### THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##
#### TEST OVERWRITE?
		###mutex.lock()
		###var scene_lookup_dup = scene_lookup.duplicate()
		###scene_lookup_test[scene_full_path] = gltf.generate_scene(gltf_state)
		###mutex.unlock()
#
#
#
#
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
##
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
##
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
##
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
#
#
#
#
#
##func generate_scene_deferred(scene_full_path: String, gltf: GLTFDocument, gltf_state: GLTFState) -> void:
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
## TODO Added emit_signal("single_thread_process_finished") when count matches for loop size -1
#
#
## WORKS
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
##func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
## NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
#func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String) -> void:
#
	#var scene_full_path: String = collection_scene_full_paths_array[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
#
		#mutex.lock()
		#file_bytes_lookup[scene_full_path] = file_bytes
		#mutex.unlock()
#
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
## NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
#
	#
	#
	## NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	#if index == collection_scene_full_paths_array.size() -1:
		#if debug: print("index has reached collection size")
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#
#
#
#
### EDITED
### NOTE 1:10 to load ~ 1200 Synty assets
#### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
###func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, collection_name: String) -> void:
### NOTE: Set flag for either BASISU or UNCOMPRESSED based on collection size. No way to get system RAM and VRAM. 
##func multi_threaded_load_gltf_scene_instances(index: int, imported_textures_path: String, collection_name: String, initial_import: bool = false, uncompressed: bool = true) -> void:
	###if debug: print("current index: ", index)
	###if debug: print("collection_scene_full_paths[current_sub_folder_name].size() -1: ", collection_scene_full_paths[current_sub_folder_name].size() -1)
	##
##
	##var scene_full_path: String = collection_scene_full_paths_array[index]
##
	##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	##if scene_file:
		##var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##scene_file.close()
		##var gltf_state: GLTFState = GLTFState.new()
##
### TEST Copy textures to here and then combine after on single thread? will it work?
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
###TEST loading in textures from mulit-threaded loaded .glb
		###if false:
		###if run_gltf_image_hash_check(collection_scene_full_paths_array):
		### FIXME NOTE: If failed import then this will brake. (Will find .png images and will multi-thread try and create textures in filesystem)
		### Can we find if failed import and clear collections textures folder to reset this?
		###if run_gltf_image_hash_check(collection_textures_paths[collection_name]):
		##if initial_import:
			##if uncompressed:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
			##else:
				##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
##
		### FIXME Drag and Drop .glb scenes to collection will create duplicate textures and warning about UID duplicates. 
		### Possible solutions: Either set .glb textures not extracted on import /  move textures to collections/../textures / or reference in place X NO not this -> push_warning
		### CHECK will these be overwritten when below runs next restart? and will the textures still be connected to original .glb in project?
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		###await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
##
##
### NOTE: On inital import cannot expose to user because using embeded uncompressed textures not referencing the project collections textures
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
		##
		##
		###else: # For single threaded texture writes to filesystem
			###call_deferred("deferred_write_textures_to_filesystem", file_bytes, imported_textures_path, gltf_state, scene_full_path)
		##
		##
		##
		##
		##
		##
	### NOTE: Being run async will not necessarly be the last to run but with call_deferred should allow for threads to completely finish before signal is emitted
	##if index == collection_scene_full_paths_array.size() -1:
		##if debug: print("index has reached collection size")
		##call_deferred("deferred_finished_processing_collection_signal")
##
		##
##
##
##func deferred_write_textures_to_filesystem(file_bytes: PackedByteArray, imported_textures_path: String, gltf_state: GLTFState, scene_full_path: String) -> void:
	##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
##
	###mutex.lock()
	##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	###mutex.unlock()
###
###
###func deferred_finished_processing_collection_signal() -> void:
	###if debug: print("collection import stack finished")
	###emit_signal("finished_processing_collection")
#
#
#
#
##● Error append_from_buffer(bytes: PackedByteArray, base_path: String, state: GLTFState, flags: int = 0)
##
##Takes a PackedByteArray defining a glTF and imports the data to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_buffer() where to find dependencies and can be empty.
##
##
##● Error append_from_file(path: String, state: GLTFState, flags: int = 0, base_path: String = "")
##
##Takes a path to a glTF file and imports the data at that file path to the given GLTFState object through the state parameter.
##
##Note: The base_path tells append_from_file() where to find dependencies and can be empty.
#
#
#
#
#
#
#
#
#
#
#### Check if res:// textures contains .png files. Do not run image hash if .png exist
##func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	##if collection_textures_path == "res://collections/textures/":
		##return false
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##return false
##
	##return true
#
#
#func run_gltf_image_hash_check(collection_scene_full_paths_array: Array[String]) -> bool:
	#var collection_textures: Array[String] = collection_scene_full_paths_array.duplicate()
	#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
	#if collection_textures.size() > 0:
		#return false
#
	#return true
#
#
#
#
#func wait_loop(task_id: int, wait_time: int, scenes_dir_path: String) -> void: 
	#var wait_count: int = 0
	#while not WorkerThreadPool.is_group_task_completed(task_id):
		#await get_tree().process_frame
		#wait_count += 1
		#if debug: print("wait_count: ", wait_count)
		#if wait_count > wait_time: # Consider a more robust timeout/error handling
			#push_warning("Wait time exceded for: " + scenes_dir_path)
			#break
	#return
#endregion



















#region ORIGINAL GLTF IMPORT CODE REFERENCE
## ORIGINAL WORKS BUT STILL SOMETIMES WILL CRASH AND HAS DUPLICATES WHEN TWO OR MORE COLLECTIONS
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
#var collection_scene_full_paths: Array[String] = []
#
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
	#if scenes_dir_path == project_scenes_path:
#
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false
#
	#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	#if collection_textures_path == "res://collections/textures/":
		#pass
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#run_gltf_image_hash_check = false
#
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		#ran_task_id2 = true
		##gltf_file_paths.clear()
		##scene_lookup.clear()
		##var collection_scene_full_paths: Array[String] = []
		##collection_scene_full_paths = []
		#collection_scene_full_paths.clear()
		##collect_gltf_files(scenes_dir_path)
		#var imported_textures_path: String
#
#
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#collection_scene_full_paths.append(scene_full_path)
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#if run_gltf_image_hash_check:
			#
## NOTE CAUTION About this section Get files reimporting when this is run and godot freezes 
## NOTE: With await get_tree().process_frame and var start_time = Time.get_ticks_msec() removed works like commented out so that fixes this part
## NOTE When this section is comment out scan does not pick up textures in filesystem and get errors so the wait time here was giving the system time to do scan or something so add time below
			##var start_time = Time.get_ticks_msec()
			##await get_tree().process_frame
## NOTE: NO WILL INTERMITTENTLY FREEZE AND CRASH REGARDLESS IF COMMENT OUT OR NOT
#
			#task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf), collection_file_names.size())
#
			#var wait_count: int = 0
			#while not WorkerThreadPool.is_group_task_completed(task_id):
				#await get_tree().process_frame
				#wait_count += 1
				#if wait_count > 1000: # Consider a more robust timeout/error handling
					#push_warning("Hashing task timed out for: " + scenes_dir_path)
					#break
#
#
			#scene_loading_complete = true
			##var end_time = Time.get_ticks_msec()
			##var elapsed_time = end_time - start_time
## NOTE CAUTION About this section Get files reimporting when this is run and godot freezes
#
### TEST Process all single threaded
### NOTE: Still reimports :( even single threaded test so that is not it.
##
			##var process_single_threaded_list2: Array[String] = []
			##for file_name: String in collection_file_names:
				##if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
					###var scene_full_path = scenes_dir_path.path_join(file_name)
					##process_single_threaded_list2.append(scenes_dir_path.path_join(file_name))
##
##
##
			##for scene_full_path: String in process_single_threaded_list2:
### TEST
#
#
#
			### TEST TEMP Run all through and see if dest_md5 changes NOTE: When processing single image .import is not updated indicating that maybe the dest_md5 did not change
			#for scene_full_path: String in process_single_threaded_list:
				#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
#
## NOTE gave ERROR: Attempted to call reimport_files() recursively, this is not allowed. when enabled but get can't find files when disabled??
## INTERMITTEN ERROR ERROR: Can't find file 'res://collections/test/textures/_0.png' during file reimport. 
			#
			##EditorInterface.get_resource_filesystem().scan()
			#for file in DirAccess.get_files_at(collection_textures_path):
				#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
#
			#await EditorInterface.get_resource_filesystem().resources_reimported
#
			#await get_tree().process_frame # NOTE May require more gap time between this and multi-thread import
			## NOTE: SCAN must be finished and textures visible in filesystem before next step runs
			##await get_tree().create_timer(10).timeout # DO if scanning check or something?
#
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_file_names.size())
#
			#var wait_count2: int = 0
			#while not WorkerThreadPool.is_group_task_completed(task_id2):
				#await get_tree().process_frame
				#wait_count2 += 1
				#if wait_count2 > 10000:
					#break
#
		#else:
			##if debug: print("gltf_file_paths: ", gltf_file_paths.size())
			#if debug: print("collection_scene_full_paths: ", collection_scene_full_paths.size())
			#await get_tree().process_frame
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_file_names.size())
#
			#var wait_count: int = 0
			#while not WorkerThreadPool.is_group_task_completed(task_id2):
				#await get_tree().process_frame
				#wait_count += 1
				#if wait_count > 10000:
					#break
#
		#for scene_full_path in collection_scene_full_paths:
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument) -> void:
	#var scene_full_path: String = collection_scene_full_paths[index]
	##var scene_full_path: String = gltf_file_paths[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
### Initial single threaded loading of scenes with textures to import to filesystem
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
## TEST TEMP LOAD
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
## TEST TEMP LOAD
#
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
	## FIXME Maybe collect_gltf_files() not finished running when this is run with multiple collections open? 
	##if debug: print("gltf_file_paths: ", gltf_file_paths.size())
	#
	#var scene_full_path: String = collection_scene_full_paths[index]
	##var scene_full_path: String = gltf_file_paths[index]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
#endregion

#region Current Version 3 WORKING!!!! SINGLE COLLECTION!! PARTIAL MULTI COLLECTION IMPORT SUPPORT
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#var collection_scene_full_paths: Dictionary[int, Array] = {}
#var collection_textures_paths: Dictionary[int, String] = {} 
#var collection_id: int = 0
#var current_collection_id: int = -1
#
#
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
	#if scenes_dir_path == project_scenes_path:
#
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false
#
	## This gets overwritten too so needs to be lower and have id with dic
	#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	#if collection_textures_path == "res://collections/textures/":
		#pass
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#run_gltf_image_hash_check = false
#
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		#collection_id += 1
		#
		#ran_task_id2 = true
		#var imported_textures_path: String
#
#
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
		#await get_tree().create_timer(1).timeout
#
		##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		#collection_textures_paths[collection_id] = collection_textures_path
#
#
		#var collection_scene_full_paths_array: Array[String] = []
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#collection_scene_full_paths_array.append(scene_full_path)
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#collection_scene_full_paths[collection_id] = collection_scene_full_paths_array.duplicate()
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		#if run_gltf_image_hash_check:
#
			#
			#if collection_id > 1: # Do not hold for first collection
				#if debug: print("going to wait for finished_processing_collection")
				#await finished_processing_collection
				#if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
			#if collection_scene_full_paths[collection_id].size() > 0:
				#current_collection_id = collection_id # NOTE: To maintain same data through stack 
				#if debug: print("Starting collection_id: ", current_collection_id)
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths[current_collection_id]), collection_scene_full_paths[current_collection_id].size())
#
				#if debug: print("waiting for image hashing to finish")
				#await finished_image_hashing
				#if debug: print("image hashing finished")
#
			#scene_loading_complete = true
			#for scene_full_path: String in process_single_threaded_list:
#
				#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
#
			#if debug: print("collection_textures_paths[current_collection_id]: ", collection_textures_paths[current_collection_id])
			#for file in DirAccess.get_files_at(collection_textures_paths[current_collection_id]):
				#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
#
			##EditorInterface.get_resource_filesystem().scan()
#
			#await EditorInterface.get_resource_filesystem().resources_reimported
			#if debug: print("reimport finished")
#
			#await get_tree().process_frame
#
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_scene_full_paths[current_collection_id].size())
#
#
		#else:
			#if collection_id > 1: # Do not hold for first collection
				#if debug: print("going to wait for finished_processing_collection")
				#await finished_processing_collection
#
			#if debug: print("collection_scene_full_paths: ", collection_scene_full_paths.size())
#
			#current_collection_id = collection_id # NOTE: To maintain same data through stack 
			#if debug: print("Starting collection_id: ", current_collection_id)
#
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_scene_full_paths[current_collection_id].size())
#
#
		#await finished_processing_collection
		#for scene_full_path in collection_scene_full_paths[current_collection_id]:
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
#
	#var scene_full_path: String = collection_scene_full_paths[current_collection_id][index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
		#
	#if index == collection_scene_full_paths[current_collection_id].size() -1:
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")

#endregion

#region Version 4 WORKING CLEAN-UP AND MAKE MULTI-COLLECTION FUNCTIONAL 
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#
#
#
#var collection_scene_full_paths: Dictionary[int, Array] = {}
#var collection_textures_paths: Dictionary[int, String] = {} 
#var collection_id: int = 0
#var current_collection_id: int = -1
#
#
### TEST
##func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##pass
#
## FIXME CRASHES WHEN 3 COLLECTIONS OPEN AT START EVEN WITH ALL HAVING TEXTURES PRE-IMPORTED
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
#
	## FIXME Setup signal for when finished
	#if scenes_dir_path == project_scenes_path:
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false # FIXME Maybe don't need?
#
	## This gets overwritten too so needs to be lower and have id with dic
	##var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	##if collection_textures_path == "res://collections/textures/":
		##pass
	##else:
		##var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		##var collection_textures: Array[String]
		##collection_textures.assign(packed_collection_textures)
		##collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
##
		##if collection_textures.size() > 0:
			##run_gltf_image_hash_check = false
#
	## TODO can subfoldername can be used in place of collection_id
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		#collection_id += 1
		#
		#ran_task_id2 = true
		#var imported_textures_path: String
#
#
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # NOTE: Will ERROR If inside threaded function 
#
#
		#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
		#collection_textures_paths[collection_id] = collection_textures_path
#
#
		#var collection_scene_full_paths_array: Array[String] = []
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#collection_scene_full_paths_array.append(scene_full_path)
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#collection_scene_full_paths[collection_id] = collection_scene_full_paths_array.duplicate()
#
#
		#if collection_id > 1: # Do not hold for first collection
			#if debug: print("collection waiting to do image hashing")
			#await finished_processing_collection
			#if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
#
		## FIXME If first collection through has imported textures next one without gets skipped it seems
		#if run_gltf_image_hash_check(collection_textures_paths[collection_id]):
#
			#
			##if collection_id > 1: # Do not hold for first collection
				##if debug: print("collection waiting to do image hashing")
				##await finished_processing_collection
				##if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
#
			#if collection_scene_full_paths[collection_id].size() > 0:
				#current_collection_id = collection_id # NOTE: To maintain same data through stack 
				#if debug: print("Starting collection_id: ", current_collection_id)
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths[current_collection_id]), collection_scene_full_paths[current_collection_id].size())
#
				#if debug: print("waiting for image hashing to finish")
				#await finished_image_hashing
				#if debug: print("image hashing finished")
#
			#scene_loading_complete = true
			#for scene_full_path: String in process_single_threaded_list:
#
				#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
#
			#if debug: print("collection_textures_paths[current_collection_id]: ", collection_textures_paths[current_collection_id])
			#for file in DirAccess.get_files_at(collection_textures_paths[current_collection_id]):
				#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
#
			#EditorInterface.get_resource_filesystem().scan()
#
			#await EditorInterface.get_resource_filesystem().resources_reimported
			#if debug: print("reimport finished")
#
			##FIXME Maybe more time needed here or something else ERROR: Can't find file 'res://collections/third/textures/_0.png' during file reimport.
			#await get_tree().create_timer(5).timeout
#
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_scene_full_paths[current_collection_id].size())
#
#
		#else:
			##if collection_id > 1: # Do not hold for first collection
				##if debug: print("collection waiting to do multi-threading import")
				##await finished_processing_collection
#
			#if debug: print("collection_scene_full_paths: ", collection_scene_full_paths.size())
#
			#current_collection_id = collection_id # NOTE: To maintain same data through stack 
			#if debug: print("Starting collection_id: ", current_collection_id)
#
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_scene_full_paths[current_collection_id].size())
#
		## NOTE: WITH TWO COLLECTIONS THE FIRST WILL BE CREATING BUTTONS WHILE THE SECOND IS DOING MULTI-THREADED IMPORT IS THIS CAUSING CRASH?
		#await finished_processing_collection
		#for scene_full_path in collection_scene_full_paths[current_collection_id]:
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	#emit_signal("finished_image_hashing")
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
## This runs on main thread and is blocking run on single background thread?
## FIXME can be combined to one function with flag pass multi_threaded_load_gltf_scene_instances with flag to pass to call deferred
## FIXME Make reusable for on mouse_entered 360 scene import fallback when scene_lookup does not contain generated scene 
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY LOADING AND GENERATING SCENE IT WORKS TO SET THE DEST_MD5
		##mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
## THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
#
	#var scene_full_path: String = collection_scene_full_paths[current_collection_id][index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
		#
	#if index == collection_scene_full_paths[current_collection_id].size() -1:
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#
#
#func run_gltf_image_hash_check(collection_textures_path: String) -> bool:
	#if collection_textures_path == "res://collections/textures/":
		#return false
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#return false
			##run_gltf_image_hash_check = false
#
	#return true
#

#endregion

#region Version 2
#
## FIXME Will sometimes crash on start with large collection?
## FIXME Opening new collection will grab currently open collection and tack on new scene buttons? Maybe not clearing array?
## FIXME either collect_gltf_files or scene_lookup not being cleared between adding new collections to panel
## FIXME When to collections open get # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
## FIXME button label not being updated to hide if below min size to hide label
##var collection_scene_full_paths: Array[String] = []
#var collection_scene_full_paths: Dictionary[int, Array] = {}
#var collection_id: int = 0
#var current_collection_id: int = -1
##var ready_for_next_task: bool = true
#
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
	#if scenes_dir_path == project_scenes_path:
#
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false
#
	#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	#if collection_textures_path == "res://collections/textures/":
		#pass
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#run_gltf_image_hash_check = false
#
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		#collection_id += 1
		#
		#ran_task_id2 = true
		##gltf_file_paths.clear()
		##scene_lookup.clear()
		##var collection_scene_full_paths: Array[String] = []
		##collection_scene_full_paths = []
		##collection_scene_full_paths.clear()
		##collect_gltf_files(scenes_dir_path)
		#var imported_textures_path: String
#
#
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
		#var collection_scene_full_paths_array: Array[String] = []
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#collection_scene_full_paths_array.append(scene_full_path)
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#collection_scene_full_paths[collection_id] = collection_scene_full_paths_array.duplicate()
#
		#if run_gltf_image_hash_check:
#
#
#
## NOTE: while first collection in running in multi-thread function next collection runs the code above causing either crash or duplicate issues 
## So a count would need to be kept and the paths_for_hashing_task incremented for each collection or getting collection_scene_full_paths within the functions themselves setting a flag to only run once
## and resetting next function that runs
## FIXME A task is already running when i try to run another one so must wait for one multi-threaded task to finish before starting another one
			##var next_collection_wait_count: int = 0
			##while not ready_for_next_task:
				##await get_tree().process_frame
				##next_collection_wait_count += 1
				##if debug: print("holding for task to finish")
				##if next_collection_wait_count > 10000: # Consider a more robust timeout/error handling
					##push_warning("Next collection could not be loaded because last collection: " + scenes_dir_path + " did not finish.")
					##break
			#if debug: print("going to wait for finished_processing_collection")
			#if collection_id > 1: # Do not hold for first collection
				#await finished_processing_collection
				##WorkerThreadPool.wait_for_group_task_completion(task_id)
				#if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
				##await get_tree().create_timer(10).timeout
			#
			##var gltf: GLTFDocument = GLTFDocument.new()
			##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
			##var paths_for_hashing_task = collection_scene_full_paths.duplicate(true)
			#if collection_scene_full_paths[collection_id].size() > 0:
				##ready_for_next_task = false
				##var gltf: GLTFDocument = GLTFDocument.new()
				##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
				#current_collection_id = collection_id
				#if debug: print("Starting collection_id: ", current_collection_id)
				#collection_hased_images.clear()
				#process_single_threaded_list.clear()
				#task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf, collection_scene_full_paths[current_collection_id]), collection_scene_full_paths[current_collection_id].size())
				##task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(collection_scene_full_paths[current_collection_id]), collection_scene_full_paths[current_collection_id].size())
				#await finished_image_hashing
				#
				##var wait_count: int = 0
				##while not WorkerThreadPool.is_group_task_completed(task_id):
					##if debug: print("processing collection: " + str(current_collection_id) + " wait_count: " + str(wait_count))
					##await get_tree().process_frame
					##
					##wait_count += 1
					##
					##if wait_count > 10000: # Consider a more robust timeout/error handling
						##push_warning("Hashing task timed out for: " + scenes_dir_path)
						##break
			#else:
				#if debug: print("paths_for_hashing_task.size() not > 0")
				## Handle case where no hashable files were found if needed
				#pass
			##scene_loading_complete = true
			##WorkerThreadPool.wait_for_group_task_completion(task_id)
			##await get_tree().create_timer(5).timeout
			##ready_for_next_task = true
#
#
#
#
			##task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf), collection_file_names.size())
##
			##var wait_count: int = 0
			##while not WorkerThreadPool.is_group_task_completed(task_id):
				##await get_tree().process_frame
				##wait_count += 1
				##if wait_count > 1000: # Consider a more robust timeout/error handling
					##push_warning("Hashing task timed out for: " + scenes_dir_path)
					##break
#
#
#
#
#
#
#
#
			#scene_loading_complete = true
			###var end_time = Time.get_ticks_msec()
			###var elapsed_time = end_time - start_time
###NOTE CAUTION About this section Get files reimporting when this is run and godot freezes
##
### TEST Process all single threaded
### NOTE: Still reimports :( even single threaded test so that is not it.
##
			##var process_single_threaded_list2: Array[String] = []
			##for file_name: String in collection_file_names:
				##if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
					###var scene_full_path = scenes_dir_path.path_join(file_name)
					##process_single_threaded_list2.append(scenes_dir_path.path_join(file_name))
##
##
##
			##for scene_full_path: String in process_single_threaded_list2:
### TEST
#
#
#
			### TEST TEMP Run all through and see if dest_md5 changes NOTE: When processing single image .import is not updated indicating that maybe the dest_md5 did not change
			#for scene_full_path: String in process_single_threaded_list:
				#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
#
## NOTE gave ERROR: Attempted to call reimport_files() recursively, this is not allowed. when enabled but get can't find files when disabled??
## INTERMITTEN ERROR ERROR: Can't find file 'res://collections/test/textures/_0.png' during file reimport. 
			#
			##EditorInterface.get_resource_filesystem().scan()
			#for file in DirAccess.get_files_at(collection_textures_path):
				#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
#
			#await EditorInterface.get_resource_filesystem().resources_reimported
#
			#await get_tree().process_frame # NOTE May require more gap time between this and multi-thread import
			## NOTE: SCAN must be finished and textures visible in filesystem before next step runs
			##await get_tree().create_timer(10).timeout # DO if scanning check or something?
#
			##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_file_names.size())
			#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_scene_full_paths[current_collection_id].size())
 #
			#var wait_count2: int = 0
			#while not WorkerThreadPool.is_group_task_completed(task_id2):
				#await get_tree().process_frame
				#wait_count2 += 1
				#if wait_count2 > 10000:
					#break
#
		##else:
			###if debug: print("gltf_file_paths: ", gltf_file_paths.size())
			##if debug: print("collection_scene_full_paths: ", collection_scene_full_paths.size())
			##await get_tree().process_frame
			##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_file_names.size())
##
			##var wait_count: int = 0
			##while not WorkerThreadPool.is_group_task_completed(task_id2):
				##await get_tree().process_frame
				##wait_count += 1
				##if wait_count > 10000:
					##break
##
		##for scene_full_path in collection_scene_full_paths[current_collection_id]:
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
### NOTE: Required initial import step because set_handle_binary_image will write to filesystem and can not be multi-threaded
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
##func multi_threaded_gltf_image_hashing(index: int, paths_for_this_task: Array[String]) -> void:
	#
	### Use the passed-in array, not the member variable
	##if index >= paths_for_this_task.size():
		##push_error("Hashing thread index out of bounds: %d >= %d" % [index, paths_for_this_task.size()])
		##return # Avoid crash if something went wrong with task setup
	##var single_threaded_list: Array[String]
	##var collection_hased_images: Array[int]
#
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
#
	#var scene_full_path: String = paths_for_this_task[index]
#
	##var scene_full_path: String = collection_scene_full_paths[index]
	##var scene_full_path: String = gltf_file_paths[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##await get_tree().process_frame
#
		##if error == OK:
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
	#if index == paths_for_this_task.size() - 1:
		#call_deferred("deferred_emit_signal")
#
#
#func deferred_emit_signal() -> void:
	#if debug: print("Finished processing collection")
	##emit_signal("finished_processing_collection")
	#emit_signal("finished_image_hashing")
#
#
		##else:
			##push_error("GLTF append failed for %s with error %d" % [scene_full_path, error])
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
### TEST TEMP LOAD
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
### TEST TEMP LOAD
#
## NOTE 1:10 to load ~ 1200 Synty assets
### Multi-threaded loading of scenes that already have textures imported to the collections textures folder
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
	## FIXME Maybe collect_gltf_files() not finished running when this is run with multiple collections open? 
	##if debug: print("gltf_file_paths: ", gltf_file_paths.size())
	#var scene_full_path: String = collection_scene_full_paths[current_collection_id][index]
	##var scene_full_path: String = collection_scene_full_paths[index]
	##var scene_full_path: String = gltf_file_paths[index]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
		#
	#if index == collection_scene_full_paths[current_collection_id].size() -1:
		#call_deferred("deferred_finished_processing_collection_signal")
#
#
#func deferred_finished_processing_collection_signal() -> void:
	#if debug: print("collection import stack finished")
	#emit_signal("finished_processing_collection")
#


#endregion

#region Gemini 2.5 Pro Assisted

#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
	#if scenes_dir_path == project_scenes_path:
#
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			#await get_tree().create_timer(1).timeout
#
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	#var create_buttons: bool = true
	#var new_scene_view: Button = null
	#scene_loading_complete = false
#
	#var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
	#if collection_textures_path == "res://collections/textures/":
		#pass
	#else:
		#var packed_collection_textures: PackedStringArray = DirAccess.get_files_at(collection_textures_path)
		#var collection_textures: Array[String]
		#collection_textures.assign(packed_collection_textures)
		#collection_textures = collection_textures.filter(func(array_object) -> bool: return array_object.get_extension() == "png")
#
		#if collection_textures.size() > 0:
			#run_gltf_image_hash_check = false
#
#
	## Make collection_scene_full_paths a LOCAL variable for clarity within this function's scope
	#var local_collection_scene_full_paths: Array[String] = []
#
	#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
	#if collection_file_names.size() > 0:
		#ran_task_id2 = true # Consider if this flag needs better management
#
		#var imported_textures_path: String
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
		#for file_name: String in collection_file_names:
			#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf":
				#var scene_full_path = scenes_dir_path.path_join(file_name)
				#local_collection_scene_full_paths.append(scene_full_path) # Populate the local array
				## Determine imported_textures_path correctly for this specific collection
				#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		## === Hashing Task ===
		#if run_gltf_image_hash_check:
			## Create a copy of the paths specific to THIS task
			#var paths_for_hashing_task = local_collection_scene_full_paths.duplicate()
#
			## Ensure the task count matches the array size being processed
			#if paths_for_hashing_task.size() > 0:
				#task_id = WorkerThreadPool.add_group_task(
					#multi_threaded_gltf_image_hashing.bind(gltf, paths_for_hashing_task), # Bind the copy
					#paths_for_hashing_task.size() # Use the correct size
				#)
#
				#var wait_count: int = 0
				#while not WorkerThreadPool.is_group_task_completed(task_id):
					#await get_tree().process_frame
					#wait_count += 1
					#if wait_count > 1000: # Consider a more robust timeout/error handling
						#push_warning("Hashing task timed out for: " + scenes_dir_path)
						#break
				## NOTE: process_single_threaded_list is populated here by the threads
			#else:
				## Handle case where no hashable files were found if needed
				#pass
#
			#scene_loading_complete = true # This seems premature, maybe move after loading task?
#
			## --- Single-threaded processing ---
			## This uses process_single_threaded_list which was populated by the hashing threads
			## Ensure the mutex logic in hashing thread is correct for this.
			#var single_thread_list_copy = process_single_threaded_list.duplicate() # Process a stable copy
			#process_single_threaded_list.clear() # Clear the shared list for the next collection
			#for scene_full_path: String in single_thread_list_copy:
				 ## Pass the correct textures path for this collection
				#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
#
#
			## --- Filesystem updates (Main Thread - Correct) ---
			## ... (scan, update_file, await resources_reimported) ...
#
			#for file in DirAccess.get_files_at(collection_textures_path):
				#if file.get_extension() == "png": # TODO Add for other file types check if system imports under different file types?
					#EditorInterface.get_resource_filesystem().update_file(file)
#
			#await EditorInterface.get_resource_filesystem().resources_reimported
#
			#await get_tree().process_frame
#
#
		 ## === Loading Task (after hashing/importing) ===
		 ## Create a copy of the paths specific to THIS task
			#var paths_for_loading_task = local_collection_scene_full_paths.duplicate()
#
		 ## Ensure the task count matches the array size being processed
			#if paths_for_loading_task.size() > 0:
				#task_id2 = WorkerThreadPool.add_group_task(
					#multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, paths_for_loading_task), # Bind the copy
					#paths_for_loading_task.size() # Use the correct size
				#)
#
				#var wait_count2: int = 0
				#while not WorkerThreadPool.is_group_task_completed(task_id2):
					#await get_tree().process_frame
					#wait_count2 += 1
					#if wait_count2 > 10000: # Consider better timeout/error handling
						#push_warning("Loading task timed out for: " + scenes_dir_path)
						#break
			#else:
			  ## Handle case where no loadable files were found if needed
				#pass
#
		## === Loading Task (if hashing wasn't run) ===
		#else: # Not run_gltf_image_hash_check
			 ## Create a copy of the paths specific to THIS task
			#var paths_for_loading_task = local_collection_scene_full_paths.duplicate()
#
			#if debug: print("local_collection_scene_full_paths size: ", paths_for_loading_task.size()) # Debug with local copy size
			#await get_tree().process_frame
#
			#if paths_for_loading_task.size() > 0:
				#task_id2 = WorkerThreadPool.add_group_task(
					#multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path, paths_for_loading_task), # Bind the copy
					#paths_for_loading_task.size() # Use the correct size
				#)
#
				#var wait_count: int = 0
				#while not WorkerThreadPool.is_group_task_completed(task_id2):
					#await get_tree().process_frame
					#wait_count += 1
					#if wait_count > 10000: # Consider better timeout/error handling
						#push_warning("Loading task (no hash) timed out for: " + scenes_dir_path)
						#break
			#else:
				 ## Handle case where no loadable files were found if needed
				#pass
#
		## === Create Buttons (using the local list) ===
		#for scene_full_path in local_collection_scene_full_paths: # Iterate the local list
			## Pass necessary data to create_scene_buttons
			#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false) # Ensure new_scene_view is handled correctly
#
	## else: handle case where collection_file_names is empty
#
## ... (rest of your script) ...
#
#endregion





#
## NOTE: Added 'paths_for_this_task' argument
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument, paths_for_this_task: Array[String]) -> void:
	## Use the passed-in array, not the member variable
	#if index >= paths_for_this_task.size():
		#push_error("Hashing thread index out of bounds: %d >= %d" % [index, paths_for_this_task.size()])
		#return # Avoid crash if something went wrong with task setup
#
	#var scene_full_path: String = paths_for_this_task[index]
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
#
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
		## NOTE: This will get the first but multi threading will process and end with the last and import that one? maybe reason dest_md5 different
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			## Keep using mutex for shared resources like collection_hased_images
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				## Careful: process_single_threaded_list is also shared, ensure mutex covers its modification if needed elsewhere simultaneously
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
			#mutex.unlock()
#
#
#
### Initial single threaded loading of scenes with textures to import to filesystem
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		##await get_tree().process_frame
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#await get_tree().process_frame # NOTE: Avoids ERROR: scene/main/node.cpp:1779 - Index p_index = 1 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
## TEST TEMP LOAD
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
## TEST TEMP LOAD
#
#
## NOTE: Added 'paths_for_this_task' argument
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String, paths_for_this_task: Array[String]) -> void:
	## Use the passed-in array, not the member variable
	#if index >= paths_for_this_task.size():
		#push_error("Loading thread index out of bounds: %d >= %d" % [index, paths_for_this_task.size()])
		#return # Avoid crash
#
	#var scene_full_path: String = paths_for_this_task[index]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
#
		## Consider if reusing the 'gltf' instance here across threads is safe.
		## If GLTFDocument.append_from_buffer modifies internal state non-atomically,
		## you might need a mutex around this call or create a new GLTFDocument per thread.
		## However, often these methods are designed to be relatively self-contained per call.
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		## scene_lookup is shared, so mutex is essential
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()







# NOTE Importing all single threaded and then restarting and having all imported multi-thread does not update .import!!!
# I could leave it it in this working state as initial load will be slow and the after all fast and is working no errors or crashes
# NOTE Something with actually loading the scenes and displaying them so maybe textures do need to be loaded to set the dest.md5 or something
# BUT GET: FIXED by await get_tree().process_frame after gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
  #ERROR: scene/main/node.cpp:1779 - Index p_index = 0 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
  #ERROR: scene/main/node.cpp:1685 - Parameter "p_child" is null.
  #ERROR: scene/main/node.cpp:1779 - Index p_index = 0 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
  #ERROR: scene/main/node.cpp:1685 - Parameter "p_child" is null.
  #ERROR: scene/main/node.cpp:1779 - Index p_index = 0 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
  #ERROR: scene/main/node.cpp:1685 - Parameter "p_child" is null.
  #ERROR: Attempted to call reimport_files() recursively, this is not allowed.

# NOTE something with reastarting after importing assets causes this to work SO longer delay load assets or something? 






	#
	## TODO REVISIT INTIAL LOADING ON MULTI THREAD NOTE: IF THERE WAS A WAY TO WHILE PARSING SINGLE THREAD TO CHECK IF THE DEPENDNCIES ARE IN THE COLLECTIONS/TEXTURES FOLDER LOCATION THEN ADD AS TASK TO MULTI-THREAD AND SKIP SINGLE THREAD PROCESSING?
	## BUT YOU CAN'T KNOW UNTIL AFTER YOU HAVE PARSED THE GLTFSTATE TO GLTFDOCUMENT WITH APPEND_FROM_BUFFER???
	#else:
		#if collection_file_names.size() > 0:
			#if debug: print("processing collection files")
			## FIXME TODO Clean up and only use collect_gltf_files or DirAccess.get_files_at(scenes_dir_path)
			#gltf_file_paths.clear()
			#collect_gltf_files(scenes_dir_path)
			#
			## FIXME TODO CHECK IF CAN COMBINE WITH var collection_textures_path: String = project_scenes_path.path_join(scenes_dir_path.split("/")[-1].path_join("textures".path_join("/")))
			#var imported_textures_path: String
			#
#
			#var gltf: GLTFDocument = GLTFDocument.new()
			#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
			#
#
			#
			#for file_name: String in collection_file_names:
				#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
					#var scene_full_path = scenes_dir_path.path_join(file_name)
					#imported_textures_path = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
			#if run_gltf_image_hash_check:
				#if debug: print("running gltf_image_hash_check")
				#
		##
				###gltfdocuments.clear()
#
#
				##await get_tree().process_frame
				##var wait_count1: int = 0
				##while EditorInterface.get_resource_filesystem().get_scanning_progress() != 1:
					##await get_tree().process_frame
					##wait_count1 += 1
					##if debug: print("wait_count: ", wait_count1)
					##if wait_count1 > 100:
						##break
#
#
				### DO hashing of imported_textures_path after initial scene import
				##var image_paths: PackedStringArray = DirAccess.get_files_at(imported_textures_path)
				##for image_path: String in image_paths:
					##if image_path.get_extension() == "png":
						##var texture := CompressedTexture2D.new()
						##texture = load(imported_textures_path + image_path)
						##var image: Image = texture.get_image()
						##if image:
							##image.decompress()
							###image.convert(Image.FORMAT_RGBA8)
				##
							### Get raw pixel data as bytes (this is content-based)
							##var bytes := image.get_data()
				##
							### Hash the actual byte content
							##var image_hash := hash(bytes)
							##if debug: print("image_hash: ", image_hash)
#
							##if not gltf_images.has(image_hash):
								##mutex.lock()
								##gltf_images[image_hash] = texture
								##mutex.unlock()
#
#
					##var image := texture.get_image()
					##image.convert(Image.FORMAT_RGBA8)
		##
					### Get raw pixel data as bytes (this is content-based)
					##var bytes := image.get_data()
		##
					### Hash the actual byte content
					##var image_hash := hash(bytes)
		##
					##if not gltf_images.has(image_hash):
						##mutex.lock()
						##gltf_images[image_hash] = texture
						##mutex.unlock()
#
				#var start_time = Time.get_ticks_msec()
				#if debug: print("collection_file_names.size(): ", collection_file_names.size())
				##var thread_count := OS.get_processor_count()
				##if debug: print("thread_count: ", thread_count)
				##if collection_file_names.size() > 0:
					###ran_task_id2 = true
					##gltf_file_paths.clear()
					##collect_gltf_files(scenes_dir_path)
					##if debug: print("gltf_file_paths size: ", gltf_file_paths.size())
					##if debug: print("gltf_file_paths size 10 chunk: ", gltf_file_paths.size() % 10)
					#
					#
				## NOTE: STEP 1: | INITIAL IMPORT | Multi-thread through all scene files and get all scenes with new textures that need to be imported single thread to filesystem
				## We hash the images as we go through the scenes so we can get matching and add them to an array, if a new image not in array is found we also get the scene that the textures were attached to
				#await get_tree().process_frame
				##var gltf: GLTFDocument = GLTFDocument.new()
				##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
				#
				##task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded.bind(scenes_dir_path, collection_file_names, gltf), collection_file_names.size())
				##task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, collection_file_names.size())
				##task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, file_names.size())
				#
				#ran_task_id2 = true
				#task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing.bind(gltf), collection_file_names.size())
				##task_id = WorkerThreadPool.add_group_task(multi_threaded_gltf_image_hashing, collection_file_names.size())
#
				#var wait_count: int = 0
				#while not WorkerThreadPool.is_group_task_completed(task_id):
					#await get_tree().process_frame
					#
					## NOTE: Create function to pull in thumbnails if they exist and display those here
					#
					#
					##await get_tree().create_timer(1).timeout
					## NOTE: Will only run during while loop, but should always finish before loading scenes
					## Check if thumbnail cache exists if they don't wait for finish and then create them, if they do load them while still in while loop
					## load what does exist as being checked?
					##if create_buttons:
						##create_buttons = false
						###var new_scene_view: Button = null
						### Do check and return if no thumbnail and load not finished
						### If there is thumbnails load them but don't use scene_lookup dict
						##for file_name: String in collection_file_names:
							###if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
							##var scene_full_path = scenes_dir_path.path_join(file_name)
							##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
					##if thumbnail_cache and load_cache:
						##load_cache = false
						###if debug: print("thumbnail_path_lookup.size: ", thumbnail_path_lookup.size())
						##for scene_full_path: String in thumbnail_cache_path_lookup.keys():
							##load_thumbnails(scene_full_path, new_sub_collection_tab, thumbnail_cache_path_lookup[scene_full_path])
						#
					##pause_for_collection_finish = true
					##if debug: print("wait_count for multi-thread scene import: ", wait_count)
					## Can load in thumbnails from cache during this time
					#wait_count += 1
					#if wait_count > 1000:
						#break
				##scene_loading_complete = true
				###pause_for_collection_finish = false
				##else:
				#scene_loading_complete = true
				#var end_time = Time.get_ticks_msec()
				#var elapsed_time = end_time - start_time
				#if debug: print("multithreading load time: ", elapsed_time, " milliseconds")
				##for index: int in file_bytes_array.size():
				##var scene_view: Button = file_bytes_array.pop_back()
				##var gltf: GLTFDocument = GLTFDocument.new()
				##for file_bytes: PackedByteArray in file_bytes_array:
					##call_me(file_bytes, scene_full_path, gltf)
				#if debug: print("scene_loading_complete")
				#if debug: print("collection_hased_images: ", collection_hased_images.size())
				#if debug: print("process_single_threaded_list: ", process_single_threaded_list) # NOTE: CAUSING ISSUE OF Task 'reimport' already exists.
				#if debug: print("gltf_state_lookup keys: ", gltf_state_lookup.keys())
				#
##
##
				###for file_name: String in collection_file_names:
					###if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
						###var scene_full_path = scenes_dir_path.path_join(file_name)
						###load_gltf_scene_instance(scene_full_path) # Load all textures to filsystem first and do scan to import them so that generate_scene sees them
				### NOTE: STEP 2: | INITIAL IMPORT | Process Single threaded only scenes that have new image textures to import FIXME DO on background thread?
				#for scene_full_path: String in process_single_threaded_list:
					#load_gltf_scene_instance(scene_full_path, gltf, imported_textures_path)
				## NOTE: STABLE TO THIS POINT MAX VRAM ~5.1 ON SYNTY SET 100
				#
				## FIXME NEED TO TRIGGER REIMPORT OF TEXTURE FILES THAT HAVE BEEN ADDED
				##
				#EditorInterface.get_resource_filesystem().scan()
				##await get_tree().create_timer(5).timeout 
				##EditorInterface.get_resource_filesystem().reimport_files(DirAccess.get_files_at(collection_textures_path))
				#
				## FIXME Issue here where reimport starts and 
				## FIXME Find best way to set this to required min if to short get can't find error and if also to short get task "reimport" already exists
				## FIXME Even with long wait still get ERROR: Task 'reimport' already exists.
				## and   ERROR: editor/progress_dialog.cpp:217 - Condition "!tasks.has(p_task)" is true. Returning: canceled
				## ERROR: editor/progress_dialog.cpp:240 - Condition "!tasks.has(p_task)" is true.
#
				#if debug: print("collection_gltf_images: ", collection_gltf_images)
				#await get_tree().create_timer(5).timeout # Time required for scan to update and import new textures, #TODO find way to make accurate
				##ran_task_id2 = true # TEST
				##task_id = WorkerThreadPool.add_group_task(probably_wont_work, gltfdocuments.size())
				###var wait_count: int = 0
				##while not WorkerThreadPool.is_group_task_completed(task_id):
					##if debug: print("scene_lookup.size(): ", scene_lookup.size())
					##await get_tree().process_frame
					##wait_count += 1
					##if wait_count > 10000:
						##break
				##var start_time = Time.get_ticks_msec()
#
#
#
				##for gltf_doc: GLTFDocument in gltfdocuments.keys():
					##var gltf_state: GLTFState = gltfdocuments[gltf_doc][0]
					##var scene_full_path: String = gltfdocuments[gltf_doc][1]
					##if debug: print("scene_full_path: ", scene_full_path)
					###await get_tree().create_timer(0.1).timeout
					##await get_tree().process_frame
					##scene_lookup[scene_full_path] = gltf_doc.generate_scene(gltf_state) # Not heavy load
				###var end_time = Time.get_ticks_msec()
				###var elapsed_time = end_time - start_time
				##if debug: print("gltf.generate_scene(gltf_state) load time: ", elapsed_time, " milliseconds for: ", gltfdocuments.size(), " scenes")
#
### FIXME THE TEXTURES ARE COPIED INTO THE FILESYSTEM BEFORE THIS POINT BUT NOT PROPERLY IMPORTED FREEZING EVERYTHING BELOW 
### FIXME ADD BELOW code as function to reuse here
				### NOTE: Then run multi-threading on remaining scenes in collection FIXME Order of buttons on first runs will be out of order or maybe not if I just run through them all again
				### TODO Create skip flag if collection/textures has images TODO Reset skip flag if new scenes added to collection
				### Make sure last task_id is finished
				###if run_gltf_image_hash_check:
				### NOTE: Reuse data from first scan?
				### NOTE: STEP 3: | INITIAL IMPORT | FIXME ERRORS I THINK AS A RESULT OF PROCESSING THE FILES THAT WE JUST PROCESSES SINGLE THREAD ABOVE AGAIN HERE?
				###WorkerThreadPool.wait_for_group_task_completion(task_id)
				##await get_tree().process_frame
				##var gltf2: GLTFDocument = GLTFDocument.new()
				##gltf2.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
##
				##task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf2, imported_textures_path), collection_file_names.size())
##
				##var wait_count2: int = 0
				##while not WorkerThreadPool.is_group_task_completed(task_id2):
					##await get_tree().process_frame
					##
					### NOTE: Create function to pull in thumbnails if they exist and display those here
					##
					###await get_tree().create_timer(1).timeout
					### NOTE: Will only run during while loop, but should always finish before loading scenes
					### Check if thumbnail cache exists if they don't wait for finish and then create them, if they do load them while still in while loop
					### load what does exist as being checked?
					###if create_buttons:
						###create_buttons = false
						####var new_scene_view: Button = null
						#### Do check and return if no thumbnail and load not finished
						#### If there is thumbnails load them but don't use scene_lookup dict
						###for file_name: String in collection_file_names:
							####if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
							###var scene_full_path = scenes_dir_path.path_join(file_name)
							###create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
##
					###if thumbnail_cache and load_cache:
						###load_cache = false
						####if debug: print("thumbnail_path_lookup.size: ", thumbnail_path_lookup.size())
						###for scene_full_path: String in thumbnail_cache_path_lookup.keys():
							###load_thumbnails(scene_full_path, new_sub_collection_tab, thumbnail_cache_path_lookup[scene_full_path])
						##
					###pause_for_collection_finish = true
					###if debug: print("wait_count for multi-thread scene import: ", wait_count)
					### Can load in thumbnails from cache during this time
					##wait_count2 += 1
					##if wait_count2 > 1000:
						##break








			#else:
				## NOTE: Then run multi-threading on remaining scenes in collection FIXME Order of buttons on first runs will be out of order or maybe not if I just run through them all again
				## TODO Create skip flag if collection/textures has images TODO Reset skip flag if new scenes added to collection
				## Make sure last task_id is finished
				##if run_gltf_image_hash_check:
					##WorkerThreadPool.wait_for_group_task_completion(task_id)
				#await get_tree().process_frame
				##var gltf: GLTFDocument = GLTFDocument.new()
				##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
				#task_id2 = WorkerThreadPool.add_group_task(multi_threaded_load_gltf_scene_instances.bind(gltf, imported_textures_path), collection_file_names.size())
#
				#var wait_count: int = 0
				#while not WorkerThreadPool.is_group_task_completed(task_id2):
					#await get_tree().process_frame
					#
					## NOTE: Create function to pull in thumbnails if they exist and display those here
					#
					##await get_tree().create_timer(1).timeout
					## NOTE: Will only run during while loop, but should always finish before loading scenes
					## Check if thumbnail cache exists if they don't wait for finish and then create them, if they do load them while still in while loop
					## load what does exist as being checked?
					##if create_buttons:
						##create_buttons = false
						###var new_scene_view: Button = null
						### Do check and return if no thumbnail and load not finished
						### If there is thumbnails load them but don't use scene_lookup dict
						##for file_name: String in collection_file_names:
							###if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
							##var scene_full_path = scenes_dir_path.path_join(file_name)
							##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
					##if thumbnail_cache and load_cache:
						##load_cache = false
						###if debug: print("thumbnail_path_lookup.size: ", thumbnail_path_lookup.size())
						##for scene_full_path: String in thumbnail_cache_path_lookup.keys():
							##load_thumbnails(scene_full_path, new_sub_collection_tab, thumbnail_cache_path_lookup[scene_full_path])
						#
					##pause_for_collection_finish = true
					##if debug: print("wait_count for multi-thread scene import: ", wait_count)
					## Can load in thumbnails from cache during this time
					#wait_count += 1
					#if wait_count > 10000:
						#break
#
#
#
		##
		##for gltf: GLTFDocument in gltfs:
			##
			##if debug: print("gltf: ", gltf)
		#
		#
		#
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
		##var count: int  = 0
		##for scene_full_path: String in gltf_image_lookup:
			##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
			###if debug: print("gltf_image_lookup[scene_full_path].get_property_list(): ", gltf_image_lookup[scene_full_path].get_property_list())
			##
			##for image
			##gltf_image_lookup[scene_full_path].save_png(imported_textures_path + "/" + "_" + str(count) + ".png")
			##count += 1
#
#
		##EditorInterface.get_resource_filesystem().scan()
		##await EditorInterface.get_resource_filesystem().filesystem_changed
		###await get_tree().process_frame
		##await get_tree().create_timer(5).timeout
		##for gltf: GLTFDocument in gltfdocuments.keys():
			##var gltf_state: GLTFState = gltfdocuments[gltf][0]
			##var scene_full_path: String = gltfdocuments[gltf][1]
			##if debug: print("scene_full_path: ", scene_full_path)
			###await get_tree().create_timer(0.1).timeout
			##await get_tree().process_frame
			##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
#
#
#
#
		### After all the scene files file_bytes are read in multi-thread use main thread to copy textures to filesystem and create Node in scene_lookup
		###var gltf: GLTFDocument = GLTFDocument.new()
		##for scene_full_path: String in file_bytes_lookup.keys():
			##if scene_full_path != "":
				###if debug: print("scene_full_path: ", scene_full_path)
				##call_me(file_bytes_lookup[scene_full_path], scene_full_path)
		##
		### file_bytes_lookup no longer needed
		##file_bytes_lookup.clear()
		#
		##await get_tree().process_frame
#
#
#
#
## FIXME I think scene_lookup getting cleared which dumps memory to 2.2 but also no thumbnails get loaded but that is when there is scene_data_cache
	##if not thumbnail_cache:
	## Skip creating new_scene_view button if cache exists
#
	##if reload_scene_view_buttons_func:
		##if debug: print("second run")
		##for scene_full_path in scene_lookup.keys():
			##
			##create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
		## IMPORTANT KEEP
			#await get_tree().process_frame
			#for scene_full_path in scene_lookup.keys():
				#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)



	#scene_lookup.clear()

	#if ran_task_id2: # Hold here until group task_id finishes while not blocking main thread
		#var wait_count: int = 0
		#while not WorkerThreadPool.is_group_task_completed(task_id):
			#await get_tree().process_frame
			#if debug: print("wait_count: ", wait_count)
			#wait_count += 1
			#if wait_count > 10000:
				#break



	#if gltf_file_paths.size() == 0:
		#ran_task_id2 = false
#
	## FIXME Run task if gltf_file_paths.size() != 0 or thumbnails do not exist for collection
	#if ran_task_id2: # Cache is built so will not run even though thumbnails no not exist so need to FIXME
		#await get_tree().process_frame # NOTE: Seems to sometimes crash on start without process_frame
		#task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, gltf_file_paths.size())



		
		
		#if debug: print("THIS IS THE FULL PATH scene_full_path: ", scene_full_path)
		#var loaded_scene = null
	#for scene_full_path in scene_lookup.keys():
		#var new_scene_view: Button = null
		#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)


## TEST WORKING EXAMPLE MULTI THREADING (NOT USED)
	#var new_scene_view: Button = null
	#var bound_callable = Callable(multi_test.bind(scenes_dir_path, new_sub_collection_tab, new_scene_view, false))
	##var bound_callable = Callable(multi_test.bind(scenes_dir_path, new_sub_collection_tab))
##
	###var task_id = WorkerThreadPool.add_group_task(create_scene_buttons.bind(scene_full_path, new_sub_collection_tab, new_scene_view, false), file_names.size())
	#var task_id = WorkerThreadPool.add_group_task(bound_callable, file_names.size())
	 ###Other code...
	#WorkerThreadPool.wait_for_group_task_completion(task_id)
	 ###Other code that depends on the enemy AI already being processed.






	##for file_name in get_all_in_folder(scenes_dir_path):
		## NOTE: If the file path ends with "textures" skip it
		#if full_path_split(file_name, true)[0] != "textures":
			#if debug: print("file_name : ", file_name)
			#if debug: print("scenes_dir_path: ", scenes_dir_path)
			#var scene_full_path = scenes_dir_path.path_join(file_name)
			#var loaded_scene = null
			#create_scene_buttons(loaded_scene, scene_full_path, new_sub_collection_tab, false)




#func probably_wont_work(index: int) -> void:
	##
	##for gltf: GLTFDocument in gltfdocuments.keys():
	#var gltf_state: GLTFState = gltfdocuments[gltfdocuments.keys()[index]][0]
	#var scene_full_path: String = gltfdocuments[gltfdocuments.keys()[index]][1]
	#if debug: print("scene_full_path: ", scene_full_path)
	##await get_tree().create_timer(0.1).timeout
	#await get_tree().process_frame
	#scene_lookup[scene_full_path] = gltfdocuments.keys()[index].generate_scene(gltf_state)


#var sub_collection_scene_count: int = 0
#var count_finished :int = 0
## ORIGINAL WORKING
#func add_scenes_to_collections(sub_folders_path: String, sub_folder_name: String, new_sub_collection_tab: Control):
	##var scenes_dir_path: String = sub_folders_path + sub_folder_name
	#var scenes_dir_path: String = sub_folders_path.path_join(sub_folder_name)
	#if scenes_dir_path == project_scenes_path:
#
		#while scene_snap_plugin_ref.get_editor_interface().get_resource_filesystem().is_scanning():
			##if debug: print("waiting for import to finish")
			#await get_tree().create_timer(1).timeout
#
#
	## Return only files no directories
	##include_dir = false
	## FIXME FIXME FIXME FIXME FIXME
	##load_scene_primer(scenes_dir_path)
	#
	## Initialize previous_scenes_dir_path to scenes_dir_path
	#if initialize_dir_path:
		#previous_scenes_dir_path = scenes_dir_path
		#initialize_dir_path = false
#
	#
	##await restore_saved_data()
#
#
	#sub_collection_scene_count += DirAccess.get_files_at(scenes_dir_path).size()
#
	##if debug: print("RESULTS: ", get_all_in_folder(scenes_dir_path))
	##await get_tree().create_timer(1).timeout
	##for file in DirAccess.get_files_at(scenes_dir_path):
	#if debug: print("DirAccess.get_files_at(scenes_dir_path): ", DirAccess.get_files_at(scenes_dir_path).size())
	#for file_name: String in DirAccess.get_files_at(scenes_dir_path):
		#var scene_full_path = scenes_dir_path.path_join(file_name)
		##if debug: print("THIS IS THE FULL PATH scene_full_path: ", scene_full_path)
		##var loaded_scene = null
		#var new_scene_view: Button = null
		#create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)
#
#
#
	###for file_name in get_all_in_folder(scenes_dir_path):
		### NOTE: If the file path ends with "textures" skip it
		##if full_path_split(file_name, true)[0] != "textures":
			##if debug: print("file_name : ", file_name)
			##if debug: print("scenes_dir_path: ", scenes_dir_path)
			##var scene_full_path = scenes_dir_path.path_join(file_name)
			##var loaded_scene = null
			##create_scene_buttons(loaded_scene, scene_full_path, new_sub_collection_tab, false)

#endregion

# Run the entire stack here if thumbnail exists??

#func do_thumbnail_check(collection_file_names: PackedStringArray, scenes_dir_path: String) -> void:
	#var thumbnail_cache: bool = false
	#var load_cache: bool = true
	#var thumbnail_count: int = 0
	#thumbnail_cache_path_lookup.clear()
#
	#for file_name: String in collection_file_names:
		#if file_name.get_extension() == "glb" or file_name.get_extension() == "gltf": # or file_name.get_extension() == "obj":
			#var scene_full_path = scenes_dir_path.path_join(file_name)
			##gltf_file_paths.append(scene_full_path)
			#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
			#thumbnail_cache_path_lookup[scene_full_path] = thumbnail_cache_path
			#if user_dir.file_exists(thumbnail_cache_path):
				#thumbnail_count += 1
				## Change flag if all files in the collection have a thumbnail
				#if thumbnail_count == collection_file_names.size():
					#thumbnail_cache = true



func load_thumbnails(scene_full_path: String, new_sub_collection_tab: Control, thumbnail_cache_path: String, create_button: bool = true) -> void:
	var new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
	var new_sprite = Sprite2D.new()
	var image: Image = Image.load_from_file(thumbnail_cache_path)
	image.clear_mipmaps()
	image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
	new_sprite.texture = ImageTexture.create_from_image(image)
	new_sprite.centered = false
	# Set based off of scene_view scale_size and matches SubViewportContainer position
	new_sprite.position = Vector2(0.0, 13.0)
	new_scene_view.child_sprite = new_sprite
	new_scene_view.add_child(new_sprite)


	if create_button:
		create_scene_buttons(scene_full_path, new_sub_collection_tab, new_scene_view, false)



func update_texture_dependencies(scene_full_path: String) -> void:
	#if debug: print("getting dependencies")
	for dep in ResourceLoader.get_dependencies(scene_full_path):
		#if debug: print(dep)
		#if debug: print(dep.get_slice("::", 0)) # Prints UID.
		#if debug: print(dep.get_slice("::", 2)) # Prints path.
		var dep_path: String = dep.get_slice("::", 2)
		var dep_uid: String = dep.get_slice("::", 0)
		if debug: print("DEP_PATH!!!!!!!!!!: ", dep_path)
		var dep_file_name: PackedStringArray = full_path_split(dep_path, true)
		#if debug: print("dep_file_name: ", dep_file_name)
		#if debug: print("texture_file_names: ", texture_file_names)
		if texture_file_names.has(dep_file_name[0]):
			if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
				ResourceUID.set_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
				#if debug: print("ResourceUID has id: ", dep.get_slice("::", 0))
			else:
				ResourceUID.add_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
				#if debug: print("ResourceUID does not have id: ", dep.get_slice("::", 0))


func _on_scene_file_name(file_path: String):
	file_full_path = file_path



##func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, scene_name_split: PackedStringArray) -> Button:
#func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, file_name_split: PackedStringArray, new_scene: bool) -> Button:
	#var new_scene_view: Button = SCENE_VIEW.instantiate()
#
	#if not new_scene:
		#if new_scene_view:
			#new_scene_view.add_favorite.connect(add_scene_button_to_favorites)
			#new_scene_view.remove_favorite.connect(remove_scene_button_from_favorites)
			#new_scene_view.scene_focused.connect(update_current_scene_path)
#
			#new_sub_collection_tab.find_child("HFlowContainer").add_child(new_scene_view)
#
			#if new_sub_collection_tab != favorites and last_session_favorites.has(scene_full_path):
				#if scene_full_path != "":
					#new_scene_view.heart_split_panel.button_pressed = true
					##Cycle back trough and create buttons for Favorite Tab
					#add_scene_button_to_favorites(scene_full_path, false)
			#
			#if new_sub_collection_tab == favorites:
				#new_scene_view.heart_split_panel.button_pressed = true
				#new_scene_view.clear_favorite.connect(modify_heart_from_matching_favorite)
#
			#new_scene_view.owner = self
			##new_scene_view.name = scene_name_split[0]
			#new_scene_view.name = file_name_split[0]
			#new_scene_view.scene_full_path = scene_full_path
#
			## NOTE added to scene_view_instances to enable view sizing
			#scene_view_instances.append(new_scene_view)
#
	#return new_scene_view

var last_button_index: int = -1
var selected_buttons: Array[Node] = []
#var selected_buttons: Array[Node] = []

func clear_selected_buttons() -> void:
	
	# NOTE Create duplicate, reading from array while removing entries will cause issues.
	#for button: Button in selected_buttons.duplicate():
	for button in selected_buttons.duplicate():
		if button and button is Button:
			update_scene_view_button(button, false)

	selected_buttons.clear()
	selected_buttons = []


func select_all_visible_buttons() -> void:
	pass

# when switching tabs clear selected_buttons and load up only that tabs selected objects
#region Duplicate code from sub_collection_tab

#var selected_button_style_box = preload("res://addons/scene_snap/resource/scene_view_selected_stylebox.tres")
#var selected_button_style_box = preload("uid://ct6u0av44vyyi")

#func remove_selected_buttons() -> void:
	#_on_selected_texture_button_toggled(toggled_on: bool)
#
#var selected_scene_buttons: Array[Node] = []

# FIXME Cannot select and then hold shift and select more
func get_selected_buttons(button: Button, scene_buttons: Array[Node], selected: bool) -> void:
	#var last_button: Button
	##if button in group of selected_buttons
	#if selected_buttons.has(button):
		#for selected_button: Button in selected_buttons:
			#update_scene_view_button(selected_button, selected)

	if Input.is_key_pressed(KEY_SHIFT): # Shift and then selecting another box NOTE: Not related to MultiSelectBox
		var selected_button_index: int = button.get_index()

		if last_button_index == -1:
			last_button_index = selected_button_index

		if last_button_index < selected_button_index: # Normal left to right selection (top down)
			for index: int in range(last_button_index, selected_button_index + 1):
				update_scene_view_button(scene_buttons[index], selected)
				#last_button = scene_buttons[index] # Update the last button
		if last_button_index > selected_button_index: # non normal right to left selection (bottom up)
			for index: int in range(selected_button_index, last_button_index + 1):
				update_scene_view_button(scene_buttons[index], selected)
				#last_button = scene_buttons[index] # Update the last button

	else:
		update_scene_view_button(button, selected)
		#last_button = button # Update the last button

	#for btn in scene_buttons:
		#if btn and btn is Button:
			#btn.selected_texture_button.hide()
	# FIXME Leaves a bunch showing texture button not just last one
	#if scene_buttons.get_child(last_button_index)
	#button.get_parent().get_child(last_button_index).selected_texture_button.show()
	#if last_button:
	# FIXME Works, but if clicking again erases box and MultiSelectBox 
	button.selected_texture_button.show() # do not hide last buttons selection box
	#selected_buttons.clear()
	#if debug: print("selected_buttons: ", selected_buttons)


func update_scene_view_button(button: Button, selected: bool) -> void:
	if button.is_visible_in_tree(): # Restrict if filtered scenes
		if selected:
			#button.selected_texture_button.button_pressed = true
			button.selected_texture_button.show()
			button.self_modulate = Color(1.0, 1.0, 1.0, 0.6)
			
			var new_style_box: StyleBoxFlat = StyleBoxFlat.new()
			new_style_box.draw_center = false
			new_style_box.set_border_width(0, 3)
			new_style_box.set_border_width(1, 3)
			new_style_box.set_border_width(2, 3)
			new_style_box.set_border_width(3, 3)

			#new_style_box.set_border_color(Color(0.43, 0.72, 0.98, 1.0))
			#new_style_box.set_border_color(theme_accent_color)
			new_style_box.set_border_color(get_accent_color())
			
			
			button.add_theme_stylebox_override("normal", new_style_box)
			if not selected_buttons.has(button):
				selected_buttons.append(button)

		else:
			if debug: print("executing for removal: ", button)
			#button.selected_texture_button.button_pressed = false
			button.selected_texture_button.hide()
			button.self_modulate = Color(1.0, 1.0, 1.0, 0.18)
			button.remove_theme_stylebox_override("normal")
			if selected_buttons.has(button):
				selected_buttons.erase(button)
				

		last_button_index = button.get_index()
#endregion

func update_box_select_color() -> void:
	#if settings.has_setting("interface/theme/accent_color"):
		#theme_accent_color = settings.get_setting("interface/theme/accent_color")
	for button: Button in selected_buttons:
		update_scene_view_button(button, true)
			#button.set_border_color(theme_accent_color)


var scene_view_buttons: Array[Button] = []

# FIXME TODO Consider switching to part of Global Tags system where "favorite" tag is added
# NOTE Removed in favor of storing to resource because to slow
func restore_favorite_hearts() -> void:
	#for main_collection_tab: Control in main_collection_tabs:
		#if debug: print("main_collection_tab: ", main_collection_tab)
	#for sub_collection_tab: Contol in sub_collection_tabs:
		#for new_scene_view
	#if debug: print("last_session_favorites: ", last_session_favorites)
	for scene_view: Button in scene_view_buttons:
		if debug: print("scene_view.scene_full_path: ", scene_view.scene_full_path)
		
		if scene_favorites.has(scene_view.scene_full_path):
		#if last_session_favorites.has(scene_view.scene_full_path):
			if debug: print("match found")
			scene_view.heart_texture_button.button_pressed = true
			##Cycle back trough and create buttons for Favorite Tab
			#add_scene_button_to_favorites(scene_full_path, false)
#
#
			#if new_sub_collection_tab != favorites and last_session_favorites.has(scene_full_path):
				#if debug: print("is this code running?")
				#
				##if debug: print("scene_full_path: ", scene_full_path)
				#if scene_full_path != "":
					##new_scene_view.heart_split_panel.button_pressed = true
					#new_scene_view.heart_texture_button.button_pressed = true
					##Cycle back trough and create buttons for Favorite Tab
					#add_scene_button_to_favorites(scene_full_path, false)
#
#
			#if new_sub_collection_tab == favorites:
				##new_scene_view.heart_split_panel.button_pressed = true
				#new_scene_view.heart_texture_button.button_pressed = true
				#new_scene_view.clear_favorite.connect(modify_heart_from_matching_favorite)


var current_button: Button = null
#var last_button: Button = null
#var last_sub_viewport: SubViewport = null
var processed_button: Button = null
#var wait_count: int = 0
#var sub_viewport: SubViewport = null


################################################################################## KEEP FOR NOW DO NOT DELETE
## Dynamic scene loading fallback
### Reload the scene_view button with the full scene to do 360 rotation 
## FIXME We get the scene_instance here and again when we call get_camera_aabb_view? TODO Combined them?
#func reload_scene_view_button(button: Button, scene_full_path: String, sub_viewport: SubViewport) -> void:
	#var collection_name: String = scene_full_path.split("/")[-2]
	#var scene_instance: Node = null
	#if collection_lookup.has(collection_name) and collection_lookup[collection_name].has(scene_full_path):
		#scene_instance = collection_lookup[collection_name][scene_full_path]
	## Try loading from scene_lookup first and if not then fallback
	## FIXME mutex.lock must extend to here
	#if not collection_lookup.is_empty() and collection_lookup.has(collection_name):
		## FIXME I get scene_instance here and then again in get_camera_aabb_view()
		#mutex.lock()
		##var scene_instance = scene_lookup[scene_full_path]
		##var scene_instance = collection_lookup[collection_name][scene_full_path]
		#mutex.unlock()
		#if debug: print("scene_instance: ", scene_instance)
		#if scene_instance != null and is_instance_valid(scene_instance):
			##push_error("calling from here1")
			## FIXME scene_instance is not valid or something if scene == null:? 
			#get_camera_aabb_view(button, scene_instance, scene_full_path, sub_viewport)
			## Call down to button after scene loaded on thread so not waiting from scene_view button
			#button.child_sprite.hide() # Hide the the NewSprite
			#button.sub_viewport_container.show()
			#button.camera_gimbal = button.sub_viewport.get_child(1)
			#button.rotate_scene = true
		#else:
			#push_warning("scene instance is still loading or has been freed from memory.")
			##push_warning("scene instance has been freed from memory")
#
	#else:
		#current_button = button
#
		## If thread is processing a stale scene let it finish and then reload
		#if button != processed_button and thread.is_alive():
			#var wait_count: int = 0
			#while thread.is_alive():
				#await get_tree().process_frame
				#wait_count += 1
				#if wait_count > 10000:
					#break
#
			#if is_instance_valid(current_button.sub_viewport):
				#reload_scene_view_button(current_button, current_button.scene_full_path, current_button.sub_viewport)
				#if debug: print("finishing stale scene")
#
			#return
#
		#await get_tree().process_frame
#
		#if not thread.is_alive():
			#processed_button = button
			## FIXME I load scene from file here 
			##var scene_instance: Node = await load_scene_instance(scene_full_path)
			##var scene_instance: Node = collection_lookup[collection_name][scene_full_path]
#
			#if button != current_button: # Check that button is still same button after finished loading, if not reload again
				#if is_instance_valid(current_button.sub_viewport):
					#reload_scene_view_button(current_button, current_button.scene_full_path, current_button.sub_viewport)
#
			#else:
				#if scene_instance != null and is_instance_valid(current_button.sub_viewport):
					## FIXME and I load scene from file again here?
					##push_error("calling from here2")
					#if debug: print("hello from here")
					#get_camera_aabb_view(button, scene_instance, scene_full_path, current_button.sub_viewport)
					## Call down to button after scene loaded on thread so not waiting from scene_view button
					#button.child_sprite.hide() # Hide the the NewSprite
					#button.sub_viewport_container.show()
					#button.camera_gimbal = button.sub_viewport.get_child(1)
					#button.rotate_scene = true
				#else:
					#push_warning("scene instance is still loading or has been freed from memory.")
################################################################################## KEEP FOR NOW DO NOT DELETE



### FIXME MAYBE MOVE TO SCENE_VIEW MOUSE_ENTERED?
### CAUTION DO NOT DELETE
#### Reload the scene_view button with the full scene to do 360 rotation 
### FIXME We get the scene_instance here and again when we call get_camera_aabb_view? TODO Combined them?
#func reload_scene_view_button(button: Button, scene_full_path: String, sub_viewport: SubViewport) -> void:
	#var collection_name: String = scene_full_path.split("/")[-2].to_snake_case()
	#var scene_instance: Node = null
	#mutex.lock()
	#if not collection_lookup.is_empty() and collection_lookup.has(collection_name) and collection_lookup[collection_name].has(scene_full_path):
		##if processing_collection:
			##push_warning("The collection has not finished processing. The scene preview is not available.")
			##return
		##else:
		#if debug: print("Accessing collection_lookup with collection_name: ", collection_name)
		#if debug: print("Accessing collection_lookup with scene_full_path: ", scene_full_path)
		#scene_instance = collection_lookup[collection_name][scene_full_path].duplicate()
		## Load in and display the default surface materials from the material_lookup dict created during editor startup in add_scenes_to_collections()
		## TODO Add in functionality to display current selected or favorite material on the preview as well toggle button
		## FIXME ERROR: res://addons/scene_snap/scripts/scene_viewer.gd:10691 - Out of bounds get index '1' (on base: 'Array' for SM_Wall_04 in Carpenters Workshop collection? 
		## Either not being stored or maybe wrap around code issue?
		##set_surface_materials(scene_instance, scene_full_path, -1, null, true)
		#set_surface_materials(scene_instance, scene_full_path, true)
	#mutex.unlock()
#
	#if scene_instance != null and is_instance_valid(scene_instance):
		#get_camera_aabb_view(button, scene_instance, scene_full_path, sub_viewport)
		## Call down to button after scene loaded on thread so not waiting from scene_view button
		#button.child_sprite.hide() # Hide the the NewSprite
		#button.sub_viewport_container.show()
		#button.camera_gimbal = button.sub_viewport.get_child(1)
		#button.rotate_scene = true
		##button.scene_ready = true
	#else:
		##button.scene_ready = false
		#push_warning("scene instance is still loading or has been freed from memory.")

# REFACTORED FIXME sub_viewport_container is being removed for buttons with active tags
func reload_scene_view_button(button: Button, scene_full_path: String, sub_viewport: SubViewport) -> void:
	scene_instance = load_scene_instance(scene_full_path) # May need to call to have current_scene_path updated?
	if scene_instance and is_instance_valid(scene_instance):
		set_surface_materials(scene_instance, scene_full_path, true)
		get_camera_aabb_view(button, scene_instance, scene_full_path, sub_viewport)
		## Call down to button after scene loaded on thread so not waiting from scene_view button
		button.child_sprite.hide() # Hide the the NewSprite
		button.sub_viewport_container.show()
		button.camera_gimbal = button.sub_viewport.get_child(1)
		button.rotate_scene = true


	#var collection_name: String = scene_full_path.split("/")[-2].to_snake_case()
	#var scene_instance: Node = null
	#mutex.lock()
	#if not collection_lookup.is_empty() and collection_lookup.has(collection_name) and collection_lookup[collection_name].has(scene_full_path):
		##if processing_collection:
			##push_warning("The collection has not finished processing. The scene preview is not available.")
			##return
		##else:
		#if debug: print("Accessing collection_lookup with collection_name: ", collection_name)
		#if debug: print("Accessing collection_lookup with scene_full_path: ", scene_full_path)
		#scene_instance = collection_lookup[collection_name][scene_full_path].duplicate()
		## Load in and display the default surface materials from the material_lookup dict created during editor startup in add_scenes_to_collections()
		## TODO Add in functionality to display current selected or favorite material on the preview as well toggle button
		## FIXME ERROR: res://addons/scene_snap/scripts/scene_viewer.gd:10691 - Out of bounds get index '1' (on base: 'Array' for SM_Wall_04 in Carpenters Workshop collection? 
		## Either not being stored or maybe wrap around code issue?
		##set_surface_materials(scene_instance, scene_full_path, -1, null, true)
		#set_surface_materials(scene_instance, scene_full_path, true)
	#mutex.unlock()
#
	#if scene_instance != null and is_instance_valid(scene_instance):
		#get_camera_aabb_view(button, scene_instance, scene_full_path, sub_viewport)
		## Call down to button after scene loaded on thread so not waiting from scene_view button
		#button.child_sprite.hide() # Hide the the NewSprite
		#button.sub_viewport_container.show()
		#button.camera_gimbal = button.sub_viewport.get_child(1)
		#button.rotate_scene = true
		##button.scene_ready = true
	#else:
		##button.scene_ready = false
		#push_warning("scene instance is still loading or has been freed from memory.")




#func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, scene_name_split: PackedStringArray) -> Button:
#func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, file_name_split: PackedStringArray, new_scene: bool) -> Button:
## Create scene view button and connect signals return the button
#func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, new_scene: bool, thumbnail_cache_path: String) -> Button:
func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, new_scene: bool) -> Button:
	var new_scene_view: Button = SCENE_VIEW.instantiate()
	
	#new_scene_view.thumbnail_cache_path = thumbnail_cache_path
	new_scene_view.sharing_disabled = sharing_disabled
	new_scene_view.thumbnail_size_value = thumbnail_size_value
	#if debug: print("last_session_favorites: ", last_session_favorites)
	#if not new_scene:
	if new_scene_view:
		#new_sub_collection_tab.find_child("HFlowContainer").add_child(new_scene_view)
		if debug: print("new_sub_collection_tab: ", new_sub_collection_tab)
		new_sub_collection_tab.h_flow_container.add_child(new_scene_view)

		if not new_scene:
			#if debug: print("THIS IS THE FULL PATH: ", scene_full_path)
			# NOTE added to scene_view_instances to enable view sizing
			scene_view_instances.append(new_scene_view)
			
			new_scene_view.add_favorite.connect(add_scene_button_to_favorites)
			#new_scene_view.scene_has_animation.connect(add_scene_button_to_scene_has_animation)
			new_scene_view.remove_favorite.connect(remove_scene_button_from_favorites)
			new_scene_view.scene_focused.connect(update_current_scene_path)
			
			new_scene_view.update_selected_scene_view_button.connect(func(scene_view_button: Button) -> void: emit_signal("update_selected_scene_view_button", scene_view_button))
			
			#new_scene_view.set_scenes_default_materials.connect(set_surface_materials)
			########### KEEP Allows dropping onto another button to import keep?
			#new_scene_view.process_drop_data_from_scene_view.connect(parse_drop_file)
			########### KEEP
			

			# FIXME CHECK HOW WORKS WITH PLAYING ANIMATION FROM BUTTON MAY NEED TO UPDATE scene in scene_view.gd
			# Gets signaled from scene_view on button entered to load_scene_instance NOTE: scene arg is placeholder and gets replaced with load_scene_instance(scene_full_path)
			new_scene_view.reload_scene.connect(reload_scene_view_button)
			#new_scene_view.reload_scene.connect(func (button, scene, scene_full_path, sub_viewport) -> void:
					##if debug: print("button: ", button)
					#button = button
					#if not thread.is_alive():
						#await get_tree().process_frame
						#var scene_instance: Node = await load_scene_instance(scene_full_path)
						#if button != button: # Check that button is still same button after finished loading if not reload again
							#return
						#else:
							#if button.sub_viewport_container:
								#get_camera_aabb_view(button, scene_instance, scene_full_path, sub_viewport)
								#if debug: print("rotate for button: ", button)
								#button.continue_function = true
								#button.rotate_scene = true)


# WORKING MULTITHREADING
					#var task_id = WorkerThreadPool.add_task(load_scene_data.bind(scene_full_path))
#
					#if WorkerThreadPool.wait_for_task_completion(task_id) == OK:
						## Other code that depends on task being processed.
						##if debug: print("thread finished success")
						#get_camera_aabb_view(button, get_scene_instance_from_loaded_data(file_bytes, scene_full_path), scene_full_path, sub_viewport))






			new_scene_view.button_selected.connect(get_selected_buttons)
			#new_scene_view.scene_tag_added_or_removed.connect(append_scenes_with_edited_tags)
			
			#############CURRENTLY NOT USED
			#new_scene_view.toggle_tag_panel_state.connect(toggle_current_main_tab_tag_panel)

			#new_scene_view.remove_open_tag_panel.connect(remove_tag_panel)
			new_scene_view.toggle_tag_panel.connect(toggle_tag_panel_state)
			new_scene_view.clear_tags.connect(clear_shared_and_global_tags)
			new_scene_view.clear_selected_enabled.connect(func(state: bool) -> void: clear_selected_enabled = state)
			
			new_scene_view.get_scene_ready_state.connect(func(collection_name: String, scene_full_path: String) -> void: 

					if scene_full_path.begins_with("res://"):
						new_scene_view.scene_ready = true
						return
					# FIXME Somehow still getting through?
					if processed_collections.has(collection_name):
					#if not processing_collection and collection_queue.size() == 0:
						mutex.lock()
						if not collection_lookup.is_empty() and collection_lookup.has(collection_name) and collection_lookup[collection_name].has(scene_full_path):
							new_scene_view.scene_ready = true
						else:
							new_scene_view.scene_ready = false
						#scene_instance = collection_lookup[collection_name][scene_full_path]
						mutex.unlock())
			
			#new_scene_view.scene = load_scene_instance(scene_full_path)
			


			# TEST
			#await get_tree().process_frame
			#await restore_saved_data()
			#if last_session_favorites.has(scene_full_path):
				#new_scene_view.heart_texture_button.button_pressed = true
			# TEST END

			# FIXME CHECK IF NEEDED I THINK I REMOVED THIS NO SUB COLLECTION TAB FAVORITES
			#if debug: print("new_sub_collection_tab: ", new_sub_collection_tab)
			#if debug: print("I think this is running before last_session_favorites is restored?")

			# Prevent loading until restore of data from scene_snap_plugin.gd _set_window_layout

			#while not continue_load:
				#await get_tree().process_frame



############################ NOTE was pulled out to not block button creation while slow last_session_favorites restored
			#if new_sub_collection_tab != favorites and last_session_favorites.has(scene_full_path):
			if new_sub_collection_tab != new_favorites_tab and scene_favorites.has(scene_full_path):
				if debug: print("is this code running?")
				
				#if debug: print("scene_full_path: ", scene_full_path)
				if scene_full_path != "":
					#new_scene_view.heart_split_panel.button_pressed = true
					new_scene_view.heart_texture_button.button_pressed = true
					#Cycle back trough and create buttons for Favorite Tab
					add_scene_button_to_favorites(scene_full_path, false)
			
			## Restore scene_has_animation Array
			#if settings.has_setting("scene_snap_plugin/scenes_with_animations"):
				#settings
				#scene_has_animation = settings.get_setting("scene_snap_plugin/scenes_with_animations")
				##if debug: print("scene_has_animation: ", scene_has_animation)
			
			
			## Restore animation icon button to scenes with animations from scene_has_animation Array
			#if scene_has_animation.has(scene_full_path):
				#new_scene_view.show_animation_texture_button = true
			
			
			#if new_sub_collection_tab == favorites:
			if new_sub_collection_tab == new_favorites_tab:
				# Set the Heart filter button default RED pressed for the "favorites" Tab
				new_scene_view.heart_texture_button.button_pressed = true
				new_scene_view.clear_favorite.connect(modify_heart_from_matching_favorite)

			new_scene_view.owner = self
			##new_scene_view.name = scene_name_split[0]
			#new_scene_view.name = file_name_split[0]
			new_scene_view.name = get_scene_name(scene_full_path, true)
			##if debug: print("new_scene_view.name: ", new_scene_view.name)
			new_scene_view.scene_full_path = scene_full_path
			
			scene_view_buttons.append(new_scene_view)

	return new_scene_view


var last_scene_full_path: String = ""
var last_surface_index: int = -1
# FIXME Duplicate code in scene_snap_plaugin.gd move here?
# FIXME Set all surfaces to default unless changed, only way to do that is to store changes right? or just initially loaded they are all default 
# so if scene_full_path == last_scene_full_path
# This function needs to be called on scene preview
# TODO Set flag for 360 rotation to always have defaults set even if same scene_full_path


# TODO Fix so that can change different surfaces without resetting other surfaces back to default
#func set_surface_materials(scene_instance: Node, scene_full_path: String, surface: int, material: StandardMaterial3D, is_button: bool = false, not_scene_preview: bool = true) -> void:
func set_surface_materials(scene_instance: Node, scene_full_path: String, set_default_material: bool = false) -> void:
	if scene_full_path.begins_with("res://") and current_material_index == -1:
		return


	# Initially set the material to default material if one has not been selected
	if current_material_index == -1:
		current_material_index = materials_3d_array.find(get_default_material())

	# Update the material buttons number and visible texture to match the current one and check if favorite
	material_3d_number.set_text(str(current_material_index))
	var selected_material: Resource = materials_3d_array[current_material_index]
	material_button_mesh_instance_3d.set_surface_override_material(0, selected_material)
	do_material_favorite_check()



	#var default_material: BaseMaterial3D = get_default_material()
	if scene_instance != null:
		#if material == null:
		
			#var default_material: StandardMaterial3D = material_lookup[current_scene_path][current_selected_surface_index]
			## NOTE: This is good since it is only changing the button surface so hardcoding to 0 is correct here
			#material_button_mesh_instance_3d.set_surface_override_material(0, default_material)
	#if scene_preview != null:
		var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)







		#for mesh_node: MeshInstance3D in mesh_node_instances:
			## FIXME Broken because scene_preview sets this and then when scene_to_place comes and matches last_scene_full_path this gets skipped
			## Pass flag to exclude scene_preview from setting last last_scene_full_path?
			## FIXME broken when same scene but changing body or collision? find fix?
			##if last_scene_full_path != scene_full_path or is_button: # If new scene set all material to defaults # FIXME will this still work for favorites?
				##if not_scene_preview:
				###if debug: print("setting last_scene_full_path")
					##last_scene_full_path = scene_full_path
				###last_surface_index = surface
			#for surface_index: int in mesh_node.mesh.get_surface_count():
				##if material_lookup[scene_full_path].has(surface_index):
				##if material_lookup[scene_full_path][surface_index]:
				#
					#var default_material: StandardMaterial3D = material_lookup[scene_full_path][surface_index]


		# FIXME Some scene are not getting all their surfaces registered or somehting is going on? Exampe SM Wall 04
		# NOTE: Also appears for SM Wall 04 that the texture is not even correct? and some walls index is offset by 1?
		for mesh_node: MeshInstance3D in mesh_node_instances:
			## We want to skip if same scene different surface
			## we want to allow if different scene and different surface
			#if last_scene_full_path != scene_full_path and last_surface_index != current_selected_surface_index:
				#last_scene_full_path = scene_full_path
				#last_surface_index = current_selected_surface_index
				## We do not want to skip if same scene different body or collision
			for surface_index: int in mesh_node.mesh.get_surface_count():
				if material_lookup.has(scene_full_path):
					var materials: Array = material_lookup[scene_full_path]
					#if debug: print("materials: ", materials)
					if surface_index >= 0 and surface_index < materials.size():
						var default_material: BaseMaterial3D = materials[surface_index]
						mesh_node.set_surface_override_material(surface_index, default_material)
					else:
						push_warning("A material was not found for one of the surfaces of the scene located at: ", scene_full_path)

			if not set_default_material and current_selected_surface_index != -1:
				mesh_node.set_surface_override_material(current_selected_surface_index, selected_material)




#var new_editor_plugin_instance: EditorPlugin = EditorPlugin.new()
var last_open_tag_panel: Control = null
var last_editor_plugin_instance: EditorPlugin = null


#func remove_tag_panel(current_editor_plugin_instance: EditorPlugin, current_tag_panel: Control) -> void:
	## Initialize last_open_tag_panel
	#if not last_open_tag_panel: 
		#last_open_tag_panel = current_tag_panel
		#last_editor_plugin_instance = current_editor_plugin_instance
	#if debug: print("current_tag_panel: ", current_tag_panel)
	#if debug: print("last_open_tag_panel: ", last_open_tag_panel)
	#if last_open_tag_panel and last_open_tag_panel != current_tag_panel:
		#last_open_tag_panel = current_tag_panel
		#last_editor_plugin_instance = current_editor_plugin_instance
		#last_editor_plugin_instance.remove_control_from_docks(last_open_tag_panel)





const TAG_PANEL = preload("res://addons/scene_snap/plugin_scenes/tag_panel.tscn")
var new_editor_plugin_instance: EditorPlugin = EditorPlugin.new()
var new_tag_panel: Control = null
var last_scene_view_button_pressed: Button = null
var last_selected_buttons: Array[Node] = []


### Toggle open/close the tag panel according to some parameters
#func toggle_tag_panel_state(scene_view_button_pressed: Button) -> void:
	#var selection_changed = last_selected_buttons != selected_buttons
	#var button_changed = last_scene_view_button_pressed != scene_view_button_pressed
	#
	#if button_changed or selection_changed:
		#if new_tag_panel:
			#close_tag_panel()
			#if selected_buttons.has(scene_view_button_pressed) and selected_buttons.has(last_scene_view_button_pressed) and not selection_changed:
				#last_scene_view_button_pressed = scene_view_button_pressed
				#return
#
		#open_tag_panel(scene_view_button_pressed)
	#else:
		#if new_tag_panel:
			#close_tag_panel()
		#else:
			#open_tag_panel(scene_view_button_pressed)
#
	#last_scene_view_button_pressed = scene_view_button_pressed
	#last_selected_buttons = selected_buttons.duplicate()





## Toggle open/close the tag panel according to some parameters
func toggle_tag_panel_state(scene_view_button_pressed: Button) -> void:
	var selection_changed: bool = last_selected_buttons != selected_buttons
	var button_changed: bool = last_scene_view_button_pressed != scene_view_button_pressed 
	# If the button pressed is different from the last one pressed or selection changed.
	if button_changed or selection_changed:

		# Always close to refresh the panel if button or selection changed
		if new_tag_panel:
			close_tag_panel()
			# Keep panel closed if: button pressed is in selected | last button pressed is in selected | selected are the same.
			if selected_buttons.has(scene_view_button_pressed) and selected_buttons.has(last_scene_view_button_pressed) and not selection_changed:
				last_scene_view_button_pressed = scene_view_button_pressed
				return

		# If not one of the above cases for keep panel closed, then open it.
		open_tag_panel(scene_view_button_pressed)

	else: # If the button pressed is the same as the last one pressed
		if new_tag_panel: # If the panel aready open then close it
			close_tag_panel()
		else: # If it is not open already, open it.
			open_tag_panel(scene_view_button_pressed)

	last_scene_view_button_pressed = scene_view_button_pressed
	# Create duplicate so that last_selected_buttons does not simply reference selected_buttons and always ==.
	last_selected_buttons = selected_buttons.duplicate() 


func close_tag_panel() -> void:
	if new_tag_panel:
		new_editor_plugin_instance.remove_control_from_docks(new_tag_panel)
		new_tag_panel.queue_free()
		new_tag_panel = null

## Open the tag panel add in selected_buttons and connect to tag_added_or_removed signal for saving
func open_tag_panel(scene_view_button_pressed: Button) -> void:
	new_tag_panel = TAG_PANEL.instantiate()
	new_tag_panel.sharing_disabled = sharing_disabled
	new_tag_panel.selected_buttons = selected_buttons
	new_tag_panel.tag_added_or_removed.connect(append_buttons_with_edited_tags)
	#new_tag_panel.update_scene_mesh_tags.connect(store_tags_in_scene_mesh)
	new_tag_panel.scene_view = scene_view_button_pressed
	new_editor_plugin_instance.add_control_to_dock(new_editor_plugin_instance.DOCK_SLOT_RIGHT_BL, new_tag_panel)

# TODO Decide if want to remove both shared and global tags or maybe just global
# TODO Check if shift and drag box select will erase tags for multi select? Seems to be okay?
# CAUTION MAYBE SHOULD CONTAIN WARNING THAT WILL REMOVED SHARED TAGS TOO?
# MAYBE SINGLE SHIFT CLICK REMOVES GLOBAL AND HOLDING CLICK REMOVES BOTH? 
func clear_shared_and_global_tags(clear_shared_tags: bool, scene_view_button_pressed: Button) -> void:
	if selected_buttons and selected_buttons.has(scene_view_button_pressed):
		for button: Button in selected_buttons:
			clear_shared_and_global_tags_extended(clear_shared_tags, button)

	else:
		clear_shared_and_global_tags_extended(clear_shared_tags, scene_view_button_pressed)


func clear_shared_and_global_tags_extended(clear_shared_tags: bool, button: Button) -> void:
	print("clearing tags for: ", button.scene_full_path)
	button.global_tags.clear()
	
	if clear_shared_tags:
		button.shared_tags.clear()
		button.tags.clear()
		# Clear from scene_data_cache
		mutex.lock()
		main_collection_tab_script.update_scene_data_cache_paths("", "", false, button.scene_full_path)
		mutex.unlock()

	if button.global_tags.is_empty() and button.shared_tags.is_empty():
		# HACK # To refresh tag panel tags
		if new_tag_panel:
			close_tag_panel()
			open_tag_panel(button)
		#button.tags_button_active.hide()
	#elif (button.global_tags.is_empty() and not button.shared_tags.is_empty()) \
		#or (not button.global_tags.is_empty() and button.shared_tags.is_empty()):
		#print("show single tag")
		#button.tags_button_active.set_texture_normal(TAG)
	button.update_tags_icon()
	load_tags_to_tag_button_tool_tip(button)
	append_buttons_with_edited_tags(button)


##func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, scene_name_split: PackedStringArray) -> Button:
#func instance_scene_view(new_sub_collection_tab: Control, scene_full_path: String, file_name_split: PackedStringArray, new_scene: bool) -> Button:
	#var new_scene_view: Button = SCENE_VIEW.instantiate()
#
	##if not new_scene:
	#if new_scene_view:
		#new_sub_collection_tab.find_child("HFlowContainer").add_child(new_scene_view)
#
		#if not new_scene:
			## NOTE added to scene_view_instances to enable view sizing
			#scene_view_instances.append(new_scene_view)
			#
			#new_scene_view.add_favorite.connect(add_scene_button_to_favorites)
			#new_scene_view.remove_favorite.connect(remove_scene_button_from_favorites)
			#new_scene_view.scene_focused.connect(update_current_scene_path)
			#new_scene_view.process_drop_data_from_scene_view.connect(parse_drop_file)
			#new_scene_view.recreate_scene_button.connect(create_scene_buttons)
#
			## FIXME CHECK IF NEEDED I THINK I REMOVED THIS NO SUB COLLECTION TAB FAVORITES
			#if new_sub_collection_tab != favorites and last_session_favorites.has(scene_full_path):
				#if scene_full_path != "":
					##new_scene_view.heart_split_panel.button_pressed = true
					#new_scene_view.heart_texture_button.button_pressed = true
					##Cycle back trough and create buttons for Favorite Tab
					#add_scene_button_to_favorites(scene_full_path, false)
			#
			#if new_sub_collection_tab == favorites:
				##new_scene_view.heart_split_panel.button_pressed = true
				#new_scene_view.heart_texture_button.button_pressed = true
				#new_scene_view.clear_favorite.connect(modify_heart_from_matching_favorite)
#
			#new_scene_view.owner = self
			##new_scene_view.name = scene_name_split[0]
			#new_scene_view.name = file_name_split[0]
			#if debug: print("new_scene_view.name: ", new_scene_view.name)
			#new_scene_view.scene_full_path = scene_full_path
#
	#return new_scene_view



#############CURRENTLY NOT USED replaced by pass_selected_buttons_to_tag_panel()
#var last_scene_view_pressed: Button = null
#
#func toggle_current_main_tab_tag_panel(scene_view: Button) -> void:
	#if debug: print("selected_buttons: ", selected_buttons)
	#var tag_panel: Control = main_tab_container.get_current_tab_control().tag_panel
	#if scene_view == last_scene_view_pressed and tag_panel.visible:
		#tag_panel.hide()
	#else:
		#tag_panel.scene_view = scene_view
		#tag_panel.selected_buttons = selected_buttons
		#tag_panel.show()
		#if debug: print("main_tab_container.get_current_tab_control(): ", main_tab_container.get_current_tab_control())
#
	#last_scene_view_pressed = scene_view


#var last_scene_view_pressed: Button = null




# TODO CLEANUP
## Triggered every time scene focus changes
# FIXME Breaks for scene within res:// because not in material_lookup[scene_full_path]
# FIXME Needs to be triggered on very first load of collection or at the least when scene_preview generated
# FIXME If cycle favorites then update scene preview to the favorite material when switching if disable then default texture
func update_current_scene_path(scene_full_path: String, scene: Button) -> void:
	if not scene_full_path.begins_with("res://"): # FIXME Remove blanket exclusion
		if debug: print("scene focues: ", scene)
		current_scene_path = scene_full_path
		emit_signal("pass_current_scene_up", scene_full_path)
		
		mutex.lock()
		if debug: print("material_lookup[scene_full_path]: ", material_lookup[scene_full_path])
		if material_lookup[scene_full_path].size() > 1:
			
			material_button_surface_selection.disabled = false
		else:
			current_selected_surface_index = 0
			material_button_surface_selection.set_text(str(current_selected_surface_index))
			material_button_surface_selection.disabled = true
		mutex.unlock()

		emit_signal("get_current_scene_preview")
		if not cycle_material_favorites:
			current_material_index = materials_3d_array.find(get_default_material())
		set_surface_materials(current_scene_preview, scene_full_path)
		do_material_favorite_check()

	else:
		current_scene_path = scene_full_path
		emit_signal("pass_current_scene_up", scene_full_path)

		current_selected_surface_index = 0
		material_button_surface_selection.set_text(str(current_selected_surface_index))
		material_button_surface_selection.disabled = true

		emit_signal("get_current_scene_preview")
		if not cycle_material_favorites:
			current_material_index = materials_3d_array.find(get_default_material())
		set_surface_materials(current_scene_preview, scene_full_path)
		do_material_favorite_check()




## NOTE TEST IMPLEMENT FROM SCENE_SNAP_PLUAGIN.GD
	### FIXME TODO Consider changing to heart?
	##if hold_current_material and held_current_material_index != -1:
		##if debug: print("holding current material")
		##current_material_index = held_current_material_index
		###favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
		##favorite_material_button.self_modulate = get_accent_color()
	#emit_signal("get_current_scene_preview")
	#if cycle_material_favorites:
		#set_surface_materials(current_scene_preview, scene_full_path, true)
		##update_materials_mesh_instance_3d(materials_3d_array[current_material_index])
#
	#else:
		#if debug: print("reseting to default material")
		##set_material_button_to_default_material()
		#set_surface_materials(current_scene_preview, scene_full_path)
		##update_materials_mesh_instance_3d(await get_default_material())
		##_on_material_button_surface_selection_pressed()


#func load_scenes(full_path: String) -> PackedScene:
	#var res = ResourceLoader.load_threaded_get(full_path)
	#if res:
		#return res
	#else:
		#push_error("Failed to load resource: ", full_path)
		#return




#func get_thumbnail_cache_path(ext: String, scene_full_path: String) -> String:
func get_thumbnail_cache_path(scene_full_path: String) -> String:
	var thumbnail_cache_path: String
	var split: PackedStringArray = full_path_split(scene_full_path, false) # ["user:", "shared_collections", "scenes", "3D Scenes", "test", "SM_SFloorMiddle150x450--Tags.tscn"]

	match split[1]:

		"global_collections":
			thumbnail_cache_path = path_to_thumbnail_cache_global.path_join(split[3].path_join(split[4].path_join(get_scene_name(scene_full_path, true) + ".png")))
			return thumbnail_cache_path

		"shared_collections":
			thumbnail_cache_path = path_to_thumbnail_cache_shared.path_join(split[3].path_join(split[4].path_join(get_scene_name(scene_full_path, true) + ".png")))
			return thumbnail_cache_path

		_: # Will match all paths in res:// dir including "collections"
			var project_name: String = ProjectSettings.get_setting("application/config/name")
			thumbnail_cache_path = path_to_thumbnail_cache_project.path_join(project_name.path_join(get_scene_name(scene_full_path, true) + ".png"))
			return thumbnail_cache_path

	return ""







	
	
	
	
	# "user://shared_collections/scenes_thumbnail_cache/"
	#match ext:
		#".tscn":
			#thumbnail_cache_path = path_to_thumbnail_cache + scene_full_path.substr(14, scene_full_path.length() - 18) + "png"
		#".glb":
			#thumbnail_cache_path = path_to_thumbnail_cache + scene_full_path.substr(14, scene_full_path.length() - 17) + "png"
	#match ext:
		#".tscn":
			#thumbnail_cache_path = path_to_thumbnail_cache.path_join(split[3].path_join(split[4].path_join(split_name[0] + ".png")))
		#".glb": # FIXME
			#thumbnail_cache_path = path_to_thumbnail_cache + scene_full_path.substr(14, scene_full_path.length() - 17) + "png"
	#return thumbnail_cache_path
			
	#if scene_full_path.ends_with(".tscn"):
		#
	#elif scene_full_path.ends_with(".glb"):

#func create_scene_buttons(loaded_scene: PackedScene, scene_full_path: String, new_sub_collection_tab: Control, pass_cache: bool):
	#if debug: print("loaded_scene: ", loaded_scene)
	#if debug: print("scene_full_path: ", scene_full_path)
	#if debug: print("new_sub_collection_tab: ", new_sub_collection_tab)
	#
	#
	#if initialize_last_sub_collection_tab:
		#last_sub_collection_tab = new_sub_collection_tab
		#initialize_last_sub_collection_tab = false
	##if debug: print("scene_full_path: ", scene_full_path)
	##var file_name_split: PackedStringArray
	##if project_scenes:
		##file_name_split = full_path_split(scene_full_path, true)
	##else:
		##file_name_split = full_path_split(scene_full_path, true)
	##if debug: print("scene_full_path!!: ", scene_full_path)
	#var file_name_split: PackedStringArray = full_path_split(scene_full_path, true)
	#if file_name_split[0].ends_with(".tscn"):
		##file_name_split[0] = file_name_split[0].rstrip(".tscn")
		#file_name_split[0] = file_name_split[0].substr(0, file_name_split[0].length() - 5) # The length of .tscn = 5
	##if debug: print("file_name_split. ", file_name_split)
	##var scene_full_path = scenes_dir_path.path_join(file_name)
#
	##if scene_full_path.ends_with(".tscn"):
	#if scene_full_path.ends_with(".tscn") or scene_full_path.ends_with(".glb"):
		#var thumbnail_cache_path: String
		#if scene_full_path.ends_with(".tscn"):
			#thumbnail_cache_path = get_thumbnail_cache_path(".tscn", scene_full_path)
		#elif scene_full_path.ends_with(".glb"): # NOTE TODO THIS WILL BE USED IF .GLB FILES ARE ADDED TO USER:// 
			#thumbnail_cache_path = get_thumbnail_cache_path(".glb", scene_full_path)
#
		## FIXME MAYBE EXPENSIVE OPERATION??
		#if user_dir.file_exists(thumbnail_cache_path) and not pass_cache: # Allow for pass_cache to recreate scene for 3d and animation playing
			#if debug: print("THUMBNAIL CACHE PATH: ", thumbnail_cache_path)
			##var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
			#var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
#
			### Keep in for use of 3D rotation and playing animations
			##var subviewport_container: Control = new_scene_view.get_child(0).get_child(0)
			##subviewport_container.queue_free()
#
			#var subviewport_node_child: SubViewport = new_scene_view.get_child(0).get_child(0).get_child(0)
			#if debug: print("subviewport_node_child: ", subviewport_node_child.name)
			##subviewport_node.queue_free()
#
#
			#var vbox_container: Control = new_scene_view.get_child(0)
#
#
			#var new_sprite = Sprite2D.new()
			#var image: Image = Image.load_from_file(thumbnail_cache_path)
			#image.clear_mipmaps()
			#image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
			#new_sprite.texture = ImageTexture.create_from_image(image)
			#new_sprite.centered = false
			## Set based off of scene_view scale_size
			#new_sprite.offset = Vector2(-13, -13)
#
			#vbox_container.add_child(new_sprite)
			#vbox_container.move_child(new_sprite, 0)
#
			#await get_tree().create_timer(0.001).timeout
			#new_scene_view.set_scene_view_size(thumbnail_size_value)
#
#
		#else:
			##if debug: print(" THIS IS THE scene_full_path: ", scene_full_path)
			#if ResourceLoader.exists(scene_full_path):
				#var scene: PackedScene
				#if loaded_scene != null:
					#scene = loaded_scene
				#else: # FIXME FIXME FIXME FIXME FIXME FIXME FIXME 
					##scene = load_scenes(scene_full_path)
					#if debug: print("scene_full_path!!!!!: ", scene_full_path)
					#scene = load(scene_full_path)
				##all_scenes.append(scene)
#
				##if debug: print("create_button")
#
				##var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
				#var new_scene_view: Button
				#if not pass_cache:
					#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, true)
				#else:
					#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
#
				#new_scene_view.visible = false
				#new_scene_view.disabled = true
				#var new_camera_3d: Node3D = SCENE_VIEW_CAMERA_3D.instantiate()
				#var scene_instance = scene.instantiate()
				##var subviewport_child = new_scene_view.get_child(0).get_child(0).get_child(0)
#
				##subviewport_child.add_child(scene_instance)
				##scene_instance.owner = self
				##scene_instance.name = file_name_split[0]

## FIXME Consider combining into 1 by removing using just thumbnail cache images (Many subviewports will cause lag)
##func create_scene_buttons(file_name: String, scenes_dir_path: String, new_sub_collection_tab: Control):
##func create_scene_buttons(loaded_scene: PackedScene, scene_full_path: String, new_sub_collection_tab: Control):
#func create_scene_buttons(loaded_scene: PackedScene, scene_full_path: String, new_sub_collection_tab: Control, pass_cache: bool):
	##if debug: print("loaded_scene: ", loaded_scene)
	##if debug: print("scene_full_path: ", scene_full_path)
	##if debug: print("new_sub_collection_tab: ", new_sub_collection_tab)
	#
	#
	#if initialize_last_sub_collection_tab:
		#last_sub_collection_tab = new_sub_collection_tab
		#initialize_last_sub_collection_tab = false
	##if debug: print("scene_full_path: ", scene_full_path)
	##var file_name_split: PackedStringArray
	##if project_scenes:
		##file_name_split = full_path_split(scene_full_path, true)
	##else:
		##file_name_split = full_path_split(scene_full_path, true)
	##if debug: print("scene_full_path!!: ", scene_full_path)
	#var file_name_split: PackedStringArray = full_path_split(scene_full_path, true)
	#if file_name_split[0].ends_with(".tscn"):
		##file_name_split[0] = file_name_split[0].rstrip(".tscn")
		#file_name_split[0] = file_name_split[0].substr(0, file_name_split[0].length() - 5) # The length of .tscn = 5
	##if debug: print("file_name_split. ", file_name_split)
	##var scene_full_path = scenes_dir_path.path_join(file_name)
#
	##if scene_full_path.ends_with(".tscn"):
	#if scene_full_path.ends_with(".tscn") or scene_full_path.ends_with(".glb"):
		#var thumbnail_cache_path: String
		#if scene_full_path.ends_with(".tscn"):
			#thumbnail_cache_path = get_thumbnail_cache_path(".tscn", scene_full_path)
		#elif scene_full_path.ends_with(".glb"): # NOTE TODO THIS WILL BE USED IF .GLB FILES ARE ADDED TO USER:// 
			#thumbnail_cache_path = get_thumbnail_cache_path(".glb", scene_full_path)
#
		## FIXME MAYBE EXPENSIVE OPERATION??
		#if user_dir.file_exists(thumbnail_cache_path) and not pass_cache: # Allow for pass_cache to recreate scene for 3d and animation playing
			#if debug: print("THUMBNAIL CACHE PATH: ", thumbnail_cache_path)
			##var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
			#var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
#
			### Keep in for use of 3D rotation and playing animations
			#var subviewport_container: Control = new_scene_view.get_child(0).get_child(0)
			#subviewport_container.queue_free()
#
			##var subviewport_node_child: SubViewport = new_scene_view.get_child(0).get_child(0).get_child(0)
			##if debug: print("subviewport_node_child: ", subviewport_node_child.name)
			##subviewport_node.queue_free()
#
#
			#var vbox_container: Control = new_scene_view.get_child(0)
#
#
			#var new_sprite = Sprite2D.new()
			#var image: Image = Image.load_from_file(thumbnail_cache_path)
			#image.clear_mipmaps()
			#image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
			#new_sprite.texture = ImageTexture.create_from_image(image)
			#new_sprite.centered = false
			## Set based off of scene_view scale_size
			#new_sprite.offset = Vector2(-13, -13)
#
			#vbox_container.add_child(new_sprite)
			#vbox_container.move_child(new_sprite, 0)
#
			#await get_tree().create_timer(0.001).timeout
			#new_scene_view.set_scene_view_size(thumbnail_size_value)
			#
#
#
		#else:
			##if debug: print(" THIS IS THE scene_full_path: ", scene_full_path)
			#if ResourceLoader.exists(scene_full_path):
				#var scene: PackedScene
				#if loaded_scene != null:
					#scene = loaded_scene
				#else: # FIXME FIXME FIXME FIXME FIXME FIXME FIXME 
					##scene = load_scenes(scene_full_path)
					#scene = load(scene_full_path)
				##all_scenes.append(scene)
#
				##if debug: print("create_button")
#
				##var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
				#var new_scene_view: Button
				#if pass_cache:
					#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
				#else:
					#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, true)
					##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
#
				#if not pass_cache:
					#new_scene_view.visible = false
					#new_scene_view.disabled = true
#
				#var new_camera_3d: Node3D = SCENE_VIEW_CAMERA_3D.instantiate()
				#var scene_instance = scene.instantiate()
				#var subviewport_child = new_scene_view.get_child(0).get_child(0).get_child(0)
#
				#subviewport_child.add_child(scene_instance)
				#scene_instance.owner = self
#
				## NOTE add to all_scenes_instances to enable rotation on them
				#all_scenes_instances.append(scene_instance)
#
				## NOTE Camera3D was instatiated here as a result of an error when instanced as part of the scene_view /
				## scene and calling get_child to find the mesh_node when running _focus_camera_on_node_3d
				#scene_instance.add_sibling(new_camera_3d, true)
				#new_camera_3d.owner = self
#
#
#
				#var aabb: AABB = AABB()  # Initialize an empty AABB
				#var mesh_node: MeshInstance3D
				#
				## Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
				#var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)
				##if debug: print("mesh_node_instances.size: ", mesh_node_instances.size())
				#if mesh_node_instances.size() == 1:
					#if scene_instance.get_child(0) is MeshInstance3D:
						#mesh_node = scene_instance.get_child(0)
						#aabb = mesh_node.get_aabb()
#
					#elif scene_instance.get_child(0).get_child(0) is MeshInstance3D:
						#mesh_node = scene_instance.get_child(0).get_child(0)
						#aabb = mesh_node.get_aabb()
#
				#else:
					#var mesh_node_names: Dictionary = {}  # Use a Dictionary for unique names
					##var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)
#
					#for mesh_node_child: Node in mesh_node_instances:
						##if debug: print("mesh_node: ", mesh_node)
						#
						#if not mesh_node_names.has(mesh_node_child.name):
							#mesh_node_names[mesh_node_child.name] = true  # Mark the name as seen
#
							### Merge the AABB of this mesh node
							#aabb = aabb.merge(mesh_node_child.get_aabb())  # Update AABB with the new one
#
#
				##var aabb = mesh_node.get_aabb()
				#var offset = aabb.get_center()
				#new_camera_3d.position = offset
				## NOTE add to all_scene_cameras to enable rotation on them
				#all_scene_cameras.append(new_camera_3d)
				#
				#var viewport_camera: Camera3D = new_camera_3d.get_child(0).get_child(0)
				##_focus_camera_on_node_3d(mesh_node, viewport_camera)
				#_focus_camera_on_node_3d(aabb, viewport_camera)
#
				## FIXME Will not work with .glb
				##if scene_full_path.ends_with(".tscn"):
					##mesh_node.get_surface_override_material(0).cull_mode = 2 #CULL_DISABLED
#
#
				#if not pass_cache:
					#
					### Generate thumbnail cache
					#var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(".tscn", scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
					#var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(".tscn", scene_full_path), true) # ["SM_SFloorCornerR.png"]
	#
					#if thumb_path_split[1] == "project_scenes":
						#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
					#else:
						#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
					## NOTE Will not grab correct viewport texture image unless await RenderingServer.frame_pre_draw used
					#await RenderingServer.frame_pre_draw
					#subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
					#await RenderingServer.frame_post_draw
#
					#var texture_data = subviewport_child.get_viewport().get_texture().get_image()
#
					#texture_data.save_png(thumbnail_cache_path)
#
					#scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
#
					#new_scene_view.queue_free()
					##This will cycle back trough this function and create buttons using the newly created thumbnails
					#reload_scene_view_buttons()
#
#
#
	## NOTE Left for 360 degree rotation of scene view on button NOT USED
	#rotate = true
	#
	#sub_collection_scene_count -= 1
	#if sub_collection_scene_count == 0:
		#count_finished += 1
		#if count_finished == 2: # The create scene buttons cycle happens twice, once for the Global-Shared Collections and again for the Project Scenes
			##if debug: print("FIRE OFF FINISHED")
			#emit_signal("tab_scene_buttons_created")
			##restore_saved_data()
			##new_main_collection_tab.set_tabs_close_state()
	##if debug: print("finished making the buttons")
	##self.print_tree_pretty()

var scene_instance: Node = null

#var scene_view_reference: Array[Button] = []

# DUPLICATE MULTI-THREADED TEST
# Version 2 360 rotation and anim playing
# FIXME Consider combining into 1 by removing using just thumbnail cache images (Many subviewports will cause lag)
#func create_scene_buttons(file_name: String, scenes_dir_path: String, new_sub_collection_tab: Control):
#func create_scene_buttons(loaded_scene: PackedScene, scene_full_path: String, new_sub_collection_tab: Control):
# TODO Fix pass_cache: bool because it is confusing consider create_cache? use_cache? and flip value of all functions calling it
#func create_scene_buttons(loaded_scene:, scene_full_path: String, new_sub_collection_tab: Control, new_scene_view: Button, pass_cache: bool):
## Step through function at different levels. Entire function opens every file and creates thumbnails. if pass_cache == false then thumbnails exist and can skip  
func create_scene_buttons(scene_full_path: String, new_sub_collection_tab: Control, new_scene_view: Button, pass_cache: bool) -> void:
	
	#if scene_full_path.is_empty():
		#scene_full_path = collection_scene_full_paths_array[index]
	#var collection_name: String = new_sub_collection_tab.name
	#if debug: print("new_sub_collection_tab name: ", new_sub_collection_tab.name)
	if debug: print("scene_full_path: ", scene_full_path)

	# Exclude scenes that will be removed on next startup from being creating buttons for them
	if unused_collection_scenes_path.has(scene_full_path):
		if debug: print("skipping button creation for scene at: ", scene_full_path)
		return
	
	if initialize_last_sub_collection_tab:
		last_sub_collection_tab = new_sub_collection_tab
		initialize_last_sub_collection_tab = false


	# TODO Create array with all extensions check scene_full_path.get_sxtension against array. has
	if accepted_file_ext.has(scene_full_path.get_extension()):
		if debug: print("A file with a valid extension has been found")
		
	#if scene_full_path.ends_with(".tscn") or scene_full_path.ends_with(".glb") or scene_full_path.ends_with(".fbx"):
		#if debug: print("THIS IS THE FULL PATH: ", scene_full_path)
		var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
		#if debug: print("thumbnail_cache_path: ", thumbnail_cache_path)
		#if scene_full_path.ends_with(".tscn"):
			#thumbnail_cache_path = 
		#if scene_full_path.ends_with(".fbx"):
			#thumbnail_cache_path = get_thumbnail_cache_path(".fbx", scene_full_path)
		#elif scene_full_path.ends_with(".glb"): # NOTE TODO THIS WILL BE USED IF .GLB FILES ARE ADDED TO USER:// 
			#thumbnail_cache_path = get_thumbnail_cache_path(".glb", scene_full_path)

		# FIXME MAYBE EXPENSIVE OPERATION??
		# After this function has gone through one time and the thumbnails have been generated
		# NOTE: If thumbnails have been created
		# FIXME NOT SURE IF SOMETHING BROKEN HERE BUT SEEMS LIKE SOME THAT HAVE THUMBNAILS ARE SLIPPING THROUGH AND CALLING get_camera_aabb_view()
		if user_dir.file_exists(thumbnail_cache_path) and pass_cache == false: # Allow for pass_cache to recreate scene for 3d and animation playing
			if debug: print("Thumbnail cache found skipping creating new thumbnails")

			#if debug: print("THUMBNAIL CACHE PATH: ", thumbnail_cache_path)
			#var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
			if new_scene_view == null:
				if debug: print("creating new scene")
				#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false, thumbnail_cache_path)
				new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
				
			else:
				if debug: print("not creating new scene")
				new_scene_view.visible = true
				new_scene_view.disabled = false

			## Add reference to easily cleanup on exit
			#if not scene_view_reference.has(new_scene_view):
				#scene_view_reference.append(new_scene_view)







			# NOTE: Runs on functions second pass, only if successful generation of thumbnails
			# For each scene_full_path check if data is stored in cache if yes then skip importing
			#if debug: print("scene_data_cache.scene_data.keys(): ", scene_data_cache.scene_data.keys())
			# NOTE: This will run for every scene how to only run once on initial import and then use cache after
			# could store every scene_full_path even with empties on initial load? but dict would be full of long path strings?
			# but here is where I would load everything in so lets try with all entered even empty and see about changing keys to shorter
			# maybe /collection/file_name.glb instead of full path? but maybe not enough resolution for duplicate collections and scenes in shared and global?
			# but would tags be different? you wouldn't have them in both. and if so you would want them treated same? (short path okay) different? (different need scene_full_path)
			# NOTE: import_mesh_tags(scene, scene_view_button) gets run in the get_camera_aabb_view() when loading scene so a loading scene file second time below should never happen

			# FIXME TODO Cleanup old entries when collections removed or .tscn or .scn scenes removed from res:// dir
			# If cache TODO this should be moved to lower part where thumbnails are genenrated after scene_lookup populated
			if scene_data_cache.scene_data.keys().has(scene_full_path):
				print("scene_data_cache has key: ", scene_full_path, " loading data from cache")
				new_scene_view.tags = scene_data_cache.scene_data[scene_full_path]["t"] # "tags"
				new_scene_view.shared_tags = scene_data_cache.scene_data[scene_full_path]["s"] # "shared_tags"
				new_scene_view.global_tags = scene_data_cache.scene_data[scene_full_path]["g"] # "global_tags"
				
				load_tags_to_tag_button_tool_tip(new_scene_view)

				print("cache shared tags: ", new_scene_view.shared_tags)
				# Maybe if cache then recreate scene buttons here?




			#else: # If cache does not exist but thumbnails do and scene_loading_complete
				##if not scene_loading_complete:
					##if debug: print("scene_loading_complete not complete")
					##reload_scene_view_buttons_func = true
					##return
				##var wait_count: int = 0
				##while not scene_loading_complete:
					##await get_tree().process_frame
					##wait_count += 1
					##if wait_count > 1000:
						##break



				#if not scene_lookup.is_empty() and scene_lookup.has(scene_full_path):
					#var scene_instance = scene_lookup[scene_full_path]
					#import_mesh_tags(scene_instance, new_scene_view)
#
				#else: # Fall back to loading single background thread or main thread
#
#
					## NOTE: This is why the editor is slow to boot when opne or have a collection open because I couldn't figure out how to mulithread it 
					## and it is loading in each scene file to get the metadata tags from each MeshInstance3D
					## NOTE: Single background thread loading
					#var scene_instance: Node = load_scene_instance(scene_full_path)
#
					## FIXME How to handle external updated shared tags when cache exists? this will be skipped
					## Then handle merging tags rather then replace
					#import_mesh_tags(scene_instance, new_scene_view)
#
						### FIXME TODO PROCESS OTHER SCENE SPECIFIC THINGS HERE TOO LIKE ANIMATIONS ETC INSTEAD OF BELOW.
		##
					##var animation_player_node_instances: Array[Node] = scene_instance.find_children("*", "AnimationPlayer", true, false)
					##if debug: print("animation_player_node_instances: ", animation_player_node_instances)
					##if animation_player_node_instances.size() >= 1:
						##if debug: print("new_scene_view 1: ", new_scene_view)
						##new_scene_view.animation_texture_button.show()
		##
		##
					### FIXME COPY TEXTURES OVER TO COLLECTIONS FOLDER ON DRAG AND DROP?
		##
					### Remove scene so that it is not held in memory
					## I think this is why I can't go back over??
					## FIXME after mouse_enter and scene loaded from scene_lookup scene are being freed from memory?
					#if debug: print("removing scene instance")
					#scene_instance.queue_free()


# FIXME NEEDS TO BE FIXED REMOVING subviewport_container CAUSES ISSUES WITH scene_lookup AS WELL AS KEPING IT IN
			# FIXME TODO Fit for both holding in memory and pulling data from disk in low vram setting
			## subviewport_container is part of default .tscn file and is used to create thumbnail .png before 
			## being freed from memory
			var subviewport_container: Control = new_scene_view.sub_viewport_container
#			subviewport_container.queue_free()
			subviewport_container.free() # Free to avoid ERROR: scene/main/node.cpp:1779 - Index p_index = 0 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).

			#load_thumbnails(scene_full_path, new_sub_collection_tab, thumbnail_cache_path, false)
			#var new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
			var new_sprite = Sprite2D.new()
			var image: Image = Image.load_from_file(thumbnail_cache_path)
			image.clear_mipmaps()
			image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
			new_sprite.texture = ImageTexture.create_from_image(image)
			new_sprite.centered = false
			# Set based off of scene_view scale_size and matches SubViewportContainer position
			new_sprite.position = Vector2(0.0, 13.0)
			new_scene_view.child_sprite = new_sprite
			new_scene_view.add_child(new_sprite)
			#new_scene_view.move_child(new_sprite, 0)

			
			await get_tree().create_timer(0.001).timeout
			new_scene_view.set_scene_view_size(thumbnail_size_value)








		else: # Only runs code below this point on first run when no thumbnails or pass_cache == true
			#if not scene_loading_complete:
				## There was no thumbnail cache from previous so reload function when loading of all scenes is complete required
				#reload_scene_view_buttons_func = true
				#return
			if debug: print("creating scene view again")
			#if debug: print(" THIS IS THE scene_full_path: ", scene_full_path)
			#if ResourceLoader.exists(scene_full_path):
				#if debug: print("LOADER EXISTS")
			
			
			
			#if pass_cache:
			#if debug: print("creating scene view again")
			#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false, thumbnail_cache_path)
			new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
			#else:
				#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, true)
				##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)

			if pass_cache == false:
				new_scene_view.visible = false
				new_scene_view.disabled = true
				
			var subviewport_child: SubViewport = new_scene_view.get_child(0).get_child(0)#.get_child(0)
			




			#var scene: Node3D = null
			#var scene: StaticBody3D = null



			
			## Exclude non PackedScene files .obj and just generate thumbnails
			if scene_full_path.get_extension() == "obj":
				return
				## scene_full_path will need to reference PackedScene path which is swapped out for each .obj
				## So PackedScene is created camera gets and creates thumbnail then next .obj replaces old one in scene and repeat
				## When hovering over will need to repeat the process 
				##var loaded_scene = load(full_path_split(scene_full_path, true)[0].path_join(".obj"))
				##var loaded_scene = load(full_path_split(scene_full_path, true)[0])
				##var loaded_scene = load(scene_full_path)
				#var obj_scene = load(scene_full_path)
				#var new_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
				#new_mesh_instance_3d.set_mesh(obj_scene)
				#
				##var obj_scene: Node3D = loaded_scene.instantiate()
#
				### Create and save scene
				#var packed_scene = PackedScene.new()
				##packed_scene.pack(tscn_static_body)
				#packed_scene.pack(new_mesh_instance_3d)
				##var save_path = "res://project_scenes/" + tscn_static_body.name + ".tscn"
				##var scene_name: String = tscn_static_body.get_child(0).name
				## FIXME TODO FIND BEST WAY TO NAME SAME ABOVE
				##var scene_name: String = tscn_static_body.name
				#var scene_name: String = "temp_obj_scene"
				##var scene_name: String = full_path_split(scene_full_path, true)[0]
				#var path_to_save_scene: String = "res://collections/project/"
				#
				#var save_path: String = path_to_save_scene.path_join(scene_name + ".tscn")
				##if debug: print("Saving scene... " + save_path)
				##ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
				#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
#
				#scene_full_path = save_path
				#new_mesh_instance_3d.queue_free()






			if debug: print("scene_full_path: ", scene_full_path)


# ORIGINAL WORKING NON-THREAD
			var scene: Node = null
			#push_error("get_camera_aabb_view START")
			var scene_instance = await get_camera_aabb_view(new_scene_view, scene, scene_full_path, subviewport_child)
			#push_error("get_camera_aabb_view FINISHED")

# TEST To free memory 
			#scene_instance.free()



			
			if scene_instance:
				if debug: print("scene_instance: ", scene_instance)
				for child: Node in scene_instance.get_children():
					if debug: print("THIS IS A CHILD OF THE SCENE: ", child)
					# TODO change out icon to match body and collision
					#if debug: print("Collision_3D_State: ", Collision_3D_State)
					if child is CollisionShape3D:
						if debug: print("CollisionShape3D.shape: ", child.get_shape().get_class())
						new_scene_view.texture_rect_collision.show()
					else:
						new_scene_view.texture_rect_collision.hide()


			# Show attribute buttons
			var body_type_map = {
				"NO_PHYSICSBODY3D": "no_body",
				"NODE3D": "node",
				"STATICBODY3D": "static",
				"RIGIDBODY3D": "rigid",
				"CHARACTERBODY3D": "character"
			}


			var col_3d_string: String = ""
			var col_3d
			match current_3d_collision_state:
				"NO_COLLISION": col_3d = NO_COLLISION
				"SPHERESHAPE3D": col_3d_string = "SphereShape3D"
				"BOXSHAPE3D": col_3d_string = "BoxShape3D"
				"CAPSULESHAPE3D": col_3d_string = "CapsuleShape3D"
				"CYLINDERSHAPE3D": col_3d_string = "CylinderShape3D"
				"SIMPLIFIED_CONVEX": col_3d = SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D
				"SINGLE_CONVEX": col_3d = SINGLE_CONVEX_POLYGON_SHAPE_3D
				"MULTI_CONVEX": col_3d = MULTI_CONVEX_POLYGON_SHAPE_3D
				"TRIMESH": col_3d_string = "ConcavePolygonShape3D"

			if col_3d_string != "":
				# FIXME SEEMS to work sometimes but also might need to be stored to show after restart
				new_scene_view.texture_rect_collision.set_texture(get_theme_icon(&"col_3d_string", &"EditorIcons"))
			else:
				new_scene_view.texture_rect_collision.set_texture(col_3d)


			#var animation_player_node_instances: Array[Node] = scene_instance.find_children("*", "AnimationPlayer", true, false)
			#if debug: print("animation_player_node_instances: ", animation_player_node_instances)
			#if animation_player_node_instances.size() >= 1:
				#if debug: print("new_scene_view 1: ", new_scene_view)
				#new_scene_view.show_animation_texture_button = true
				##new_scene_view
				#scene_has_animation.append(scene_full_path)
				##new_scene_view.set_meta("has_animation", true)




			if pass_cache == false:


## TEST Check for time impact
				#var start_time = Time.get_ticks_msec()
#
#
				## Get the location within the filesystem where the .png thumbnails should be placed
				#var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
				#var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
#
				## Create the filesystem folders for the .png thumbnails
				#if thumb_path_split[1] == "project_scenes":
					#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
				#else:
					#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
				## Requird for subviewport texture to draw correctly, first check if connection is already made
				#if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
					#await RenderingServer.frame_pre_draw
				#subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
				#await RenderingServer.frame_post_draw
#
				## Get the viewport texture and save it as a png thumbnail at the thumbnail_cache_path
				#var texture_data = subviewport_child.get_viewport().get_texture().get_image()
				#texture_data.save_png(thumbnail_cache_path)
#
				## Add this scene to the array of buttons that need to go through this function again and load the thumbnail
				#scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
#
#
				#var end_time = Time.get_ticks_msec()
				#var elapsed_time = end_time - start_time
				#if debug: print("getting thumbnail path and creating thumbnail took ", elapsed_time, " milliseconds")


# TEST Check for time impact
				#var start_time = Time.get_ticks_msec()

				# TODO Maybe can be put on background thread?
				# Get the location within the filesystem where the .png thumbnails should be placed
				var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
				#var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]

				# Create the filesystem folders for the .png thumbnails
				if thumb_path_split[1] == "project_scenes":
					create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
				else:
					create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))

				# Requird for subviewport texture to draw correctly, first check if connection is already made
				if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
					await RenderingServer.frame_pre_draw
				subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
				await RenderingServer.frame_post_draw

				# Get the viewport texture and save it as a png thumbnail at the thumbnail_cache_path
				var texture_data = subviewport_child.get_viewport().get_texture().get_image()
				texture_data.save_png(thumbnail_cache_path)

				# Add this scene to the array of buttons that need to go through this function again and load the thumbnail
				scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab


				#var end_time = Time.get_ticks_msec()
				#var elapsed_time = end_time - start_time
				#if debug: print("getting thumbnail path and creating thumbnail took ", elapsed_time, " milliseconds")




				# Cycle back trough this function and create buttons using the newly created thumbnails
				reload_scene_view_buttons(new_scene_view)



#
			#else: # FIXME Create thumbnails for .glb and gltf files ## TODO Repeat code from above combine into function
				#if debug: print("RUNNING THIS CODE")
#
				#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
				#if pass_cache == false:
					#new_scene_view.visible = false
					#new_scene_view.disabled = true
				#var subviewport_child: SubViewport = new_scene_view.get_child(0).get_child(0).get_child(0)
				#var scene: StaticBody3D = null
				#var scene_instance = get_camera_aabb_view(scene, scene_full_path, subviewport_child)
#
				##for child: Node in scene_instance.get_children():
					##if debug: print("THIS IS A CHILD OF THE SCENE: ", child)
				#if pass_cache == false:
					#var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
					#var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
#
					## Create the filesystem folders for the .png thumbnails
					#if thumb_path_split[1] == "project_scenes":
						#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
					#else:
						#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
					## NOTE: REVISED TODO: Check for errors
					#if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
						#await RenderingServer.frame_pre_draw
#
					#subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
					#await RenderingServer.frame_post_draw
#
					#var texture_data = subviewport_child.get_viewport().get_texture().get_image()
	##
					#texture_data.save_png(thumbnail_cache_path)
					#
					#scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
					#
					#reload_scene_view_buttons(new_scene_view)







				#if not pass_cache:
				##if run_once:
					##run_once = false
					#var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
					#var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
#
					#if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
						#await RenderingServer.frame_pre_draw
					#subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
					#await RenderingServer.frame_post_draw
#
					#var texture_data = subviewport_child.get_viewport().get_texture().get_image()
					#texture_data.save_png(thumbnail_cache_path)
					#scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
#
					#reload_scene_view_buttons(new_scene_view)

				#var gltf := GLTFDocument.new()
				#var gltf_state := GLTFState.new()
				#var snd_file = FileAccess.open(scene_full_path, FileAccess.READ)
				#var fileBytes = PackedByteArray()
				#fileBytes = snd_file.get_buffer(snd_file.get_length())
				#gltf.append_from_buffer(fileBytes, "user://global_collections/scenes/Global Collections/tree/", gltf_state, 8)
				#
				#var path: String = "res://collections/tree/"
				#var error1 = gltf.write_to_filesystem(gltf_state, path)
				#if error1 != OK:
					#if debug: print("failed to write gltf")
				

#var run_once: bool = true



# ORIGINAL WORKING
## Version 2 360 rotation and anim playing
## FIXME Consider combining into 1 by removing using just thumbnail cache images (Many subviewports will cause lag)
##func create_scene_buttons(file_name: String, scenes_dir_path: String, new_sub_collection_tab: Control):
##func create_scene_buttons(loaded_scene: PackedScene, scene_full_path: String, new_sub_collection_tab: Control):
## TODO Fix pass_cache: bool because it is confusing consider create_cache? use_cache? and flip value of all functions calling it
##func create_scene_buttons(loaded_scene:, scene_full_path: String, new_sub_collection_tab: Control, new_scene_view: Button, pass_cache: bool):
### Step through function at different levels. Entire function opens every file and creates thumbnails. if pass_cache == false then thumbnails exist and can skip  
#func create_scene_buttons(scene_full_path: String, new_sub_collection_tab: Control, new_scene_view: Button, pass_cache: bool) -> void:
	##var collection_name: String = new_sub_collection_tab.name
	##if debug: print("new_sub_collection_tab name: ", new_sub_collection_tab.name)
	#if debug: print("scene_full_path: ", scene_full_path)
#
	## Exclude scenes that will be removed on next startup from being creating buttons for them
	#if unused_collection_scenes_path.has(scene_full_path):
		#if debug: print("skipping button creation for scene at: ", scene_full_path)
		#return
	#
	#if initialize_last_sub_collection_tab:
		#last_sub_collection_tab = new_sub_collection_tab
		#initialize_last_sub_collection_tab = false
#
#
	## TODO Create array with all extensions check scene_full_path.get_sxtension against array. has
	#if accepted_file_ext.has(scene_full_path.get_extension()):
		#if debug: print("A file with a valid extension has been found")
		#
	##if scene_full_path.ends_with(".tscn") or scene_full_path.ends_with(".glb") or scene_full_path.ends_with(".fbx"):
		##if debug: print("THIS IS THE FULL PATH: ", scene_full_path)
		#var thumbnail_cache_path: String = get_thumbnail_cache_path(scene_full_path)
		##if debug: print("thumbnail_cache_path: ", thumbnail_cache_path)
		##if scene_full_path.ends_with(".tscn"):
			##thumbnail_cache_path = 
		##if scene_full_path.ends_with(".fbx"):
			##thumbnail_cache_path = get_thumbnail_cache_path(".fbx", scene_full_path)
		##elif scene_full_path.ends_with(".glb"): # NOTE TODO THIS WILL BE USED IF .GLB FILES ARE ADDED TO USER:// 
			##thumbnail_cache_path = get_thumbnail_cache_path(".glb", scene_full_path)
#
		## FIXME MAYBE EXPENSIVE OPERATION??
		## After this function has gone through one time and the thumbnails have been generated
		## NOTE: If thumbnails have been created
		## FIXME NOT SURE IF SOMETHING BROKEN HERE BUT SEEMS LIKE SOME THAT HAVE THUMBNAILS ARE SLIPPING THROUGH AND CALLING get_camera_aabb_view()
		#if user_dir.file_exists(thumbnail_cache_path) and pass_cache == false: # Allow for pass_cache to recreate scene for 3d and animation playing
			#if debug: print("Thumbnail cache found skipping creating new thumbnails")
#
			##if debug: print("THUMBNAIL CACHE PATH: ", thumbnail_cache_path)
			##var new_scene_view: Button = instance_scene_view(new_sub_collection_tab, scene_full_path, scene_name_split)
			#if new_scene_view == null:
				#if debug: print("creating new scene")
				##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false, thumbnail_cache_path)
				#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
				#
			#else:
				#if debug: print("not creating new scene")
				#new_scene_view.visible = true
				#new_scene_view.disabled = false
#
			### Add reference to easily cleanup on exit
			##if not scene_view_reference.has(new_scene_view):
				##scene_view_reference.append(new_scene_view)
#
#
#
#
#
#
#
			## NOTE: Runs on functions second pass, only if successful generation of thumbnails
			## For each scene_full_path check if data is stored in cache if yes then skip importing
			##if debug: print("scene_data_cache.scene_data.keys(): ", scene_data_cache.scene_data.keys())
			## NOTE: This will run for every scene how to only run once on initial import and then use cache after
			## could store every scene_full_path even with empties on initial load? but dict would be full of long path strings?
			## but here is where I would load everything in so lets try with all entered even empty and see about changing keys to shorter
			## maybe /collection/file_name.glb instead of full path? but maybe not enough resolution for duplicate collections and scenes in shared and global?
			## but would tags be different? you wouldn't have them in both. and if so you would want them treated same? (short path okay) different? (different need scene_full_path)
			## NOTE: import_mesh_tags(scene, scene_view_button) gets run in the get_camera_aabb_view() when loading scene so a loading scene file second time below should never happen
#
			## FIXME TODO Cleanup old entries when collections removed or .tscn or .scn scenes removed from res:// dir
			## If cache TODO this should be moved to lower part where thumbnails are genenrated after scene_lookup populated
			#if scene_data_cache.scene_data.keys().has(scene_full_path):
				#if debug: print("scene_data_cache has key: ", scene_full_path, " loading data from cache")
				#new_scene_view.tags = scene_data_cache.scene_data[scene_full_path]["t"] # "tags"
				#new_scene_view.shared_tags = scene_data_cache.scene_data[scene_full_path]["s"] # "shared_tags"
				#new_scene_view.global_tags = scene_data_cache.scene_data[scene_full_path]["g"] # "global_tags"
				#
				#load_tags_to_tag_button_tool_tip(new_scene_view)
#
#
#
#
#
			##else: # If cache does not exist but thumbnails do and scene_loading_complete
				###if not scene_loading_complete:
					###if debug: print("scene_loading_complete not complete")
					###reload_scene_view_buttons_func = true
					###return
				###var wait_count: int = 0
				###while not scene_loading_complete:
					###await get_tree().process_frame
					###wait_count += 1
					###if wait_count > 1000:
						###break
#
#
#
				##if not scene_lookup.is_empty() and scene_lookup.has(scene_full_path):
					##var scene_instance = scene_lookup[scene_full_path]
					##import_mesh_tags(scene_instance, new_scene_view)
##
				##else: # Fall back to loading single background thread or main thread
##
##
					### NOTE: This is why the editor is slow to boot when opne or have a collection open because I couldn't figure out how to mulithread it 
					### and it is loading in each scene file to get the metadata tags from each MeshInstance3D
					### NOTE: Single background thread loading
					##var scene_instance: Node = load_scene_instance(scene_full_path)
##
					### FIXME How to handle external updated shared tags when cache exists? this will be skipped
					### Then handle merging tags rather then replace
					##import_mesh_tags(scene_instance, new_scene_view)
##
						#### FIXME TODO PROCESS OTHER SCENE SPECIFIC THINGS HERE TOO LIKE ANIMATIONS ETC INSTEAD OF BELOW.
		###
					###var animation_player_node_instances: Array[Node] = scene_instance.find_children("*", "AnimationPlayer", true, false)
					###if debug: print("animation_player_node_instances: ", animation_player_node_instances)
					###if animation_player_node_instances.size() >= 1:
						###if debug: print("new_scene_view 1: ", new_scene_view)
						###new_scene_view.animation_texture_button.show()
		###
		###
					#### FIXME COPY TEXTURES OVER TO COLLECTIONS FOLDER ON DRAG AND DROP?
		###
					#### Remove scene so that it is not held in memory
					### I think this is why I can't go back over??
					### FIXME after mouse_enter and scene loaded from scene_lookup scene are being freed from memory?
					##if debug: print("removing scene instance")
					##scene_instance.queue_free()
#
#
## FIXME NEEDS TO BE FIXED REMOVING subviewport_container CAUSES ISSUES WITH scene_lookup AS WELL AS KEPING IT IN
			## FIXME TODO Fit for both holding in memory and pulling data from disk in low vram setting
			### subviewport_container is part of default .tscn file and is used to create thumbnail .png before 
			### being freed from memory
			#var subviewport_container: Control = new_scene_view.sub_viewport_container
##			subviewport_container.queue_free()
			#subviewport_container.free() # Free to avoid ERROR: scene/main/node.cpp:1779 - Index p_index = 0 is out of bounds ((int)data.children_cache.size() - data.internal_children_front_count_cache - data.internal_children_back_count_cache = 0).
#
			##load_thumbnails(scene_full_path, new_sub_collection_tab, thumbnail_cache_path, false)
			##var new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
			#var new_sprite = Sprite2D.new()
			#var image: Image = Image.load_from_file(thumbnail_cache_path)
			#image.clear_mipmaps()
			#image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
			#new_sprite.texture = ImageTexture.create_from_image(image)
			#new_sprite.centered = false
			## Set based off of scene_view scale_size and matches SubViewportContainer position
			#new_sprite.position = Vector2(0.0, 13.0)
			#new_scene_view.child_sprite = new_sprite
			#new_scene_view.add_child(new_sprite)
			##new_scene_view.move_child(new_sprite, 0)
#
			#
			#await get_tree().create_timer(0.001).timeout
			#new_scene_view.set_scene_view_size(thumbnail_size_value)
#
#
#
#
#
#
#
#
		#else: # Only runs code below this point on first run when no thumbnails or pass_cache == true
			##if not scene_loading_complete:
				### There was no thumbnail cache from previous so reload function when loading of all scenes is complete required
				##reload_scene_view_buttons_func = true
				##return
			#if debug: print("creating scene view again")
			##if debug: print(" THIS IS THE scene_full_path: ", scene_full_path)
			##if ResourceLoader.exists(scene_full_path):
				##if debug: print("LOADER EXISTS")
			#
			#
			#
			##if pass_cache:
			##if debug: print("creating scene view again")
			##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false, thumbnail_cache_path)
			#new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
			##else:
				##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, true)
				###new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, file_name_split, false)
#
			#if pass_cache == false:
				#new_scene_view.visible = false
				#new_scene_view.disabled = true
				#
			#var subviewport_child: SubViewport = new_scene_view.get_child(0).get_child(0)#.get_child(0)
			#
#
#
#
#
			##var scene: Node3D = null
			##var scene: StaticBody3D = null
#
#
#
			#
			### Exclude non PackedScene files .obj and just generate thumbnails
			#if scene_full_path.get_extension() == "obj":
				#return
				### scene_full_path will need to reference PackedScene path which is swapped out for each .obj
				### So PackedScene is created camera gets and creates thumbnail then next .obj replaces old one in scene and repeat
				### When hovering over will need to repeat the process 
				###var loaded_scene = load(full_path_split(scene_full_path, true)[0].path_join(".obj"))
				###var loaded_scene = load(full_path_split(scene_full_path, true)[0])
				###var loaded_scene = load(scene_full_path)
				##var obj_scene = load(scene_full_path)
				##var new_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
				##new_mesh_instance_3d.set_mesh(obj_scene)
				##
				###var obj_scene: Node3D = loaded_scene.instantiate()
##
				#### Create and save scene
				##var packed_scene = PackedScene.new()
				###packed_scene.pack(tscn_static_body)
				##packed_scene.pack(new_mesh_instance_3d)
				###var save_path = "res://project_scenes/" + tscn_static_body.name + ".tscn"
				###var scene_name: String = tscn_static_body.get_child(0).name
				### FIXME TODO FIND BEST WAY TO NAME SAME ABOVE
				###var scene_name: String = tscn_static_body.name
				##var scene_name: String = "temp_obj_scene"
				###var scene_name: String = full_path_split(scene_full_path, true)[0]
				##var path_to_save_scene: String = "res://collections/project/"
				##
				##var save_path: String = path_to_save_scene.path_join(scene_name + ".tscn")
				###if debug: print("Saving scene... " + save_path)
				###ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
				##ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
##
				##scene_full_path = save_path
				##new_mesh_instance_3d.queue_free()
#
#
#
#
#
#
			#if debug: print("scene_full_path: ", scene_full_path)
#
#
## ORIGINAL WORKING NON-THREAD
			#var scene: Node = null
			##push_error("get_camera_aabb_view START")
			#var scene_instance = await get_camera_aabb_view(new_scene_view, scene, scene_full_path, subviewport_child)
			##push_error("get_camera_aabb_view FINISHED")
#
#
#
#
			#if debug: print("scene_instance: ", scene_instance)
			#for child: Node in scene_instance.get_children():
				#if debug: print("THIS IS A CHILD OF THE SCENE: ", child)
				## TODO change out icon to match body and collision
				##if debug: print("Collision_3D_State: ", Collision_3D_State)
				#if child is CollisionShape3D:
					#if debug: print("CollisionShape3D.shape: ", child.get_shape().get_class())
					#new_scene_view.texture_rect_collision.show()
				#else:
					#new_scene_view.texture_rect_collision.hide()
#
#
			## Show attribute buttons
			#var body_type_map = {
				#"NO_PHYSICSBODY3D": "no_body",
				#"NODE3D": "node",
				#"STATICBODY3D": "static",
				#"RIGIDBODY3D": "rigid",
				#"CHARACTERBODY3D": "character"
			#}
#
#
			#var col_3d_string: String = ""
			#var col_3d
			#match current_3d_collision_state:
				#"NO_COLLISION": col_3d = NO_COLLISION
				#"SPHERESHAPE3D": col_3d_string = "SphereShape3D"
				#"BOXSHAPE3D": col_3d_string = "BoxShape3D"
				#"CAPSULESHAPE3D": col_3d_string = "CapsuleShape3D"
				#"CYLINDERSHAPE3D": col_3d_string = "CylinderShape3D"
				#"SIMPLIFIED_CONVEX": col_3d = SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D
				#"SINGLE_CONVEX": col_3d = SINGLE_CONVEX_POLYGON_SHAPE_3D
				#"MULTI_CONVEX": col_3d = MULTI_CONVEX_POLYGON_SHAPE_3D
				#"TRIMESH": col_3d_string = "ConcavePolygonShape3D"
#
			#if col_3d_string != "":
				## FIXME SEEMS to work sometimes but also might need to be stored to show after restart
				#new_scene_view.texture_rect_collision.set_texture(get_theme_icon(&"col_3d_string", &"EditorIcons"))
			#else:
				#new_scene_view.texture_rect_collision.set_texture(col_3d)
#
#
			##var animation_player_node_instances: Array[Node] = scene_instance.find_children("*", "AnimationPlayer", true, false)
			##if debug: print("animation_player_node_instances: ", animation_player_node_instances)
			##if animation_player_node_instances.size() >= 1:
				##if debug: print("new_scene_view 1: ", new_scene_view)
				##new_scene_view.show_animation_texture_button = true
				###new_scene_view
				##scene_has_animation.append(scene_full_path)
				###new_scene_view.set_meta("has_animation", true)
#
#
#
#
			#if pass_cache == false:
#
#
### TEST Check for time impact
				##var start_time = Time.get_ticks_msec()
##
##
				### Get the location within the filesystem where the .png thumbnails should be placed
				##var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
				##var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
##
				### Create the filesystem folders for the .png thumbnails
				##if thumb_path_split[1] == "project_scenes":
					##create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
				##else:
					##create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
##
				### Requird for subviewport texture to draw correctly, first check if connection is already made
				##if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
					##await RenderingServer.frame_pre_draw
				##subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
				##await RenderingServer.frame_post_draw
##
				### Get the viewport texture and save it as a png thumbnail at the thumbnail_cache_path
				##var texture_data = subviewport_child.get_viewport().get_texture().get_image()
				##texture_data.save_png(thumbnail_cache_path)
##
				### Add this scene to the array of buttons that need to go through this function again and load the thumbnail
				##scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
##
##
				##var end_time = Time.get_ticks_msec()
				##var elapsed_time = end_time - start_time
				##if debug: print("getting thumbnail path and creating thumbnail took ", elapsed_time, " milliseconds")
#
#
## TEST Check for time impact
				##var start_time = Time.get_ticks_msec()
#
				## TODO Maybe can be put on background thread?
				## Get the location within the filesystem where the .png thumbnails should be placed
				#var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
				##var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
#
				## Create the filesystem folders for the .png thumbnails
				#if thumb_path_split[1] == "project_scenes":
					#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
				#else:
					#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
				## Requird for subviewport texture to draw correctly, first check if connection is already made
				#if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
					#await RenderingServer.frame_pre_draw
				#subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
				#await RenderingServer.frame_post_draw
#
				## Get the viewport texture and save it as a png thumbnail at the thumbnail_cache_path
				#var texture_data = subviewport_child.get_viewport().get_texture().get_image()
				#texture_data.save_png(thumbnail_cache_path)
#
				## Add this scene to the array of buttons that need to go through this function again and load the thumbnail
				#scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
#
#
				##var end_time = Time.get_ticks_msec()
				##var elapsed_time = end_time - start_time
				##if debug: print("getting thumbnail path and creating thumbnail took ", elapsed_time, " milliseconds")
#
#
#
#
				## Cycle back trough this function and create buttons using the newly created thumbnails
				#reload_scene_view_buttons(new_scene_view)
#
#
#
##
			##else: # FIXME Create thumbnails for .glb and gltf files ## TODO Repeat code from above combine into function
				##if debug: print("RUNNING THIS CODE")
##
				##new_scene_view = instance_scene_view(new_sub_collection_tab, scene_full_path, false)
				##if pass_cache == false:
					##new_scene_view.visible = false
					##new_scene_view.disabled = true
				##var subviewport_child: SubViewport = new_scene_view.get_child(0).get_child(0).get_child(0)
				##var scene: StaticBody3D = null
				##var scene_instance = get_camera_aabb_view(scene, scene_full_path, subviewport_child)
##
				###for child: Node in scene_instance.get_children():
					###if debug: print("THIS IS A CHILD OF THE SCENE: ", child)
				##if pass_cache == false:
					##var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
					##var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
##
					### Create the filesystem folders for the .png thumbnails
					##if thumb_path_split[1] == "project_scenes":
						##create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3])))
					##else:
						##create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
##
					### NOTE: REVISED TODO: Check for errors
					##if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
						##await RenderingServer.frame_pre_draw
##
					##subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
					##await RenderingServer.frame_post_draw
##
					##var texture_data = subviewport_child.get_viewport().get_texture().get_image()
	###
					##texture_data.save_png(thumbnail_cache_path)
					##
					##scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
					##
					##reload_scene_view_buttons(new_scene_view)
#
#
#
#
#
#
#
				##if not pass_cache:
				###if run_once:
					###run_once = false
					##var thumb_path_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), false) # ["user:", "global_collections", "scenes", "Global Collections", "New folder", "SM_SFloorCornerR--Tags.tscn"]
					##var thumb_file_name_split: PackedStringArray = full_path_split(get_thumbnail_cache_path(scene_full_path), true) # ["SM_SFloorCornerR.png"]
##
					##if not RenderingServer.frame_pre_draw.is_connected(func () -> void: RenderingServer.frame_pre_draw):
						##await RenderingServer.frame_pre_draw
					##subviewport_child.set_update_mode(SubViewport.UPDATE_ONCE)
					##await RenderingServer.frame_post_draw
##
					##var texture_data = subviewport_child.get_viewport().get_texture().get_image()
					##texture_data.save_png(thumbnail_cache_path)
					##scenes_full_paths_to_reload[scene_full_path] = new_sub_collection_tab
##
					##reload_scene_view_buttons(new_scene_view)
#
				##var gltf := GLTFDocument.new()
				##var gltf_state := GLTFState.new()
				##var snd_file = FileAccess.open(scene_full_path, FileAccess.READ)
				##var fileBytes = PackedByteArray()
				##fileBytes = snd_file.get_buffer(snd_file.get_length())
				##gltf.append_from_buffer(fileBytes, "user://global_collections/scenes/Global Collections/tree/", gltf_state, 8)
				##
				##var path: String = "res://collections/tree/"
				##var error1 = gltf.write_to_filesystem(gltf_state, path)
				##if error1 != OK:
					##if debug: print("failed to write gltf")
				#
#
##var run_once: bool = true


func _on_frame_pre_draw() -> void:
	

	# NOTE Left for 360 degree rotation of scene view on button NOT USED
	rotate = true
	
	#settings.set_setting("scene_snap_plugin/scenes_with_animations", scene_has_animation)
	#settings.erase("scene_snap_plugin/scenes_with_animations")
	#settings.erase("scene_snap_plugin/scenes_with_animations/scenes")
	
	sub_collection_scene_count -= 1
	if sub_collection_scene_count == 0:
		count_finished += 1
		if count_finished == 2: # The create scene buttons cycle happens twice, once for the Global-Shared Collections and again for the Project Scenes
			#if debug: print("FIRE OFF FINISHED")
			emit_signal("tab_scene_buttons_created")
			#restore_saved_data()
			#new_main_collection_tab.set_tabs_close_state()
	#if debug: print("finished making the buttons")
	#self.print_tree_pretty()





### Required for the initial creation of scene thumbnails
## FIXME not sure why I had scene: Node3D as argument and populate with var scene: StaticBody3D = null before calling function?????????
## Oh it's called from new_scene_view.reload_scene.connect(get_camera_aabb_view) I guess to save from running again if alrady instanced?????
##func get_camera_aabb_view(scene: Node, scene_full_path: String, subviewport_child: SubViewport) -> Node:
## This is run when hovering over the thumbnail or when creating thumbnail for the first time if it doesn't already exist
#func get_camera_aabb_view(scene_view_button: Button, scene: Node, scene_full_path: String, subviewport_child: SubViewport) -> void:
	#if debug: print("getting camera")
	#if scene == null:
		##if thread.start(load_scene_instance.bind("scene_full_path")) == OK:
			##if debug: print("thread running")
#
		##threads.push_back(Thread.new())
		##var handle_data_flag: String = "do_camera_stuff"
		##threads[-1].start(load_scene_data.bind(scene_full_path, scene_view_button, handle_data_flag, subviewport_child))
		##threads[-1].start(load_scene_data.bind(scene_full_path, scene_view_button))
		##scene = scene_instance
		#scene = load_scene_instance(scene_full_path)
		##scene = scene_view_button.load_scene_instance(scene_full_path)
	#else:
		#do_camera_stuff(scene, subviewport_child)
#
#func do_camera_stuff(scene: Node, subviewport_child: SubViewport) -> void:
	#if debug: print("doing camera stuff now")
	#var new_camera_3d: Node3D = SCENE_VIEW_CAMERA_3D.instantiate()
#
	##subviewport_child.call_deferred("add_child", scene)
	#subviewport_child.add_child(scene)
	##scene.call_deferred("set_owner", self)
	#scene.owner = self
#
	## NOTE add to all_scenes_instances to enable rotation on them
	#all_scenes_instances.append(scene)
#
	## NOTE Camera3D was instatiated here as a result of an error when instanced as part of the scene_view /
	## scene and calling get_child to find the mesh_node when running _focus_camera_on_node_3d
	#scene.add_sibling(new_camera_3d, true)
	#new_camera_3d.name = "NewCamera3D"
	#new_camera_3d.owner = self
#
#
#
	#var aabb: AABB = AABB()  # Initialize an empty AABB
	#var mesh_node: MeshInstance3D
	##var mesh_node_count: int
	#
	#
	## Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
	## When there is no thumbnails this is run twice so can be optimized for when scenes are first dragged and dropped or generated from scenes placed in folder
	#scenes_with_multiple_meshes.clear()
	#scenes_with_mesh_tag_data.clear()
	#var mesh_node_instances: Array[Node] = scene.find_children("*", "MeshInstance3D", true, false)
	#if debug: print("The ", scene.name, " has: ", mesh_node_instances.size(), " MeshInstance3D Nodes")
	##if debug: print("mesh_node_instances.size: ", mesh_node_instances.size())
	#if mesh_node_instances.size() == 1:
		#if scene.get_child(0) is MeshInstance3D:
			#mesh_node = scene.get_child(0)
			#aabb = mesh_node.get_aabb()
#
		#elif scene.get_child(0).get_child(0) is MeshInstance3D:
			#mesh_node = scene.get_child(0).get_child(0)
			#aabb = mesh_node.get_aabb()
#
		#set_camera_aabb_offset(aabb, new_camera_3d, mesh_node_instances)
#
	#else:
		## Store scenes with multiple meshes with their meshes in a dictionary
		## NOTE This is only run when no thumbnails exist for 1st imported scene. Storage per session is done in create_scene_buttons() func.
		#scenes_with_multiple_meshes[scene.name] = mesh_node_instances
		#
		#
		#
		## Trigger MultipleMeshGLB button visible
#
		#var mesh_node_names: Dictionary = {}  # Use a Dictionary for unique names
		##var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)
#
		#for mesh_node_child: Node in mesh_node_instances:
			### TEST On exporting new single .glb files for each of the mesh instances in the scene
			##export_gltf(mesh_node_child, scene_full_path.path_join(mesh_node_child.name + ".glb"))
#
			## Scan the filesystem to update
			#var editor_filesystem = EditorInterface.get_resource_filesystem()
			#editor_filesystem.scan()
			#
			##if debug: print("mesh_node: ", mesh_node)
			#
			### FIXME Will not work with .glb
			##if scene_full_path.ends_with(".tscn"):
				##mesh_node_child.get_surface_override_material(0).cull_mode = 2 #CULL_DISABLED
			#
			#if not mesh_node_names.has(mesh_node_child.name):
				#mesh_node_names[mesh_node_child.name] = true  # Mark the name as seen
#
				### Merge the AABB of this mesh node
				#aabb = aabb.merge(mesh_node_child.get_aabb())  # Update AABB with the new one
#
		#set_camera_aabb_offset(aabb, new_camera_3d, mesh_node_instances)
#
	#scene_instance = scene
	##return scene






var gltf_load_complete: bool = false

#var run_thread: bool = true


### Required for the initial creation of scene thumbnails
## FIXME not sure why I had scene: Node3D as argument and populate with var scene: StaticBody3D = null before calling function?????????
## Oh it's called from new_scene_view.reload_scene.connect(get_camera_aabb_view) I guess to save from running again if alrady instanced?????
##func get_camera_aabb_view(scene: Node, scene_full_path: String, subviewport_child: SubViewport) -> Node:
## This is run when hovering over the thumbnail or when creating thumbnail for the first time if it doesn't already exist
# ORIGINAL WORKING NON-THREAD

# NOTE: Called when:
# 1. Creating thumbnail for the first time if it doesn't already exist, not called if thumbnail does exist. FIXME STILL SEEMS TO BE CALLED EVEN IF THUMBNAIL DOES EXISTS CAUSING ISSUES
# 2. Connected button mouse_entered signal for doing 360 rotation in reload_scene_view_button().
# 3. When placing scene. and button for project collection scene is created.

# FIXME Some smaller .glb like FX files do not have thumbnail image properly generated possible no AABB BOX? TODO TODO figure out why
func get_camera_aabb_view(scene_view_button: Button, scene: Node, scene_full_path: String, subviewport_child: SubViewport) -> Node:
	var collection_name: String = scene_full_path.split("/")[-2].to_snake_case()
	if debug: print("scene_full_path: ", scene_full_path)
	#if debug: print("scene: ", scene)
	if scene == null:
		#print("scene was null loading")
		scene = load_scene_instance(scene_full_path)
		# NOTE: Moved to part of import process
		#if scene:
			#print("printed for every scene_view on import?")
			#import_mesh_tags(scene, scene_view_button)



			##if scene_full_path.begins_with("res://") and scene_full_path.get_extension() == "scn":
			#mutex.lock()
			#if scene_full_path.begins_with("res://") and accepted_file_ext.has(scene_full_path.get_extension()):
				#
				## FIXME make run on no-blocking background thread 
				#scene = await load_scene_instance(scene_full_path)
#
  ## FIXME This will throw errors sometimes what looks like because of the is_instance_valid(scene_lookup[scene_full_path]) check  ERROR: res://addons/scene_snap/scripts/scene_viewer.gd:12301 - Invalid access to property or key 'user://global_collections/scenes/Global Collections/glb/SM_Prop_Gem_Socket_04.glb' on a base object of type 'Dictionary[String, Node]'.
## is it being cleared in multi-thread before this is run? 
			#elif not collection_lookup.is_empty() and collection_lookup.has(collection_name) and scene_lookup.keys().has(scene_full_path) and is_instance_valid(scene_lookup[scene_full_path]):
				#
				#scene = collection_lookup[collection_name][scene_full_path].duplicate()
				#
				#if scene != null:
					## FIXME Will cancel intial load wait_count for multi-thread scene import: if not finished 
					#if debug: print("getting scene from collection_lookup[collection_name][scene_full_path]: ", scene)
					#import_mesh_tags(scene, scene_view_button)
				#else:
					#push_error("entry does not exist in collection_lookup")
			#mutex.unlock()


	## NOTE: If cache has scene_full_path then skip NO can't skip need to get scene otherwise wait for WorkerThreadPool to finish and get loaded scene from Dict
#### ORIGINAL WORKING NON-THREAD
		##scene = load_scene_instance(scene_full_path)
		##import_mesh_tags(scene, scene_view_button)
#
		##elif not gltf_load_complete:
##
## FIXME Project scenes get loaded into cache but no thumbnail so gives error
## FIXME WILL not load if in cache but will not need to right? ,because that means that a thumbnail has already been generated and can skip
### TEST THREADED AGAIN
## FIXME Restructor for Memory first loading
		## FIXME May need to set flag for when processing scenes but thumbnails are showing to pass to fallback loading
		##mutex.lock() 
#
#
		### FIXME Holding here stops main thread and I think the finished_processing_collection from being emitted so creates deadlock
		### FIXME why does scene_lookup not have entry??
		### FIXME get collection count and if after all collections imported and still fails check then throw error or warning?
		##mutex.lock()
		##if not scene_lookup.has(scene_full_path): # FIXME Will only work for first collection?
			##if debug: print("WAITING FOR MULTI-THREADING IMPORT TO FINISH HERE")
			##await wait_ready(scene_lookup.has(scene_full_path))
			##
			##
			##
			###if debug: print("WAITING FOR MULTI-THREADING IMPORT TO FINISH HERE")
			###await finished_processing_collection # Wait until collection scanned and then run function again which will do check again and wait for next collection import
			##
			##get_camera_aabb_view(scene_view_button, scene, scene_full_path, subviewport_child)
			##return # Loop back through function but do not continue from here
		##mutex.unlock()
		##if debug: print("CONTINUING TO RUN THIS FUNCTION HERE")
		##if debug: print("scene_lookup: ", scene_lookup)
		##if debug: print("scene_full_path: ", scene_full_path)
#
#
## NOTE Not finding scene_full path because scene_full_path: res://collections/test/SM_Bld_Camp_Tent_03_static_trimesh.scn
		##mutex.lock()
#
## NOTE FIXME THIS IS WHAT IS BRAKING INITIAL IMPORT WITH SKIPPING CHUNK LOADING AND WHEN CLEARING SCENE_LOOKUP
#
		#
		##if debug: print("scene_full_path: ", scene_full_path)
		##if not collection_lookup.is_empty():
			##if debug: print("scene_lookup is not empty")
			##if debug: print("scene_lookup: ", collection_lookup)
			##if debug: print("scene_full_path: ", scene_full_path)
		##if collection_lookup.has(collection_name):
			##if debug: print("scene_lookup has scene_full_path")
		##if scene_loading_complete and not scene_lookup.is_empty() and scene_lookup.has(scene_full_path) and is_instance_valid(scene_lookup[scene_full_path]):
		##if scene_loading_complete and not scene_lookup.is_empty() and scene_lookup.has(scene_full_path) and is_instance_valid(scene_lookup[scene_full_path]):
		#if not collection_lookup.is_empty() and collection_lookup.has(collection_name) and is_instance_valid(scene_lookup[scene_full_path]):
			##mutex.lock()
			##scene = scene_lookup[scene_full_path]
			#scene = collection_lookup[collection_name][scene_full_path]
			##mutex.unlock()
			##mutex.unlock()
			#if scene != null:
				## FIXME Will cancel intial load wait_count for multi-thread scene import: if not finished 
				#if debug: print("getting scene from collection_lookup[collection_name][scene_full_path]: ", scene)
				#import_mesh_tags(scene, scene_view_button)
			#else:
				#push_error("entry does not exist in collection_lookup")
#
		#else: # When placing scene project collection scene is created, scene_full_path will reference this .scn project collection scene
			#if scene_full_path.begins_with("res://") and scene_full_path.get_extension() == "scn":
				## FIXME make run on no-blocking background thread 
				#scene = await load_scene_instance(scene_full_path)
			#else:
				#
				##push_error("Why is this not finding scene_full_path in scene_lookup")
				#push_warning("scene_lookup did not contain the scene, falling back to single threaded import")
				#push_warning("this needs to be re-enabled and fixed")
				#return null
				##scene = await load_scene_instance(scene_full_path)
				##if scene != null:
					##import_mesh_tags(scene, scene_view_button)
				##else:
					##push_error("single threaded import fallback failed")
		##mutex.unlock()
#
#
#
#
#
#
		##if scene_data_cache.scene_data.keys().has(scene_full_path):
			##if debug: print("scene_data_cache has scene_full_path skipping")
		##else: # this has been loaded further up so should work
			###scene = scene_lookup[scene_full_path]
			###import_mesh_tags(scene, scene_view_button)
##
##
			### FIXME load all paths into scene_lookup
			##if not scene_lookup.is_empty() and scene_lookup.has(scene_full_path):
				##scene = scene_lookup[scene_full_path]
				##import_mesh_tags(scene, scene_view_button)
##
##
			##else:
				##scene = await load_scene_instance(scene_full_path)
				##import_mesh_tags(scene, scene_view_button)



	if scene:
		#print("printed for every scene_view on import?")
		#import_mesh_tags(scene, scene_view_button)
		#if debug: print("running now")
		var new_camera_3d: Node3D = SCENE_VIEW_CAMERA_3D.instantiate()
		
		# FIXME Broken for project scenes
		# NOTE: This is for if the viewport is removed after every button exit
		#if not subviewport_child.get_child(0) == scene:
		subviewport_child.add_child(scene)
		scene.owner = self


		# NOTE add to all_scenes_instances to enable rotation on them
		all_scenes_instances.append(scene)

		# NOTE Camera3D was instatiated here as a result of an error when instanced as part of the scene_view /
		# scene and calling get_child to find the mesh_node when running _focus_camera_on_node_3d
		scene.add_sibling(new_camera_3d, true)
		new_camera_3d.name = "NewCamera3D"
		new_camera_3d.owner = self


		var aabb: AABB = AABB()  # Initialize an empty AABB
		var mesh_node: MeshInstance3D
		#var mesh_node_count: int
		
		
		# Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
		# When there is no thumbnails this is run twice so can be optimized for when scenes are first dragged and dropped or generated from scenes placed in folder
		scenes_with_multiple_meshes.clear()
		scenes_with_mesh_tag_data.clear()
		var mesh_node_instances: Array[Node] = scene.find_children("*", "MeshInstance3D", true, false)
		if debug: print("The ", scene.name, " has: ", mesh_node_instances.size(), " MeshInstance3D Nodes")
		#if debug: print("mesh_node_instances.size: ", mesh_node_instances.size())

	# NOTE Replaced with code below TODO Check if issues
		if mesh_node_instances.size() == 1:
			if debug: print("scene children: ", scene.get_children())
			if scene.get_child(0) is MeshInstance3D:
				mesh_node = scene.get_child(0)
				aabb = mesh_node.get_aabb()

			elif scene.get_child(0).get_child(0) is MeshInstance3D:
				mesh_node = scene.get_child(0).get_child(0)
				aabb = mesh_node.get_aabb()

	# NOTE: Did not work?
		#if mesh_node_instances.size() == 1:
			#mesh_node = scene.find_child('*MeshInstance3D*', true, false)
			#aabb = mesh_node.get_aabb()

			set_camera_aabb_offset(aabb, new_camera_3d, mesh_node_instances)

		else:
			# Store scenes with multiple meshes with their meshes in a dictionary
			# NOTE This is only run when no thumbnails exist for 1st imported scene. Storage per session is done in create_scene_buttons() func.
			scenes_with_multiple_meshes[scene.name] = mesh_node_instances
			
			
			
			# Trigger MultipleMeshGLB button visible

			var mesh_node_names: Dictionary = {}  # Use a Dictionary for unique names
			#var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)

			for mesh_node_child: Node in mesh_node_instances:
				## TEST On exporting new single .glb files for each of the mesh instances in the scene
				#export_gltf(mesh_node_child, scene_full_path.path_join(mesh_node_child.name + ".glb"))

				# Scan the filesystem to update
				var editor_filesystem = EditorInterface.get_resource_filesystem()
				editor_filesystem.scan()
				
				#if debug: print("mesh_node: ", mesh_node)
				
				## FIXME Will not work with .glb
				#if scene_full_path.ends_with(".tscn"):
					#mesh_node_child.get_surface_override_material(0).cull_mode = 2 #CULL_DISABLED
				
				if not mesh_node_names.has(mesh_node_child.name):
					mesh_node_names[mesh_node_child.name] = true  # Mark the name as seen

					## Merge the AABB of this mesh node
					aabb = aabb.merge(mesh_node_child.get_aabb())  # Update AABB with the new one

			set_camera_aabb_offset(aabb, new_camera_3d, mesh_node_instances)

	return scene





# Change to :
# Just get from hit mesh directly was using name to store all in one, but broke when more then one instanced and 
# system renamed duplicates in tree
#var scene_tags: Dictionary[int, Array] = {}
#var scene_tags: Dictionary[String, Array] = {}

# TODO cleanup empty scene_data_cache entries
# FIXME Not sure where to do this, but if Global and Shared tags empty then remove "extras" and re export .glb to overwrite original
# NOTE this has to happen before create_scene_buttons to fill scene_data_cache
func import_mesh_tags(gltf_state: GLTFState, scene_full_path: String) -> void:
	var tags: Array[String]
	var shared_tags: Array[String]
	var global_tags: Array[String]

	# NOTE: Since this happens after scene_view_buttons are created tags imported here will not be visible until after restart
	# TODO: Either run same code during initial import multi_threaded_gltf_image_hashing() or check dif of current update_scene_data_tags_cache 
	# and recreate dif scene_view_buttons?
	for node in gltf_state.get_json()["nodes"]:
		if node.has("extras") and node["extras"].has("global_tags") and not node["extras"]["global_tags"].is_empty():
			var encrypted_json_global_tags = node["extras"]["global_tags"]

			for encrypted_tag in encrypted_json_global_tags.keys():
				var encrypted_tag_string = encrypted_json_global_tags[encrypted_tag]  # This is a string like "[6, 197, 85, ...]"
				var tag_array = JSON.parse_string(encrypted_tag_string)
				if typeof(tag_array) == TYPE_ARRAY:
					var pba := PackedByteArray()
					for byte in tag_array:
						pba.append(byte)
					var decrypted_json_global_tag: PackedStringArray = global_tags_aes_decryption(pba)
					print("Decrypted tag:", decrypted_json_global_tag)
					tags.append_array(decrypted_json_global_tag)
					global_tags.append_array(decrypted_json_global_tag)
					# NEED TO UPDATE new_scene_view.shared_tags TOO!
					#new_scene_view.shared_tags.append(decrypted_json_global_tag)



		if node.has("extras") and node["extras"].has("shared_tags") and not node["extras"]["shared_tags"].is_empty():
			var json_shared_tags = node["extras"]["shared_tags"]
			print("shared tags: ", json_shared_tags)
			if not sharing_disabled:
				tags.append_array(json_shared_tags)
				shared_tags.append_array(json_shared_tags)

		# Remove meta "extras" from .glb file if it has no tags. NOTE: Will need to edit later if wanting to store additional things
		if node.has("extras") and tags.is_empty():
			removed_unused_meta_extras(scene_full_path)

		# Need to store in cache to get back later when scene_view_buttons created. Otherwise could skip cache and store directly
		# Load imported scene tags data into scene_data_cache 
		if not tags.is_empty():# or not shared_tags.is_empty() or not global_tags.is_empty():
			update_scene_data_tags_cache(scene_full_path, tags, shared_tags, global_tags)
		else:
			mutex.lock()
			main_collection_tab_script.update_scene_data_cache_paths("", "", false, scene_full_path)
			mutex.unlock()


func removed_unused_meta_extras(scene_full_path: String) -> void:
	print("removing meta extras from file located at: ", scene_full_path)
	var scene_instance: Node = scene_lookup[scene_full_path]
	var first_mesh_node: MeshInstance3D = get_scenes_first_mesh_node(scene_instance)
	# Check if the mesh node has the "extras" metadata entry and remove it
	if first_mesh_node.has_meta("extras"):
		first_mesh_node.remove_meta("extras")
	export_gltf(scene_instance, scene_full_path)


# FIXME CONSIDER STORING IN LARGER DICTIONARY WHEN UNPACKED FOR TAG MATCHING OR AUTOCOMPLETE OF SAME TAG
# AS YOU TYPE SIMILIR TAGS BEGIN TO SHOW AND CAN BE DRAGGED IN? OR SELECTED?
# FIXME TAGS FOR OTHER ASSET TYPES?? ## Stored meta in editor settings json file scene mesh id: tags? 
# Grab all tags and store them in array within each of the scene_view buttons for quick access
# This is run on session start when first creating the buttons 
func import_mesh_tags2(scene_instance: Node, new_scene_view: Button) -> void:
	scenes_with_multiple_meshes.clear()
	#scenes_with_mesh_tag_data.clear()

##FIXME RUN .find_children("*", "MeshInstance3D" EVERY TIME OR CREATE DICTIONARY FOR EACH OBJECT TO MAKE INITIAL IMPORT A BIT FASTER?
## RATHER THEN RUNNING .find_children("*", "MeshInstance3D" TWICE?

	# Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
	var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)

	if mesh_node_instances.size() > 1:
		new_scene_view.multiple_mesh_glb.show()
		# Store for lookup for button popup
		scenes_with_multiple_meshes[scene_instance.name] = mesh_node_instances

		# Create new .glb scene file for each??? and then run through create_scene_buttons?
		# Or create similar logic to create_scene_buttons specific to this use case?



	for mesh_node: MeshInstance3D in mesh_node_instances:
		# Create new .glb files for each of the child MeshInstance3D

		if mesh_node.has_meta("extras"):
			# Combined Global and Shared tags NOTE: NOT USED YET
			var tags: Dictionary[String, Array] = {}
			var metadata: Dictionary = mesh_node.get_meta("extras")
			
			# Shared tags
			if metadata.has("shared_tags") and metadata["shared_tags"] != []:
				#new_scene_view.tags_button_active.show()

				for tag: String in metadata["shared_tags"]:
					if debug: print("new_scene_view: ", new_scene_view)
					new_scene_view.shared_tags.append(tag)
					# Group into one array for single array parsing in scene_snap_plugin.gd process_snap_flow_manager_connections()
					new_scene_view.tags.append(tag)

			# Global tags
			if metadata.has("global_tags") and metadata["global_tags"] != {}:
				if metadata["global_tags"].keys().has(get_key(false)):# and metadata["global_tags"][get_key(false)] != []:
					#new_scene_view.tags_button_active.show()
					# Within the global tags dictionary find keys that match the reference key get_key(false)
					if metadata["global_tags"].keys().has(get_key(false)):
						
						var reference_key: String = get_key(false)
						var string_array: String = str(metadata["global_tags"][get_key(false)])
						if debug: print("string_array: ", string_array)
						var encrypted_data: PackedByteArray = string_to_packed_byte_array(string_array)
						#var encrypted_data: PackedByteArray = string_array.to_utf8_buffer()
						# Ensure the data is padded to a multiple of 16 bytes
						#encrypted_data = pad_to_16(encrypted_data)
						if debug: print("encrypted_data: ", encrypted_data)
						
						if debug: print("decrypted_data: ", global_tags_aes_decryption(encrypted_data))
						var decrypted_data_array: PackedStringArray = global_tags_aes_decryption(encrypted_data)
						
						# NOTE: Converts PackedStringArray into Array[String]
						# Reference: https://www.reddit.com/r/godot/comments/189a8qg/how_to_transform_packedstringarray_to_arraystring/ (aezart)
						var decrypted_global_tags_array: Array[String] = []
						decrypted_global_tags_array.assign(decrypted_data_array)

						## NOTE doesn't work because this is just a temp instance
						## When placing in scene set then?
						## Initialize plain text metadata array for decrypted_global_tags
						#metadata["decrypted_global_tags"] = decrypted_global_tags_array
						## Take decrypted tags from decrypted_global_tags_array and store them back into decrypted_global_tags as plain text
						## for this session only NOTE: We will remove the plain text version when saving to disk.
						##mesh_node.metadata.set_meta("decrypted_global_tags", decrypted_global_tags_array)
						##mesh_node.set_meta(metadata["decrypted_global_tags"], decrypted_global_tags_array)
						##await get_tree().process_frame
						#mesh_node.set_meta("extras", metadata)
						## To verify, retrieve the data:
						#var retrieved_metadata = mesh_node.get_meta("extras")
						#if debug: print("retrieved_metadata: ", retrieved_metadata)  # Should print the dictionary with your array

						
						for tag: String in decrypted_global_tags_array:
							new_scene_view.global_tags.append(tag)
							# Group into one array for single array parsing in scene_snap_plugin.gd process_snap_flow_manager_connections()
							new_scene_view.tags.append(tag)






			if debug: print("mesh_node.name: ", mesh_node.name)
			#scene_tags[mesh_node.name] = new_scene_view.tags
			# Track the mesh_node by adding data to it and getting back later
			#mesh_node.set_meta("session_tags", new_scene_view.tags)
			#scene_tags[mesh_node.get_instance_id()] = new_scene_view.tags
			#if debug: print("scene_tags: ", scene_tags)

			#if debug: print("get_scene_name(scene_view_button.scene_full_path): ", get_scene_name(scene_view_button.scene_full_path))
			#scene_tags[get_scene_name(scene_view_button.scene_full_path)] = scene_view_button.tags

			load_tags_to_tag_button_tool_tip(new_scene_view)

	print("new_scene_view.tags: ", new_scene_view.tags)

	# Load imported scene tags data into scene_data_cache 
	update_scene_data_tags_cache(new_scene_view.scene_full_path, new_scene_view.tags, new_scene_view.shared_tags, new_scene_view.global_tags)



## Apply the tags to the tag button tooltip text
func load_tags_to_tag_button_tool_tip(new_scene_view: Button) -> void:
	# Join all tags into a single string separated by commas
	print("Filling tooltip with shared tags: ", new_scene_view.shared_tags)
	var share_tags_string: String = ", ".join(new_scene_view.shared_tags)
	var global_tags_string: String = ", ".join(new_scene_view.global_tags)
	var tool_tip_text: String = ""

	if new_scene_view.shared_tags and not sharing_disabled:
		new_scene_view.update_tags_icon()
		#new_scene_view.tags_button_active.show()
		tool_tip_text = "Shared Tags: " + share_tags_string
	if new_scene_view.global_tags:
		new_scene_view.update_tags_icon()
		#new_scene_view.tags_button_active.show()
		tool_tip_text = "Global Tags: " + global_tags_string
	if new_scene_view.shared_tags and new_scene_view.global_tags and not sharing_disabled:
		tool_tip_text = "Shared Tags: " + share_tags_string + "\n" + "Global Tags: " + global_tags_string
	elif new_scene_view.shared_tags and new_scene_view.global_tags and sharing_disabled:
		tool_tip_text = "Global Tags: " + global_tags_string

	new_scene_view.tags_button.set_tooltip_text(tool_tip_text)


## Pad the data to a multiple of 16 bytes if necessary
#func pad_to_16(byte_array: PackedByteArray) -> PackedByteArray:
	#var padding_length = (16 - byte_array.size() % 16) % 16
	#var padding = PackedByteArray()
	#padding.resize(padding_length)  # Pad with 0x00
	#return byte_array + padding





## FIXME CONSIDER STORING IN LARGER DICTIONARY WHEN UNPACKED FOR TAG MATCHING OR AUTOCOMPLETE OF SAME TAG
## AS YOU TYPE SIMILIR TAGS BEGIN TO SHOW AND CAN BE DRAGGED IN? OR SELECTED?
## FIXME TAGS FOR OTHER ASSET TYPES?? ## Stored meta in editor settings json file scene mesh id: tags? 
## Grab all tags and store them in array within each of the scene_view buttons for quick access
## This is run on session start when first creating the buttons 
#func import_mesh_tags(scene_instance: Node, new_scene_view: Button) -> void:
	#scenes_with_multiple_meshes.clear()
	#scenes_with_mesh_tag_data.clear()
	## Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
	#var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)
#
	#if mesh_node_instances.size() > 1:
		#new_scene_view.multiple_mesh_glb.show()
		## Store for lookup for button popup
		#scenes_with_multiple_meshes[scene_instance.name] = mesh_node_instances
#
		## Create new .glb scene file for each??? and then run through create_scene_buttons?
		## Or create similar logic to create_scene_buttons specific to this use case?
#
#
#
	#for mesh_node: MeshInstance3D in mesh_node_instances:
		## Create new .glb files for each of the child MeshInstance3D
#
		#if mesh_node.has_meta("extras") and mesh_node.get_meta("extras").has("shared_tags"):
#
#
			#var metadata: Dictionary = mesh_node.get_meta("extras")
			##if metadata["global_tags"].keys().has(get_key(false)):
				##if debug: print("yes")
			## Check for data in either shared_tags array or global_tags dictionary
			## FIXME check for metadata["global_tags"][get_key(false)] not done before so error
			#if metadata["shared_tags"] != [] or metadata["global_tags"][get_key(false)] != []:
			##if metadata["shared_tags"] != [] or metadata["global_tags"] != {}:
			##if "shared_tags" in metadata or "global_tags" in metadata:
				#new_scene_view.tags_button_active.show()
#
#
#
				## Combined Global and Shared tags
				#var tags: Dictionary[String, Array] = {}
				## Shared tags
				##var shared_tags: Array[String] = []
				#if mesh_node.get_meta("extras").has("shared_tags"):
					#for tag: String in mesh_node.get_meta("extras")["shared_tags"]:
						##shared_tags.append(tag)
#
						##if debug: print("scene_view scene_instance: ", scene_instance)
						#if debug: print("new_scene_view: ", new_scene_view)
						#new_scene_view.shared_tags.append(tag)
#
#
				#if mesh_node.get_meta("extras").has("global_tags"):
					## Within the global tags dictionary find keys that match the reference key get_key(false)
					#if mesh_node.get_meta("extras")["global_tags"].keys().has(get_key(false)):
						#
						#var reference_key: String = get_key(false)
						#var string_array: String = mesh_node.get_meta("extras")["global_tags"][get_key(false)]
						#var encrypted_data: PackedByteArray = string_to_packed_byte_array(string_array)
						##var encrypted_data: PackedByteArray = string_array.to_utf8_buffer()
						#if debug: print("encrypted_data: ", encrypted_data)
						#
						#if debug: print("decrypted_data: ", global_tags_aes_decryption(encrypted_data))
						#var decrypted_data_array: PackedStringArray = global_tags_aes_decryption(encrypted_data)
						#
						## NOTE: Converts PackedStringArray into Array[String]
						## Reference: https://www.reddit.com/r/godot/comments/189a8qg/how_to_transform_packedstringarray_to_arraystring/ (aezart)
						#var decrypted_global_tags_array: Array[String] = []
						#decrypted_global_tags_array.assign(decrypted_data_array)
#
						#for tag: String in decrypted_global_tags_array:
							#new_scene_view.global_tags.append(tag)
#
#
#
#
#
#
				## Join all tags into a single string separated by commas
				#var tags_string: String = ", ".join(new_scene_view.shared_tags)
				#new_scene_view.tags_button_active.set_tooltip_text(tags_string)
#
			##else:
				##new_scene_view.tags_button_active.hide()
				#
#
		#if debug: print("scene_instance.name: ", scene_instance.name)
		#if scenes_with_global_tags.has(scene_instance.name):
			#new_scene_view.tags_button_active.show()
			## Join all tags into a single string separated by commas
			#var tags_string: String = ", ".join(scenes_with_global_tags[scene_instance.name])
			#new_scene_view.tags_button_active.set_tooltip_text(tags_string)
#
#
#
	### FIXME Maybe need scene_full_path
	##last_session_scene_tag_count[new_scene_view.name] = new_scene_view.shared_tags.size() + new_scene_view.global_tags.size()
	##if debug: print("last_session_scene_tag_count: ", last_session_scene_tag_count)


# Function to convert the string representation of an array to PackedByteArray
func string_to_packed_byte_array(string_array: String):
	var result = PackedByteArray()
	var array_str = string_array.replace("[", "").replace("]", "")
	var array_values = array_str.split(", ")
	for value in array_values:
		result.append(value.to_int())
	return result




func generate_scene_sub_meshinstance3d() -> void:
	if debug: print(scenes_with_multiple_meshes)





var encryption_key_setting: String = "scene_snap_plugin/global_tags_key:_warning!_removing_or_changing_key_will_make_your_global_tags_unaccessible/encryption_key"

## Get the encryption key or the 5 digit key is used to uniquely 
## identify and retrieve a user's encrypted local tags within the shared metadata.
func get_key(get_encryption_key: bool) -> String:
	if settings.has_setting(encryption_key_setting):
		var encryption_key: String = settings.get_setting(encryption_key_setting)
		if get_encryption_key:
			return encryption_key
		else:
			# Get the first 5 digits of the encryption key to use as the reference key
			return encryption_key.substr(0, encryption_key.length() - 11)
	else:
		push_error("No encryption key found in Project Settings!")
		return ""


#func pad_tag_text(tag_text: String) -> PackedByteArray:
	## Convert string to bytes
	#var data_bytes = tag_text.to_utf8_buffer()
	#
	## Calculate padding needed to reach the next 16-byte boundary
	#var padding_needed = 16 - (data_bytes.size() % 16)
	#if padding_needed == 16:
		#padding_needed = 0  # Data is already a multiple of 16
	#
	## Apply padding (PKCS#7 padding scheme)
	#for _i in range(padding_needed):
		#data_bytes.append(padding_needed)
	#
	#return data_bytes



var aes = AESContext.new()

#func global_tags_aes_encryption(tag_text: String) -> void:
func global_tags_aes_encryption(tags: Array[String]) -> PackedByteArray:
#func encrypt_tag1(tag_text: String) -> void:
	#var tags = ["house", "tree", "car", "book", "lamp"]  # Example tags
	var combined_tags = PackedByteArray()
	
	# Step 1 & 2: Combine tags into a single string and convert to bytes
	for tag in tags:
		combined_tags.append_array((tag + "|").to_utf8_buffer())  # Using "|" as a delimiter
	
	if debug: print("combined_tags: ", combined_tags.get_string_from_utf8())
	
	# Remove the last delimiter
	combined_tags.remove_at(combined_tags.size() - 1)
	
	# Step 3: Pad the byte array
	var padding_needed = 16 - (combined_tags.size() % 16)
	if padding_needed != 16:
		for _i in range(padding_needed):
			combined_tags.append(padding_needed)
	
	# Step 4: Encrypt the padded byte array
	#var aes = AESContext.new()
	
	#var key = "My16ByteKey12345"  # Example 16-byte key
	aes.start(AESContext.MODE_ECB_ENCRYPT, get_key(true).to_utf8_buffer())
	var encrypted_data = aes.update(combined_tags)
	aes.finish()
	
	# Step 5: The 'encrypted_data' variable now contains the encrypted tags
	# You can store or transmit this data as needed
	if debug: print("Encrypted data size: ", encrypted_data.size())
	if debug: print("Encrypted data: ", encrypted_data)
	return encrypted_data


func global_tags_aes_decryption(encrypted_data: PackedByteArray) -> PackedStringArray:
	# Example of decryption (if needed)
	aes.start(AESContext.MODE_ECB_DECRYPT, get_key(true).to_utf8_buffer())
	var decrypted_data = aes.update(encrypted_data)
	aes.finish()
	
	# Remove padding
	var padding_length = decrypted_data[decrypted_data.size() - 1]
	decrypted_data.resize(decrypted_data.size() - padding_length)
	
	# Convert back to string and split by delimiter
	var decrypted_string = decrypted_data.get_string_from_utf8()
	var decrypted_tags = decrypted_string.split("|")
	#print("Decrypted tags: ", decrypted_tags)
	return decrypted_tags


#var last_session_scene_tag_count: Dictionary[String, int] = {} # {scene_full_path: tag_count}
#var current_session_scene_tag_count: Dictionary[String, int] = {} # {scene_full_path: tag_count}
var scene_view_buttons_with_tags_added_or_removed: Array[Button] = [] # [button_scene_full_path, button_scene_full_path]


# NOTE Did this way because thought that encryption would be heavy load, but maybe do when tag added removed in tag_panel?
# Will adding tags to scene file while scene open cause issues? we remove and recreate it.
# NOTE: Check does not need to be very reliable so scene_name used over scene_full_path
func append_buttons_with_edited_tags(scene_view: Button) -> void:
	#if debug: print("scene_full_path: ", scene_full_path)
	#if debug: print("tag_count: ", tag_count)
	#current_session_scene_tag_count[scene_full_path] = tag_count
	#if debug: print("scene_view_button_tag_count: ", current_session_scene_tag_count)
	if not scene_view_buttons_with_tags_added_or_removed.has(scene_view):
		scene_view_buttons_with_tags_added_or_removed.append(scene_view)
	if debug: print("scene_view_buttons_with_tags_added_or_removed: ", scene_view_buttons_with_tags_added_or_removed)
	#return false
	#pass
	#scene_data_cache.scene_data[tagged_scene_full_path][tags].clear()


# FIXME does not account for multiple mesh and stored data in them 
func get_scenes_first_mesh_node(scene_instance: Node) -> MeshInstance3D:
	var first_mesh_node: MeshInstance3D
	# Reference: https://forum.godotengine.org/t/getting-all-meshinstance3ds-from-scene/44127 (mrcdk)
	var mesh_node_instances: Array[Node] = scene_instance.find_children("*", "MeshInstance3D", true, false)
	if mesh_node_instances.size() > 0:
		first_mesh_node = mesh_node_instances[0]

	return first_mesh_node




# MODIFIED VERSION
# NOTE: Called from scene_snap_plugin.gd _get_window_layout() function on session open close and save
# TODO: with many tags may get slow so restrict to on session close only????
# Modify for removing tags as well if deleted by user
# FIXME Do check of file size or tag count to only save if tags updated so maybe central store of each mesh and number of tags
# because currently deleting and writing files to disk every save 
# FIXME Slow because goes through all scene_view_buttons not just the ones that are being edited?
#func store_tags_in_scene_mesh(scene_view: Button, shared_tags: Array[String]) -> void:

# FIXME Being stored as Node:<Node3D#6267682816568> not <Node3D#6267682816568>
# TODO Edit or create new function to remove extras that are empty no tags or data
func store_tags_in_scene_mesh() -> void:
	#for button: Button in scene_view_buttons_with_tags_added_or_removed:
		#scene_view_buttons_with_tags_added_or_removed.erase(button)

## TEST Single multi thread
	#var task_id1 = WorkerThreadPool.add_task(load_gltf_scene_instances_multi_threaded)
	#while not WorkerThreadPool.is_task_completed(task_id1): 
		#await get_tree().create_timer(5).timeout
#
	#for index: int in scene_view_buttons_with_tags_added_or_removed.size():
		#var scene_view: Button = scene_view_buttons_with_tags_added_or_removed.pop_back()
		#var scene_instance = scene_lookup[scene_view.scene_full_path]

# TEST MULTITHREADING

	#var task_id1 = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, scene_view_buttons_with_tags_added_or_removed.size())
	#while not WorkerThreadPool.is_group_task_completed(task_id1): 
		#await get_tree().create_timer(5).timeout
#
	#for index: int in scene_view_buttons_with_tags_added_or_removed.size():
		#var scene_view: Button = scene_view_buttons_with_tags_added_or_removed.pop_back()
		#var scene_instance = scene_lookup[scene_view.scene_full_path]

	# FIXME push to group threading for faster processing
	# NOTE: With single background thread
	for index: int in scene_view_buttons_with_tags_added_or_removed.size():
		var scene_view: Button = scene_view_buttons_with_tags_added_or_removed.pop_back()
		# FIXME Update to using scene_lookup
		#var collection_name: String  = scene_view.scene_full_path.split("/")[-2].to_snake_case()
		mutex.lock()
		#var scene_instance: Node = scene_lookup[scene_view.scene_full_path]
		var scene_instance: Node = load_scene_instance(scene_view.scene_full_path)
		if debug: print("tag scene_instance, ", scene_instance)
		#var scene_instance: Node = collection_lookup[collection_name][scene_view.scene_full_path].duplicate()
		mutex.unlock()
		#var scene_instance: Node = await load_scene_instance(scene_view.scene_full_path)

## TEST
		#for child in scene_instance.get_children():
			#child.owner = scene_instance
		#export_gltf(scene_instance, scene_view.scene_full_path)


		var first_mesh_node: MeshInstance3D = get_scenes_first_mesh_node(scene_instance)

		# Check if the mesh node has the "extras" metadata entry
		var metadata: Dictionary = {}
		if first_mesh_node.has_meta("extras"):
			metadata = first_mesh_node.get_meta("extras")  # Get existing metadata

		## Store shared tags directly
		#metadata["shared_tags"] = shared_tags


		# STORE SHARED TAGS
		metadata["shared_tags"] = []
		# Save shared_tags into the mesh Metadata Extras shared_tags Array
		if scene_view.shared_tags != []:
			if debug: print("scene_button.shared_tags: ", scene_view.shared_tags)
			for tag in scene_view.shared_tags:
				if not metadata["shared_tags"].has(tag):  # Avoid duplicates
					metadata["shared_tags"].append(tag)
					if debug: print("added shared tag: " + tag + "to: ", scene_view.name)

		if not metadata.has("global_tags"):
			metadata["global_tags"] = {}
		if metadata["global_tags"].keys().has(get_key(false)):
			metadata["global_tags"].erase(get_key(false)) #[get_key(false)] = [] # Clear existing global_tags only for specific user

		# Encrypt entire global_tags array with aes and save global_tags into the mesh Metadata Extras global_tags Dictionary
		if scene_view.global_tags != []:
			if debug: print("GLOBAL TAGS: ", scene_view.global_tags)
			if debug: print("global_tags_aes_encryption(scene_button.global_tags): ", global_tags_aes_encryption(scene_view.global_tags))
			metadata["global_tags"][get_key(false)] = global_tags_aes_encryption(scene_view.global_tags)
			if debug: print("metadata[global_tags]: ", metadata["global_tags"])

		# Set the updated metadata back to the mesh node
		first_mesh_node.set_meta("extras", metadata)
		# FIXME Will only save for .gltf .glb files not .fbx or others
		# Save .glb back to disk 
		if scene_view.scene_full_path.get_extension() == "glb" or scene_view.scene_full_path.get_extension() == "gltf":

			# FIXME Will only work for .glb files so need to modify to work will other file types
			# Delete the original file
			if user_dir.file_exists(scene_view.scene_full_path):
				user_dir.remove(scene_view.scene_full_path)

				## File will not save correctly unless all children are owned by the scene_instance
				#for child in scene_instance.get_children():
					#child.owner = scene_instance

				# Export the scene_instance in memory to the same location as original file overwrite it with the one with tag data.
				export_gltf(scene_instance, scene_view.scene_full_path)
				#export_gltf_with_tags(scene_instance, scene_view.scene_full_path)

		if debug: print("Updated Metadata: ", metadata)

		## Remove scene so that it is not held in memory
		#scene_instance.queue_free()


		# Maybe just run parse_mesh_node function here which also runs load_tags_to_tag_button_tool_tip(scene_view)
		# and will load the decrypted tags back in?
		# Update the tool_tip to show to new tags
		load_tags_to_tag_button_tool_tip(scene_view)
		update_scene_data_tags_cache(scene_view.scene_full_path, scene_view.tags, scene_view.shared_tags, scene_view.global_tags)

		#var scene_data_dict: Dictionary[String, Array] = {
			#"tags": scene_view.tags,
			#"shared_tags": scene_view.shared_tags,
			#"global_tags": scene_view.global_tags
		#}
#
		#scene_data_cache.scene_data[scene_view.scene_full_path] = scene_data_dict
#
		#if ResourceSaver.save(scene_data_cache, "res://addons/scene_snap/resources/scene_data_cache.tres") == OK:
			#if debug: print("Successfully updated tags for: ", scene_view.scene_full_path, " in scene_data_cache")
		#else:
			#if debug: push_error("Failed to update tags for: ", scene_view.scene_full_path, " in scene_data_cache")



# NOTE: Dictionay strings reduced size because will be entered for every scene faster lookup lower memory
func update_scene_data_tags_cache(scene_full_path: String, tags: Array[String], shared_tags: Array[String], global_tags: Array[String]) -> void:
	var scene_data_dict: Dictionary[String, Array] = {
		"t": tags,
		"s": shared_tags,
		"g": global_tags
	}

	scene_data_cache.scene_data[scene_full_path] = scene_data_dict
	if debug: print("Data to save: ", scene_data_cache.scene_data)

	if ResourceSaver.save(scene_data_cache, "res://addons/scene_snap/resources/scene_data_cache.tres") == OK:
		if debug: print("Successfully updated tags for: ", scene_full_path, " in scene_data_cache")
	else:
		if debug: push_error("Failed to update tags for: ", scene_full_path, " in scene_data_cache")








#ORIGINAL WORKS BUT LOOPS THROUGH ALL SCENES AND IS SLOW
## NOTE: Called from scene_snap_plugin.gd _get_window_layout() function on session open close and save
## TODO: with many tags may get slow so restrict to on session close only????
## Modify for removing tags as well if deleted by user
## FIXME Do check of file size or tag count to only save if tags updated so maybe central store of each mesh and number of tags
## because currently deleting and writing files to disk every save 
## FIXME Slow because goes through all scene_view_buttons not just the ones that are being edited?
#func store_tags_in_scene_mesh() -> void:
	##var scene_buttons: Array[Button] = scene_viewer_panel_instance.scene_view_buttons
	#if debug: print("SIZE: ", scene_view_buttons.size())
	#for scene_button: Button in scene_view_buttons:
		#var button_scene_full_path: String = scene_button.scene_full_path
		#if scene_view_buttons_with_tags_added_or_removed.has(button_scene_full_path):
			## Remove so that will not continue to update same scene
			#scene_view_buttons_with_tags_added_or_removed.erase(button_scene_full_path)
#
			## Temp load scene_instance to add metadata to first_mesh_node
#
## ORIGINAL WORKING NON-THREAD
			#var scene_instance: Node = load_scene_instance(button_scene_full_path)
#
#
#
			#var first_mesh_node: MeshInstance3D = get_scenes_first_mesh_node(scene_instance)
#
#
			## Check if the mesh node has the "extras" metadata entry
			#var metadata: Dictionary = {}
			#if first_mesh_node.has_meta("extras"):
				#metadata = first_mesh_node.get_meta("extras")  # Get existing metadata
#
			## STORE SHARED TAGS
			### Initialize "extras" if it's not already there
			##if not metadata.has("shared_tags"):
				##metadata["shared_tags"] = []
			#metadata["shared_tags"] = []
			## Save shared_tags into the mesh Metadata Extras shared_tags Array
			#if scene_button.shared_tags != []:
				#if debug: print("scene_button.shared_tags: ", scene_button.shared_tags)
				#for tag in scene_button.shared_tags:
					#if not metadata["shared_tags"].has(tag):  # Avoid duplicates
						#metadata["shared_tags"].append(tag)
						#if debug: print("added shared tag: " + tag + "to: ", scene_button.name)
#
			## STORE GLOBAL TAGS
			## Initialize "extras" if it's not already there
			## TODO Find way to remove plain text tags in decrypted_global_tags maybe if string remove??
			## TO prevent decrepted tags from leaking out
			## Remove plain text decrypted_global_tags before saving to disk
			##metadata["decrypted_global_tags"] = []
			#
			#if not metadata.has("global_tags"):
				#metadata["global_tags"] = {}
			#if metadata["global_tags"].keys().has(get_key(false)):
				#metadata["global_tags"].erase(get_key(false)) #[get_key(false)] = [] # Clear existing global_tags only for specific user
#
			## Encrypt entire global_tags array with aes and save global_tags into the mesh Metadata Extras global_tags Dictionary
			#if scene_button.global_tags != []:
				#if debug: print("GLOBAL TAGS: ", scene_button.global_tags)
				#if debug: print("global_tags_aes_encryption(scene_button.global_tags): ", global_tags_aes_encryption(scene_button.global_tags))
				#metadata["global_tags"][get_key(false)] = global_tags_aes_encryption(scene_button.global_tags)
				#if debug: print("metadata[global_tags]: ", metadata["global_tags"])
#
#
#
#
#
			## Set the updated metadata back to the mesh node
			#first_mesh_node.set_meta("extras", metadata)
			## FIXME Will only save for .gltf .glb files not .fbx or others
			## Save .glb back to disk
			#if scene_button.scene_full_path.get_extension() == "glb" or scene_button.scene_full_path.get_extension() == "gltf":
#
				## FIXME Will only work for .glb files so need to modify to work will other file types
				## Delete the original file
				#if user_dir.file_exists(scene_button.scene_full_path):
					#user_dir.remove(scene_button.scene_full_path)
					## Export the scene_instance in memory to the same location as original file overwrite it with the one with tag data.
					#export_gltf(scene_instance, scene_button.scene_full_path)
#
			#if debug: print("Updated Metadata: ", metadata)
#
			### Remove scene so that it is not held in memory
			##scene_instance.queue_free()
#
#
			## Maybe just run parse_mesh_node function here which also runs load_tags_to_tag_button_tool_tip(scene_button)
			## and will load the decrypted tags back in?
			## Update the tool_tip to show to new tags
			#load_tags_to_tag_button_tool_tip(scene_button)







func set_camera_aabb_offset(aabb: AABB, new_camera_3d: Node3D, mesh_node_instances: Array[Node]) -> void:
	#var aabb = mesh_node.get_aabb()
	var offset = aabb.get_center()
	new_camera_3d.position = offset
	# NOTE add to all_scene_cameras to enable rotation on them
	all_scene_cameras.append(new_camera_3d)
	
	var viewport_camera: Camera3D = new_camera_3d.get_child(0).get_child(0)
	# FIXME ALTERNATE BETWEEN THE DIFFERENT METHODS TO GET THE BEST RESULTS FOR EITHER MERGED AABB OR SINGLE AABB
	_focus_camera_on_node_3d(aabb, viewport_camera, mesh_node_instances, false)
	#_focus_camera_on_node_3d(mesh_node, viewport_camera, mesh_node_instances, false)
	
	## FIXME Will not work with .glb
	#if scene_full_path.ends_with(".tscn"):
		#mesh_node.get_surface_override_material(0).cull_mode = 2 #CULL_DISABLED
	#if debug: print("mesh_node: ", mesh_node)
	#await get_tree().create_timer(5).timeout
	#mesh_node.get_active_material(0).cull_mode = 2 #CULL_DISABLED
	#if debug: print("mesh_node.get_surface_override_material(0): ", mesh_node.get_surface_override_material(0))
	#mesh_node.get_surface_override_material(0).cull_mode = 2 #CULL_DISABLED



var scenes_full_paths_to_reload: Dictionary = {}
var create_new_buttons: bool = true
#var sub_collection_to_reload: Dictionary = {}
#var scenes_dir_path_to_reload: Dictionary = {}

#var thread: Thread
var threads_finished = 0
var threads = []
#var mutex = Mutex.new()

## Reference: https://godotforums.org/d/34254-how-to-wait-for-multiple-threads/3 (xyz)
## Pass in flags to match call_deferred handling of data
## This function runs in a separate thread.
#func load_scene_data(scene_full_path: String, new_scene_view: Button, handle_data_flag: String, sub_viewport: SubViewport) -> void:
	##await get_tree().process_frame
	#mutex.lock()
	#threads_finished += 1
	#if debug: print("Thread ", threads_finished, " done")
	## Load file data into memory (thread-safe operation)
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		## Load the .glb file into memory as PackedByteArray
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#if threads_finished == threads.size():
			#handle_loaded_data(file_bytes, scene_full_path, new_scene_view, handle_data_flag, sub_viewport)
			#call_deferred("done")
#
		#mutex.unlock()


#func load_scene_data_group(scene_index: int) -> Node:
	#var scene_full_path = all_project_files[scene_index]
	#var file_bytes = load_scene_data(scene_full_path)
	#return get_scene_instance_from_loaded_data(file_bytes, scene_full_path)
	##var scene_instance = get_scene_instance_from_loaded_data(file_bytes, scene_full_path)
	### Process the loaded scene instance, e.g., add it to the scene tree
	##add_child(scene_instance)
#
#func load_scene_data(scene_full_path: String) -> PackedByteArray:
	#var file_bytes = PackedByteArray()
	#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
	#return file_bytes


# thread
# while scene_size > 0:
	# scene_full_path.pop_back()
# In separate thread load file_bytes into Dictionary {scene_full_path: file_bytes}
# put file_bytes in array and pop_back? how to assure order? maybe work out, in the same order they are loaded by scene_full_path should should matchup?


# Getting back later
	#for index: int in file_bytes_array.size():
		#var file_bytes: PackedByteArray = file_bytes_array.pop_back()


# When collection open load all PackedByteArray() into memory on separate thread. on main thread create scene_data_cache and thumbnails 
# as pop_back and free them from memory

# WORKING
#var file_bytes = PackedByteArray()



## SHOULD WORK ORIGINAL
#func load_scene_data(scenes_dir_path: String) -> Dictionary[String, Array]: #Array[PackedByteArray]:
	## Load file data into memory (thread-safe operation)
	#var file_bytes_array: Array[PackedByteArray] = []
	#var scenes_dir_path_dict: Dictionary[String, Array] = {}
	#
	#for file_name: String in DirAccess.get_files_at(scenes_dir_path):
		#var scene_full_path = scenes_dir_path.path_join(file_name)
	#
		##var file_bytes = PackedByteArray()
		#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#file_bytes_array.append(scene_file.get_buffer(scene_file.get_length()))
			##file_bytes = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
	#scenes_dir_path_dict[scenes_dir_path] = file_bytes_array
	#return scenes_dir_path_dict



### SHOULD WORK 2
#func load_scene_data(scenes_dir_path: String) -> Array[PackedByteArray]:
	## Load file data into memory (thread-safe operation)
	#var file_bytes_array: Array[PackedByteArray] = []
	##var scenes_dir_path_dict: Dictionary[String, Array] = {}
	#
	#for file_name: String in DirAccess.get_files_at(scenes_dir_path):
		#var scene_full_path = scenes_dir_path.path_join(file_name)
	#
		##var file_bytes = PackedByteArray()
		#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#file_bytes_array.append(scene_file.get_buffer(scene_file.get_length()))
			##file_bytes = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
	##scenes_dir_path_dict[scenes_dir_path] = file_bytes_array
	#return file_bytes_array



var gltf_file_paths: Array[String] = []
var thumbnail_cache_path_lookup: Dictionary[String, String] = {}
var scene_loading_complete: bool = false

# FIXME Add support for obj
## Get all files and subdirectories recursively within user:// to do threading
func collect_gltf_files(dir: String) -> void:
	# Collect files in the current directory
	var files: PackedStringArray = res_dir.get_files_at(dir)
	for file in files:
		if file.get_extension() == "glb" or file.get_extension() == "gltf":
			gltf_file_paths.append(dir.path_join(file))

	# Collect subdirectories and recurse into them
	var dirs: PackedStringArray = res_dir.get_directories_at(dir)
	for subdir in dirs:
		var subdir_path = dir.path_join(subdir)
		#gltf_files.append(subdir_path)  # Add subdirectory to the list
		collect_gltf_files(subdir_path)  # Recurse into the subdirectory


#var tres_file_paths: Array[String] = []
var materials_3d_array: Array[BaseMaterial3D] = []


# FIXME TODO ADJUST FOR LOW VRAM SETTING BY LOADING ON DEMAND NOT PRELOADING ALL??
# FIXME Maybe can be combined with function above (dir: String, extension: String)?? How to do both glb and gltf | list array?
## Get all files and subdirectories recursively within res:// for material overrides
func collect_standard_material_3d(dir: String) -> void:
	# Collect files in the current directory
	var files: PackedStringArray = res_dir.get_files_at(dir)
	for file in files:
		if file.get_extension() == "tres":
			var loaded_file = load(dir.path_join(file))
			if loaded_file is BaseMaterial3D:
				materials_3d_array.append(loaded_file)

	# Collect subdirectories and recurse into them
	var dirs: PackedStringArray = res_dir.get_directories_at(dir)
	for subdir in dirs:
		var subdir_path = dir.path_join(subdir)
		#gltf_files.append(subdir_path)  # Add subdirectory to the list
		collect_standard_material_3d(subdir_path)  # Recurse into the subdirectory










# for scene_full_path: String in gltf_files:


	#var task_id = WorkerThreadPool.add_group_task(load_scene_data.bind(gltf_files.pop_back()), gltf_files.size())
	#WorkerThreadPool.wait_for_group_task_completion(task_id)




var file_bytes_array: Array[PackedByteArray] = []
var file_bytes_lookup: Dictionary[String, PackedByteArray] = {}

### SHOULD WORK 4
func load_scene_data(scene_full_path: String, gltf_file: int) -> void:
	# Load file data into memory (thread-safe operation)
	
	#var scenes_dir_path_dict: Dictionary[String, Array] = {}
	
	#for file_name: String in DirAccess.get_files_at(scenes_dir_path):
		#var scene_full_path = scenes_dir_path.path_join(file_name)
	
	#var file_bytes = PackedByteArray()
	var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
	if scene_file:
		#mutex.lock()
		file_bytes_array.append(scene_file.get_buffer(scene_file.get_length()))
		#mutex.unlock()
		#file_bytes = scene_file.get_buffer(scene_file.get_length())
		scene_file.close()
	#scenes_dir_path_dict[scenes_dir_path] = file_bytes_array
	#return file_bytes_array
	# Yield the thread to prevent it from blocking the main thread
	#await get_tree().process_frame



#var file_bytes_array: Array[PackedByteArray] = []
## SHOULD WORK 3
#func load_scene_data(scenes_dir_path: String) -> void:
	## Load file data into memory (thread-safe operation)
	#file_bytes_array = []
	##var scenes_dir_path_dict: Dictionary[String, Array] = {}
	#var scene_count: int = DirAccess.get_files_at(scenes_dir_path).size()
#
	#for file_name: String in DirAccess.get_files_at(scenes_dir_path):
		#while scene_count > 0:
			#scene_count -= 1
#
			#var scene_full_path = scenes_dir_path.path_join(file_name)
		#
			##var file_bytes = PackedByteArray()
			#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
			#if scene_file:
				#file_bytes_array.append(scene_file.get_buffer(scene_file.get_length()))
				##file_bytes = scene_file.get_buffer(scene_file.get_length())
				#scene_file.close()
		##scenes_dir_path_dict[scenes_dir_path] = file_bytes_array
		##return file_bytes_array
		#
			## Yield the thread to prevent it from blocking the main thread
			#await get_tree().process_frame







#func load_scene_data(scene_full_path: String) -> Array[PackedByteArray]:
	## Load file data into memory (thread-safe operation)
	#file_bytes = PackedByteArray()
	#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()




#func load_scene_data(scene_full_path: String,) -> PackedByteArray:
	## Load file data into memory (thread-safe operation)
	#var file_bytes = PackedByteArray()
	#var scene_file: FileAccess = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
	#return file_bytes










## WORKING
## This function runs in the main thread.
#func get_scene_instance_from_loaded_data(file_bytes: PackedByteArray, scene_full_path: String,) -> Node:
#
	## Will load and create thumbnail for mesh
	#var gltf := GLTFDocument.new()
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
	#var gltf_state := GLTFState.new()
	## Get the path in the res:// project filesystem where we will store the textures.
	## NOTE: For .glb in user:// a "textures" folder is not required.   
	#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
	## Pass in the path of imported textures
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
	##scene_instance = gltf.generate_scene(gltf_state)
#
	#return gltf.generate_scene(gltf_state)











var load_count: int = 0

# FIXME Reduce number of loads
# Balance Memory and wait time
# NOTE: hold collection in memory? no to much memory used for large collection
# NOTE: load on seperate thread, but load time seems same
# Loaded when: 
# 1. Hovering over button (can hold im memory for temp time so that when saving tags it is fast) (Add delay to load 3d)
# 2. Saving tags (when creating tags lazy load selected scenes so that when saving fast)
# 3. Creating thumbnails (combine with import tags at initial load so not loaded twice)
# 4. Importing Tags -> before import_mesh_tags() in create_scene_buttons()


## WORKING
## FIXME Check if loaded_threaded can be used here
## NOTE: This defaults to scene_full_path.begins_with("res://") because this is run after the scene is imported into the res dir 
#func load_scene_instance(scene_full_path: String) -> Node:
	#load_count += 1
	#if debug: print("load_count: ", load_count)
##func load_scene_instance(scene_full_path: String) -> void:
	#var scene_instance: Node
	#if scene_full_path.get_extension() == "glb":# or scene_full_path.get_extension() == "gltf":
		#if scene_full_path.begins_with("res://"):
			#var scene_loaded: PackedScene = load(scene_full_path)
			#scene_instance = scene_loaded.instantiate()
		#else:
			#
			###var scene_loaded: PackedScene = load(scene_full_path)
			###scene_instance = scene_loaded.instantiate()
			###pass
			### Will load and create thumbnail for mesh
			##var gltf := GLTFDocument.new()
			##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
			##
			### Open the .glb / gltf file
			##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
			##if scene_file:
				### Load the .glb file into memory as PackedByteArray
				##var file_bytes = scene_file.get_buffer(scene_file.get_length())
				##scene_file.close()
				##
				##var gltf_state := GLTFState.new()
				### Get the path in the res:// project filesystem where we will store the textures.
				### NOTE: For .glb in user:// a "textures" folder is not required.   
				##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
				### Pass in the path of imported textures
				##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
### FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
				###gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
				### TEST Unpack .glb to user:// textures path and then import
				###gltf.append_from_buffer(file_bytes, scene_full_path.path_join("textures"), gltf_state, 8)
				###gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
				### NOTE with textures already compressed and added with .import files to textures folder in user://
				###gltf.append_from_buffer(file_bytes, scene_full_path.path_join("textures"), gltf_state, 8)
##
##
				##var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
				##for mesh in meshes:
					##if debug: print("mesh: ", mesh)
##
				##scene_instance = gltf.generate_scene(gltf_state)
#
#
			## FIXME
			##scene_instance = load_gltf_scene_instance(scene_full_path)
			##pass
			#push_warning("no code was executed here!")
			##### Single background thread working
			##thread.start(load_gltf_scene_instance.bind(scene_full_path))
			##var wait_count: int = 0
			##while thread.is_alive():
				##await get_tree().process_frame
				##wait_count += 1
				##if wait_count > 10000: # Adjust wait count to appropriate time to load a large scene on basic cpu from hdd
					##return
##
			##scene_instance = thread.wait_to_finish()
#
#
### DISABLED TEMP
### For GLB
				##var glb_save_path = "res://test_out" + ".glb"
				##var err = gltf.write_to_filesystem(gltf_state, glb_save_path)
				##if not err == OK:
					##if debug: print('Error writting to filesystem %s' % err)
#
#
### For .tscn .scn
				##var packed_scene = PackedScene.new()
				##if packed_scene.pack(scene_instance) != OK:
					##if debug: print("result: ", packed_scene.pack(scene_instance))
##
				##else:
					###var save_path:  String = "res://".path_join(scene_instance.name.path_join(".glb"))
					###var save_path:  String = "res://" + scene_instance.name + ".glb"
					###var save_path:  String = "res://" + scene_instance.name
					##var scn_save_path = "res://test_out" + ".scn"
					##if ResourceSaver.save(packed_scene, scn_save_path) != OK:
						##if debug: print("Could not save :( Path: " + scn_save_path + ", Error Code: " + str(ResourceSaver.save(packed_scene, scn_save_path)))
					##else:
						##if debug: print("pack and save successful")
#
#
### For GLB
##func export_gltf(root: Node, save_path: String) -> void:
	##var doc = GLTFDocument.new()
	##var state = GLTFState.new()
	##var err = doc.append_from_scene(root, state)
	##if not err == OK:
		##if debug: print('Error appending from scene %s' % err)
	##else:
		##err = doc.write_to_filesystem(state, save_path)
		##if not err == OK:
			##if debug: print('Error writting to filesystem %s' % err)
#
#
				##if debug: print("scene_instance: ", scene_instance)
				##if debug: print("scene_instance childrensss: ", scene_instance.get_children())
##
##
###region TEST To see if loaded scene_preview can be reused rather then copying in .glb from user:// when placing scene
				###scene_instance.set_owner(null)
				##var save_path:  String = "res://".path_join(scene_instance.name.path_join(".glb")) 
				##var packed_scene = PackedScene.new()
				##
##
				##scene_instance.get_child(0).free()
				#### Ensure all children are unique and have no existing parent outside this scene
				###for child in scene_instance.get_children():
					###if child.get_parent() != scene_instance:
						#### Remove the child from its current parent
						###child.get_parent().remove_child(child)
						#### Add it back to scene_instance to ensure correct parentage
						###scene_instance.add_child(child)
##
##
				##var pack_result = packed_scene.pack(scene_instance)
				##if pack_result == OK:
					### Save the PackedScene resource
					##var error = ResourceSaver.save(packed_scene, save_path)
					##if error != OK:
						##if debug: print("Failed to save scene: Error code ", error)
					##else:
						##if debug: print("Scene saved successfully to ", save_path)
				##else:
					##if debug: print("Failed to pack scene: Error code ", pack_result)
					##
### FIXME Getting Failed to save scene: Error code 15 ERR_FILE_UNRECOGNIZED = 15
#
#
#
#
#
					##if debug: print("THIS CODE WAS EXECUTED")
#
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	##thread.wait_to_finish()
	#return scene_instance





# TODO Pass all loading of scenes through here
func load_scene_instance(scene_full_path: String) -> Node:
	#if scene_full_path:
		#current_scene_path = scene_full_path
	if scene_full_path.begins_with("res://") and accepted_file_ext.has(scene_full_path.get_extension()): # Load from project filesystem
			return load(scene_full_path).instantiate()

	else:
		var loaded_scene: Node = null
		var collection_name: String = scene_full_path.split("/")[-2].to_snake_case()

		# TODO CHECK IF HAS ISSUES WITH GLTF TODO ADD SUPPORT FOR .OBJ
		var file_ext: String = scene_full_path.get_extension()
		if file_ext == "glb":# or file_ext == "gltf":# or file_ext == "obj":
			mutex.lock()
			# Pull from collection_lookup # Pull from Memory
			if not collection_lookup.is_empty() and collection_lookup.has(collection_name) and scene_lookup.keys().has(scene_full_path) and is_instance_valid(scene_lookup[scene_full_path]):
				loaded_scene = collection_lookup[collection_name][scene_full_path].duplicate()
				if debug: print("loaded_scene: ", loaded_scene)

			else: # Fallback loading directly from disk single thread when not in lookup 
				var imported_base_path: String = project_scenes_path.path_join(collection_name)
				var imported_textures_path: String = imported_base_path.path_join("textures".path_join("/"))
				loaded_scene = load_gltf_scene_instance(scene_full_path, imported_textures_path)
			mutex.unlock()
		else:
			push_error("Attempting to load an unsupported file type. Only 'glb' is currently supported with 'gltf' and 'obj' planned.")


		return loaded_scene











#endregion

### ORIGINAL SINGLE THREAD WORKING
### FIXME Check if loaded_threaded can be used here
##func load_gltf_scene_instance_from_user(scene_full_path: String) -> Node:
#func load_gltf_scene_instance(scene_full_path: String) -> Node:
	##var scene_full_path: String = gltf_file_paths[index]
	#var scene_instance: Node
	##if scene_full_path.get_extension() == "glb" or scene_full_path.get_extension() == "gltf":
	#var gltf := GLTFDocument.new()
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		## Load the .glb file into memory as PackedByteArray
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state := GLTFState.new()
		#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		#scene_instance = gltf.generate_scene(gltf_state)
#
	#return scene_instance

var call_scan: bool = false
#var gltfdocuments: Dictionary[GLTFDocument, Array] = {}
var gltf_state_lookup: Dictionary[String, GLTFState] = {}
#var gltf_state_array: Array[GLTFState] = []
#var gltf_state_lookup: Array[Dictionary] = []
#var gltf_state_lookup: Dictionary[int, Dictionary] = {}
#var scene_full_path_lookup: Dictionary[int, String] = {}

### WORKING
### FIXME Check if loaded_threaded can be used here
##func load_gltf_scene_instance_from_user(scene_full_path: String) -> Node:
##func load_gltf_scene_instance(index: int, gltf: GLTFDocument) -> void:
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
	##if debug: print("index: ", index)
	##if debug: print("gltf_file_paths.size() -1: ", gltf_file_paths.size() -2)
	##if index == gltf_file_paths.size() -2:
		##call_scan = true
	##var scene_full_path: String = gltf_file_paths[index]
	##var scene_instance: Node
	##if scene_full_path.get_extension() == "glb" or scene_full_path.get_extension() == "gltf":
#
## TEST Disabled temp
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		## Load the .glb file into memory as PackedByteArray
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state := GLTFState.new()
		#
		### FIXME Make more global reused in next function and has to be recaculated again so pass into this function and the next not here
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8) # Very heavy load that can only be single threaded because writes to filesystem
#
		##await get_tree().create_timer(0.1).timeout
		###await get_tree().process_frame
##
		##var gltf_state_scene_path_array: Array = [] 
		##gltf_state_scene_path_array.append(gltf_state)
		##gltf_state_scene_path_array.append(scene_full_path)
		###if debug: print("gltf_state_scene_path_array: ", gltf_state_scene_path_array)
		##
		##gltfdocuments[gltf] = gltf_state_scene_path_array
#
#
		###gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
		##var editor_filesystem = EditorInterface.get_resource_filesystem()
		### NOTE Will only get the first scene textures
		##var wait_count: int = 0
		##while editor_filesystem.get_scanning_progress() != 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if debug: print("wait_count: ", wait_count)
			##if wait_count > 1000:
				##break
		##await get_tree().create_timer(5).timeout
		##EditorInterface.get_resource_filesystem().scan()
		##if call_scan:
			##call_scan = false
			## Scan the filesystem to update
		##var editor_filesystem = EditorInterface.get_resource_filesystem()
		##editor_filesystem.scan()
		#
		### Iterate through all images in the GLTFState
		##for image in gltf_state.get_images():
			##editor_filesystem.update_file(image.get_path())
		##editor_filesystem.scan()
	#
		##if debug: print("editor_filesystem scanning: ", editor_filesystem.is_scanning())
		##await get_tree().create_timer(5).timeout
		##if debug: print("editor_filesystem scanning: ", editor_filesystem.is_scanning())
		#
		#
		##var image_texture_paths := PackedStringArray()
#
#
		### Iterate through all images in the GLTFState
		##for image in gltf_state.get_images():
			##editor_filesystem.update_file(image.get_path())
		##editor_filesystem.scan()
		#
		#
			###if debug: print("image path: ", image.get_path())
			##if not image_texture_paths.has(image.get_path()):
				##image_texture_paths.append(image.get_path())
		##if debug: print("image_texture_paths: ", image_texture_paths)
#
#
#
#
		##for image in gltf_state.images:
			##if image.name != "":
				##var tex_path := imported_textures_path.path_join(image.name + ".png")
				##texture_paths.append(tex_path)
				##editor_filesystem.update_file(tex_path)
		##
		###if not editor_filesystem.is_scanning():
		##editor_filesystem.reimport_files(texture_paths)
		##editor_filesystem.update_file(imported_textures_path)
#
#
		##var wait_count: int = 0
		####while editor_filesystem.is_scanning():
		##while editor_filesystem.get_scanning_progress() != 1:
			##await get_tree().process_frame
			##wait_count += 1
			##if debug: print("wait_count: ", wait_count)
			##if wait_count > 1000:
				##break
#
#
		##await get_tree().process_frame
		##await get_tree().create_timer(1).timeout
		##scene_instance = gltf.generate_scene(gltf_state)
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
	##return scene_instance







# ORIGINAL WHEN LOADING AT READY CODE WAS WORKING WHEN ITEMS ALREADY COPIED TO COLLECTIONS
# NOTE Without already imported textures this will throw errors and sometimes crash asking for Use call_deferred() or call_thread_group() instead.

#var scene_lookup: Dictionary[String, Node] = {}
#var mutex: Mutex = Mutex.new()

#func multi_threaded_load_gltf_scene_instances(index: int) -> void:
	#var scene_full_path: String = gltf_file_paths[index]
#
	#var gltf: GLTFDocument = GLTFDocument.new()
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#
		#var gltf_state: GLTFState = GLTFState.new()
		#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()



################################# KEEP REFERENCE
## NOTE Without already imported textures this will throw errors and sometimes crash asking for Use call_deferred() or call_thread_group() instead.
## But when the texture is already in res:// this works very fast for loading the scenes CHECK how different from the other method 
## NOTE: Set of 100 .glb with textures already imported will load with no error and not reimport textures with this code going from RAM 14.2 VRAM 1.7 to RAM 14.6 to VRAM 1.9 in 5 secs no visible thumbnails until fully loaded
## NOTE: For above loads buttons as intended and all button 360 generation is instant
## NOTE Set of 500 RAM 14.7 VRAM 1.9 LOAD TIME 9.8 sec NO errors or reimport with textures already imported
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument) -> void:
	#var scene_full_path: String = gltf_file_paths[index]
#
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#
		#var gltf_state: GLTFState = GLTFState.new()
		#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
################################# KEEP REFERENCE



################################# KEEP REFERENCE
## NOTE Without already imported textures this will throw errors and sometimes crash asking for Use call_deferred() or call_thread_group() instead.
## But when the texture is already in res:// this works very fast for loading the scenes CHECK how different from the other method 
## NOTE: Set of 100 .glb with textures already imported will load with no error and not reimport textures with this code going from RAM 14.2 VRAM 1.7 to RAM 14.6 to VRAM 1.9 in 5 secs no visible thumbnails until fully loaded
## NOTE: For above loads buttons as intended and all button 360 generation is instant
## NOTE Set of 500 RAM 14.7 VRAM 1.9 LOAD TIME 9.8 sec NO errors or reimport with textures already imported
#
## TODO Check if can get gltf from first scan image hashing and reuse here so not reading file again? at the very least can optimize by storeing file_bytes
## FIXME what about gltf_state reuse and changing flag back to non embded and have dictionary with file_bytes and gltf_state reuse with HANDLE_BINARY_EXTRACT_TEXTURES
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_full_path: String = gltf_file_paths[index]
#
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#
		#var gltf_state: GLTFState = GLTFState.new()
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
		## I think this import from buffer is breaking things so maybe can't reun for all and only new ones?
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#
		### NOTE: Set the images of the GLTFState here to the ones already imported
		### TEST With giving all images to all GLTFStates
		##gltf_state.set_images(collection_gltf_images)
		##gltf_state.set_textures(collection_gltf_textures)
		##gltf_state.set_materials(collection_gltf_materials)
#
#
		## FIXME Will need to get image reference list for each gltf_state to now only apply specific images to specific gltf files? Example first scene had _1.png scene to only _2.png
#
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
################################## KEEP REFERENCE
#
#




### WHY DOESN'T THE dest_md5 WITHIN .godot/imported file for this .png file MATCH?
#var gltf: GLTFDocument = GLTFDocument.new()
#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
#
#
#
#func load_gltf_scene_instance(scene_full_path: String, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state := GLTFState.new()
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
#
#func multi_threaded_load_gltf_scene_instances(index: int, gltf: GLTFDocument, imported_textures_path: String) -> void:
	#var scene_full_path: String = gltf_file_paths[index]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()





# I want the MD5 to match for both of these









var gltf_images: Array[Image] = []
var gltf_image_lookup: Dictionary[String, Array] = {}
var gltf_lookup: Dictionary[String, GLTFDocument] = {}
var gltfs: Array = []

#var image_hash_lookup: Dictionary[String, int] = {} # FIXME use scene_full_path and filter method maybe? so as processed if image has lookup size changes then add scene_full_path
var collection_hased_images: Array[int] = []
var collection_images: Array[String] = []
var collection_materials: Array[String] = []
#var collection_hased_images: Array[PackedByteArray] = []
#var collection_images: Array[PackedByteArray] = []
var process_single_threaded_list: Array[String] = [] # NOTE: This will be a list of scene_full_paths that get added when collection_hased_images.size changes
var collection_gltf_images: Array[Texture2D] = []
var collection_gltf_textures: Array[GLTFTexture] = []
var collection_gltf_materials: Array[Material] = []

#TEST
#var global_thread_results: Array = []
# to process single threaded list 


#var gltf_images: Dictionary = {}
################################ KEEP REFERENCE
# NOTE Without already imported textures this will throw errors and sometimes crash asking for Use call_deferred() or call_thread_group() instead.
# But when the texture is already in res:// this works very fast for loading the scenes CHECK how different from the other method 
# NOTE: Set of 100 .glb with textures already imported will load with no error and not reimport textures with this code going from RAM 14.2 VRAM 1.7 to RAM 14.6 to VRAM 1.9 in 5 secs no visible thumbnails until fully loaded
# NOTE: For above loads buttons as intended and all button 360 generation is instant
# NOTE Set of 500 RAM 14.7 VRAM 1.9 LOAD TIME 9.8 sec NO errors or reimport with textures already imported
# NOTE: Using gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU) will load into VRAM each scenes textures overloading VRAM
# NOTE: append_from_buffer shares textures between all scenes append_from_file creates new duplicate textures for each scene file

#
#func multi_threaded_gltf_image_hashing(index: int, gltf: GLTFDocument) -> void:
##func multi_threaded_gltf_image_hashing(index: int) -> void:
	#var scene_full_path: String = gltf_file_paths[index]
#
	## CAUTION MEMORY USED GOES UP A LOT WHEN CREATING NEW DOCUMENT FOR EACH GLTF
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		##call_deferred_thread_group("defer_me", file_bytes, scene_full_path, gltf)
		##call_deferred("defer_me", file_bytes, scene_full_path, gltf)
#
#
		##var gltf_state := GLTFState.new()
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
##
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		##await get_tree().create_timer(0.1).timeout
		###await get_tree().process_frame
##
		##var gltf_state_scene_path_array: Array = [] 
		##gltf_state_scene_path_array.append(gltf_state)
		##gltf_state_scene_path_array.append(scene_full_path)
		###if debug: print("gltf_state_scene_path_array: ", gltf_state_scene_path_array)
		##
		##mutex.lock()
		##gltfdocuments[gltf] = gltf_state_scene_path_array
		##mutex.unlock()
#
#
			#
		#var gltf_state: GLTFState = GLTFState.new()
		#
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU) # NOTE: For lower VRAM but slower import
		##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_DISCARD_TEXTURES)
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED) # NOTE: For Higer VRAM and faster import
		#
#
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
		## NOTE:-------------
		## Do hash check of imported_textures_path each time 
		## then do hash of images from gltf and if same above hash array has has then skip otherwise add to process list 
		## then process single threaded only those from the list which should be small if many shared textures then process all the rest multi-threaded
		## do in hash checking in batched chunks to avoid memory over fill TODO check of existing images in imported_textures_path can be reduced by only checking new ones and only clearing when 
		## changing collection so will want dictionary with filename: hash if filename in dict keys skip
		## ------------------
#
		## NOTE: Can this be store as HANDLE_BINARY_EMBED_AS_BASISU for each whole collection to use later?
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		##mutex.lock()
		##scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		##mutex.unlock()
#
#
##-------------- THIS SLOWS THINGS DOWN BUT ALSO KEEPS VRAM IN CHECK
## NOTE: ~ 35-40% CPU Utilization ~ 5GB VRAM | multithreading load time: 83219 milliseconds ON 1200 SYNTY SET
## NOTE: BLOCKS MAIN THREAD INTERMITTENTLY | SEEMS TO UNLOAD VRAM AUTOMATICALLY
		##WORKS 
		## POSSIBLE SOLUTIONS FIND WAY TO MATCH MD5 HASH EXACTLY | SINGLE THREADED INITIAL IMPORT :( | FIGURE OUT HOW TO MAP GLTFSTATE 
		## TO IMAGES I IMPORT | FIND WAY TO BLOCK CHANGING EITHER IMPORT OR .PNG FILES WHEN RUNNING append_from_buffer
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#mutex.lock()
			#if not collection_hased_images.has(image_hash):
				#collection_hased_images.append(image_hash)
				##if not collection_gltf_images.has(texture):
					##collection_gltf_images.append(texture)
				#if not process_single_threaded_list.has(scene_full_path):
					#process_single_threaded_list.append(scene_full_path)
				##gltf_state_lookup[scene_full_path] = gltf_state
			#mutex.unlock()
##-------------- THIS SLOWS THINGS DOWN BUT ALSO KEEPS VRAM IN CHECK
#
#
		##for texture: GLTFTexture in gltf_state.get_textures():
			##mutex.lock()
			##if not collection_gltf_textures.has(texture):
				##collection_gltf_textures.append(texture)
			##mutex.unlock()
##
		##for material: Material in gltf_state.get_materials():
			##mutex.lock()
			##if not collection_gltf_materials.has(material):
				##collection_gltf_materials.append(material)
			##mutex.unlock()
#
#
#
#
#
#
		##gltf_state = null
#
		## Store for later use
		##await get_tree().create_timer(0.1).timeout
		##await get_tree().process_frame
#
		### NOTE: LOOP BACK THROUGH MULTI-THREADED AND CREATE SCENES FROM THIS ALREADY PROCESSED CACHED DATA
		### NOTE: BUT ISSUE IS THAT THIS DATA CONTAINS INCOMPRESSED TEXTURES AND THE ONLY WAY TO REFERENCE SINGLE SOURCE IS BY RUNNING
		### append_from_buffer AGAIN? BUT MAYBE NOT A PROBLEM SINCE ONLY LOADING AND UNLOADING THEM FROM VRAM WHEN 360 AND SCENE_PREVIEW? BUT PLACING 
		### WOULD NEED TO REFERENCE SINGLE SOURCE?
		##var gltf_state_scene_path_array: Array = [] 
		##gltf_state_scene_path_array.append(gltf_state)
		##gltf_state_scene_path_array.append(scene_full_path)
		###if debug: print("gltf_state_scene_path_array: ", gltf_state_scene_path_array)
		##
		### CAUTION WILL ONLY WORK IF GLTFDocument.new() IS CREATED EACH THREAD
		##mutex.lock()
		##gltfdocuments[gltf] = gltf_state_scene_path_array
		##mutex.unlock()
#
		##mutex.lock()
		##gltf_state_lookup[scene_full_path] = gltf_state
		##mutex.unlock()
#
#
#
		## NOTE: Seems stable to this point
#



## TEST ATTEMPT TO MAKE FASTER NOTE: About same average load time
		#var local_hashed_images := []
#
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#var image_bytes: PackedByteArray = image.get_data()
			#var image_hash: int = hash(image_bytes)
#
			#local_hashed_images.append(image_hash) # No locking needed here
#
		## Push the local result back to the global result queue
		#mutex.lock()
		#global_thread_results.append(local_hashed_images)
		#mutex.unlock()


			#if debug: print("collection_hased_images: ", collection_hased_images.size())
			#if debug: print("process_single_threaded_list: ", process_single_threaded_list.size())
			#if debug: print("image_hash: ", image_hash)
			
			
			
			
			##var image = texture.get_image()
			##image.convert(Image.FORMAT_RGBA8)
			###texture.get_image().FORMAT_RGBA8
			##var id = image.get_rid()
			##var hash = hash(image)
			##if debug: print("hash: ", hash)
			##if not gltf_images.has(texture):
				##mutex.lock()
				##gltf_images.append(texture)
				##mutex.unlock()


		#var image_paths: PackedStringArray = DirAccess.get_files_at(imported_textures_path)
		#for image_path: String in image_paths:
			#if image_path.get_extension() == "png":
				#var texture := CompressedTexture2D.new()
				#texture = load(imported_textures_path + image_path)
				#var image: Image = texture.get_image()
				#if image:
					#image.decompress()
					##image.convert(Image.FORMAT_RGBA8)
		#
					## Get raw pixel data as bytes (this is content-based)
					#var bytes := image.get_data()
		#
					## Hash the actual byte content
					#var image_hash := hash(bytes)
					#if debug: print("image_hash: ", image_hash)


		## DO hashing of imported_textures_path after initial scene import
		#var image_paths: PackedStringArray = DirAccess.get_files_at(imported_textures_path)
		#for image_path: String in image_paths:
			#var image := Image.new()
			#image = load(image_path)
			#if debug: print(image)
		

		
		#var path: String = user://

		# if first run call deferred if in cache then run normal
		#call_deferred_thread_group("call_here", file_bytes, gltf, gltf_state)
		#mutex.lock()
		#gltf.append_from_buffer(file_bytes, path_to_thumbnail_cache_global, gltf_state, 8)
		#mutex.unlock()
		# NOTE: Hash the images in imported_textures_path load with set_handled hash the images from that and compare hash if hash same 
		# add scene to multithread import pool if not add to single thread import pool?
		# NOTE: but one at a time? import first create textures then do check on all rest? 
		# NOTE: import first then do hash check for all until one fails then import the second single threaded that failed and then run hash until all have mathcing hash then run full original multithread??
		# I think this could work!!
		# NOTE: if imported_textures_path has texture
		#if gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8) != OK:
			#if debug: print("failed but hopefully no errors??")
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state)
		#gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		#gltf.append_from_file(file_bytes, "", gltf_state, 8)
		#gltf.append_from_file(scene_full_path, gltf_state, 0, imported_textures_path) # This freezes up but allows for end process
		#gltf.append_from_file(scene_full_path, gltf_state, 0, "") # This freezes up but allows for end process
		
		

		#mutex.lock()
		#gltfs.append(gltf)
		##gltf_lookup[scene_full_path] = gltf
		#mutex.unlock()



		
		
		
		#for texture: Texture2D in gltf_state.get_images():
			#var image: Image = texture.get_image()
			#mutex.lock()
			#gltf_image_lookup[scene_full_path] = gltf_state.get_images()
			##gltf_images.append(image)
			#mutex.unlock()



		#if debug: print("gltf_images: ", gltf_images)
		# TODO revisit combining textures
		##if debug: print("gltf images: ", gltf_state.get_images())
		#for texture: Texture2D in gltf_state.get_images():
			##var image = texture.get_image()
			##image.convert(Image.FORMAT_RGBA8)
			###texture.get_image().FORMAT_RGBA8
			##var id = image.get_rid()
			##var hash = hash(image)
			##if debug: print("hash: ", hash)
			##if not gltf_images.has(texture):
				##mutex.lock()
				##gltf_images.append(texture)
				##mutex.unlock()
		##if debug: print("gltf_images size: ", gltf_images.size())

#
			#var image := texture.get_image()
			#image.convert(Image.FORMAT_RGBA8)
#
			## Get raw pixel data as bytes (this is content-based)
			#var bytes := image.get_data()
#
			## Hash the actual byte content
			#var image_hash := hash(bytes)
#
			#if not gltf_images.has(image_hash):
				#mutex.lock()
				#gltf_images[image_hash] = texture
				#mutex.unlock()
		#
		#if debug: print("gltf_images: ", gltf_images)
		##mutex.lock()
		#for image_hash: int in gltf_images:
			#gltf_images[image_hash].get_image().save_png(imported_textures_path + "/" + str(image_hash) + ".png")
		##mutex.unlock()
			##image.save_png(imported_textures_path + "/" + gltf_state.filename + ".png")


		

		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()
		#gltf_state = null
		#scene_lookup[scene_full_path].queue_free()
################################ KEEP REFERENCE

#func call_here(file_bytes: PackedByteArray, gltf: GLTFDocument, gltf_state: GLTFState) -> void:
	#gltf.append_from_buffer(file_bytes, path_to_thumbnail_cache_global, gltf_state, 8)



#func call_image_deferred() -> void:
	#for image_hash: int in gltf_images:
		#gltf_images[image_hash].get_image().save_png(imported_textures_path + "/" + "_" + ".png")


#var gltf
#var gltf_state
var scene_lookup: Dictionary[String, Node] = {}
#var material_lookup: Dictionary[Resource, Array] = {}
var material_lookup: Dictionary[String, Array] = {}
var collection_lookup: Dictionary[String, Dictionary] = {}
var scene_lookup_test: Dictionary[String, Node] = {}
var emit_finished: bool = true
var mutex: Mutex = Mutex.new()
var gltf_state_mutex: Mutex = Mutex.new()
#var mutex_parsed_images := Mutex.new()
#var mutex_scene_lookup := Mutex.new()


## NOTE THIS WORKS WITHOUT WARNINGS ERRORS OR IMPORTING .PNG FILES TO COLLECTIONS/TEXTURES FOLDER BUT MEMORY LEAK
## I THINK TEXTURES ARE STORED IN VRAM THIS WAY SO MAY JUST DO THIS ON FIRST LOAD THEN COPY TEXTURES IN AND DO ORIGINAL WAY AFTER TEXTURES EXIST?
## BUG SEEMS TO HAVE MEMORY LEAK WHEN USING gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
#func load_gltf_scene_instances_multi_threaded(index: int, scenes_dir_path: String, collection_file_names: PackedStringArray, gltf: GLTFDocument) -> void:
	#var scene_full_path: String = scenes_dir_path.path_join(collection_file_names[index])
	##if debug: print("scene_full_path: ", scene_full_path)
	##var gltf: GLTFDocument = GLTFDocument.new()
	##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true) # This will crash godot on start sometimes
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = file_bytes
		##mutex.unlock()
		#scene_file.close()
#
		##var gltf_state: GLTFState = GLTFState.new()
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		##
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		###gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
		##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
		###gltf.append_from_file(scene_full_path, gltf_state, 0, imported_textures_path) # This freezes up but allows for end process
##
		###call_deferred("defer_me", file_bytes, scene_full_path, gltf)
##
		###mutex.lock() # Less issues but slow to load
		##gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		###gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
		###mutex.unlock()
		##
		###gltf.append_from_buffer(file_bytes, "", gltf_state, 8) # This freezes up and will not end process easily
		##var scene = gltf.generate_scene(gltf_state)
		##
		##mutex.lock() 
		##scene_lookup[scene_full_path] = scene
		##mutex.unlock()
		###await get_tree().process_frame
		#
#
#
#
		#var gltf_state: GLTFState = GLTFState.new()
		#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
		#mutex.lock()
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()




		
		#call_deferred("defer_me", file_bytes, scene_full_path, gltf)





## FIXME Cleanup after each collection scene_lookup and gltf_file_paths from memory
## currenly will load all into memory at start and will fill up small memory if several collections
## So batch collection processing needed this function run on individual collections rather then all files at once
## or just run when collection opened. and only if not in cache so need to do check before running this function
## 1. Check cache 2. If no cache bulk process for single collection
#func load_gltf_scene_instances_multi_threaded2(index: int, scenes_dir_path: String, collection_file_names: PackedStringArray) -> void:
##func load_gltf_scene_instances_multi_threaded(index: int) -> void:
	##var scene_full_path: String = gltf_file_paths[index]
#
	#var scene_full_path: String = scenes_dir_path.path_join(collection_file_names[index])
	#if debug: print("scene_full_path: ", scene_full_path)
	### TODO Check if non .glb or .gltf file will return and then run next in sequence or comepletely stop loop
	##var path_ext: String = scene_full_path.get_extension()
	##if not path_ext == "glb" or path_ext == "gltf": # or file_name.get_extension() == "obj":
		##return
	##if debug: print("scene_full_path: ", scene_full_path)
#
	#var gltf: GLTFDocument = GLTFDocument.new() # NOTE From docs looks like only one is required not creating new one for each GLTFState.
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
	## Do all this on multi thread and put in dict then pop_back as read out on single main thead to write to filesystem and to scene_lookup[scene_full_path]
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
		##mutex.lock()
		##file_bytes_lookup[scene_full_path] = scene_file.get_buffer(scene_file.get_length())
		###file_bytes_array.append(scene_file.get_buffer(scene_file.get_length()))
		##mutex.unlock()
		#scene_file.close()
#
#
	##var gltf_state: GLTFState = GLTFState.new()
	##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
	##call_deferred("defer_me", imported_textures_path, scene_full_path, gltf, gltf_state)
	###scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
#
#
		#
		#
		#
		### TEST FIXME Remove collections and get call deffered working
		### This section needs to be called call_thread_group
		###call_deferred_thread_group("call_deferred_thread" , gltf, file_bytes, scene_full_path)
		#var gltf_state: GLTFState = GLTFState.new()
		#gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
		#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
		####if debug: print("imported_textures_path: ", imported_textures_path)
		###await get_tree().process_frame
##
		### This expects the textures to be there before this code is run single or multi-threaded
		### How do i extract them from .glb before this point?? this is the code that extracts them and places them in this location
		### Copy all .glb files into textures folder and then remove all none texture .glb files?
		### Myabe not possible to do multithreaded when initially getting textures?
		### Copy image textures to temp outside res:// and on main thread add in?
		###NOTE this has trouble with extracting multi
		##call_deferred_thread_group("call_me", file_bytes, imported_textures_path, scene_full_path, gltf, gltf_state)
		###mutex.lock()
		####gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
		#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
		####mutex.unlock()
		###
		##gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
####
		####call_deferred_thread_group("call_me", scene_full_path, gltf, gltf_state)
		#mutex.lock()
		#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
		#mutex.unlock()



#func defer_me(file_bytes: PackedByteArray, scene_full_path: String, gltf: GLTFDocument)-> void:
	#var gltf_state: GLTFState = GLTFState.new()
	#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)




#func call_me(file_bytes: PackedByteArray, scene_full_path: String) -> void:
##func call_me(file_bytes: PackedByteArray, scene_full_path: String, gltf: GLTFDocument ) -> void:
	#var gltf: GLTFDocument = GLTFDocument.new()
	#var gltf_state: GLTFState = GLTFState.new()
	#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
#
	#
	#
	#mutex.lock()
	##gltf_state.base_path = imported_textures_path
	##gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_BASISU)
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
	## NOTE: using from_file -> FileAccess above not required but also unpacks each scenes textures where from_buffer combines them
	## Also has more errors, but same no errors after textures exist
	##gltf.append_from_file(scene_full_path, gltf_state, 0, imported_textures_path)
#
	##gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
	##gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
	## Scan the filesystem to update
	#
	##extract_textures(imported_textures_path, gltf_state)
	##if debug: print("gltf images: ", gltf_state.get_images())
	#
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	#mutex.unlock()


func extract_textures(imported_textures_path: String, gltf_state: GLTFState) -> void:
	if debug: print("gltf_state.get_images().size(): ", gltf_state.get_images().size())
	#for i in range(gltf_state.get_images().size()):
	for texture: Texture2D in gltf_state.get_images():
		#var texture: Texture2D = gltf_state.get_images()[i]
		var image: Image = texture.get_image()
		image.save_png(imported_textures_path + "/" + gltf_state.filename + ".png")
		
		#image.save_png(imported_textures_path + "/" + str(gltf_state.filename) + ".png" + str(i))
		#image.save_png(imported_textures_path + "/" + gltf_state.filename + "_texture_" + str(i) + ".png")

	
	
	
	#for i in range(gltf_state.get_images().size()):
		#var image = gltf_state.get_images()[i]
		#if image is Image:
			#var path = imported_textures_path % i
			#var err = image.save_png(path)
			#if debug: print("Saved", path, "Error:", err)


#func call_deferred_thread(gltf: GLTFDocument, file_bytes: PackedByteArray, scene_full_path: String) -> void:
	#if debug: print("scene_full_path HERE", scene_full_path)
	##mutex.lock()
	#var gltf_state: GLTFState = GLTFState.new()
	#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
	##if debug: print("imported_textures_path: ", imported_textures_path)
	##await get_tree().process_frame
	#mutex.lock()
	#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
	##gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
#
	#
	#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
	#mutex.unlock()

#func single_threaded_load_gltf_scene_instances() -> void:
	#scene_lookup.clear()
	##var scene_full_path: String = gltf_file_paths[index]
	##for scene_full_path: String in gltf_file_paths:
	#for index: int in scene_view_buttons_with_tags_added_or_removed.size():
		#mutex.lock()
		#var scene_view: Button = scene_view_buttons_with_tags_added_or_removed.pop_back()
		#mutex.unlock()
		#var scene_full_path = scene_view.scene_full_path
		#
	##for scene_view: Button in scene_view_buttons_with_tags_added_or_removed:
		##var scene_full_path = scene_view.scene_full_path
		#
		##var scene_instance = scene_lookup[scene_view.scene_full_path]
	##for scene_full_path: String in gltf_file_paths:
#
		#var gltf: GLTFDocument = GLTFDocument.new()
		#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
		#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
		#if scene_file:
			#var file_bytes: PackedByteArray = scene_file.get_buffer(scene_file.get_length())
			#scene_file.close()
			#
			#var gltf_state: GLTFState = GLTFState.new()
			#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
#
			#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
#
			#mutex.lock()
			#scene_lookup[scene_full_path] = gltf.generate_scene(gltf_state)
			#mutex.unlock()




		#var scene_instance = gltf.generate_scene(gltf_state)
		#call_deferred("_on_scene_loaded", gltf, gltf_state, scene_full_path)

		
		#scene_lookup[scene_full_path] = scene_instance
		#
		#scene_instance = gltf.generate_scene(gltf_state)
		#mutex.unlock()
	#return scene_instance

#func _on_scene_loaded(gltf: GLTFDocument, gltf_state: GLTFState,  scene_full_path: String) -> void:
	#var scene_instance = gltf.generate_scene(gltf_state)
	#scene_lookup[scene_full_path] = scene_instance




func reload_scene_view_buttons(new_scene_view: Button) -> void:
	#var loaded_scene = null
	for scene_full_path in scenes_full_paths_to_reload.keys():
		create_scene_buttons(scene_full_path, scenes_full_paths_to_reload[scene_full_path], new_scene_view, false)
	scenes_full_paths_to_reload.clear()
	
	
	
	
	#for sub_collection in sub_collection_to_reload.keys():
		#if debug: print("sub_collection_to_reload[sub_collection]: ", sub_collection_to_reload[sub_collection])
		#for scenes_dir_path in sub_collection_to_reload[sub_collection].keys():
			#if debug: print("scenes_name: ", sub_collection_to_reload[sub_collection][scenes_dir_path])
			#create_scene_buttons(scenes_name, sub_collection_to_reload[sub_collection][scenes_name], sub_collection)
		##for scenes_name in sub_collection_to_reload[sub_collection][scenes_dir_path_to_reload[0]]:
		##for scenes_name in scenes_dir_path_to_reload.keys():
			##create_scene_buttons(scenes_name, scenes_dir_path_to_reload[scenes_name], sub_collection)


	#if debug: print("scenes_to_reload.keys(): ", scenes_to_reload.keys())
	#for scene in scenes_to_reload.keys():
		#create_scene_buttons(scene, scenes_to_reload[scene][0], scenes_to_reload[scene][1])
	#scenes_to_reload.clear()


# ORIGINAL
	# REFERENCE Mansur Isaev and Contributors Scene Library Plugin
@warning_ignore("unsafe_method_access")
func _calculate_node_aabb(mesh_node: Node) -> AABB:
	var aabb := AABB()

	if mesh_node is Node3D and not mesh_node.is_visible():
		return aabb
	# NOTE: If the mesh_node is not MeshInstance3D, the AABB is not calculated correctly.
	# The camera may have incorrect distances to objects in the scene.
	elif mesh_node is MeshInstance3D:
		aabb = mesh_node.get_global_transform() * mesh_node.get_aabb()

	# Merge all scene meshes into 1 AABB # FIXME improve for large scenes and multimesh
	if mesh_node:
		for i: int in mesh_node.get_child_count():
			aabb = aabb.merge(_calculate_node_aabb(mesh_node.get_child(i)))

	return aabb

#func _focus_camera_on_node_2d(mesh_node: Node) -> void:
	#var rect: Rect2 = _calculate_node_rect(mesh_node)
	#_camera_2d.set_position(rect.get_center())
#
	#var zoom_ratio: float = THUMB_GRID_SIZE / maxf(rect.size.x, rect.size.y)
	#_camera_2d.set_zoom(Vector2(zoom_ratio, zoom_ratio))



#func _focus_camera_on_node_3d(mesh_node: Node, new_camera_3d: Camera3D) -> void:
	#var transform := Transform3D.IDENTITY
	## TODO: Add a feature to configure the rotation of the camera.
	#transform.basis *= Basis(Vector3.UP, deg_to_rad(40.0))
	#transform.basis *= Basis(Vector3.LEFT, deg_to_rad(22.5))
#
	#var aabb: AABB = _calculate_node_aabb(mesh_node)
	#var distance: float = aabb.get_longest_axis_size() / tan(deg_to_rad(new_camera_3d.get_fov()) * 0.5)
	#transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()
#
	#new_camera_3d.set_global_transform(transform.orthonormalized())


#func _focus_camera_on_node_3d(aabb: AABB, new_camera_3d: Camera3D) -> void:
func _focus_camera_on_node_3d(mesh_node_or_aabb, new_camera_3d: Camera3D, mesh_node_instances: Array[Node], single_mesh: bool) -> void:
	var transform := Transform3D.IDENTITY
	# TODO: Add a feature to configure the rotation of the camera.
	transform.basis *= Basis(Vector3.UP, deg_to_rad(40.0))
	transform.basis *= Basis(Vector3.LEFT, deg_to_rad(22.5))

	var aabb: AABB
	var distance: float
	
	if single_mesh:
		aabb = _calculate_node_aabb(mesh_node_or_aabb)
	else:
		aabb = mesh_node_or_aabb
	if mesh_node_instances.size() <= 2:
		distance = aabb.get_longest_axis_size() / tan(deg_to_rad(new_camera_3d.get_fov()) *  0.5)#0.5)
		transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()
	#if mesh_node_instances.size() == 2:
		#distance = aabb.get_longest_axis_size() / tan(deg_to_rad(new_camera_3d.get_fov()) *  0.5)#0.5)
		#transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()
	else:
		distance = aabb.get_longest_axis_size() / tan(deg_to_rad(new_camera_3d.get_fov()) *  0.5)#0.5)
		transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()
		transform.origin.y = .7
		
	#if debug: print("distance: ", distance)
	#transform.origin = transform * (Vector3.BACK * distance) + aabb.get_center()

	new_camera_3d.set_global_transform(transform.orthonormalized())






func create_split_screen_clone() -> void:
	main_tab_clone = main_tab_container.duplicate()
	# NOTE add to all_scenes_instances to enable rotation on them
	for scene_instance in main_tab_clone.find_children("*","StaticBody3D", true, false ):
		all_scenes_instances.append(scene_instance)
	for new_scene_view in main_tab_clone.find_children("*","Button", true, false ):
		scene_view_instances.append(new_scene_view)
	for camera in main_tab_clone.find_children("CameraGimbal","Node3D", true, false ):
		all_scene_cameras.append(camera)

func remove_split_screen_clone() -> void:
	for scene_instance in main_tab_clone.find_children("*","StaticBody3D", true, false ):
		all_scenes_instances.erase(scene_instance)
	for new_scene_view in main_tab_clone.find_children("*","Button", true, false ):
		scene_view_instances.erase(new_scene_view)
	for camera in main_tab_clone.find_children("CameraGimbal","Node3D", true, false ):
		all_scene_cameras.erase(camera)


# NOTE small bug with h_split_container drag bar becoming visible when dragged off screen
func _on_split_panel_toggled(toggled_on: bool) -> void:
	current_offset = h_split_container.get_split_offset()
	
	if toggled_on:
		create_split_screen_clone()
		if not create_duplicate:
			remove_split_screen_clone()
			main_tab_clone.queue_free()

		if h_split_container and main_tab_clone:
			
			h_split_container.add_child(main_tab_clone)
			main_tab_container.show()
			main_tab_clone.show()
			h_split_container.set_split_offset(h_split_container.size.x / 2)


		if current_offset <= min_max_offsets or current_offset >= (h_split_container.size.x - min_max_offsets):
			h_split_container.set_split_offset(h_split_container.size.x / 2)
			
		else:
			h_split_container.set_split_offset(current_offset)
#
	else:
		if current_offset <= min_max_offsets:
			pass
		else:
			remove_split_screen_clone()
			main_tab_clone.queue_free()
			create_duplicate = true


func _on_h_split_container_dragged(offset: int) -> void:
	current_offset = offset
	if offset <= min_max_offsets:
		create_duplicate = false
		main_tab_container.hide()
		# Seems to be the only solution to reset Toggle
		split_panel.toggle_mode = false
		split_panel.toggle_mode = true

	if offset >= (h_split_container.size.x - min_max_offsets):
		split_panel.toggle_mode = false
		split_panel.toggle_mode = true


func _on_v_slider_value_changed(value: float) -> void:
	#get_tree().get_root().set_input_as_handled()
	thumbnail_size_value = value
	for scene_view in scene_view_instances:
		scene_view.thumbnail_size_value = value
		scene_view.set_scene_view_size(thumbnail_size_value)

#region NOTE NOT USED
## NOTE NOT USED
#
## FIXME fix for 2d scenes
#func add_scenes_to_all_scenes_view() -> void:
	#for scene in all_scenes:
		#var scene_instance = scene.instantiate()
		#var scene_path: String = scene_instance.get_scene_file_path()
		#var scene_file: String = scene_path.get_file()
#
		#var scene_name_split: PackedStringArray = scene_file.split("--", false, 0)
##
		### Set scene name to file path name
		##scene_instance.name = scene_name_split[0]
		#
		#
		#for tag: int in scene_name_split.size():
			#if tag == 0:
				#pass
			#else:
				#var tag_name: String = scene_name_split[tag]
				#if tag_name.ends_with(".tscn"):
					#tag_name = tag_name.substr(0, tag_name.length() - 5)
					#if tags.has(tag_name):
						#pass
					#else:
						#tags.append(tag_name)
					##if debug: print(tag_name)
				#else:
					#if tags.has(tag_name):
						#pass
					#else:
						#tags.append(tag_name)
					##if debug: print(tag_name)
					#
	## Create tabs for each tag and add scenes to them
	#create_sub_tag_tabs()
#
#
#func create_sub_tag_tabs():
	#var main_folder_name: String = "All Scenes"
	#var new_main_collection_tab: TabBar = MAIN_COLLECTION_TAB.instantiate()
	#if main_folder_name and main_folder_name is String:
		#
		#main_tab_container.add_child(new_main_collection_tab)
#
		#new_main_collection_tab.name = main_folder_name
		#new_main_collection_tab.owner = self
	#
	#for tag in tags:
		#var new_sub_collection_tab: Control = SUB_COLLECTION_TAB.instantiate()
#
		#if tag and tag is String:
			#new_main_collection_tab.find_child("SubTabContainer").add_child(new_sub_collection_tab)
			##new_main_collection_tab.find_child("SubTabContainer").call_thread_safe("add_child", new_sub_collection_tab)
#
			#new_sub_collection_tab.name = tag
			#new_sub_collection_tab.owner = self
			#
			#
		#for scene in all_scenes:
			#pass





func create_atlas_texture(scenes_dir_path: String) -> void:
	var atlas_size = atlas_texture_data.size()
	if debug: print(atlas_size)
	# TEST generate AtlasTexture
	# Reference: https://forum.godotengine.org/t/programatically-generate-an-atlastexture-given-an-array-of-sprites-texture2d/750
	Image.create_empty(2048, 1024, false, Image.FORMAT_RGBA8)




func apply_thumbnail_textures():
	for key in thumbnail_lookup_dict.keys():
		var new_image = Image.new()
		var texture = ImageTexture.new()
		new_image.create_from_data(106, 106, false, Image.FORMAT_RGBA8, thumbnail_lookup_dict[key])
		texture.create_from_image(new_image)
		key.texture_normal = texture
#endregion


func _on_make_floating_pressed() -> void:
	emit_signal("make_floating_panel")
	#if debug: print("make floating")
	pass # Replace with function body.



#region Drag & Drop Import/Copy Functionality
# NOTE CODE TO CHECK FOR DEPENDENCIES SHOULD BE CHECKED ONCE WHEN IMPORT/COPY OVER TO USER:// DIR 
# AND THEN AGAIN FOR FILES THAT ARE BEING IMPORTED BACK INTO THE PROJECT RES:// DIR FROM THE USER:// DIR.



## FIXME CONVERT BELOW TO COPY OVER FROM RES:// TO USER:// OF TEXTURES
## Clearing of ResourceUID cache (KoBeWi)
## REFERENCE: https://github.com/godotengine/godot/pull/67128#issuecomment-1272640848
#var user_files: Array[String]
#
#func copy_textures_from_user_to_res() -> void:
	#user_files = []
	#
	#add_files_from_user(shared_collections_path)
	#
	#for file in user_files:
		#
		## Get the root directory of where the scene file is in user://
		#var dir = DirAccess.open(file.get_base_dir())
		#for dr in dir.get_directories():
			## Get the full path in the user:// directory to the folder containing the textures
			#var source_path = file.get_base_dir().path_join(dr)
			#for dep in ResourceLoader.get_dependencies(file):
				#
				## From each .tscn scene file get the dependencies base directory of 
				## where the scene file expects to find the textures in the project res://
				#var dep_uid: String = dep.get_slice("::", 0)
				##if debug: print(dep_uid)
				#var dep_path: String = dep.get_slice("::", 2)
				#var dep_base_dir: String = dep_path.get_base_dir()
				#var dest_path = DirAccess.open("res://")
				#
				## Check to see if folder exists otherwise copy contents of textures folder
				## from user:// to the dependencies path found in the .tscn file
				#if dest_path.dir_exists_absolute(dep_base_dir):
					##if debug: print(dep_path)
					#pass
				#else:
					#copy_dir_recursively(source_path + "/", dep_base_dir + "/")
#
#
#
#
#func add_files_from_user(dir: String):
	#for file in DirAccess.get_files_at(dir):
		#if file.get_extension() == "tscn":# or file.get_extension() == "tres":
			#user_files.append(dir.path_join(file))
	#
	#for dr in DirAccess.get_directories_at(dir):
		#user_files.append(dir.path_join(dr))
		#add_files_from_user(dir.path_join(dr))
#
#
#
#
#
## Is there a way to copy folders from "res://" to "user://"? (godot 4) (sexgott)
##REFERENCE: https://www.reddit.com/r/godot/comments/19f0mf2/is_there_a_way_to_copy_folders_from_res_to_user/
#func copy_dir_recursively(source: String, destination: String):
	#DirAccess.make_dir_recursive_absolute(destination)
	#
	#var source_dir = DirAccess.open(source);
	#
	#for filename in source_dir.get_files():
		##OS.alert(source + filename, 'File Not Recognized')
		#source_dir.copy(source + filename, destination + filename)
		#
	#for dir in source_dir.get_directories():
		#self.copy_dir_recursively(source + dir + "/", destination + dir + "/")









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


#func rename_sub_collection_tab(main_tab_name: String, current_tab_name: String, new_tab_name: String) -> void:
	#var collection_folder_path: String
	#var thumbnail_folder_path: String
	#match main_tab_name:
		#"Global Collections":
			#collection_folder_path= scenes_paths[0].path_join("Global Collections")
			#thumbnail_folder_path = path_to_thumbnail_cache_global.path_join("Global Collections")
		#"Shared Collections":
			#collection_folder_path = scenes_paths[1].path_join("Shared Collections")
			#thumbnail_folder_path = path_to_thumbnail_cache_shared.path_join("Shared Collections")
#
	#rename_folder(collection_folder_path, current_tab_name, new_tab_name)
	#rename_folder(thumbnail_folder_path, current_tab_name, new_tab_name)
	##create_main_collection_tabs(false)
	##if debug: print("main_tab_name: ", main_tab_name)
	##if debug: print("current_tab_name: ", current_tab_name)
	##if debug: print("new_tab_name: ", new_tab_name)
#
#
##func dir_contents(user_dir: String, scene_folder_path: String):
	##var path: String = user_dir.path_join(scene_folder_path)
#func rename_folder(folder_path: String, current_tab_name: String, new_tab_name: String):
	#var dir = DirAccess.open(folder_path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#if file_name == current_tab_name:
			#var error = dir.rename(current_tab_name, new_tab_name)
			#if error != OK:
				#printerr("Could not rename folder")
			#else:
				#pass
				##EditorSettings
#
			##create_folders(user_dir, scene_folder_path.path_join("New Collection"))
			##if debug: print("create New Collection Folder")
#
	#else:
		#if debug: print("An error occurred when trying to access the path.")








# Original
## FIXME Will not work with when files are have --TAGS
## TEST drag and drop from outside project folder
#func parse_drop_file(origin_file_path: String, path_to_save_scene: String, new_sub_collection_tab: Control):
#
	## 1. Check if the dropped object is a folder, extract scenes and textures
	#var dir = DirAccess.open(origin_file_path)
#
	#if dir != null:
		#if debug: print("current dir: ", dir.get_current_dir())
		#
		## Use change_dir to move into the directory and then check
		#if dir.change_dir(origin_file_path) == OK:
			#if debug: print("This is a directory")
		#else:
			#if debug: print("This is a file or cannot change to this directory")
	#else:
		#if debug: print("Could not open path")
	##if DirAccess.open(origin_file_path).current_is_dir():
		##if debug: print("this is a directory")
	##if res_dir
	##var dir = DirAccess.open(path)
		###if dir:
			###dir.list_dir_begin()
			###var file_name = dir.get_next()
			###if file_name == "":
				###if debug: print("create New Collection Folder")
			####while file_name != "":
				####if dir.current_is_dir():
#
	##if origin_file_path.
#
	#if debug: print("origin_file_path: ", origin_file_path)
	#if load(origin_file_path) is Texture:
		#if debug: print("This is a texture")
#
		## TEST
	#if debug: print("Do a check here is destination folder has dep if not or included in dropped files if not add popup to warning message")
	#for dep in ResourceLoader.get_dependencies(origin_file_path):
		#
		## From each .tscn scene file get the dependencies base directory of 
		## where the scene file expects to find the textures in the project res://
		#var dep_uid: String = dep.get_slice("::", 0)
		#if debug: print("dep_uid: ", dep_uid)
		#var dep_path: String = dep.get_slice("::", 2)
		#if debug: print("dep_path: ", dep_path)
	##TEST
	#
#
	##if debug: print("path_to_save_scene: ", path_to_save_scene)
	#
	#var loaded_scene: PackedScene
	#
	#if load(origin_file_path) is PackedScene:
		#loaded_scene = load(origin_file_path)
#
	#if origin_file_path.ends_with(".tscn"): # Simply copy it over
		#var scene_name_split: PackedStringArray = full_path_split(origin_file_path, true)
		#var path_to_save_scene_split: PackedStringArray = full_path_split(path_to_save_scene, false)
		#
		#if not user_dir.dir_exists(path_to_save_scene):
			#create_folders(path_to_save_scene_split[0] + "//", path_to_save_scene_split[1].path_join(path_to_save_scene_split[2].path_join(path_to_save_scene_split[3])))
			#
		## NOTE This will strip out --TAGS
		#var scene_full_path: String = path_to_save_scene.path_join(scene_name_split[0] + ".tscn")
		##if scene_full_path.ends_with(".tscn"):
			##pass
		##else:
			##scene_full_path = path_to_save_scene.path_join(scene_name_split[0] + ".tscn")
#
#
		#if debug: print("scene_full_path: ", scene_full_path)
		##if debug: print("get_thumbnail_cache_path: ", get_thumbnail_cache_path(".tscn", scene_full_path))
		#var thumbnail_cache_path: String = get_thumbnail_cache_path(".tscn", scene_full_path)
		#var thumb_path_split: PackedStringArray = full_path_split(thumbnail_cache_path, false)
#
		#if user_dir:
			### Skip reimporting if file exists # TODO add option to skip this step if user wants to overwrite existing scenes
			#
			## Copy .tscn file
			#if user_dir.file_exists(scene_full_path):
				#push_warning("Scene already exists at: ", scene_full_path)
#
			#else:
				#var scene_copy_result = user_dir.copy(origin_file_path, scene_full_path)
				#if scene_copy_result == OK:
					#pass
					##if debug: print("Scene copied successfully.")
				#else:
					#if debug: print("Failed to copy Scene.")
			#
			## Copy thumbnail
			#if user_dir.file_exists(thumbnail_cache_path):
				#push_warning("File already exists at: ", thumbnail_cache_path)
				#pass
			#else:
				#var project_name: String = ProjectSettings.get_setting("application/config/name")
				##scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - 5) # The length of .tscn = 5
				#var name_png: String = scene_name_split[0] + ".png"
				#var thumbnail_path: String = path_to_thumbnail_cache_project.path_join(project_name.path_join(name_png))
				#
				##if debug: print("thumbnail_path: ", thumbnail_path)
				##if debug: print("thumbnail_cache_path: ", thumbnail_cache_path)
				##if debug: print("THIS HERE: ", thumb_path_split)
				#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
				#var thumbnail_copy_result = user_dir.copy(thumbnail_path, thumbnail_cache_path)
				#if thumbnail_copy_result == OK:
					#pass
					##if debug: print("Thumbnail copied successfully.")
				#else:
					#if debug: print("Failed to copy Thumbnail.")
#
			#await get_tree().process_frame
			##await get_tree().create_timer(3).timeout
			#create_scene_buttons(loaded_scene, scene_full_path, new_sub_collection_tab)
#
	#else: # Run the file through the import process
		#
		##var loaded_scene: PackedScene = load(origin_file_path)
		#var scene: Node3D = loaded_scene.instantiate()
#
		#if debug: print("ADD POPUP TO ADDED LOCATION OF TEXTURE HERE!")
		#var new_standard_material: StandardMaterial3D = StandardMaterial3D.new()
		#new_standard_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, new_texture)
#
		#var mesh_node: MeshInstance3D
		#mesh_node = find_mesh_instance_3d_child(scene)
		#
		#if debug: print("mesh_node: ", mesh_node)
	#
		#if mesh_node == null:
			#printerr("The imported scene does have a MeshInstance3D child or grandchild")
	#
		#var tscn_static_body = StaticBody3D.new()
	#
		#var tscn_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
	#
		## Rename StaticBody3D to MeshInstance3D Name
		#tscn_static_body.name = mesh_node.name# + "--Tags"
	#
		#tscn_mesh_instance_3d = mesh_node.duplicate()
#
		#tscn_static_body.add_child(tscn_mesh_instance_3d)
		#tscn_mesh_instance_3d.set_owner(tscn_static_body)
#
		## Iterate through MeshInstance3D children to create individual collision shapes
		#for child in tscn_static_body.get_children():
	#
			#if child is MeshInstance3D and child.mesh:
				#child.set_surface_override_material(0, new_standard_material)
#
			#var mesh_shape = child.mesh.create_trimesh_shape()
			#var collision_shape = CollisionShape3D.new()
			#collision_shape.shape = mesh_shape
			#collision_shape.name = child.name + "_collision"
			## Apply the original mesh child's transform to the collision shape
			#collision_shape.transform = child.transform
			## Add the collision shape to the RigidBody3D
			#tscn_static_body.add_child(collision_shape)
			## Set the owner to ensure it's saved with the rigid_body # scene
			#collision_shape.set_owner(tscn_static_body)
			#if debug: print("Added CollisionShape3D for: ", child.name)
#
		## Free the original scene root, as it's no longer needed
		#scene.queue_free()
	#
	#
		### Create and save scene
		#var packed_scene = PackedScene.new()
		#packed_scene.pack(tscn_static_body)
		##var save_path = "res://project_scenes/" + tscn_static_body.name + ".tscn"
		#var save_path: String = path_to_save_scene.path_join(tscn_static_body.name + ".tscn")
		##if debug: print("Saving scene... " + save_path)
		##ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
		#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
#
		#await get_tree().process_frame
		##await get_tree().create_timer(2).timeout
		#create_scene_buttons(loaded_scene, save_path, new_sub_collection_tab)
		#
	#if debug: print("NEED TO REFRESH COLLECTIONS HERE AND ON MAIN TAB CHANGE")
	
#var processed_scene_count: int = -1
	# Revision 1
# FIXME Will not work with when files are have --TAGS
# TEST drag and drop from outside project folder
# FIXME TODO Fix for .glb files being dropped in as no conversion is required if keeping as .glb and not .gltf?
# FIXME .gltf files that are dropped in have links to textures that are broken and show as _0.png _1.png etc.
## Handle files that are dropped into the Scene Viewer panel 
func parse_drop_file(origin_file_path: String, path_to_save_scene: String, scene_count: int, new_sub_collection_tab: Control) -> void:
	#if processed_scene_count == -1:
		#processed_scene_count = scene_count
	if debug: print("origin_file_path: ", origin_file_path)

	# 1. Check if the dropped object is a folder, extract scenes and textures
	var dir = DirAccess.open(origin_file_path)

	if dir != null:
		# Use change_dir to move into the directory and then check
		if dir.change_dir(origin_file_path) == OK:
			parse_directory(origin_file_path, path_to_save_scene, new_sub_collection_tab)
			if debug: print("This is a directory")
			return

	if load(origin_file_path) is Texture:
		process_texture(origin_file_path, path_to_save_scene, new_sub_collection_tab)
		if debug: print("This is a texture")
		return

	if load(origin_file_path) is PackedScene:
		# FIXME TODO PULL IN REQUIRED TEXTURE WITHOUT NEEDING MANUAL DROP INTO SCENE VIEWER WINDOW
		process_packedscene(origin_file_path, path_to_save_scene, scene_count, new_sub_collection_tab)
		if debug: print("This is a packedscene")
		return

	else:
		printerr("Could not process the file at: ", origin_file_path)


func parse_directory(origin_file_path: String, path_to_save_scene: String, new_sub_collection_tab: Control) -> void:
	pass
	


# FIXME TODO If using .glb textures folder not required
func process_texture(origin_file_path: String, path_to_save_scene: String, new_sub_collection_tab: Control) -> void:
	#res://imported/Textures/colormap.png
	#if debug: print( "split: ", full_path_split(origin_file_path, true))
	#if debug: print("path_to_save_scene: ", path_to_save_scene)
	var texture_file_name: PackedStringArray = full_path_split(origin_file_path, true)
	var full_path_to_copy_texture: String = path_to_save_scene.path_join("textures".path_join(texture_file_name[0]))
	

	var path_split: PackedStringArray = full_path_split(full_path_to_copy_texture, false)
	create_folders(path_split[0] + "//", path_split[1].path_join(path_split[2].path_join(path_split[3].path_join(path_split[4].path_join(path_split[5])))))
	#if debug: print(path_split[0] + "//", path_split[1].path_join(path_split[2].path_join(path_split[3].path_join(path_split[4].path_join(path_split[5])))))

	#if debug: print("full_path_to_copy_texture: ", full_path_to_copy_texture)
	new_texture_path = origin_file_path
	emit_signal("do_file_copy", user_dir, origin_file_path, full_path_to_copy_texture)
	# NOTE: Also copy over all .import files to retain original UID to tie the assets UID to the UID referenced in the .tscn files
	if debug: print("origin_file_path: ", origin_file_path)
	var origin_file_path_import: String = origin_file_path + ".import"
	if debug: print("origin_file_path_import: ", origin_file_path_import)
	var full_path_to_copy_texture_import: String = path_to_save_scene.path_join("textures".path_join(texture_file_name[0] + ".import"))
	if debug: print("full_path_to_copy_texture_import: ", full_path_to_copy_texture_import)
	emit_signal("do_file_copy", user_dir, origin_file_path_import, full_path_to_copy_texture_import)
	
	#copy_file(origin_file_path, full_path_to_copy_texture)

## FIXME Can be in scene_snap_plugin.gd and signal called to do function
#func copy_file(origin_file_path: String, path_to_copy_file: String) -> void:
	#if user_dir:
		#if user_dir.file_exists(path_to_copy_file): # Skip copy if file exists
			#push_warning("Skipping... file already exists at: ", path_to_copy_file)
		#else: # Copy over file
			#if user_dir.copy(origin_file_path, path_to_copy_file) != OK:
				#if debug: print("Failed to copy file from ", origin_file_path, " to ", path_to_copy_file)

var collection_file_names: PackedStringArray = []
## Process files that get dragged from filesystem dock into the Scene Viewer Panel
func process_packedscene(origin_file_path: String, path_to_save_scene: String, scene_count: int, new_sub_collection_tab: Control) -> void:
	
	
	var dep_path: String = ""
	
		# TEST
	if debug: print("Do a check here is destination folder has dep if not or included in dropped files if not add popup to warning message")
	for dep in ResourceLoader.get_dependencies(origin_file_path):
		
		# From each .tscn scene file get the dependencies base directory of 
		# where the scene file expects to find the textures in the project res://
		var dep_uid: String = dep.get_slice("::", 0)
		if debug: print("dep_uid: ", dep_uid)
		dep_path = dep.get_slice("::", 2)
		if debug: print("dep_path: ", dep_path)
	#TEST
	

	#if debug: print("path_to_save_scene: ", path_to_save_scene)
	
	var loaded_scene: PackedScene
	
	if load(origin_file_path) is PackedScene:
		loaded_scene = load(origin_file_path)
	else:
		printerr("File was not a PackedScene")


	var scene: Node3D = loaded_scene.instantiate()
	












	
	#if debug: print("scene type: ", scene.get_class())
	##if debug: print("scene.get_children(): ", scene.get_children())
	#var tscn_static_body = StaticBody3D.new()
	##var tscn_static_body = RigidBody3D.new()
	## FIXME TODO FIND BEST WAY TO NAME
	##tscn_static_body.name = scene.get_child(0).name
	#tscn_static_body.name = scene.name
#
	##var scene_scale: Vector3 = scene.get_child(0).get_scale()
	##var scene_rotation: Vector3 = scene.get_child(0).get_rotation()
	##tscn_static_body.set_scale(scene_scale)
	##tscn_static_body.set_rotation(scene_rotation)
	## FIXME Add additional conversions here replace_by to other types
	#scene.replace_by(tscn_static_body)
	##var tscn_static_body = scene
#
#
#
	## FIXME NOTE Quaternious assets import with scaling consider applying scale to tscn_static_body root and 
	## clearing scale on children. because the mesh scales fine, but the CollisionShape3D is not scaled
	#
#
	## Create trimesh collision children for all MeshInstance3D in scene
	#var mesh_node_instances: Array[Node] = tscn_static_body.find_children("*", "MeshInstance3D", true, false)
	#var collision_node_instances: Array[Node] = tscn_static_body.find_children("*", "CollisionShape3D", true, false)
	#var animation_player_node_instances: Array[Node] = tscn_static_body.find_children("*", "AnimationPlayer", true, false)
	#
	#
	## Do check if collision count matches mesh count # TODO Modify for 2D
	#var has_collision_shape: bool = collision_node_instances.size() == mesh_node_instances.size()
#
	#
	#for mesh_child: MeshInstance3D in mesh_node_instances:
		### Reset mesh children scale
		##mesh_child.global_transform.basis = Basis.IDENTITY
		##mesh_child.set_scale(mesh_child.get_scale() / scene_scale)
		##mesh_child.global_transform.origin = mesh_child.global_transform.origin / scene_scale
#
		## FIXME NODE3D Scene root is being converted to static body 3d
		#var collision_shape = null
		#
		#if not has_collision_shape:
			#var mesh_shape = mesh_child.mesh.create_trimesh_shape()
			#collision_shape = CollisionShape3D.new()
			#collision_shape.shape = mesh_shape
			#collision_shape.name = mesh_child.name + "_collision"
			#
			#collision_shape.scale = mesh_child.scale
			#collision_shape.rotation_degrees = mesh_child.rotation_degrees
			#collision_shape.position = mesh_child.position
			#
			#tscn_static_body.add_child(collision_shape)
			#collision_shape.set_owner(tscn_static_body)
#
			#if debug: print("Added CollisionShape3D for: ", mesh_child.name)




		## NOTE Do check if the animation in the AnimationPlayer has any tracks
		#var track_count: int = 0
		#for animation_player_node in animation_player_node_instances:
			#var animation_list: PackedStringArray = animation_player_node.get_animation_list()
			#var first_animation: Animation = animation_player_node.get_animation(animation_list[0])
			#track_count = first_animation.get_track_count()
			#if debug: print("track_count: ", track_count)
			## NOTE Remove AnimationPlayers with first animation having no tracks (Synty seem to have this node on .fbx imports)
			#if track_count == 0:
				#animation_player_node.free()


		#if track_count != 0 and animation_player_node_instances.size() >= 1 or mesh_node_instances.size() > 1: # NOTE track_count != 0 is not needed with above queue_free() but left in
			#var remote_transform_3d = RemoteTransform3D.new()
			#remote_transform_3d.name = mesh_child.name + "_remote_transform"
			#mesh_child.add_child(remote_transform_3d)
			#remote_transform_3d.set_owner(tscn_static_body)
			#if not has_collision_shape:
				#var collision_shape_path: NodePath = remote_transform_3d.get_path_to(collision_shape)
				#remote_transform_3d.set_remote_node(collision_shape_path)
			#if debug: print("PLACEHOLDER FOR CREATING ANIMATIONPLAYER ICON ON BUTTON")

	var save_path: String = ""
	var scene_file: String = scene.get_scene_file_path().get_file()
	if origin_file_path.get_extension() == "glb":
		#var scene_path: String = scene.get_scene_file_path()
		#var scene_file: String = scene.get_scene_file_path().get_file()
		if debug: print("scene.name: ", scene.name)
		if user_dir.copy(origin_file_path, path_to_save_scene.path_join(scene_file)) != OK:
			if debug: print("save error")

		save_path = path_to_save_scene.path_join(scene.name + ".glb")

	else:


# TEST
		# Export .tscn file to .glb
		save_path = path_to_save_scene.path_join(scene.name + ".glb")
		export_gltf(scene, save_path)








####################KEEP Code for creating .tscn from all other types
		##if origin_file_path.get_extension() == "tscn":
		### Create and save scene
		#var packed_scene = PackedScene.new()
		##packed_scene.pack(tscn_static_body)
		#packed_scene.pack(scene)
		##var save_path = "res://project_scenes/" + tscn_static_body.name + ".tscn"
		##var scene_name: String = tscn_static_body.get_child(0).name
		## FIXME TODO FIND BEST WAY TO NAME SAME ABOVE
		##var scene_name: String = tscn_static_body.name
		#var scene_name: String = scene.name
		#
		#save_path = path_to_save_scene.path_join(scene_name + ".tscn")
#
		#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
####################KEEP








	if debug: print("removing scene instance1")
	scene.queue_free()
#	tscn_static_body.queue_free()

	await get_tree().process_frame
	if debug: print("save_path: ", save_path)
	var new_scene_view: Button = null
	#if debug: print("new_sub_collection_tab.name: ", new_sub_collection_tab.name)
	#if debug: print("processed_scene_count: ", processed_scene_count)
	#processed_scene_count -= 1
	# NOTE: Runs once after all files that were dropped have been processed and saved as .glb to the user:// dir.
	#if processed_scene_count <= 0:
	#if debug: print("collection_scene_full_paths_array", collection_scene_full_paths_array)
	#if debug: print("collection_scene_full_paths: ", collection_scene_full_paths)
	
	
	collection_file_names.append(scene_file)
	if debug: print("collection_file_names: ", collection_file_names)
	if debug: print("collection_file_names.size(): ", collection_file_names.size())
	if debug: print("collection scene_count: ", scene_count)
	#collection_file_names.clear()
	if collection_file_names.size() == scene_count:
		collection_file_names.clear()
		
		if debug: print("processing finished")
		#if debug: print("path_to_save_scene: ", path_to_save_scene.split("/")[-2])
		# Trigger add_scenes_to_collections once after all files copied to user:// dir
		
		
		var main_collection_tab_name: String = path_to_save_scene.split("/")[-2]
		var sub_folders_path: String = ""
		if main_collection_tab_name == "Global Collections":
			sub_folders_path = scenes_paths[0].path_join(main_collection_tab_name)
		if main_collection_tab_name == "Shared Collections":
			sub_folders_path = scenes_paths[1].path_join(main_collection_tab_name)

		#var scenes_dir_path: String = sub_folders_path.path_join(new_sub_collection_tab.name)
		#var collection_file_names: PackedStringArray = DirAccess.get_files_at(scenes_dir_path)
		#add_scenes_to_collections(collection_name: String, sub_folders_path: String, new_sub_collection_tab: Control, collection_file_names: PackedStringArray)
		# NOTE: Process only new scenes added to collection collection_file_names
		#if debug: print("collection_file_names size: ", collection_file_names.size())
		# FIXME Works on first run, but breaks on ones after if more is being added?
		#var files_for_this_batch: PackedStringArray = collection_file_names.duplicate() # Create a copy for this specific call
		# TODO add to queue
		var collection_data: Array = []
		collection_data.append(new_sub_collection_tab.name)
		#collection_data.append(collection_name_snake_case)
		collection_data.append(sub_folders_path)
		collection_data.append(new_sub_collection_tab)
		collection_queue.append(collection_data)
		
		if debug: print("processing_collection: ", processing_collection)
		if debug: print("collection_queue.size(): ", collection_queue.size())

# FIXME IN CREATE BUTTONS CHECK IF BUTTON EXISTS AND IF YES DO NOT CREATE ANOTHER DUPLICATE BUTTON
		#var processed_collection: bool = not processing_collection
		#await wait_ready(processed_collection)

		while processing_collection:
			await get_tree().process_frame

		if not processing_collection and collection_queue.size() >= 1:
			#emit_signal("process_next_collection", files_for_this_batch)
			emit_signal("process_next_collection", true)
		#collection_file_names.clear()
		##add_scenes_to_collections(new_sub_collection_tab.name, sub_folders_path, new_sub_collection_tab, files_for_this_batch)
		#await finished_processing_collection # ? FIXME Find correct sginal to listen to.
		#if debug: print("clearing collection_file_names now")
		#collection_file_names.clear()
	# NOTE: Run already project imported scene through add_scenes_to_collections or do not remove scene above and use to generate thumbnails etc?
	# on next start will run through add_scenes_to_collections, but then will not get 360? 
	#create_scene_buttons(save_path, new_sub_collection_tab, new_scene_view, false)





























##
	## FIXME NEED TO ACCOUNT FOR DIFFERENT STATES THAT THE .TSCN FILE IS IN. NO COLLISIONS. MADE FROM OTHER SCENES.
	## SCENES GENERATED BY USER WILL NEED TO HAVE THUMBNAILS MADE NOT COPIED OVER SINCE THEY DON'T EXIST
	#if origin_file_path.ends_with(".tscn"): # Simply copy it over
		#var scene_name_split: PackedStringArray = full_path_split(origin_file_path, true)
		#if debug: print("origin_file_path: ", origin_file_path)
		#if debug: print("scene_name_split: ", scene_name_split)
		#var path_to_save_scene_split: PackedStringArray = full_path_split(path_to_save_scene, false)
		#
		#if not user_dir.dir_exists(path_to_save_scene):
			#create_folders(path_to_save_scene_split[0] + "//", path_to_save_scene_split[1].path_join(path_to_save_scene_split[2].path_join(path_to_save_scene_split[3])))
			#
		## NOTE This will strip out --TAGS
		#var scene_full_path: String = path_to_save_scene.path_join(scene_name_split[0] + ".tscn")
		##if scene_full_path.ends_with(".tscn"):
			##pass
		##else:
			##scene_full_path = path_to_save_scene.path_join(scene_name_split[0] + ".tscn")
#
#
		##if debug: print("scene_full_path: ", scene_full_path)
		##if debug: print("get_thumbnail_cache_path: ", get_thumbnail_cache_path(".tscn", scene_full_path))
		#var thumbnail_cache_path: String = get_thumbnail_cache_path(".tscn", scene_full_path)
		#var thumb_path_split: PackedStringArray = full_path_split(thumbnail_cache_path, false)
#
		#if user_dir:
			### Skip reimporting if file exists # TODO add option to skip this step if user wants to overwrite existing scenes
			#
			## Copy .tscn file
			#if user_dir.file_exists(scene_full_path):
				#push_warning("Scene already exists at: ", scene_full_path)
#
			#else:
				#var scene_copy_result = user_dir.copy(origin_file_path, scene_full_path)
				#if scene_copy_result != OK:
					#if debug: print("Failed to copy Scene.")
			#
			## Copy thumbnail
			#if user_dir.file_exists(thumbnail_cache_path):
				#push_warning("File already exists at: ", thumbnail_cache_path)
				#pass
			#else: # FIXME COPY OR CREATE ONE 
				#
				#var project_name: String = ProjectSettings.get_setting("application/config/name")
				##scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - 5) # The length of .tscn = 5
				#var name_png: String = scene_name_split[0] + ".png"
				#var thumbnail_path: String = path_to_thumbnail_cache_project.path_join(project_name.path_join(name_png))
				#
				#create_folders(thumb_path_split[0] + "//", thumb_path_split[1].path_join(thumb_path_split[2].path_join(thumb_path_split[3].path_join(thumb_path_split[4]))))
#
				#if user_dir.file_exists(thumbnail_path):
					#var thumbnail_copy_result = user_dir.copy(thumbnail_path, thumbnail_cache_path)
					#if thumbnail_copy_result == OK:
						#pass
						##if debug: print("Thumbnail copied successfully.")
					#else:
						#if debug: print("Failed to copy Thumbnail.")
#
			#await get_tree().process_frame
			##await get_tree().create_timer(3).timeout
			##if debug: print("scene_full_path #####: ", scene_full_path)
			#create_scene_buttons(loaded_scene, scene_full_path, new_sub_collection_tab)
#
	#else: # Run the file through the import process
		#
		##var loaded_scene: PackedScene = load(origin_file_path)
		##var scene: Node3D = loaded_scene.instantiate()
		#var tscn_static_body = StaticBody3D.new()
		#var mesh_node_instances: Array[Node] = scene.find_children("*", "MeshInstance3D", true, false)
		#if debug: print("mesh_node_instances.size: ", mesh_node_instances.size())
		#if mesh_node_instances.size() == 1:
			##if debug: print("ADD POPUP TO ADDED LOCATION OF TEXTURE HERE!")
			#var new_standard_material: StandardMaterial3D = StandardMaterial3D.new()
			##if new_texture_path == "":
				##push_warning("A texture has not been added to the collection.")
			##else:
				##var new_texture: Texture = load(new_texture_path)
				##new_standard_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, new_texture)
#
#
#
			## NOTE: Copy the texture that is listed as a dep over to the user:// directory
			#process_texture(dep_path, path_to_save_scene, new_sub_collection_tab)
#
			## Use the dep_path to get the path to the texture
			#var new_texture: Texture = load(dep_path)
			#new_standard_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, new_texture)

#
#
#
			#var mesh_node: MeshInstance3D
			#mesh_node = find_mesh_instance_3d_child(scene)
			#
			#if debug: print("mesh_node: ", mesh_node)
		#
			#if mesh_node == null:
				#printerr("The imported scene does have a MeshInstance3D child or grandchild")
		#
			##var tscn_static_body = StaticBody3D.new()
		#
			#var tscn_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
		#
			## Rename StaticBody3D to MeshInstance3D Name
			#tscn_static_body.name = mesh_node.name# + "--Tags"
		#
			#tscn_mesh_instance_3d = mesh_node.duplicate()
#
			#tscn_static_body.add_child(tscn_mesh_instance_3d)
			#tscn_mesh_instance_3d.set_owner(tscn_static_body)
#
			## Iterate through MeshInstance3D children to create individual collision shapes
			#for child in tscn_static_body.get_children():
		#
				#if child is MeshInstance3D and child.mesh:
					#child.set_surface_override_material(0, new_standard_material)
#
				#var mesh_shape = child.mesh.create_trimesh_shape()
				#var collision_shape = CollisionShape3D.new()
				#collision_shape.shape = mesh_shape
				#collision_shape.name = child.name + "_collision"
				## Apply the original mesh child's transform to the collision shape
				#collision_shape.transform = child.transform
				## Add the collision shape to the RigidBody3D
				#tscn_static_body.add_child(collision_shape)
				## Set the owner to ensure it's saved with the rigid_body # scene
				#collision_shape.set_owner(tscn_static_body)
				#if debug: print("Added CollisionShape3D for: ", child.name)
#
		#else:
			#
			#var new_standard_material: StandardMaterial3D = StandardMaterial3D.new()
			## NOTE: Copy the texture that is listed as a dep over to the user:// directory
			#process_texture(dep_path, path_to_save_scene, new_sub_collection_tab)
#
			## Use the dep_path to get the path to the texture
			#var new_texture: Texture = load(dep_path)
			#new_standard_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, new_texture)
#
			#for mesh_child: MeshInstance3D in mesh_node_instances:
#
#
				#if mesh_child == null:
					#printerr("The imported scene does have a MeshInstance3D child or grandchild")
#
				#var tscn_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
			#
				## Rename StaticBody3D to MeshInstance3D Name
## NOTE CHANGED FROM REAPEAT CODE HERE
				#var scene_name: String = scene.get_child(0).name
				##tscn_static_body.name = mesh_child.name# + "--Tags"
				#tscn_static_body.name = scene_name
			#
				#tscn_mesh_instance_3d = mesh_child.duplicate()
#
				#tscn_static_body.add_child(tscn_mesh_instance_3d)
				#tscn_mesh_instance_3d.set_owner(tscn_static_body)
#
			## Iterate through MeshInstance3D children to create individual collision shapes
			#for child in tscn_static_body.get_children():
		#
				#if child is MeshInstance3D and child.mesh:
					#child.set_surface_override_material(0, new_standard_material)
#
				#var mesh_shape = child.mesh.create_trimesh_shape()
				#var collision_shape = CollisionShape3D.new()
				#collision_shape.shape = mesh_shape
				#collision_shape.name = child.name + "_collision"
				## Apply the original mesh child's transform to the collision shape
				#collision_shape.transform = child.transform
				## Add the collision shape to the RigidBody3D
				#tscn_static_body.add_child(collision_shape)
				## Set the owner to ensure it's saved with the rigid_body # scene
				#collision_shape.set_owner(tscn_static_body)
				#if debug: print("Added CollisionShape3D for: ", child.name)
#
#
#
#
#
#
#
#
#
		## Free the original scene root, as it's no longer needed
		#scene.queue_free()
	#
	#
		### Create and save scene
		#var packed_scene = PackedScene.new()
		#packed_scene.pack(tscn_static_body)
		##var save_path = "res://project_scenes/" + tscn_static_body.name + ".tscn"
		#var save_path: String = path_to_save_scene.path_join(tscn_static_body.name + ".tscn")
		##if debug: print("Saving scene... " + save_path)
		##ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
		#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
#
		#await get_tree().process_frame
		##await get_tree().create_timer(2).timeout
		#if debug: print("save_path: ", save_path)
		#create_scene_buttons(loaded_scene, save_path, new_sub_collection_tab)
		#
	#if debug: print("NEED TO REFRESH COLLECTIONS HERE AND ON MAIN TAB CHANGE")
#
	#

	
#endregion

#enum State {
	#STATE_ONE,
	#STATE_TWO,
	#STATE_THREE,
	#STATE_FOUR,
	#STATE_FIVE
#}





# ORIGINAL START
#enum Collision_3D_State {
	#NO_COLLISION,
	#SPHERESHAPE3D,
	#BOXSHAPE3D,
	#CAPSULESHAPE3D,
	#CYLINDERSHAPE3D,
	#SIMPLIFIED_CONVEX,
	#SINGLE_CONVEX,
	#MULTI_CONVEX,
	#TRIMESH
#}
#
#func toggle_3d_collision_state_up():
	#match next_3d_collision_state:
		#Collision_3D_State.NO_COLLISION:
			#next_3d_collision_state = Collision_3D_State.TRIMESH
		#Collision_3D_State.TRIMESH:
			#next_3d_collision_state = Collision_3D_State.MULTI_CONVEX
		#Collision_3D_State.MULTI_CONVEX:
			#next_3d_collision_state = Collision_3D_State.SINGLE_CONVEX
		#Collision_3D_State.SINGLE_CONVEX:
			#next_3d_collision_state = Collision_3D_State.NO_COLLISION
			#
#
##const MULTI_CONVEX = preload("res://addons/scene_snap/icons/multi_convex.svg")
##const SIMPLIFIED_CONVEX = preload("res://addons/scene_snap/icons/simplified_convex.svg")
##const SINGLE_CONVEX = preload("res://addons/scene_snap/icons/single_convex.svg")
##const TRIMESH = preload("res://addons/scene_snap/icons/trimesh.svg")
##const NO_COLLISION = preload("res://addons/scene_snap/icons/no_collision.svg")
#
#func toggle_3d_collision_state_down():
	#match next_3d_collision_state:
		#Collision_3D_State.NO_COLLISION:
			#change_collision_shape_3d_button.set_button_icon(NO_COLLISION)
			#change_collision_shape_3d_button.tooltip_text = "Place Scene With No Collisions"
			#next_3d_collision_state = Collision_3D_State.SPHERESHAPE3D
		#Collision_3D_State.SPHERESHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"SphereShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "SphereShape3D The fastest shape to check collisions against"
			#next_3d_collision_state = Collision_3D_State.BOXSHAPE3D
		#Collision_3D_State.BOXSHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"BoxShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "BoxShape3D"
			#next_3d_collision_state = Collision_3D_State.CAPSULESHAPE3D
		#Collision_3D_State.CAPSULESHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"CapsuleShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "CapsuleShape3D"
			#next_3d_collision_state = Collision_3D_State.CYLINDERSHAPE3D
		#Collision_3D_State.CYLINDERSHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"CylinderShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "CylinderShape3D Note: CapsuleShape3D or BoxShape3D is recommended due to known bugs with cylinder collision shapes."
			#next_3d_collision_state = Collision_3D_State.SIMPLIFIED_CONVEX
		#Collision_3D_State.SIMPLIFIED_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Simplified (ConvexPolygonShape3D)"
			#next_3d_collision_state = Collision_3D_State.SINGLE_CONVEX
		#Collision_3D_State.SINGLE_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(SINGLE_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Single (ConvexPolygonShape3D)"
			#next_3d_collision_state = Collision_3D_State.MULTI_CONVEX
		#Collision_3D_State.MULTI_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(MULTI_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Multiple (ConvexPolygonShape3Ds)"
			#next_3d_collision_state = Collision_3D_State.TRIMESH
		#Collision_3D_State.TRIMESH:
			##change_collision_shape_3d_button.set_button_icon(TRIMESH)
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"ConcavePolygonShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "Trimesh (ConcavePolygonShape3D) NOTE: Intended to be used primarily with StaticBody3D level geometry"
			#next_3d_collision_state = Collision_3D_State.NO_COLLISION
#
#
#var current_3d_collision_state: String = "" 
#var next_3d_collision_state: Collision_3D_State = Collision_3D_State.TRIMESH
#
#
#
#
#
#func _on_change_collision_shape_3d_button_pressed() -> void:
	#
	#
	#current_3d_collision_state = Collision_3D_State.find_key(next_3d_collision_state)
	##if debug: print("current_state: ", current_state)
	#toggle_3d_collision_state_down()
	##if debug: print("current_state: ", current_state)
	##scene_snap_settings.set_collision_state(Collision_3D_State.find_key(current_state))
	##scene_snap_settings.currently_selected_collision_state = Collision_3D_State.find_key(current_state)
	#emit_signal("change_collision_shape_3d", current_3d_collision_state)
	#
	##if debug: print("scene_snap_settings.currently_selected_collision_state: ", scene_snap_settings.currently_selected_collision_state)
	#if debug: print("change collsionshape3d")
	#pass # Replace with function body.
# ORIGINAL END





# Reference: https://www.reddit.com/r/godot/comments/17beg3u/creating_assets_during_runtime_such_as_custom/(mrcdk)
# FIXME Being stored as Node:<Node3D#6267682816568> not <Node3D#6267682816568> NOTE: Non-issue, issue was not setting all child.owner = root
func export_gltf(root: Node, save_path: String) -> void:
	# File will not save correctly unless all children are owned by the scene_instance
	for child in root.get_children():
		child.owner = root
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_scene(root, state)
	if not err == OK:
		if debug: print('Error appending from scene %s' % err)
	else:
		err = doc.write_to_filesystem(state, save_path)
		if not err == OK:
			if debug: print('Error writting to filesystem %s' % err)







func do_button_conflict_matching() -> void:
	var first_conflict: bool = false
	var second_conflict: bool = false

	#if next_3d_collision_state != 0 and next_type_3d <= 1: # 1 is Node3D / 0 is No Collision
	if next_type_3d <= 1:
		collision_3d_warning.set_texture(get_theme_icon("NodeWarning", "EditorIcons"))
		collision_3d_warning.set_tooltip_text("WARNING: CollisionShape3D only serves to provide a collision shape to a CollisionObject3D derived node. \
		\nPlease only use it as a child of Area3D, StaticBody3D, RigidBody3D, CharacterBody3D, etc. to give them a shape.")
		
		change_collision_shape_3d_button.set_disabled(true)
		collision_visibility_toggle_button.set_disabled(true)
		var disabled_color = Color(0.44, 0.46, 0.49, 1.00)
		collision_3d_number.set("theme_override_colors/font_color", disabled_color)
		collision_3d_warning.show()
		emit_signal("set_enable_collision", false) # Do not generate collisions for placed object if PhysicsBody3D is None or Node3D 
		emit_signal("visible_scene_preview_collisions", false) # Do not generate or show collisions for scene preview
		first_conflict = true
	else:
		change_collision_shape_3d_button.set_disabled(false)
		collision_visibility_toggle_button.set_disabled(false)
		var default_color: = Color(0.75, 0.75, 0.75, 1)
		collision_3d_number.set("theme_override_colors/font_color", default_color)
		collision_3d_warning.hide()
		if collision_toggled_on:
			emit_signal("set_enable_collision", true)
			emit_signal("visible_scene_preview_collisions", true)


	if next_3d_collision_state == 7 and next_type_3d != 2: # 7 is Trimesh / 2 is StaticBody3D
		collision_3d_warning.set_texture(get_theme_icon("NodeWarning", "EditorIcons"))
		collision_3d_warning.set_tooltip_text("WARNING: The Trimesh CollisionShape3D is intended to be used primarily with StaticBody3D level geometry.")
		collision_3d_warning.show()
		second_conflict= true

	if first_conflict and second_conflict:
		collision_3d_warning.set_texture(get_theme_icon("NodeWarnings2", "EditorIcons"))
		collision_3d_warning.set_tooltip_text("WARNING: The Trimesh CollisionShape3D is intended to be used primarily with StaticBody3D level geometry. \
		\nWARNING: CollisionShape3D only serves to provide a collision shape to a CollisionObject3D derived node. \
		\nPlease only use it as a child of Area3D, StaticBody3D, RigidBody3D, CharacterBody3D, etc. to give them a shape.")
		collision_3d_warning.show()




enum Collision_3D_State {
	#NO_COLLISION,
	SPHERESHAPE3D,
	BOXSHAPE3D,
	CAPSULESHAPE3D,
	CYLINDERSHAPE3D,
	SIMPLIFIED_CONVEX,
	SINGLE_CONVEX,
	MULTI_CONVEX,
	TRIMESH
}

var next_3d_collision_state: Collision_3D_State = Collision_3D_State.TRIMESH

# Function to toggle state in the given direction
func toggle_3d_collision_state(direction: int) -> void:

	# Get the current index of the state using the enum values
	var current_index = int(next_3d_collision_state)

	# Move up (direction = 1) or down (direction = -1)
	current_index += direction
	
	# Wrap around if needed (ensure index stays within bounds)
	if current_index < 0:
		current_index = Collision_3D_State.size() - 1
	elif current_index >= Collision_3D_State.size():
		current_index = 0
	
	# Update the next state (use the enum value by its index)
	next_3d_collision_state = Collision_3D_State.values()[current_index]
	update_3d_collision_state_button()
	# TODO make func so that both buttons can call and do same check when pressed
	do_button_conflict_matching()


# FIXME "Multiple Convex" shape very small and giving ERROR: res://addons/scene_snap/scene_snap_plugin.gd:3722 - Trying to assign invalid previously freed instance.

# Function to update the button and tooltip based on the current state
func update_3d_collision_state_button() -> void:
	match next_3d_collision_state:
		#Collision_3D_State.NO_COLLISION:
			#change_collision_shape_3d_button.set_button_icon(NO_COLLISION)
			#change_collision_shape_3d_button.tooltip_text = "No collisions"
		Collision_3D_State.SPHERESHAPE3D:
			change_collision_shape_3d_button.set_button_icon(get_theme_icon("SphereShape3D", "EditorIcons"))
			change_collision_shape_3d_button.tooltip_text = "SphereShape3D"
		Collision_3D_State.BOXSHAPE3D:
			change_collision_shape_3d_button.set_button_icon(get_theme_icon("BoxShape3D", "EditorIcons"))
			change_collision_shape_3d_button.tooltip_text = "BoxShape3D"
		Collision_3D_State.CAPSULESHAPE3D:
			change_collision_shape_3d_button.set_button_icon(get_theme_icon("CapsuleShape3D", "EditorIcons"))
			change_collision_shape_3d_button.tooltip_text = "CapsuleShape3D"
		Collision_3D_State.CYLINDERSHAPE3D:
			change_collision_shape_3d_button.set_button_icon(get_theme_icon("CylinderShape3D", "EditorIcons"))
			change_collision_shape_3d_button.tooltip_text = "CylinderShape3D Note: CapsuleShape3D or BoxShape3D is recommended due to known bugs with cylinder collision shapes."
		Collision_3D_State.SIMPLIFIED_CONVEX:
			change_collision_shape_3d_button.set_button_icon(SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D)
			change_collision_shape_3d_button.tooltip_text = "Simplified Convex"
		Collision_3D_State.SINGLE_CONVEX:
			change_collision_shape_3d_button.set_button_icon(SINGLE_CONVEX_POLYGON_SHAPE_3D)
			change_collision_shape_3d_button.tooltip_text = "Single Convex"
		Collision_3D_State.MULTI_CONVEX:
			change_collision_shape_3d_button.set_button_icon(MULTI_CONVEX_POLYGON_SHAPE_3D)
			change_collision_shape_3d_button.tooltip_text = "Multiple Convex"
		Collision_3D_State.TRIMESH:
			change_collision_shape_3d_button.set_button_icon(get_theme_icon("ConcavePolygonShape3D", "EditorIcons"))
			change_collision_shape_3d_button.tooltip_text = "Trimesh" #NOTE: Intended to be used primarily with StaticBody3D level geometry."

# Toggle up function (Move forward in the list)
func toggle_3d_collision_state_up() -> void:
	toggle_3d_collision_state(-1)
	update_collision_shape_3d_variables()

# Toggle down function (Move backward in the list)
func toggle_3d_collision_state_down() -> void:
	toggle_3d_collision_state(1)
	update_collision_shape_3d_variables()

var current_3d_collision_state: String = "" 

# Button press handler
func _on_change_collision_shape_3d_button_pressed() -> void:
	toggle_3d_collision_state_down()  # Example: Change state down when the button is pressed
	#collision_shape_3d_info()


func update_collision_shape_3d_variables() -> void:
	current_3d_collision_state = Collision_3D_State.find_key(next_3d_collision_state) # Get collision name as string
	collision_3d_number.set_text(str(next_3d_collision_state))
	emit_signal("change_collision_shape_3d", current_3d_collision_state)


enum Physics_Body_Type_3D {
	NO_PHYSICSBODY3D,
	NODE3D,
	STATICBODY3D,
	RIGIDBODY3D,
	CHARACTERBODY3D
}

# Initially set to NO_PHYSICSBODY3D (as an example)
var next_type_3d: Physics_Body_Type_3D = Physics_Body_Type_3D.CHARACTERBODY3D

# Function to toggle physics body type in the given direction
func toggle_physics_body_type_3d(direction: int) -> void:
	# Get the current index of the body type (as an integer)
	var current_index = int(next_type_3d)

	# Move up (direction = 1) or down (direction = -1)
	current_index += direction
	
	# Wrap around if needed (ensure index stays within bounds)
	if current_index < 0:
		current_index = Physics_Body_Type_3D.size() - 1
	elif current_index >= Physics_Body_Type_3D.size():
		current_index = 0
	
	# Update the next body type (use the enum value by its index)
	next_type_3d = Physics_Body_Type_3D.values()[current_index]
	update_physics_body_type_button()
	do_button_conflict_matching()
	
# Function to update the button and tooltip based on the current body type
func update_physics_body_type_button() -> void:
	match next_type_3d:
		Physics_Body_Type_3D.NO_PHYSICSBODY3D:
			change_body_type_3d_button.set_button_icon(NO_COLLISION)
			change_body_type_3d_button.tooltip_text = "No PhysicsBody3D"
		Physics_Body_Type_3D.NODE3D:
			change_body_type_3d_button.set_button_icon(get_theme_icon("Node3D", "EditorIcons"))
			change_body_type_3d_button.tooltip_text = "Node3D"
		Physics_Body_Type_3D.STATICBODY3D:
			change_body_type_3d_button.set_button_icon(get_theme_icon("StaticBody3D", "EditorIcons"))
			change_body_type_3d_button.tooltip_text = "StaticBody3D"
		Physics_Body_Type_3D.RIGIDBODY3D:
			change_body_type_3d_button.set_button_icon(get_theme_icon("RigidBody3D", "EditorIcons"))
			change_body_type_3d_button.tooltip_text = "RigidBody3D"
		Physics_Body_Type_3D.CHARACTERBODY3D:
			change_body_type_3d_button.set_button_icon(get_theme_icon("CharacterBody3D", "EditorIcons"))
			change_body_type_3d_button.tooltip_text = "CharacterBody3D"

# Toggle up function (Move forward in the list)
func toggle_physics_body_type_up() -> void:
	toggle_physics_body_type_3d(-1)
	update_update_physics_body_type_3d_variables()

# Toggle down function (Move backward in the list)
func toggle_physics_body_type_down() -> void:
	toggle_physics_body_type_3d(1)
	update_update_physics_body_type_3d_variables()

var current_type_3d: String = ""

# Button press handler
func _on_change_body_type_3d_button_pressed() -> void:
	toggle_physics_body_type_down()  # Change state up when the button is pressed


func update_update_physics_body_type_3d_variables() -> void:
	current_type_3d = Physics_Body_Type_3D.find_key(next_type_3d) # Get body type name as string
	body_3d_number.set_text(str(next_type_3d))
	emit_signal("change_physics_body_type_3d", current_type_3d)









#enum Material_Override_3D {
	#NO_PHYSICSBODY3D,
	#NODE3D,
	#STATICBODY3D,
	#RIGIDBODY3D,
	#CHARACTERBODY3D
#}
#
#
#
#
## Initially set to NO_PHYSICSBODY3D (as an example)
#var next_material_3d: Material_Override_3D = Material_Override_3D.CHARACTERBODY3D
#
## Function to toggle physics body type in the given direction
#func toggle_material_override_3d(direction: int) -> void:
	## Get the current index of the body type (as an integer)
	#var current_index = int(next_material_3d)
#
	## Move up (direction = 1) or down (direction = -1)
	#current_index += direction
	#
	## Wrap around if needed (ensure index stays within bounds)
	#if current_index < 0:
		#current_index = Material_Override_3D.size() - 1
	#elif current_index >= Material_Override_3D.size():
		#current_index = 0
	#
	## Update the next body type (use the enum value by its index)
	#next_material_3d = Material_Override_3D.values()[current_index]
	#update_material_override_button()
	#do_button_conflict_matching()
	#
## Function to update the button and tooltip based on the current body type
#func update_material_override_button() -> void:
	#match next_material_3d:
		#Material_Override_3D.NO_PHYSICSBODY3D:
			#change_body_type_3d_button.set_button_icon(NO_COLLISION)
			#change_body_type_3d_button.tooltip_text = "No PhysicsBody3D"
		#Material_Override_3D.NODE3D:
			#change_body_type_3d_button.set_button_icon(get_theme_icon("Node3D", "EditorIcons"))
			#change_body_type_3d_button.tooltip_text = "Node3D"
		#Material_Override_3D.STATICBODY3D:
			#change_body_type_3d_button.set_button_icon(get_theme_icon("StaticBody3D", "EditorIcons"))
			#change_body_type_3d_button.tooltip_text = "StaticBody3D"
		#Material_Override_3D.RIGIDBODY3D:
			#change_body_type_3d_button.set_button_icon(get_theme_icon("RigidBody3D", "EditorIcons"))
			#change_body_type_3d_button.tooltip_text = "RigidBody3D"
		#Material_Override_3D.CHARACTERBODY3D:
			#change_body_type_3d_button.set_button_icon(get_theme_icon("CharacterBody3D", "EditorIcons"))
			#change_body_type_3d_button.tooltip_text = "CharacterBody3D"
#
## Toggle up function (Move forward in the list)
#func toggle_material_override_up() -> void:
	#toggle_material_override_3d(-1)
	#update_material_override_3d_variables()
#
## Toggle down function (Move backward in the list)
#func toggle_material_override_down() -> void:
	#toggle_material_override_3d(1)
	#update_material_override_3d_variables()
#
var current_material_3d: String = ""
#var material_index: int = -1
var default_material: StandardMaterial3D = null
var collect_tres: bool = true
#
## FIXME Need to reload project for tres_file_paths to be populated by collect_tres_files("res://")
### Button press handler
#func _on_change_material_button_pressed() -> void:
	#if debug: print("default_material: ", default_material)
	#if collect_tres:
		#collect_tres = false
		#collect_tres_files("res://")
		#await get_tree().process_frame
	#for tres in tres_file_paths:
		#var file = load(tres)
		#if file is StandardMaterial3D:
			#if debug: print("file: ", file)
		#
	#toggle_material_override_down()  # Change state up when the button is pressed






#func update_material_button_mesh_instance_3d(material: Material) -> void:
	#material_button_mesh_instance_3d.set_surface_override_material(0, material)
	#material_button_mesh_instance_3d.mesh.surface_set_material(0, material)
	
	#default_material = material





#
#
#func update_material_override_3d_variables() -> void:
	#current_material_3d = Material_Override_3D.find_key(next_material_3d) # Get body type name as string
	#body_3d_number.set_text(str(next_material_3d))
	#emit_signal("change_physics_body_type_3d", current_material_3d)


## Button press handler
#func _on_change_material_button_pressed() -> void:
	## Collect .tres materials on first use
	#if collect_tres:
		#collect_tres = false
		#collect_standard_material_3d("res://") 
		##collect_tres_files("res://")  # You must define this function
		#await get_tree().process_frame
#
	#if materials_3d_array.is_empty():
		#push_warning("No materials files found in project.")
		#return
#
	## Cycle to next material
	#material_index += 1
	#if material_index >= materials_3d_array.size():
		#material_index = 0
#
	#var material = materials_3d_array[material_index]
	#update_material_button_mesh_instance_3d(0, material)  # Surface index 0 assumed






	#var material = load(tres_path)
	#
	#if material is StandardMaterial3D:
		#if debug: print("Applying material:", tres_path)
		#update_material_button_mesh_instance_3d(0, material)  # Surface index 0 assumed
	#else:
		#push_warning("Not a valid StandardMaterial3D: " + tres_path)


## Replace the enum with an array to store loaded materials
#var materials: Array = []

# Index to track the current material
var current_material_index: int = -1
var current_favorite_material_index: int = -1

## Function to load materials from tres_file_paths and initialize materials array
#func load_materials_from_tres_paths() -> void:
	#for tres_path in tres_file_paths:
		#var material = load(tres_path)
		#if material is StandardMaterial3D:
			#materials.append(material)

# Function to cycle materials
func cycle_material(direction: int) -> void:
	#var material_index: int = -1

	if cycle_material_favorites:
		#material_index = current_favorite_material_index
		if not favorite_materials_index_array.is_empty():
			wrap_around_index(direction, favorite_materials_index_array)
		else:
			push_warning("Add materials to favorite, there are currently none.")
	else:
		#material_index = current_material_index
		wrap_around_index(direction, materials_3d_array)



	#var selected_material: Resource = materials_3d_array[current_material_index]
	#material_button_mesh_instance_3d.set_surface_override_material(0, selected_material)
	#material_3d_number.set_text(str(current_material_index))

	emit_signal("get_current_scene_preview")
	set_surface_materials(current_scene_preview, current_scene_path)
	#do_material_favorite_check()







	#var default_material: StandardMaterial3D = material_lookup[current_scene_path][current_selected_surface_index]
	#if current_material_index != materials_3d_array.find(default_material):
		#favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
	#else:
		#favorite_material_button.set_texture_normal(get_theme_icon("NonFavorite", "EditorIcons"))
#
	#emit_signal("update_mesh_material", material)

func wrap_around_index(direction: int, array: Array) -> void:
	# Convert from index in materials_3d_array to index in favorite_materials_index_array
	if cycle_material_favorites:
		current_material_index = favorite_materials_index_array.find(current_material_index)
	current_material_index += direction

	if debug: print("current_material_index1: ", current_material_index)

	# Wrap around to ensure index stays within bounds of the array
	if current_material_index < 0:
		current_material_index = array.size() - 1
	elif current_material_index >= array.size():
		current_material_index = 0

	# Convert back from index in favorite_materials_index_array index in materials_3d_array
	if cycle_material_favorites:
		#favorite_materials_index_array.find(current_material_index)
		current_material_index = favorite_materials_index_array[current_material_index]
		if debug: print("current_material_index2: ", current_material_index)



# Button press handler
func _on_change_material_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		cycle_material(-1)
	else:
		cycle_material(1)





### Function to update the material on the Button
## TODO update scene_preview mesh and button 360 mesh here 
## FIXME secondary textures not being applied example workbench vice, workbench yes, vice does not have texture NOTE: works when cycling on that surface but just no default texture visible
#func update_materials_mesh_instance_3d(material: Material) -> void:
#
	### NOTE: This is good since it is only changing the button surface so hardcoding to 0 is correct here
	##material_button_mesh_instance_3d.set_surface_override_material(0, material)
#
	#if material_lookup.keys().has(current_scene_path):# and material_lookup[current_scene_path].has(current_selected_surface_index):
		##var default_material: StandardMaterial3D = material_lookup[current_scene_path][current_selected_surface_index]
		##if current_material_index == materials_3d_array.find(default_material):
			##favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
		##else:
			##favorite_material_button.set_texture_normal(get_theme_icon("NonFavorite", "EditorIcons"))
#
		## NOTE: This needs to update the current surface with the selected material, but also set the other surfaces to their default textures.
		## NOTE: Need to get scene_preview from scene_snap_plugin.gd and then add in here emit call to update var in this script.
		#emit_signal("get_current_scene_preview")
		## This sets the dafualt texture for the scene_preview
		##set_surface_materials(current_scene_preview, current_scene_path, current_selected_surface_index, material, false, false)
		#set_surface_materials(current_scene_preview, current_scene_path)
		##emit_signal("update_mesh_material", current_scene_path, current_selected_surface_index, material)




	#if debug: print("Current Material:", material)
	#
	##var material_id: int = material.get_instance_id()
	#
	#if material_lookup.has(material) and material_lookup[material].has(current_scene_path):
	##if material_lookup[material].has(current_scene_path):
	##if material == default_material:
		#favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
	#else:
		#favorite_material_button.set_texture_normal(get_theme_icon("NonFavorite", "EditorIcons"))
	#
	#
	#
	#
	#emit_signal("update_mesh_material", material)

#var favorite_material_enabled: bool = false

#func set_default_material() -> void:
	#if hold_current_material:
		##favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
		#favorite_material_button.self_modulate = get_accent_color()
	#else:
		#set_material_button_to_default_material()



## FIXME Defualt for some material is wrong or shows two. FIXME THIS IS BECAUSE SOME MESH HAVE MULTIPLE MATERIALS PROBLEM IS THAT MY SETUP IS APPLYING SINGLE MATERIAL TO ALL PARTS. HOW TO FIX?
## It grabs the second material because in loop it overwrites the first material applied to surface 0
#func set_material_button_to_default_material() -> void:
	#if debug: print("reset to default material1")
	##await get_tree().process_frame # Time for current_scene_path to be available
	#
	#var default_material: BaseMaterial3D = await get_default_material()
	#set_surface_materials(current_scene_preview, current_scene_path)
	#
	##if current_scene_path and material_lookup.keys().has(current_scene_path):
		##if debug: print("material_lookup[current_scene_path]: ", material_lookup[current_scene_path])
		##var default_material: BaseMaterial3D = material_lookup[current_scene_path][current_selected_surface_index]
		##if debug: print("default_material: ", default_material)
		##update_materials_mesh_instance_3d(default_material)
#
#
#
			### Update the index to match the default materials index in the materials_3d_array
			### FIXME Breaks for newly imported collections must re load all .tres or add new after okay doing that after import re check for .tres
	##favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
	#current_material_index = materials_3d_array.find(default_material)
	#material_3d_number.set_text(str(current_material_index))
	#do_material_favorite_check()
	##favorite_material_button.self_modulate = Color(1.0, 0, 0, 1.0)


func get_default_material() -> BaseMaterial3D:
	var default_material: BaseMaterial3D
	#await get_tree().process_frame # Time for current_scene_path to be available

	if current_scene_path and material_lookup.keys().has(current_scene_path):
		if debug: print("material_lookup[current_scene_path]: ", material_lookup[current_scene_path])
		default_material = material_lookup[current_scene_path][current_selected_surface_index]
	return default_material





func get_current_material() -> BaseMaterial3D:
	var current_material: BaseMaterial3D
	
	current_material = materials_3d_array[current_material_index]
	return current_material



#func _on_default_material_button_pressed() -> void:
	#material_3d_number.set_text(str(current_material_index))
	#if debug: print("reset to default material1")
	#await get_tree().process_frame # Time for current_scene_path to be available
	#if current_scene_path:
		#for material: StandardMaterial3D in material_lookup.keys():
			#if material_lookup[material].has(current_scene_path):
				##current_material_index = materials_3d_array.find(material)
				#
				#update_material_button_mesh_instance_3d(0, material)
				#if debug: print("reset to default material2")
#
				## Update the index to match the default materials index in the materials_3d_array
				## FIXME Breaks for newly imported collections must re load all .tres or add new after okay doing that after import re check for .tres
				#current_material_index = materials_3d_array.find(material)

#
## FIXME Defualt for some material is wrong or shows two. FIXME THIS IS BECAUSE SOME MESH HAVE MULTIPLE MATERIALS PROBLEM IS THAT MY SETUP IS APPLYING SINGLE MATERIAL TO ALL PARTS. HOW TO FIX?
## TODO set label 
## TODO set toggled on to blue star
## FIXME MYABE FLIP BEHAVIOR WHERE BLUE STAR HOLDS TO A TEXTURE? IN NONE FAVORITE STATE WILL WHITE WHEN DEFAULT AND CAN BE RESET WITH RIGHT CLICK ALL OTHERS NON-FAVORITE?
## WHAT ABOUT QUICK SETTING BLUE LOCKED TO TEXTURE BUTTON?




#
## CAUTION NOTE Not used replaced by func _on_favorite_material_button_toggled(toggled_on: bool) -> void:
#func _on_default_material_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#hold_current_material = true
		#held_current_material_index = current_material_index
		##
		##if debug: print("current_material_index: ", current_material_index)
		###set_default_material = true
		###await get_tree().process_frame # Time for current_scene_path to be available
		###if current_scene_path:
			###for material: StandardMaterial3D in material_lookup.keys():
				###if material_lookup[material].has(current_scene_path):
					###update_material_button_mesh_instance_3d(0, material)
					###current_material_index = materials_3d_array.find(material)
#
		#favorite_material_button.set_texture_normal(get_theme_icon("Favorites", "EditorIcons"))
		#favorite_material_button.self_modulate = get_accent_color()
		##
	#else:
		#hold_current_material = false
		#set_material_button_to_default_material()
		###set_default_material = false
		##favorite_material_button.set_texture_normal(get_theme_icon("NonFavorite", "EditorIcons"))
#









var current_selected_surface_index: int = 0

## Change selected surface when button pressed and update selected surface index
func _on_material_button_surface_selection_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		current_selected_surface_index -= 1
	else:
		current_selected_surface_index += 1

	# Wrap around if needed (ensure index stays within bounds)
	if current_selected_surface_index < 0:
		current_selected_surface_index = material_lookup[current_scene_path].size() - 1
	elif current_selected_surface_index >= material_lookup[current_scene_path].size():
		current_selected_surface_index = 0

	material_button_surface_selection.set_text(str(current_selected_surface_index))
	# if set default:
	#	set_material_button_to_default_material()
	#set_material_button_to_default_material()
	# Get the current scene_preview and change its material to the selected one
	emit_signal("get_current_scene_preview")
	set_surface_materials(current_scene_preview, current_scene_path)


func do_material_favorite_check() -> void:
	if favorite_materials_index_array.has(current_material_index):
		favorite_material_button.self_modulate = Color(1.0, 0.0, 0.0, 1.0)
	else:
		favorite_material_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)



# FIXME this can just be an int lookup of materials_3d_array
var favorite_materials_index_array: Array[int] = []

func _on_favorite_material_button_pressed() -> void:
	#materials_3d_array[current_material_index] # will give the material
	if favorite_materials_index_array.has(current_material_index):
		favorite_materials_index_array.erase(current_material_index)
		if debug: print("change heart to white")
		favorite_material_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		if debug: print("change heart to red")
		favorite_material_button.self_modulate = Color(1.0, 0.0, 0.0, 1.0)
		favorite_materials_index_array.append(current_material_index)



var cycle_material_favorites: bool = false

func _on_enable_favorites_cycle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		cycle_material_favorites = true
		if debug: print("turn dot red")
		enable_favorites_cycle_button.self_modulate = Color(1.0, 0.0, 0.0, 1.0)
	else:
		cycle_material_favorites = false
		enable_favorites_cycle_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		if debug: print("turn dot white")









enum Physics_Body_Type_2D {
	STATICBODY2D,
	RIGIDBODY2D,
	CHARACTERBODY2D
}


func toggle_physics_body_type_2d():
	match next_type_2d:
		Physics_Body_Type_2D.STATICBODY2D:
			change_body_type_2d_button.set_button_icon(get_theme_icon(&"StaticBody2D", &"EditorIcons"))
			change_body_type_2d_button.tooltip_text = "StaticBody2D"
			next_type_2d = Physics_Body_Type_2D.RIGIDBODY2D
		Physics_Body_Type_2D.RIGIDBODY2D:
			change_body_type_2d_button.set_button_icon(get_theme_icon(&"RigidBody2D", &"EditorIcons"))
			change_body_type_2d_button.tooltip_text = "RigidBody2D"
			next_type_2d = Physics_Body_Type_2D.CHARACTERBODY2D
		Physics_Body_Type_2D.CHARACTERBODY2D:
			change_body_type_2d_button.set_button_icon(get_theme_icon(&"CharacterBody2D", &"EditorIcons"))
			change_body_type_2d_button.tooltip_text = "CharacterBody2D"
			next_type_2d = Physics_Body_Type_2D.STATICBODY2D


var current_type_2d: String = "" 
var next_type_2d: Physics_Body_Type_2D = Physics_Body_Type_2D.STATICBODY2D


func _on_change_body_type_2d_button_pressed() -> void:
	current_type_2d = Physics_Body_Type_2D.find_key(next_type_2d)
	toggle_physics_body_type_2d()
	emit_signal("change_physics_body_type_2d", current_type_2d)





























#enum Collision_3D_State {
	#NO_COLLISION,
	#SPHERESHAPE3D,
	#BOXSHAPE3D,
	#CAPSULESHAPE3D,
	#CYLINDERSHAPE3D,
	#SIMPLIFIED_CONVEX,
	#SINGLE_CONVEX,
	#MULTI_CONVEX,
	#TRIMESH
#}
#
#
##const MULTI_CONVEX = preload("res://addons/scene_snap/icons/multi_convex.svg")
##const SIMPLIFIED_CONVEX = preload("res://addons/scene_snap/icons/simplified_convex.svg")
##const SINGLE_CONVEX = preload("res://addons/scene_snap/icons/single_convex.svg")
##const TRIMESH = preload("res://addons/scene_snap/icons/trimesh.svg")
##const NO_COLLISION = preload("res://addons/scene_snap/icons/no_collision.svg")
#
#func toggle_collision_state():
	#match next_state:
		#Collision_3D_State.NO_COLLISION:
			#change_collision_shape_3d_button.set_button_icon(NO_COLLISION)
			#change_collision_shape_3d_button.tooltip_text = "Place Scene With No Collisions"
			#next_state = Collision_3D_State.SPHERESHAPE3D
		#Collision_3D_State.SPHERESHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"SphereShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "SphereShape3D The fastest shape to check collisions against"
			#next_state = Collision_3D_State.BOXSHAPE3D
		#Collision_3D_State.BOXSHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"BoxShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "BoxShape3D"
			#next_state = Collision_3D_State.CAPSULESHAPE3D
		#Collision_3D_State.CAPSULESHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"CapsuleShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "CapsuleShape3D"
			#next_state = Collision_3D_State.CYLINDERSHAPE3D
		#Collision_3D_State.CYLINDERSHAPE3D:
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"CylinderShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "CylinderShape3D Note: CapsuleShape3D or BoxShape3D is recommended due to known bugs with cylinder collision shapes."
			#next_state = Collision_3D_State.SIMPLIFIED_CONVEX
		#Collision_3D_State.SIMPLIFIED_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(SIMPLIFIED_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Simplified (ConvexPolygonShape3D)"
			#next_state = Collision_3D_State.SINGLE_CONVEX
		#Collision_3D_State.SINGLE_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(SINGLE_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Single (ConvexPolygonShape3D)"
			#next_state = Collision_3D_State.MULTI_CONVEX
		#Collision_3D_State.MULTI_CONVEX:
			#change_collision_shape_3d_button.set_button_icon(MULTI_CONVEX_POLYGON_SHAPE_3D)
			#change_collision_shape_3d_button.tooltip_text = "Multiple (ConvexPolygonShape3Ds)"
			#next_state = Collision_3D_State.TRIMESH
		#Collision_3D_State.TRIMESH:
			##change_collision_shape_3d_button.set_button_icon(TRIMESH)
			#change_collision_shape_3d_button.set_button_icon(get_theme_icon(&"ConcavePolygonShape3D", &"EditorIcons"))
			#change_collision_shape_3d_button.tooltip_text = "Trimesh (ConcavePolygonShape3D) NOTE: Intended to be used primarily with StaticBody3D level geometry"
			#next_state = Collision_3D_State.NO_COLLISION
#
#
#var current_state: String = "" 
#var next_state: Collision_3D_State = Collision_3D_State.TRIMESH
#
#
#
#
#
#func _on_change_collision_shape_2d_button_pressed() -> void:
	#current_state = Collision_3D_State.find_key(next_state)
	##if debug: print("current_state: ", current_state)
	#toggle_collision_state()
	##if debug: print("current_state: ", current_state)
	##scene_snap_settings.set_collision_state(Collision_3D_State.find_key(current_state))
	##scene_snap_settings.currently_selected_collision_state = Collision_3D_State.find_key(current_state)
	#emit_signal("change_collision_shape_3d", current_state)
	#
	##if debug: print("scene_snap_settings.currently_selected_collision_state: ", scene_snap_settings.currently_selected_collision_state)
	#if debug: print("change collsionshape3d")
	#pass # Replace with function body.


enum Collision_2D_State {
	NO_COLLISION,
	CIRCLESHAPE2D,
	RECTANGLESHAPE2D,
	CAPSULESHAPE2D
}


func toggle_2d_collision_state():
	match next_2d_collision_state:
		Collision_2D_State.NO_COLLISION:
			change_collision_shape_2d_button.set_button_icon(NO_COLLISION)
			change_collision_shape_2d_button.tooltip_text = "Place Scene With No Collisions"
			next_2d_collision_state = Collision_2D_State.CIRCLESHAPE2D
		Collision_2D_State.CIRCLESHAPE2D:
			change_collision_shape_2d_button.set_button_icon(get_theme_icon(&"CircleShape2D", &"EditorIcons"))
			change_collision_shape_2d_button.tooltip_text = "CircleShape2D The fastest shape to check collisions against"
			next_2d_collision_state = Collision_2D_State.RECTANGLESHAPE2D
		Collision_2D_State.RECTANGLESHAPE2D:
			change_collision_shape_2d_button.set_button_icon(get_theme_icon(&"RectangleShape2D", &"EditorIcons"))
			change_collision_shape_2d_button.tooltip_text = "RectangleShape2D"
			next_2d_collision_state = Collision_2D_State.CAPSULESHAPE2D
		Collision_2D_State.CAPSULESHAPE2D:
			change_collision_shape_2d_button.set_button_icon(get_theme_icon(&"CapsuleShape2D", &"EditorIcons"))
			change_collision_shape_2d_button.tooltip_text = "CapsuleShape2D"
			next_2d_collision_state = Collision_2D_State.NO_COLLISION


var current_2d_collision_state: String = "" 
var next_2d_collision_state: Collision_2D_State = Collision_2D_State.CIRCLESHAPE2D





func _on_change_collision_shape_2d_button_pressed() -> void:
	current_2d_collision_state = Collision_2D_State.find_key(next_2d_collision_state)
	#if debug: print("current_state: ", current_state)
	toggle_2d_collision_state()
	#if debug: print("current_state: ", current_state)
	#scene_snap_settings.set_collision_state(Collision_3D_State.find_key(current_state))
	#scene_snap_settings.currently_selected_collision_state = Collision_3D_State.find_key(current_state)
	emit_signal("change_collision_shape_2d", current_2d_collision_state)
	
	#if debug: print("scene_snap_settings.currently_selected_collision_state: ", scene_snap_settings.currently_selected_collision_state)
	if debug: print("change collsionshape2d")
	pass # Replace with function body.

var scene_instantiate_enabled: bool = false

func _on_scene_creation_toggle_button_pressed() -> void:
	if debug: print("scene_instantiate_enabled1: ", scene_instantiate_enabled)
	scene_instantiate_enabled = not scene_instantiate_enabled
	if debug: print("scene_instantiate_enabled2: ", scene_instantiate_enabled)
	if not scene_instantiate_enabled:
		scene_state_number.set_text("1")

		scene_creation_toggle_button.set("theme_override_colors/icon_hover_color", Color(1.00, 0.00, 0.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_focus_color", Color(1.00, 0.00, 0.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_pressed_color", Color(1.00, 0.00, 0.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_normal_color", Color(1.00, 0.00, 0.00, 1.00)) 

		scene_creation_toggle_button.set_tooltip_text("ACTIVE: Make local. \
		\n\u2022 NOTE: Collision shapes will be shared between all root nodes 'Instantiated as scene' or 'Make local' unless \
		\n'Make Sub-Resources Unique' or 'Make Unique' under the collision shape is selected within the inspector panel.")
		emit_signal("instantiate_as_scene", false)

	else:
		scene_state_number.set_text("0")


		scene_creation_toggle_button.set("theme_override_colors/icon_hover_color", Color(1.00, 1.00, 1.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_focus_color", Color(1.00, 1.00, 1.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_pressed_color", Color(1.00, 1.00, 1.00, 1.00))
		scene_creation_toggle_button.set("theme_override_colors/icon_normal_color", Color(1.00, 1.00, 1.00, 1.00))



		#scene_creation_toggle_button.theme_override_colors.icon_normal_color = Color(0.44, 0.73, 0.98, 1.00)
		#scene_creation_toggle_button.set_self_modulate(Color(0.44, 0.73, 0.98, 1.00))
		scene_creation_toggle_button.set_tooltip_text("ACTIVE: Instantiate as scene. \
		\n\u2022 NOTE: Collision shapes will be shared between all root nodes 'Instantiated as scene' or 'Make local' unless \
		\n'Make Sub-Resources Unique' or 'Make Unique' under the collision shape is selected within the inspector panel.")
		emit_signal("instantiate_as_scene", true)




#func _on_scene_creation_toggle_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#scene_state_number.set_text("0")
		#scene_creation_toggle_button.set_tooltip_text("ACTIVE: Instantiate as scene. \
		#\n\u2022 NOTE: Collision shapes will be shared between all root nodes 'Instantiated as scene' or 'Make local' unless \
		#\n'Make Sub-Resources Unique' or 'Make Unique' under the collision shape is selected within the inspector panel.")
		#
		#
		##scene_creation_toggle_button.set_tooltip_text("[b]Section 1[/b]\nThis is the first section.\n\n" +
				   ##"\u2500\u2500\u2500\u2500\u2500\u2500\n\n" +
				   ##"[b]Section 2[/b]\nThis is the second section.")
#
#
#
#
		#
		#
		#emit_signal("instantiate_as_scene", true)
		## TODO CHANGE FLAG to be able to Instantiate as scene
	#else:
		#scene_state_number.set_text("1")
		#scene_creation_toggle_button.set_tooltip_text("ACTIVE: Make local. \
		#\n\u2022 NOTE: Collision shapes will be shared between all root nodes 'Instantiated as scene' or 'Make local' unless \
		#\n'Make Sub-Resources Unique' or 'Make Unique' under the collision shape is selected within the inspector panel.")
		#emit_signal("instantiate_as_scene", false)


func _on_gen_lod_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		gen_lod_button.set_tooltip_text("Create LODs")
		# TODO CHANGE FLAG to be able to create lods
	else:
		gen_lod_button.set_tooltip_text("Do not create LODs")


var collision_toggled_on: bool = true

# NOTE: CollisionShape3D must also be set to visible under 3DViewport top toolbar View -> Gizmos -> CollisionShape3D
func _on_collision_visibility_toggle_button_toggled(toggled_on: bool) -> void:

	if toggled_on:
		collision_visibility_toggle_button.set_texture_normal(get_theme_icon("GuiVisibilityVisible", "EditorIcons"))
		collision_visibility_toggle_button.set_tooltip_text("ACTIVE: Show collisions with scene preview. \
		\n\u2022 NOTE: Generation of the scene preview will be slower when active, especially for Multiple Convex collisions generation. \
		\n\u2022 NOTE: CollisionShape3D must also be set to visible under 3DViewport top toolbar View -> Gizmos -> CollisionShape3D.")
		collision_toggled_on = true
		emit_signal("visible_scene_preview_collisions", true)
	else:
		collision_visibility_toggle_button.set_texture_normal(get_theme_icon("GuiVisibilityHidden", "EditorIcons"))
		collision_visibility_toggle_button.set_tooltip_text("NOT ACTIVE: Show collisions with scene preview. \
		\n\u2022 NOTE: Generation of the scene preview will be slower when active, especially for Multiple Convex collisions generation. \
		\n\u2022 NOTE: CollisionShape3D must also be set to visible under 3DViewport top toolbar View -> Gizmos -> CollisionShape3D.")
		collision_toggled_on = false
		emit_signal("visible_scene_preview_collisions", false)



func get_accent_color() -> Color:
	var theme_accent_color: Color
	if settings.has_setting("interface/theme/accent_color"):
		theme_accent_color = settings.get_setting("interface/theme/accent_color")
	return theme_accent_color


func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = for_text
	return label


func _on_enable_pinning_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		enable_pinning_toggle_button.set_texture_normal(get_theme_icon("PinPressed", "EditorIcons"))
		#enable_pinning_toggle_button.set_self_modulate(Color(0.44, 0.73, 0.98, 1.00))
		enable_pinning_toggle_button.set_self_modulate(get_accent_color())
		
		
		#enable_pinning_toggle_button.set_self_modulate(Color(0.14, 0.52, 0.86, 1.00))
		#enable_pinning_toggle_button.set_button_icon(get_theme_icon("PinPressed", "EditorIcons"))
		enable_pinning_toggle_button.set_tooltip_text("ACTIVE: Instantiate as child of pinned scene tree node.")
		emit_signal("enable_node_pinning", true)
	else:
		enable_pinning_toggle_button.set_self_modulate(Color(1, 1, 1, 1))
		enable_pinning_toggle_button.set_tooltip_text("NOT ACTIVE: Instantiate as child of pinned scene tree node.")
		emit_signal("enable_node_pinning", false)


func _on_unique_sub_resources_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		unique_sub_resources_toggle_button.set_self_modulate(Color(1, 0, 0, 1))
		unique_sub_resources_toggle_button.set_tooltip_text("ACTIVE: Make mesh material sub-resources unique. \
		\n\u2022 NOTE: Each instance will have an additional mesh material resource loaded into memory. \
		\n\u2022 NOTE: Collision shapes and other resources will not be duplicated and will remain shared.")
		emit_signal("make_resources_unique", true)

	else:
		unique_sub_resources_toggle_button.set_self_modulate(Color(1, 1, 1, 1))
		unique_sub_resources_toggle_button.set_tooltip_text("NOT ACTIVE: Make mesh material sub-resources unique. \
		\n\u2022 NOTE: Each instance will have an additional mesh material resource loaded into memory. \
		\n\u2022 NOTE: Collision shapes and other resources will not be duplicated and will remain shared.")
		emit_signal("make_resources_unique", false)



func _on_match_scale_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		#scene_preview. closest_object_scale
		emit_signal("match_target_scale", true)
		if debug: print("matching scale of object connecting to")
	else:
		emit_signal("match_target_scale", false)
		if debug: print("keeping own scale")


func _on_pin_panel_toggled(toggled_on: bool) -> void:
	if toggled_on:
		distraction_free_mode(true)
		##get_tree().get_root().transient = false
#
#
		#get_tree().get_root().set_transparent_background(true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)




		#get_tree().get_root().set_flag(Window.FLAG_BORDERLESS, true)

		##get_tree().get_root().transient = false
		##if debug: print("class: ", get_tree().get_root().get_class())
		##get_tree().get_root().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
		#pin_panel.set_texture_normal(get_theme_icon("PinPressed", "EditorIcons"))
		#pin_panel.set_self_modulate(Color(0.44, 0.73, 0.98, 1.00))
		##enable_pinning_toggle_button.set_self_modulate(Color(0.14, 0.52, 0.86, 1.00))
		##enable_pinning_toggle_button.set_button_icon(get_theme_icon("PinPressed", "EditorIcons"))
		#pin_panel.set_tooltip_text("ACTIVE: Instantiate as child of pinned scene tree node.")

	else:
		distraction_free_mode(false)
		##get_tree().get_root().set_flag(Window.FLAG_ALWAYS_ON_TOP, false)
		#pin_panel.set_self_modulate(Color(1.00, 1.00, 1.00, 1.00))
		#pin_panel.set_tooltip_text("NOT ACTIVE: Instantiate as child of pinned scene tree node.")


func distraction_free_mode(toggled_on: bool) -> void:
	if toggled_on:
		if debug: print(get_tree().get_root().get_class())
		
		#var window: Window = get_tree().get_root()
	#get_tree().get_root().set_flag(Window.FLAG_BORDERLESS, true)
	#popup_window_instance.set_transparent_background(true)
		#window.set_flag(Window.FLAG_TRANSPARENT, true)
	#popup_window_instance.set_flag(Window.FLAG_MOUSE_PASSTHROUGH, true)
	#popup_window_instance.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	#popup_window_instance.set_flag(Window.FLAG_BORDERLESS, true)
		
		
		#get_tree().get_root().set_transparent_background(true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, 0)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)
		# TODO ADD button that becomes visible to exit mode
		color_rect.hide()
		#v_box_container.hide()
		for main_tab: Control in main_tab_container.get_children():
			main_tab.h_box_container.hide()
			match main_tab.name:
				"Global Collections", "Shared Collections":
					main_tab.sub_tab_container.set_self_modulate(Color(1.00, 1.00, 1.00, 0.00))

			
		emit_signal("enable_distraction_free_mode", true)
			
	else:
		
		color_rect.show()
		#v_box_container.show()
		for main_tab: Control in main_tab_container.get_children():
			main_tab.h_box_container.show()
			match main_tab.name:
				"Global Collections", "Shared Collections":
					main_tab.sub_tab_container.set_self_modulate(Color(1.00, 1.00, 1.00, 1.00))
		emit_signal("enable_distraction_free_mode", false)

# FIXME This is also captured through main_container.tab_changed.connect(selected_main_tab_changed) in scene_snap_plugin.gd
func _on_main_tab_container_tab_changed(tab: int) -> void:
	main_tab_container.get_current_tab_control().call_deferred("get_scene_buttons")
	
	#if debug: print("main tab changed: ")
	pass # Replace with function body.


# USE only for single mesh centering
#region center mesh code NOT USED
func run_mesh_centering() -> void:
	for child in get_children():
		# Ensure the child is a MeshInstance3D before proceeding
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		if mesh_instance != null:
			var mesh: ArrayMesh = mesh_instance.mesh
			if mesh is ArrayMesh:
				var surface_count = mesh.get_surface_count()
				if debug: print("Surface count: ", surface_count)  # Debug print to verify the surface count
				for surface_index in range(surface_count):
					var tool = MeshDataTool.new()
					tool.create_from_surface(mesh, surface_index)

					# Variables to find the bottom center and average XZ center
					var min_y: float = INF
					var sum_x = 0.0
					var sum_z = 0.0
					var vertex_count = tool.get_vertex_count()

					# Loop through vertices to find the lowest Y and the average XZ
					for i in range(vertex_count):
						var vertex: Vector3 = tool.get_vertex(i)
						if vertex.y < min_y:
							min_y = vertex.y
						sum_x += vertex.x
						sum_z += vertex.z

					# Calculate the average X and Z
					var avg_x: float = sum_x / vertex_count
					var avg_z: float = sum_z / vertex_count

					# Calculate the offset needed to center the mesh at the bottom center
					var offset = Vector3(-avg_x, -min_y, -avg_z)

					# Shift all vertices by this offset
					for i in range(vertex_count):
						var vertex: Vector3 = tool.get_vertex(i)
						vertex += offset
						tool.set_vertex(i, vertex)

					# Apply the changes back to the mesh
					tool.commit_to_surface(mesh, surface_index)

					# Update the mesh instance's transform to reflect the change, if needed
					# mesh_instance.transform.origin += offset  # Uncomment if you want to adjust the MeshInstance3D's position
#endregion




func _exit_tree() -> void:
	if cleanup_task_id1:
		WorkerThreadPool.wait_for_group_task_completion(task_id1)
		if cleanup_task_id2:
			WorkerThreadPool.wait_for_group_task_completion(task_id2)
	
	#for scene_view: Button in scene_view_reference:
		#scene_view.free()
	
	
	#if ran_task_id2:
		#WorkerThreadPool.wait_for_group_task_completion(task_id2)
		#if run_gltf_image_hash_check: # NOTE: Was already cleaned up before starting task_id2
			#WorkerThreadPool.wait_for_group_task_completion(task_id)
		#else:
			#WorkerThreadPool.wait_for_group_task_completion(task_id)
			#WorkerThreadPool.wait_for_group_task_completion(task_id2)
