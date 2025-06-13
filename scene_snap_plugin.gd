@tool
extends EditorPlugin

var debug = preload("uid://dfb5uhllrlnbf").new().run()


#var print_enabled: bool = false
var scenedock_editor: Node
var scenedock_tree: Tree




# NOTE left off set_uid of imported files to uid of originals and removing import file
#signal setup_after_autoload

signal all_scenes_loaded_re_emit
signal enter_tree_complete
signal open_popup_complete

# TEST MULTI THREADING
signal task_completed(result)

#const RUST = preload("res://addons/scene_snap/rust_gdextension/rust.gdextension")

# SnapManager
#var scene_preview: String = "": get = get_scene_preview, set = set_scene_preview
@onready var res_dir = DirAccess.open("res://")
@onready var user_dir = DirAccess.open("user://")
#@onready var shared_collections_path: String = "user://shared_collections/scenes/"
#@onready var project_scenes_path: String = "res://scenes/"
@onready var project_scenes_path: String = "res://collections/"
#@onready var project_textures_path: String = "res://textures/"

# TODO Why did I choose this file path structure? Was is so that imported into project matched path from scenes, which I later switched to collections?
# The first shared_collections and global_collections folders allow for having scenes and thumbnail_cache folders for each.
# the Shared Collections and Global Collections names help to match the main tab names exactly.
var file_paths: Array[String] = ["global_collections/scenes/Global Collections", "shared_collections/scenes/Shared Collections"]
#"global_collections/thumbnail_cache_global/Global Collections",
#"shared_collections/thumbnail_cache_shared/Shared Collections"]

# Scene Viewer needs to be load otherwise get error below on intial addon import:
# scene/resources/resource_format_text.cpp:284 - Parse Error: Busy. [Resource file res://addons/scene_snap/plugin_scenes/scene_viewer.tscn:29]
# Failed loading resource: res://addons/scene_snap/plugin_scenes/scene_viewer.tscn. Make sure resources have been imported by opening the project in the editor at least once.
var SCENE_VIEWER = load("res://addons/scene_snap/plugin_scenes/scene_viewer.tscn")
#const SCENE_VIEWER = preload("res://addons/scene_snap/plugin_scenes/scene_viewer.tscn")
const POPUP_WINDOW = preload("res://addons/scene_snap/plugin_scenes/popup_window.tscn")
const MAIN_FAVORITES_TAB = preload("res://addons/scene_snap/plugin_scenes/main_favorites_tab.tscn")

# SnapManager Viewer const
#const SnapManagerGraph = preload("res://addons/scene_snap/scripts/snap_flow_manager_graph.gd")

#const SNAP_MANAGER_GRAPH = preload("res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn")

#const SNAP_MANAGER_GRAPH = preload("res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn")

#const SNAP_MANAGER_GRAPH_ORIGINAL = preload("res://addons/scene_snap/plugin_scenes/snap_manager_graph_original.tscn")
#const SNAP_MANAGER_GRAPH_COPY = preload("res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn")

#const SNAP_MANAGER_GRAPH = preload("res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn")


const SNAP_MENU_PANEL = preload("res://addons/scene_snap/plugin_scenes/snap_menu_panel.tscn")


const SNAP_NODE_3D = preload("res://addons/scene_snap/snap_manager/scenes/snap_node_3d.tscn")
const SnapNode3d = preload("res://addons/scene_snap/snap_manager/scripts/snap_node_3d.gd")
const PLANE_3D = preload("res://addons/scene_snap/snap_manager/scenes/plane_3d.tscn")
const SNAP_FLUSH = preload("res://addons/scene_snap/snap_manager/scenes/snap_flush.tscn")
const SnapFlush = preload("res://addons/scene_snap/snap_manager/scripts/snap_flush.gd")

#var graph_scene_path: String = "res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn"
const graph_scene_path: String = "res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn"
#const ExtendFbxDocument = preload("res://addons/scene_snap/extend_fbx_document.gd")


# Scene Viewer variables
@export var number: int


var scene_viewer_panel_instance : Control
var snap_manager_graph_instance: GraphEdit = null

var panel_window_position: Vector2
var popup_window_instance : Window

# SnapManager variables
var ray_cast_3d
#var ray_cast_3d
var ray_cast_3d_x_offset: float
var ray_cast_3d_y_offset: float
var ray_cast_3d_z_offset: float

var switch_mode: bool = false
# NOTE Change later to actual file
var selected_scene_file: bool = true
var instantiate_scene: bool = true
#var aabb: AABB
var first_click: bool = true
var rotation_value: int = 15
var rotation_15: bool = true
var scale_reduction_value: int = 5
var scale_5: bool = true
#var selected_nodes: Array[Node] = []
var align_scene_axis: bool = false
var selected_node: Node3D = null
var selected_nodes: Array[Node] = []

var editor_camera3d_position_lock = Vector3.ZERO
var key_e_not_pressed: bool = true
var raycast_result

var editor_viewport_3d_active: bool = false
var scene_preview_3d_active: bool = false

# Set the default snap charateristics to snapping to normal.round()
var snap_normal_round: bool = true

var scene_preview: Node = null
var reference_collision_scene_child: CollisionShape3D = null
#var scene_preview_mesh: MeshInstance3D = null
#var scene_preview_mesh: StaticBody3D = null
var scene_preview_mesh: Node3D = null

var snap_on_rotate: bool = false
var snap_flush_front: bool = false
## TEMP DISABLED
#var snap_flush_scene: Node3D

# This will store the previously selected nodes
var last_selected_nodes: Array[Node] = []

var multi_select_enabled: bool = false
#var set_snap_ray_cast_3d: bool = true

var mesh_instance_3d: MeshInstance3D
var collision_point: Vector3


# Snap Flush Variables
var snap_down: bool = false
var snap_flush_bottom: bool = false
var snap_flush_top: bool = false
var snap_flush_left: bool = false
var snap_flush_right: bool = false


# Snap Flush And Center Pipe
var snap_flush_center_pipe: bool = false
var last_vector_normal: Vector3
var create_center_snap_ray: bool = false
var process_ray: bool = false
var center_ray: Node3D
var initialize_center_ray: bool = false
var pipe_center_snap_last_position: Vector3
var door: bool = true
var wall: bool = true
var center_pipe: bool = false
var from: Vector3
var to: Vector3

# Scene Preview Variables
var last_scene_preview_pos: Vector3
var last_scene_preview: Node
var scene_number: int = 0

var update_visible_scenes: bool = true
# Flags
var quick_scroll_enabled: bool = false
var allow_pressed: bool = true
var object_rotated: bool = false
var object_scaled: bool =  false

var mesh_hit: bool = false
var collision_hit: bool = false
var snap_front_flush_enabled: bool = false
var scene_preview_snap: bool = false
var current_rotation_degrees: float
var get_current_rotation: bool = true
var create_rotation_node: bool = true
var new_node_3d: Node3D

var new_editorplugin = EditorPlugin.new()
var last_normal: Vector3
var editor_viewport_count: int = 4
var initialize_scene_preview: bool = true

var new_raycast_3d: RayCast3D
var preview_offset: Vector3
var rotated_global_transform: Basis
var last_scene_path: String = ""
var current_visible_buttons: Array[Node] = []
var connect_scene_view_button_signals: bool = true
var panel_floating_on_start: bool
var show_favorites_tab_on_startup: bool
#var instantiate_panel: bool = false

var settings

var current_collision_3d_state: String# = "NO_COLLISION"
var current_body_2d_type: String# = "StaticBody2D"
var current_body_3d_type: String# = "StaticBody3D"
var create_as_scene: bool = true
var scene_preview_collisions: bool = true
var scene_preview_collisions_last_state: bool
var enable_collisions: bool = true
var node_pinning_enabled: bool = true

var make_unique: bool = false

var mouse_over_scene_tree: bool = false
var pinned_tree_item: TreeItem = null
var pinned_node: Node = null
var tree_items: Array[TreeItem]

var save_path: String = ""
var theme_accent_color: Color
var selected_scene_view_button: Button
var scene_link_enabled: bool = false
var current_main_tab: Control
var current_sub_tab: Control
#var main_container: TabContainer
#var skip_on_start: bool = true

#var scene_snap_settings_instance: Node

#var currently_selected_collision_state: int = 0


## Handler for when a scene is saved
#func _on_scene_saved(filepath: String):
	#
	## Find and remove matching scene button and png from filesystem
	#
	#
	#
	#var new_scene_view: Button = null
	#var loaded_scene: PackedScene = load(filepath)
	#scene_viewer_panel_instance.create_scene_buttons(loaded_scene, filepath, scene_viewer_panel_instance.new_main_project_scenes_tab, new_scene_view, false)
#
	#if debug: print("thumb_cache: ", scene_viewer_panel_instance.get_thumbnail_cache_path(".tscn", filepath))
	##if filepath == scene_to_watch:
		## The specific scene was saved
	#if debug: print("The scene was saved: ", filepath)
		## Perform any additional actions you want when the scene is saved



#var required_scenes_dict: Dictionary = {}
#
#func store_required_scenes(filepath: String):
	## Get file_path to all scenes that are dependencies of other scenes in project
	#var required_scenes_array: Array[String] = []
	#for dep in ResourceLoader.get_dependencies(filepath):
		#var dep_path: String = dep.get_slice("::", 2)
#
		#if not required_scenes_array.has(dep_path):
			#required_scenes_array.append(dep_path)
#
	#required_scenes_dict[filepath] = required_scenes_array
	#if debug: print("required_scenes_dict: ", required_scenes_dict)


#var graph_edit_button: GraphEdit
var snap_panel_menu: Control = null
var snap_flow_manager_graph: GraphEdit = null

#var snap_manager_graph_connections: Array[Dictionary] = []

var allow_pin_removal: bool = true

var save_to_original_scene_path: bool = true


#var graph_edit_scene_path_original: String = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_original.tscn"
##var graph_edit_scene_path_copy: String = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn"
#
#var last_graph_edit_save_path: String = ""

#func open_graph_editor(open: bool) -> void:
	#if open: # Open the scene and instantiate it
		#snap_flow_manager_graph = ResourceLoader.load("res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn","",ResourceLoader.CACHE_MODE_IGNORE_DEEP).instantiate()
		##snap_flow_manager_graph = load("res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn").instantiate()
		#if debug: print("Opening path: ", snap_flow_manager_graph.get_scene_file_path())
		#
		## Optionally connect signals here if needed
		#add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
	#else: # If we close the editor and need to remove the scene
		## First, remove the scene file from the filesystem
		#var dir = DirAccess.open("res://addons/scene_snap/plugin_scenes/")
		#if dir:
			#var error = dir.remove("snap_manager_graph_copy.tscn")
			#if error == OK:
				#if debug: print("res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn REMOVED")
			#else:
				#if debug: print("Failed to remove the file.")
		#
		## Now, remove the scene from the container and free the memory
		#if snap_flow_manager_graph:
			#remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
			#snap_flow_manager_graph.free()
			#snap_flow_manager_graph = null  # Make sure no other references exist
			#
		## Scan the filesystem to update the editor
		#var editor_filesystem = EditorInterface.get_resource_filesystem()
		#if !editor_filesystem.is_scanning():
			#editor_filesystem.scan()  # This refreshes the editor's file view
		#
		## Optionally, you can trigger a refresh manually by reloading the editor interface, 
		## but that is generally not needed if the scan method works.


#var snap_connections: Array[Dictionary] = []


const SnapManagerData = preload("res://addons/scene_snap/scripts/snap_flow_manager_data.gd")
#var user_favorites: Favorites = Favorites.new()
var scene_data_cache: SceneDataCache = SceneDataCache.new()




var node_indices: Dictionary = {}
#var port_tag_text_dict: Dictionary[int, Array] = {}
var port_tag_text_dict: Dictionary[int, String] = {}
var grouped_tags: Array[String] = []
var single_tag: String = ""
var closest_object_scale: Vector3 = Vector3.ZERO
var match_scale: bool = true

var task_id_number: int = 0
var mutex: Mutex = Mutex.new()

## Cache the tags and their relationship to snap_flow_manager_graph.connections for quick lookup in the process()
# FIXME signal to update when connections changed and graphedit is open. 
func cache_snap_flow_manager_graph_tags() -> void:
	if debug: print("snap_flow_manager_graph.get_children(): ", snap_flow_manager_graph.get_children())
	for graphnode: Control in snap_flow_manager_graph.get_children():
		if debug: print("graphnode.name: ", graphnode.name)
		if graphnode.name == "_connection_layer" or graphnode is GraphFrame:
			continue
		var index: int = 0
		
		port_tag_text_dict = {}
		for child in graphnode.get_children():
			
			# FIXME Group some tags and keep individual ones seperate will want to change this to a flag
			#grouped_tags = []
			single_tag = ""
			
			if child.has_meta("tag_text"):

				#grouped_tags.append(child.get_meta("tag_text"))
				#port_tag_text_dict[index] = grouped_tags
				#node_indices[graphnode.name] = port_tag_text_dict
				
				
				single_tag = child.get_meta("tag_text")
				port_tag_text_dict[index] = single_tag
				node_indices[graphnode.name] = port_tag_text_dict
				index += 1
	if debug: print("node_indices: ", node_indices)
# FIXME LEFT OFF if debug: print("node_indices: ", node_indices) not printing

#func load_snap_flow_manager_graph() -> void:
	#snap_flow_manager_graph = load(graph_scene_path).instantiate()
	## Hide so does not pop in on start
	#snap_flow_manager_graph.hide()
	#snap_flow_manager_graph.get_child(0).hide()
	## Add child so have access to the scene_tree itself not just connections
	#add_child(snap_flow_manager_graph)
	#snap_flow_manager_graph.visible = false
	#cache_snap_flow_manager_graph_tags()
	#snap_flow_manager_graph.update_tag_cache.connect(cache_snap_flow_manager_graph_tags)








func _enter_tree() -> void:
	scene_data_cache = ResourceLoader.load("res://addons/scene_snap/resources/scene_data_cache.tres")
# Clear scene_data_cache before versioning
	#scene_data_cache.scene_favorites.clear()
	#scene_data_cache.scene_data.clear()
	#ResourceSaver.save(scene_data_cache)


	#var p: = PrintDebug.new()
	#if debug: print("debug.print_enabled: ", debug)
	#if debug: print("WALLLABALLA")

	#load("uid://dfb5uhllrlnbf")
## TEST MULTI THREADING
	## Connect the signal to a function that handles the results
	#self.task_completed.connect(_on_task_completed)
	#connect("task_completed", self, "_on_task_completed")


	
	# Create duplicate scene_data_cache so that original resource file can be written to
	#user_favorites = ResourceLoader.load("res://addons/scene_snap/resources/user_favorites.tres").duplicate(true)
	#scene_data_cache = ResourceLoader.load("res://addons/scene_snap/resources/scene_data_cache.tres")




	#var snap_manager_data = SnapManagerData.new()
	snap_panel_menu = SNAP_MENU_PANEL.instantiate()
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, snap_panel_menu)
	
	#var graph_scene_path: String = "res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn"
	# CAUTION: If snap_flow_manager_graph is not loaded properly and then saved by save_snap_manager_data() may lead to file curruption
	#snap_flow_manager_graph = ResourceLoader.load(graph_scene_path, "", ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	
	#call_deferred("load_snap_flow_manager_graph")
	snap_flow_manager_graph = load(graph_scene_path).instantiate()
	# Hide so does not pop in on start
	#snap_flow_manager_graph.hide()
	#snap_flow_manager_graph.get_child(0).hide()
	# Add child so have access to the scene_tree itself not just connections
	#add_child(snap_flow_manager_graph)
	#snap_flow_manager_graph.visible = false

	cache_snap_flow_manager_graph_tags()
	snap_flow_manager_graph.update_tag_cache.connect(cache_snap_flow_manager_graph_tags)
	
	# FIXME HACK Works but don't like it
	# TODO Find better way Maybe when SHIFT_Q?? add in then and then reparent when openned from panel NOTE Didn't work so maybe this is best
	# NOTE data not available from graphedit until after adding to tree
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
	
	#for graphnode in snap_flow_manager_graph.get_children():
		#var index: int = 0
		#for graphnode_child in graphnode:
			#index += 1
			
			
		#if debug: print("snap_flow_manager_graph child: ", graphnode)

	snap_panel_menu.open_graph_editor.connect(func(open: bool) -> void:
		if open: # Load the graph editor scene without caching to memory (I think you will not be able to write over original if not since it will be reference)

			if snap_flow_manager_graph == null:
				snap_flow_manager_graph = load(graph_scene_path).instantiate()
				cache_snap_flow_manager_graph_tags()
				snap_flow_manager_graph.update_tag_cache.connect(cache_snap_flow_manager_graph_tags)
				#snap_flow_manager_graph = ResourceLoader.load(graph_scene_path, "", ResourceLoader.CACHE_MODE_IGNORE).instantiate()
				# Connect signals.
				#snap_flow_manager_graph.save_snap_manager.connect(save_snap_manager_data.bind(graph_scene_path))

			add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)

		else: # On close save the graph scene, the connection data and remove snap_flow_manager_graph
			#save_snap_manager_data(snap_flow_manager_graph, snap_manager_data, graph_scene_path)
			save_snap_flow_manager_data()

			remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph))


# FIXME TODO NOTE left off going to graphedit script and saving scene anytime a change is made not just saving the updated connections so reuse code above




















			#var packed_scene = PackedScene.new()
			#var result = packed_scene.pack(snap_flow_manager_graph)
			#var error = ResourceSaver.save(packed_scene, "res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn")
			#if error != OK:
				#push_error("An error occurred while saving the scene to disk.")
			#else:
				#if debug: print("saved scene")

				
			#if result == OK:
				#var error = ResourceSaver.save(packed_scene, scene_path)
				##var error = ResourceSaver.save(packed_scene, "res://my_scene.tscn")
				#if error != OK:
					#push_error("An error occurred while saving the scene to disk.")
				#else:
					#if debug: print("saved scene")
					#emit_signal("graph_updated")
			
			
			
			#remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
			#snap_flow_manager_graph.queue_free())
	
	
	#snap_flow_manager_graph = SNAP_MANAGER_GRAPH.instantiate()
	#add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)

	## Initialize the thread pool
	#for i in range(23):  # Example: create 4 threads
		#var t = Thread.new()
		#thread_pool.append(t)
	## Get the editor's base control
	#var base_control = EditorInterface.get_base_control()
	## Get the editor title bar (the one with Scene Project Debug ...)
	#var editor_title_bar = base_control.find_child('*EditorTitleBar*', true, false)
	## Get the first PopupMenu (Scene)
	#var scene_popup = editor_title_bar.find_children("*", "PopupMenu", true, false)[0] as PopupMenu
	## Get the id of the first item (New Scene)
	#var id = scene_popup.get_item_id(0)
	## Emit the "id_pressed" signal
	#scene_popup.id_pressed.emit(id)



	var base_control = EditorInterface.get_base_control()

	# Get the Editor_Scene_Tabs and Monitor on tab_hovered signals to remove scene_preview
	var editor_scene_tabs = get_child_of_type(base_control, "EditorSceneTabs", true)
	var editor_scene_tabbar = get_child_of_type(editor_scene_tabs, "TabBar", true)
	editor_scene_tabbar.tab_hovered.connect(func(tab: int):
		scene_preview_3d_active = false
		remove_existing_scene_preview())

	var scenedock = get_child_of_type(base_control, "SceneTreeDock", true)
	scenedock_editor = get_child_of_type(scenedock, "SceneTreeEditor")
	scenedock_tree = get_child_of_type(scenedock_editor, "Tree")


	# Monitor mouse events for hovering over the Scene Tree
	scenedock_tree.mouse_entered.connect(_on_scenedock_tree_mouse_entered)
	scenedock_tree.mouse_exited.connect(_on_scenedock_tree_mouse_exited)
	#FIXME ALERT GETTING ERROR: core/object/object.cpp:1249 - Error calling from signal 'button_clicked' to callable: 'EditorPlugin(scene_snap_plugin.gd)::node_pinned': Cannot convert argument 1 from Object to Object.
	# WHEN CLICKING TO OPEN SCENE IN SCENE TREE NEED CHECK THAT BUTTON CLICKED IS PIN 
	scenedock_tree.button_clicked.connect(node_pinned)


	# NOT left off here getting when scene tab changes to clear visual_instances_data
	# also find out why below is reporting so many nodes added and removed
	scene_changed.connect(changed_to_new_scene)
	
	
	#EditorInterface.get_edited_scene_root().node_removed.connect(remove_global_tris)
	#get_tree().node_removed.connect(remove_global_tris)
	
	# FIXME Giving error Internal script error! Opcode: 0 (please report) for await not sure why 
	# maybe cause of engine crashing on saves and changes
	# Clear pinned node from scene_pinned_node dict if removed from scene tree
	get_tree().node_removed.connect(func(node: Node) -> void:
		# Create timer to delay until after scene_changed
		await get_tree().create_timer(1).timeout
		#if debug: print("allow_pin_removal: ", allow_pin_removal)
		if node == pinned_node and allow_pin_removal:
			# Remove pinned node from dictionary
			scene_pinned_node.erase(EditorInterface.get_edited_scene_root()))
			#if debug: print("node removed: ", node))
	#get_tree().node_added.connect(add_global_tris)


	
	#var current_item: TreeItem = scenedock_tree.get_selected()
	#while current_item != null:
		#if debug: print("select item now")
	#pin_node()
	#var current_item: TreeItem = scenedock_tree.get_selected()
#
	#var color: Color = Color(194, 67, 0, 255)
	#current_item.set_custom_bg_color(0, color)
	#current_item.add_button(0, FAVORITES_ICON)
	
	# Connect to the scene_saved signal
	#self.scene_saved.connect(store_required_scenes)
	#self.scene_saved.connect(_on_scene_saved)


	
	#var scene_path: String = "res://test.tscn"
	#for dep in ResourceLoader.get_dependencies(scene_path):
		#if debug: print(dep)
	#
	## Instance the scene and add it as a child
	#scene_snap_settings_instance = scene_snap_settings.instantiate()
	#add_child(scene_snap_settings_instance)
	#
	## Access exported variables
	#if debug: print("Setting 1:", scene_snap_settings_instance.setting1)
	#if debug: print("Setting 2:", scene_snap_settings_instance.setting2)






	#await get_tree().create_timer(5).timeout
	
	#var dep_uid: String = "uid://25e5riqybgvb"
	#ResourceUID.add_id(8576626692258089695, "res://collections/kenny_space_station_kit/textures/colormap.png")
	#if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
		#if debug: print("IT HAS IT WHY NOT WORKING!!")
	
	
	#if debug: print("This should be the very first thing to print")
	scene_viewer_panel_instance = SCENE_VIEWER.instantiate()
	await wait_ready(scene_viewer_panel_instance, "scene_viewer_panel_instance")
	#if debug: print("scene_viewer_panel_instance: ", scene_viewer_panel_instance)
	#if debug: print("user_favorites.scene_favorites: ", user_favorites.scene_favorites)
	# Works but error
	


	# Copy data stored in cache to script variables
	scene_viewer_panel_instance.scene_favorites = scene_data_cache.scene_favorites

	## Copy data stored in cache to script variables
	#scene_viewer_panel_instance.scene_favorites = user_favorites.scene_favorites






	#snap_manager_graph_instance = SNAP_MANAGER_GRAPH.instantiate()
	
	
	#instantiate_snap_manager_graph()
	
	#get_tree().get_root().add_child(snap_manager_graph_instance)



	#var new_doc = ExtendFbxDocument.new()

	#Engine
	#var error = Error("This is an error!")
	#push_error("Caught error: " + str(error))
	#set_print_error_messages(value)
	#Engine.set_print_error_messages(false)


	settings = EditorInterface.get_editor_settings()



	#var debug_print_setting: String = "scene_snap_plugin/enable_plugin_debug_print_statements"
	## If the setting does not exist create it and set it to false
	#if not settings.has_setting(debug_print_setting):
		#var print_enabled: bool = false
		#settings.set_setting(debug_print_setting, print_enabled)
#
	#else: # set the print_enabled flag to match what is in settings
		#print_enabled = settings.get_setting(debug_print_setting)



	#$TabBar.tab_hovered(0).connect($TabBar.remove_tab)
	#var base_control = EditorInterface.get_base_control()
	# Initilize panel_floating_on_start setting
	#settings.set_setting("scene_snap_plugin/panel_floating_on_start", false)
	#settings.set_initial_value("scene_snap_plugin/panel_floating_on_start", false, false)
	#settings.erase("scene_snap_plugin/panel_position")
	# `settings.set("some/property", 10)` also works as this class overrides `_set()` internally.
	#settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
	#settings.set_setting("scene_snap_plugin/panel_position", scene_viewer_panel_instance.global_position)
	# `settings.get("some/property")` also works as this class overrides `_get()` internally.
	#await get_tree().process_frame
	#await get_tree().create_timer(1).timeout
	if settings.has_setting("scene_snap_plugin/panel_floating_on_start"):
		panel_floating_on_start = settings.get_setting("scene_snap_plugin/panel_floating_on_start")
	if settings.has_setting("scene_snap_plugin/show_favorites_tab_on_startup"):
		show_favorites_tab_on_startup = settings.get_setting("scene_snap_plugin/show_favorites_tab_on_startup")
	
	# Restore global tags
	if settings.has_setting("scene_snap_plugin/global_tags"):
		scene_viewer_panel_instance.scenes_with_global_tags = settings.get_setting("scene_snap_plugin/global_tags")
		
	#if panel_floating_on_start:
		#instantiate_panel = true
	#if debug: print("panel_floating_on_start: ", panel_floating_on_start)
	#var list_of_settings = settings.get_property_list()
	
	
	
	
	#if debug: print("list_of_settings: ", list_of_settings)
	configure_host_system_folder_structure()
	generate_user_global_tags_keys()
	#copy_textures_from_user_to_res()
	#scene_viewer_panel_instance = SCENE_VIEWER.instantiate()
	#if panel_floating_on_start:
		### NOTE Does not set panel size early enough
		##set_deferred("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
		##set_deferred("scene_snap_plugin/panel_window_position", panel_window_position)
		#call_deferred("restore_scene_panel_size")
		
	#scene_viewer_panel_instance.size = settings.get_setting("scene_snap_plugin/panel_size")
	#panel_window_position = settings.get_setting("scene_snap_plugin/panel_window_position")
	
	
	#call_deferred("set_intial_panel_size")
	#await get_tree().process_frame
	#await wait_ready(scene_viewer_panel_instance, "scene_viewer_panel_instance")
	#scene_viewer_panel_instance.last_session_favorites = user_favorites.scene_favorites
	
	#if scene_viewer_panel_instance:
	scene_viewer_panel_instance.make_floating_panel.connect(_open_popup)
	scene_viewer_panel_instance.pass_current_scene_up.connect(set_scene_preview)
	scene_viewer_panel_instance.tab_scene_buttons_created.connect(set_all_scenes_loaded)
	scene_viewer_panel_instance.do_file_copy.connect(copy_file)
	
	scene_viewer_panel_instance.change_collision_shape_3d.connect(update_scene_preview_collisions)
	
	#scene_viewer_panel_instance.change_collision_shape_3d.connect(
		#func (current_state: String) -> void:
			#current_collision_3d_state = current_state
			##if scene_preview != null and scene_preview_collisions:
				##
				##scene_preview.owner = null
				##await reparent_scene_preview(scene_preview)
				##scene_preview.set_owner(EditorInterface.get_edited_scene_root())
				##scene_preview.name = "ScenePreview"
				##
				##var save_path = "none"
				##await match_collision_state(scene_preview, scene_preview.name, save_path, false)
			#)
	
	# FIXME apply_multi_node_collisions
	#scene_viewer_panel_instance.change_collision_shape_3d.connect(apply_multi_node_collisions)
	scene_viewer_panel_instance.change_physics_body_type_3d.connect(func(current_3d_type: String) -> void: current_body_3d_type = current_3d_type)
	#scene_viewer_panel_instance.change_physics_body_type_3d.connect(apply_multi_node_body_type)
	scene_viewer_panel_instance.change_physics_body_type_2d.connect(func(current_2d_type: String) -> void: current_body_2d_type = current_2d_type)
	scene_viewer_panel_instance.instantiate_as_scene.connect(func(add_as_scene: bool) -> void: create_as_scene = add_as_scene)
	scene_viewer_panel_instance.enable_node_pinning.connect(func(enable_node_pinning: bool) -> void:
			node_pinning_enabled = enable_node_pinning
			if not enable_node_pinning:
				pinned_node = null
				pinned_tree_item = null
				scene_pinned_node.clear()
				get_tree_items() # Get current tree items
				for tree_item: TreeItem in tree_items: # Erase pins for all tree_items
					if tree_item.get_button_by_id(0, 10) != -1:
						tree_item.erase_button(0, tree_item.get_button_by_id(0, 10)))


	scene_viewer_panel_instance.get_current_scene_preview.connect(func() -> void: scene_viewer_panel_instance.current_scene_preview = scene_preview)


## FIXME Does not trigger filtering
	#scene_viewer_panel_instance.initialize_filters.connect(func() -> void:
				##await get_tree().create_timer(10).timeout
				#update_selected_buttons_for_tab(current_main_tab))
				##var main_container: TabContainer = scene_viewer_panel_instance.main_tab_container
				###var main_tab: Control = main_container.get_current_tab_control()
				##selected_main_tab_changed(main_container.current_tab))

	#scene_viewer_panel_instance.initialize_filters.connect(call_deferred("initialize_filters"))


	## Update scene_preview material to selected button material
	## FIXME Will set all mesh nodes to the same material override
	## FIXME Does not set the non selected surfaces to default material
	#scene_viewer_panel_instance.update_mesh_material.connect(set_surface_materials)
	
	#scene_viewer_panel_instance.update_mesh_material.connect(func(scene_full_path: String, surface: int, material: StandardMaterial3D) -> void:
		#if scene_preview != null:
			#var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
			#for mesh_node: MeshInstance3D in mesh_node_instances:
				## FIXME Adjust surface number from material button surface selection
				#mesh_node.set_surface_override_material(surface, material)
				#for non_selected_surface_index: int in mesh_node.mesh.get_surface_count():
					#if non_selected_surface_index != surface:
						#var default_material: StandardMaterial3D = scene_viewer_panel_instance.material_lookup[scene_full_path][non_selected_surface_index]
						#mesh_node.set_surface_override_material(non_selected_surface_index, default_material))

	scene_viewer_panel_instance.match_target_scale.connect(func(match_target_scale: bool) -> void: match_scale = match_target_scale)


	## Reset first scene view button selection to 0 when changing tabs
	scene_viewer_panel_instance.bubble_up_selected_sub_tab_changed.connect(selected_sub_collection_tab_changed)
	scene_viewer_panel_instance.enable_distraction_free_mode.connect(change_scene_viewer_window_properties)

	# This gets passed up from scene_view.gd to scene_viewer.gd to here to set selected_scene_view_button on button pressed
	# FIXME RESET SELECTED BUTTON ON KEY -Q AND RIGHT MOUSE
	scene_viewer_panel_instance.update_selected_scene_view_button.connect(func(scene_view_button: Button) -> void:
			scene_number = scene_view_button.get_index() - 1
			selected_scene_view_button = scene_view_button # Used to get plain text tags to load into mesh of scene_to_place
			
			snap_flow_manager_graph.selected_scene_view_button = scene_view_button)


#		func (tab: int, main_tab: Control) -> void: scene_viewer_panel_instance.current_scene_path = current_visible_buttons[0].scene_full_path)
	#scene_viewer_panel_instance.selected_sub_tab_changed.connect(
		#func (tab: int) -> void: scene_viewer_panel_instance.current_scene_path = current_visible_buttons[0].scene_full_path)


	scene_viewer_panel_instance.make_resources_unique.connect(func (make_resources_unique: bool) -> void: make_unique = make_resources_unique)
	
	scene_viewer_panel_instance.visible_scene_preview_collisions.connect(toggle_scene_preview_collisions)
	

	scene_viewer_panel_instance.set_enable_collision.connect(func (set_enable_collision: bool) -> void: enable_collisions = set_enable_collision)
	
	#scene_viewer_panel_instance.visible_scene_preview_collisions.connect(func (show_collisions: bool) -> void: scene_preview_collisions = show_collisions)
	
	#scene_viewer_panel_instance.visible_scene_preview_collisions.connect(
		#func (show_collisions: bool) -> void:
			#if scene_preview != null:
				#if debug: print("scene_preview: ", scene_preview)
			#scene_preview_collisions = show_collisions)
			
	#scene_viewer_panel_instance.set_no_collision.connect(
		#func (set_no_collision: bool) -> void:
			#if set_no_collision:
				#scene_preview_collisions_last_state = scene_preview_collisions
				#scene_preview_collisions = false
			#else:
				#scene_preview_collisions = scene_preview_collisions_last_state)

	

	scene_viewer_panel_instance.gen_lods.connect(generate_lods)
		#for scene_view_button in scene_viewer_panel_instance.scene_view_instances:
			#scene_view_button.pass_up_scene_number.connect(update_selected_scene_number)

		
	#if debug: print("current_scene_path: ", current_scene_path)
	#popup_window_instance = POPUP_WINDOW.instantiate()
	
	await get_tree().process_frame
	
	
	if panel_floating_on_start:
		#await get_tree().create_timer(1).timeout
		#call_deferred("_open_popup")
		_open_popup()
		## NOTE Does not set panel size early enough
		#set_deferred("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
		#set_deferred("scene_snap_plugin/panel_window_position", panel_window_position)
		#call_deferred("restore_scene_panel_size")
	else:
		#add_control_to_bottom_panel()
		add_control_to_bottom_panel(scene_viewer_panel_instance, "Scene Viewer")


	
	
	if show_favorites_tab_on_startup:
		if panel_floating_on_start:
			# Reference: https://forum.godotengine.org/t/awaiting-a-user-signal/2398/2 (vonagam)
			#await Signal(self, "enter_tree_complete")
			await Signal(self, "open_popup_complete")
		var main_container: TabContainer = scene_viewer_panel_instance.main_tab_container
		await wait_ready(main_container, "scene_viewer_panel_instance.main_tab_container")
		var main_favorite_tab: Control = MAIN_FAVORITES_TAB.instantiate()
		await get_tree().process_frame
		if main_container and main_favorite_tab:
			main_container.add_child(main_favorite_tab)
			main_favorite_tab.owner = scene_viewer_panel_instance

	# Does not load but no error 
	#scene_viewer_panel_instance.last_session_favorites = user_favorites.scene_favorites
	
	#add_control_to_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, scene_viewer_panel_instance)
	#make_bottom_panel_item_visible(scene_viewer_panel_instance)
	#add_control_to_popup_window_deferred()
	
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	
	## Connect to editor filesystem changed signal to update scene view buttons within Project Scenes
	#EditorInterface.get_resource_filesystem().filesystem_changed.connect(file_added_or_removed)

	# Connect signals from buttons when all instanced
	#await wait_ready(scene_viewer_panel_instance.scene_view_instances)
	# Reference: https://forum.godotengine.org/t/awaiting-a-user-signal/2398/2 (vonagam)
	await Signal(self, "all_scenes_loaded_re_emit")
	for scene_view_button in scene_viewer_panel_instance.scene_view_instances:
		scene_view_button.pass_up_scene_number.connect(update_selected_scene_number)


	#scene_viewer_panel_instance.initialize_filters.connect(call_deferred("initialize_filters"))
	#if debug: print("EVERYTHING IS READY THIS SHOULD PRINT AT THE END")
	emit_signal("enter_tree_complete")
	#scene_viewer_panel_instance.last_session_favorites = user_favorites.scene_favorites

	
	#await get_tree().create_timer(6).timeout






#func update_scene_save_path(original: bool) -> void:
	## Flip state
	#save_to_original_scene_path != save_to_original_scene_path
	#if debug: print("opening original: ", original)
	#if original:
		#snap_flow_manager_graph.scene_path = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn"
	#else:
		#snap_flow_manager_graph.scene_path = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_original.tscn"
		


#func instantiate_snap_manager_graph() -> void:
	#if debug: print("this is working here")
	#if snap_manager_graph_instance != null:
		#if debug: print("freeing snap_manager_graph_instance")
		##snap_manager_graph_instance.queue_free()
		#snap_manager_graph_instance.free()
		#await get_tree().create_timer(5).timeout
		#
		#snap_manager_graph_instance = load("res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn").instantiate()
		#if debug: print("new snap_manager_graph_instance: ", snap_manager_graph_instance)
		##snap_manager_graph_instance = SNAP_MANAGER_GRAPH.instantiate()
	##else:
		##if debug: print("REFRESHING SNAP MANAGER DATA")
		##snap_manager_graph_instance.queue_free()
		##snap_manager_graph_instance = null
		#
		## Reload SNAP_MANAGER_GRAPH
		##const SNAP_MANAGER_GRAPH = load("res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn").instantiate()
		##snap_manager_graph_instance = load("res://addons/scene_snap/plugin_scenes/snap_flow_manager_graph.tscn").instantiate()



#region Save and Restore

#func file_added_or_removed() -> void:
	#if debug: print("SOMETHING WAS CHANGED IN THE FILESYSTEM")


#func make_panel_floating(panel_instance) -> void:
	#_open_popup()

#func restore_scene_panel_size() -> void:
	#var settings = EditorInterface.get_editor_settings()
	##await get_tree().process_frame
	##scene_viewer_panel_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	##scene_viewer_panel_instance.size = settings.get_setting("scene_snap_plugin/panel_size")
	#popup_window_instance.size = settings.get_setting("scene_snap_plugin/panel_size")
	#panel_window_position = settings.get_setting("scene_snap_plugin/panel_window_position")


#func set_intial_panel_size() -> void:
	##scene_viewer_panel_instance.size = Vector2(scene_viewer_panel_instance.size.x, 456)
	#scene_viewer_panel_instance.set_deferred("size", Vector2(scene_viewer_panel_instance.size.x, 456))






#var connect_signals: bool = true
#
#func connect_main_tab_signals(main_container: TabContainer) -> void:
	#connect_signals = false
	#for main_tab: MainBaseTab in main_container.get_children():
		#main_tab.update_visible_buttons.connect(update_scene_preview_and_visible_buttons)


#func set_surface_materials(scene_full_path: String, surface: int, material: StandardMaterial3D) -> void:
	##if scene_preview != null:
	#var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
	#for mesh_node: MeshInstance3D in mesh_node_instances:
		## FIXME Adjust surface number from material button surface selection
		#if surface != -1 and material != null:
			#mesh_node.set_surface_override_material(surface, material)
		#for non_selected_surface_index: int in mesh_node.mesh.get_surface_count():
			#if non_selected_surface_index != surface:
				#var default_material: StandardMaterial3D = scene_viewer_panel_instance.material_lookup[scene_full_path][non_selected_surface_index]
				#mesh_node.set_surface_override_material(non_selected_surface_index, default_material)


#func initialize_filters() -> void:
	#var main_container: TabContainer = scene_viewer_panel_instance.main_tab_container
	#selected_main_tab_changed(main_container.current_tab)

# NOTE Saving snap_flow_manager_graph.tscn in PackedScene saves: Nodes | Positions | Connections etc. 
#func save_snap_manager_data(snap_flow_manager_graph: Control, snap_manager_data: Resource, graph_scene_path: String) -> void:
# NOTE Can only save on exit not while graphedit is open
func save_snap_flow_manager_data() -> void:
	
	#var snap_manager_data = SnapManagerData.new()
	#var graph_connection_data_path: String = "res://addons/scene_snap/resources/snap_manager_data.tres"
	

	var packed_scene = PackedScene.new()
	if packed_scene.pack(snap_flow_manager_graph) != OK:
		push_error("An error occurred while packing the snap flow manager graph.")
	#var graph_edit_child_control_nodes: Array[Node] = snap_flow_manager_graph.find_children("*", "Control", true, false)
	#for child: Control in graph_edit_child_control_nodes:
		#if debug: print(child.name)
	#if debug: print("graph_edit_child_control_nodes: ", graph_edit_child_control_nodes)
	if ResourceSaver.save(packed_scene, graph_scene_path) != OK:
		push_error("An error occurred while saving the snap flow manager graph to disk.")


	# EDIT NOTE: **NOT** Required to read connections when snap manager (GraphEdit) panel closed.
	# Get the connections from snap_flow_manager_graph.tscn, store them in snap_manager_data.gd and then save the connections to disk using snap_manager_data.tres
	# NOTE: Required to read connections when snap manager (GraphEdit) panel closed.
	#snap_manager_data.connections = snap_flow_manager_graph.get_connection_list()
	#if ResourceSaver.save(snap_manager_data, graph_connection_data_path) != OK:
		#push_error("An error occurred while saving the snap manager connection data to disk.")
	#snap_manager_data.connections = snap_flow_manager_graph.get_connection_list()
	#if ResourceSaver.save(snap_manager_data, graph_connection_data_path) != OK:
		#push_error("An error occurred while saving the snap manager connection data to disk.")







# NOTE Required for follow focus to function when in window popup mode
func selected_main_tab_changed(tab: int) -> void:
	# Clear out stale buttons in "Favorites" scene_buttons that have been "Freed" from favorites collection in other tabs.
	# NOTE: After being cleared above any none "Freed" buttons are regenerated and added to "Favorites" scene_buttons in main_base_tab.gd get_scene_buttons()
	for main_tab: Control in scene_viewer_panel_instance.main_tab_container.get_children():
		if main_tab.name == "Favorites":
			main_tab.scene_buttons.clear()

	#if debug: print("this is the tab: ", tab)
	var main_container: TabContainer = scene_viewer_panel_instance.main_tab_container
	#var main_tab: Control = main_container.get_current_tab_control()
	current_main_tab = main_container.get_current_tab_control()



	#Connect signals as tabs are openned after checking if connection does not already exists
	if not current_main_tab.update_visible_buttons.is_connected(update_scene_preview_and_visible_buttons):
		current_main_tab.update_visible_buttons.connect(update_scene_preview_and_visible_buttons)

	#if debug: print("THIS IS THE MAIN TAB NAME: ", main_tab.name)
	#update_selected_buttons_for_tab(tab, main_tab)
	update_selected_buttons_for_tab(current_main_tab)
	update_scene_preview_and_visible_buttons()

	#if connect_signals:
		#connect_main_tab_signals(main_container)


# FIXME Find way to get current open tab on startup
func selected_sub_collection_tab_changed(tab: int, main_tab: Control) -> void:
	if debug: print("this is the tab: ", tab)

	#update_selected_buttons_for_tab(tab, main_tab)
	update_selected_buttons_for_tab(main_tab)
	update_scene_preview_and_visible_buttons()

## FIXME grabs that last collections default texture not the current collection
	#await get_tree().process_frame
	## Update to collection default texture on tab change
	#scene_viewer_panel_instance._on_default_material_button_pressed()



#func update_selected_buttons_for_tab(tab: int, main_tab: Control) -> void:
## Node2D MultiSelectBox and selected_buttons
func update_selected_buttons_for_tab(main_tab: Control) -> void:
	if debug: print("updating selected buttons")
	if debug: print("main_tab: ", main_tab.name)
	scene_viewer_panel_instance.selected_buttons.clear()

	# Create function in main_base_tab.gd to get scene_buttons
	if main_tab:
		var scene_buttons: Array[Node]
		match main_tab.name:
			"Project Scenes", "Favorites":
				if debug: print("Project or Favorites")
				scene_buttons = main_tab.h_flow_container.get_children()
				

			_:  # NOTE: Or connect to selected_sub_tab_changed signal tab to replace main_tab.sub_tab_container.get_current_tab()
				if main_tab.sub_tab_container.get_current_tab() > -1:
					current_sub_tab = main_tab.sub_tab_container.get_child(main_tab.sub_tab_container.get_current_tab())
					if current_sub_tab:
						if debug: print("current_sub_tab.name: ",current_sub_tab.name)
						scene_buttons = current_sub_tab.h_flow_container.get_children()

		#scene_buttons = scene_buttons.filter(func(button): return button is Button)
		if scene_buttons:
			for scene_button in scene_buttons:
				if scene_button is Button and scene_button.selected_texture_button.button_pressed: # for Node2D MultiSelectBox
					scene_viewer_panel_instance.selected_buttons.append(scene_button)


		if debug: print("scene_viewer_panel_instance.selected_buttons: ", scene_viewer_panel_instance.selected_buttons)
		#main_tab.filter_buttons()
		main_tab.get_scene_buttons()

	else:
		push_warning("the tab could not be found.")


## Get currently visible buttons and create ScenePreview for the one that is focused
func update_scene_preview_and_visible_buttons() -> void:
	if scene_preview_3d_active and current_visible_buttons:
		remove_existing_scene_preview()
		# Find the focused button within the visible on-screen buttons if none get the first button 
		scene_number = 0
		for button: Button in current_visible_buttons:
			if button.has_focus():
				scene_number = current_visible_buttons.find(button)

		selected_scene_view_button = current_visible_buttons[scene_number]

		initialize_scene_preview = true # Grab list of current buttons in view

		if scene_preview == null and scene_preview_mesh == null:
			create_scene_preview()


# FIXME When changing scenes this happens after change causing errors how to trigger before scene change?
func remove_existing_scene_preview() -> void:
	if scene_preview != null:# and not scene_preview.is_inside_tree():
		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		# Cleanup scene_preview from dict for mesh collision
		var object_id: int = scene_preview.get_instance_id()
		filtered_object_ids.erase(object_id)

		#get_tree().get_root().remove_child(scene_preview)

		#scene_preview.free()
		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		scene_preview.queue_free()

		#scene_preview_mesh.free() # FIXME Do I need scene_preview_mesh it is just reference to scene_preview
		
		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		scene_preview_mesh = null
		
		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		scene_preview = null
		#scene_preview.queue_free()
		#scene_preview.free()
		
		
		#scene_preview_mesh.queue_free()
		#scene_preview_mesh.free()
		#get_tree().get_root().remove_child(scene_preview_mesh)
		#scene_preview_mesh = null
		#scene_preview_mesh.free()
		#scene_preview.free()

	#var existing_preview = get_tree().get_root().find_child("ScenePreview", true, false)
	#if existing_preview:
		#existing_preview.get_parent().remove_child(existing_preview)




func _on_scenedock_tree_mouse_entered() -> void:
	get_tree_items()
	mouse_over_scene_tree = true


func get_tree_items() -> void: # Update on mouse enter tree
	tree_items.clear()
	var current_item: TreeItem = scenedock_tree.get_root()
	while current_item != null:
		tree_items.append(current_item)
		current_item = current_item.get_next_visible()


func _on_scenedock_tree_mouse_exited() -> void:
	# Clear all none selected item pins
	for tree_item: TreeItem in tree_items:
		if tree_item != null:
			if tree_item.get_button_by_id(0, 10) != -1 and tree_item != pinned_tree_item:
				tree_item.erase_button(0, tree_item.get_button_by_id(0, 10))
	mouse_over_scene_tree = false


# Reference: https://github.com/dzil123/godot_scenetree_color_nodes (dzil123) MIT Licensed code
static func get_child_of_type(node: Node, type: String, recursive: bool = false) -> Node:
	var l = node.find_children("", type, recursive, false)
	assert(len(l) == 1)
	return l[0]

# BUG When button pressed is "open in editor" and switches scene trees if arg declared with item: TreeItem 
# ERROR: core/object/object.cpp:1249 - Error calling from signal 'button_clicked' to callable: 'EditorPlugin(scene_snap_plugin.gd)::node_pinned': Cannot convert argument 1 from Object to Object.
#func node_pinned(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
func node_pinned(item, column: int, id: int, mouse_button_index: int) -> void:

	if item:
		# Erase pins for all tree_items
		for tree_item: TreeItem in tree_items:
			if tree_item.get_button_by_id(0, 10) != -1:
				tree_item.erase_button(0, tree_item.get_button_by_id(0, 10))

		if item != pinned_tree_item and id == 10:
			var node_path = item.get_metadata(0)
			pinned_node = EditorInterface.get_edited_scene_root().get_node(node_path)

			# Change Pin color to blue
			add_pin_button(item, true)
			pinned_tree_item = item

		# TODO FIXME Remove from Dict when node is deleted from tree
		elif id == 10: # Remove only if Pin icon button pressed
			# Remove so that defaults back to root node pinning
			pinned_tree_item = null
			pinned_node = null
			add_pin_button(item, false)
			# Remove pinned node from dictionary
			scene_pinned_node.erase(EditorInterface.get_edited_scene_root())

	else: # FIXME Find more universal solution for all cases
		# NOTE Works but will still Error when switching back to original scene where scene_preview existed how to fix?
		# ERROR: editor/editor_data.cpp:1216 - Condition "!p_node->is_inside_tree()" is true.
		# Remove scene preview because maybe pressed "open in editor" and changed scene trees
		# TODO # Reload scene_preview when tree returns NOTE: Use same code as pinneded node when changing scenes?
		remove_existing_scene_preview()
		












# TODO Check if both functions are needed Just get working for now
#FIXME UPDATE SCALE TOO
func update_scene_preview_collisions(current_state: String) -> void:
	current_collision_3d_state = current_state
	if scene_preview != null and scene_preview_collisions:
		var collision_node_instances: Array[Node] = scene_preview.find_children("*", "CollisionShape3D", true, false)
		for collision_shape_3d: CollisionShape3D in collision_node_instances:
			collision_shape_3d.free()

		enable_collisions = true
		var save_path = "none"
		if debug: print("matching5")
		await match_collision_state(scene_preview, scene_preview.name, save_path, false)


# Create preview collisions on eye icon visibility changed
func toggle_scene_preview_collisions(show_collisions: bool) -> void:
	scene_preview_collisions = show_collisions
	if scene_preview != null and not show_collisions:
		var collision_node_instances: Array[Node] = scene_preview.find_children("*", "CollisionShape3D", true, false)
		for collision_shape_3d: CollisionShape3D in collision_node_instances:
			collision_shape_3d.queue_free()

	elif scene_preview != null and show_collisions:
		enable_collisions = true
		var save_path = "none"
		if debug: print("matching4")
		await match_collision_state(scene_preview, scene_preview.name, save_path, false)




# KEEP BUT NOT USED
func get_current_tab_order(sub_container_order_dict: Dictionary, main_tab_name: String, sub_tab_bar: TabBar) -> Array:
	var current_tab_order: Array = []
	#if debug: print("sub_container_order_dict.size(): ", sub_container_order_dict[main_tab_name].size())
	for index: int in range(0, sub_container_order_dict[main_tab_name].size()):
		#if debug: print(index)
		var current_sub_tab_name: String = sub_tab_bar.get_tab_title(index)
		current_tab_order.append(current_sub_tab_name)
		#if debug: print("current_sub_tab_name: ", current_sub_tab_name)
	return current_tab_order


# # FIXME if adding new folders to user:// after save and close causes (3) scene/main/node.cpp:460 - Parameter "p_child" is null. TODO Combine dictionaries into 1 NOTE Order effects results
func _set_window_layout(configuration): # NOTE This functionality seems slow to restore config
	# Restore favorites
	#scene_viewer_panel_instance.scene_favorites = configuration.get_value("SceneSnapPlugin", "favorites", Array())
	#scene_viewer_panel_instance.continue_load = true
	#if debug: print("favorites: ", scene_viewer_panel_instance.scene_favorites)
	
	# Restore favorite_materials_index_array
	scene_viewer_panel_instance.favorite_materials_index_array = configuration.get_value("SceneSnapPlugin", "favorite_materials_index_array", Array())
	
	## Restore show animation texture button state
	#scene_viewer_panel_instance.scene_has_animation = configuration.get_value("SceneSnapPlugin", "scene_has_animation", Array())

	#await get_tree().process_frame # Give scene_viewer_panel_instance time to instantiate and load all its children
	# HACK Does not allow for minimizing past 456 on first run
	# Set new project scene_viewer_panel_instance.custom_minimum_size to 456 for initial 2 row display of assets then overwrite min every start after to 173
	#scene_viewer_panel_instance.custom_minimum_size = Vector2(0.0, 173.0)
	# CAUTION WILL NEED TO CHANGE IF MORE SIDE PANEL BUTTONS ARE ADDED
	scene_viewer_panel_instance.custom_minimum_size = Vector2(0.0, 216.0) # Seems to be the min can go without slider moving behind tabs # Increased as a result of adding more sidepanel buttons


	# Restore slider value
	scene_viewer_panel_instance.zoom_v_slider.value = configuration.get_value("SceneSnapPlugin", "zoom_slider_value", float())

	# Get dictionary (Sub Tabs)
	var sub_container_order_dict = configuration.get_value("SceneSnapPlugin", "sub_container_tabs_order", Dictionary())

	# Get dictionary (Sub Tabs Selection)
	var sub_container_selection_dict = configuration.get_value("SceneSnapPlugin", "sub_container_tabs_selection", Dictionary())
	#if debug: print(sub_container_selection_dict)
	
	# Restore scene filter text
	var scene_filter_text_dict = configuration.get_value("SceneSnapPlugin", "scene_filter_text", Dictionary())
	
	## Restore previous current selected tab
	#var current_selected_tabs_dict = configuration.get_value("SceneSnapPlugin", "current_selected_tabs", Dictionary()) #{main_tab: current_tab_name}
	
	#if debug: print(scene_filter_text_dict)


	# Get array (Main Tabs)
	var main_container_tabs_names = configuration.get_value("SceneSnapPlugin", "main_container_tabs_order", Array())
	#if debug: print("main_container_tabs_names: ", main_container_tabs_names)
	
	# NOTE: FIXME WHY DO I SET THIS HERE AND NOT ONREADY? MYABE NOT READY AT THAT POINT?
	var main_container = scene_viewer_panel_instance.main_tab_container
	await wait_ready(main_container, "scene_viewer_panel_instance.main_tab_container")

	# FIXME TEST WILL THIS WORK WHEN FIRST INSTALLING PLUGIN AND USING?
	main_container.tab_changed.connect(selected_main_tab_changed)

	# Restore order (Main Tabs)
	var main_container_tab_order: int = 0
	#if main_container_tabs_names.has("Favorites"):
		#var main_favorite_tab: Control = MAIN_FAVORITES_TAB.instantiate()
		#main_container.add_child(main_favorite_tab)
		#main_favorite_tab.owner = scene_viewer_panel_instance

	for main_tab_name: String in main_container_tabs_names:
		#if debug: print("MAIN NAME: ", main_tab_name)
		# HACK
		#await get_tree().create_timer(1).timeout
		# FIXME Will error if disabling favorites tab from openning on startup in editor settings
		await wait_ready(main_container.find_child(main_tab_name, false, true), "main_container.find_child(main_tab_name, false, true)," + main_tab_name)
		var new_main_collection_tab: Control = main_container.find_child(main_tab_name, false, true)
		#if debug: print("new_main_collection_tab: ", new_main_collection_tab)
		main_container.move_child(new_main_collection_tab, main_container_tab_order)
		main_container_tab_order += 1
		# Restore scene filter text
		# HACK
		#await get_tree().create_timer(2).timeout
		
		if new_main_collection_tab:

			new_main_collection_tab.scene_search_line_edit.text = scene_filter_text_dict[main_tab_name]
			# Required to update UI
			new_main_collection_tab._on_scene_search_line_edit_text_changed(scene_filter_text_dict[main_tab_name])
			# Restore order (Sub Tabs)
			if main_tab_name != "Favorites" and main_tab_name != "Project Scenes":
				# NOTE With SubContainer:
				#var sub_container_tab_order: int = 0
				#var sub_container = main_container.find_child(main_tab_name, false, false).find_child("SubTabBar", true, false)
				#for sub_tab in sub_container_order_dict[main_tab_name]:
					#if debug: print("sub_tab: ", sub_tab)
					#sub_container.move_child(sub_container.find_child(sub_tab, false, false), sub_container_tab_order)
					#sub_container_tab_order += 1

				## NOTE With SubTab:
				#var previous_tab_order: Dictionary = {}
				#var previous_tab_order: Array = []
				#var current_tab_order: Dictionary = {}
				#var current_tab_order: Array = []
				#
				var sub_tab_bar_tab_order: int = 0
	#
				#var sub_tab_bar: TabBar = main_container.find_child(main_tab_name, false, false).find_child("SubTabBar", true, false)
				var sub_tab_container: TabContainer = new_main_collection_tab.sub_tab_container
				
				# Restore previous session open tabs and order
				scene_viewer_panel_instance.create_sub_collection_tabs(sub_container_order_dict[main_tab_name], new_main_collection_tab)



	# KEEP 
				## NOTE I don't know what I did to figure this out, but I did not use AI.
				##if debug: print(get_current_tab_order(sub_container_order_dict, main_tab_name, sub_tab_bar))
				#for previous_sub_tab_name: String in sub_container_order_dict[main_tab_name]:
					#var move_me: int = get_current_tab_order(sub_container_order_dict, main_tab_name, sub_tab_bar).find(previous_sub_tab_name)
					#sub_tab_bar.move_tab(move_me, sub_tab_bar_tab_order)
					#sub_tab_bar_tab_order += 1
	# KEEP 
				
				# Restore selection (Sub Tabs)
				sub_tab_container.set_current_tab(sub_container_selection_dict[main_tab_name])

	# Restore selection (Main Tabs)
	main_container.current_tab = configuration.get_value("SceneSnapPlugin", "main_container_current_tab", int())

	# Restore Heart Filter Button State
	var heart_filter_state_dict = configuration.get_value("SceneSnapPlugin", "heart_filter_state", Dictionary())
	
	#######################################################################################KEEP
	## Restore 2D 3D selection state
	#scene_viewer_panel_instance.next_filter = configuration.get_value("SceneSnapPlugin", "filter_2d_3d_state", int())

	# NOTE filter_2d_3d_state_dict share keys so can be combined TODO combine both into one Dictionay
	
	# Reference: https://forum.godotengine.org/t/awaiting-a-user-signal/2398/2 (vonagam)
	#await Signal(self, "all_scenes_loaded_re_emit")
	
	## Restore favorites
	#scene_viewer_panel_instance.scene_favorites = configuration.get_value("SceneSnapPlugin", "favorites", Array())
	#if debug: print("favorites I NEED TO SEE THIS SO BIGG PRINT: ", scene_viewer_panel_instance.scene_favorites)
	
	
	# Restore heart filter state
	for main_tab_name in heart_filter_state_dict.keys():
		var main_collection_tab: Control = main_container.find_child(main_tab_name, false, true)
		main_collection_tab.heart_texture_button.button_pressed = heart_filter_state_dict[main_tab_name]


	#for main_tab_name: String in main_container_tabs_names:
		##if debug: print("MAIN NAME: ", main_tab_name)
		## HACK
		##await get_tree().create_timer(1).timeout
		#await wait_ready(main_container.find_child(main_tab_name, false, true))
		#var new_main_collection_tab: Control = main_container.find_child(main_tab_name, false, true)
		##if debug: print("new_main_collection_tab: ", new_main_collection_tab)
		#main_container.move_child(new_main_collection_tab, main_container_tab_order)
		#main_container_tab_order += 1
		## Restore scene filter text
		## HACK
		##await get_tree().create_timer(2).timeout
		#
		#
		#new_main_collection_tab.scene_search_line_edit.text = scene_filter_text_dict[main_tab_name]
		## Required to update UI
		#new_main_collection_tab._on_scene_search_line_edit_text_changed(scene_filter_text_dict[main_tab_name])
		## Restore order (Sub Tabs)
		#if main_tab_name != "Favorites" and main_tab_name != "Project Scenes":
			## NOTE With SubContainer:
			##var sub_container_tab_order: int = 0
			##var sub_container = main_container.find_child(main_tab_name, false, false).find_child("SubTabBar", true, false)
			##for sub_tab in sub_container_order_dict[main_tab_name]:
				##if debug: print("sub_tab: ", sub_tab)
				##sub_container.move_child(sub_container.find_child(sub_tab, false, false), sub_container_tab_order)
				##sub_container_tab_order += 1
#
			### NOTE With SubTab:
			##var previous_tab_order: Dictionary = {}
			##var previous_tab_order: Array = []
			##var current_tab_order: Dictionary = {}
			##var current_tab_order: Array = []
			##
			#var sub_tab_bar_tab_order: int = 0
##
			##var sub_tab_bar: TabBar = main_container.find_child(main_tab_name, false, false).find_child("SubTabBar", true, false)
			#var sub_tab_container: TabContainer = new_main_collection_tab.sub_tab_container
			#
			## Restore previous session open tabs and order
			#scene_viewer_panel_instance.create_sub_collection_tabs(sub_container_order_dict[main_tab_name], new_main_collection_tab)


 ##KEEP 
			### NOTE I don't know what I did to figure this out, but I did not use AI.
			###if debug: print(get_current_tab_order(sub_container_order_dict, main_tab_name, sub_tab_bar))
			##for previous_sub_tab_name: String in sub_container_order_dict[main_tab_name]:
				##var move_me: int = get_current_tab_order(sub_container_order_dict, main_tab_name, sub_tab_bar).find(previous_sub_tab_name)
				##sub_tab_bar.move_tab(move_me, sub_tab_bar_tab_order)
				##sub_tab_bar_tab_order += 1
 ##KEEP 
			##
			 ##Restore selection (Sub Tabs)
			#sub_tab_container.set_current_tab(sub_container_selection_dict[main_tab_name])
			
			
			
	## Restore required scenes
	#required_scenes_dict = configuration.get_value("SceneSnapPlugin", "required_scenes", Dictionary())
			

		
		
		
	#scene_viewer_panel_config = configuration.get_value("SceneSnapPlugin", "scene_viewer_panel_config", Dictionary())
#
	## Restore Scene_view_panel side button states
	#create_as_scene = scene_viewer_panel_config.create_as_scene
	#if create_as_scene:
		#scene_viewer_panel_instance.scene_creation_toggle_button.button_pressed = true
	#else:
		#scene_viewer_panel_instance.scene_creation_toggle_button.button_pressed = false




	# Restore Scene_view_panel side button states
	create_as_scene = configuration.get_value("SceneSnapPlugin", "create_as_scene_button_state", bool())
	if create_as_scene:
		#scene_viewer_panel_instance.scene_creation_toggle_button.button_pressed = true
		scene_viewer_panel_instance.scene_instantiate_enabled = true
	else:
		scene_viewer_panel_instance.scene_instantiate_enabled = false
		#scene_viewer_panel_instance.scene_creation_toggle_button.button_pressed = false

	scene_viewer_panel_instance.next_type_3d = configuration.get_value("SceneSnapPlugin", "body_type_3d_button_state", String())
	for number: int in 5: # HACK Cycle back to to correct selection by presseing the button 5 times :( FIXME
		scene_viewer_panel_instance._on_change_body_type_3d_button_pressed()
	
	#scene_viewer_panel_instance.next_3d_collision_state = configuration.get_value("SceneSnapPlugin", "current_3d_collision_state", String())
	scene_viewer_panel_instance.next_3d_collision_state = configuration.get_value("SceneSnapPlugin", "current_3d_collision_state", int())
	# Toggle back one because button_press will initialize it to the saved value
	scene_viewer_panel_instance.toggle_3d_collision_state(-1)
	scene_viewer_panel_instance._on_change_collision_shape_3d_button_pressed()


	#if configuration.get_value("SceneSnapPlugin", "lod_button_state", bool()):
		#scene_viewer_panel_instance.gen_lod_button.button_pressed = true
	#else:
		#scene_viewer_panel_instance.gen_lod_button.button_pressed = false
#
	#if configuration.get_value("SceneSnapPlugin", "filter_by_folder", bool()): # If expression returns true
		#scene_viewer_panel_instance.new_main_project_scenes_tab.filter_by_file_system_folder_button.button_pressed = true
	#else:
		#scene_viewer_panel_instance.new_main_project_scenes_tab.filter_by_file_system_folder_button.button_pressed = false
#
	#if configuration.get_value("SceneSnapPlugin", "node_pinning_state", bool()):
		#scene_viewer_panel_instance._on_enable_pinning_toggle_button_toggled(true)
	#else:
		#scene_viewer_panel_instance._on_enable_pinning_toggle_button_toggled(false)


	scene_viewer_panel_instance.gen_lod_button.button_pressed = configuration.get_value("SceneSnapPlugin", "lod_button_state", bool())
	scene_viewer_panel_instance.new_main_project_scenes_tab.filter_by_file_system_folder_button.button_pressed = configuration.get_value("SceneSnapPlugin", "filter_by_folder", bool())
	scene_viewer_panel_instance._on_enable_pinning_toggle_button_toggled(configuration.get_value("SceneSnapPlugin", "node_pinning_state", bool()))


	#required_scenes_dict = configuration.get_value("SceneSnapPlugin", "required_scenes", Dictionary())
	#required_scenes_dict = configuration.get_value("SceneSnapPlugin", "required_scenes", Dictionary())
	#required_scenes_dict = configuration.get_value("SceneSnapPlugin", "required_scenes", Dictionary())
	#var body_type = configuration.get_value("SceneSnapPlugin", "create_as_scene_button_state", bool()
	#scene_viewer_panel_instance.next_type_3d = Physics_Body_Type_3D.
	#next_type_3d: Physics_Body_Type_3D = Physics_Body_Type_3D.NO_PHYSICSBODY3D
			
			
	
			
			
			
			
	scene_viewer_panel_instance.saved_data_restored = true
	


#var scene_viewer_panel_config: Dictionary = {}


# Re-emiiting a signal because I don't know how to just await the first one directly
func set_all_scenes_loaded() -> void:
	emit_signal("all_scenes_loaded_re_emit")

enum Physics_Body_Type_3D {
	NO_PHYSICSBODY3D,
	NODE3D,
	STATICBODY3D,
	RIGIDBODY3D,
	CHARACTERBODY3D
}



#func wait_available(configuration) -> bool:
	#var wait_time: int = 0
	#var main_collection_tab: Control
#
	#while true:
		#scene_viewer_panel_instance.scene_favorites = configuration.get_value("SceneSnapPlugin", "favorites", Array())
#
		#if scene_viewer_panel_instance.scene_favorites != []:
			#return true  # Found the control, return true
		#
		#await get_tree().process_frame  # Wait for the next frame
		#wait_time += 1
#
		#if wait_time >= 120:
			#push_error("Failed to load favorites")
			#return false  # Timeout reached
#
	#return false  # Fallback, though this line should not be reached










#func wait_available(main_container: Node, main_tab_name: String) -> bool:
	#var wait_time: int = 0
	#var main_collection_tab: Control
#
	#while true:
		#main_collection_tab = main_container.find_child(main_tab_name, false, true)
#
		#if main_collection_tab:
			#return true  # Found the control, return true
		#
		#await get_tree().process_frame  # Wait for the next frame
		#wait_time += 1
#
		#if wait_time >= 1:
			#push_error("Failed to load: ", main_tab_name)
			#return false  # Timeout reached
#
	#return false  # Fallback, though this line should not be reached







#func progressive_wait(object: ) -> bool
	#if object:
		#return true
	#await get_tree().process_frame
	
func wait_ready(object, name: String) -> bool:
	var wait_time: int = 0
	while not object:
		if debug: print("waiting for ", name, " to be ready")
		await get_tree().process_frame
		wait_time += 1

		if wait_time >= 120:
			push_error("Failed to load: ", name)
			return false

	return true





# NOTE: Runs during editor use not just on editor close
func _get_window_layout(configuration):

	# Save variables back to scene_data_cache.tres resource file before closing editor
	# Save Favorites to resource file for faster retrival on next start
	scene_data_cache.scene_favorites = scene_viewer_panel_instance.scene_favorites
	# Saving to uid not supported
	#if ResourceSaver.save(scene_data_cache, "uid://3as6dllcbl36") != OK:
	if ResourceSaver.save(scene_data_cache, "res://addons/scene_snap/resources/scene_data_cache.tres") == OK:
		if debug: print("Successfully saved favorites to scene_data_cache")
	else:
		if debug: push_error("Failed to save favorites to scene_data_cache")

	# NOTE: Saving scene_favorites and running ResourceSaver.save after saving the metadata tags causes metadata tags never to 
	# be written? I don't know why but this order works
	# Copy tags to scene mesh metadata
	scene_viewer_panel_instance.store_tags_in_scene_mesh()

	# Save favorite_materials_index_array
	configuration.set_value("SceneSnapPlugin", "favorite_materials_index_array", scene_viewer_panel_instance.favorite_materials_index_array)
	


	
	
	
	## FIXME loops through all scenes not just the ones with tags
	#scene_viewer_panel_instance.store_tags_in_scene_mesh()
	################################################################################
	# NOTE MUST BE DISABLED DURING DEVELOPMENT TO BE ABLE TO MAKE CHANGES TO DEFAULT SCENE IN EDITOR
	# SCENE IS LOADED IN ON SESSION START AND THAT SAME SCENE IS SAVED BACK TO ORIGINAL ON EXIT HERE.
	# Save snap manager if not closed by user before exit.
	#save_snap_manager_data()
	################################################################################
	#var scene_buttons: Array[Button] = scene_viewer_panel_instance.scene_view_buttons
	#if debug: print("SIZE: ", scene_buttons.size())
	#for scene_button: Button in scene_buttons:
		## Save shared_tags into the mesh Metadata Extras shared_tags Array
		#if scene_button.shared_tags != []:
			#if debug: print("SHARED TAGS: ", scene_button.shared_tags)
		## Encrypt and save global_tags into the mesh Metadata Extras global_tags Dictionary
		#if scene_button.global_tags != []:
			#if debug: print("GLOBAL TAGS: ", scene_button.global_tags)
		
	
		
	#if debug: print("scene_viewer_panel_instance.scene_view_buttons: ", scene_viewer_panel_instance.scene_view_buttons)
	#await get_tree().create_timer(5).timeout










	## Save Favorites to resource file for faster retrival on next start
	#user_favorites.scene_favorites = scene_viewer_panel_instance.scene_favorites
	#ResourceSaver.save(user_favorites, "res://addons/scene_snap/resources/user_favorites.tres")



	# Cache/Save created scene_view buttons to disk so they are not recreated on collection open
	# NOTE: TODO Add pass flag to create scene_view buttons
	
	
	
	# HACK TODO Consider changing to resource file and saving there. done this way because restoring from save took to long
	#var settings = EditorInterface.get_editor_settings()
	#settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
	settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.get_parent().size)
	settings.set_setting("scene_snap_plugin/panel_window_position", scene_viewer_panel_instance.get_parent().position)
	settings.set_setting("scene_snap_plugin/global_tags", scene_viewer_panel_instance.scenes_with_global_tags)
	
	
	
	## TEST
	#var property_info = {
	#"name": "scene_snap_plugin/panel_size",
	#"type": TYPE_INT,
	#"hint": PROPERTY_HINT_ENUM,
	#"hint_string": "one,two,three"
	#}
#
	#settings.add_property_info(property_info)
	## TEST
	
	
	
	var main_container = scene_viewer_panel_instance.main_tab_container
	
	# Slider value
	configuration.set_value("SceneSnapPlugin", "zoom_slider_value", scene_viewer_panel_instance.zoom_v_slider.value)




	# Create Dictionaries
	var sub_container_order_dict: Dictionary = {} # { main_container_tab: sub_container_tabs_names,}
	var sub_container_selection_dict: Dictionary = {} # { main_container_tab: sub_container_tabs_selected,}
	var scene_filter_text_dict: Dictionary = {}
	var heart_filter_state_dict: Dictionary = {}
	#var filter_2d_3d_state_dict: Dictionary = {}
	######################################################################################KEEP
	#var current_filter_2d_3d_state: int
	######################################################################################KEEP
	#var current_selected_tabs_dict: Dictionary = {} = configuration.get_value("SceneSnapPlugin", "scene_filter_text", Dictionary())

	# Save main tabs order
	var main_container_tabs_names: Array[String] = []
	
	for main_collection_tab in main_container.get_children():
		# This is will get the order that the Main Collection Tabs are in
		main_container_tabs_names.append(main_collection_tab.name)
		# Save scene filter text
		scene_filter_text_dict[main_collection_tab.name] = main_collection_tab.scene_search_line_edit.text

		# Restrict getting sub tabs on "Global Collections", "Shared Collections"
		if main_collection_tab.name != "Favorites" and main_collection_tab.name != "Project Scenes":

			# Save sub tabs order NOTE must use get_tab_title() not sub_tab.name
			var sub_container_tabs_names: Array[String] = [] # Create a new array for each main_tab
			
			# FIXME
			#for sub_tab in main_tab.sub_tab_bar.get_children():
				#var sub_tab_index: int = sub_tab.get_index()
				#var sub_tab_name: String = main_tab.sub_tab_bar.get_tab_title(sub_tab_index)
			
			# FIXME FIXME
			for sub_tab_index: int in main_collection_tab.sub_tab_container.get_tab_count():
				var sub_tab_name: String = main_collection_tab.sub_tab_container.get_tab_title(sub_tab_index)
				sub_container_tabs_names.append(sub_tab_name)
			sub_container_order_dict[main_collection_tab.name] = sub_container_tabs_names
			sub_container_selection_dict[main_collection_tab.name] = main_collection_tab.sub_tab_container.current_tab


######################################################################################KEEP
	## Save 2D 3D selection state
	##if debug: print("scene_viewer_panel_instance.filter SAVE: ", scene_viewer_panel_instance.filter)
	#configuration.set_value("SceneSnapPlugin", "filter_2d_3d_state", scene_viewer_panel_instance.next_filter)



	# Save Heart Filter Button State
	for main_collection_tab in main_container.get_children():
		#var main_tab_name: String = main_tab.name
		heart_filter_state_dict[main_collection_tab.name] = main_collection_tab.heart_texture_button.button_pressed

	#if debug: print(heart_filter_state_dict)
	configuration.set_value("SceneSnapPlugin", "heart_filter_state", heart_filter_state_dict)



	# Save array (Main Tabs)
	configuration.set_value("SceneSnapPlugin", "main_container_tabs_order", main_container_tabs_names)
	
	
	
	
	# Save dictionary (Sub Tabs)
	configuration.set_value("SceneSnapPlugin", "sub_container_tabs_order", sub_container_order_dict)
	
	
	
	
	
	# Save dictionary (Sub Tabs Selection)
	configuration.set_value("SceneSnapPlugin", "sub_container_tabs_selection", sub_container_selection_dict)
	# Save dictionary (Scene Filter Text)
	configuration.set_value("SceneSnapPlugin", "scene_filter_text", scene_filter_text_dict)

	# Save main tabs selection
	configuration.set_value("SceneSnapPlugin", "main_container_current_tab", main_container.current_tab)
	
	# Save favorites
	#configuration.set_value("SceneSnapPlugin", "favorites", scene_viewer_panel_instance.get_tree().get_nodes_in_group("favorites"))
	#if debug: print("favorites: ", scene_viewer_panel_instance.scene_favorites)
	configuration.set_value("SceneSnapPlugin", "favorites", scene_viewer_panel_instance.scene_favorites)
	
	## Save scenes with animation for icon display
	#configuration.set_value("SceneSnapPlugin", "scene_has_animation", scene_viewer_panel_instance.scene_has_animation)

	# Save open favorites Tab
	configuration.set_value("SceneSnapPlugin", "open_favorites_tab", scene_viewer_panel_instance.open_favorites_tab)
	
	# Save scene_viewer_panel_instance size
	#configuration.set_value("SceneSnapPlugin", "scene_panel_size", scene_viewer_panel_instance.size)

	# Save scene_viewer_panel_instance position
	#configuration.set_value("SceneSnapPlugin", "scene_panel_position", scene_viewer_panel_instance.global_position)

	# Save scene_viewer_panel_instance state
	#configuration.set_value("SceneSnapPlugin", "scene_panel_state", scene_panel_floating)

	## Save required scenes
	#configuration.set_value("SceneSnapPlugin", "required_scenes", required_scenes_dict)

	# Save Scene_view_panel side button states
	#configuration.set_value("SceneSnapPlugin", "create_as_scene_button_state", scene_viewer_panel_instance.scene_creation_toggle_button.button_pressed)
	configuration.set_value("SceneSnapPlugin", "create_as_scene_button_state", scene_viewer_panel_instance.scene_instantiate_enabled)
	
	configuration.set_value("SceneSnapPlugin", "body_type_3d_button_state", scene_viewer_panel_instance.next_type_3d)
	configuration.set_value("SceneSnapPlugin", "current_3d_collision_state", scene_viewer_panel_instance.next_3d_collision_state)
	configuration.set_value("SceneSnapPlugin", "lod_button_state", scene_viewer_panel_instance.gen_lod_button.button_pressed)

	configuration.set_value("SceneSnapPlugin", "filter_by_folder", scene_viewer_panel_instance.new_main_project_scenes_tab.filter_by_file_system_folder_button.button_pressed)

	configuration.set_value("SceneSnapPlugin", "node_pinning_state", node_pinning_enabled)



	## Save Scene Viewer Panel configuration
	##var scene_viewer_panel_config: Dictionary = {}
	#scene_viewer_panel_config["create_as_scene"] = create_as_scene
	#
	#
	## Run last
	#configuration.set_value("SceneSnapPlugin", "scene_viewer_panel_config", scene_viewer_panel_config)
	
	#var scene_viewer_panel_config = configuration.get_value("SceneSnapPlugin", "scene_view_panel_config", Dictionary())


#endregion


	
#region Docks
#func call_add_control_to_bottom_panel() -> void:
	#
	#add_control_to_bottom_panel(scene_viewer_panel_instance, "Scene Viewer")
	#if debug: print("scene_viewer_panel_instance.global_position: ", scene_viewer_panel_instance.global_position)

#func add_control_to_popup_window_deferred() -> void:
	#add_tool_menu_item("Open Window", _open_popup)

func add_control_to_filesystem_dock_deferred() -> void:
	add_control_to_dock(DOCK_SLOT_LEFT_BR, scene_viewer_panel_instance)

# How can I detect when the mouse cursor is inside the window or not? (rainlizard)
# Reference: https://www.reddit.com/r/godot/comments/e36zyq/how_can_i_detect_when_the_mouse_cursor_is_inside/
func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_ENTER:
			if panel_floating_on_start and popup_window_instance:
				var win: Window = popup_window_instance
				# Get position and size of the editor window 
				var root_pos: Vector2 = get_tree().get_root().position
				var root_size: Vector2 = get_tree().get_root().size
				# If the scene_viewer_panel is within the editor window on the x axis keep it on top
				# otherwise allow it to go behind other windows
				if win.position.x > root_pos.x and win.position.x < (root_pos.x + root_size.x):
					#get_tree().get_root().grab_focus()
					#win.visible = false
					#win.visible = true
					win.transient = false
					win.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
				else:
					#get_tree().get_root().grab_focus()
					win.set_flag(Window.FLAG_ALWAYS_ON_TOP, false)
					#win.always_on_top = false
				#if debug: print('Mouse entered window')
				get_tree().get_root().grab_focus()




func change_scene_viewer_window_properties(distraction_free_mode: bool) -> void:
	if distraction_free_mode and popup_window_instance != null:
		if debug: print("this triggered")
		#popup_window_instance.set_flag(Window.FLAG_TRANSPARENT, true)
		#popup_window_instance.set_transparent_background(true)

		#popup_window_instance.set_transparent_background(true)
		#popup_window_instance.set_flag(Window.FLAG_TRANSPARENT, true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
		#popup_window_instance.set_flag(Window.FLAG_MOUSE_PASSTHROUGH, false)
		#popup_window_instance.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
		#popup_window_instance.set_flag(Window.FLAG_BORDERLESS, true)

		#get_tree().get_root().set_transparent_background(true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	else:
		get_tree().get_root().set_transparent_background(false)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, false, 0)


func _open_popup() -> void:
	popup_window_instance = POPUP_WINDOW.instantiate()
	await get_tree().process_frame # Needed to give time to instantiate POPUP_WINDOW when opening popup on start
	popup_window_instance.name = "Scene Viewer"
	
	
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	#get_tree().get_root().set_flag(Window.FLAG_BORDERLESS, true)
	#popup_window_instance.set_transparent_background(true)
	#popup_window_instance.set_flag(Window.FLAG_TRANSPARENT, true)
	#popup_window_instance.set_flag(Window.FLAG_MOUSE_PASSTHROUGH, true)
	#popup_window_instance.set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	#popup_window_instance.set_flag(Window.FLAG_BORDERLESS, true)

	#get_tree().get_root().set_transparent_background(true)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
  #DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true, 0)
  #DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, 0)
  #DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)


	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, 0)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)
	
	
	
	

	if panel_floating_on_start:
		#var settings = EditorInterface.get_editor_settings()
		if settings.has_setting("scene_snap_plugin/panel_size") and settings.has_setting("scene_snap_plugin/panel_window_position"):
			popup_window_instance.size = settings.get_setting("scene_snap_plugin/panel_size")
			panel_window_position = settings.get_setting("scene_snap_plugin/panel_window_position")
		get_editor_interface().popup_dialog(popup_window_instance, Rect2i(panel_window_position, popup_window_instance.size))
	else:
		get_editor_interface().popup_dialog(popup_window_instance, Rect2i(scene_viewer_panel_instance.global_position, scene_viewer_panel_instance.size))

	settings.set_setting("scene_snap_plugin/panel_floating_on_start", true)
	
	popup_window_instance.attach_dock.connect(reattach_dock)

	remove_control_from_bottom_panel(scene_viewer_panel_instance)

	popup_window_instance.add_child(scene_viewer_panel_instance)
	# Allow panel to resize and keep anchored
	scene_viewer_panel_instance.set_anchors_preset(Control.PRESET_FULL_RECT)

	# After scene fully loaded then adjust it
	call_deferred("adjust_menu_bar_overlap")


	scene_viewer_panel_instance.make_floating.hide()
	######KEEP
	#scene_viewer_panel_instance.pin_panel.show()
	######KEEP
	
	scene_viewer_panel_instance.owner = popup_window_instance
	
	panel_floating_on_start = true
	

	## Reference: https://forum.godotengine.org/t/awaiting-a-user-signal/2398/2 (vonagam)
	#await Signal(self, "enter_tree_complete")
	#await get_tree().create_timer(5).timeout
	#if debug: print("grbbing focus now")
	#popup_window_instance.grab_focus()
	emit_signal("open_popup_complete")


func adjust_menu_bar_overlap() -> void:
	scene_viewer_panel_instance.h_box_container.position.y = 5
	scene_viewer_panel_instance.h_box_container.position.x = 5
	scene_viewer_panel_instance.h_box_container.size.x -= 10

#endregion

func reattach_dock() -> void:
	panel_floating_on_start = false
	# HACK TODO Consider changing to resource file and saving there. done this way because restoring from save took to long
	#var settings = EditorInterface.get_editor_settings()
	settings.set_setting("scene_snap_plugin/panel_floating_on_start", false)
	#settings.set_setting("scene_snap_plugin/panel_size", scene_viewer_panel_instance.size)
	settings.set_setting("scene_snap_plugin/panel_window_position", scene_viewer_panel_instance.get_parent().position)
	
	var panel_parent: Window = scene_viewer_panel_instance.get_parent()
	panel_parent.remove_child(scene_viewer_panel_instance)
	
	
	scene_viewer_panel_instance.owner = null
	add_control_to_bottom_panel(scene_viewer_panel_instance, "Scene Viewer")
	make_bottom_panel_item_visible(scene_viewer_panel_instance)

	#scene_viewer_panel_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_viewer_panel_instance.h_box_container.position.y = 0
	scene_viewer_panel_instance.h_box_container.position.x = 0
	scene_viewer_panel_instance.h_box_container.size.x += 10
	scene_viewer_panel_instance.make_floating.show()
	######KEEP
	#scene_viewer_panel_instance.pin_panel.hide()
	######KEEP
	#scene_viewer_panel_instance.visible = true
	#scene_viewer_panel_instance.set_focus_mode(Control.FOCUS_ALL)
	#
	#scene_viewer_panel_instance.grab_focus()
	panel_parent.queue_free()

	#if debug: print("attaching dock now")




#region Filesystem Configs
func configure_host_system_folder_structure() -> void:
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	#ProjectSettings.set_setting("application/config/custom_user_dir_name", "Godot/shared_collections")
	ProjectSettings.set_setting("application/config/custom_user_dir_name", "Godot/scene_snap")
	DirAccess.make_dir_recursive_absolute("user://")
	# For scenes
	#create_folders("user://", "shared_collections/scenes/2D Scenes")
	#create_folders("user://", "shared_collections/scenes/3D Scenes")

	#create_folders("user://", "global_collections/scenes/Global Collections")
	#create_folders("user://", "shared_collections/scenes/Shared Collections")
	create_folders("user://", "global_collections/scenes/Global Collections")
	create_folders("user://", "shared_collections/scenes/Shared Collections")
	
	
	
	# For scene_thumbnail_cache
	#create_folders("user://", "shared_collections/scenes_thumbnail_cache/2D Scenes")
	#create_folders("user://", "shared_collections/scenes_thumbnail_cache/3D Scenes")

	var project_name: String = ProjectSettings.get_setting("application/config/name")
	create_folders("user://", "project_scenes/thumbnail_cache_project".path_join(project_name))
	#create_folders("user://", "project_scenes/thumbnail_cache_project")
	create_folders("user://", "global_collections/thumbnail_cache_global/Global Collections")
	create_folders("user://", "shared_collections/thumbnail_cache_shared/Shared Collections")
	
	# Create "New Collection" folder if it does not already exist
	for path in file_paths:
		create_folders("user://", path.path_join("New Collection".path_join("textures")))


	# NOTE FIXME MOVE OVER TO WHEN FOLDER IS IMPORTED
	#copy_textures_from_user_to_res()


var encryption_key_setting: String = "scene_snap_plugin/global_tags_key:_warning!_removing_or_changing_key_will_make_your_global_tags_unaccessible/encryption_key"

## This 5 digit key is used to uniquely identify and retrieve a user's encrypted local tags within the shared metadata.
func get_reference_key() -> String:
	if settings.has_setting(encryption_key_setting):
		var encryption_key: String = settings.get_setting(encryption_key_setting)
		# Get the first 5 digits of the encryption key to use as the reference key
		return encryption_key.substr(0, encryption_key.length() - 11)
	else:
		push_error("No encryption key found in Project Settings!")
		return ""


func generate_user_global_tags_keys() -> void:

	# TESTING: REMOVE # TO REGENERATE KEY
	#settings.erase(encryption_key_setting)

	if not settings.has_setting(encryption_key_setting):
		
		var encryption_key: String = generate_key()
		settings.set_setting(encryption_key_setting, encryption_key)
		print_rich("[color=green][b]An encryption key: [/b][/color]", encryption_key, "[color=green][b] has been generated for your global tags.\
		\nYour encryption key is stored in the Project Settings under Editor -> Editor Settings -> Scene Snap Plugin.[/b][/color]")

		#if debug: print("REF KEY: ", get_reference_key())

func generate_key() -> String:
	var crypto = Crypto.new()
	var key = crypto.generate_random_bytes(8) # Generate a 16-byte key
	if debug: print("Generated Key (hex): ", key.hex_encode())
	return key.hex_encode()





#var aes = AESContext.new()
#func move_me():
	##var key = "My secret key!!!" # Key must be either 16 or 32 bytes.
	#var data = "My secret text!!" # Data size must be multiple of 16 bytes, apply padding if needed.
	## Encrypt ECB
	#aes.start(AESContext.MODE_ECB_ENCRYPT, key.to_utf8_buffer())
	#var encrypted = aes.update(data.to_utf8_buffer())
	#aes.finish()
	## Decrypt ECB
	#aes.start(AESContext.MODE_ECB_DECRYPT, key.to_utf8_buffer())
	#var decrypted = aes.update(encrypted)
	#aes.finish()
	## Check ECB
	#assert(decrypted == data.to_utf8_buffer())
	#if debug: print("data: ", decrypted.get_string_from_utf8())





	##var key = "My secret key!!!" # Key must be either 16 or 32 bytes.
	#var data = "My secret text!!" # Data size must be multiple of 16 bytes, apply padding if needed.
	## Encrypt ECB
	#aes.start(AESContext.MODE_ECB_ENCRYPT, key)
	#var encrypted = aes.update(data.to_utf8_buffer())
	#aes.finish()
	## Decrypt ECB
	#aes.start(AESContext.MODE_ECB_DECRYPT, key)
	#var decrypted = aes.update(encrypted)
	#aes.finish()
	## Check ECB
	#assert(decrypted == data.to_utf8_buffer())
	#if debug: print("data: ", decrypted.get_string_from_utf8())
	
	
	
	
	
	
	
	#var crypto = Crypto.new()
	#var key = "your_secret_key"  # Replace with a secure, unique key
	#var data = "some_tag_data"  # The data you want to encrypt
#
	#var encrypted = crypto.encrypt(key.sha256_buffer(), data.to_utf8())
	#var decrypted = crypto.decrypt(key.sha256_buffer(), encrypted)
#
	#if debug: print("Encrypted: ", encrypted.hex_encode())
	#if debug: print("Decrypted: ", decrypted.get_string_from_utf8())
	
	
	
	
	#var crypto = Crypto.new()
	#var key = crypto.generate_rsa(1024)
	#if debug: print("KEY: ", key)
	#return key
	##var hasher = HashingContext.new()
	##hasher.start(HashingContext.HASH_SHA256)
	##hasher.update(username.to_utf8())
	##var hashed_username = hasher.finish()
	##return hashed_username.hex_encode()


func pad_data(data: PackedByteArray) -> PackedByteArray:
	# Calculate padding needed to reach the next 16-byte boundary
	var padding_needed = 16 - (data.size() % 16)
	if padding_needed == 16:
		padding_needed = 0  # Data is already a multiple of 16
	# Apply padding (this is a simplified example; actual padding schemes may vary)
	for _i in range(padding_needed):
		data.append(padding_needed)
	return data

# Example usage
var tag = "example_tag".to_utf8_buffer()
var padded_tag = pad_data(tag)
# Now you can encrypt 'padded_tag'


func create_folders(dir: String, scene_folder_path: String) -> void:
	if not DirAccess.dir_exists_absolute(dir + scene_folder_path):
		DirAccess.make_dir_recursive_absolute(dir + scene_folder_path)


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
#endregion


# This function is called when the selection changes
func _on_selection_changed():
	pass
	#get_visible_scene_view_buttons()
	###### SNAP FLUSH GLUE
	## Clear Snap Flush Scene instances NOTE can also use find_child()
	#for node in EditorInterface.get_edited_scene_root().get_children():
		#if node is MeshInstance3D or node is StaticBody3D:
			#var node_children = node.get_children()
			#for node_child in node_children:
				#if node_child.name.begins_with("SnapFlush_"):
					#node.remove_child(node_child)

	#selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	#for node in selected_nodes:
		#if node is Node3D:
			#pass

	#call_deferred("remove_scene_preview_if_not_selected")
	#clear_ray_cast_3d_nodes()

#func update_scene_preview(value) -> void:
	#scene_preview = value


#func get_scene_preview() -> String:
	#return scene_preview


# NOTE called from scene_view.gd
#func set_scene_preview(scene_path: String) -> void:
#func set_scene_preview(value) -> void:
	#scene_preview = value
	#var existing_preview = get_tree().get_root().find_child("ScenePreview", true, false)
	#if existing_preview:
		#existing_preview.get_parent().remove_child(existing_preview)
		#scene_preview = null
#
	#create_scene_preview()


## TEMP DISABLED
#func filter_nodes_for_snap_flush(node: Node3D) -> void:
#
	#var node_children = node.get_children()
	#
	#if node is MeshInstance3D:
		#snap_flush_scene = SNAP_FLUSH.instantiate()
		#snap_flush_scene.selection_has_collision = false
		#create_snap_flush(node)
		#
	#else:
		#pass
#
	#for node_child in node_children:
		#if node_child is CollisionShape3D:
			#snap_flush_scene = SNAP_FLUSH.instantiate()
			#snap_flush_scene.selection_has_collision = true
#
			#
		#else:
			#pass
#
#
#func create_snap_flush(node: Node3D) -> void:
	#node.add_child(snap_flush_scene)
	#snap_flush_scene.name = "SnapFlush_" + node.name
	#snap_flush_scene.owner = node
	##snap_flush_scene.selection_is_valid = true


func multi_select_nodes() -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	for node in selected_nodes:
		last_selected_nodes.append(node)

	if multi_select_enabled:
		for node in selected_nodes:
			if not last_selected_nodes.has(node):
				last_selected_nodes.append(node)
	else:
		last_selected_nodes.clear()
	### Add a RayCast3D node to each newly selected node
	for last_node in last_selected_nodes:
		if last_node is StaticBody3D:
			EditorInterface.get_selection().add_node(last_node)


# NOTE NOT USED FIXME FIND BEST SOLUTION WAS CAUSING ERRORS NOW THAT REMOVING WHEN NOT SCENE_PREVIEW_ACTIVE = FALSE
func remove_scene_preview_if_not_selected():
	await get_tree().create_timer(3.0).timeout
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selected_nodes.has(scene_preview_mesh):
		pass
	else:
		scene_preview_3d_active = false
		#remove_existing_scene_preview()
		# Find and remove ScenePreview
		var existing_preview = get_tree().get_root().find_child("ScenePreview", true, false)
		if existing_preview:
			existing_preview.get_parent().remove_child(existing_preview)
			# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
			existing_preview.queue_free()
			scene_preview = null


# FIXME BROKEN NOT WORKING
func current_viewport_window(screen_name: String) -> void:
	if screen_name == "3D":
		editor_viewport_3d_active = true
	else:
		editor_viewport_3d_active = false


# FIXME Rename associated nodes
func apply_multi_node_collisions(current_state: String) -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	var skip_collision: bool = false
	for node: Node in selected_nodes:
		if node is StaticBody3D or node is RigidBody3D or node is CharacterBody3D:
			var collision_node_instances: Array[Node] = node.find_children("*", "CollisionShape3D", true, false)
			for collision_shape_3d: CollisionShape3D in collision_node_instances:
				collision_shape_3d.free()
			# NOTE Need to hook into existing code Redundant code from func match_collision_state()
			#if debug: print("current_collision_3d_state: ", current_collision_3d_state)
			#if debug: print("current_state: ", current_state)
			var mesh_node_instances: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
			var shape_3d: Shape3D = null
			match current_state:
				#"NO_COLLISION":
					#skip_collision = true
				"SPHERESHAPE3D":
					shape_3d = SphereShape3D.new()
				"BOXSHAPE3D":
					shape_3d = BoxShape3D.new()
				"CAPSULESHAPE3D":
					shape_3d = CapsuleShape3D.new()
				"CYLINDERSHAPE3D":
					shape_3d = CylinderShape3D.new()
				"SIMPLIFIED_CONVEX", "SINGLE_CONVEX", "MULTI_CONVEX", "TRIMESH":
					shape_3d = null

			if not skip_collision:
				apply_collision(node, mesh_node_instances, shape_3d, false)


func apply_multi_node_body_type(current_type_3d: String) -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	for node: Node in selected_nodes:
		#if debug: print("NODE: ", node.get_path())
		if debug: print("node.name: ", node.name)
		# NOTE CAN SEARCH THE FILESYSTEM TREE FOR THE MATCHING NAME BUT SEEMS BRITTLE OR WOULD BE SLOW
#		var node_instance = load(node.get_path())#.instantiate()
		var node_position: Vector3 = node.global_transform.origin
		if debug: print("NODE FIRST CHILD: ", node.get_child(0))
		if node is StaticBody3D or node is RigidBody3D or node is CharacterBody3D:
			var physics_body_3d: PhysicsBody3D
			match current_type_3d:
				"STATICBODY3D":
					
					physics_body_3d = StaticBody3D.new()
					#physics_body_3d.name = node.name
					#physics_body_3d.position = node_position
					node.replace_by(physics_body_3d, true)
					#EditorInterface.get_selection().add_node(physics_body_3d)

				"RIGIDBODY3D":
					physics_body_3d = RigidBody3D.new()
					node.replace_by(physics_body_3d, true)


				"CHARACTERBODY3D":
					physics_body_3d = CharacterBody3D.new()
					node.replace_by(physics_body_3d, true)

			physics_body_3d.name = node.name
			physics_body_3d.position = node_position
			# Add the newly created nodes to the selection
			EditorInterface.get_selection().add_node(physics_body_3d)







var dragging_node: Node = null
#var rotated: bool = false
var scaled: bool =  false
var duplicate_dragging_node: bool = false
var dragging_node_duplicate: Node = null

func _input(event: InputEvent) -> void:
	
	# If duplicate is created switch selection to duplicate
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_D):
		# Give time for duplicate to be created
		await get_tree().process_frame
		if dragging_node != null: # Switch selected node to new duplicate node
			var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
			for node: Node in selected_nodes:
				# FIXME 
				#if node is MeshInstance3D:
					
				if node is Node3D:# or node is MeshInstance3D:
					if debug: print("setting dragged node to new duplicate node")
					# OR SIMULATE CTRL AND D KEY IF dragging_node != null AND LEFT MOUSE CLICK?
					dragging_node = node
					duplicate_dragging_node = true
					#scene_preview = node
					#scene_preview_3d_active = true
					#create_scene_preview()
					

	if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_E):
		object_rotated = true
		if debug: print("hello")
	if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_R):
		scaled = true
		
	## make this function work in scene_viewer transfer to scenesnapglobal or connect somehow
	##if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_Q):
	#if Input.is_key_pressed(KEY_Q):
		#EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
		#scene_preview_3d_active = not scene_preview_3d_active
		#if not node_pinning_enabled:
			#pinned_node == null
		#if not scene_preview_3d_active:
			#
			##if pinned_node != null:
				#
			##if node_to_place_under != null:
				##change_selection_to(node_to_place_under)
			## Find and remove ScenePreview
			##node_to_place_under = null
			#var existing_preview = get_tree().get_root().find_child("ScenePreview", true, false)
			#if existing_preview:
				#existing_preview.get_parent().remove_child(existing_preview)
				#scene_preview = null
		#else: # Recreate the ScenePreview on MOUSE_BUTTON_LEFT and KEY_Q pressed
			#initialize_scene_preview = true
			##node_to_place_under = null
			#create_scene_preview()



	if event is InputEventMouseButton:

		## FIXME WORKS ALSO WHEN NOT OVER THE PANEL ALSO CANNOT SCALE SCRIPT TEXT SIZE AS A RESULT
#
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_CTRL):
			##get_tree().get_root().set_input_as_handled()
			#scene_viewer_panel_instance.zoom_v_slider.value -= 10
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_CTRL):
			##get_tree().get_root().set_input_as_handled()
			#scene_viewer_panel_instance.zoom_v_slider.value += 10



		# Quick scroll for collision shape swap
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_C):
			pass
			#apply_multi_node_collisions()



# TEST
		# Quick scroll for collision shapes
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_C):
			get_tree().get_root().set_input_as_handled()
			scene_viewer_panel_instance.toggle_3d_collision_state_down()

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_C):
			get_tree().get_root().set_input_as_handled()
			scene_viewer_panel_instance.toggle_3d_collision_state_up()

		# Quick scroll for body types
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_B):
			get_tree().get_root().set_input_as_handled()
			scene_viewer_panel_instance.toggle_physics_body_type_down()


		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_B):
			get_tree().get_root().set_input_as_handled()
			scene_viewer_panel_instance.toggle_physics_body_type_up()


		# Quick scroll for materials
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_M):
			get_tree().get_root().set_input_as_handled()
			#if current_sub_tab:
				#if debug: print("disabling scroll mode now")
				#current_sub_tab.scroll_container.vertical_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_DISABLED
				#current_sub_tab.scroll_container.set_vertical_scroll_mode = 0 # SCROLL_MODE_DISABLED = 0
			scene_viewer_panel_instance.cycle_material(1)
			#scene_viewer_panel_instance.toggle_material_override_down()


		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_M):
			get_tree().get_root().set_input_as_handled()
			scene_viewer_panel_instance.cycle_material(-1)
			#scene_viewer_panel_instance.toggle_material_override_up()


		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_M):
			get_tree().get_root().set_input_as_handled()
			# FIXME if white reset to white if blue reset to blue
			scene_viewer_panel_instance.set_default_material()
			#scene_viewer_panel_instance._on_default_material_button_pressed()






		#if Input.is_key_pressed(KEY_Q):
			#if debug: print("hello")
		# NOTE: Hold Q for quick relocation of objects with snapping
		# TODO Clean up
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_Q):
			if not node_pinning_enabled:
				pinned_node == null
			# Cancel scene_preview if active
			if scene_preview_3d_active:
				scene_preview_3d_active = false
				remove_existing_scene_preview()


			## Load scene data for snapping
			#add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
			#remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
			# Remove last duplicate if Left mouse and Q 
			if dragging_node != null and duplicate_dragging_node:
				dragging_node.queue_free()
				duplicate_dragging_node = false
				return # Without getting new drag node
				


			if dragging_node != null:
				dragging_node = null
				duplicate_dragging_node = false
				#dragging_node_duplicate = null
			else:
				# HACK implement proper left mouse button released
				await get_tree().create_timer(0.2).timeout
				var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
				for node: Node in selected_nodes:
					# FIXME 
					#if node is MeshInstance3D:
						
					if node is Node3D:# or node is MeshInstance3D:
						if debug: print("setting dragged node2")
						dragging_node = node


		# FIXME Getting node not found in scene tree when deleting initial node that is duplicated from 
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			
			if dragging_node != null: 


				if duplicate_dragging_node: # Make additional duplicates even easier by not requiring CTRL + D
					var dragging_node_name: String = dragging_node.name
					dragging_node = dragging_node.duplicate()
					EditorInterface.get_edited_scene_root().add_child(dragging_node)
					dragging_node.owner = EditorInterface.get_edited_scene_root()
					## Add scene_preview under pinned node
					#await reparent_to_selected_node(dragging_node)
					for child: Node in dragging_node.get_children():
						child.owner = EditorInterface.get_edited_scene_root()
					
					
					dragging_node.name = dragging_node_name # Keep original name




				#if duplicate_dragging_node: # Make additional duplicates even easier by not requiring CTRL + D
					#dragging_node_duplicate = dragging_node.duplicate()
					#EditorInterface.get_edited_scene_root().add_child(dragging_node_duplicate)
					#dragging_node_duplicate.set_owner(EditorInterface.get_edited_scene_root())
					### Add scene_preview under pinned node
					##await reparent_to_selected_node(dragging_node_duplicate)
					#for child: Node in dragging_node_duplicate.get_children():
						#child.set_owner(EditorInterface.get_edited_scene_root())
					#
					#
					#dragging_node_duplicate.name = dragging_node.name # Keep name




				else: # Place non duplicate dragging_node
					if debug: print("deactivating dragging")
					dragging_node = null
			
			
			## Place non duplicate dragging_node
			#if dragging_node != null:
				#if debug: print("deactivating dragging")
				#dragging_node = null
					
			
					
				#await get_tree().create_timer(1).timeout
				#simulate_keypress(KEY_Q, true)
				#simulate_keypress(KEY_Q, false)
				##if rotated or scaled:
					##await get_tree().create_timer(0.1).timeout
					##simulate_keypress(KEY_Q, true)
					##scaled = false
					##rotated = false
			#if object_rotated:
				#object_rotated = false
				#simulate_keypress(KEY_Q, true)
				#simulate_keypress(KEY_Q, false)
#
#
			#if object_rotated or scaled:
				##await get_tree().create_timer(0.5).timeout
				###if debug: print("de setting keyQ")
				#scaled = false
				#object_rotated = false
				##if debug: print("simulating KEY Q")
				#await get_tree().create_timer(1).timeout
				#simulate_keypress(KEY_Q, true)
				#simulate_keypress(KEY_Q, false)







		# make this function work in scene_viewer transfer to scenesnapglobal or connect somehow
		# TODO Needs cleanup
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_Q):
			
			# Set the material to the default material for the selected scene when scene_preview activated
			# FIXME Follow default through collection?
			#if scene_viewer_panel_instance.current_material_index == -1:
				#if debug: print("setting index")
			#scene_viewer_panel_instance._on_default_material_button_pressed()
			# Cancel dragging_node if active
			if dragging_node != null:
				dragging_node = null
				duplicate_dragging_node = false
			
			get_visible_scene_view_buttons()

			EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
			scene_preview_3d_active = not scene_preview_3d_active
			if not node_pinning_enabled:
				pinned_node == null
			if not scene_preview_3d_active:
				remove_existing_scene_preview()

			else: # Recreate the ScenePreview on MOUSE_BUTTON_LEFT and KEY_Q pressed
				update_scene_preview_and_visible_buttons()



		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and not Input.is_key_pressed(KEY_E):
			# Toggle between these when mouse middle button pressed
			snap_normal_round = !snap_normal_round
		
		

			
			#simulate_keypress(KEY_Q, true)
		
		# TODO FIXME In window popup mode will get stuck cycling the current tab even after switching to new tab
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_SHIFT):
			
			#get_tree().get_root().set_input_as_handled()
			#EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
			
			if scene_preview_3d_active:
				get_tree().get_root().set_input_as_handled()
				EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
				if update_visible_scenes: # updated once when cycling begins and reset to check again when anything other then shift key is pressed
					if debug: print("running get_visible_scene_view_buttons")
					get_visible_scene_view_buttons()
					update_visible_scenes = false

				cycle_scene_focus("up")


		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_SHIFT):
			
			if scene_preview_3d_active:
				if debug: print("cycling")
				get_tree().get_root().set_input_as_handled()
				EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
				if update_visible_scenes:
					get_visible_scene_view_buttons()
					update_visible_scenes = false
				cycle_scene_focus("down")


		if not Input.is_key_pressed(KEY_SHIFT):
			update_visible_scenes = true
			quick_scroll_enabled = false


		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_SHIFT):
			#quick_add_to_favorites()


#region Input Rotation

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_E):
			EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
			rotation_15 = !rotation_15 # flip state

			if not rotation_15:
				#TODO make value adjustable
				rotation_value = 2
			else:
				rotation_value = 15

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_E):
			input_rotation("clockwise", rotation_value)

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_E):
			input_rotation("counterclockwise", rotation_value)
#endregion

#region Input Scaling

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_R):
			EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
			scale_5 = !scale_5 # flip state

			if not scale_5:
				#TODO make value adjustable / by whole number or * by fraction
				scale_reduction_value = 50
			else:
				scale_reduction_value = 5

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) and Input.is_key_pressed(KEY_R):
			input_scale("up", scale_reduction_value)

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN) and Input.is_key_pressed(KEY_R):
			input_scale("down", scale_reduction_value)
#endregion



		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and Input.is_key_pressed(KEY_E):
			
			# reparent child(0), move pivotnode3d to center of scene, make pivotnode3d parent again 
			#if debug: print("change state")
			change_pivot_point_position()


		# Change rotation point (snap_point, center, end)
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and Input.is_key_pressed(KEY_E):
			pass



# Writing an EditorPlugin, is it possible to 'select' a different node in the scene tree inside of a tool script? (LydianAlchemist)
# Reference: https://www.reddit.com/r/godot/comments/chyne5/writing_an_editorplugin_is_it_possible_to_select/?rdt=40046
func change_selection_to(child:Node):
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(child)





## Get all the buttons in the collection 
func get_visible_scene_view_buttons() -> void:
	current_visible_buttons.clear()  # Clear the current list at the start
	
	var main_tabs: Array[Node] = scene_viewer_panel_instance.main_tab_container.get_children()
	
	for tab in main_tabs:
		if tab.visible:
			if tab.name == "Favorites" or tab.name == "Project Scenes":
				#await get_tree().process_frame # Required for when in popup window
				check_button_visible(tab)
			#elif tab.name == "Project Scenes":
				#check_button_visible(tab)
			else:
				var sub_tabs: Array[Node] = tab.sub_tab_container.get_children()
				#var sub_tabs: Array[Node] = tab.find_child("SubTabContainer", true, false).get_children()
				#await get_tree().process_frame # Required for when in popup window
				for sub_tab: Control in sub_tabs:
					check_button_visible(sub_tab)


# TODO REPLACE WITH
# MAYBE get_file()
#String get_file() const
#If the string is a valid file path, returns the file name, including the extension.
#var file = "/path/to/icon.png".get_file() # file is "icon.png"

# FIXME TODO Replace code in scene_viewer.gd where this is better option FIXME Currently node names and scene names have a 2 appended???
# FIXME TODO Should added nodes follow the CamelCase convention of naming nodes??
## Get the last string in scene_full_path, remove the extension and return.
# NOTE CURRENTLY NOT USED HERE
func get_scene_name(scene_full_path: String) -> String:
	#var scene_name = scene_full_path.split("/")[-1]
	var scene_name = scene_full_path.get_file()
	return scene_name.rstrip("." + scene_name.get_extension())


## From all the buttons in the collection get just the ones that are visible
func check_button_visible(tab: Node) -> void:
	var collection_scene_views: Array[Node] = tab.h_flow_container.get_children()
	#var collection_scene_views: Array[Node] = tab.find_child("HFlowContainer", true, false).get_children()
	for scene_view_button in collection_scene_views:
		if scene_view_button is Button:
			
			## Add decrypted scene view button tags array to scene_tags Dictionary for snapping in process_snap_flow_manager_connections()
			##var extension: String = 
			## Get the last string in scene_full_path
			#var scene_name = scene_view_button.scene_full_path.split("/")[-1]
			## Remove the extension
			#scene_name = scene_name.rstrip("." + scene_name.get_extension())
			#if debug: print("scene_name[-1].get_extension(): ", scene_name[-1].get_extension())
			#if debug: print("scene_name[-1]: ", scene_name[-1])
			##rstrip(scene_name[-1].get_extension())
			#if debug: print("scene_view_button.scene_full_path: ", scene_view_button.scene_full_path)
			#if debug: print("get_scene_name(scene_view_button.scene_full_path): ", get_scene_name(scene_view_button.scene_full_path))
			#scene_tags[get_scene_name(scene_view_button.scene_full_path)] = scene_view_button.tags

			#scene_tags[scene_view_button.name] = scene_view_button.tags
			#if debug: print("scene_view_button: ", scene_view_button)
		
			if scene_view_button.is_visible_in_tree():# and not current_visible_buttons.has(scene_view_button):
				current_visible_buttons.append(scene_view_button)
				#if debug: print("current scene view button: ", scene_view_button)

	var scenes: Array[Node] = current_visible_buttons
	pass_down_scene_number_to_scene_buttons(scenes)

	#pass_down_scene_number_to_scene_buttons(current_visible_buttons.duplicate())


func cycle_scene_focus(direction: String) -> void:
	
	quick_scroll_enabled = true
	var main_container = scene_viewer_panel_instance.main_tab_container
	
	EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	
	var scenes: Array[Node] = current_visible_buttons

# TEST OKAY PASSED
	for scene in scenes:
		if debug: print("scene name: ", scene.name, " scene number: ", scene.scene_number)
# TEST

	if debug: print("scenes.size(): ", scenes.size())
	if debug: print("here are the scene buttons that are visible: ", scenes)
	#pass_down_scene_number_to_scene_buttons(scenes)
	
	if scenes.size() == 0: # TODO FIXME ADD EXCEPTIONS FOR WHEN ALL SCENES ARE FILTERED OUT
		pass 
		#push_warning("No visible scenes available, or Scene Viewer Panel not open. Please select a scene or open a collection of scenes within the Scene Viewer. \
		#\n TIP: Undock Scene Viewer Panel to enable Scene Quick Scroll (SHIFT+Scroll Wheel) even when Scene Viewer is not visible.")
		return  # Exit if there are no scenes
	
	# Ensure scene_number is within valid bounds
	#scene_number = clamp(scene_number, 0, scenes.size() - 1)
	var clamped_scene_number: int = clamp(scene_number, 0, scenes.size() - 1)
	scene_number = clamped_scene_number
	if debug: print("scene_number: ", scene_number)

	# Use modulo to handle cycling through scenes
	#scene_number = (scene_number + scenes.size()) % scenes.size()
	
	# Ensure scene_number is within bounds after possible adjustment
	if scene_number >= scenes.size() or scene_number < 0:
		if debug: print("Invalid scene_number:", scene_number)
		return

	match direction:
		"up":
			#if debug: print("scene_number: ", scene_number)
			scene_number = (scene_number - 1 + scenes.size()) % scenes.size()
			#if debug: print("scene_number2: ", scene_number)
			#if debug: print("scene_number: ", scene_number)
		"down":
			#if debug: print("scene_number: ", scene_number)
			scene_number = (scene_number + 1) % scenes.size()
			#if debug: print("scene_number2: ", scene_number)

	# FIXME Number gets messed up if filtering so must refresh order number?
	# FIXME RESET SELECTED BUTTON ON KEY -Q AND RIGHT MOUSE
	# Sets button in focus to selected_scene_view_button on quick cycle
	selected_scene_view_button = scenes[scene_number] # FIXME may not be required here after moving things to snap flow manager
	if debug: print("selected_scene_view_button: ",selected_scene_view_button)
	# Pass to snap_flow_manager_graph.gd to process tags for snapping
	snap_flow_manager_graph.selected_scene_view_button = scenes[scene_number]
	
	if selected_scene_view_button:
		
# NOTE MAYBE MORE STABLE CURRENT SETUP DOES NOT WORK FOR BUTTONS CREATED AFTER START AND ONLY CONNECT TO SIGNALS ON START
		for main_tab: Control in main_container.get_children():
			var main_tab_index: int = main_tab.get_index()
			if main_tab_index == main_container.current_tab:
				match main_tab.name:
					"Project Scenes":
						scene_viewer_panel_instance.new_main_project_scenes_tab.scroll_container.ensure_control_visible(selected_scene_view_button)
					"Favorites":
						#scene_viewer_panel_instance.favorites.scroll_container.ensure_control_visible(selected_scene_view_button)
						scene_viewer_panel_instance.new_favorites_tab.scroll_container.ensure_control_visible(selected_scene_view_button)
						
					#"Global Collections", "Shared Collections":
					_:  # NOTE: Or connect to selected_sub_tab_changed signal tab to replace main_tab.sub_tab_container.get_current_tab()
						var current_sub_tab: Control = main_tab.sub_tab_container.get_child(main_tab.sub_tab_container.get_current_tab())
						current_sub_tab.scroll_container.ensure_control_visible(selected_scene_view_button)


		selected_scene_view_button.grab_focus()


# NOTE: What purpose did this serve? Breaks cycling of filtered scenes when not in popup window mode.
# I think it was HACK to grab focus but not needed with above line.
		#simulate_keypress(KEY_ENTER, true)
		#simulate_keypress(KEY_ENTER, false)


		#if scene_viewer_panel_instance.set_default_material:
			#scene_viewer_panel_instance._on_default_material_button_toggled(true)



#func quick_add_to_favorites() -> void:
	#scene_viewer_panel_instance.add_scene_button_to_favorites(current_scene_path, true)
	#if debug: print("scene_viewer_panel_instance: ", scene_viewer_panel_instance)

## Fill the scene_view.gd scene_number variable with its index in the scenes Array
func pass_down_scene_number_to_scene_buttons(scenes: Array[Node]) -> void:
	for scene in scenes:
		#scene.pass_up_scene_number.connect(update_selected_scene_number)
		#if debug: print("finding scene: ", scenes.find(scene))
		scene.scene_number = scenes.find(scene)
		
	
func update_selected_scene_number(button_scene_number: int) -> void:
	scene_number = button_scene_number
	#if debug: print("changed scene_number to: ", scene_number)



func full_path_split(scene_full_path: String) -> PackedStringArray:
	var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 0)
	return scene_full_path_split


#func get_scene_name(scene_full_path: String, no_extension: bool) -> String:
	#var scene_name: String = scene_full_path.get_file()
	#if no_extension:
		#scene_name = scene_name.substr(0, scene_name.length() - (scene_name.get_extension().length() + 1)) # Remove extension + 1 for the "."
#
	#return scene_name



# FIXME create dir if not exists
func copy_file(dir: DirAccess, origin_file_path: String, path_to_copy_file: String) -> bool:
	if dir:
		if dir.file_exists(path_to_copy_file): # Skip copy if file exists
			#push_warning("Skipping... file already exists at: ", path_to_copy_file)
			return true
		else: # Copy over file
			#if debug: print("copying file from ", origin_file_path, " to ", path_to_copy_file)
			if dir.copy(origin_file_path, path_to_copy_file) != OK:
				printerr("Failed to copy file from ", origin_file_path, " to ", path_to_copy_file)
				return false
		# Scan the filesystem to update
		#if not origin_file_path.get_extension() == "glb":
		var editor_filesystem = EditorInterface.get_resource_filesystem()
		editor_filesystem.scan()
		#if debug: print("filesystem was scanned")
		return true
	else:
		printerr("The directory: ", dir, " is not valid")
		return false


func snake_to_pascal_with_seperation(snake_case_string: String) -> String:
	snake_case_string.to_pascal_case()
	# Split the string into words
	var words = snake_case_string.split(" ")
	var result = ""

	for word in words:
		if word.strip_edges() != "":
			# Capitalize the first letter and add the rest in lowercase
			result += word.capitalize() + " "
	
	# Remove the trailing space and return
	return result.strip_edges()



#func to_pascal_case_with_spaces(input: String) -> String:
	#input.to_pascal_case()
	## Split the string into words
	#var words = input.split(" ")
	#var result = ""
#
	#for word in words:
		#if word.strip_edges() != "":
			## Capitalize the first letter and add the rest in lowercase
			#result += word.capitalize() + " "
#
	## Remove the trailing space and return
	#return result.strip_edges()


#enum State {
	#STATE_ONE,
	#STATE_TWO,
	#STATE_THREE
#}
#
#func toggle_state(current_state: int):
	#match current_state:
		#State.STATE_ONE:
			#current_state = State.STATE_TWO
		#State.STATE_TWO:
			#current_state = State.STATE_THREE
		#State.STATE_THREE:
			#current_state = State.STATE_ONE
			#
#var current_state: State = State.STATE_ONE
##toggle_state()

#enum Collision_State {
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
#var NO_COLLISION
#var SPHERESHAPE3D
#var BOXSHAPE3D
#var CAPSULESHAPE3D
#var CYLINDERSHAPE3D
#var SIMPLIFIED_CONVEX
#var SINGLE_CONVEX
#var MULTI_CONVEX
#var TRIMESH

#func toggle_collision_state():

#func get_collision_3d_state(current_state: String) -> void:
	#current_collision_3d_state = current_state
	#if debug: print(current_state)
	#match current_state:
		#"NO_COLLISION":
			#if debug: print("NO_COLLISION")
		#"SPHERESHAPE3D":
			#if debug: print("THIS is SPHERESHAPE3D")
		#"BOXSHAPE3D":
			#if debug: print("BOXSHAPE3D")
		#"CAPSULESHAPE3D":
			#if debug: print("CAPSULESHAPE3D")
		#"CYLINDERSHAPE3D":
			#if debug: print("CYLINDERSHAPE3D")
		#"SIMPLIFIED_CONVEX":
			#if debug: print("SIMPLIFIED_CONVEX")
		#"SINGLE_CONVEX":
			#if debug: print("SINGLE_CONVEX")
		#"MULTI_CONVEX":
			#if debug: print("MULTI_CONVEX")
		#"TRIMESH":
			#if debug: print("TRIMESH")



#func get_body_3d_type(current_type: String) -> void:
	#current_body_3d_type = current_type









## Reference Mesh_lod_generator plugin (Martin LOUVEL)
#func generate_lods_for_mesh(mesh: MeshInstance3D, lod_bias: float = 0.5, normal_merge_angle: float = 25, normal_split_angle: float = 60):
	#var original_mesh = mesh.mesh
	#if not original_mesh:
		#return
	#var importer := ImporterMesh.new()
	#var surface_count = original_mesh.get_surface_count()
	#for i in range(surface_count):
		#var surface_arrays = original_mesh.surface_get_arrays(i)
		#if surface_arrays.is_empty():
			#continue
		#importer.add_surface(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
		#importer.generate_lods(normal_merge_angle, normal_split_angle, Array())
	#mesh.mesh = importer.get_mesh()
	#mesh.lod_bias = lod_bias


# Reference Mesh_lod_generator plugin (Martin LOUVEL)
func generate_lods(lod_bias: float = 0.5, normal_merge_angle: float = 25, normal_split_angle: float = 60):
	var scene = EditorInterface.get_edited_scene_root()
	var mesh_node_instances: Array[Node] = scene.find_children("*", "MeshInstance3D", true, false)

	for mesh_node: MeshInstance3D in mesh_node_instances:
		var original_mesh = mesh_node.mesh
		if not original_mesh:
			return
		var importer := ImporterMesh.new()
		var surface_count = original_mesh.get_surface_count()
		for i in range(surface_count):
			var surface_arrays = original_mesh.surface_get_arrays(i)
			if surface_arrays.is_empty():
				continue
			importer.add_surface(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
			importer.generate_lods(normal_merge_angle, normal_split_angle, Array())
		mesh_node.mesh = importer.get_mesh()
		mesh_node.lod_bias = lod_bias


# TODO Check this function to find duplicate code that can be combined
func place_scene(scene_to_place: Node3D, scene_preview: Node3D, scene_name: String) -> void:
	# Add the scene to the tree and set owner 
	if not create_as_scene:
		# FIXME This gets done twice once at beginning of chain
		var physics_body_3d: Node3D
		# TODO Pass down bodytype so not doing another check here
		if debug: print("this is the body type: ", current_body_3d_type)
		match current_body_3d_type:
			
			"NO_PHYSICSBODY3D":
				if debug: print("THIS FIRED")
				### TODO CHECK FOR MULTIPLE MESH CHILD FUNCTIONALITY
				#EditorInterface.get_edited_scene_root().add_child(scene_to_place)
				#scene_to_place.owner = EditorInterface.get_edited_scene_root()
#
				#for child: Node3D in scene_to_place.get_children():
#
					#if make_unique:
						#make_mesh_material_unique(child)
#
					#child.owner = null
					#scene_to_place.remove_child(child)
					#
					#EditorInterface.get_edited_scene_root().add_child(child)
					#child.set_owner(EditorInterface.get_edited_scene_root())
					#
					#await reparent_to_selected_node(child)
#
					#child.name = scene_name
#
					## Set placed scene to same location and rotation as scene preview
					## NOTE To correct for some .fbx x axis -90 rotation and 100x scale
					#child.rotation = Vector3(child.rotation.x, scene_preview.rotation.y, scene_preview.rotation.z)
					#child.global_transform.origin = scene_preview.global_transform.origin
#
				#scene_to_place.queue_free()
#
				#return




				## TODO CHECK FOR MULTIPLE MESH CHILD FUNCTIONALITY
				EditorInterface.get_edited_scene_root().add_child(scene_to_place)
				scene_to_place.owner = EditorInterface.get_edited_scene_root()

				#scene_to_place.rotation = Vector3(scene_to_place.rotation.x, scene_preview.rotation.y, scene_preview.rotation.z)
				#scene_to_place.global_transform.origin = scene_preview.global_transform.origin

				return



			"NODE3D":
				physics_body_3d = Node3D.new()
			"STATICBODY3D":
				physics_body_3d = StaticBody3D.new()
			"RIGIDBODY3D":
				physics_body_3d = RigidBody3D.new()
			"CHARACTERBODY3D":
				physics_body_3d = CharacterBody3D.new()


		EditorInterface.get_edited_scene_root().add_child(physics_body_3d)
		
		
		physics_body_3d.owner = null



		await reparent_to_selected_node(physics_body_3d)
		#var selected_node_size: int = EditorInterface.get_selection().get_selected_nodes().size()
		#if selected_node_size == 1:
			#for selected_node: Node in EditorInterface.get_selection().get_selected_nodes():
				#if selected_node.name == "ScenePreview":# and selected_node.get_parent() == node_to_place_under:
					#if debug: print("selected_node: ", selected_node)
					#physics_body_3d.reparent(node_to_place_under)
#
		#else:
			#physics_body_3d.reparent(EditorInterface.get_edited_scene_root())
		
		
		
		
		physics_body_3d.set_owner(EditorInterface.get_edited_scene_root())
		
		
		
		#physics_body_3d.owner = EditorInterface.get_edited_scene_root()

		EditorInterface.get_edited_scene_root().add_child(scene_to_place)
		scene_to_place.owner = EditorInterface.get_edited_scene_root()
		
		#if make_unique:
			#scene_to_place.duplicate(true)
		
		for child: Node3D in scene_to_place.get_children():
			
			if make_unique:
				make_mesh_material_unique(child)
			
			child.owner = null
			scene_to_place.remove_child(child)
			
			EditorInterface.get_edited_scene_root().add_child(child)
			child.set_owner(EditorInterface.get_edited_scene_root())
			
			child.reparent(physics_body_3d)

		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		scene_to_place.queue_free()
		
		


		#physics_body_3d.name = scene_name
#
		## Set placed scene to same location and rotation as scene preview
		#physics_body_3d.global_transform.origin = scene_preview.global_transform.origin
		#physics_body_3d.global_transform.basis = scene_preview.global_transform.basis
		#
		## Add to total tri scene tri count for mesh snapping
		#var mesh_node_instances: Array[Node] = physics_body_3d.find_children("*", "MeshInstance3D", true, false)
		#for mesh_child: MeshInstance3D in mesh_node_instances:
			#add_global_tris(mesh_child)
#
			#if not mesh_child.tree_exited.is_connected(remove_global_tris):
				#mesh_child.tree_exited.connect(remove_global_tris.bind(mesh_child))

		set_object_position_and_add_mesh_tris(physics_body_3d, scene_name)


	else:
		
		## FIXME LEFT OFF HERE
		#var physics_body_3d: Node3D
		## TODO Pass down bodytype so not doing another check here 
		#match current_body_3d_type:
			#"NO_PHYSICSBODY3D":
				### TODO CHECK FOR MULTIPLE MESH CHILD FUNCTIONALITY
				#EditorInterface.get_edited_scene_root().add_child(scene_to_place)
				#scene_to_place.owner = EditorInterface.get_edited_scene_root()
				#
				##if make_unique:
					##scene_to_place.duplicate(true)
				#
				#for child: Node3D in scene_to_place.get_children():
					#
					#
					#if make_unique:
						#make_mesh_material_unique(child)
					#
					#
					#child.owner = null
					#scene_to_place.remove_child(child)
					#
					#EditorInterface.get_edited_scene_root().add_child(child)
					#child.set_owner(EditorInterface.get_edited_scene_root())
					#
					#await reparent_to_selected_node(child)
#
					#child.name = scene_name
#
#
					## Set placed scene to same location and rotation as scene preview
					#child.global_transform.origin = scene_preview.global_transform.origin
					##child.global_transform.basis = scene_preview.global_transform.basis
					#
				#scene_to_place.queue_free()
#
				#return
		#
			#_:
				#if make_unique:
					#for child: Node3D in scene_to_place.get_children():
						#make_mesh_material_unique(child)






		EditorInterface.get_edited_scene_root().add_child(scene_to_place)




		#if make_unique:
			#scene_to_place.duplicate(true)

		await reparent_to_selected_node(scene_to_place)

# FIXME TODO Implement
#if make_unique:
#if child is CollisionShape3D:
	#child.shape = child.shape.duplicate(true)
#if child is MeshInstance3D:
	#child.mesh = child.mesh.duplicate(true)



		scene_to_place.owner = EditorInterface.get_edited_scene_root()





		## Change node name from ScenePreview to scene's file name
		#scene_to_place.name = scene_name
		##EditorInterface.get_edited_scene_root().set_editable_instance(scene_to_place, true)
#
		## Set placed scene to same location and rotation as scene preview
		#scene_to_place.global_transform.origin = scene_preview.global_transform.origin
		#scene_to_place.global_transform.basis = scene_preview.global_transform.basis
#
		## Add to total tri scene tri count for mesh snapping
		#var mesh_node_instances: Array[Node] = scene_to_place.find_children("*", "MeshInstance3D", true, false)
		#for mesh_child: MeshInstance3D in mesh_node_instances:
			#add_global_tris(mesh_child)
#
			## Connect tree_exit signal to remove tris when node is deleted
			#if not mesh_child.tree_exited.is_connected(remove_global_tris):
				#mesh_child.tree_exited.connect(remove_global_tris.bind(mesh_child))

		set_object_position_and_add_mesh_tris(scene_to_place, scene_name)

# TODO: REMOVE add mesh tris from name since no longer doing that here
# FIXME carry over scale of scene_preview children mesh and collision shapes to object NOTE: What about just using duplicate? because just preview not built up object scene
# Create scale function that both use rather then copying over scale in var that will keep value between cycling previews
func set_object_position_and_add_mesh_tris(object: Node3D, scene_name: String) -> void:
	if debug: print("scene_preview children: ", scene_preview.get_children())
	if debug: print("object children: ", object.get_children())
	if debug: print("object: ", object)
	# FIXME See if this can be put here
	#EditorInterface.get_edited_scene_root().add_child(object)
	#object.set_owner(EditorInterface.get_edited_scene_root())
	if debug: print("scene name: ", scene_name)

	object.name = scene_name

	# FIXED TO ADJUST FOR ROOT NODE OFFSETS
	# var mesh = scene_preview.get_child(0) as MeshInstance3D
	# Set placed scene to same location scale and rotation as scene preview
	object.global_transform.origin = scene_preview.get_child(0).global_transform.origin

	# FIXME Transfer over and set meta from scene preview to object

	# FIXME 
	# Set placed scene to same location scale and rotation as scene preview
	#object.global_transform.origin = scene_preview.global_transform.origin
	# Factor in if object already scaled Ex. for some .fbx imports

	# NOTE: GodotJolt Little exclamation mark warning, but it looks like it can be safely ignored.
	# Reference: https://github.com/godotengine/godot/issues/5734#issuecomment-2220778601 (hmans)
	object.scale *= scene_preview.scale
	
###################### KEEP 
	#set_scale(object)
###################### KEEP 
	
	# Set placed scene to same location and rotation as scene preview adjust for .fbx importes with 90x
	object.rotation = Vector3(object.rotation.x, scene_preview.rotation.y, scene_preview.rotation.z)

	
# TEST if meta is retained from preview to now
	if object.has_meta("extras"):
		var metadata: Dictionary = object.get_meta("extras")
		if debug: print("metadata: ", metadata)

	
	embed_decrypted_global_tags_in_scene(object)

	#if not selected_scene_view_button:
		#get_visible_scene_view_buttons()
	#if current_visible_buttons:
		# FIXME Will need to be fix if on KEY_Q and right mouse click instance other then first in collection
		# TODO Change to focused button probably better??
		#selected_scene_view_button = current_visible_buttons[0]



	#if not selected_scene_view_button:
		#get_visible_scene_view_buttons()
	#if current_visible_buttons:
		## FIXME Will need to be fix if on KEY_Q and right mouse click instance other then first in collection
		## TODO Change to focused button probably better??
		##selected_scene_view_button = current_visible_buttons[0]
#
		#var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(object)
		##await get_tree().process_frame
		## When placing just mesh
		#if not first_mesh_node:
			#first_mesh_node = object
		#if first_mesh_node.has_meta("extras"):
			#var metadata: Dictionary = first_mesh_node.get_meta("extras")
			## Overwrite encrypted global tags with decrypted plain text tags
			#metadata["global_tags"] = selected_scene_view_button.global_tags
			##metadata["global_tags"] = selected_scene_view_button.global_tags
			#first_mesh_node.set_meta("extras", metadata)
			#if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))






	### TODO Duplicate code can be made into function
	#var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(object)
	##await get_tree().process_frame
		## When placing just mesh
	#if not first_mesh_node:
		#first_mesh_node = object
	#if first_mesh_node.has_meta("extras"):
		#var metadata: Dictionary = first_mesh_node.get_meta("extras")
		## Copy the metadata over from the scene_preview to the placed_scene_object
		#first_mesh_node.set_meta("extras", scene_preview.get_meta("extras"))
		#if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))


	#var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(object)
	##await get_tree().process_frame
	#if first_mesh_node.has_meta("extras"):
		#var metadata: Dictionary = first_mesh_node.get_meta("extras")
		#metadata["global_tags"] = selected_scene_view_button.global_tags
		#first_mesh_node.set_meta("extras", metadata)
		#if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))




	#if object is MeshInstance3D:
		#add_global_tris(object)
#
		#if not object.tree_exited.is_connected(remove_global_tris):
			#object.tree_exited.connect(remove_global_tris.bind(object))
	#else:
		## Add to total tri scene tri count for mesh snapping
		#var mesh_node_instances: Array[Node] = object.find_children("*", "MeshInstance3D", true, false)
		#for mesh_child: MeshInstance3D in mesh_node_instances:
			#if debug: print("adding tris")
			#add_global_tris(mesh_child)
#
			#if not mesh_child.tree_exited.is_connected(remove_global_tris):
				#mesh_child.tree_exited.connect(remove_global_tris.bind(mesh_child))


## Adds tags to the scene preview for placing and again added to the scene when it is placed in the environment for other objects to be snapped to it.
func embed_decrypted_global_tags_in_scene(scene: Node3D) -> void:
	if not selected_scene_view_button:
		get_visible_scene_view_buttons()
	if current_visible_buttons:
		# FIXME Will need to be fix if on KEY_Q and right mouse click instance other then first in collection
		# TODO Change to focused button probably better??
		#selected_scene_view_button = current_visible_buttons[0]

		if debug: print("scene children: ", scene.get_children())
		# .glb has not mesh node children and itself is not a mesh node?  is this right?
		# NOTE: This is run twice. once when creating scene preview and again when placing the scene.
		# The second time however the children is []?
		# Why did this work before and not now? what changed?? should this even be running for scenes found within the collection folder
		# they already have global tags embeded right?
		# Also why is this not finding the mesh node the scens have them? but the scene preview always pulls from the user://??
		# so why issue here?
		if debug: print("scene.scene_file_path: ", scene.scene_file_path)
		var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene)
		#var first_mesh_node: Node3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene)
		# NOTE: For when placing just MeshInstance3D
		# NOTE: FIXME Breaks when run on scenes created in project collections and also crashes godot
		if not first_mesh_node:
			#await get_tree().process_frame # Retry
			#first_mesh_node = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene)
			#if not first_mesh_node:
			if scene is MeshInstance3D:
				first_mesh_node = scene
			else:
				push_warning("A mesh node could not be found for this scene.")

		if first_mesh_node.has_meta("extras"):
			var metadata: Dictionary = first_mesh_node.get_meta("extras")
			## Combine shared_tags and decrypted global_tags into one Array[String]
			#var tags: Array[String] = selected_scene_view_button.shared_tags
			#for tag: String in selected_scene_view_button.global_tags:
				#if not tags.has(tag):
					#tags.append(tag)

			# Remove encrypted global_tags and shared_tags since not required
			metadata.erase("shared_tags")
			metadata.erase("global_tags")
			#metadata["tags"] = tags
			metadata["tags"] = selected_scene_view_button.tags

			first_mesh_node.set_meta("extras", metadata)

			if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))





func make_mesh_material_unique(child: Node) -> void:
	#if child is CollisionShape3D:
		#child.shape = child.shape.duplicate(true)
	if child is MeshInstance3D:
		child.mesh = child.mesh.duplicate(true)
		# Create duplicate material for each surface material on the mesh
		for material_index: int in child.mesh.get_surface_count():
			var material_dup =  child.mesh.surface_get_material(material_index).duplicate(true)
			child.mesh.surface_set_material(material_index, material_dup)



#func set_owner_recursive(node: Node, owner: Node):
	#for child in node.get_children():
		#child.owner = EditorInterface.get_edited_scene_root()
		#set_owner_recursive(child, owner)

# FIXME modify for embeded .glb in new scenes


## Save the scene to the project dir save_path and create a scene_view_button. Return the newly created scene in project dir to place in viewport
func save_and_instantiate_scene(new_scene_to_place: Node, save_path: String) -> Node:

	var packed_scene = PackedScene.new()
	#var new_scene_dup = new_scene_to_place.duplicate()
	#EditorInterface.get_edited_scene_root().add_child(new_scene_dup)
	#new_scene_dup.owner = EditorInterface.get_edited_scene_root()



	#scene_root_dup.owner = null
	#var scene_root_dup: Node = new_scene_to_place
	#EditorInterface.get_edited_scene_root().add_child(new_scene_dup)
	#new_scene_dup.owner = EditorInterface.get_edited_scene_root()
	#var scene_root = get_editor_interface().get_edited_scene_root()
	#scene_root_dup.owner = EditorInterface.get_edited_scene_root()
	#scene_root_dup.owner = scene_root_dup
	#set_owner_recursive(scene_root_dup, scene_root_dup.owner)
	#packed_scene.pack(new_scene_dup) # FIXME THIS IS MY ISSUE HERE pack() Any existing data will be cleared
	



	# FIXED: Mesh was not owned by PhysicsBody3D parent node so was not packed. NOTE: (pack() function -> Packs the path node, and all owned sub-nodes)
	for child: Node in new_scene_to_place.get_children():
		child.owner = new_scene_to_place

	packed_scene.pack(new_scene_to_place)
	if debug: print("After packing: ", new_scene_to_place.get_children())


	#packed_scene.pack(new_scene_to_place) # FIXME THIS IS MY ISSUE HERE pack() Any existing data will be cleared
	
	#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
	ResourceSaver.save(packed_scene, save_path)


	# Create scene view button
	# TODO ADD FLAGS FOR BODY COLLISION AND LODS TO DISPLAY ICONS ON BUTTON
	var new_scene_view: Button = null
	var loaded_scene: PackedScene = load(save_path)
	#scene_viewer_panel_instance.create_scene_buttons(loaded_scene, save_path, scene_viewer_panel_instance.new_main_project_scenes_tab, new_scene_view, false)
	scene_viewer_panel_instance.create_scene_buttons(save_path, scene_viewer_panel_instance.new_main_project_scenes_tab, new_scene_view, false)

	# Scan the filesystem to update
	var editor_filesystem = EditorInterface.get_resource_filesystem()
	if not editor_filesystem.is_scanning():
		editor_filesystem.scan()

	var loaded_scene_instance = loaded_scene.instantiate()
	if debug: print("loaded_scene children: ", loaded_scene_instance.get_children())
	#return loaded_scene.instantiate()
	return loaded_scene_instance





				#if scene_full_path.get_extension() == "obj":
					#var obj_scene = load(scene_full_path)
					#var new_mesh_instance_3d: MeshInstance3D = MeshInstance3D.new()
					#new_mesh_instance_3d.set_mesh(obj_scene)
					#var packed_scene = PackedScene.new()
					#packed_scene.pack(new_mesh_instance_3d)
					#var scene_name: String = "temp_obj_scene"
					#var path_to_save_scene: String = "res://collections/project/"
					#var save_path: String = path_to_save_scene.path_join(scene_name + ".tscn")
					#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_RELATIVE_PATHS)
					#scene_full_path = save_path
					#new_mesh_instance_3d.queue_free()












#func move_col_children(mesh_node: MeshInstance3D) -> void:
	## Move StaticBody3D collision children under root node
	#var mesh_node_parent: Node = mesh_node.get_parent()
	#for col_child: CollisionShape3D in mesh_node.get_child(0).get_children():
		#mesh_node.get_child(0).remove_child(col_child)
		#col_child.owner = null
#
		#if mesh_node_parent:
			#mesh_node_parent.add_child(col_child)
			#col_child.owner = mesh_node_parent
		##else:
			##mesh_node.add_sibling(col_child)
			##col_child.owner = 
#
		### FIXME GodotPhysics cannot handle scaling the collision apply on import?
		### Set scale rotation and position of collisions to match mesh_node 
		##col_child.scale = mesh_node.scale
		##col_child.rotation_degrees = mesh_node.rotation_degrees
		##col_child.position = mesh_node.position
#
#
	## Remove the StaticBody3D generated by create_multiple_convex_collisions() NOTE: queue_free() not removing StaticBody3D
	#mesh_node.get_child(0).free()


# ORIGINAL
func primitive_collision(mesh_node: MeshInstance3D, new_scene_to_place: Node, shape_3d: Shape3D, expanded_mesh: ArrayMesh, mesh_instance_3d_node: MeshInstance3D) -> void:
	var collision_shape_3d = CollisionShape3D.new()
	
	collision_shape_3d.shape = shape_3d
	#collision_shape_3d.name = new_scene_to_place.name + "_collision"
	new_scene_to_place.add_child(collision_shape_3d)
	collision_shape_3d.set_owner(new_scene_to_place)
	collision_shape_3d.rotation = mesh_node.rotation

	var mesh_aabb: AABB
	
	if expanded_mesh == null:
		mesh_aabb = mesh_node.mesh.get_aabb()
		collision_shape_3d.position = mesh_aabb.get_center()
	else:
		mesh_aabb = expanded_mesh.get_aabb()
		collision_shape_3d.position = Vector3(mesh_aabb.get_center().x, mesh_aabb.get_center().z, - mesh_aabb.get_center().y)
		# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
		mesh_instance_3d_node.queue_free()


	if shape_3d is SphereShape3D:
		shape_3d.radius = mesh_aabb.get_longest_axis_size() / 2

	if shape_3d is BoxShape3D:
		shape_3d.size = mesh_aabb.size

	if shape_3d is CapsuleShape3D or shape_3d is CylinderShape3D:
		if mesh_node.rotation == Vector3.ZERO:
			
			shape_3d.height = mesh_aabb.size.y
			# Get the largest axis on the base of the object and set the radius
			if mesh_aabb.size.x >= mesh_aabb.size.z:
				shape_3d.radius = mesh_aabb.size.x / 2
			else:
				shape_3d.radius = mesh_aabb.size.z / 2

		else: # For some .FBX imported mesh that are rotated -90 on x axis
			collision_shape_3d.rotation = Vector3.ZERO
			# Set height relative to the -90x rotated mesh which now has z up
			shape_3d.height = mesh_aabb.size.z
			
			if mesh_aabb.size.x >= mesh_aabb.size.y:
				shape_3d.radius = mesh_aabb.size.x / 2
			else:
				shape_3d.radius = mesh_aabb.size.y / 2





#@export var mesh_node: MeshInstance3D
#@export var expansion_factor: float = 100.0  # The factor by which the mesh will be expanded


#var expansion_factor: float = 100.0
# FIXME Collision are being added to scenes that already have collisions if mesh and collision count == skip
func apply_collision(new_scene_to_place: Node, mesh_node_instances: Array[Node], shape_3d: Shape3D, preview: bool) -> void:
	# FIXME For scenes with more then 1 mesh and more then 1 child
	var mesh_instance_3d_node = MeshInstance3D.new()
	var expanded_mesh = ArrayMesh.new()
	var scaled_mesh: bool = false

	if mesh_node_instances.size() == 1 and new_scene_to_place.get_child_count() == 1:
		for mesh_node: MeshInstance3D in mesh_node_instances:

			# NOTE Section required by some .fbx files with 100x scale
			# Ensure the mesh_node is valid and is of type ArrayMesh
			if mesh_node and mesh_node.mesh is ArrayMesh:

				if mesh_node.scale != Vector3.ONE:
					scaled_mesh = true
					
					var original_mesh = mesh_node.mesh as ArrayMesh
					
					# Create a new ArrayMesh and MeshDataTool
					#var expanded_mesh = ArrayMesh.new()
					var mdt = MeshDataTool.new()
					var surface_count = original_mesh.get_surface_count()
					
				# Iterate through each surface in the mesh
					for surface_index in range(surface_count):
						# Create MeshDataTool from the current surface
						mdt.create_from_surface(original_mesh, surface_index)

						var vertex_count = mdt.get_vertex_count()

						# Expand the vertices for this surface
						for i in range(vertex_count):
							var vertex = mdt.get_vertex(i)
							# Expand the vertex by the expansion factor
							#vertex *= expansion_factor
							vertex *= mesh_node.scale
							mdt.set_vertex(i, vertex)

						# If the expanded mesh is empty, commit the first surface, otherwise append the surface
						if surface_index == 0:
							expanded_mesh.clear_surfaces()
							mdt.commit_to_surface(expanded_mesh, surface_index)
						else:
							mdt.commit_to_surface(expanded_mesh, surface_index)


					mesh_instance_3d_node.set_mesh(expanded_mesh)
				
				else:
					scaled_mesh = false
					mesh_instance_3d_node = mesh_node


				match current_collision_3d_state:
					"SPHERESHAPE3D", "BOXSHAPE3D", "CAPSULESHAPE3D", "CYLINDERSHAPE3D":
						if scaled_mesh:
							primitive_collision(mesh_node, new_scene_to_place ,shape_3d, expanded_mesh, mesh_instance_3d_node)
						else:
							expanded_mesh = null
							primitive_collision(mesh_node, new_scene_to_place ,shape_3d, expanded_mesh, mesh_instance_3d_node)
						return

					"SIMPLIFIED_CONVEX":
						mesh_instance_3d_node.create_convex_collision(true, true)

					"SINGLE_CONVEX":
						mesh_instance_3d_node.create_convex_collision(false, false)

					"MULTI_CONVEX": # FIXME "Multiple Convex" shape very small and giving ERROR: res://addons/scene_snap/scene_snap_plugin.gd:3722 - Trying to assign invalid previously freed instance.
						var settings = MeshConvexDecompositionSettings.new()

						# NOTE Default values with max_concavity = 0 and max_convex_hulls = 32 (gives same result as UI Create Collision Shape)
						settings.convex_hull_approximation = true
						settings.convex_hull_downsampling = 4
						settings.max_concavity = 0
						settings.max_convex_hulls = 32
						settings.max_num_vertices_per_convex_hull = 32
						settings.min_volume_per_convex_hull = 0.0001
						settings.mode = MeshConvexDecompositionSettings.Mode.CONVEX_DECOMPOSITION_MODE_VOXEL
						settings.normalize_mesh = false
						settings.plane_downsampling = 4
						settings.project_hull_vertices = true
						settings.resolution = 10000
						settings.revolution_axes_clipping_bias = 0.05
						settings.symmetry_planes_clipping_bias = 0.05

						# Apply the convex decomposition
						mesh_instance_3d_node.create_multiple_convex_collisions(settings)

					"TRIMESH":
						#if not new_scene_to_place is StaticBody3D:
							#push_warning("TRIMESH is intended to be used with StaticBody3D")
							
						mesh_instance_3d_node.create_trimesh_collision()

# FIXME IF SOMETHING BREAKS WHEN CREATING SCENE_PREVIEW RE-ENABLE THIS
# Error about mesh already ahve parent node 3d
				#EditorInterface.get_edited_scene_root().add_child(mesh_instance_3d_node)

# Built in functions create_convex and create_trimesh create StaticBody3D nodes and then add respective collision shapes to that
				# FIXME Somewhere is creating an extra StaticBody3d NODE named MESH_col 
				# Get the collision shape created by one of the built in functions above
				if debug: print("mesh_instance_3d_node children: ", mesh_instance_3d_node.get_children())
				# NOTE: Get all collision shapes generated above. Remove the CollisionShape3D and reparent them to the scene_preview mesh node
				for child: CollisionShape3D in mesh_instance_3d_node.get_child(0).get_children():


					if debug: print("child collision: ", child)


					child.set_owner(null)
					mesh_instance_3d_node.get_child(0).remove_child(child)

					#if not preview: # FIXME THIS PREVENTS FROM MAKING ONE PASS OF THIS FUNC FOR BOTH PREVIEW AND PLACEMENT
						#pass
					# FIXME REMOVE WHEN PLACED REQUIRED BEFORE THEN. Remove the StaticBody3D generated by one of the built in functions above
					# QUEUE_FREE WILL STILL ADD AS CHILD
					# 
					#mesh_instance_3d_node.get_child(0).free()

					child.name = new_scene_to_place.name + "_collision"
					# Add the collision shape back in as a child of the new scenes root node
					EditorInterface.get_edited_scene_root().add_child(child)
					
					child.set_owner(EditorInterface.get_edited_scene_root())

					child.reparent(mesh_node.get_parent())
					child.set_owner(mesh_node.get_parent())

					# Set collision shape's transform rotation and scale based on the original mesh
					child.position = mesh_node.position
					child.rotation_degrees = mesh_node.rotation_degrees
					child.scale = mesh_node.scale

					## Remove the StaticBody3D generated by one of the built in functions above
					#mesh_instance_3d_node.get_child(0).queue_free()
					#mesh_instance_3d_node.queue_free()
				
				# After looping through and getting all the CollisionShape3D remove StaticBody3D
				# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
				mesh_instance_3d_node.get_child(0).free()





#
				#if preview:
					##EditorInterface.get_edited_scene_root().add_child(mesh_instance_3d_node)
					#for child: CollisionShape3D in mesh_instance_3d_node.get_child(0).get_children():
#
#
### TEST
						##child.set_owner(null)
						###child.get_parent().remove_child(child)
						##mesh_instance_3d_node.get_child(0).remove_child(child)
						##
						###child.name = new_scene_to_place.name + "_collision"
						##EditorInterface.get_edited_scene_root().add_child(child)
						##
						##child.set_owner(EditorInterface.get_edited_scene_root())
#
#
#
#
						#child.reparent(mesh_node.get_parent())
						#child.set_owner(mesh_node.get_parent())
#
						## Set collision shape's transform based on the original mesh
						#child.position = mesh_node.position
						#child.rotation_degrees = mesh_node.rotation_degrees
						#
						#mesh_instance_3d_node.queue_free()
				#else:
##					EditorInterface.get_edited_scene_root().add_child(mesh_instance_3d_node)
#
					#
					#for child: CollisionShape3D in mesh_instance_3d_node.get_child(0).get_children():
						##mesh_instance_3d_node.get_child(0).remove_child(child)
						#child.set_owner(null)
						##child.get_parent().remove_child(child)
						#mesh_instance_3d_node.get_child(0).remove_child(child)
						#
						##child.name = new_scene_to_place.name + "_collision"
						#EditorInterface.get_edited_scene_root().add_child(child)
						#
						#child.set_owner(EditorInterface.get_edited_scene_root())
#
#
						#child.reparent(mesh_node.get_parent())
						#child.set_owner(mesh_node.get_parent())
#
						## Set collision shape's transform based on the original mesh
						#child.position = mesh_node.position
						#child.rotation_degrees = mesh_node.rotation_degrees
#
						#mesh_instance_3d_node.queue_free()
				##return
#







# WARNING DO NOT DELETE ###################################################################################################################################################
						## FIXME NOTE Quaternious assets import with scaling consider applying scale to tscn_static_body root and 
						## clearing scale on children. because the mesh scales fine, but the CollisionShape3D is not scaled
						#
#
						## Create trimesh collision children for all MeshInstance3D in scene
						#var animation_player_node_instances: Array[Node] = new_scene_to_place.find_children("*", "AnimationPlayer", true, false)
						#
						#
						## Do check if collision count matches mesh count # TODO Modify for 2D
						#var has_collision_shape: bool = collision_node_instances.size() == mesh_node_instances.size()
#
						#
						#for mesh_child: MeshInstance3D in mesh_node_instances:
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
								#new_scene_to_place.add_child(collision_shape)
								#collision_shape.set_owner(new_scene_to_place)
#
								#if debug: print("Added CollisionShape3D for: ", mesh_child.name)
#
#
#
# WARNING DO NOT DELETE ###################################################################################################################################################
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
#
#
							#if track_count != 0 and animation_player_node_instances.size() >= 1 or mesh_node_instances.size() > 1: # NOTE track_count != 0 is not needed with above queue_free() but left in
								#var remote_transform_3d = RemoteTransform3D.new()
								#remote_transform_3d.name = mesh_child.name + "_remote_transform"
								#mesh_child.add_child(remote_transform_3d)
								#remote_transform_3d.set_owner(new_scene_to_place)
								#if not has_collision_shape:
									#var collision_shape_path: NodePath = remote_transform_3d.get_path_to(collision_shape)
									#remote_transform_3d.set_remote_node(collision_shape_path)
								#if debug: print("PLACEHOLDER FOR CREATING ANIMATIONPLAYER ICON ON BUTTON")
						#
						#
						#
						#
						#if debug: print("TRIMESH")
# WARNING DO NOT DELETE ###################################################################################################################################################









## Function to get the AABB after scaling
#func get_scaled_aabb(mesh_node: MeshInstance3D) -> AABB:
	## Get the AABB of the mesh without transformation
	#var raw_aabb = mesh_node.mesh.get_aabb()
#
	## Get the scale of the MeshInstance3D node
	#var scale = mesh_node.scale
#
	## Apply the scale to the raw AABB
	#var scaled_min = raw_aabb.position * scale
	#var scaled_max = (raw_aabb.position + raw_aabb.size) * scale
#
	## Create the new AABB using the scaled min and max values
	#var scaled_aabb = AABB(scaled_min, scaled_max - scaled_min)
#
	#return scaled_aabb



# Function to get transformed AABB after scaling and rotation
func get_transformed_aabb(mesh_node: MeshInstance3D) -> AABB:
	# Get the mesh's original AABB
	var original_aabb = mesh_node.mesh.get_aabb()
	
	# Get the current transformation (which includes position, rotation, scale)
	var transform = mesh_node.mesh.transform
	
	# Manually scale and rotate the AABB
	var scale_factor = Vector3(100, 100, 100)  # Scale by 100
	var rotation = Transform3D().rotated(Vector3(1, 0, 0), deg_to_rad(-90))  # Rotate -90 degrees on the X axis
	
	# Apply the scale and rotation to the original AABB
	var transformed_aabb = AABB(Vector3.ZERO, original_aabb.size)
	transformed_aabb = rotation.xform(transformed_aabb)  # Rotate AABB
	transformed_aabb = transformed_aabb * scale_factor  # Scale AABB
	
	# Optionally, you could take the AABB relative to the world position
	# transformed_aabb.position += transform.origin
	
	return transformed_aabb



func match_collision_state(new_scene_to_place: Node, scene_name: String, save_path: String, loaded_from_project_dir: bool) -> void:
	#if debug: print("new_scene_to_place: ", new_scene_to_place)
	# NOTE DO ALL EDITS TO BASE SCENE BEFORE PLACING INTO SCENE EXAMchange_collision_shape_3dPLE: COLLISIONS - CONVERTING TO RIGIDBODY - ADDING LODS - 
	# TODO OPTIONS FOR ADDING EACH OF THE DIFFERENT COLLISION MESH FLAGS HERE

	# FIXME TODO CAUTION FOR SIMEPLE NODE WITH NO COLLISION GOES TO ELSE. MAY NEED TO BE FINXED 
	if new_scene_to_place and enable_collisions:
		if debug: print("followed this path")
		#var scene_with_no_collision: Node3D = null
		#var tscn_static_body: StaticBody3D = null
		var shape_3d: Shape3D = null
		
		# FIXME how many checks for finding the mesh children? #1
		var mesh_node_instances: Array[Node] = new_scene_to_place.find_children("*", "MeshInstance3D", true, false)
		if debug: print("mesh_node_instances: ", mesh_node_instances)
		#var collision_node_instances: Array[Node] = new_scene_to_place.find_children("*", "CollisionShape3D", true, false)
		match current_collision_3d_state:
			#"NO_COLLISION":
				## FIXME Warning about not having collision on PhysicsBody3D
				#if save_path == "none": # Gate to stop scene_preview from continuing
					#return
				#await get_tree().process_frame
				#for collision_node: Node in collision_node_instances:
					#collision_node.free()
				#await get_tree().process_frame
				#place_scene(new_scene_to_place, scene_preview, scene_name)
				#return
			# NOTE If adding collision shape must also convert root node to PhysicsBody
			"SPHERESHAPE3D":
				shape_3d = SphereShape3D.new()
			"BOXSHAPE3D":
				shape_3d = BoxShape3D.new()
			"CAPSULESHAPE3D":
				shape_3d = CapsuleShape3D.new()
			"CYLINDERSHAPE3D":
				shape_3d = CylinderShape3D.new()
			"SIMPLIFIED_CONVEX", "SINGLE_CONVEX", "MULTI_CONVEX", "TRIMESH":
				shape_3d = null


		
		if save_path == "none": # For Scene_Preview
			apply_collision(new_scene_to_place, mesh_node_instances, shape_3d, true)
			return # Scene preview gets returned here, FIXME reuse
		else: # For Scenes being placed after click # FIXME need to only do once to remove redundant processing
			apply_collision(new_scene_to_place, mesh_node_instances, shape_3d, false)

		##if save_path == "none": # Gate to stop scene_preview from continuing
			##return
		## FIXME Here we need to inject the scene preview into newly created scene
		## Create .tscn from the scene and save it into collection/project folder
		#if not loaded_from_project_dir:
			## FIXME MESH IS LOST HERE.
			#if debug: print("new_scene_to_place chidlren1: ", new_scene_to_place.get_children())
			#new_scene_to_place = save_and_instantiate_scene(new_scene_to_place, save_path)
			#if debug: print("new_scene_to_place chidlren2: ", new_scene_to_place.get_children())
#
		#place_scene(new_scene_to_place, scene_preview, scene_name)

	else:
		if debug: print("NO followed this path")
		if save_path == "none": # Gate to stop scene_preview from continuing
			return
		#await get_tree().process_frame
		#for collision_node: Node in collision_node_instances:
			#collision_node.free()
		#await get_tree().process_frame
		# Create .tscn from the scene and save it into collection/project folder
	if not loaded_from_project_dir:
		#if debug: print("this here ran")
		
		new_scene_to_place = save_and_instantiate_scene(new_scene_to_place, save_path)
	place_scene(new_scene_to_place, scene_preview, scene_name)


#func get_scene_name_physics_body_extender(new_scene_to_place: Node) -> String:
	#if new_scene_to_place:
		#var name_extender: String
		#if new_scene_to_place is Node2D:
			#var physics_body_2d: PhysicsBody2D
			#match current_body_2d_type:
				#"STATICBODY2D":
					#name_extender = "no"
				#"RIGIDBODY2D":
					#name_extender = "no"
				#"CHARACTERBODY2D":
					#name_extender = "no"
		#if new_scene_to_place is Node3D:
			#var physics_body_3d: PhysicsBody3D
			#match current_body_3d_type:
				#"STATICBODY3D":
					#name_extender = "no"
				#"RIGIDBODY3D":
					#name_extender = "no"
				#"CHARACTERBODY3D":
					#name_extender = "no"
	#return name_extender
#
#func get_scene_name_collision_type_extender(new_scene_to_place: Node) -> String:
	#if new_scene_to_place:
		#var name_extender: String
#
		#if new_scene_to_place is Node2D:
			#match current_collision_2d_state:
				#"NO_COLLISION":
					#name_extender = "no"
				#"CIRCLESHAPE2D":
					#name_extender = "no"
				#"RECTANGLESHAPE2D":
					#name_extender = "no"
				#"CAPSULESHAPE2D":
					#name_extender = "no"
#
		#if new_scene_to_place is Node3D:
			#match current_collision_3d_state:
				#"NO_COLLISION": 
					#name_extender = "no"
				#"SPHERESHAPE3D":
					#name_extender = "no"
				#"BOXSHAPE3D":
					#name_extender = "no"
				#"CAPSULESHAPE3D":
					#name_extender = "no"
				#"CYLINDERSHAPE3D":
					#name_extender = "no"
				#"SIMPLIFIED_CONVEX":
					#name_extender = "no"
				#"SINGLE_CONVEX":
					#name_extender = "no"
				#"MULTI_CONVEX":
					#name_extender = "no"
				#"TRIMESH":
					#name_extender = "no"
	#return name_extender


#var node_to_place_under: Node = null
#
#func reparent_to_selected_node(scene: Node) -> void:
	#if pinned_node != null:
		#node_to_place_under = pinned_node
		#if debug: print("node_to_place_under: ", node_to_place_under)
	#if node_to_place_under != null:
		#scene.reparent(node_to_place_under)
		#return
#
#
	#for selected_node: Node in EditorInterface.get_selection().get_selected_nodes():
		#if selected_node.name != "ScenePreview":
			#node_to_place_under = selected_node
			#scene.reparent(selected_node)
			#if debug: print("parented to selected_node")
		#else:
			##if node_to_place_under != null:
				##scene_preview.reparent(node_to_place_under)
				##if debug: print("node_to_place_under was null")
			##else:
			#scene.reparent(EditorInterface.get_edited_scene_root())
			##scene.set_owner(EditorInterface.get_edited_scene_root())
			#if debug: print("node_to_place_under was null")



# TODO Check if combined still works
func reparent_to_selected_node(scene: Node) -> void:
	#scene.set_owner(null)

	if node_pinning_enabled and pinned_node != null:
		scene.reparent(pinned_node)
		#scene.set_owner(pinned_node)

	else:
		scene.reparent(EditorInterface.get_edited_scene_root())
	#scene.set_owner(EditorInterface.get_edited_scene_root())


#var last_save_path: String = ""


#func get_save_path() -> String:
	#if save_path:
		#return save_path
#
	#var scene_path: String = scene_viewer_panel_instance.current_scene_path
#
	#var scene_name_no_ext: String = scene_viewer_panel_instance.get_scene_name(scene_path, true)
#
	#var collection_name: String
	##var ext_length: int = scene_path.get_extension().length() + 1 # + 1 for the "."
	#var scene_file_path_split: PackedStringArray = full_path_split(scene_path)
#
	## First do check if save scene to project path exists and if yes instance that and skip below
	## instance scene from user:// -> Edit -> save scene to project path
	#if res_dir: # TODO updating folder name when collection name changes
		#if scene_path.begins_with("res://"):
			#
			## NOTE May need to adjust for scn later
			#if scene_path.get_extension() != "tscn":
				##scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - ext_length)
				#collection_name = "project"
#
		#else: # NOTE Will need to change if decide to support more then .tscn for files in the user:// dir
			## NOTE If not using --tags will end in .tscn so needs to be removed
			##scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - ext_length)
			#collection_name = scene_file_path_split[4].to_snake_case()
#
		## Create Directories if not already scenes with no textures or shared textures will not create directory previously
		#create_folders("res://", "collections".path_join(collection_name))
#
#
#
	#var body_type_map: Dictionary[String, String] = {
		#"NO_PHYSICSBODY3D": "no_body",
		#"NODE3D": "node",
		#"STATICBODY3D": "static",
		#"RIGIDBODY3D": "rigid",
		#"CHARACTERBODY3D": "character"
	#}
#
	#var collision_type_map: Dictionary[String, String] = {
		##"NO_COLLISION": "no_collision",
		#"SPHERESHAPE3D": "sphere",
		#"BOXSHAPE3D": "box",
		#"CAPSULESHAPE3D": "capsule",
		#"CYLINDERSHAPE3D": "cylinder",
		#"SIMPLIFIED_CONVEX": "simplified",
		#"SINGLE_CONVEX": "single",
		#"MULTI_CONVEX": "multi",
		#"TRIMESH": "trimesh"
	#}
#
	## Use the name mapping to create the scene name
	#var body_3d = body_type_map.get(current_body_3d_type, "")
	#var col_3d = collision_type_map.get(current_collision_3d_state, "")
#
	## Construct the save path
	#if body_3d != "" and col_3d != "":
		#save_path = project_scenes_path.path_join(
			#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".tscn")
		#)
	##last_save_path = save_path
	#return save_path










#region CREATE SCENE PREVIEW ORIGINAL WORKING BUT NEEDS REFACTOR
##### ORIGINAL WORKING BUT NEEDS REFACTOR
## TODO REFACTOR SCENEPREVIEW CODE WITH SCENE TO PLACE CODE INTO ONE 
 ## FIXME  CLEANUP FOLLOW FOCUS NOT WORKING FIX 
##@warning_ignore("node_configuration_warning")
## TODO REFACTOR CREATE NEW SCENE ADD GLB AS INSTANCE OF IT, ADD COLLISIONS DIRECTLY TO THE NEW SCENE
## NEW SCENE -> NODE3D
## GLB INSTANCE -----> GLB
## COLLISION --------> COLLISIONSHAPE3D
## CONSIDER SCENE_PREVIEW BEING ONLY MESHINSTANCE3D??? NOT NODE3D IN REFACTOR
## ?? Create mesh library for the previews rather then instancing the scene for performance, but then more memory taken up.
## but it can be saved to disk and referenced from disk. LOD versions?? compressed textures?? Maybe little benefit for complexity?
## Button hover will still need to load in scene, and when placed, but when cycling through mesh will be speed up.
## FIXME TODO CERATE SCENE PREVIEW WITH NODE PARENT FOR SNAPPING OFFSET FUNCTIONALITY
#
## NOTE: 
## 1. - When creating scene preview. If the scene_full_path of the focused button is either .GLTF or .GLB use scene_lookup to get the scene, otherwise load from the project FIXME does not account for file types other then glb and gltf
## 2. - When left mouse click to place scene. If the scene exists in the project filesystem use that, if not save the user:// scene to the res:// dir and use the created scene. -> NOTE: When placing scene we are always using the scene from project collection folder.
#func create_scene_preview():
	##if debug: print("current_collision_3d_state: ", current_collision_3d_state)
	#if initialize_scene_preview:
		#get_visible_scene_view_buttons()
#
	## This section deals with the loading of the scene and naming it according to the selected parameters
## -----------------------> Scene Instance and Placement Section
	#if not scene_preview == null:# and not scene_preview_mesh == null:
#
		#var scene_path: String = scene_viewer_panel_instance.current_scene_path
		#var scene_name_no_ext: String = scene_viewer_panel_instance.get_scene_name(scene_path, true)
		#var new_scene_to_place: Node
		#var loaded_from_project_dir: bool = false
		#var collection_name: String
		#var scene_file_path_split: PackedStringArray = full_path_split(scene_path)
##
		### First do check if save scene to project path exists and if yes instance that and skip below
		### instance scene from user:// -> Edit -> save scene to project path
		#if res_dir: # FIXME TODO updating folder name when collection name changes
			#if scene_path.begins_with("res://"):
				#
				## NOTE May need to adjust for scn later
				#if scene_path.get_extension() != "tscn":
					#collection_name = "project"
#
			#else: # NOTE Will need to change if decide to support more then .tscn for files in the user:// dir
				## NOTE If not using --tags will end in .tscn so needs to be removed
				#collection_name = scene_file_path_split[4].to_snake_case()
#
			## Create Directories if not already. Scenes with no textures or shared textures will not create directory previously
			#create_folders("res://", "collections".path_join(collection_name))
#
			#var body_type_map: Dictionary[String, String] = {
				#"NO_PHYSICSBODY3D": "no_body",
				#"NODE3D": "node",
				#"STATICBODY3D": "static",
				#"RIGIDBODY3D": "rigid",
				#"CHARACTERBODY3D": "character"
			#}
#
			#var collision_type_map: Dictionary[String, String] = {
				##"NO_COLLISION": "no_col",
				#"SPHERESHAPE3D": "sphere",
				#"BOXSHAPE3D": "box",
				#"CAPSULESHAPE3D": "capsule",
				#"CYLINDERSHAPE3D": "cylinder",
				#"SIMPLIFIED_CONVEX": "simplified",
				#"SINGLE_CONVEX": "single",
				#"MULTI_CONVEX": "multi",
				#"TRIMESH": "trimesh"
			#}
#
			## Use the name mapping to create the scene name
			#var body_3d = body_type_map.get(current_body_3d_type, "")
			#var col_3d = collision_type_map.get(current_collision_3d_state, "")
			##var no_body: bool = false
#
			## FIXME for multiple mesh children
			#if body_3d == "no_body":
				#col_3d = "no_col"
#
				## TODO FIXME Must be passed down through stack of functions??
				## FIXME Must be fixed for all scene types
				## FIXME KEEP WITH SCENE_PREVIEW THAT IS ALREADY LOADED OR LOAD IN NEW DATA?
				#if scene_preview.get_child_count() == 1 and scene_preview.get_child(0) is MeshInstance3D:
					#
					## FIXME 
					#for child: MeshInstance3D in scene_preview.get_children():
#
#
## TEMP TEST
						## Construct the save path
						#if body_3d != "" and col_3d != "":
							#save_path = project_scenes_path.path_join(
								#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".scn")
							#)
## TEMP TEST
						### Construct the save path
						##if body_3d != "" and col_3d != "":
							##save_path = project_scenes_path.path_join(
								##collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".glb")
							##)
#
#
#
						#if create_as_scene: # This happens when clicking the mouse
#
							#if res_dir.file_exists(save_path): # Load from the res:// dir if it has been created
								#if debug: print("loading from res://")
								#new_scene_to_place = load(save_path).instantiate()
#
							#else: # Load from the user:// dir and save to res:// dir and then load and use the scene created in the res:// collection folder
								#if debug: print("instancing new scene now")
								## Copy .glb file in and make a child of the no no yes no I don't know just fix
								## Scene_preview loaded into buffer so copy from user:// disk to res:// collection location keep textures embeded
## TEMP TEST copy .glb in directly outside of being embeded
								##copy_file(res_dir, scene_path, save_path)
#
								## Open, name, close, instantiate
								##EditorInterface.open_scene_from_path("res://collections/test/SM_Arc_FirTree_a.glb", true)
								#
								##EditorInterface.open_scene_from_path(scene_path, true)
## TEMP disabled
								#new_scene_to_place = save_and_instantiate_scene(child, save_path)
#
						#else:
#
							#new_scene_to_place = child.duplicate()
#
#
#
#
						#EditorInterface.get_edited_scene_root().add_child(new_scene_to_place)
						#new_scene_to_place.set_owner(EditorInterface.get_edited_scene_root())
						#
#
						#
						#
						#await reparent_to_selected_node(new_scene_to_place)
#
#
#
#
#
#
						#set_object_position_and_add_mesh_tris(new_scene_to_place, child.name)
#
						#return
#
#
				#else: # remove body and collisions make mesh the scene root and place
					#if debug: print("scene_preview.get_child_count() is greater than 1 could not preceed: ", scene_preview.get_child_count())
#
#
#
## TEMP TEST
			## Construct the save path
			#if body_3d != "" and col_3d != "":
				#save_path = project_scenes_path.path_join(
					#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".scn")
				#)
## TEMP TEST
			### Construct the save path
			##if body_3d != "" and col_3d != "":
				##save_path = project_scenes_path.path_join(
					##collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".glb")
				##)
#
#
#
			##if debug: print("this is the save path: ", save_path)
			## TODO Here I need to copy the .glb file into the res:// directory and create inherited scenes from it.
			## NOTE Currently works but creates a new .tscn file that does not inherit from original
			#if res_dir.file_exists(save_path):
			##if res_dir.file_exists(get_save_path()):
				##if debug: print("the file exists loading it")
				#loaded_from_project_dir = true
				## FIXME THE REASON THAT SCENEPREVIEW DOES NOT SEE THE SCENE THAT WILL BE PLACED IS BECAUSE OF THIS SWITCH HERE
				## IT IS ALWAYS GETTING THE PREVIEW FROM THE load(scene_path).instantiate() NOT FOR WHAT IS IN THE RES:// SAVE PATH
				#new_scene_to_place = load(save_path).instantiate()
				##new_scene_to_place = load(get_save_path(scene_path, scene_name, scene_name_split)).instantiate()
#
			#else:
				## Load from scene_lookup TODO FIX BROKEN fallback for non scene_lookup
				#mutex.lock()
				#new_scene_to_place = scene_viewer_panel_instance.scene_lookup[scene_path]
				#mutex.unlock()
				#
				#
				#
				## TEST copy .glb in directly outside of being embeded
				## May need to change default import settings for scenes to not extract textures
## TEST copy .glb in directly outside of being embeded
				##copy_file(res_dir, scene_path, save_path)
## TEMP disabled
				## FIXME BROKEN
				##new_scene_to_place = await scene_viewer_panel_instance.load_scene_instance(scene_path)
#
				#loaded_from_project_dir = false
#
#
##region Not Currently Used Keep For 2D
#
		### NOTE First match body type
		##if new_scene_to_place is Node2D:
			##var physics_body_2d: PhysicsBody2D
			##match current_body_2d_type:
				##"STATICBODY2D":
					##physics_body_2d = StaticBody2D.new()
					##physics_body_2d.name = new_scene_to_place.name
					##new_scene_to_place.replace_by(physics_body_2d)
				##"RIGIDBODY2D":
					##physics_body_2d = RigidBody2D.new()
					###EditorInterface.get_edited_scene_root().add_child(physics_body_2d)
					###physics_body_2d.owner = EditorInterface.get_edited_scene_root()
					##physics_body_2d.name = new_scene_to_place.name
					##new_scene_to_place.replace_by(physics_body_2d)
				##"CHARACTERBODY2D":
					##physics_body_2d = CharacterBody2D.new()
					##physics_body_2d.name = new_scene_to_place.name
					##new_scene_to_place.replace_by(physics_body_2d)
##
			##new_scene_to_place.queue_free()
			##if debug: print("matching3")
			##match_collision_state(physics_body_2d, scene_name_no_ext, save_path, false)
##endregion
#
		#if new_scene_to_place is Node3D:
			#
#
			##var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(new_scene_to_place)
			##if first_mesh_node.has_meta("extras"):
				##var metadata: Dictionary = first_mesh_node.get_meta("extras")
				##metadata["global_tags"] = selected_scene_view_button.global_tags
				##first_mesh_node.set_meta("extras", metadata)
				##if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))
#
#
			##if debug: print("current_body_3d_type: ", current_body_3d_type)
			#var physics_body_3d: Node3D = null
			#if debug: print("this is the body type2: ", current_body_3d_type)
			#match current_body_3d_type:
				#"NO_PHYSICSBODY3D":
					#enable_collisions = false
					#if debug: print("THIS FIRED")
					#new_scene_to_place.name = scene_name_no_ext
					##match_collision_state(new_scene_to_place, scene_name, save_path, true)
					#return
#
				#"NODE3D":
					#enable_collisions = false
					##if not scene_preview_collisions:
						#
					#if not loaded_from_project_dir:
						#physics_body_3d = Node3D.new()
				#"STATICBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = StaticBody3D.new()
#
				#"RIGIDBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = RigidBody3D.new()
#
				#"CHARACTERBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = CharacterBody3D.new()
#
			#if physics_body_3d != null:
				#new_scene_to_place.replace_by(physics_body_3d)
				#physics_body_3d.name = scene_name_no_ext
#
#
			#if loaded_from_project_dir:
				##if debug: print("new_scene_to_place: ", new_scene_to_place)
				#if debug: print("matching2")
				#match_collision_state(new_scene_to_place, scene_name_no_ext, save_path, true)
			#else:
				## FIXME MAYBE HOLD new_scene_to_place AND PLACE THAT?
## CAUTION FIXME new_scene_to_place was being removed for single instance loading. Keep as part of fallback when scene not in scene_lookup or low VRAM setting
				##new_scene_to_place.queue_free()
				#if debug: print("matching1")
				#match_collision_state(physics_body_3d, scene_name_no_ext, save_path, false)
#
	## Reset save path 
	#save_path = ""
#
## -----------------------> Scene_Preview Section
	## FIXME if scene preview skip remove ScenePreview
	## FIXME create new scene view based on focues not index 0
	#if scene_preview == null:
		#var scene_name: String
		#
		#
		#if initialize_scene_preview:
			#if current_visible_buttons.is_empty():
				##push_warning("No visible scenes available, or Scene Viewer Panel not open. Please select a scene or open a collection of scenes within the Scene Viewer. \
				##\n TIP: Undock Scene Viewer Panel to enable Scene Quick Scroll (SHIFT+Scroll Wheel) even when Scene Viewer is not visible.")
				## Reset initialize_scene_preview flag with time for function to finish
				#await get_tree().create_timer(.1).timeout
				#initialize_scene_preview = true
				#return
			#else:
				##if res_dir.file_exists(get_save_path()):
					##scene_preview = load(save_path).instantiate()
				##else:
				## TODO CHECK IF HAS ISSUES WITH GLTF
				## FIXME
				#if current_visible_buttons[scene_number].scene_full_path.get_extension() == "glb" or current_visible_buttons[scene_number].scene_full_path.get_extension() == "gltf":
					## FIXME BROKEN BECAUSE OF DELAY scene_preview_3d_active NOT BEING SET TO TRUE OR IS AND THEN BECAUSE OF DELAY SOMETHING IS SWITHCING IT BACK TO FALSE?
#
## CAUTION IMPORTANT DO NOT REMOVE FALL BACK FOR LOADING DIRECTLY FROM DISK ON MAIN/SINGLE BACKGROUND THREAD 
					### Without thread WORKS BUT BLOCKS MAIN THREAD
					##scene_preview = scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[scene_number].scene_full_path)
					#
## Background load scenes ahead and behind the current index so that can quickly load preview? ca
## if another request comes in and the last is not finished do not run function and keep the current 
#
## TEST pull from scene_lookup[scene_full_path] # Pull from Memory
					## NOTE: Create duplicate so not freeing original when queue_free()
					#mutex.lock()
					#if debug: print("scene_viewer_panel_instance.scene_lookup.size(): ", scene_viewer_panel_instance.scene_lookup.size())
					#scene_preview = scene_viewer_panel_instance.scene_lookup[current_visible_buttons[scene_number].scene_full_path].duplicate()
					#mutex.unlock()
#
#
					## FIXME BROKEN BECAUSE OF DELAY scene_preview_3d_active NOT BEING SET TO TRUE OR IS AND THEN BECAUSE OF DELAY SOMETHING IS SWITHCING IT BACK TO FALSE?
					### With thread
					##scene_preview = await scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[scene_number].scene_full_path)
#
#
					##scene_preview = await scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[scene_number].scene_full_path)
					##scene_preview = await get_scene_instance(current_visible_buttons[scene_number].scene_full_path)
					##await get_scene_instance(current_visible_buttons[scene_number].scene_full_path)
					##var wait_count: int = 0
					##while scene_preview == null:
						##await get_tree().process_frame
						##wait_count += 1
						##if wait_count > 1000:
							##break
#
## As we scroll through scenes they will be loaded one per thread. mutex lock var scene_preview
#
					##await get_tree().process_frame # NOTE: Seems to sometimes crash on start without process_frame
					##task_id = WorkerThreadPool.add_group_task(load_gltf_scene_instances_multi_threaded, gltf_file_paths.size())
#
#
#
					##var task_id: int = WorkerThreadPool.add_task(await get_scene_instance.bind(current_visible_buttons[scene_number].scene_full_path))
					##if debug: print("task_id1: ", task_id)
					##var wait_count: int = 0
					##while scene_preview == null:
					###while not WorkerThreadPool.is_task_completed(task_id):
						##await get_tree().process_frame
						##if debug: print("wait_count: ", wait_count)
						##wait_count += 1
						##if wait_count > 500:
							##break
					##if debug: print("task_id1: ", task_id)
					##WorkerThreadPool.wait_for_task_completion(task_id)
#
#
#
#
#
#
					#
					##if scene_preview == null:
						##await get_tree().create_timer(2).timeout
						##scene_preview = await get_scene_instance(scene_viewer_panel_instance.current_scene_path)
					##var wait_count: int = 0
					##while scene_preview == null:
						##await get_tree().process_frame
						##wait_count += 1
						##if wait_count > 1000:
							##break
					#
					#
					##await get_tree().create_timer(3).timeout
					#if debug: print("scene_preview1: ", scene_preview)
				#else: # Loading from res:// or will break attempting to load non .gltf file from user:// FIXME
					#scene_preview = load(current_visible_buttons[scene_number].scene_full_path).instantiate()
					##scene_name = scene_viewer_panel_instance.file_name_no_ext(scene_viewer_panel_instance.current_scene_path)
				#scene_viewer_panel_instance.current_scene_path = current_visible_buttons[scene_number].scene_full_path
#
		#else:
			##if res_dir.file_exists(get_save_path()):
				##scene_preview = load(save_path).instantiate()
			##else:
			## TODO CHECK IF HAS ISSUES WITH GLTF
			#if scene_viewer_panel_instance.current_scene_path.get_extension() == "glb" or scene_viewer_panel_instance.current_scene_path.get_extension() == "gltf":
#
## CAUTION IMPORTANT DO NOT REMOVE FALL BACK FOR LOADING DIRECTLY FROM DISK ON MAIN/SINGLE BACKGROUND THREAD 
				### Without thread WORKS BUT BLOCKS MAIN THREAD
				##scene_preview = scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
#
## TEST pull from scene_lookup[scene_full_path] # Pull from Memory
				#mutex.lock()
				#scene_preview = scene_viewer_panel_instance.scene_lookup[scene_viewer_panel_instance.current_scene_path].duplicate()
				#mutex.unlock()
#
#
				## FIXME BROKEN BECAUSE OF DELAY scene_preview_3d_active NOT BEING SET TO TRUE
				### With thread
				##scene_preview = await scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
#
#
#
				##scene_preview = await scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
				##scene_preview = await get_scene_instance(scene_viewer_panel_instance.current_scene_path)
				##await get_scene_instance(scene_viewer_panel_instance.current_scene_path)
				##var wait_count: int = 0
				##while scene_preview == null:
					##await get_tree().process_frame
					##wait_count += 1
					##if wait_count > 1000:
						##break
#
#
#
#
#
				##var task_id: int = WorkerThreadPool.add_task(await get_scene_instance.bind(scene_viewer_panel_instance.current_scene_path))
				##if debug: print("task_id2: ", task_id)
				##var wait_count: int = 0
				##while scene_preview == null:
				###while not WorkerThreadPool.is_task_completed(task_id):
					##await get_tree().process_frame
					##if debug: print("wait_count: ", wait_count)
					##wait_count += 1
					##if wait_count > 500:
						##break
				##if debug: print("task_id2: ", task_id)
				##WorkerThreadPool.wait_for_task_completion(task_id)
#
#
#
#
				#
				##if scene_preview == null:
					##await get_tree().create_timer(2).timeout
					##scene_preview = await get_scene_instance(scene_viewer_panel_instance.current_scene_path)
				##var wait_count: int = 0
				##while scene_preview == null:
					##await get_tree().process_frame
					##wait_count += 1
					##if wait_count > 1000:
						##break
				#if debug: print("scene_preview2: ", scene_preview)
				##await get_tree().create_timer(3).timeout
			#else: # Load the .tscn or .scn from the res:// dir # Loading from res:// or will break attempting to load non .gltf file from user:// FIXME
				#scene_preview = load(scene_viewer_panel_instance.current_scene_path).instantiate()
			##scene_name = scene_viewer_panel_instance.file_name_no_ext(scene_viewer_panel_instance.current_scene_path)
#
		#scene_name = scene_viewer_panel_instance.get_scene_name(scene_viewer_panel_instance.current_scene_path, true)
#
#
#
		### FIXME SCENE PREVIEW NEEDS TO HAVE A NODE PARENT AND REFACTOR EVERYTHING BELOW AND 
		##if debug: print("scene_preview.get_children(): ",scene_preview.get_children())
		##
		##if scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview).has_meta("extras"):
		###if scene_preview.get_child(0).has_meta("extras"):
			##if debug: print("new_scene_to_place.get_meta(extras): ", scene_preview.get_child(0).get_meta("extras"))
#
		#embed_decrypted_global_tags_in_scene(scene_preview)
		##if not selected_scene_view_button:
			##get_visible_scene_view_buttons()
		##if current_visible_buttons:
			### FIXME Will need to be fix if on KEY_Q and right mouse click instance other then first in collection
			### TODO Change to focused button probably better??
			###selected_scene_view_button = current_visible_buttons[0]
##
			##var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview)
			###await get_tree().process_frame
			##if first_mesh_node.has_meta("extras"):
				##var metadata: Dictionary = first_mesh_node.get_meta("extras")
				### Overwrite encrypted global tags with decrypted plain text 
				##metadata["global_tags"] = selected_scene_view_button.global_tags
				###metadata["global_tags"] = selected_scene_view_button.global_tags
				##first_mesh_node.set_meta("extras", metadata)
				##if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))
#
#
#
#
#
#
#
		##if existing_preview:
			##existing_preview.name = "ScenePreview2"
#
#
#
#
		## Store scene_name in SnapManagerGraph for snapping
		##snap_manager_graph_instance.scene_name = scene_name
		##snap_manager_graph_instance.pass_scene_name(scene_name)
		##const SNAP_MANAGER_DATA: SnapManagerData = preload("res://addons/scene_snap/resource/snap_manager_data.tres")
		##var snap_mananger_data: SnapManagerData = load("res://addons/scene_snap/resource/snap_manager_data.tres")
		##if debug: print("snap_mamanger_data.connections: ", load("res://addons/scene_snap/resource/snap_manager_data.tres").connections)
		##if snap_manager_graph_instance:
			##if debug: print("instance exists")
			### Get snap_flow_manager_graph output
			##if debug: print("snap_flow_manager_graph.get_connection_list(): ", snap_manager_graph_instance.get_connection_list())
		##if snap_manager_graph_instance.line_edit:
			##
			##if scene_name.contains(snap_manager_graph_instance.line_edit.get_text()):
				##if debug: print("There is a name match")
		##if debug: print("scene_name: ", snap_manager_graph_instance.scene_name)
		##if debug: print("object aabb: ", snap_manager_graph_instance.get_scene_aabb(scene_preview))
#
#
#
#
		## Get snap_mamanger_graph connections
		## If graph open pull from graph else pull from saved .tres
		##if snap_flow_manager_graph:
		##	if debug: print("current connections: ", snap_flow_manager_graph.connections)
		##else:
		#
#
#
#
#
		#
		#
		#
		#EditorInterface.get_edited_scene_root().add_child(scene_preview)
#
		#if scene_preview.is_inside_tree():
#
##region Currently not used kept for 2D
#
			##if scene_preview is Node2D:
				##scene_viewer_panel_instance.change_body_type_3d_button.hide()
				##scene_viewer_panel_instance.change_body_type_2d_button.show()
				##
				##scene_viewer_panel_instance.change_collision_shape_3d_button.hide()
				##scene_viewer_panel_instance.change_collision_shape_2d_button.show()
				##
				##if debug: print("scene is 2d")
			##if scene_preview is Node3D:
				##scene_viewer_panel_instance.change_body_type_2d_button.hide()
				##scene_viewer_panel_instance.change_body_type_3d_button.show()
				##
				##scene_viewer_panel_instance.change_collision_shape_2d_button.hide()
				##scene_viewer_panel_instance.change_collision_shape_3d_button.show()
##endregion
#
			## Show backface FIXME TODO maybe just get the first meshinstance3d
			## FIXME Not all main textures are the material 0 so looping through all can this be improved?
			#var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
			#for mesh_node: MeshInstance3D in mesh_node_instances:
				#for mesh_material_index: int in mesh_node.mesh.get_surface_count():
					#var active_material: StandardMaterial3D = mesh_node.get_active_material(mesh_material_index)
					#active_material.cull_mode = 2 #CULL_DISABLED
				#
				##var active_material: StandardMaterial3D = mesh_node.get_active_material(0)
				##mesh_node.get_active_material(0).cull_mode = 2 #CULL_DISABLED
				##active_material.cull_mode = 2 #CULL_DISABLED
				##if debug: print("mesh material culling: ", mesh_node.get_active_material(0).get_cull_mode())
					## Update the material_button in scene_viewer.tscn with the current previews material
					## FIXME UPDATES THE MATERIAL ON ALL INSTANCED OBJECTS IN SCENE NOTE ACTUALLY NOT RELATED TO THIS SO SOMEWHERE ELSE
					## FIXME Will update to the last active material in loop
					#scene_viewer_panel_instance.update_material_button_mesh_instance_3d(0, active_material)
#
#
			## TODO Strip out changing of body type not needed 
			#if scene_preview_collisions:
				## TEST START
				#if scene_preview is Node3D:
					#
					#
########################## ORIGINAL WORKS
					##var physics_body_3d: Node3D = null
					##match current_body_3d_type:
						##"NO_PHYSICSBODY3D":
							### make meshinstance3d the root of the scene 
							##pass
						##"NODE3D":
							##physics_body_3d = Node3D.new()
						##"STATICBODY3D":
							##physics_body_3d = StaticBody3D.new()
						##"RIGIDBODY3D":
							##physics_body_3d = RigidBody3D.new()
						##"CHARACTERBODY3D":
							##physics_body_3d = CharacterBody3D.new()
##
					##if physics_body_3d != null:
						##scene_preview.replace_by(physics_body_3d)
						##physics_body_3d.name = scene_name
						##scene_preview = physics_body_3d
######################### ORIGINAL WORKS
#
#
#
					##var physics_body_3d: Node3D = null
					##match "STATICBODY3D":
						##"STATICBODY3D":
							##physics_body_3d = StaticBody3D.new()
##
					##if physics_body_3d != null:
						##scene_preview.replace_by(physics_body_3d)
						##physics_body_3d.name = scene_name
						##scene_preview = physics_body_3d
##
##
					###if debug: print("VIEWPORT 3D GIZMOS: ", EditorInterface.get_editor_viewport_3d(0).get_gizmos())
					##var save_path = "none"
					###scene_preview.queue_free()
					###await match_collision_state(physics_body_3d, scene_name, save_path, false)
					##await match_collision_state(scene_preview, scene_name, save_path, false)
######################### ALSO WORKS
#
					## TODO FIXME Collisions generated here are not reused when placing scene will speed up placement
					#if debug: print("matching collision state now")
					#var save_path = "none"
					#if debug: print("matching6")
					#await match_collision_state(scene_preview, scene_preview.name, save_path, false)
#
#
#
			### Strip scene_preview down to its first Meshinstance3D child
			##scene_preview = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview)
#
			## TODO check if .owner and .set_owner can be part of reparent func
			## Add scene_preview under pinned node
			#scene_preview.owner = null
			#await reparent_to_selected_node(scene_preview)
#
			#scene_preview.set_owner(EditorInterface.get_edited_scene_root())
#
#
#
			##if debug: print("scene_preview.name: ", scene_preview.name)
#
#
			##if existing_preview:
				##existing_preview.name = "ScenePreview2"
				##scene_preview.name = existing_preview.name
			##else:
			##await get_tree().process_frame
			##scene_preview.name = "ScenePreview"
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
######################KEEP NOTE: Originally had only mesh due to snapping and collision issues may need to go revert to that?
## but complete redid who in process with excluding scene_preview.
			## Apply transparency to ScenePreview
			##scene_preview_mesh.set_transparency(0.4)
######################KEEP
#
			### Change selection to the "ScenePreview"
			##call_deferred("keep_scene_preview_focus", scene_preview)
#
### TEMP DISABLED
			## Put the preview at the last previews position when in quick cycle
			#scene_preview.global_transform.origin = last_scene_preview_pos
##
#
#
#
			### Get distance to floor snapping
			##var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
			##var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
			##var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
			##if scene_viewer_panel_instance.current_scene_path != last_scene_path:
				##scene_preview.global_transform.basis = Basis.IDENTITY
				### Reset object_rotated flag for new scene
				##object_rotated = false
###
###
###
			##if snap_down:
				##scene_preview.global_transform.origin = editor_camera3d.project_position(mouse_pos, distance)
##???????????????????????????????????????????????????????
			#scene_preview_mesh = scene_preview
			## NOTE Entire code runs to here when creating new scene_preview
#
			## NOTE: Rename existing_preview and load in next scene with original "ScenePreview" name 
			## otherwise the engine will append number when getting same name conflict.
			#if existing_preview:
				#existing_preview.name = "ScenePreview2"
#
			## Await the name change. 
			#await get_tree().process_frame
			#scene_preview.name = "ScenePreview"
			## Change selection to the "ScenePreview"
			#call_deferred("keep_scene_preview_focus", scene_preview)
#
#
#
#
#
		#else:
			##scene_preview_3d_active = false
			#scene_preview.queue_free()
			##scene_preview = null
#
#
	#initialize_scene_preview = false
	#last_scene_path = scene_viewer_panel_instance.current_scene_path
#endregion




#region CREATE SCENE PREVIEW REFACTORED
# TODO REFACTOR SCENEPREVIEW CODE WITH SCENE TO PLACE CODE INTO ONE 
 # FIXME  CLEANUP FOLLOW FOCUS NOT WORKING FIX 
#@warning_ignore("node_configuration_warning")
# TODO REFACTOR CREATE NEW SCENE ADD GLB AS INSTANCE OF IT, ADD COLLISIONS DIRECTLY TO THE NEW SCENE
# NEW SCENE -> NODE3D
# GLB INSTANCE -----> GLB
# COLLISION --------> COLLISIONSHAPE3D
# CONSIDER SCENE_PREVIEW BEING ONLY MESHINSTANCE3D??? NOT NODE3D IN REFACTOR
# ?? Create mesh library for the previews rather then instancing the scene for performance, but then more memory taken up.
# but it can be saved to disk and referenced from disk. LOD versions?? compressed textures?? Maybe little benefit for complexity?
# Button hover will still need to load in scene, and when placed, but when cycling through mesh will be speed up.
# FIXME TODO CERATE SCENE PREVIEW WITH NODE PARENT FOR SNAPPING OFFSET FUNCTIONALITY

# NOTE: 
# 1. - When creating scene preview. If the scene_full_path of the focused button is either .GLTF or .GLB use scene_lookup to get the scene, otherwise load from the project FIXME does not account for file types other then glb and gltf
# 2. - When left mouse click to place scene. If the scene exists in the project filesystem use that, if not save the user:// scene to the res:// dir and use the created scene. -> NOTE: When placing scene we are always using the scene from project collection folder.

# FIXME Scene being placed is removed from lookup
func create_scene_preview():
	#if debug: print("current_collision_3d_state: ", current_collision_3d_state)
	if initialize_scene_preview:
		get_visible_scene_view_buttons()

	# This section deals with the loading of the scene and naming it according to the selected parameters
# -----------------------> Scene Instance and Placement Section
	if not scene_preview == null:# and not scene_preview_mesh == null:

		var scene_path: String = scene_viewer_panel_instance.current_scene_path
		var scene_name_no_ext: String = scene_viewer_panel_instance.get_scene_name(scene_path, true)
		var new_scene_to_place: Node
		var loaded_from_project_dir: bool = false
		var collection_name: String
		var scene_file_path_split: PackedStringArray = full_path_split(scene_path)
#
		## First do check if save scene to project path exists and if yes instance that and skip below
		## instance scene from user:// -> Edit -> save scene to project path
		if res_dir: # FIXME TODO updating folder name when collection name changes
			if scene_path.begins_with("res://"):
				#new_scene_to_place = load(scene_path).instantiate()
				#loaded_from_project_dir = true
				
				# NOTE May need to adjust for scn later
				if scene_path.get_extension() != "tscn":
					if debug: print("creating collection project")
					collection_name = "project"

			else: # NOTE Will need to change if decide to support more then .tscn for files in the user:// dir
				# NOTE If not using --tags will end in .tscn so needs to be removed
				collection_name = scene_file_path_split[4].to_snake_case()



			# Create Directories if not already. Scenes with no textures or shared textures will not create directory previously
			create_folders("res://", "collections".path_join(collection_name))

			var body_type_map: Dictionary[String, String] = {
				"NO_PHYSICSBODY3D": "no_body",
				"NODE3D": "node",
				"STATICBODY3D": "static",
				"RIGIDBODY3D": "rigid",
				"CHARACTERBODY3D": "character"
			}

			var collision_type_map: Dictionary[String, String] = {
				#"NO_COLLISION": "no_col",
				"SPHERESHAPE3D": "sphere",
				"BOXSHAPE3D": "box",
				"CAPSULESHAPE3D": "capsule",
				"CYLINDERSHAPE3D": "cylinder",
				"SIMPLIFIED_CONVEX": "simplified",
				"SINGLE_CONVEX": "single",
				"MULTI_CONVEX": "multi",
				"TRIMESH": "trimesh"
			}

			# Use the name mapping to create the scene name
			var body_3d = body_type_map.get(current_body_3d_type, "")
			var col_3d = collision_type_map.get(current_collision_3d_state, "")
			#var no_body: bool = false

			# FIXME for multiple mesh children
			if body_3d == "no_body":
				col_3d = "no_col"

				# TODO FIXME Must be passed down through stack of functions??
				# FIXME Must be fixed for all scene types
				# FIXME KEEP WITH SCENE_PREVIEW THAT IS ALREADY LOADED OR LOAD IN NEW DATA?
				# TODO Would need to be updated to add the ability to toggle scene linking either
				# copy .glb file to disk and add to scene or create .scn from buffer with no link.
				# NOTE: reusing scene_preview with no collision so these check maybe not needed
				if scene_preview.get_child_count() == 1 and scene_preview.get_child(0) is MeshInstance3D:
					
					# FIXME 
					for child: MeshInstance3D in scene_preview.get_children():


# TEMP TEST
						# Construct the save path
						if body_3d != "" and col_3d != "":
							save_path = project_scenes_path.path_join(
								collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".tscn")
							)
# TEMP TEST
						## Construct the save path
						#if body_3d != "" and col_3d != "":
							#save_path = project_scenes_path.path_join(
								#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".glb")
							#)



						if create_as_scene: # This happens when clicking the mouse

							if res_dir.file_exists(save_path): # Load from the res:// dir if it has been created
								if debug: print("loading from res://")
								new_scene_to_place = load(save_path).instantiate()

							else: # Load from the user:// dir and save to res:// dir and then load and use the scene created in the res:// collection folder
								if debug: print("instancing new scene now")
								# Copy .glb file in and make a child of the no no yes no I don't know just fix
								# Scene_preview loaded into buffer so copy from user:// disk to res:// collection location keep textures embeded
# TEMP TEST copy .glb in directly outside of being embeded
								#copy_file(res_dir, scene_path, save_path)

								# Open, name, close, instantiate
								#EditorInterface.open_scene_from_path("res://collections/test/SM_Arc_FirTree_a.glb", true)
								
								#EditorInterface.open_scene_from_path(scene_path, true)
# TEMP disabled
								## Set Surface materials from scene_preview before saving
								##TEST set default
								if debug: print("creating default material1")
								#scene_viewer_panel_instance.set_surface_materials(new_scene_to_place, scene_path, -1, null)
								scene_viewer_panel_instance.set_surface_materials(new_scene_to_place, scene_path)


								new_scene_to_place = save_and_instantiate_scene(child, save_path)

						else:

							new_scene_to_place = child.duplicate()




						EditorInterface.get_edited_scene_root().add_child(new_scene_to_place)
						new_scene_to_place.set_owner(EditorInterface.get_edited_scene_root())
						

						
						
						await reparent_to_selected_node(new_scene_to_place)






						set_object_position_and_add_mesh_tris(new_scene_to_place, child.name)

						return


				else: # remove body and collisions make mesh the scene root and place
					if debug: print("scene_preview.get_child_count() is greater than 1 could not preceed: ", scene_preview.get_child_count())



# TEMP TEST
			# Construct the save path
			if body_3d != "" and col_3d != "":
				save_path = project_scenes_path.path_join(
					collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".tscn")
				)
# TEMP TEST
			## Construct the save path
			#if body_3d != "" and col_3d != "":
				#save_path = project_scenes_path.path_join(
					#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".glb")
				#)



			#if debug: print("this is the save path: ", save_path)
			# TODO Here I need to copy the .glb file into the res:// directory and create inherited scenes from it.
			# NOTE Currently works but creates a new .tscn file that does not inherit from original
			if res_dir.file_exists(save_path):
			#if res_dir.file_exists(get_save_path()):
				#if debug: print("the file exists loading it")
				loaded_from_project_dir = true
				# FIXME THE REASON THAT SCENEPREVIEW DOES NOT SEE THE SCENE THAT WILL BE PLACED IS BECAUSE OF THIS SWITCH HERE
				# IT IS ALWAYS GETTING THE PREVIEW FROM THE load(scene_path).instantiate() NOT FOR WHAT IS IN THE RES:// SAVE PATH
				new_scene_to_place = load(save_path).instantiate()
				#new_scene_to_place = load(get_save_path(scene_path, scene_name, scene_name_split)).instantiate()

			else:
				new_scene_to_place = scene_viewer_panel_instance.load_scene_instance(scene_path)
				#mutex.lock()
				##var scene_lookup_duplicate: Dictionary[String, Node] = scene_viewer_panel_instance.scene_lookup.duplicate()
				##new_scene_to_place = scene_lookup_duplicate[scene_path]
				##new_scene_to_place = scene_viewer_panel_instance.scene_lookup[scene_path].duplicate()
				##if debug: print("scene_viewer_panel_instance.collection_lookup: ", scene_viewer_panel_instance.collection_lookup)
				#new_scene_to_place = scene_viewer_panel_instance.collection_lookup[collection_name][scene_path].duplicate()
				##var new_scene: Node = scene_viewer_panel_instance.scene_lookup[scene_path]
				##new_scene_to_place = new_scene.duplicate()
				#mutex.unlock()


				###TEST set default
				if debug: print("creating default material2")
				scene_viewer_panel_instance.set_surface_materials(new_scene_to_place, scene_path)
				#scene_viewer_panel_instance.set_surface_materials(new_scene_to_place, scene_path, -1, null)

				#if debug: print("new_scene_to_place children1: ", new_scene_to_place.get_children())

				#var mesh_node_instances: Array[Node] = new_scene_to_place.find_children("*", "MeshInstance3D", true, false)
				#for mesh_instance in mesh_node_instances:
					#if debug: print("Original mesh resource: ", mesh_instance.mesh.resource_path)
				## Load from scene_lookup TODO FIX BROKEN fallback for non scene_lookup
				#mutex.lock()
				##var scene_lookup_duplicate: Dictionary[String, Node] = scene_viewer_panel_instance.scene_lookup.duplicate()
				##new_scene_to_place = scene_lookup_duplicate[scene_path]
				#new_scene_to_place = scene_viewer_panel_instance.scene_lookup[scene_path].duplicate()
				##var new_scene: Node = scene_viewer_panel_instance.scene_lookup[scene_path]
				##new_scene_to_place = new_scene.duplicate()
				#mutex.unlock()
				##await get_tree().process_frame
#
#
				#var mesh_nodes_instances: Array[Node] = new_scene_to_place.find_children("*", "MeshInstance3D", true, false)
				#for mesh_instance in mesh_nodes_instances:
					#if debug: print("Duplicate mesh resource: ", mesh_instance.mesh.resource_path)



				
				# TEST copy .glb in directly outside of being embeded
				# May need to change default import settings for scenes to not extract textures
# TEST copy .glb in directly outside of being embeded
				#copy_file(res_dir, scene_path, save_path)
# TEMP disabled
				# FIXME BROKEN
				#new_scene_to_place = await scene_viewer_panel_instance.load_scene_instance(scene_path)

				loaded_from_project_dir = false


#region Not Currently Used Keep For 2D

		## NOTE First match body type
		#if new_scene_to_place is Node2D:
			#var physics_body_2d: PhysicsBody2D
			#match current_body_2d_type:
				#"STATICBODY2D":
					#physics_body_2d = StaticBody2D.new()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
				#"RIGIDBODY2D":
					#physics_body_2d = RigidBody2D.new()
					##EditorInterface.get_edited_scene_root().add_child(physics_body_2d)
					##physics_body_2d.owner = EditorInterface.get_edited_scene_root()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
				#"CHARACTERBODY2D":
					#physics_body_2d = CharacterBody2D.new()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
#
			#new_scene_to_place.queue_free()
			#if debug: print("matching3")
			#match_collision_state(physics_body_2d, scene_name_no_ext, save_path, false)
#endregion

		if new_scene_to_place is Node3D:
			

			#var first_mesh_node: MeshInstance3D = scene_viewer_panel_instance.get_scenes_first_mesh_node(new_scene_to_place)
			#if first_mesh_node.has_meta("extras"):
				#var metadata: Dictionary = first_mesh_node.get_meta("extras")
				#metadata["global_tags"] = selected_scene_view_button.global_tags
				#first_mesh_node.set_meta("extras", metadata)
				#if debug: print("first_mesh_node.get_meta('extras'): ", first_mesh_node.get_meta("extras"))


			#if debug: print("current_body_3d_type: ", current_body_3d_type)
			var physics_body_3d: Node3D = null
			if debug: print("this is the body type2: ", current_body_3d_type)
			match current_body_3d_type:
				"NO_PHYSICSBODY3D":
					enable_collisions = false
					if debug: print("THIS FIRED")
					new_scene_to_place.name = scene_name_no_ext
					#match_collision_state(new_scene_to_place, scene_name, save_path, true)
					return

				"NODE3D":
					enable_collisions = false
					#if not scene_preview_collisions:
						
					if not loaded_from_project_dir:
						physics_body_3d = Node3D.new()
				"STATICBODY3D":
					enable_collisions = true
					if not loaded_from_project_dir:
						physics_body_3d = StaticBody3D.new()

				"RIGIDBODY3D":
					enable_collisions = true
					if not loaded_from_project_dir:
						physics_body_3d = RigidBody3D.new()

				"CHARACTERBODY3D":
					enable_collisions = true
					if not loaded_from_project_dir:
						physics_body_3d = CharacterBody3D.new()

			if physics_body_3d != null:
				# NOTE: Here we will want to add the ability to toggle scene linking either
				# copy .glb file to disk and add to scene or create .scn from buffer with no link.
				#if debug: print("scene_path: ", scene_path)
				# NOTE: .glb file will be copied into the project and will be embedded within the .scn /tscn scene
				if scene_link_enabled:
					#var project_collection_base_path: String = scene_viewer_panel_instance.get_project_path(scene_path)
					#var model_path: String = 
					#var model_path: String = scene_viewer_panel_instance.get_project_path(scene_path, "models")
					#if debug: print("model copy path: ", model_path.path_join(scene_path.split("/")[-1]))
					#copy_file(user_dir, scene_path, model_path.path_join(scene_path.split("/")[-1]))
					#copy_file(user_dir, scene_path, project_collection_import_path.path_join(scene_path.split("/")[-1]))
					var model_path: String = scene_viewer_panel_instance.get_collection_path(scene_path, false)
					copy_file(user_dir, scene_path, model_path)
					await get_tree().process_frame
					await get_tree().create_timer(5).timeout
					# TODO Add wait here for 
					var model = load(model_path)
					var model_instance = model.instantiate()
					physics_body_3d.add_child(model_instance)

				else:

					new_scene_to_place.replace_by(physics_body_3d)
				physics_body_3d.name = scene_name_no_ext




			if loaded_from_project_dir:
				#if debug: print("new_scene_to_place: ", new_scene_to_place)
				if debug: print("matching2")
				match_collision_state(new_scene_to_place, scene_name_no_ext, save_path, true)
			else:
				# FIXME MAYBE HOLD new_scene_to_place AND PLACE THAT?
# CAUTION FIXME new_scene_to_place was being removed for single instance loading. Keep as part of fallback when scene not in scene_lookup or low VRAM setting
				#new_scene_to_place.queue_free()
				if debug: print("matching1")

				###TEST set default
				#if debug: print("creating default material2")
				#
				#var current_selected_material: Resource = scene_viewer_panel_instance.materials_3d_array[scene_viewer_panel_instance.current_material_index]
				#scene_viewer_panel_instance.set_surface_materials(physics_body_3d, scene_path, scene_viewer_panel_instance.current_selected_surface_index, current_selected_material)

				match_collision_state(physics_body_3d, scene_name_no_ext, save_path, false)
				#match_collision_state(new_scene_to_place, scene_name_no_ext, save_path, false)

	# Reset save path 
	save_path = ""

# -----------------------> Scene_Preview Section
	# FIXME if scene preview skip remove ScenePreview
	# FIXME create new scene view based on focues not index 0
	if scene_preview == null:
		var scene_name: String
		
		
		# TODO CLEANUP AND PUT INTO SEPARATE FUNCTION
		# If there are no scene buttons when Q_KEY and mouse button right clicked reset again
		if initialize_scene_preview:
			if current_visible_buttons.is_empty():
				#push_warning("No visible scenes available, or Scene Viewer Panel not open. Please select a scene or open a collection of scenes within the Scene Viewer. \
				#\n TIP: Undock Scene Viewer Panel to enable Scene Quick Scroll (SHIFT+Scroll Wheel) even when Scene Viewer is not visible.")
				# Reset initialize_scene_preview flag with time for function to finish
				await get_tree().create_timer(.1).timeout
				initialize_scene_preview = true
				return
			else:
				scene_viewer_panel_instance.current_scene_path = current_visible_buttons[scene_number].scene_full_path
				#scene_preview = scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
				scene_preview = scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[scene_number].scene_full_path)

		else: # NOTE: Will work without this second setting of current_scene_path. Is it keeping a reference of it?
			scene_viewer_panel_instance.current_scene_path = current_visible_buttons[scene_number].scene_full_path
			#scene_preview = scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
			scene_preview = scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[scene_number].scene_full_path)

		scene_name = scene_viewer_panel_instance.get_scene_name(scene_viewer_panel_instance.current_scene_path, true)

		embed_decrypted_global_tags_in_scene(scene_preview)

		EditorInterface.get_edited_scene_root().add_child(scene_preview)

		if scene_preview.is_inside_tree():

			# Set the materials
			# FIXME passing additional parameters seems to really slow scene_preview cycling?
			# Why does this change material when cycling? Because this is not what is setting the material.
			if scene_viewer_panel_instance.cycle_material_favorites:
				scene_viewer_panel_instance.set_surface_materials(scene_preview, scene_viewer_panel_instance.current_scene_path)
			else:
				scene_viewer_panel_instance.set_surface_materials(scene_preview, scene_viewer_panel_instance.current_scene_path, true)
			#scene_viewer_panel_instance.set_surface_materials(scene_preview, scene_viewer_panel_instance.current_scene_path, -1, null, false, false)
			#scene_viewer_panel_instance.set_surface_materials(scene_preview, scene_viewer_panel_instance.current_scene_path, -1, null)
			# Update material button

#region Currently not used kept for 2D

			#if scene_preview is Node2D:
				#scene_viewer_panel_instance.change_body_type_3d_button.hide()
				#scene_viewer_panel_instance.change_body_type_2d_button.show()
				#
				#scene_viewer_panel_instance.change_collision_shape_3d_button.hide()
				#scene_viewer_panel_instance.change_collision_shape_2d_button.show()
				#
				#if debug: print("scene is 2d")
			#if scene_preview is Node3D:
				#scene_viewer_panel_instance.change_body_type_2d_button.hide()
				#scene_viewer_panel_instance.change_body_type_3d_button.show()
				#
				#scene_viewer_panel_instance.change_collision_shape_2d_button.hide()
				#scene_viewer_panel_instance.change_collision_shape_3d_button.show()
#endregion





			## HACK
			#scene_viewer_panel_instance.cycle_material(-1)
			#scene_viewer_panel_instance.cycle_material(1)



			## Show backface FIXME TODO maybe just get the first meshinstance3d
			## FIXME Not all main textures are the material 0 so looping through all can this be improved?
			#var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
			#for mesh_node: MeshInstance3D in mesh_node_instances:
				#for mesh_material_index: int in mesh_node.mesh.get_surface_count():
					#var active_material: StandardMaterial3D = mesh_node.get_active_material(mesh_material_index)
					#active_material.cull_mode = 2 #CULL_DISABLED
				#
				##var active_material: StandardMaterial3D = mesh_node.get_active_material(0)
				##mesh_node.get_active_material(0).cull_mode = 2 #CULL_DISABLED
				##active_material.cull_mode = 2 #CULL_DISABLED
				##if debug: print("mesh material culling: ", mesh_node.get_active_material(0).get_cull_mode())
					## Update the material_button in scene_viewer.tscn with the current previews material
					## FIXME UPDATES THE MATERIAL ON ALL INSTANCED OBJECTS IN SCENE NOTE ACTUALLY NOT RELATED TO THIS SO SOMEWHERE ELSE
					## FIXME Will update to the last active material in loop
					#scene_viewer_panel_instance.update_material_button_mesh_instance_3d(0, active_material)


			# TODO Strip out changing of body type not needed 
			if scene_preview_collisions:
				# TEST START
				if scene_preview is Node3D:
					

					
######################### ORIGINAL WORKS
					#var physics_body_3d: Node3D = null
					#match current_body_3d_type:
						#"NO_PHYSICSBODY3D":
							## make meshinstance3d the root of the scene 
							#pass
						#"NODE3D":
							#physics_body_3d = Node3D.new()
						#"STATICBODY3D":
							#physics_body_3d = StaticBody3D.new()
						#"RIGIDBODY3D":
							#physics_body_3d = RigidBody3D.new()
						#"CHARACTERBODY3D":
							#physics_body_3d = CharacterBody3D.new()
#
					#if physics_body_3d != null:
						#scene_preview.replace_by(physics_body_3d)
						#physics_body_3d.name = scene_name
						#scene_preview = physics_body_3d
######################## ORIGINAL WORKS



					#var physics_body_3d: Node3D = null
					#match "STATICBODY3D":
						#"STATICBODY3D":
							#physics_body_3d = StaticBody3D.new()
#
					#if physics_body_3d != null:
						#scene_preview.replace_by(physics_body_3d)
						#physics_body_3d.name = scene_name
						#scene_preview = physics_body_3d
#
#
					##if debug: print("VIEWPORT 3D GIZMOS: ", EditorInterface.get_editor_viewport_3d(0).get_gizmos())
					#var save_path = "none"
					##scene_preview.queue_free()
					##await match_collision_state(physics_body_3d, scene_name, save_path, false)
					#await match_collision_state(scene_preview, scene_name, save_path, false)
######################## ALSO WORKS

					# TODO FIXME Collisions generated here are not reused when placing scene will speed up placement
					if debug: print("matching collision state now")
					var save_path = "none"
					if debug: print("matching6")
					await match_collision_state(scene_preview, scene_preview.name, save_path, false)



			## Strip scene_preview down to its first Meshinstance3D child
			#scene_preview = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview)

			# TODO check if .owner and .set_owner can be part of reparent func
			# Add scene_preview under pinned node
			scene_preview.owner = null
			await reparent_to_selected_node(scene_preview)

			scene_preview.set_owner(EditorInterface.get_edited_scene_root())



			#if debug: print("scene_preview.name: ", scene_preview.name)


			#if existing_preview:
				#existing_preview.name = "ScenePreview2"
				#scene_preview.name = existing_preview.name
			#else:
			#await get_tree().process_frame
			#scene_preview.name = "ScenePreview"






			
			
			

#####################KEEP NOTE: Originally had only mesh due to snapping and collision issues may need to go revert to that?
# but complete redid who in process with excluding scene_preview.
			# Apply transparency to ScenePreview
			#scene_preview_mesh.set_transparency(0.4)
#####################KEEP

			## Change selection to the "ScenePreview"
			#call_deferred("keep_scene_preview_focus", scene_preview)

## TEMP DISABLED
			# Put the preview at the last previews position when in quick cycle
			scene_preview.global_transform.origin = last_scene_preview_pos
#



			## Get distance to floor snapping
			#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
			#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
			#var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
			#if scene_viewer_panel_instance.current_scene_path != last_scene_path:
				#scene_preview.global_transform.basis = Basis.IDENTITY
				## Reset object_rotated flag for new scene
				#object_rotated = false
##
##
##
			#if snap_down:
				#scene_preview.global_transform.origin = editor_camera3d.project_position(mouse_pos, distance)
#???????????????????????????????????????????????????????
			scene_preview_mesh = scene_preview
			# NOTE Entire code runs to here when creating new scene_preview

			# NOTE: Rename existing_preview and load in next scene with original "ScenePreview" name 
			# otherwise the engine will append number when getting same name conflict.
			if existing_preview:
				existing_preview.name = "ScenePreview2"

			# Await the name change. 
			await get_tree().process_frame
			scene_preview.name = "ScenePreview"
			# Change selection to the "ScenePreview"
			call_deferred("keep_scene_preview_focus", scene_preview)





		else:
			#scene_preview_3d_active = false
			# Only requird if loading scene dynamically from disk when placing not from memory and dictionary lookup
			scene_preview.queue_free()
			#scene_preview = null


	initialize_scene_preview = false
	last_scene_path = scene_viewer_panel_instance.current_scene_path
#endregion



## TODO Pass all loading of scenes through here
#func load_scene_instance() -> Node:
	#var scene_preview: Node = null
	#var scene_full_path: String = current_visible_buttons[scene_number].scene_full_path
	#
	#if scene_full_path.begins_with("res://"): # Load from project filesystem
		#scene_preview = load(scene_full_path).instantiate()
	#else: # Pull from scene_lookup[scene_full_path] # Pull from Memory
		## TODO CHECK IF HAS ISSUES WITH GLTF TODO ADD SUPPORT FOR .OBJ
		#var file_ext: String = scene_full_path.get_extension()
		#if file_ext == "glb" or file_ext == "gltf" or file_ext == "obj":
			#mutex.lock()
			#if scene_viewer_panel_instance.scene_lookup.has(scene_full_path):
				#scene_preview = scene_viewer_panel_instance.scene_lookup[scene_full_path].duplicate()
#
			#else: # Fallback loading directly from disk single thread when not in lookup 
				#var imported_base_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].to_snake_case())
				#var imported_textures_path: String = imported_base_path.path_join("textures".path_join("/"))
				#scene_preview = scene_viewer_panel_instance.load_gltf_scene_instance(scene_full_path, imported_textures_path)
			#mutex.unlock()
#
	#return scene_preview


## NOTE Duplicate code from scene_preview.gd
#func load_scene_instance(scene_full_path: String) -> Node:
	#var scene_instance: Node
	#if scene_full_path.get_extension() == "glb":# or scene_full_path.get_extension() == "gltf":
		#if scene_full_path.begins_with("res://"):
			#var scene_loaded: PackedScene = load(scene_full_path)
			#scene_instance = scene_loaded.instantiate()
		#else:
			#scene_instance = scene_viewer_panel_instance.load_gltf_scene_instance.bind(scene_full_path)
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	#return scene_instance







#var current_scene_full_path: String = ""
#var processed_scene_full_path: String = ""
#
##var wait_count: int = 0
### Function to let thread finish and not create new one if one is running
#func get_scene_instance(scene_full_path: String) -> Node:
	#var scene_instance: Node = null
	#current_scene_full_path = scene_full_path
#
	## If thread is processing a stale scene let it finish and then reload
	#if scene_full_path != processed_scene_full_path and scene_viewer_panel_instance.thread.is_alive():
		#var wait_count: int = 0
		#while scene_viewer_panel_instance.thread.is_alive(): # Hold here until thread is finished then reload
			#await get_tree().process_frame
			#wait_count += 1
			#if wait_count > 1000:
				#break
#
		##if is_instance_valid(current_button.sub_viewport):
		##if scene_full_path == current_scene_full_path: # Check if still same path?
		#get_scene_instance(scene_full_path)
		#if debug: print("finishing stale scene")
		#if debug: print("finishing stale scene")
		#return
#
	#await get_tree().process_frame
#
	#if not scene_viewer_panel_instance.thread.is_alive():
		#processed_scene_full_path = scene_full_path
		#scene_instance = await scene_viewer_panel_instance.load_scene_instance(scene_full_path)
#
		#if scene_full_path != current_scene_full_path: # Check that button is still same button after finished loading, if not reload again
			##if is_instance_valid(current_button.sub_viewport):
			#if debug: print("reloading function with new scene path")
			#get_scene_instance(current_scene_full_path)
#
		##else:
			##return scene_instance
	###get_scene_instance(scene_full_path)
	##if scene_instance:
		##return scene_instance
	##else:
		##get_scene_instance(scene_full_path)
	#
	#return null


var current_scene_full_path: String = ""
var processed_scene_full_path: String = ""
#var scene_instance: Node = null



## TODO Run with multi-thread and dispose of unused loaded scenes
#func get_scene_instance(scene_full_path: String) -> Node:
	#var scene_instance: Node = null
	#current_scene_full_path = scene_full_path
#
	## If thread is processing a stale scene, let it finish and then reload
	#if scene_full_path != processed_scene_full_path and scene_viewer_panel_instance.thread.is_alive():
		#var wait_count: int = 0
		#while scene_viewer_panel_instance.thread.is_alive():
			#await get_tree().process_frame
			#wait_count += 1
			#if wait_count > 1000:
				#break
#
		#if scene_full_path == current_scene_full_path:
			#get_scene_instance(scene_full_path)
			#if debug: print("finishing stale scene")
		#return null  # Early return to avoid further execution
#
	#await get_tree().process_frame
#
	#if not scene_viewer_panel_instance.thread.is_alive():
		#processed_scene_full_path = scene_full_path
		#scene_instance = await scene_viewer_panel_instance.load_scene_instance(scene_full_path)
		##scene_preview = await scene_viewer_panel_instance.load_scene_instance(scene_full_path)
#
		#if scene_full_path != current_scene_full_path:
			#if debug: print("reloading function with new scene path")
			#get_scene_instance(current_scene_full_path)
			##return await get_scene_instance(current_scene_full_path)  # Recursive call to reload with the new path
#
	#return scene_instance


# TODO Run with multi-thread and dispose of unused loaded scenes
func get_scene_instance(scene_full_path: String) -> void:
	var scene_instance: Node = null
	current_scene_full_path = scene_full_path

	# If thread is processing a stale scene, let it finish and then reload
	if scene_full_path != processed_scene_full_path and scene_viewer_panel_instance.thread.is_alive():
		var wait_count: int = 0
		while scene_viewer_panel_instance.thread.is_alive():
			await get_tree().process_frame
			wait_count += 1
			if wait_count > 1000:
				break

		if scene_full_path == current_scene_full_path:
			get_scene_instance(scene_full_path)
			if debug: print("finishing stale scene")
		return  # Early return to avoid further execution

	await get_tree().process_frame

	if not scene_viewer_panel_instance.thread.is_alive():
		processed_scene_full_path = scene_full_path
		#scene_instance = await scene_viewer_panel_instance.load_scene_instance(scene_full_path)
		mutex.lock()
		if debug: print("requesting load scene")
		scene_preview = scene_viewer_panel_instance.load_gltf_scene_instance.bind(scene_full_path)
		#scene_preview = load_scene_instance(scene_full_path)
		mutex.unlock()

		if scene_full_path != current_scene_full_path:
			if debug: print("reloading function with new scene path")
			get_scene_instance(current_scene_full_path)
			#return await get_scene_instance(current_scene_full_path)  # Recursive call to reload with the new path

	#return scene_instance


## NOTE Duplicate code from scene_preview.gd
#func load_scene_instance(scene_full_path: String) -> Node:
	#var scene_instance: Node
	#if scene_full_path.get_extension() == "glb":# or scene_full_path.get_extension() == "gltf":
		#if scene_full_path.begins_with("res://"):
			#var scene_loaded: PackedScene = load(scene_full_path)
			#scene_instance = scene_loaded.instantiate()
		#else:
			#scene_instance = scene_viewer_panel_instance.load_gltf_scene_instance.bind(scene_full_path)
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	#return scene_instance






var existing_preview: Node3D = null







########################################################################################
#ORIGINAL WORKING BELOW

## TODO REFACTOR SCENEPREVIEW CODE WITH SCENE TO PLACE CODE INTO ONE 
 ## FIXME  CLEANUP FOLLOW FOCUS NOT WORKING FIX 
##@warning_ignore("node_configuration_warning")
## TODO REFACTOR CREATE NEW SCENE ADD GLB AS INSTANCE OF IT, ADD COLLISIONS DIRECTLY TO THE NEW SCENE
## NEW SCENE -> NODE3D
## GLB INSTANCE -----> GLB
## COLLISION --------> COLLISIONSHAPE3D
## CONSIDER SCENE_PREVIEW BEING ONLY MESHINSTANCE3D??? NOT NODE3D IN REFACTOR
## ?? Create mesh library for the previews rather then instancing the scene for performance, but then more memory taken up.
## but it can be saved to disk and referenced from disk. LOD versions?? compressed textures?? Maybe little benefit for complexity?
## Button hover will still need to load in scene, and when placed, but when cycling through mesh will be speed up.
#func create_scene_preview():
	##if debug: print("current_collision_3d_state: ", current_collision_3d_state)
	#if initialize_scene_preview:
		#get_visible_scene_view_buttons()
#
	## This section deals with the loading of the scene and naming it according to the selected parameters
	#if not scene_preview == null:# and not scene_preview_mesh == null:
#
		#var scene_path: String = scene_viewer_panel_instance.current_scene_path
		#var scene_name_no_ext: String = scene_viewer_panel_instance.get_scene_name(scene_path, true)
		#var new_scene_to_place: Node
		#var loaded_from_project_dir: bool = false
		#var collection_name: String
		#var scene_file_path_split: PackedStringArray = full_path_split(scene_path)
##
		### First do check if save scene to project path exists and if yes instance that and skip below
		### instance scene from user:// -> Edit -> save scene to project path
		#if res_dir: # TODO updating folder name when collection name changes
			#if scene_path.begins_with("res://"):
				#
				## NOTE May need to adjust for scn later
				#if scene_path.get_extension() != "tscn":
					#collection_name = "project"
#
			#else: # NOTE Will need to change if decide to support more then .tscn for files in the user:// dir
				## NOTE If not using --tags will end in .tscn so needs to be removed
				#collection_name = scene_file_path_split[4].to_snake_case()
#
			## Create Directories if not already scenes with no textures or shared textures will not create directory previously
			#create_folders("res://", "collections".path_join(collection_name))
#
			#var body_type_map: Dictionary[String, String] = {
				#"NO_PHYSICSBODY3D": "no_body",
				#"NODE3D": "node",
				#"STATICBODY3D": "static",
				#"RIGIDBODY3D": "rigid",
				#"CHARACTERBODY3D": "character"
			#}
#
			#var collision_type_map: Dictionary[String, String] = {
				##"NO_COLLISION": "no_col",
				#"SPHERESHAPE3D": "sphere",
				#"BOXSHAPE3D": "box",
				#"CAPSULESHAPE3D": "capsule",
				#"CYLINDERSHAPE3D": "cylinder",
				#"SIMPLIFIED_CONVEX": "simplified",
				#"SINGLE_CONVEX": "single",
				#"MULTI_CONVEX": "multi",
				#"TRIMESH": "trimesh"
			#}
#
			## Use the name mapping to create the scene name
			#var body_3d = body_type_map.get(current_body_3d_type, "")
			#var col_3d = collision_type_map.get(current_collision_3d_state, "")
			##var no_body: bool = false
#
			## FIXME for multiple mesh children
			#if body_3d == "no_body":
				#col_3d = "no_col"
#
				## TODO FIXME Must be passed down through stack of functions??
				## FIXME Must be fixed for all scene types
				#if scene_preview.get_child_count() == 1 and scene_preview.get_child(0) is MeshInstance3D:
					#
					#for child: MeshInstance3D in scene_preview.get_children():
						#
						## Construct the save path
						#if body_3d != "" and col_3d != "":
							#save_path = project_scenes_path.path_join(
								#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".tscn")
							#)
#
						#if create_as_scene: # This happens when clicking the mouse
#
							#if res_dir.file_exists(save_path): # Load from the res:// dir if it has been created
								#if debug: print("loading from res://")
								#new_scene_to_place = load(save_path).instantiate()
#
							#else: # Load from the user:// dir and save to res:// dir
								#if debug: print("instancing new scene now")
								## Open name close instantiate
								##EditorInterface.open_scene_from_path("res://collections/test/SM_Arc_FirTree_a.glb", true)
								#
								##EditorInterface.open_scene_from_path(scene_path, true)
								#new_scene_to_place = save_and_instantiate_scene(child, save_path)
#
						#else:
#
							#new_scene_to_place = child.duplicate()
#
#
#
#
						#EditorInterface.get_edited_scene_root().add_child(new_scene_to_place)
						#new_scene_to_place.set_owner(EditorInterface.get_edited_scene_root())
						#
						#await reparent_to_selected_node(new_scene_to_place)
#
#
						#set_object_position_and_add_mesh_tris(new_scene_to_place, child.name)
#
						#return
#
#
				#else: # remove body and collisions make mesh the scene root and place
					#if debug: print("scene_preview.get_child_count() is greater than 1 could not preceed: ", scene_preview.get_child_count())
#
#
						##if res_dir.file_exists(save_path):
							##loaded_from_project_dir = true
							##new_scene_to_place = load(save_path).instantiate()
						#
						##new_scene_to_place.global_position = scene_preview.global_position
						##new_scene_to_place.global_transform.origin = scene_preview.global_transform.origin
#
						##child.rotation = Vector3(child.rotation.x, scene_preview.rotation.y, scene_preview.rotation.z)
						##child.global_transform.origin = scene_preview.global_transform.origin
#
#
						##EditorInterface.get_edited_scene_root().add_child(new_scene_to_place)
						##new_scene_to_place.owner = EditorInterface.get_edited_scene_root()
						##return
						##child.set_owner(null)
						##new_scene_to_place.remove_child(child)
						##EditorInterface.get_edited_scene_root().add_child(child)
						##child.set_owner(EditorInterface.get_edited_scene_root())
						##new_scene_to_place.free()
						##new_scene_to_place = child
#
						##child.set_owner(null)
						##mesh_instance_3d_node.get_child(0).remove_child(child)
						##
						###child.name = new_scene_to_place.name + "_collision"
						##EditorInterface.get_edited_scene_root().add_child(child)
						##
						##child.set_owner(EditorInterface.get_edited_scene_root())
##
						##child.reparent(mesh_node.get_parent())
						##child.set_owner(mesh_node.get_parent())
#
#
			## Construct the save path
			#if body_3d != "" and col_3d != "":
				#save_path = project_scenes_path.path_join(
					#collection_name.path_join(scene_name_no_ext + "_" + body_3d + "_" + col_3d + ".tscn")
				#)
#
			##if debug: print("this is the save path: ", save_path)
			## TODO Here I need to copy the .glb file into the res:// directory and create inherited scenes from it.
			## NOTE Currently works but creates a new .tscn file that does not inherit from original
			#if res_dir.file_exists(save_path):
			##if res_dir.file_exists(get_save_path()):
				##if debug: print("the file exists loading it")
				#loaded_from_project_dir = true
				## FIXME THE REASON THAT SCENEPREVIEW DOES NOT SEE THE SCENE THAT WILL BE PLACED IS BECAUSE OF THIS SWITCH HERE
				## IT IS ALWAYS GETTING THE PREVIEW FROM THE load(scene_path).instantiate() NOT FOR WHAT IS IN THE RES:// SAVE PATH
				#new_scene_to_place = load(save_path).instantiate()
				##new_scene_to_place = load(get_save_path(scene_path, scene_name, scene_name_split)).instantiate()
#
			#else:
				#loaded_from_project_dir = false
				##if scene_path.get_extension() == "glb":
				#new_scene_to_place = scene_viewer_panel_instance.load_scene_instance(scene_path)
				#
				##else:
					##new_scene_to_place = load(scene_path).instantiate()
#
#
#
		##if debug: print("scene_path: ", scene_path)# user://global_collections/scenes/Global Collections/Kenny Graveyard Kit/border_pillar.tscn
		##if debug: print("scene_file_split: ", scene_file_split) # ["user:", "global_collections", "scenes", "Global Collections", "Kenny Graveyard Kit", "coffin.tscn"]
		##var texture_files_path: String = scene_file_split[0] + "//" + scene_file_split[1].path_join(scene_file_split[2].path_join(scene_file_split[3].path_join(scene_file_split[4].path_join("textures"))))
		##var collection_name: String = scene_file_split[4].to_snake_case()
		###if debug: print(snake_to_pascal_with_seperation(collection_name))
		#### Reference: https://forum.godotengine.org/t/check-whether-a-string-is-upper-or-lower-case/18179 (juppi)
		###for letter: String in collection_name:
			###if letter == letter.to_upper():
				###if debug: print(letter)
			####if letter.is_u
			####if debug: print(letter)
		###if debug: print(String.chr(129302))
##
		##for texture_file_name: String in DirAccess.get_files_at(texture_files_path):
			##var origin_texture_full_path: String = texture_files_path.path_join(texture_file_name)
			##project_textures_full_path = project_textures_path.path_join(collection_name.path_join(texture_file_name))
			##create_folders("res://", "textures".path_join(collection_name))
			##if debug: print("project_textures_full_path: ", project_textures_full_path)
			##copy_file(res_dir, origin_texture_full_path, project_textures_full_path)
#
#
#
#
		##if debug: print("getting dependencies")
		##for dep in ResourceLoader.get_dependencies(scene_path):
			##if debug: print(dep)
			##if debug: print(dep.get_slice("::", 0)) # Prints UID.
			##if debug: print(dep.get_slice("::", 2)) # Prints path.
			##var dep_uid: String = dep.get_slice("::", 0)
			##if ResourceUID.has_id(ResourceUID.text_to_id(dep_uid)):
				##ResourceUID.set_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
				##if debug: print("ResourceUID has id: ", dep.get_slice("::", 0))
			##else:
				##ResourceUID.add_id(ResourceUID.text_to_id(dep_uid), project_textures_full_path)
				##if debug: print("ResourceUID does not have id: ", dep.get_slice("::", 0))
#
#
##region TEMP DISABLED
##
		##if res_dir:# TODO Consider adding to subfolders by collection name, NOTE will then require updating folder name when collection name
			### changed or recursive search through scenes folder to find if scene already in project to use. 
			###var project_scenes_full_path: String = project_scenes_path.path_join(scene_name_split[0] + ".tscn")
			##var collection_name: String = scene_file_path_split[4].to_snake_case()
			##var project_scenes_full_path: String = project_scenes_path.path_join(collection_name.path_join(scene_name_split[0] + ".tscn"))
##
			### Create Directories if not already scenes with no textures or shared textures will not create directory previously
			##create_folders("res://", "collections".path_join(collection_name))
##
			### If it already exists load the scene from project filesystem collections folder
			##if copy_file(res_dir, scene_path, project_scenes_full_path): 
				##var loaded_scene: PackedScene = load(scene_path)
##
				##var new_scene_view: Button = null
				##scene_viewer_panel_instance.create_scene_buttons(loaded_scene, project_scenes_full_path, scene_viewer_panel_instance.new_main_project_scenes_tab, new_scene_view, false)
##
##
			##
##
##
##
			###scene_preview = load(project_scenes_path.path_join(scene_name_split[0] + ".tscn")).instantiate()
			##var new_scene_to_place = load(project_scenes_path.path_join(collection_name.path_join(scene_name_split[0] + ".tscn"))).instantiate()
##endregion
			#
			#
		## NOTE First match body type
		#if new_scene_to_place is Node2D:
			#var physics_body_2d: PhysicsBody2D
			#match current_body_2d_type:
				#"STATICBODY2D":
					#physics_body_2d = StaticBody2D.new()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
				#"RIGIDBODY2D":
					#physics_body_2d = RigidBody2D.new()
					##EditorInterface.get_edited_scene_root().add_child(physics_body_2d)
					##physics_body_2d.owner = EditorInterface.get_edited_scene_root()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
				#"CHARACTERBODY2D":
					#physics_body_2d = CharacterBody2D.new()
					#physics_body_2d.name = new_scene_to_place.name
					#new_scene_to_place.replace_by(physics_body_2d)
#
			#new_scene_to_place.queue_free()
			#if debug: print("matching3")
			#match_collision_state(physics_body_2d, scene_name_no_ext, save_path, false)
#
		#if new_scene_to_place is Node3D:
			##if debug: print("current_body_3d_type: ", current_body_3d_type)
			#var physics_body_3d: Node3D = null
			#if debug: print("this is the body type2: ", current_body_3d_type)
			#match current_body_3d_type:
				#"NO_PHYSICSBODY3D":
					#enable_collisions = false
					#if debug: print("THIS FIRED")
					#new_scene_to_place.name = scene_name_no_ext
					##match_collision_state(new_scene_to_place, scene_name, save_path, true)
					#return
#
#
				##if scene_full_path.get_extension() == "obj":
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
					##EditorInterface.get_edited_scene_root().add_child(new_scene_to_place)
					##new_scene_to_place.owner = EditorInterface.get_edited_scene_root()
					##for child: Node3D in new_scene_to_place.get_children():
						##child.owner = null
						##new_scene_to_place.remove_child(child)
						##
						##EditorInterface.get_edited_scene_root().add_child(child)
						##child.set_owner(EditorInterface.get_edited_scene_root())
						##
						##await reparent_to_selected_node(child)
#
						### Set placed scene to same location and rotation as scene preview
						##child.global_transform.origin = scene_preview.global_transform.origin
						##child.global_transform.basis = scene_preview.global_transform.basis
						###child.rotate_x(-90)
						###child.scale = Vector3(100.0, 100.0, 100.0)
#
					##new_scene_to_place.queue_free()
#
					##return
#
					#
				#"NODE3D":
					#enable_collisions = false
					##if not scene_preview_collisions:
						#
					#if not loaded_from_project_dir:
						#physics_body_3d = Node3D.new()
				#"STATICBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = StaticBody3D.new()
#
				#"RIGIDBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = RigidBody3D.new()
#
				#"CHARACTERBODY3D":
					#enable_collisions = true
					#if not loaded_from_project_dir:
						#physics_body_3d = CharacterBody3D.new()
#
			#if physics_body_3d != null:
				#new_scene_to_place.replace_by(physics_body_3d)
				#physics_body_3d.name = scene_name_no_ext
#
#
			#if loaded_from_project_dir:
				##if debug: print("new_scene_to_place: ", new_scene_to_place)
				#if debug: print("matching2")
				#match_collision_state(new_scene_to_place, scene_name_no_ext, save_path, true)
			#else:
				#new_scene_to_place.queue_free()
				#if debug: print("matching1")
				#match_collision_state(physics_body_3d, scene_name_no_ext, save_path, false)
#
	## Reset save path 
	#save_path = ""
#
#
	## FIXME if scene preview skip remove ScenePreview
	#if scene_preview == null:
		#var scene_name: String
		#
		#if initialize_scene_preview:
			#if current_visible_buttons.is_empty():
				##push_warning("No visible scenes available, or Scene Viewer Panel not open. Please select a scene or open a collection of scenes within the Scene Viewer. \
				##\n TIP: Undock Scene Viewer Panel to enable Scene Quick Scroll (SHIFT+Scroll Wheel) even when Scene Viewer is not visible.")
				## Reset initialize_scene_preview flag with time for function to finish
				#await get_tree().create_timer(.1).timeout
				#initialize_scene_preview = true
				#return
			#else:
				##if res_dir.file_exists(get_save_path()):
					##scene_preview = load(save_path).instantiate()
				##else:
				#
				#if current_visible_buttons[0].scene_full_path.get_extension() == "glb":
					#scene_preview = scene_viewer_panel_instance.load_scene_instance(current_visible_buttons[0].scene_full_path)
				#
				#else:
					#scene_preview = load(current_visible_buttons[0].scene_full_path).instantiate()
					##scene_name = scene_viewer_panel_instance.file_name_no_ext(scene_viewer_panel_instance.current_scene_path)
				#scene_viewer_panel_instance.current_scene_path = current_visible_buttons[0].scene_full_path
#
		#else:
			##if res_dir.file_exists(get_save_path()):
				##scene_preview = load(save_path).instantiate()
			##else:
			#if scene_viewer_panel_instance.current_scene_path.get_extension() == "glb":
				#scene_preview = scene_viewer_panel_instance.load_scene_instance(scene_viewer_panel_instance.current_scene_path)
			#else:
				#scene_preview = load(scene_viewer_panel_instance.current_scene_path).instantiate()
			##scene_name = scene_viewer_panel_instance.file_name_no_ext(scene_viewer_panel_instance.current_scene_path)
#
		#scene_name = scene_viewer_panel_instance.get_scene_name(scene_viewer_panel_instance.current_scene_path, true)
		#
		## Store scene_name in SnapManagerGraph for snapping
		##snap_manager_graph_instance.scene_name = scene_name
		##snap_manager_graph_instance.pass_scene_name(scene_name)
		##const SNAP_MANAGER_DATA: SnapManagerData = preload("res://addons/scene_snap/resource/snap_manager_data.tres")
		##var snap_mananger_data: SnapManagerData = load("res://addons/scene_snap/resource/snap_manager_data.tres")
		##if debug: print("snap_mamanger_data.connections: ", load("res://addons/scene_snap/resource/snap_manager_data.tres").connections)
		##if snap_manager_graph_instance:
			##if debug: print("instance exists")
			### Get snap_flow_manager_graph output
			##if debug: print("snap_flow_manager_graph.get_connection_list(): ", snap_manager_graph_instance.get_connection_list())
		##if snap_manager_graph_instance.line_edit:
			##
			##if scene_name.contains(snap_manager_graph_instance.line_edit.get_text()):
				##if debug: print("There is a name match")
		##if debug: print("scene_name: ", snap_manager_graph_instance.scene_name)
		##if debug: print("object aabb: ", snap_manager_graph_instance.get_scene_aabb(scene_preview))
#
#
#
#
		## Get snap_mamanger_graph connections
		## If graph open pull from graph else pull from saved .tres
		##if snap_flow_manager_graph:
		##	if debug: print("current connections: ", snap_flow_manager_graph.connections)
		##else:
		#
#
#
#
#
		#
		#
		#
		#EditorInterface.get_edited_scene_root().add_child(scene_preview)
#
		#if scene_preview.is_inside_tree():
			#
			## Connect up node tree exit signal to properly remove node from tree when deleted by user
			##scene_preview.tree_exiting.connect(func() -> void:
					##if scene_preview_3d_active:
						##create_scene_preview())
					##scene_preview.queue_free()
					##scene_preview_3d_active = false
					##scene_preview = null)
#
#
		##scene_preview_3d_active = false
		###remove_existing_scene_preview()
		### Find and remove ScenePreview
		##var existing_preview = get_tree().get_root().find_child("ScenePreview", true, false)
		##if existing_preview:
			##existing_preview.get_parent().remove_child(existing_preview)
			##existing_preview.queue_free()
			##scene_preview = null
#
#
			#if scene_preview is Node2D:
				#scene_viewer_panel_instance.change_body_type_3d_button.hide()
				#scene_viewer_panel_instance.change_body_type_2d_button.show()
				#
				#scene_viewer_panel_instance.change_collision_shape_3d_button.hide()
				#scene_viewer_panel_instance.change_collision_shape_2d_button.show()
				#
				#if debug: print("scene is 2d")
			#if scene_preview is Node3D:
				#scene_viewer_panel_instance.change_body_type_2d_button.hide()
				#scene_viewer_panel_instance.change_body_type_3d_button.show()
				#
				#scene_viewer_panel_instance.change_collision_shape_2d_button.hide()
				#scene_viewer_panel_instance.change_collision_shape_3d_button.show()
				##if debug: print("scene is 3d")
#
#
			##var values: Array = []
			##values.append(scene_name)
#
#
			## Show backface FIXME TODO maybe just get the first meshinstance3d
			#var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
			#for mesh_node: MeshInstance3D in mesh_node_instances:
				#var active_material: StandardMaterial3D = mesh_node.get_active_material(0)
				##mesh_node.get_active_material(0).cull_mode = 2 #CULL_DISABLED
				#active_material.cull_mode = 2 #CULL_DISABLED
				## Update the material_button in scene_viewer.tscn with the current previews material
				#scene_viewer_panel_instance.update_material_button_mesh_instance_3d(0, active_material)
				#
				#
				#
				##values.append(mesh_node.mesh.get_aabb())
#
#
			### Store scene_name in SnapManagerGraph for snapping
			##snap_manager_graph_instance.set_object_values(scene_preview, values)
			##snap_manager_graph_instance.object = scene_preview
#
#
#
			### Hide collision shapes
			##var collision_node_instances: Array[Node] = scene_preview.find_children("*", "CollisionShape3D", true, false)
			##for collision_node: CollisionShape3D in collision_node_instances:
				##collision_node.hide()
#
			## TODO Strip out changing of body type not needed 
			#if scene_preview_collisions:
				## TEST START
				#if scene_preview is Node3D:
########################## ORIGINAL WORKS
					##var physics_body_3d: Node3D = null
					##match current_body_3d_type:
						##"NO_PHYSICSBODY3D":
							### make meshinstance3d the root of the scene 
							##pass
						##"NODE3D":
							##physics_body_3d = Node3D.new()
						##"STATICBODY3D":
							##physics_body_3d = StaticBody3D.new()
						##"RIGIDBODY3D":
							##physics_body_3d = RigidBody3D.new()
						##"CHARACTERBODY3D":
							##physics_body_3d = CharacterBody3D.new()
##
					##if physics_body_3d != null:
						##scene_preview.replace_by(physics_body_3d)
						##physics_body_3d.name = scene_name
						##scene_preview = physics_body_3d
######################### ORIGINAL WORKS
#
#
#
					##var physics_body_3d: Node3D = null
					##match "STATICBODY3D":
						##"STATICBODY3D":
							##physics_body_3d = StaticBody3D.new()
##
					##if physics_body_3d != null:
						##scene_preview.replace_by(physics_body_3d)
						##physics_body_3d.name = scene_name
						##scene_preview = physics_body_3d
##
##
					###if debug: print("VIEWPORT 3D GIZMOS: ", EditorInterface.get_editor_viewport_3d(0).get_gizmos())
					##var save_path = "none"
					###scene_preview.queue_free()
					###await match_collision_state(physics_body_3d, scene_name, save_path, false)
					##await match_collision_state(scene_preview, scene_name, save_path, false)
######################### ALSO WORKS
#
					## TODO FIXME Collisions generated here are not reused when placing scene will speed up placement
					#if debug: print("matching collision state now")
					#var save_path = "none"
					#if debug: print("matching6")
					#await match_collision_state(scene_preview, scene_preview.name, save_path, false)
#
#
#
			### Strip scene_preview down to its first Meshinstance3D child
			##scene_preview = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview)
#
			#scene_preview.owner = null
			#await reparent_to_selected_node(scene_preview)
#
			#scene_preview.set_owner(EditorInterface.get_edited_scene_root())
			#scene_preview.name = "ScenePreview"
			#
#
			#
			#
			#
#
######################KEEP NOTE: Originally had only mesh due to snapping and collision issues may need to go revert to that?
			## Apply transparency to ScenePreview
			##scene_preview_mesh.set_transparency(0.4)
######################KEEP
#
			## Change selection to the "ScenePreview"
			#call_deferred("keep_scene_preview_focus", scene_preview)
#
### TEMP DISABLED
			## Put the preview at the last previews position when in quick cycle
			#scene_preview.global_transform.origin = last_scene_preview_pos
##
##
			### Get distance to floor snapping
			##var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
			##var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
			##var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
			##if scene_viewer_panel_instance.current_scene_path != last_scene_path:
				##scene_preview.global_transform.basis = Basis.IDENTITY
				### Reset object_rotated flag for new scene
				##object_rotated = false
###
###
###
			##if snap_down:
				##scene_preview.global_transform.origin = editor_camera3d.project_position(mouse_pos, distance)
##???????????????????????????????????????????????????????
			#scene_preview_mesh = scene_preview
#
		#else:
			##scene_preview_3d_active = false
			#scene_preview.queue_free()
			##scene_preview = null
#
#
	#initialize_scene_preview = false
	#last_scene_path = scene_viewer_panel_instance.current_scene_path
















#func generate_glb_node(scene_full_path: String) -> Node3D:
	#var scene: Node3D
	#var gltf := GLTFDocument.new()
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
	#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
		#
		#var gltf_state := GLTFState.new()
		##var base_path: String = "res://collections/new_collection/textures/"
		#var base_path: String = "res://collections/test/"
		#gltf.append_from_buffer(file_bytes, base_path, gltf_state, 8)
		#
		#var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
		#for mesh in meshes:
			#if debug: print("mesh: ", mesh)
		#
		#scene = gltf.generate_scene(gltf_state)
	#return scene


## FIXME Check if loaded_threaded can be used here
#func load_scene_instance(scene_full_path: String) -> Node3D:
	#var scene_instance: Node3D
	#if scene_full_path.get_extension() == "glb" or scene_full_path.get_extension() == "gltf":
		#if scene_full_path.begins_with("res://"):
			#var scene_loaded: PackedScene = load(scene_full_path)
			#scene_instance = scene_loaded.instantiate()
		#else:
			## Will load and create thumbnail for mesh
			#var gltf := GLTFDocument.new()
			#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
			#
			#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
			#if scene_file:
				#var file_bytes = scene_file.get_buffer(scene_file.get_length())
				#scene_file.close()
				#
				#var gltf_state := GLTFState.new()
				#var base_path: String = "res://collections/test/"
				#gltf.append_from_buffer(file_bytes, base_path, gltf_state, 8)
#
				#var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
				#for mesh in meshes:
					#if debug: print("mesh: ", mesh)
#
				#scene_instance = gltf.generate_scene(gltf_state)
				#if debug: print("THIS CODE WAS EXECUTED")
#
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	#return scene_instance


# How to get from GrapNode port -> to tag_text and then from tag_text to matching if scene_preview.shared_tags or global_tags has tag_text 
# then do something.

# NOTE: Pre-cache the snap_flow_manager_graph nodes in dictionary
# key = "IndividualTags" : Dictionary{port number : "tag_text"} Dictionary{Dictionary{}}
# node_indices["IndividualTags"][2] = tag_text
#var node_indices: Dictionary = {}
#var port_tag_text_dict: Dictionary[int, Array] = {}
#var grouped_tags: Array[String] = []

# Given Node name and port get array of tag_texts
# stop further processing when snapping logic determined and connection has not changed

#var scene_tags: Dictionary[String, Array] = {}

##func process_snap_flow_manager_connections(scene_preview: Object, scene_name: String) -> void:
#func process_snap_flow_manager_connections(collision_point: Vector3, vector_normal: Vector3) -> void:
	#var snap_flag: String = ""
	## TODO For single tag modifiers without object to snap to connection...
	##
	##
	##
	#
	#
	#
	## For object to object snapping
	#if selected_scene_view_button and closest_object:
		##for tag: String in selected_scene_view_button.tags:
			##if debug: print("scene_tag: ", tag)
		##if debug: print("I WANT THIS ONLY TO RUN WHEN SNAPPING TO ANOTHER OBJECT")
		#if debug: print("snap_flow_manager_graph.get_connection_list(): ", snap_flow_manager_graph.get_connection_list())
		#
		#var connections: Array[Dictionary] = snap_flow_manager_graph.get_connection_list()
		#for connection: Dictionary in connections:
#
#
#
			### DEBUG
			##if debug: print("node_indices[connection.from_node][connection.from_port]: ", node_indices[connection.from_node][connection.from_port])
			##if selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]):
				##if debug: print("this scenes tag has a connection in the snap flow manager")
			##if debug: print("node_indices[connection.to_node][connection.to_port]: ", node_indices[connection.to_node][connection.to_port])
			##if debug: print("scene_tags[closest_object.name]: ", scene_viewer_panel_instance.scene_tags[closest_object.name])
			### The object snapping to has a connection in the snap flow manager
			##if scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[connection.to_node][connection.to_port]):
				##if debug: print("The object snapping to has a connection in the snap flow manager")
#
			### TEST CODE execution from graphedit
			##if selected_scene_view_button.tags != [] and selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]):
				##evaluate_user_code(snap_flow_manager_graph.code_edit.text)
#
			#var first_level_connected: bool = false
			## If the object to place has a tag that matches one in the snap flow from_node connections 
			## and the object to snap to has a tag in the to_node connections then follow connection
			#if selected_scene_view_button.tags != [] and selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]) and \
			#scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[connection.to_node][connection.to_port]):
				#first_level_connected = true
				#
				#if debug: print("Apply 1st level snap logic to the scene_preview")
				#for next_connection: Dictionary in connections:
					#if debug: print("node_indices[next_connection.from_node][next_connection.from_port]: ", node_indices[next_connection.from_node][next_connection.from_port])
					#if scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[next_connection.from_node][next_connection.from_port]):
					##if node_indices[next_connection.from_node][next_connection.from_port] == closest_object.name:
						##if debug: print("connection.to_node: ", node_indices[next_connection.to_node][next_connection.to_port])
						#if debug: print("next_connection.to_node: ", next_connection.to_node)
						#snap_flag = next_connection.to_node
#
						#var output_node = snap_flow_manager_graph.find_child(next_connection.to_node)
						#if debug: print(output_node.get_child(2).get_text())
					#
					##else:
						##snap_flag = ""
				###if debug: print("connection.from_node: ", connection.from_node)
			##if first_level_connected and connection.from_node == closest_object.name:# and connection.to_node == "Attack" and keep_alive:
				##if debug: print("connection.to_node: ", connection.to_node)
				#
				#
				##if debug: print("Apply snap logic to the scene_preview")
				##snap_flag = "center_pipe"
			## FIXME has for one but not for the second so resets back to no flag
			##else:
				##snap_flag = ""
#
	#apply_scene_preview_snap_logic(collision_point, vector_normal, snap_flag)
#
			##if snapping_to_object.tags
			##if debug: print("closest_object2: ", closest_object)
			#
			#
			#
			##if connection.from_node == "IndividualTags" and connection.to_node == "SnapToObject":# and connection.keep_alive:
				###if snap_flow_manager_graph == null:
					###snap_flow_manager_graph = load(graph_scene_path).instantiate()
				##var input_graph_node: GraphNode = snap_flow_manager_graph.get_child(connection.from_node.get_index())
				###var input_graph_node: GraphNode = snap_flow_manager_graph.find_child(connection.from_node, false) # Not recursive
				##for child: Control in input_graph_node.get_children():
					##if child.has_meta("tag_text") and selected_scene_view_button.tags.has(child.get_meta("tag_text")):
						##if debug: print("we have a connection!")
			###if debug: print(connection.from_node.get_children())
			###if debug: print("we have a connection!")
			##pass
#
#
#
#
#
	##if debug: print("scene_preview: ", scene_preview)
	##if debug: print("scene_name: ", scene_name)
	##if debug: print("current connections: ", ResourceLoader.load("res://addons/scene_snap/resources/snap_manager_data.tres","", ResourceLoader.CACHE_MODE_IGNORE).connections)
### Take in connections and output switching flags that get process at scene_preview_snap_to_normal()
### Turn the connections into meaningful flags set for snapping
	##var connections: Array = ResourceLoader.load("res://addons/scene_snap/resources/snap_manager_data.tres","", ResourceLoader.CACHE_MODE_IGNORE).connections
##
	##for connection in connections:
		##var from_node = connection["from_node"]
		##if debug: print("from_node: ", from_node)
		##if from_node == "ObjectToSnap":
			##var line_edit: LineEdit = snap_flow_manager_graph.find_child("InputLineEdit", true, true)
			##if debug: print("line_edit_text_split: ", parse_line_edit(line_edit, scene_name))
		##var to_node = connection["to_node"]
		##if from_node == "SnapToObject":
			##var line_edit: LineEdit = snap_flow_manager_graph.find_child("IntermediateLineEdit", true, true)
			##if debug: print("line_edit_text_split: ", parse_line_edit(line_edit, scene_name))
		##var from_port = connection["from_port"]
		##var to_port = connection["to_port"]
		##var keep_alive = connection["keep_alive"]
		##
		### Example: If connection is from "Idle" to "Attack"
		##if from_node == "Idle" and to_node == "Attack" and keep_alive:
			##pass
			### Trigger the "Attack" logic in your game
			### You might call a function or change a state, etc.
			###start_attack_sequence()

# FIX ISSUE WITH SCENE IN FOCUS VS SELECTED 

var current_closest_object = null

## MODIFIED VERSION
func process_snap_flow_manager_connections(collision_point: Vector3, vector_normal: Vector3) -> void:
	var snap_flag: String = ""
	# For object to object snapping
	# Add gates to reduce process in most restrictive possible order first
	if selected_scene_view_button and selected_scene_view_button.tags != []:# and closest_object:
		var connections: Array[Dictionary] = snap_flow_manager_graph.get_connection_list()
		#if debug: print("snap_flow_manager_graph.get_connection_list(): ", snap_flow_manager_graph.get_connection_list())
		
		var reverse_connection_lookup: Dictionary[String, String] = {} # Get the root connection from the final transform modifier given the middle Snap-To-Object
		for connection: Dictionary in connections:
			# FIXME Will change if scene tree structure changes
			var code_edit_node: = snap_flow_manager_graph.find_child(connection.to_node).get_child(connection.to_port).get_child(1)
			


			# EVALUATE FIRST CONNECTION FROM ROOT FIXME Evaluates 2nd connection here too when snapping to self
			# TODO How to know that connection root with tag is tag1 and not tag2?
			# NOTE: Should fix above issue having and connection.from_node == "IndividualTags"
			if connection.from_node == "IndividualTags" and selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]):

				# TEST Get reverse lookup test START FROM END WORK WAY BACK
				#if snap_flow_manager_graph.find_child(connection.to_node).get_child(connection.to_port).get_child(1) is CodeEdit:
				# FIXME Weak connection to origin and will break if IndividualTags changes TEST
				# TODO CHECK IF connection.from_node == "IndividualTags": REQUIRED MAY BE ASSUMED WITH IF CHECK ABOVE?
				if code_edit_node is CodeEdit:# and connection.from_node == "IndividualTags":

					#if debug: print("root of connection found return value")
					# Store Transform for multi transform addition
						# Returns the transform to be applied to scene_preview
					# Will eveluate before scene_preview ready so need to await frame
					# ERROR Invalid access to property or key 'position' on a base object of type 'Nil'.
					# FIXME will eveluate before scene_preview ready and with await will ERROR when removing scenePreo
					#await get_tree().process_frame
					#if scene_preview:
					if scene_preview:# and evaluate_user_code(code_edit_node.text, scene_preview, vector_normal) != null:
						evaluate_user_code(code_edit_node.text, scene_preview, vector_normal)
						pass
						#if debug: print(evaluate_user_code(code_edit_node.text, scene_preview))
				#Invalid access to property or key 'Mesh2' on a base object of type 'Dictionary[String, Array]'. When instance and then snapping to that
				# FIXME closest_object.name gets RENAMED WITH APPENDING NUMBER WHEN DUPLICATE THEN IT CAN'T FIND IT BY NAME IN THE DICTIONARY
				# AWAIT RENAME?
				# NOTE: OBJECT IN TREE GETS RENAMED WHEN DUPLICATE NAME AND CANNOT FIND IN DICTIONARY
				# REQUIRES CHANGING TO CLOSEST OBJECT WHICH IS SERIALIZED AND NOT DUPLICATED
				elif closest_object:
				
					#if closest_object != current_closest_object:
						#current_closest_object = closest_object
						## NOTE: Rename existing_preview and load in next scene with original "ScenePreview" name 
						## otherwise the engine will append number when getting same name conflict.
						#var existing_closest_object = get_tree().get_root().find_child(closest_object.name, true, false)
						#if existing_closest_object:
							#if debug: print("scene exsits")
							#existing_closest_object.name = closest_object.name + str("2")
							##var scene_tree_closest_object = get_tree().get_child(closest_object)
						###if existing_preview:
							##existing_preview.name = "ScenePreview2"
	##
						### Await the name change. 
						##await get_tree().process_frame
						##scene_preview.name = "ScenePreview"
				
					# TODO Check if breaks with "extras" but no "tags"
					if closest_object and closest_object.has_meta("extras"):
						var metadata: Dictionary = closest_object.get_meta("extras")

						if debug: print("closest_object tags: ", metadata["tags"])

						if metadata["tags"].has(node_indices[connection.to_node][connection.to_port]):
							var enter_string: String = connection.to_node + str(connection.to_port)
							reverse_connection_lookup[enter_string] = connection.from_node + str(connection.from_port)


					#if scene_viewer_panel_instance.scene_tags[closest_object.get_instance_id()].has(node_indices[connection.to_node][connection.to_port]):
						##if debug: print("the first connection is to the tag 2 snap-to-object")
						#var enter_string: String = connection.to_node + str(connection.to_port)
						#reverse_connection_lookup[enter_string] = connection.from_node + str(connection.from_port)
						## Store reverse conneciton lookup here in dict for next if statement


			## EVALUATE POSSIBLE SECOND CONNECTION FROM MIDDLE TAG2 SNAP-TO-OBJECT
			## Skip if from same scene-preview??
			#if connection.from_node == "OutputSnap":
				#continue

			# TODO Check if breaks with "extras" but no "tags"
			if closest_object and closest_object.has_meta("extras"):
				var metadata: Dictionary = closest_object.get_meta("extras")


				if connection.from_node == "SnapToObject" and  metadata["tags"].has(node_indices[connection.from_node][connection.from_port]):
					#if debug: print("the socond connection out starts here from: ", connection.from_node)
					var lookup_string: String = connection.from_node + str(connection.from_port)
					#if debug: print("lookup_string EXPECT SnapToObject0: ", lookup_string)
					if debug: print("reverse_connection_lookup: ", reverse_connection_lookup)
					if reverse_connection_lookup:
						if debug: print("reverse_connection_lookup[lookup_string] EXPECT IndividualTags0: ", reverse_connection_lookup[lookup_string])
						#reverse_connection_lookup[lookup_string]

						# TEST Get reverse lookup test START FROM END WORK WAY BACK
						#if snap_flow_manager_graph.find_child(connection.to_node).get_child(connection.to_port).get_child(1) is CodeEdit:
						# FIXME Weak connection to origin and will break if IndividualTags changes TEST
						# TODO CHECK IF connection.from_node == "IndividualTags": REQUIRED MAY BE ASSUMED WITH IF CHECK ABOVE?
						if code_edit_node is CodeEdit:# and connection.from_node == "IndividualTags":

							#if debug: print("root of connection found return value")
							# Store Transform for multi transform addition
								# Returns the transform to be applied to scene_preview
							if scene_preview:# and evaluate_user_code(code_edit_node.text, scene_preview, vector_normal) != null:
								evaluate_user_code(code_edit_node.text, scene_preview, vector_normal)
								pass
								#if debug: print(evaluate_user_code(code_edit_node.text, scene_preview))

# TEST DISABLE TO CHECK
	#apply_scene_preview_snap_logic(collision_point, vector_normal, snap_flag)
	# FIXME Similar logic from button scene_view loading must be applied here 
	await get_tree().process_frame # Give time for scene_preview node to be added to tree
	if dragging_node != null and dragging_node.is_inside_tree():
		dragging_node.global_position = collision_point
	set_scene_to_collision_point(collision_point)
	enable_placement = false

## ORIGINAL WORKING VERSION:
#func process_snap_flow_manager_connections(collision_point: Vector3, vector_normal: Vector3) -> void:
	#var snap_flag: String = ""
	## For object to object snapping
	#if selected_scene_view_button and closest_object:
		#var connections: Array[Dictionary] = snap_flow_manager_graph.get_connection_list()
		#for connection: Dictionary in connections:
#
			#var first_level_connected: bool = false
			## If the object to place has a tag that matches one in the snap flow from_node connections 
			## and the object to snap to has a tag in the to_node connections then follow connection
			#if selected_scene_view_button.tags != [] and selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]) and \
			#scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[connection.to_node][connection.to_port]):
				#first_level_connected = true
				#for next_connection: Dictionary in connections:
					#if scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[next_connection.from_node][next_connection.from_port]):
						#snap_flag = next_connection.to_node
#
						#var output_node = snap_flow_manager_graph.find_child(next_connection.to_node)
						#if debug: print(output_node.get_child(2).get_text())
#
	#apply_scene_preview_snap_logic(collision_point, vector_normal, snap_flag)













func execute_snap_flow_manager_connections() -> void:
	# Do the actually snapping here based on flags set by process_snap_flow_manager_connections()
	pass



# FIXME Must also pass in object that is being collided with
func parse_line_edit(line_edit: LineEdit, scene_name: String) -> bool:
	#var text_array: Array[String] = []
	var text_match: bool = false
	var text: String = line_edit.get_text()
	#if new_text.to_lower() != "" and not child.name.to_lower().contains(new_text.to_lower()):
	var line_edit_text_split: PackedStringArray = text.split(',', true, 0)
	for text_entry: String in line_edit_text_split:
		if scene_name.to_lower().contains(text_entry.to_lower().strip_edges()):
			if debug: print("there is a name match")
			text_match = true
		##if text_entry.to_lower() == contains(scene_name.to_lower()):
		##if debug: print("text_entry: ", text_entry)
		#text_entry.strip_edges()
		#text_entry.to_lower()
		#text_array.append(text_entry)
	return text_match



#region Mesh-Union-Code
# Reference: https://github.com/the-packrat/godot-mesh-union/tree/main (the-packrat)

@export var select_generated_mesh:bool = true
@export var unselect_other_nodes:bool = true
@export var show_preview:bool = false
@export var origin_name:String = ""

var ei:EditorInterface
var ur:EditorUndoRedoManager
var generated_mesh:ArrayMesh
var gm

func _on_join_button_pressed(mesh_node_instances: Array[Node]) -> MeshInstance3D:
	## get the selected nodes
	#var sna:Array = ei.get_selection().get_selected_nodes()
	var sna:Array = mesh_node_instances
	
	## collect mesh data from each meshinstance3D selected
	var ma:Array[MeshInstance3D] = []
	for n in sna:
		if is_instance_of(n, MeshInstance3D):
			ma.append(n)
	
	#if debug: print("ma: ", ma)
	## test if any meshes are selected at all
	if ma.is_empty():
		printerr("MeshReunionPlugin: no MeshInstance3D selected!")
		return
	
	## record name of first mesh in a global variable
	origin_name = ma[0].name
	
	## commit each surface array from each mesh to a single mesh
	var am:ArrayMesh = ArrayMesh.new()
	var surf_count:int = 0
	var mc:int = 0 ## make sure the correct material is applied to the correct surface
	for i in ma.size():
		var m:Mesh = ma[i].mesh
		for sc in m.get_surface_count():
			var sa = m.surface_get_arrays(sc)
			## move vertices to match intended position for each object
			for vi in sa[Mesh.ARRAY_VERTEX].size():
				sa[Mesh.ARRAY_VERTEX][vi] += ma[i].position - ma[0].position
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sa)
			am.surface_set_material(mc, m.surface_get_material(sc))
			mc += 1
	## record mesh in a global variable
	generated_mesh = am
	#if debug: print("generated_mesh: ", generated_mesh)
	
	## skip preview and create mesh if desired
	#if !show_preview:
		#_on_preview_confirm()
		#return
	var preview: MeshInstance3D = _on_preview_confirm(mesh_node_instances)
	return preview
	#
	### set up preview
	#var a:AcceptDialog = AcceptDialog.new()
	#add_child(a)
	#
	### show preview of combined mesh
	#var pa:Array[Texture2D] = ei.make_mesh_previews([am], 1000)
	#
	### draw the texture rect
	#var c:Control = Control.new()
	#var t:TextureRect = TextureRect.new()
	#t.anchor_left = 0
	#t.anchor_top = 0
	#t.anchor_right = 1
	#t.anchor_bottom = 1
	#t.texture = pa[0]
	#t.expand_mode = t.EXPAND_IGNORE_SIZE
	#var cr:ColorRect = ColorRect.new()
	#cr.color = Color(0.0, 0.0, 0.0, 1.0)
	#cr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#cr.add_child(t)
	#c.add_child(cr)
	#
	### draw text
	##var l:Label = Label.new()
	##c.add_child(l)
	##l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	##l.text = "Does this look okay?"
	##l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	##l.set("theme_override_font_sizes/font_size", 24)
	##cr.offset_bottom -= l.size.y
	#
	#a.add_child(c)
	#a.popup_centered_ratio()
	#a.title = "Mesh Preview"
	#var cb:Button = a.add_cancel_button("Cancel")
	#var ob:Button = a.get_ok_button()
	#ob.text = "Continue"
	#a.confirmed.connect(_on_preview_confirm)
	#return



func _on_preview_confirm(mesh_node_instances: Array[Node]) -> MeshInstance3D:
	## create meshinstance3D and hand it to the edited scene
	gm = MeshInstance3D.new()
	gm.mesh = generated_mesh
	
	## name the mesh
	gm.name = origin_name
	#if !$NameLine.text.is_empty():
		#gm.name = $NameLine.text
	
	## increment integer at the end of the name string until no sibling shares an identical name
	var siblings:PackedStringArray = []
	#for n in ei.get_edited_scene_root().get_children():
	for n in mesh_node_instances:
		siblings.append(n.name)
	#if debug: print("siblings: ", siblings)
	if siblings.has(gm.name):
		var i:int = 0
		var gmn:String = gm.name
		var gmni:String = ""
		
		## find whole valid integer at end of gmn
		while i < gmn.length() && gmn[-i - 1].is_valid_int():
			i += 1
		if i > 0:
			gmni = gmn.substr(gmn.length() - i, -1)
		
		## if integer begins with 0s, remove them
		## if no integer was found, mimic Godot's behaviour and set as "2"
		if !gmni.is_empty():
			i = 0
			while gmni[i] == "0":
				i += 1
			gmni = gmni.erase(0, i)
			## remove gmni from gmn
			gmn = gmn.erase(gmn.length() - gmni.length(), gmni.length())
		else:
			gmni = "2"
		
		## increment i until the new name is no longer identical to a sibling
		i = int(gmni)
		while siblings.has(gmn + gmni):
			i += 1
			gmni = str(i)
		gm.name = gmn + gmni
	
	## add the new mesh as a child to scene root
	#ur.create_action("Merge Mesh")
	#ur.add_do_method(ei.get_edited_scene_root(), "add_child", gm)
	#ur.add_do_property(gm, "owner", ei.get_edited_scene_root())
	#ur.add_undo_method(ei.get_edited_scene_root(), "remove_child", gm)
	#ur.commit_action()
	### remove other nodes from selection if desired
	#var es:EditorSelection = ei.get_selection()
	#var sna:Array = es.get_selected_nodes()
	#if unselect_other_nodes:
		#for n in sna:
			#es.remove_node(n)
	#
	### select newly created MeshInstance3D if desired
	#if select_generated_mesh:
		#es.add_node(gm)
	return gm

#endregion





#func bake_mesh(scene_preview: Node3D) -> MeshInstance3D:
	#var mesh_data_array = []
	#var transform_array = []
	#
	##var mesh_node_names: Dictionary = {}  # Use a Dictionary for unique names
	##var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
##
	##for mesh_node: Node in mesh_node_instances:
		##if debug: print("mesh_node: ", mesh_node)
		##
		##if not mesh_node_names.has(mesh_node.name):
#
#
#
#
#
	#for child in get_children():
		#if child is MeshInstance3D:
			#var mesh_instance = child
			#mesh_data_array.append(mesh_instance.mesh)
			#transform_array.append(mesh_instance.transform)
#
	#if mesh_data_array.size() > 0:
		#var combined_mesh = MeshDataTool.new()
		#combined_mesh.create_from_meshes(mesh_data_array, transform_array)
#
		#baked_mesh = combined_mesh.commit_to_surface()
		#
		#var new_instance = MeshInstance3D.new()
		#new_instance.mesh = baked_mesh
		#add_child(new_instance)
		#
		## Optionally remove the original MeshInstances
		#for child in get_children():
			#if child is MeshInstance3D:
				#child.queue_free()








#func keep_scene_preview_focus(scene_preview_mesh: MeshInstance3D) -> void:
#func keep_scene_preview_focus(scene_preview_mesh: StaticBody3D) -> void:
func keep_scene_preview_focus(scene_preview_mesh: Node3D) -> void:
#func keep_scene_preview_focus(scene_preview_mesh: MeshInstance3D) -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	# Change selection to the "ScenePreview"
	if quick_scroll_enabled:
		if scene_preview_mesh.is_inside_tree():
			change_selection_to(scene_preview_mesh)
	else:
		if selected_nodes.is_empty():
			change_selection_to(scene_preview_mesh)
		else:
			#if debug: print("selected not scene preview")
			for node in selected_nodes:
				if node != scene_preview_mesh:

					change_selection_to(scene_preview_mesh)



# how to simulate a key press (Adam_S)
# Reference: https://forum.godotengine.org/t/how-to-sumalate-a-key-press/21217/2
func simulate_keypress(key: Key, pressed: bool = true):
	var a = InputEventKey.new()
	a.keycode = key
	a.pressed = pressed # change to false to simulate a key release
	Input.parse_input_event(a)


# TEST Simulate multiple input keys
func simulate_multiple_key_presses(keys, pressed: bool = true):
	for key in keys:
		# Creating a new input event for each key
		var input_event = InputEventKey.new()
		input_event.keycode = key
		input_event.pressed = pressed

		# Sending the input event to be processed
		Input.parse_input_event(input_event)




func input_rotation(direction: String, rotation_value: int) -> void:
	EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()

	if selected_nodes != []:

		for node in selected_nodes:
			if node is Node3D:
				match direction:
					"clockwise":
						if center_pipe:
							# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
							scene_view_rotation(node, rotation_value, Vector3.RIGHT, false)
						else:
							scene_view_rotation(node, rotation_value, Vector3.UP, false)

					"counterclockwise":
						if center_pipe:
							# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
							scene_view_rotation(node, rotation_value, Vector3.RIGHT, true)
						else:
							scene_view_rotation(node, rotation_value, Vector3.UP, true)

# FIXME Conflict with this and default scaling with dragging and holding down left mouse button when in scale mode objects are scaled very large
# NOTE: Little exclamation mark warning, but it looks like it can be safely ignored.
# Reference: https://github.com/godotengine/godot/issues/5734#issuecomment-2220778601 (hmans)
func input_scale(direction: String, scale_reduction_value: int) -> void:
	EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()

	if selected_nodes != []:

		for node in selected_nodes:
			if node is Node3D:
				match direction: # Scale and factor in nodes original scale Ex. some .fbx files (node.scale *)
					"up":
						node.scale += node.scale * Vector3.ONE / scale_reduction_value
					"down":
						if node.scale - Vector3.ONE / scale_reduction_value > Vector3.ZERO:
							node.scale -= node.scale * Vector3.ONE / scale_reduction_value





#region Scaling refactor keep

### NOTE: Modified and sets scale with no warning, but GodotJolt Physics engine reverts to Vector3.ONE
#func input_scale(direction: String, scale_reduction_value: int) -> void:
	#EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	#var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	#if selected_nodes != []:
		#for node in selected_nodes:
			#if node is Node3D:
				#match direction: # Scale and factor in nodes original scale Ex. some .fbx files (node.scale *)
					#"up":
						#node_scale += node_scale * Vector3.ONE / scale_reduction_value
					#"down":
						#if node_scale - Vector3.ONE / scale_reduction_value > Vector3.ZERO:
							#node_scale -= node_scale * Vector3.ONE / scale_reduction_value
				#set_scale(node)
#
#
#var node_scale: Vector3 = Vector3.ONE
#
#func set_scale(node: Node3D) -> void:
	#var mesh_node_instances: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	#var collision_node_instances: Array[Node] = node.find_children("*", "CollisionShape3D", true, false)
	#for mesh_node: MeshInstance3D in mesh_node_instances:
		#mesh_node.scale = node_scale
	#for collision_node: CollisionShape3D in collision_node_instances:
		#collision_node.scale = node_scale
#endregion







## FIXME Fine when rotating physics bodies but breaks when directly rotating scaled meshes
#func scene_view_rotation2(node: Node3D, rotation_value: int, vector: Vector3, inverse: bool) -> void: # ORIGINAL
	#var tau_divide: int = 360 / rotation_value
	#var rotation: Basis
	#if inverse:
		#rotation= node.global_transform.basis.get_rotation_quaternion() * Quaternion(vector, TAU / tau_divide).inverse()
	#else:
		#rotation = node.global_transform.basis.get_rotation_quaternion() * Quaternion(vector, TAU / tau_divide)
#
	#node.global_transform.basis = rotation
	#rotated_global_transform = rotation


# TODO Check if works with pipe
func scene_view_rotation(node: Node3D, rotation_value: float, vector: Vector3, inverse: bool) -> void:
	if inverse:
		node.rotate_y(- deg_to_rad(rotation_value))
	else:
		node.rotate_y(deg_to_rad(rotation_value))




# NOTE calling create_pivot_node_and_center() preventing changing FIXME
func change_pivot_point_position() -> void:
	EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	# NOTE may be issues with shared AABB check if things are not working
	#var aabb
	
	if selected_nodes != []:
		for node in selected_nodes:
			if node is Node3D and node.name.begins_with("PivotNode3D_") and node.get_child(0):
				var pivot_point_scene_child = node.get_child(0)
				

				# Get aabb from scenes 1st child
				var mesh_child = pivot_point_scene_child.get_child(0)
				# NOTE adjust for none child(0) meshinstance3d children or multiple mesh
				if mesh_child is MeshInstance3D:
					var aabb = mesh_child.get_aabb()
					#if debug: print(aabb)
					#if debug: print(aabb.get_center())
					
					node.get_child(0).reparent(node.get_parent())
					
					# Move node to center postion FIXME swap out default to rotate on center not snap point
					for ray_cast_3d: RayCast3D in get_tree().get_nodes_in_group("snap_ray_cast_3d"):
						#if debug: print(ray_cast_3d)
						if ray_cast_3d:
							node.position = ray_cast_3d.global_position
					#node.position = mesh_child.global_position + aabb.get_center()

					# Reparent scene back to pivotnode3d parent
					pivot_point_scene_child.reparent(node)


# FIXME EXTREMELY MESSED UP NEEDS A LOT OF WORK
func create_pivot_node_and_center() -> void:
	if debug: print("creating")
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	
	for node in selected_nodes:
		# Skip non StaticBody3D nodes #FIXME NODE3D WITH FILTERS NEEDED
		if not node is StaticBody3D:# or not node is MeshInstance3D:
			continue
		
		# Create a new pivot node and name it uniquely
		var pivot_node_3d = Node3D.new()
		pivot_node_3d.name = "PivotNode3D_" + node.name

		# Get the parent of the selected node
		var parent = node.get_parent()

		# Add the pivot node to the parent
		parent.add_child(pivot_node_3d)
		pivot_node_3d.owner = parent
		
		# Set the pivot node's rotation to match the node
		pivot_node_3d.rotation_degrees = node.rotation_degrees
		
		# Compute the center position of the object
		var mesh_child = node.get_child(0)
		if mesh_child is MeshInstance3D:
			var aabb = mesh_child.get_aabb()
			var object_center = aabb.position + aabb.size / 2.0
			
			# Convert object_center to global coordinates
			var global_object_center = node.to_global(object_center)

			if node.name.begins_with("ScenePreview"):
				var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
				var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
				preview_offset = editor_camera3d.project_position(mouse_pos, 3)
				if debug: print("pivot node before: ",pivot_node_3d.position)
				if debug: print(preview_offset)
				pivot_node_3d.position = preview_offset
				
				node.reparent(pivot_node_3d)
				pivot_node_3d.get_child(0).get_child(0).position -= preview_offset

			else:
				# Hide the placeholder scene from view when rotating
				if not scene_preview == null:
					scene_preview.hide()
				
				pivot_node_3d.position = global_object_center - parent.global_position
				if debug: print("pivot node after: ",pivot_node_3d.position)
				# Reparent the node to the new pivot node
				node.reparent(pivot_node_3d)
				pivot_node_3d.get_child(0).get_child(0).position -= preview_offset



#region ExtraSnaps Code
############ EXTRASNAPS PLUGIN CODE
var selected: Node3D = null
var has_moved: bool = false
var move_pressed: bool = false

const RAY_LENGTH: float = 1000.
## FIXME MAKE SNAPPING TO FLOOR ALWAYS NOT JUST WHEN DRAGGING
func _move_selection(viewport_camera: Camera3D, event: InputEventMouseMotion) -> int:
	if !has_moved:
		#undoredo_action.create_action("ExtraSnaps: Transform Changed")

		## If the currently selected node is a CSG, store its use_collision status
		## and set it to false throughout the transform.
		#if selected is CSGShape3D:
			#csg_use_collisions.append({
				#"node": selected,
				#"use_collision": selected.use_collision
			#})
			#selected.use_collision = false
#
		## Also do the same for the children of the selected node.
		#for child: Node in selected_children:
			#if child is CSGShape3D:
				#csg_use_collisions.append({
					#"node": child,
					#"use_collision": child.use_collision
				#})
				#child.use_collision = false

		has_moved = true
	
	if scene_preview_3d_active:
		var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()

		# Obtain the ray origin and direction from the camera through the mouse position
		var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)

		# Calculate the intersection with the Y = 0 plane
		var plane_y = 0.0#10.0
		var distance = (plane_y - ray_origin.y) / ray_direction.y
		#if debug: print("distance: ", distance)
		# Compute the position on the Y = 0 plane
		var snap_position = ray_origin + ray_direction * distance




		###var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		###var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		#var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
		#var snap_position = editor_camera3d.project_position(mouse_pos, distance)






		# Adjust for .fbx imports with -90x
		# Apply transformation based on whether rotation should be preserved or not
		# FIXME Does not seem to do anything or needed
		#if object_rotated:
			#pass
			# Set placed scene to same location and rotation as scene preview adjust for .fbx importes with 90x
			#scene_preview_mesh.global_transform = Vector3(scene_preview_mesh.rotation.x, rotated_global_transform.rotation.y, rotated_global_transform.rotation.z)
			#if debug: print("what is this: ", scene_preview_mesh.get_class())
			#scene_preview_mesh.rotation = Vector3(scene_preview_mesh.rotation.x, rotated_global_transform.rotation.y, rotated_global_transform.rotation.z)


			#scene_preview_mesh.global_transform.basis = rotated_global_transform # Original
		#else:
			#pass
			# FIXME FIXME DO NOT DELETE
			#scene_preview_mesh.global_transform.basis = Basis.IDENTITY
			# FIXME FIXME DO NOT DELETE

		# TODO Change preview offset from pointer based on mesh/aabb size larger mesh do not fit on screen
		# Snap the object to the Y = 0 plane
		if snap_down and distance >= 0 and not mesh_hit:
			if scene_preview_mesh != null:
				#if debug: print("snap position: ", snap_position)
				if scene_preview_mesh.is_inside_tree():
					scene_preview_mesh.global_transform.origin = snap_position
			if scene_preview != null:
				#if debug: print("THIS IS ALSO WORKING!!")
				if scene_preview.is_inside_tree():
					scene_preview.global_transform.origin = snap_position
		else:
			pass

			#if scene_preview_mesh != null:
			## If not snapping, set it to a default position (3 units above the plane)
				#scene_preview_mesh.global_transform.origin = editor_camera3d.project_position(mouse_pos, 10)
			##scene_preview_mesh.global_transform.origin = ray_origin + ray_direction * 3
			#if scene_preview != null:
				#scene_preview.global_transform.origin = editor_camera3d.project_position(mouse_pos, 10)

		# Store the last position so that new scene preview does not spawn at Vector.ZERO
		if scene_preview_mesh and scene_preview_mesh.is_inside_tree():
			last_scene_preview_pos = scene_preview_mesh.global_transform.origin

	if not collision_hit:
		pass
		#if debug: print("no collision")
		#_mesh_snapping(viewport_camera, event)

	return AFTER_GUI_INPUT_PASS



var csg_use_collisions: Array[Dictionary] = []
var selected_children: Array[Node] = []
var visual_instances_data: Array[Dictionary] = []
#func _handles2(object: Object) -> bool: # ORIGINAL
	#if object is Node3D:
		#selected = object
		#visual_instances_data = []
		#collect_global_tris(object)
#
		#var out: Array[Node] = []
		#get_all_children(out, object, null, [CollisionObject3D, CSGShape3D])
		#selected_children = out
		#return true
#
	#selected = null
	#selected_children = []
	#visual_instances_data = []
	#return false

# Move to after scene is finished loading
func _handles(object: Object) -> bool: # TEST
	#if debug: print("object: ", object)
	if object is Node3D:
		selected = object
		
		
		#var mesh_node_instances: Array[Node] = object.find_children("*", "MeshInstance3D", true, false)
		#for mesh_child: MeshInstance3D in mesh_node_instances:
			#add_global_tris(mesh_child)
#
			#if not mesh_child.tree_exited.is_connected(remove_global_tris):
				#mesh_child.tree_exited.connect(remove_global_tris.bind(mesh_child))
				#if debug: print("signal connected")


		#if not visual_instances_data.size() > 0:
			#collect_global_tris(object)
		#visual_instances_data = []
		#else:
			#collect_global_tris2(object)

		var out: Array[Node] = []
		get_all_children(out, object, null, [CollisionObject3D, CSGShape3D])
		selected_children = out
		return true

	selected = null
	selected_children = []
	#visual_instances_data = []
	return false




func _on_left_mouse_button_pressed() -> void:
	if scene_preview_3d_active:# and editor_viewport_3d_active:
		move_pressed = true
		var existing_preview = get_tree().get_root().find_child("ScenePreview", true, true)
		if existing_preview:
			pass
		else:
			#if debug: print(EditorInterface.get_editor_viewport_3d(0).get_size())
			create_scene_preview()

var enable_placement: bool = false

# NOTE UPDATING IN PHYSICS PROCESS NEEDS TO MOVED HERE TOO SO THAT IT IS NOT MOVING PREVIEW WHEN OUTSIDE VIEWPORT
# This keeps input confined to the 3d viewport window
func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event:
		enable_placement = true

		
		#if debug: print("firing")
	#return EditorPlugin.AFTER_GUI_INPUT_STOP if event is InputEventMouseMotion else EditorPlugin.AFTER_GUI_INPUT_PASS


	### ADDED CODE
	## FIXME NEED TO CREATE SINGLE JUST PRESSED FOR MOUSE_BUTTON_LEFT TO PREVENT MANY SPAWANS OF scene_preview

	if event is InputEventMouseButton:
		##if debug: print("this is working here")
		# Prevent Scene Viewer panel zooming when in 3D viewport
		scene_viewer_panel_instance.enable_panel_button_sizing = false

		##if debug: print("motion")
		var mouse_event = event as InputEventMouseButton
		
		# Check if the event is for the left mouse button
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed and allow_pressed:
				# Left mouse button was pressed
				_on_left_mouse_button_pressed()
				# Prevents button from spamming scene previews
				allow_pressed = false
			elif not mouse_event.pressed:
				# Left mouse button was released
				allow_pressed = true

	if has_moved:
		for csg_data: Dictionary in csg_use_collisions:
			(csg_data['node'] as CSGShape3D).use_collision = csg_data['use_collision']
		
		csg_use_collisions = []

		#undoredo_action.add_do_property(selected, "global_transform", Transform3D(selected.global_transform))
		#undoredo_action.commit_action()
		has_moved = false


	if selected:
		if event is InputEventMouseMotion:
			#cast_distance = 0
			if not object_ids:
				tris.clear()
			#hit_object.clear()
			return _move_selection(viewport_camera, event)

	return AFTER_GUI_INPUT_PASS


const FLOAT64_MAX = 1.79769e308

func _mesh_snapping(viewport_camera: Camera3D, event: InputEventMouseMotion) -> void:
	var global_aabb: AABB
	# Mesh snapping
	from = viewport_camera.project_ray_origin(event.position)
	to = viewport_camera.project_ray_normal(event.position)

	#var min_t: float = FLOAT64_MAX
	#var min_p: Vector3 = Vector3.INF
	#var min_n: Vector3

	#var data_to_process: Array[Dictionary] = []

	# Check if aabb of visual instance intersects
	for data: Dictionary in visual_instances_data:
		
		#var global_aabb: AABB = data['aabb']
		global_aabb = data['aabb']
		var res: Variant = global_aabb.intersects_ray(from, to)
		if res is Vector3:
			#data_to_process.append(data)
			mesh_hit = true
			## TEMP DISABLED
			#if snap_flush_scene:
				#snap_flush_scene.make_it_flush = true

	#for data: Dictionary in data_to_process:
		#var tris: PackedVector3Array = data['tris']
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
			#var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			#if res is Vector3:
				#var len: float = from.distance_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1)

	#if min_t >= FLOAT64_MAX:
		#mesh_hit = false
		### TEMP DISABLED
		##if snap_flush_scene:
			##snap_flush_scene.make_it_flush = false
		#return

# TEMP DISABLED
	#scene_preview_snap_to_normal(min_p, min_n)




func _mesh_snapping2(viewport_camera: Camera3D, event: InputEventMouseMotion) -> void: #ORIGINAL
	var global_aabb: AABB
	# Mesh snapping
	from = viewport_camera.project_ray_origin(event.position)
	to = viewport_camera.project_ray_normal(event.position)

	var min_t: float = FLOAT64_MAX
	var min_p: Vector3 = Vector3.INF
	var min_n: Vector3

	var data_to_process: Array[Dictionary] = []


# TEST




# TEST






	#if debug: print("visual_instances_data.size(): ", visual_instances_data.size())
	# Check if aabb of visual instance intersects
	for data: Dictionary in visual_instances_data:
		
		#var global_aabb: AABB = data['aabb']
		global_aabb = data['aabb']
		var res: Variant = global_aabb.intersects_ray(from, to)
		if res is Vector3:
			data_to_process.append(data)
			mesh_hit = true
			## TEMP DISABLED
			#if snap_flush_scene:
				#snap_flush_scene.make_it_flush = true

	for data: Dictionary in data_to_process:
		var tris: PackedVector3Array = data['tris']
		for i: int in range(0, tris.size(), 3):
			var v0: Vector3 = tris[i + 0]
			var v1: Vector3 = tris[i + 1]
			var v2: Vector3 = tris[i + 2]
			var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			if res is Vector3:
				var len: float = from.distance_to(res)
				if len < min_t:
					min_t = len
					min_p = res
					var v0v1: Vector3 = v1 - v0
					var v0v2: Vector3 = v2 - v0
					min_n = v0v2.cross(v0v1)

	if min_t >= FLOAT64_MAX:
		mesh_hit = false
		## TEMP DISABLED
		#if snap_flush_scene:
			#snap_flush_scene.make_it_flush = false
		return

# TEMP DISABLED
	#scene_preview_snap_to_normal(min_p, min_n)


func _collision_objects_snapping(viewport_camera: Camera3D, event: InputEventMouseMotion) -> void:
	# Physics snapping
	var from: Vector3 = viewport_camera.project_ray_origin(event.position)
	var to: Vector3 = from + viewport_camera.project_ray_normal(event.position) * RAY_LENGTH
	var space: PhysicsDirectSpaceState3D = viewport_camera.get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

	if scene_preview_3d_active:
		var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		var space_state = editor_camera3d.get_world_3d().direct_space_state
		
		if not scene_preview_mesh == null:

			scene_preview_mesh.position = editor_camera3d.project_position(mouse_pos, 3)

	# Exclude selected node and its children if its or CollisionObject3D.
	# (CSG exclusion happens before first movement)
	var exclude_list: Array[RID] = []

	# Exclude the selected node
	if selected is CollisionObject3D:
		exclude_list.append(selected.get_rid())
	
	# Exclude CollisionObject children of the selected node
	for child: Node in selected_children:
		if child is CollisionObject3D:
			exclude_list.append((child as CollisionObject3D).get_rid())

	ray_query.exclude = exclude_list

	ray_query.from = from
	ray_query.to = to

	var result: Dictionary  = space.intersect_ray(ray_query)

	if result.has("position") and result.has("normal"):
		collision_hit = true

		## TEMP DISABLED
		#if snap_flush_scene:
			#snap_flush_scene.make_it_flush = true
		## TEMP DISABLED
		#scene_preview_snap_to_normal(result.position, result.normal)
	else:
		collision_hit = false
		## TEMP DISABLED
		#if snap_flush_scene:
			#snap_flush_scene.make_it_flush = false


### Get global triangle of all nodes in the scene, except the [exclude] node and its children.
## do this once on scene load
#func collect_global_tris(exclude: Node) -> void:
	#var nodes: Array[Node] = []
	#get_all_children(nodes, EditorInterface.get_edited_scene_root(), exclude, [MeshInstance3D, CSGShape3D])
	#for node: Node in nodes:
		#if node is MeshInstance3D:
			#var mesh: Mesh = node.mesh
			#if !mesh: continue
			#
			#var aabb: AABB = node.global_transform * node.get_aabb()
			#var tris: PackedVector3Array = []
			#
			#var verts: PackedVector3Array = mesh.get_faces()
			#for vert: Vector3 in verts:
				#tris.append(node.global_transform * vert)
#
			#visual_instances_data.append({ "node": node, "aabb": aabb, "tris": tris })
#
		#elif node is CSGShape3D:
			#var meshes: Array = node.get_meshes()
			#if meshes.is_empty(): continue
#
			#var aabb: AABB = node.global_transform * node.get_aabb()
			#var tris: PackedVector3Array = []
#
			#var verts: PackedVector3Array = (meshes[1] as ArrayMesh).get_faces()
			#for vert: Vector3 in verts:
				#tris.append(node.global_transform * vert)
#
			#visual_instances_data.append({ "node": node, "aabb": aabb, "tris": tris })
#

var scene_pinned_node: Dictionary [Node, Node] = {}

func changed_to_new_scene(scene_root: Node) -> void:
	# Temporarly block removal of pinned node pin since switching scene tabs triggers node removal signal
	allow_pin_removal = false
	
	# Disable ScenePreview and Dragging when switching between scene tabs
	# FIXME must be removed before changing scene tree and new root
	if scene_preview_3d_active:
		scene_preview_3d_active = false
		
		remove_existing_scene_preview()
	dragging_node = null

	#if scene_preview:
		#scene_preview.queue_free()
		#scene_preview = null
	


	# Tie pinned_node to scene_root
	#if debug: print("EditorInterface.get_edited_scene_root(): ", EditorInterface.get_edited_scene_root())
	#if debug: print("scene_root: ", scene_root)
	# Restore pinned node when switching between tabs NOTE: check if tab has scene tree by checking for scene_root
	#if pinned_node and scene_root:
		#if debug: print("pinned_node.name: ", pinned_node.get_path())
		#add_pin_button()




	if scene_root:
		for key: Node in scene_pinned_node.keys():
			#if debug: print("key: ", key)
			if scene_root == key: # Match the current scene root with the one in the dict
				change_selection_to(scene_pinned_node[key])
				await get_tree().create_timer(0.01).timeout # Give time for change to take effect
				# Update pinned_tree_item and pinned_node variables from scene_pinned_node dict 
				# NOTE: pinned_tree_item in _physics_process will reset blue pin icon
				pinned_tree_item = scenedock_tree.get_selected()
				var node_path = pinned_tree_item.get_metadata(0)
				pinned_node = EditorInterface.get_edited_scene_root().get_node(node_path)


	
	await get_tree().create_timer(3).timeout
	allow_pin_removal = true

	#scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()

	#scenario_rid = scene_root.get_world_3d().get_scenario()
	## Pass scenario_rid to rust_script
	##rust_script.store_scenario_rid(scenario_rid)
	#scene_root_node = scene_root
	#visual_instances_data = []
#
	#if scene_root != null:
		#var mesh_node_instances: Array[Node] = scene_root.find_children("*", "MeshInstance3D", true, false)
		#if debug: print("mesh_node_instances: ", mesh_node_instances.size())







		
		
		
		
		
#
#func changed_to_new_scene(scene_root: Node) -> void:
	#visual_instances_data = []
#
	#if scene_root != null:
		#var mesh_node_instances: Array[Node] = scene_root.find_children("*", "MeshInstance3D", true, false)
		#if debug: print("mesh_node_instances: ", mesh_node_instances.size())
		#for mesh_node_child: MeshInstance3D in mesh_node_instances:
#
			#add_global_tris(mesh_node_child)
#
			#if not mesh_node_child.tree_exited.is_connected(remove_global_tris):
				#mesh_node_child.tree_exited.connect(remove_global_tris.bind(mesh_node_child))
#
#
#func remove_global_tris(node: Node) -> void:
	#for data: Dictionary in visual_instances_data:
		#if data["node"] == node:
			#visual_instances_data.erase(data)
			#break
#
#
## Do this every time new node is added only clear visual_instances_data when changing to new scene tree
#func add_global_tris(node: Node) -> void:
	#var mesh: Mesh = node.mesh
#
	#var aabb: AABB = node.global_transform * node.get_aabb()
	#var tris: PackedVector3Array = []
	#
	#var verts: PackedVector3Array = mesh.get_faces()
	#for vert: Vector3 in verts:
		#tris.append(node.global_transform * vert)
#
	#visual_instances_data.append({ "node": node, "aabb": aabb, "tris": tris })










## Transform local triangle to global triangle.
func _local_tri_to_global_tri(trf: Transform3D, tri: Vector3) -> Vector3:
	return trf * tri

## Returns all the children of [node] recursively. Limit to specific types using [types]. 
func get_all_children(out: Array[Node], node: Node, exclude: Node = null, types: Array[Variant] = []) -> void:
	if node == exclude: return
	for child: Node in node.get_children():
		if child == exclude: continue

		if types.is_empty():
			out.append(child)
		else:
			for type: Variant in types:
				if is_instance_of(child, type):
					out.append(child)
					break
		
		if child.get_child_count() > 0:
			get_all_children(out, child, exclude, types)

func get_quaternion_from_normal(old_basis: Basis, new_normal: Vector3) -> Quaternion:
	new_normal = new_normal.normalized()

	var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
	var new_right : Vector3 = quat * old_basis.x
	var new_fwd : Vector3 = quat * old_basis.z

	return Basis(new_right, new_normal, new_fwd).get_rotation_quaternion()

############ EXTRASNAPS PLUGIN CODE
#endregion



# NOTE: scene_preview_mesh will not be available when first called because still loading from thread
func set_scene_to_collision_point(collision_point: Vector3) -> void:
	if scene_preview_mesh:
		scene_preview_mesh.global_position = collision_point
		# Create new Scene Preview at last ones position
		last_scene_preview_pos = collision_point


#var last_previews_global_position: Vector3
var t = 0.0
#var last_collision_point: Vector3 = Vector3.ZERO

func apply_scene_preview_snap_logic(collision_point: Vector3, vector_normal: Vector3, snap_flag: String) -> void:
	await get_tree().process_frame # Give time for scene_preview node to be added to tree
	# FIXME AWAIT FULL LOAD OF SCENE FROM THREAD
	if dragging_node != null and dragging_node.is_inside_tree():
		dragging_node.global_position = collision_point
	if scene_preview != null and scene_preview.is_inside_tree():
		var vector_normal_normalized = vector_normal.normalized()
		if snap_flag and vector_normal_normalized != Vector3.ZERO:
			#var vector_normal_normalized = vector_normal.normalized()
			# NOTE adjust for none child(0) meshinstance3d children or multiple mesh
			# NEED TO GET FIRST MESHINSTANCE3D
			# REFACTOR THIS IF CHANGING TO MESHINSTANCE3D SCENE_PREVIEW
			var preview_mesh: Mesh = scene_viewer_panel_instance.get_scenes_first_mesh_node(scene_preview).get_mesh()
			if debug: print("scene_preview mesh: ", preview_mesh)
			if debug: print("scene_preview children: ", scene_preview.get_children())
			#var scene_preview_mesh_child = scene_preview_mesh.get_child(0)
			var scene_preview_aabb = preview_mesh.get_aabb()

			#if snap_flag == "Surface Normal Z Forward":
				#if debug: print("snap out")
			# TEST Need to get child label text not the container box
			if snap_flag == "OutputSnap":
				if debug: print("vector_normal_normalized: ", vector_normal_normalized)
				# FIXME for vector_normal_normalized.y == -1 consider ofset of aabb down but that might just need to be anohter parameter.
				# separate connections each only have one outcome but that can be combined to give overall result
				# Example Snap out and offset aabb in direction of vector
				# FIXME Will lose scale 
				if vector_normal_normalized.y == 1 or vector_normal_normalized.y == -1:
					## Extract the original global transform (position, rotation, scale)
					var original_global_transform = scene_preview_mesh.global_transform

					# FIXME HACK Since scaling should be uniform grab scale of either x or z axis and apply to y axis  
					if debug: print("original_global_transform.basis.get_scale(): ", original_global_transform.basis.get_scale().x)
					if debug: print("original_global_transform: ", original_global_transform)

					# FIXME HACK Since scaling should be uniform grab scale of either x or z axis and apply to y axis  
					# Reset the Y-axis while keeping the transforms of the the x and z axis
					var reset_y_vertical: Basis = Basis(original_global_transform.basis.x, Vector3(0, original_global_transform.basis.get_scale().x, 0), original_global_transform.basis.z).orthonormalized()
					
					
					reset_y_vertical = reset_y_vertical.scaled(original_global_transform.basis.get_scale())
					#reset_y_vertical = reset_y_vertical.orthonormalized()
					scene_preview_mesh.global_transform.basis = reset_y_vertical


				else:
					if debug: print("snap out")


					# Extract the original global transform (position, rotation, scale)
					var original_global_transform = scene_preview_mesh.global_transform

					#var new_basis: Basis
					## Snap to looking_at but don't hold there for user added rotation input
					#if collision_point != last_collision_point:
						#last_collision_point = collision_point
					# Create the new rotation using looking_at
					var new_basis: Basis = Basis().looking_at(vector_normal, Vector3.UP, true)

					# Apply the new basis (rotation)
					var new_transform = Transform3D(new_basis, original_global_transform.origin)

					# Preserve the original scale by multiplying the new basis with the scale
					new_transform.basis = new_transform.basis.scaled(original_global_transform.basis.get_scale())

					# Set the global transform to the new transform (with the new rotation and preserved scale)
					scene_preview_mesh.global_transform = new_transform









					set_scene_to_collision_point(collision_point)

					
					##scene_preview_mesh.global_position = collision_point
					### Create new Scene Preview at last ones position
					##last_scene_preview_pos = collision_point



					## Point the Z Axis of scene_preview_mesh towards the dest vector normal
					#scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)

					## Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
					#var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)
#
					## Apply the rotation
					#scene_preview_mesh.global_transform.basis = rotation_90





			if snap_flag == "snap_end":

				# CHANGE THE POSITION
				# Normalize the normal vector
				var x_dir = vector_normal_normalized
				#if debug: print(x_dir)
				# Compute the new Y and Z directions
				var z_dir = Vector3.DOWN.cross(x_dir).normalized()  # Compute Z by cross product with DOWN
				var y_dir = z_dir.cross(x_dir).normalized()       # Compute Y by cross product with Z and X
				# Create the Basis matrix with X, Y, Z directions
				var basis = Basis(x_dir, y_dir, z_dir)
				scene_preview_mesh.global_transform.basis = basis
				
				
				# Compute the offset in local space
				var offset_local = Vector3(scene_preview_aabb.size.x / 2, 0, 0)
				# Apply the offset to the object's transform
				scene_preview_mesh.position += scene_preview_mesh.transform.basis * offset_local
				enable_placement = false
				return




			if vector_normal_normalized.y == 1:
				if snap_flag == "center_pipe":
				#if center_pipe:

					# Point the Z Axis of scene_preview_mesh towards the dest vector normal
					scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)

					# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
					var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)

					# Apply the rotation
					scene_preview_mesh.global_transform.basis = rotation_90

				else:
					#scene_preview_mesh.position = collision_point

					scene_preview_mesh.global_position = collision_point
					# Create new Scene Preview at last ones position
					last_scene_preview_pos = collision_point

				enable_placement = false
				return

			if vector_normal_normalized.y == -1:
				if snap_flag == "center_pipe":
				#if center_pipe:

					# Point the Z Axis of scene_preview_mesh towards the dest vector normal
					scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)

					# Rotate the current basis from above 90 degrees so X Axis is pointing towards the dest vector normal
					var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)

					# Apply the rotation
					scene_preview_mesh.global_transform.basis = rotation_90

				else:
					scene_preview_mesh.position = collision_point - Vector3(0, scene_preview_aabb.size.y, 0)

				enable_placement = false
				return

		else:
			## Look at camera?
			#var editor_camera3d_position: Vector3 = EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_position
			#scene_preview_mesh.global_transform.basis = Basis().looking_at(editor_camera3d_position, Vector3.UP, true)
			
			#scene_preview_mesh.global_transform.basis = Basis.IDENTITY
			set_scene_to_collision_point(collision_point)
		#scene_preview_mesh.global_position = collision_point
		## Create new Scene Preview at last ones position
		#last_scene_preview_pos = collision_point

	else:
		# Set both scene_preview and scene_preview_mesh = null so that update_scene_preview_and_visible_buttons()
		# can regenerate scene_preview on next KEY_Q LEFT MOUSE CLICK
		# FIXME TODO THIS IS WHAT IS FLIPPING AWAIT SCENE PREVIEW TO OFF
		# if scene_preview != null and scene_preview.is_inside_tree() NOT FINISHED LOADING SO NOT IN TREE WHEN CHECK IS PERFORMED
		# SO NEED TO DELAY CHECK UNTIL THREAD FINISHS LOADING SCENE
		scene_preview_3d_active = false
		scene_preview = null
		scene_preview_mesh = null



	enable_placement = false





#func scene_preview_snap_to_normal(collision_point: Vector3, vector_normal: Vector3, snap_flag: String) -> void:
	#await get_tree().process_frame # Give time for scene_preview node to be added to tree
	#if dragging_node != null and dragging_node.is_inside_tree():
		#dragging_node.global_position = collision_point
	#if scene_preview != null and scene_preview.is_inside_tree():
		#var vector_normal_normalized = vector_normal.normalized()
		#var scene_preview_aabb = scene_preview_mesh.get_aabb()
		#if snap_flag == "snap_end":
#
			## CHANGE THE POSITION
			## Normalize the normal vector
			#var x_dir = vector_normal_normalized
			##if debug: print(x_dir)
			## Compute the new Y and Z directions
			#var z_dir = Vector3.DOWN.cross(x_dir).normalized()  # Compute Z by cross product with DOWN
			#var y_dir = z_dir.cross(x_dir).normalized()       # Compute Y by cross product with Z and X
			## Create the Basis matrix with X, Y, Z directions
			#var basis = Basis(x_dir, y_dir, z_dir)
			#scene_preview_mesh.global_transform.basis = basis
			#
			#
			## Compute the offset in local space
			#var offset_local = Vector3(scene_preview_aabb.size.x / 2, 0, 0)
			## Apply the offset to the object's transform
			#scene_preview_mesh.position += scene_preview_mesh.transform.basis * offset_local
		#
		#
		#
		#
		#
		## NOTE Will be a heavy operation especially as connections grow TODO find way to limit connection checks while keeping fast
		###################################################################################KEEP NOTE TEMP DISABLED
		##process_snap_flow_manager_connections(scene_preview)
		###################################################################################KEEP NOTE TEMP DISABLED
	## Create a new Transform3D that only has the position from the collision_point
		##var target_transform = Transform3D.IDENTITY
		##target_transform.origin = collision_point  # Set the target position
		##
		##t += delta * 0.4
		###if debug: print(scene_preview_mesh.get_physics_interpolation_mode())
		##scene_preview_mesh.set_physics_interpolation_mode(2)
		##scene_preview_mesh.global_position.lerp(collision_point, t)
		##scene_preview_mesh.global_transform.origin = 
		##var new_position = scene_preview_mesh.transform.origin.linear_interpolate(target_transform.origin, t)
		#
		#
		#
		##scene_preview_mesh.transform = scene_preview_mesh.transform.interpolate_with(target_transform, t)
		#
#
#
			## Use the new interpolation method from TransformInterpolator
		##var interpolated_transform = Transform3D.IDENTITY
#
#
	## Interpolate the position (linear interpolation)
	##	var new_position = scene_preview_mesh.transform.origin.linear_interpolate(target_transform.origin, t)
#
	## Interpolate the rotation (spherical linear interpolation for quaternions)
	##	var new_rotation = scene_preview_mesh.transform.basis.slerp(target_transform.basis, t)
#
	## Apply the interpolated transform to the mesh
	##	scene_preview_mesh.transform.origin = new_position
	##	scene_preview_mesh.transform.basis = new_rotation
#
		##RenderingServer.interpolate_transform_3d(scene_preview_mesh.transform, target_transform, interpolated_transform, t)
		##scene_preview_mesh.transform = scene_preview_mesh.transform.interpolate_transform_3d(scene_preview_mesh.transform, target_transform, interpolated_transform, t)
	#
		## Apply the interpolated transform to the mesh
	##	scene_preview_mesh.transform = interpolated_transform
#
#
#
#
#
		##scene_preview_mesh.interpolate_with(collision_point, t)
		##scene_preview_mesh.transform = scene_preview_mesh.transform.interpolate_with(target_transform, t)
		##scene_preview_mesh.global_position = scene_preview_mesh.global_position.lerp(collision_point, t)
		##scene_preview_mesh.transform.interpolate_with(target_transform, t)
		##scene_preview_mesh.global_transform.origin.lerp(collision_point, t)
		##scene_preview_mesh.global_position.lerp(collision_point, t)
		#
#
		#scene_preview_mesh.global_position = collision_point
		## Create new Scene Preview at last ones position
		#last_scene_preview_pos = collision_point
		##var vector_normal_normalized = vector_normal.normalized()
		##if debug: print("vector_normal_normalized: ", vector_normal_normalized)
#
		##for data: Dictionary in visual_instances_data:
			##if data["node"] == node:
			##visual_instances_data.erase(data)
		##visual_instances_data
#
#
		##for data: Dictionary in visual_instances_data:
			##var mesh_node: MeshInstance3D = data["node"]
			##var mesh: Mesh = mesh_node.mesh
##
			##var dest_global_aabb: AABB = mesh_node.global_transform * mesh_node.get_aabb()
			##
			##var dest_global_transform: Basis = mesh_node.global_transform.basis
##
			### NOTE adjust for none child(0) meshinstance3d children or multiple mesh
			##var scene_preview_mesh = scene_preview_mesh.get_child(0)
			##if scene_preview_mesh is MeshInstance3D:
				##var scene_preview_aabb = scene_preview_mesh.get_aabb()
##
				### Toggle between regular normal and rounded normal for different snapping characteristics
				##if snap_normal_round:
					##vector_normal_normalized = vector_normal_normalized.round()
##
				### target will be the scenes position + the direction of the raycast hits normal
				##var target_position = scene_preview_mesh.global_transform.origin + vector_normal_normalized
##
				##if vector_normal_normalized.y == 1:
##
					##if center_pipe:
						##if debug: print("cneter pipe")
##
############## *********************** ##################
##
						### Point the Z Axis of scene_preview_mesh towards the dest vector normal
						##scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)
##
						### Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
						##var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)
##
						### Apply the rotation
						##scene_preview_mesh.global_transform.basis = rotation_90
##
############## *********************** ##################
##
					##else:
						##scene_preview_mesh.global_position = collision_point
						###scene_preview_mesh.position = collision_point
	#else:
		## Set both scene_preview and scene_preview_mesh = null so that update_scene_preview_and_visible_buttons()
		## can regenerate scene_preview on next KEY_Q LEFT MOUSE CLICK
		#scene_preview_3d_active = false
		#scene_preview = null
		#scene_preview_mesh = null
#
#
#
	#enable_placement = false



#region # FIXME DISABLED BECAUSE MESSING WITH SCALE OF QUATERNIUS ASSETS
# FIXME DISABLED BECAUSE MESSING WITH SCALE OF QUATERNIUS ASSETS

# NOTE is now func apply_scene_preview_snap_logic(collision_point: Vector3, vector_normal: Vector3, snap_flag: String) -> void:
func scene_preview_snap_to_normal2(collision_point: Vector3, vector_normal: Vector3) -> void:
	if not scene_preview == null:
		#if debug: print("vector_normal: ", vector_normal)
		#if debug: print("working")
		scene_preview_mesh.global_position = collision_point
		vector_normal = vector_normal
		var vector_normal_normalized = vector_normal.normalized()
		#if debug: print("vector_normal normalized: ", vector_normal_normalized)
		
		
		var nodes: Array[Node] = []
		get_all_children(nodes, EditorInterface.get_edited_scene_root(), selected, [MeshInstance3D, CSGShape3D])
		for node: Node in nodes:
			if node is MeshInstance3D:
				var mesh: Mesh = node.mesh
				if !mesh: continue
				
				var dest_global_aabb: AABB = node.global_transform * node.get_aabb()
				
				var dest_global_transform: Basis = node.global_transform.basis

				# NOTE adjust for none child(0) meshinstance3d children or multiple mesh
				var scene_preview_mesh = scene_preview_mesh.get_child(0)
				if scene_preview_mesh is MeshInstance3D:
				#if scene_preview_mesh is StaticBody3D:
					#if debug: print(vector_normal_normalized)
					var scene_preview_aabb = scene_preview_mesh.get_aabb()
					#if debug: print(scene_preview_aabb)
					# Toggle between regular normal and rounded normal for different snapping characteristics
					if snap_normal_round:
						vector_normal_normalized = vector_normal_normalized.round()
						
					#if debug: print(vector_normal_normalized)

					# target will be the scenes position + the direction of the raycast hits normal
					var target_position = scene_preview_mesh.global_transform.origin + vector_normal_normalized
					## Rotate smoothly with look_at (Andrea)
					## Reference: https://forum.godotengine.org/t/rotate-smoothly-with-look-at/16888/2
					#scene_preview.position = (raycast_result.position - scene_preview_aabb.get_center()) + Vector3(0, 0, scene_preview_aabb.size.z / 2)
					
					#scene_preview.global_transform.basis = scene_preview.global_transform.looking_at(target_position, Vector3.UP, true).basis



					if vector_normal_normalized.y == 1:
						if center_pipe:

############ *********************** ##################

							# Point the Z Axis of scene_preview_mesh towards the dest vector normal
							scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)

							# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
							var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)

							# Apply the rotation
							scene_preview_mesh.global_transform.basis = rotation_90

############ *********************** ##################

							
						else:
							scene_preview_mesh.position = collision_point
							#scene_preview.quaternion = get_quaternion_from_normal(scene_preview.basis, vector_normal_normalized)
					if vector_normal_normalized.y == -1:
						if center_pipe:
							
							
							# Point the Z Axis of scene_preview_mesh towards the dest vector normal
							scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.RIGHT)

							# Rotate the current basis from above 90 degrees so X Axis is pointing towards the dest vector normal
							var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)

							# Apply the rotation
							scene_preview_mesh.global_transform.basis = rotation_90
							
							
							
							
							## Calculate the direction vector from the mesh to the target position
							#var direction_to_target = (target_position - scene_preview_mesh.global_transform.origin).normalized()
##
							### Create a 90-degree rotation matrix around the Vector3.UP axis
							#var rotation_basis = Basis().rotated(Vector3.FORWARD, deg_to_rad(90))
##
							### Apply the rotation to the direction vector
							#var rotated_direction = rotation_basis * direction_to_target
#
							## Set the new basis for the mesh
							#scene_preview_mesh.global_transform.basis = Basis().looking_at(rotated_direction, Vector3.FORWARD)
						else:
							scene_preview_mesh.position = collision_point - Vector3(0, scene_preview_aabb.size.y, 0)
					if not vector_normal_normalized.y == 1 and not vector_normal_normalized.y == -1:
						
						
						if is_zero_approx(scene_preview_aabb.position.x): # Do not move to center if origin already at center Example Center Pipe
							pass
							
							
							
							
							


						else:
							# NOTE MAKE OPTIONAL SNAP AT BOTTOM EXAMPLE FOR TREES OR SNAP A MIDDLE FOR OTHER OBJECTS MAYBE
							# Set the ScenePreview at the raycast position at its center
							scene_preview_mesh.position = (collision_point - scene_preview_aabb.get_center())
							# Set the ScenePreview at the raycast position at its bottom
							#scene_preview.position = collision_point
						
						

						
						#if debug: print(scene_preview_aabb)
						# FIXME MAKE RULES FOR POSSIBLE SNAPPING DEFAULTS -STANDARD ROOM OBJECT - HANGING OBJECT - WALLS - DOORS - FLOOR PANELS
						if scene_preview_aabb.size.x > scene_preview_aabb.size.z * 5 and scene_preview_aabb.size.y > scene_preview_aabb.size.x * 1.5: # DOOR FILTER NOTE OFFSET MAY CHANGE WITH DIFFERENT STUDIO'S ASSETS
							# CHANGE THE ROTATION
							# Normalize the normal vector
							var x_dir = vector_normal_normalized
							# Compute the new Y and Z directions
							var z_dir = Vector3.DOWN.cross(x_dir).normalized()  # Compute Z by cross product with UP
							var y_dir = z_dir.cross(x_dir).normalized()       # Compute Y by cross product with Z and X
							# Create the Basis matrix with X, Y, Z directions
							var basis = Basis(x_dir, y_dir, z_dir)
							scene_preview_mesh.global_transform.basis = basis
							
							
							#scene_preview.global_transform.basis = scene_preview.global_transform.looking_at(target_position, Vector3.UP, true).basis
							##scene_preview.look_at(target_position, Vector3(0,1,0))
							#scene_preview.rotate_object_local(Vector3(0, 1, 0), -PI / 2.0)
							
							# CHANGE THE POSITION
							# Compute the offset in local space
							var offset_local = Vector3(scene_preview_aabb.size.x / 2, 0, 0)
							#Apply the offset to the object's transform
							scene_preview_mesh.position += offset_local
							door = true
							if debug: print("a door")
						
						elif scene_preview_aabb.size.x > scene_preview_aabb.size.z * 3 and scene_preview_aabb.size.y < scene_preview_aabb.size.x / 1.5: # WALL FILTER
							# CHANGE THE POSITION
							# Normalize the normal vector
							var x_dir = vector_normal_normalized
							#if debug: print(x_dir)
							# Compute the new Y and Z directions
							var z_dir = Vector3.DOWN.cross(x_dir).normalized()  # Compute Z by cross product with DOWN
							var y_dir = z_dir.cross(x_dir).normalized()       # Compute Y by cross product with Z and X
							# Create the Basis matrix with X, Y, Z directions
							var basis = Basis(x_dir, y_dir, z_dir)
							scene_preview_mesh.global_transform.basis = basis
							
							
							# Compute the offset in local space
							var offset_local = Vector3(scene_preview_aabb.size.x / 2, 0, 0)
							# Apply the offset to the object's transform
							scene_preview_mesh.position += scene_preview_mesh.transform.basis * offset_local
							wall = true
							if debug: print("a wall")

						
						# is_zero_approx(scene_preview_aabb.position.z) this if accounts for scenes that are placed with z = 0 on the back of the scene_preview_aabb box example moose head wall mount
						elif is_zero_approx(scene_preview_aabb.position.z):
							#if debug: print("abount 0 Z")
							scene_preview_mesh.global_transform.basis = scene_preview_mesh.global_transform.looking_at(target_position, Vector3.UP, true).basis
							scene_preview_mesh.position = collision_point
							if debug: print("moose head")


						elif is_zero_approx(scene_preview_aabb.position.x) or not is_zero_approx(scene_preview_aabb.position.y):
							if debug: print("a pipe")
						#elif not is_zero_approx(scene_preview_aabb.position.y):
							#if debug: print("a pipe")
							
							#var transform_x_axis = scene_preview_mesh.global_transform.basis.get_euler()
							#if debug: print(transform_x_axis)
							
							#var new transform = 
							#if not last_basis.is_equal_approx(scene_preview_mesh.global_transform.basis):
							# Update Transform only if the vector_normal changes enough from last frame This enables the rotation to be kept while moving on surface
							# NOTE ADJUST TO FIT SENSITIVITY
							if not last_vector_normal.is_equal_approx(vector_normal):
								last_vector_normal = vector_normal
								
								# Point the Z Axis of scene_preview_mesh towards the dest vector normal
								scene_preview_mesh.global_transform.basis = Basis().looking_at(vector_normal, Vector3.UP)

								# Rotate the current basis from above 90 degrees so X Axis is pointing away the dest vector normal
								var rotation_90: Basis = scene_preview_mesh.global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, TAU / 4)

								# Apply the rotation
								scene_preview_mesh.global_transform.basis = rotation_90
								
								
								
								# TEMP DISABLED NOTE
								## Create new center ray for snapping
								#var center_ray_nodes: Array[Node] = get_tree().get_nodes_in_group("center_ray")
								#for center_ray_node in center_ray_nodes:
									#if center_ray_node:
										#center_ray_node.queue_free()
								##var existing_ray = get_tree().get_root().find_child("CenterRay", true, false)
								##if existing_ray:
									##existing_ray.queue_free()
								##if center_ray_nodes == []:
									##create_center_snap_ray = true
								#center_ray = CENTER_ALIGN_RAY.instantiate()
								#EditorInterface.get_edited_scene_root().add_child(center_ray)
								##center_ray.owner = EditorInterface.get_edited_scene_root()
								#center_ray.name = "CenterRay"
								#if initialize_center_ray:
									#center_ray.global_transform.origin = collision_point
									#initialize_center_ray = false
								##center_ray.global_transform.origin.z += 1
								#center_ray.global_transform.basis = Basis().looking_at(vector_normal, Vector3.UP)
								#center_ray.get_child(0).target_position = (vector_normal.normalized() * -1)# / 50
								##if debug: print("creating ray")
								#process_ray = true







								#if debug: print(vector_normal.normalized())
								
								
								#if create_center_snap_ray:
									#var center_ray: Node3D = CENTER_ALIGN_RAY.instantiate()
									#EditorInterface.get_edited_scene_root().add_child(center_ray)
									#center_ray.owner = EditorInterface.get_edited_scene_root()
									#center_ray.name = "CenterRay"
									#center_ray.global_transform.origin = collision_point
									#center_ray.get_child(0).target_position = vector_normal_normalized * -1
									#create_center_snap_ray = false
								
								
								
								
								
								


								#if debug: print("center pipe")
								
							

						else: # STANDARD OBJECT
							scene_preview_mesh.global_transform.basis = Basis.IDENTITY
							
							
							##if debug: print("standard object")
							#scene_preview_mesh.global_transform.basis = scene_preview_mesh.global_transform.looking_at(target_position, Vector3.UP, true).basis
							## Compute the offset in local space
							#var offset_local = Vector3(0, 0, scene_preview_aabb.size.z / 2)
							### Apply the offset to the object's transform
							#scene_preview_mesh.position += scene_preview_mesh.transform.basis * offset_local
							if debug: print("standard")






						## TEMP DISABLED
						#if snap_flush_scene:
							#snap_flush_scene.destination_surface_normal = vector_normal_normalized

					# TEMP DISABLED
					aabb_flush_snapping(node, dest_global_aabb, scene_preview_aabb, vector_normal_normalized, collision_point)




func aabb_flush_snapping(node: Node3D, dest_global_aabb: AABB, scene_preview_aabb: AABB, vector_normal_normalized: Vector3, collision_point: Vector3) -> void:

	var res: Variant = dest_global_aabb.intersects_ray(from, to)
	if res is Vector3:
		pass

		if snap_flush_center_pipe:
			pass


		if snap_flush_bottom:
			scene_preview_mesh.global_transform.origin.y = dest_global_aabb.position.y

		if snap_flush_top:
					##collect_global_tris(object)
			var scene_preview_offset: float = scene_preview_aabb.size.y
			scene_preview_mesh.global_transform.origin.y = dest_global_aabb.position.y + dest_global_aabb.size.y - scene_preview_offset

				
		var scene_preview_offset: float
		if door or wall:
			scene_preview_offset = scene_preview_aabb.size.z / 2
		else:
			scene_preview_offset = scene_preview_aabb.size.x / 2
		var plus_destination_edge_offset: Vector3 = dest_global_aabb.get_center() + dest_global_aabb.size / 2
		var minus_destination_edge_offset: Vector3 = dest_global_aabb.get_center() - dest_global_aabb.size / 2
				
		match vector_normal_normalized:
			Vector3(0,0,1):
				if snap_flush_left: # Will depend on returned normal and apply a vector that is perpendicular to that
					scene_preview_mesh.global_transform.origin.x = minus_destination_edge_offset.x + scene_preview_offset

				if snap_flush_right:
					scene_preview_mesh.global_transform.origin.x = plus_destination_edge_offset.x - scene_preview_offset

			Vector3(0,0,-1):
				if snap_flush_left:
					scene_preview_mesh.global_transform.origin.x = plus_destination_edge_offset.x - scene_preview_offset

				if snap_flush_right: # Will depend on returned normal and apply a vector that is perpendicular to that
					scene_preview_mesh.global_transform.origin.x = minus_destination_edge_offset.x + scene_preview_offset

			Vector3(1,0,0):
				if snap_flush_left:
					scene_preview_mesh.global_transform.origin.z = plus_destination_edge_offset.z - scene_preview_offset

				if snap_flush_right:
					scene_preview_mesh.global_transform.origin.z = minus_destination_edge_offset.z + scene_preview_offset

			Vector3(-1,0,0):
				if snap_flush_left:
					scene_preview_mesh.global_transform.origin.z = minus_destination_edge_offset.z + scene_preview_offset

				if snap_flush_right:
					scene_preview_mesh.global_transform.origin.z = plus_destination_edge_offset.z - scene_preview_offset

# FIXME DISABLED BECAUSE MESSING WITH SCALE OF QUATERNIUS ASSETS
#endregion

# Updates scene_preview to the currently selected scene button 
func set_scene_preview(value) -> void:
	if scene_preview_3d_active:
		remove_existing_scene_preview()
		create_scene_preview()



var size_y: float = 0

var focus_popup_on_start: bool = true

#var editor_theme = get_editor_interface().get_editor_theme()

# Get the "Panels2Alt" icon from the editor theme
#var pin_icon = editor_theme.get_icon("Panels2Alt", "EditorIcons")



var pin_icon = EditorInterface.get_editor_theme().get_icon("PinPressed", "EditorIcons")
const FAVORITES_ICON = preload("res://addons/scene_snap/icons/favorites_icon.svg")
var hovered_node: TreeItem
#var add_icon: bool = true
#var enable_erase_icon: bool = false
var last_node_hovered: TreeItem

var button_info: Array = []
var current_buttons: Dictionary = {}


# FIXME OBJECTS WITH NO BODY OR COLLISION DO NOT PLACE UNDER PINNED NODE NOTE: FIXED
# FIXME WARNING OR SOMETHING NEEDED FOR ADDING UNDER SCALED OBJECTS
# FIXME BLUE PIN DISAPPEARS WHEN SCENE PREVIEW INSTANTIATED BUT STILL WORKS NOTE: FIXED
# FIXME OBJECTS STILL PLACED UNDER NODE WHEN PIN REMOVED SHOULD RESTORE TO PLACING UNDER ROOT NODE NOTE: FIXED
# FIXME SELECTING EYE ICON PRESSES PIN BUTTON!! THIS WILL NOT BE FUN TO FIX NOTE: FIXED

# If there are other buttons Eye, Script, Editor, ect. Store their information erase and add back in after pin at position 0
func add_pin_button(tree_item: TreeItem, colored: bool) -> void:
	current_buttons.clear()
	
	if tree_item.get_button_count(0) >= 1:

		# 1. Get current buttons info
		for button_index in range(tree_item.get_button_count(0) - 1, -1, -1):
			button_info.clear()

			var button_texture: Texture2D = tree_item.get_button(0, button_index)
			var button_id: int = tree_item.get_button_id(0, button_index)
			var button_state: bool = tree_item.is_button_disabled(0, button_index)
			var button_tooltip_text: String = tree_item.get_button_tooltip_text(0, button_index)

			button_info.append(button_texture)
			button_info.append(button_id)
			button_info.append(button_state)
			button_info.append(button_tooltip_text)

			current_buttons[button_index] = button_info.duplicate()

			# 2. Erase current buttons 
			tree_item.erase_button(0, button_index)

	# 3. Add pin button
	tree_item.add_button(0, pin_icon, 10, false, "Pin this node to place scenes as children of it.")

	if colored:
		# Tie pinned_node to scene_root to add back blue pin when scene tab changed
		#if debug: print("pinned_node: ", pinned_node)
		#if not scene_pinned_node.has(EditorInterface.get_edited_scene_root()):
		if pinned_node != null:
			scene_pinned_node[EditorInterface.get_edited_scene_root()] = pinned_node
		var button_index: int = tree_item.get_button_by_id(0, 10)
		#if debug: print("button_index: ", button_index)
		#tree_item.set_button_color(0, button_index, Color(0.14, 0.52, 0.86, 1.00)) # DARK BLUE COLOR
		#tree_item.set_button_color(0, button_index, Color(0.44, 0.73, 0.98, 1.00))
		tree_item.set_button_color(0, button_index, get_accent_color())
		tree_item.set_button_tooltip_text(0, button_index, "Remove pin to place scenes as children of the root node.")


		#var color: Color = Color(194, 67, 0, 255)
		#tree_item.set_custom_bg_color(0, color)

	# 4. Restore the buttons in the correct order
	var keys = current_buttons.keys()  # Get the list of keys
	keys.sort()  # Sort the keys to restore buttons in ascending order

	for key in keys:
		var button_data = current_buttons[key]
		tree_item.add_button(0, button_data[0], button_data[1], button_data[2], button_data[3])
		#hovered_node.add_button(0, button_data[0], button_data[1], button_data[2], button_data[3])


# Duplicate from main_base_tab.gd and scene_viewer.gd update_box_select_color() FIXME TODO CLEANUP
func get_accent_color() -> Color:
	var theme_accent_color: Color
	if settings.has_setting("interface/theme/accent_color"):
		theme_accent_color = settings.get_setting("interface/theme/accent_color")
	return theme_accent_color



##extends Camera3D
#
##@onready var space_state = editor_camera3d.get_world_3d().direct_space_state
#var create_occluder: bool = true
#var occluder_rid: RID
#
#func _process(delta):
	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		#var space_state = editor_camera3d.get_world_3d().direct_space_state
		## Get the mouse position on the screen
		##var mouse_position = get_viewport().get_mouse_position()
#
		## Convert screen coordinates to world coordinates
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
#
		## Perform a raycast using PhysicsDirectSpaceState
		##var ray: = PhysicsRayQueryParameters3D.new()
		#var ray = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)
#
		##var result = space_state.intersect_ray(ray_origin, ray_origin + ray_direction * 1000)
		#var result = space_state.intersect_ray(ray)
		#if debug: print(result)
#
		#if result:
			## Check if the hit object is a MeshInstance3D (mesh with no collision)
			#var hit_object = result.collider
			#if hit_object is MeshInstance3D:
				#if debug: print("Mesh hit: ", hit_object.name)
		#
		#if create_occluder:
			#create_occluder = false
			#occluder_rid = RenderingServer.occluder_create()
		#
			#RenderingServer.occluder_set_mesh(occluder_rid, vertices: PackedVector3Array, indices: PackedInt32Array)
#
	#else:
		#if occluder_rid:
			#RenderingServer.free_rid(occluder_rid)


# FIXME Works for single mesh but not when several stacked together
#func _process(delta): # ORIGINAL
	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
#
		## Convert screen coordinates to world coordinates (raycast origin and direction)
		##var ray_origin = editor_camera3d.project_position(mouse_pos, 20)
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
#
		#var ray_end = ray_origin + ray_direction * 1000
#
		#var scene_root_node: Node3D = EditorInterface.get_edited_scene_root()
		#var scenario_rid = scene_root_node.get_world_3d().get_scenario()
#
		#var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#for object_id in object_ids:
			#var mesh_instance = instance_from_id(object_id)
#
			### exclude object to be placed from mesh hit
			#if scene_preview != null:
				#if mesh_instance is MeshInstance3D and not scene_preview.get_child(0).get_instance_id() == object_id:
#
#
					#var tris: PackedVector3Array = []
				#
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
					#for i: int in range(0, tris.size(), 3):
						#var v0: Vector3 = tris[i + 0]
						#var v1: Vector3 = tris[i + 1]
						#var v2: Vector3 = tris[i + 2]
						#var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
						#if res is Vector3:
							#var len: float = from.distance_to(res)
							#if len < min_t:
								#min_t = len
								#min_p = res
								#var v0v1: Vector3 = v1 - v0
								#var v0v2: Vector3 = v2 - v0
								#min_n = v0v2.cross(v0v1)
#
					#if min_t >= FLOAT64_MAX:
						#mesh_hit = false
						#return
#
					#scene_preview_snap_to_normal(min_p, min_n)
					#
					#return







#@onready var world = get_world_3d()

# Define the beam width (thickness) along the X and Y axes (you can adjust this)
#var beam_width = 10
#var closest_mesh_instance: MeshInstance3D = null
#var shortest_distance: float = FLOAT64_MAX


#func _mesh_snapping(viewport_camera: Camera3D, event: InputEventMouseMotion) -> void:
	#var global_aabb: AABB
	## Mesh snapping
	#from = viewport_camera.project_ray_origin(event.position)
	#to = viewport_camera.project_ray_normal(event.position)



#func _process(delta):
	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
#
		##var ray_origin = editor_camera3d.project_position(mouse_pos, 20)
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
#
		#var ray_end = ray_origin + ray_direction * 1000
#
#
		#var scene_root_node: Node3D = EditorInterface.get_edited_scene_root()
		#var scenario_rid = scene_root_node.get_world_3d().get_scenario()
#
		#var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var tris: PackedVector3Array = []
#
		#for object_id in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if scene_preview != null:
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
#
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
			##var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
			#if res is Vector3:
				#var len: float = from.distance_to(res)
				##var len: float = ray_origin.distance_squared_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1)
#
		#if min_t >= FLOAT64_MAX:
			#mesh_hit = false
#
			#return
#
		#scene_preview_snap_to_normal(min_p, min_n)



#var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()


#var intersection
#var v0: Vector3
#var v1: Vector3
#var v2: Vector3

func calc_tris(delta, mesh_instance: MeshInstance3D, verts) -> void:
	var min_t: float = FLOAT64_MAX
	var min_p: Vector3 = Vector3.INF
	var min_n: Vector3
	
	for i in range(0, verts.size(), 3):
		var v0: Vector3 = mesh_instance.global_transform * (verts[i + 0])
		var v1: Vector3 = mesh_instance.global_transform * (verts[i + 1])
		var v2: Vector3 = mesh_instance.global_transform * (verts[i + 2])

		var intersection = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
		
		if intersection is Vector3:
			var len: float = ray_origin.distance_squared_to(intersection)
			
			if len < min_t:
				min_t = len
				min_p = intersection
				var v0v1: Vector3 = v1 - v0
				var v0v2: Vector3 = v2 - v0
				min_n = v0v2.cross(v0v1).normalized()

#var min_n: Vector3
var time_passed := 0.0

#func _process(delta): # BEST
	#if enable_placement and scene_preview_3d_active:
		#time_passed += delta
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var tris: PackedVector3Array = []
#
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
				#
				## To be effective need to remove all other results from object_ids
				#if not last_object_id == object_id:
					#last_object_id = object_id
#
					#verts = mesh_instance.mesh.get_faces()
				#
				##if debug: print("verts: ", verts)
				##if time_passed >= 0.01:
				#for i in range(0, verts.size(), 3):
					#var v0: Vector3 = mesh_instance.global_transform * (verts[i + 0])
					#var v1: Vector3 = mesh_instance.global_transform * (verts[i + 1])
					#var v2: Vector3 = mesh_instance.global_transform * (verts[i + 2])
#
					#var intersection = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#
					#if intersection is Vector3:
						#var len: float = ray_origin.distance_squared_to(intersection)
						#
						#if len < min_t:
							#min_t = len
							#min_p = intersection
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
					##time_passed = 0.0
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(delta, min_p, min_n)
		#else:
			#mesh_hit = false

### Filter out specific MeshInstance3D and CSGShape3D node and all its children MeshInstance3D and CSGShape3D nodes
#func filter_out_object_ids(node: Node3D) -> void:
	#if node:
		#if node is MeshInstance3D or node is CSGShape3D:
			#filtered_object_ids.erase(node.get_instance_id())
#
#
		#var mesh_node_instances: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
		#for mesh_node: MeshInstance3D in mesh_node_instances:
			#filtered_object_ids.erase(mesh_node.get_instance_id())
#
	#match typeof(node):
		#MeshInstance3D:
			#filtered_object_ids.erase(node.get_instance_id())



## Filter out specific MeshInstance3D and CSGShape3D node and all its children MeshInstance3D and CSGShape3D nodes
func filter_out_object_ids(node: Node3D) -> void:
	if node:
		filtered_object_ids.erase(node.get_instance_id())

		var mesh_node_instances: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
		for mesh_node: MeshInstance3D in mesh_node_instances:
			filtered_object_ids.erase(mesh_node.get_instance_id())

		var csg_node_instances: Array[Node] = node.find_children("*", "CSGShape3D", true, false)
		for mesh_node: CSGShape3D in csg_node_instances:
			filtered_object_ids.erase(mesh_node.get_instance_id())






var cast_distance: float = 0
var cast_step: float = 0.1
var locked_cast_distance: float


var object_tris: Dictionary
#var rust_script = MyEditorPlugin.new()

var filtered_object_ids: Array
var clear_object_id: int = 0
#var packed_array = PackedInt64Array(reduced_object_ids)
# Used to update object_tris if object is moved
var object_position: Dictionary


### RESTORE TO THIS
#func _process(delta):
	#filtered_object_ids.clear()
	#var ray_end: Vector3 = ray_origin + ray_direction * 10000
#
	#if scene_preview_3d_active or dragging_node:
		#if not scenario_rid:
			#scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()
#
		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#for object_id: int in object_ids:
			## Filter out duplicate ids
			#if not filtered_object_ids.has(object_id):
				#filtered_object_ids.append(object_id)
			## Filter out non MeshInstance3D ids Ex. Camera3D
			#if not instance_from_id(object_id) is MeshInstance3D:
				#filtered_object_ids.erase(object_id)
#
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
			#filter_out_object_ids(scene_preview)
#
		#var ray_idle: Vector3 = ray_origin + ray_direction * 10
#
		#if filtered_object_ids:
			#var result: PackedVector3Array = rust_script.process_objects(PackedInt64Array(filtered_object_ids), ray_origin, ray_direction)
			#if result:
				#scene_preview_snap_to_normal(result[0], result[1])
			#else:
				#scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)
		#else:
			#scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)


#func _process(delta):
	#filtered_object_ids.clear()
	#var ray_end: Vector3 = ray_origin + ray_direction * 10000
#
	#if scene_preview_3d_active or dragging_node:
		#if not scenario_rid:
			#scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()
#
		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#for object_id: int in object_ids:
			## Filter out duplicate ids
			#if not filtered_object_ids.has(object_id):
				#filtered_object_ids.append(object_id)
			## Filter out non MeshInstance3D ids Ex. Camera3D
			#if not instance_from_id(object_id) is MeshInstance3D:
				#filtered_object_ids.erase(object_id)
#
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
			#filter_out_object_ids(scene_preview)
#
		#var ray_idle: Vector3 = ray_origin + ray_direction * 10
#
		#if filtered_object_ids:
			#var result: PackedVector3Array = rust_script.process_objects(PackedInt64Array(filtered_object_ids), ray_origin, ray_direction)
			#if result:
				#scene_preview_snap_to_normal(result[0], result[1])
			#else:
				#scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)
		#else:
			#scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)

#var thread = Thread.new()
#var thread: Thread

# ORIGINAL
func ray_intersects_triangle(p_from: Vector3, p_dir: Vector3, p_v0: Vector3, p_v1: Vector3, p_v2: Vector3) -> Vector3:
	var e1 = p_v1 - p_v0
	var e2 = p_v2 - p_v0
	var h = p_dir.cross(e2)
	var a = e1.dot(h)
	
	if abs(a) < 0.00001:  # Parallel test (using a small epsilon instead of Math::is_zero_approx)
		#return false
		return Vector3.ZERO
	
	var f = 1.0 / a
	
	var s = p_from - p_v0
	var u = f * s.dot(h)
	
	if u < 0.0 or u > 1.0:
		#return false
		return Vector3.ZERO
	
	var q = s.cross(e1)
	var v = f * p_dir.dot(q)
	
	if v < 0.0 or u + v > 1.0:
		##return false
		return Vector3.ZERO
	
	# Compute t to find out where the intersection point is on the line
	var t = f * e2.dot(q)
	
	if t > 0.00001:  # Ray intersection test (using a small epsilon)
		#if r_res != null:
			#r_res = p_from + p_dir * t

		var r_res = p_from + p_dir * t
		##return true
		return r_res

	else:
		#return false
		return Vector3.ZERO
	##await get_tree().process_frame

 ##MOD
#func ray_intersects_triangle(p_from: Vector3, p_dir: Vector3, p_v0: Vector3, p_v1: Vector3, p_v2: Vector3) -> void:
	#var e1 = p_v1 - p_v0
	#var e2 = p_v2 - p_v0
	#var h = p_dir.cross(e2)
	#var a = e1.dot(h)
	#
	#if abs(a) < 0.00001:  # Parallel test (using a small epsilon instead of Math::is_zero_approx)
		##return false
		#return
	#
	#var f = 1.0 / a
	#
	#var s = p_from - p_v0
	#var u = f * s.dot(h)
	#
	#if u < 0.0 or u > 1.0:
		##return false
		#return
	#
	#var q = s.cross(e1)
	#var v = f * p_dir.dot(q)
	#
	#if v < 0.0 or u + v > 1.0:
		###return false
		#return
	#
	## Compute t to find out where the intersection point is on the line
	#var t = f * e2.dot(q)
	#
	#if t > 0.00001:  # Ray intersection test (using a small epsilon)
		##if r_res != null:
			##r_res = p_from + p_dir * t
#
		#res = p_from + p_dir * t



func _thread_function(ray_origin: Vector3, ray_direction: Vector3, v0: Vector3, v1: Vector3, v2: Vector3) -> Vector3:
	#mutex.lock()
	var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
	#mutex.unlock()
	return res

var res_last: Vector3
# When snapping closest_object will be what we want to check snap_flow_manager tags against.
var closest_object: Object = null

#var counter := 0
#var mutex: Mutex
#var thread = Thread.new()
#func _process_thread():
	#pass

# TEST MULTI THREADING
#var res: Variant


## TEST TULU 3 405B
## In your main script or a separate utility script.
#func process_ray_intersection(ray_origin: Vector3, ray_direction: Vector3, triangles: Array) -> Dictionary:
	#var closest_t: float = INF
	#var closest_point: Vector3 = Vector3.ZERO
	#for tri in triangles:
		#var res := Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, tri[0], tri[1], tri[2])
		#if res:
			#var t := ray_origin.distance_squared_to(res)
			#if t < closest_t:
				#closest_t = t
				#closest_point = res
	#return {"closest_t": closest_t, "closest_point": closest_point}
#
#
#func do_stuff():
	## Example usage. Replace with your actual logic.
	#var ray_origin = Vector3(0, 0, 0)
	#var ray_direction = Vector3(1, 0, 0)
	#var mesh_objects = []  # Fill this with your MeshInstance3D objects.
#
	#var all_triangles := []
	#for obj in mesh_objects:
		#var mesh_instance: MeshInstance3D = obj
		#var mesh: Mesh = mesh_instance.mesh
		#var triangles := mesh.get_faces()  # Assuming get_faces() returns triangles as Vector3 arrays
		#all_triangles.append_array(triangles)
#
	#var closest_t: float = INF
	#var closest_point: Vector3 = Vector3.ZERO
#
	#var group_id = WorkerThreadPool.add_group_task(
		#func(tri_index: int):
			#var start_index = tri_index * chunk_size
			#var end_index = min(start_index + chunk_size, all_triangles.size())
			#var chunk = all_triangles.slice(start_index, end_index)
			#return process_ray_intersection(ray_origin, ray_direction, chunk),
		#all_triangles.size() / chunk_size,  # Number of tasks
		#-1,  # Use all available threads
		#false,  # Low priority
		#"Ray Intersection Task"
	#)
#
	## Wait for all tasks to complete
	#WorkerThreadPool.wait_for_group_task_completion(group_id)
#
	## Collect results and find the closest intersection
	#for i in all_triangles.size() / chunk_size:
		#var result = WorkerThreadPool.get_group_task_result(group_id, i)
		#if result["closest_t"] < closest_t:
			#closest_t = result["closest_t"]
			#closest_point = result["closest_point"]
#
	#if debug: print("Closest Point: ", closest_point)

#var res: Variant = null
## TEST Multhread on tris
#func get_closest_point_ray_intersects_triangle(index: int, ray_origin: Vector3, ray_direction: Vector3, v0: Vector3, v1: Vector3, v2: Vector3) -> void:
	#res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
#
#
## ORIGINAL WORKING MOD
#func _process(delta):
	#if scene_preview_3d_active or dragging_node:
		#filtered_object_ids.clear()
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
		#var closest_object_id: int = -1
#
		#if not scenario_rid:
			#await get_tree().process_frame
#
		#for object_id: int in object_ids:
			## Filter out duplicate ids
			#if not filtered_object_ids.has(object_id):
				#filtered_object_ids.append(object_id)
#
			## Filter out non MeshInstance3D ids Ex. Camera3D
			#if not instance_from_id(object_id) is MeshInstance3D:
				#filtered_object_ids.erase(object_id)
#
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
			#filter_out_object_ids(scene_preview)
#
		#var idle: bool = false
#
		#if filtered_object_ids:
			#for object_id: int in filtered_object_ids:
				#if object_tris.keys().has(object_id):
#
					#res = null
					#var tris: PackedVector3Array = object_tris[object_id]
					#for i: int in range(0, tris.size(), 3):
						#var v0: Vector3 = tris[i + 0]
						#var v1: Vector3 = tris[i + 1]
						#var v2: Vector3 = tris[i + 2]
#
						#var bound_callable = Callable(get_closest_point_ray_intersects_triangle.bind(ray_origin, ray_direction, v0, v1, v2))
						##var task_id = WorkerThreadPool.add_group_task(bound_callable, 1)
						##WorkerThreadPool.wait_for_group_task_completion(task_id)
#
						#var task_id = WorkerThreadPool.add_task(bound_callable)
						#if WorkerThreadPool.wait_for_task_completion(task_id) == OK:
							### Other code that depends on task being processed.
							###if debug: print("thread finished success")
							##scene = get_scene_instance_from_loaded_data(file_bytes, scene_full_path)
#
#
#
						##var res: Vector3 = WorkerThreadPool.wait_for_task_completion(task_id)
						##var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
							#if res is Vector3:
#
								#var len: float = ray_origin.distance_squared_to(res)
#
								#if len < min_t:
									#min_t = len
									#min_p = res
									#var v0v1: Vector3 = v1 - v0
									#var v0v2: Vector3 = v2 - v0
									#min_n = v0v2.cross(v0v1).normalized()
									#closest_object_id = object_id
#
				#else:
					#var mesh_instance = instance_from_id(object_id)
					#if mesh_instance is MeshInstance3D:
						##if debug: print("mesh_instance: ", mesh_instance)
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#var tris: PackedVector3Array = []
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#tris.append(transformed_vert)
						#object_tris[object_id] = tris
#
			#if min_t < FLOAT64_MAX:
				#closest_object = instance_from_id(closest_object_id)
				##if debug: print("Snapping to object: ", instance_from_id(closest_object_id))
				##if debug: print("Snapping to object: ", closest_object)
				#closest_object_scale = closest_object.get_scale()
					#
				##if debug: print("closest_object scale: ", closest_object.get_scale())
				##if debug: print("object property list: ", closest_object.get_property_list())
				#if closest_object.has_meta("extras"):
					#var metadata: Dictionary = closest_object.get_meta("extras")
#
					#if debug: print("closest_object tags: ", metadata["tags"])
#
				##scene_preview_snap_to_normal(min_p, min_n)
#
				#process_snap_flow_manager_connections(min_p, min_n)
			#else:
				#idle = true
				#closest_object = null
#
		#if not filtered_object_ids or idle:
			#var ray_idle: Vector3 = ray_origin + ray_direction * 10
			##scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)
			#process_snap_flow_manager_connections(ray_idle, Vector3.ZERO)















##var results = [] # Each thread stores its result in this array.
#var objects: Array = []
#
#
## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#var min_t: float = FLOAT64_MAX
#var min_p: Vector3 = Vector3.ZERO
#var min_n: Vector3 = Vector3.ZERO
#var closest_object_id: int = -1
#
#
## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#func get_closest_point_ray_intersects_triangle(index: int, ray_origin: Vector3, ray_direction: Vector3) -> void:
	#min_t = FLOAT64_MAX
	#min_p = Vector3.ZERO
	#min_n = Vector3.ZERO
	#closest_object_id = -1
#
	#for object_id: int in objects:
		#var tris: PackedVector3Array = object_tris[object_id]
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			## NOTE Slower then calling Geometry3D.ray_intersects_triangle() but faster in Rust
			##var res: Vector3 = ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
#
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
					#closest_object_id = object_id
#
#
## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#func _process(delta):
	#if scene_preview_3d_active or dragging_node:
		#filtered_object_ids.clear()
#
		#if not scenario_rid:
			#await get_tree().process_frame
		#
		#for object_id: int in object_ids:
			## Filter out duplicate ids
			#if not filtered_object_ids.has(object_id):
				#filtered_object_ids.append(object_id)
#
			## Filter out non MeshInstance3D ids Ex. Camera3D
			#if not instance_from_id(object_id) is MeshInstance3D:
				#filtered_object_ids.erase(object_id)
#
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
			#filter_out_object_ids(scene_preview)
#
		#var idle: bool = false
		#objects = [] # Reset objects in array
#
		#if filtered_object_ids:
			#for object_id: int in filtered_object_ids:
				#if object_tris.keys().has(object_id):
					#objects.append(object_id)
#
				#else:
					#var mesh_instance = instance_from_id(object_id)
					#if mesh_instance is MeshInstance3D:
						##if debug: print("mesh_instance: ", mesh_instance)
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#var tris: PackedVector3Array = []
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#tris.append(transformed_vert)
						#object_tris[object_id] = tris
#
#
			#var bound_callable = Callable(get_closest_point_ray_intersects_triangle.bind(ray_origin, ray_direction))
			#var task_id = WorkerThreadPool.add_group_task(bound_callable, objects.size())
			#WorkerThreadPool.wait_for_group_task_completion(task_id)
#
			#if min_t < FLOAT64_MAX:
				#closest_object = instance_from_id(closest_object_id)
				##if debug: print("Snapping to object: ", closest_object)
				#closest_object_scale = closest_object.get_scale()
#
				##if debug: print("closest_object scale: ", closest_object.get_scale())
				#if closest_object.has_meta("extras"):
					#var metadata: Dictionary = closest_object.get_meta("extras")
#
					##if debug: print("closest_object tags: ", metadata["tags"])
#
				#process_snap_flow_manager_connections(min_p, min_n)
			#else:
				#idle = true
				#closest_object = null
#
		#if not filtered_object_ids or idle:
			#var ray_idle: Vector3 = ray_origin + ray_direction * 10
			#process_snap_flow_manager_connections(ray_idle, Vector3.ZERO)














## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#var min_t: float = FLOAT64_MAX
#var min_p: Vector3 = Vector3.ZERO
#var min_n: Vector3 = Vector3.ZERO
#var closest_object_id: int = -1
#
#
## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#func get_closest_point_ray_intersects_triangle(index:int, object_id: int, ray_origin: Vector3, ray_direction: Vector3) -> void:
	#min_t = FLOAT64_MAX
	#min_p = Vector3.ZERO
	#min_n = Vector3.ZERO
	#closest_object_id = -1
#
	#var tris: PackedVector3Array = object_tris[object_id]
	#for i: int in range(0, tris.size(), 3):
		#var v0: Vector3 = tris[i + 0]
		#var v1: Vector3 = tris[i + 1]
		#var v2: Vector3 = tris[i + 2]
#
		#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
		#if res is Vector3:
			#var len: float = ray_origin.distance_squared_to(res)
#
			#if len < min_t:
				#min_t = len
				#min_p = res
				#var v0v1: Vector3 = v1 - v0
				#var v0v2: Vector3 = v2 - v0
				#min_n = v0v2.cross(v0v1).normalized()
				#closest_object_id = object_id
#
#
## TEST MULTI THREADING WORKING BUT SAME SPEED AS NON THREAD 
#func _process(delta):
	#if scene_preview_3d_active or dragging_node:
		#filtered_object_ids.clear()
#
		#if not scenario_rid:
			#await get_tree().process_frame
		#
		#for object_id: int in object_ids:
			## Filter out duplicate ids
			#if not filtered_object_ids.has(object_id):
				#filtered_object_ids.append(object_id)
#
			## Filter out non MeshInstance3D ids Ex. Camera3D
			#if not instance_from_id(object_id) is MeshInstance3D:
				#filtered_object_ids.erase(object_id)
#
		#if dragging_node:
			#filter_out_object_ids(dragging_node)
		#else:
			#filter_out_object_ids(scene_preview)
#
		#var idle: bool = false
		#var objects: Array = []
#
		#if filtered_object_ids:
			#for object_id: int in filtered_object_ids:
				#if object_tris.keys().has(object_id):
					#objects.append(object_id)
#
				#else:
					#var mesh_instance = instance_from_id(object_id)
					#if mesh_instance is MeshInstance3D:
						##if debug: print("mesh_instance: ", mesh_instance)
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#var tris: PackedVector3Array = []
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#tris.append(transformed_vert)
						#object_tris[object_id] = tris
#
			#for object_id: int in objects:
				#var bound_callable = Callable(get_closest_point_ray_intersects_triangle.bind(object_id, ray_origin, ray_direction))
				#var task_id = WorkerThreadPool.add_group_task(bound_callable, objects.size())
				#WorkerThreadPool.wait_for_group_task_completion(task_id)
#
			#if min_t < FLOAT64_MAX:
				#closest_object = instance_from_id(closest_object_id)
				##if debug: print("Snapping to object: ", closest_object)
				#closest_object_scale = closest_object.get_scale()
#
				##if debug: print("closest_object scale: ", closest_object.get_scale())
				#if closest_object.has_meta("extras"):
					#var metadata: Dictionary = closest_object.get_meta("extras")
#
					##if debug: print("closest_object tags: ", metadata["tags"])
#
				#process_snap_flow_manager_connections(min_p, min_n)
			#else:
				#idle = true
				#closest_object = null
#
		#if not filtered_object_ids or idle:
			#var ray_idle: Vector3 = ray_origin + ray_direction * 10
			#process_snap_flow_manager_connections(ray_idle, Vector3.ZERO)




# ORIGINAL WORKING
func _process(delta):
	#while true:
		#if debug: print("hello")
		#if scene_preview_3d_active:
	#if is_instance_valid(dragging_node) and dragging_node.is_inside_tree():
		#if debug: print(dragging_node)
	if (is_instance_valid(scene_preview) and scene_preview.is_inside_tree()) \
	or (is_instance_valid(dragging_node) and dragging_node.is_inside_tree()):
	#if scene_preview_3d_active or dragging_node:
		filtered_object_ids.clear()
		var min_t: float = FLOAT64_MAX
		var min_p: Vector3 = Vector3.ZERO
		var min_n: Vector3 = Vector3.ZERO
		var closest_object_id: int = -1

		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		if not scenario_rid:
			await get_tree().process_frame
			#scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()

		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#if debug: print("total object size: ", object_tris.size())

		for object_id: int in object_ids:
			# Filter out duplicate ids
			if not filtered_object_ids.has(object_id):
				filtered_object_ids.append(object_id)


			# FIXME if subtract find way to only snap to inside of overlapping area?
			# Example Box with anoher subtract box inside and snapping to inside wall of "Room"
			# NOTE: Above will work easily with collision shape and raycast since collision shape is auto generated that has cutout
			# Exclude CSGShape3D that have operation subtract
			if instance_from_id(object_id) is CSGShape3D and instance_from_id(object_id).get_operation() == 2: #instance_from_id(object_id).OPERATION_SUBTRACTION:
				filtered_object_ids.erase(object_id)


			# Exclude all objects that are not either MeshInstance3D or CSGShape3D
			filtered_object_ids = filtered_object_ids.filter(func (object_id) -> bool: 
					return instance_from_id(object_id) is CSGShape3D or instance_from_id(object_id) is MeshInstance3D)



		# FIXME not excluding csg shape3d
		# Exclude the scene_preview or selected node to reposition
		if dragging_node:
			filter_out_object_ids(dragging_node)
		else:
			filter_out_object_ids(scene_preview)




		var idle: bool = false

		if filtered_object_ids:
			for object_id: int in filtered_object_ids:
				if object_tris.keys().has(object_id):

					var tris: PackedVector3Array = object_tris[object_id]
					for i: int in range(0, tris.size(), 3):
						var v0: Vector3 = tris[i + 0]
						var v1: Vector3 = tris[i + 1]
						var v2: Vector3 = tris[i + 2]

						#mutex = Mutex.new()
						#thread = Thread.new()
						#var res = thread.start(_thread_function.bind(ray_origin, ray_direction, v0, v1, v2))
						# NOTE: The speed bottleneck is here running ray_intersects_triangle in rust within same script is much faster
						var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
						if res is Vector3:

							#var res = ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
							#var res = thread.start(ray_intersects_triangle.bind(ray_origin, ray_direction, v0, v1, v2))

							#mutex.lock()
							#counter += 1
							#mutex.unlock()

							#thread.wait_to_finish()
							#if res != Vector3.ZERO:
							
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
				if debug: print("Snapping to object: ", closest_object)
				closest_object_scale = closest_object.get_scale()
					
				#if debug: print("closest_object scale: ", closest_object.get_scale())
				#if debug: print("object property list: ", closest_object.get_property_list())
				if closest_object.has_meta("extras"):
					var metadata: Dictionary = closest_object.get_meta("extras")

					#if debug: print("closest_object tags: ", metadata["tags"])

				#scene_preview_snap_to_normal(min_p, min_n)

				process_snap_flow_manager_connections(min_p, min_n)
			else:
				idle = true
				closest_object = null

		if not filtered_object_ids or idle:
			var ray_idle: Vector3 = ray_origin + ray_direction * 10
			#scene_preview_snap_to_normal(ray_idle, Vector3.ZERO)
			process_snap_flow_manager_connections(ray_idle, Vector3.ZERO)

	else:
		#scene_preview = null
		dragging_node = null


#
#
#
	###
		###thread.wait_to_finish()
		#### Yield the thread to prevent it from blocking the main thread
		##await get_tree().process_frame







	##scenario: RID = EditorInterface.get_edited_scene_root().get_world_3d().scenario
#######################################################################
	#var min_t: float = FLOAT64_MAX
	#var min_p: Vector3 = Vector3.ZERO
	#var min_n: Vector3 = Vector3.ZERO
	#var ray_end: Vector3 = ray_origin + ray_direction * 1000
	#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
	#for object_id: int in object_ids:
		#if object_tris.keys().has(object_id):
#
			#var tris: PackedVector3Array = object_tris[object_id]
			#for i: int in range(0, tris.size(), 3):
				#var v0: Vector3 = tris[i + 0]
				#var v1: Vector3 = tris[i + 1]
				#var v2: Vector3 = tris[i + 2]
	#
				#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				#if res is Vector3:
					#var len: float = ray_origin.distance_squared_to(res)
#
					#if len < min_t:
						#min_t = len
						#min_p = res
						#var v0v1: Vector3 = v1 - v0
						#var v0v2: Vector3 = v2 - v0
						#min_n = v0v2.cross(v0v1).normalized()
#
		#else:
			#var mesh_instance = instance_from_id(object_id)
			#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
			#var tris: PackedVector3Array = []
			#for vert in verts:
				#var transformed_vert = mesh_instance.global_transform * vert
				#tris.append(transformed_vert)
			#object_tris[object_id] = tris
#
	#if min_t < FLOAT64_MAX:
		#scene_preview_snap_to_normal(min_p, min_n)
###########################################################################
##MODDED
	#var min_t: float = FLOAT64_MAX
	#var min_p: Vector3 = Vector3.ZERO
	#var min_n: Vector3 = Vector3.ZERO
	#var ray_end: Vector3 = ray_origin + ray_direction * 1000
	#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
	#var all_tris: PackedVector3Array = []
	#for object_id: int in object_ids:
		#if object_tris.keys().has(object_id):
#
			#var tris: PackedVector3Array = object_tris[object_id]
			#all_tris.append_array(tris)
			##var result: PackedVector3Array = rust_script.process_tris(ray_origin, ray_direction, tris)
			##if result:
				##scene_preview_snap_to_normal(result[0], result[1])
			##for i: int in range(0, tris.size(), 3):
				##var v0: Vector3 = tris[i + 0]
				##var v1: Vector3 = tris[i + 1]
				##var v2: Vector3 = tris[i + 2]
	##
				##var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				##if res is Vector3:
					##var len: float = ray_origin.distance_squared_to(res)
##
					##if len < min_t:
						##min_t = len
						##min_p = res
						##var v0v1: Vector3 = v1 - v0
						##var v0v2: Vector3 = v2 - v0
						##min_n = v0v2.cross(v0v1).normalized()
#
		#else:
			#var mesh_instance = instance_from_id(object_id)
			#if mesh_instance is MeshInstance3D:
				#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
				#var tris: PackedVector3Array = []
				#for vert in verts:
					#var transformed_vert = mesh_instance.global_transform * vert
					#tris.append(transformed_vert)
				#object_tris[object_id] = tris
#
	#var result: PackedVector3Array = rust_script.process_tris(ray_origin, ray_direction, all_tris)
	#if result:
		#if debug: print(result[0])
		#scene_preview_snap_to_normal(result[0], result[1])
	##if min_t < FLOAT64_MAX:
		##scene_preview_snap_to_normal(min_p, min_n)









# FINAL WORKING
#var object_tris: Dictionary
#var rust_script = MyEditorPlugin.new()
#
#func _process(delta):
	##var min_t: float = FLOAT64_MAX
	##var min_p: Vector3 = Vector3.ZERO
	##var min_n: Vector3 = Vector3.ZERO
	#var ray_end: Vector3 = ray_origin + ray_direction * 1000
	#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
	#var all_tris: PackedVector3Array = []
	#for object_id: int in object_ids:
		#if object_tris.keys().has(object_id):
#
			#var tris: PackedVector3Array = object_tris[object_id]
			#all_tris.append_array(tris)
#
		#else:
			#var mesh_instance = instance_from_id(object_id)
			#if mesh_instance is MeshInstance3D:
				#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
				#var tris: PackedVector3Array = []
				#for vert in verts:
					#var transformed_vert = mesh_instance.global_transform * vert
					#tris.append(transformed_vert)
				#object_tris[object_id] = tris
#
	#var result: PackedVector3Array = rust_script.process_tris(ray_origin, ray_direction, all_tris)
	#if result:
		##if debug: print(result[0])
		#scene_preview_snap_to_normal(result[0], result[1])














##var object_tris: Dictionary
##var ray_origin: Vector3
##var ray_direction: Vector3
##var scenario_rid: RID
#
#var thread_pool: Array = []
#var results: Array = []
#
### This will be used to store the closest intersection
##var min_t: float = FLOAT64_MAX
##var min_p: Vector3 = Vector3.ZERO
##var min_n: Vector3 = Vector3.ZERO
#
#
#func _process(delta):
	#if scene_preview_3d_active:
		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		#var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#
		## This will be used to store the closest intersection
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
		#
		#
		## Split the work between threads
		#var chunk_size = object_ids.size() / thread_pool.size()
		#results.clear()  # Clear previous results
#
		#for i in range(thread_pool.size()):
			#var start_idx = i * chunk_size
			#var end_idx = (i + 1) * chunk_size if i < thread_pool.size() - 1 else object_ids.size()
			#var thread_data = {
				#"start_idx": start_idx,
				#"end_idx": end_idx,
				#"object_ids": object_ids.slice(start_idx, end_idx)
			#}
#
			## Start the thread with the data
			#thread_pool[i].start(_process_triangles.bind(thread_data))
#
		## Collect the results after the threads complete
		#for t in thread_pool:
			#t.wait_to_finish()  # Block until the thread finishes
#
		## After threads finish, find the minimum intersection
		#for result in results:
			#var len: float = ray_origin.distance_squared_to(result.position)
			#if len < min_t:
				#min_t = len
				#min_p = result.position
				#min_n = result.normal
#
		## Handle the result, e.g., snapping to the normal
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
#
## This function is run in each thread to process triangles
#func _process_triangles(thread_data: Dictionary) -> void:
	#var start_idx = thread_data["start_idx"]
	#var end_idx = thread_data["end_idx"]
	#var object_ids = thread_data["object_ids"]
#
	#var local_results = []
#
	#for object_id in object_ids:
		#if object_tris.has(object_id):
			#var tris: PackedVector3Array = object_tris[object_id]
			#for i in range(0, tris.size(), 3):
				#var v0 = tris[i + 0]
				#var v1 = tris[i + 1]
				#var v2 = tris[i + 2]
				#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				#
				#if res is Vector3:
					#var normal = (v1 - v0).cross(v2 - v0).normalized()
					#local_results.append({
						#"position": res,
						#"normal": normal
					#})
#
		#else:
			#var mesh_instance = instance_from_id(object_id)
			#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
			#var tris: PackedVector3Array = []
			#for vert in verts:
				#var transformed_vert = mesh_instance.global_transform * vert
				#tris.append(transformed_vert)
			#object_tris[object_id] = tris
#
	## Add local results to the shared result array (thread-safe operation)
	#lock_results(local_results)
#
## Function to safely add results from threads
#func lock_results(local_results: Array) -> void:
	#lock("results_lock", local_results)
#
## Using a mutex lock for thread-safe access to shared data
#var results_lock: Mutex = Mutex.new()
#
#func lock(name: String, data: Array) -> void:
	#results_lock.lock()
	#results.append_array(data)
	#results_lock.unlock()







# FIXME I don't know why this doesn't work
#var thread = Thread.new()
#var mutex = Mutex.new()
#func _process_thread():
	#while true:
		#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
#
		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#for object_id: int in object_ids:
			#mutex.lock()
#
			#if object_tris.keys().has(object_id):
#
				#var tris: PackedVector3Array = object_tris[object_id]
				#for i: int in range(0, tris.size(), 3):
					#var v0: Vector3 = tris[i + 0]
					#var v1: Vector3 = tris[i + 1]
					#var v2: Vector3 = tris[i + 2]
		#
					#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#if res is Vector3:
						#var len: float = ray_origin.distance_squared_to(res)
#
						#if len < min_t:
							#min_t = len
							#min_p = res
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
#
			#else: # add the tris to the dictionary
				#var mesh_instance = instance_from_id(object_id)
#
				##if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
				#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
				#var tris: PackedVector3Array = []
				#for vert in verts:
					#var transformed_vert = mesh_instance.global_transform * vert
					#tris.append(transformed_vert)
#
				#object_tris[object_id] = tris
#
			#mutex.unlock()
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
#
		#
		### Yield the thread to prevent it from blocking the main thread
		#await get_tree().process_frame




#var thread = Thread.new()
#var mutex = Mutex.new()
#
## Thread function
#func _process_thread():
	#while true:
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3 = Vector3.ZERO
		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		#var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#
		#for object_id in object_ids:
			#mutex.lock()  # Lock the mutex before accessing shared data
			#if object_tris.keys().has(object_id):
				#var tris: PackedVector3Array = object_tris[object_id]
				#for i in range(0, tris.size(), 3):
					#var v0: Vector3 = tris[i + 0]
					#var v1: Vector3 = tris[i + 1]
					#var v2: Vector3 = tris[i + 2]
					#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#if res is Vector3:
						#var len: float = ray_origin.distance_squared_to(res)
						#if len < min_t:
							#min_t = len
							#min_p = res
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
			#else:
				#var mesh_instance = instance_from_id(object_id)
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#var tris: PackedVector3Array = []
					#for vert in verts:
						#var transformed_vert = mesh_instance.global_transform * vert
						#tris.append(transformed_vert)
					#object_tris[object_id] = tris
			#mutex.unlock()  # Unlock the mutex after accessing shared data
#
		#if min_t < FLOAT64_MAX:
			## Update the scene in the main thread (safely)
			#await get_tree().process_frame
			#scene_preview_snap_to_normal(min_p, min_n)
		#
		## Yield the thread to allow the main thread to continue processing
		#await get_tree().create_timer(.001).timeout




























#func _process(delta): # BEST EDITED
	#if enable_placement and scene_preview_3d_active:
		#var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
		#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()
#
		#var mouse_pos = editor_viewport_3d.get_mouse_position()
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#var ray_end = ray_origin + ray_direction * 1000
#
		#var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var min_distance: float = FLOAT64_MAX
#
#
		#if not arrays_have_same_content(last_object_ids, object_ids):
			#last_object_ids = object_ids
#
			#for object_id: int in object_ids:
#
				#var mesh_instance = instance_from_id(object_id)
#
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
#
					#if not last_object_id == object_id:
						#last_object_id = object_id
#
						#var global_aabb: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
						#var res: Variant = global_aabb.intersects_ray(ray_origin, ray_direction)
						#if res is Vector3:
#
							#var distance = ray_origin.distance_squared_to(res)
#
							#if distance < min_distance:
								#min_distance = distance
								#closest_mesh = mesh_instance
#
#
#
		#if closest_mesh and last_closest_mesh != closest_mesh:
			#last_closest_mesh = closest_mesh
#
			#tris.clear()
			#var verts: PackedVector3Array = closest_mesh.mesh.get_faces()
			#for vert: Vector3 in verts:
				#tris.append(closest_mesh.global_transform * vert)
#
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
				#
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
#
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(delta, min_p, min_n)
		#else:
			#mesh_hit = false


#func _process(delta): # BEST EDITED
	#if enable_placement and scene_preview_3d_active:
		#time_passed += delta
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
#
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
#
			#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
#
				## To be effective need to remove all other results from object_ids
				#if not last_object_id == object_id:
					#last_object_id = object_id
#
#
					#tris.clear()
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
					#for i: int in range(0, tris.size(), 3):
						#var v0: Vector3 = tris[i + 0]
						#var v1: Vector3 = tris[i + 1]
						#var v2: Vector3 = tris[i + 2]
#
						#var intersection = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
						#if intersection is Vector3:
							#var len: float = ray_origin.distance_squared_to(intersection)
							#
							#if len < min_t:
								#min_t = len
								#min_p = intersection
								#var v0v1: Vector3 = v1 - v0
								#var v0v2: Vector3 = v2 - v0
								#min_n = v0v2.cross(v0v1).normalized()
#
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(delta, min_p, min_n)
		#else:
			#mesh_hit = false






#func _physics_process(delta: float) -> void:
	#if enable_placement and scene_preview_3d_active:
		#mouse_pos = editor_viewport_3d.get_mouse_position()
		#ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#ray_end = ray_origin + ray_direction * 10000
		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
	##if enable_placement and scene_preview_3d_active:
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var tris: PackedVector3Array = []
#
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
#
				#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
				#
				#for i in range(0, verts.size(), 3):
					#var v0: Vector3 = mesh_instance.global_transform * (verts[i + 0])
					#var v1: Vector3 = mesh_instance.global_transform * (verts[i + 1])
					#var v2: Vector3 = mesh_instance.global_transform * (verts[i + 2])
#
					#var intersection = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#
					#if intersection is Vector3:
						#var len: float = ray_origin.distance_squared_to(intersection)
						#
						#if len < min_t:
							#min_t = len
							#min_p = intersection
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
		#else:
			#mesh_hit = false
### Reference: (jgodfrey) https://forum.godotengine.org/t/how-do-i-check-2-arrays-to-see-if-both-size-and-content-match/8049/2 
#func arrays_have_same_content(array1, array2) -> bool:
	#if array1.size() != array2.size(): return false
	#for item in array1:
		#if !array2.has(item): return false
		#if array1.count(item) != array2.count(item): return false
	#return true
#
#
#var tris: PackedVector3Array = []
#var global_aabb: AABB
#var closest_mesh: Node = null
#var last_object_ids: PackedInt64Array
#var mouse_pos: Vector2
#var ray_origin: Vector3
#var ray_direction: Vector3
#var ray_end: Vector3
#
#
#var scene_root_node: Node3D
#var scenario_rid: RID
#
#var object_ids: PackedInt64Array
#
#var last_object_id: int
#var last_closest_mesh: Node
#var verts: PackedVector3Array

#var last_id: int



#func _physics_process6(delta: float) -> void: # WORKING BEST
	#if enable_placement and scene_preview_3d_active:
		#var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
		#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()
#
		#var mouse_pos = editor_viewport_3d.get_mouse_position()
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#var ray_end = ray_origin + ray_direction * 1000
#
		#var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		##if debug: print(object_ids)
#
		#var min_t: float = FLOAT64_MAX
#
		##var min_p: Vector3 = Vector3.INF
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
#
		#var min_distance: float = FLOAT64_MAX
#
#
		#if not arrays_have_same_content(last_object_ids, object_ids):
			#last_object_ids = object_ids
#
			#for object_id: int in object_ids:
#
				#var mesh_instance = instance_from_id(object_id)
#
#
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id and last_object_id == object_id:
					#last_object_id = object_id
					#closest_mesh = mesh_instance
#
#
					#var global_aabb: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
					#var res: Variant = global_aabb.intersects_ray(ray_origin, ray_direction)
					#if res is Vector3:
#
						#var distance = ray_origin.distance_squared_to(res)
#
						#if distance < min_distance:
							#min_distance = distance
							#closest_mesh = mesh_instance
#
#
			#if closest_mesh and last_closest_mesh != closest_mesh:
				#last_closest_mesh = closest_mesh
#
				#tris.clear()
				#var verts: PackedVector3Array = closest_mesh.mesh.get_faces()
				#for vert: Vector3 in verts:
					#tris.append(closest_mesh.global_transform * vert)
#
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
				#
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
#
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(delta, min_p, min_n)
		#else:
			#mesh_hit = false



#func _physics_process3(delta: float) -> void:
	#if enable_placement and scene_preview_3d_active:
		#var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
		#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()
#
		#var mouse_pos = editor_viewport_3d.get_mouse_position()
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#var ray_end = ray_origin + ray_direction * 1000
#
		#var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
		#var min_distance: float = FLOAT64_MAX
#
		#if not arrays_have_same_content(last_object_ids, object_ids):
			#last_object_ids = object_ids
#
			#for object_id: int in object_ids:
				#var mesh_instance = instance_from_id(object_id)
#
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
					#if last_object_id != object_id:
						#last_object_id = object_id
						#closest_mesh = mesh_instance
#
						#var global_aabb: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
						#var res: Variant = global_aabb.intersects_ray(ray_origin, ray_direction)
						#if res is Vector3:
							#var distance = ray_origin.distance_squared_to(res)
							#if distance < min_distance:
								#min_distance = distance
								#closest_mesh = mesh_instance
#
			#if closest_mesh and last_closest_mesh != closest_mesh:
				#last_closest_mesh = closest_mesh
#
				#tris.clear()
				#var verts: PackedVector3Array = closest_mesh.mesh.get_faces()
				#for vert: Vector3 in verts:
					#tris.append(closest_mesh.global_transform * vert)
#
		#for i in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(delta, min_p, min_n)
		#else:
			#mesh_hit = false




#func _physics_process4(delta: float) -> void:
	#if enable_placement and scene_preview_3d_active:
		#var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
		#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()
		#mouse_pos = editor_viewport_3d.get_mouse_position()
		#
		#ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
#
		##var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		##var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		##editor_camera3d.project_position(mouse_pos, 3)
#
#
#
		#ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#ray_end = ray_origin + ray_direction * 1000
		##var res: Variant = global_aabb.intersects_ray(ray_origin, ray_direction)
		#
		#
		##ray_end = editor_camera3d.project_position(mouse_pos, 1000)
		##EditorInterface.get_edited_scene_root().find_child("RayCast3D").set_target_position(ray_end)
#
		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#
		#
#
#
#
#
#
#
#
	## Mesh snapping
	##from = viewport_camera.project_ray_origin(event.position)
	##to = viewport_camera.project_ray_normal(event.position)
#
	##var min_t: float = FLOAT64_MAX
	##var min_p: Vector3 = Vector3.INF
	##var min_n: Vector3
#
	##var data_to_process: Array[Dictionary] = []
#
	## Check if aabb of visual instance intersects
	##for data: Dictionary in visual_instances_data:
		#
		##var global_aabb: AABB = data['aabb']
		##global_aabb = data['aabb']
		##var res: Variant = global_aabb.intersects_ray(from, to)
		##if debug: print(object_ids)
		#
#
#
	##if scene_preview_3d_active:
		##var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		##var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		##
		##var aabb_global: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
##
		##if aabb_global.intersects_segment(editor_camera3d.project_ray_origin(mouse_pos), (editor_camera3d.project_ray_origin(mouse_pos) + editor_camera3d.project_ray_normal(mouse_pos) * 1000)):
			##if debug: print("object hit")
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
#
#
#
	#
	#
	#
	##if scene_preview_3d_active:
		##var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		##var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		##
		##mouse_motion_event.position = mouse_pos
		##_mesh_snapping(editor_camera3d, mouse_motion_event)
#
	### Assuming you capture the input event here (maybe from _input())
		##if Input.is_mouse_button_pressed(BUTTON_LEFT):  # Example condition for mouse interaction
			##var mouse_motion_event = InputEventMouseMotion.new()
			##mouse_motion_event.position = Input.get_mouse_position()
##
			##_mesh_snapping(editor_camera3d, mouse_motion_event)
#
#
#
#
	##var main_container = scene_viewer_panel_instance.main_tab_container
	##if debug: print("main current tab: ", main_container.current_tab)
	##if debug: print("create_as_scene: ", create_as_scene)
	##for node in get_scene_tree_nodes(EditorInterface.get_edited_scene_root()):
		##if debug: print("node: ", node.get_meta("pinned_node"))
		##if debug: print("node: ", node._get_property_list())
		#
#
#
	##if pinned_tree_item:
		##if pinned_tree_item.has_meta("pinned_node"):
			##if debug: print("This is our node")
			##if debug: print(pinned_tree_item)
	##if pinned_tree_item:
		##if debug: print(pinned_node_name)
#
#
#
#
#
#
#
#
#
	##EditorInterface.edit_node(get_tree().get_edited_scene_root().find_child("Bush", true, false))
	##if debug: print("SHOW COLLISIONS: ", scene_preview_collisions)
	##if debug: print(Viewport)
	##if debug: print(EditorInterface.get_editor_viewport_3d(0).get_child(0).get_environment())
	##if debug: print(current_body_3d_type)
#
	## Force popup window to front on startup
	#if focus_popup_on_start and popup_window_instance != null:
		#if not popup_window_instance.has_focus():
			#popup_window_instance.grab_focus()
			#await get_tree().create_timer(.001).timeout
			#focus_popup_on_start = false
#
#
#
#
## MOVED TO _forward_3d_gui_input
	##if scene_preview_3d_active:
		##var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		##var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		##var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
		##var snap_position = editor_camera3d.project_position(mouse_pos, distance)
		##if snap_down:
			##if scene_preview_mesh != null:
				##scene_preview_mesh.global_transform.origin = snap_position
			##if scene_preview != null:
				##scene_preview.global_transform.origin = snap_position
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
	##if debug: print(!has_moved)
	##if debug: print("scene_viewer_panel_instance.scene_favorites: ", scene_viewer_panel_instance.scene_favorites)
#
	##if debug: print(get_editor_interface().get_resource_filesystem().is_scanning())
	##if debug: print("number: ", number)
	#
	##if instantiate_panel and scene_viewer_panel_instance.size.x != 0:
		##instantiate_panel = false
	##popup_window_instance.position = scene_viewer_panel_instance.global_position
	##popup_window_instance.size = scene_viewer_panel_instance.size
		##if scene_panel_floating:
			##_open_popup()
		##else:
			##add_control_to_bottom_panel_deferred()
	#
	#
	#
	##if debug: print("scene_panel_floating: ", scene_panel_floating)
	##if debug: print("initialize_scene_preview: ", initialize_scene_preview)
	##if debug: print("scene_number: ", scene_number)
	##if debug: print("scene_viewer_panel_instance.scene_view_instances: ", scene_viewer_panel_instance.scene_view_instances)
	##if debug: print("current_visible_buttons: ", current_visible_buttons)
	##if debug: print("scene_viewer_panel_instance.current_scene_path: ", scene_viewer_panel_instance.current_scene_path)
	##if debug: print("scene_viewer_panel_instance position: ", scene_viewer_panel_instance.get_parent().position)
	##scene_viewer_panel_instance.rect_min_size = Vector2(scene_viewer_panel_instance.rect_min_size.x, size_y)
	##scene_viewer_panel_instance.custom_minimum_size.y = size_y
	##size_y += 1
	#
	### Connect signals from buttons when all instanced
	##
	##if connect_scene_view_button_signals and scene_viewer_panel_instance.scene_view_instances != []:
		##connect_scene_view_button_signals = false
		##await get_tree().create_timer(5).timeout
		###if debug: print("scene_viewer_panel_instance.scene_view_instances: ", scene_viewer_panel_instance.scene_view_instances.size())
		##for scene_view_button in scene_viewer_panel_instance.scene_view_instances:
			##scene_view_button.pass_up_scene_number.connect(update_selected_scene_number)
		#
	#
#
	##if scene_preview != null and not quick_scroll_enabled and scene_preview_mesh.is_visible_in_tree():
	#if scene_preview != null and not quick_scroll_enabled and scene_preview_mesh != null:
		##if scene_preview_mesh.is_visible_in_tree():
			## TODO check if this can not be made better
		#var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
		##var existing_preview = get_tree().get_edited_scene_root().find_child("ScenePreview", true, false)
		#if not selected_nodes.has(scene_preview_mesh):# and existing_preview:
			##if debug: print("changing to scenepreview")
			##EditorInterface.edit_node(existing_preview)
			#change_selection_to(scene_preview_mesh)
#
#
#
	##if process_ray:
##
		### Assuming `center_ray` is the node you want to move
		### and `move_amount` is the distance you want to move up along the local Y-axis
		###if center_ray != null:
		### 1. Get the current global position of the node
		##var current_global_position = center_ray.global_transform.origin
##
		### 2. Convert the current global position to local space relative to the node's parent
		##var local_position = center_ray.to_local(current_global_position)
##
		### 3. Move the position up along the local Y-axis
		##local_position.y += 0.001  # Move up by 0.001 units
##
		### 4. Convert the updated local position back to global space
		##var updated_global_position = center_ray.to_global(local_position)
##
		### 5. Apply the updated global position to the node
		##center_ray.global_transform.origin = updated_global_position
		##
		##center_ray.get_child(0).force_raycast_update()
		##
		##if center_ray.get_child(0).is_colliding():
			##pipe_center_snap_last_position = center_ray.global_transform.origin
			###if debug: print("center_ray position: ", center_ray.global_transform.origin)
		##else:
			##process_ray = false
			##initialize_center_ray = true
#
	#if editor_viewport_3d_active:
		#rotation_snapping()



func find_closest_node_to_point(array, point):
	var closest_node = null
	var closest_node_distance = 0.0
	for i in array:
		var current_node_distance = point.distance_to(i.global_position)
		if closest_node == null or current_node_distance < closest_node_distance:
			closest_node = i
			closest_node_distance = current_node_distance
	return closest_node




#TEST
var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()

#var mouse_pos: Vector2
#var ray_origin: Vector3
#var ray_direction: Vector3
#var ray_end: Vector3
#
#
#var scene_root_node: Node3D
#var scenario_rid: RID
#
#var object_ids: PackedInt64Array
#var tris: PackedVector3Array = []

#var objects: Array[Node]

#func _process7(delta):
	#if scene_preview_3d_active:
		##var min_t: float = FLOAT64_MAX
		##var min_p: Vector3 = Vector3.INF
		##var min_n: Vector3
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
		##var min_distance: float = FLOAT64_MAX
#
		#var min_distance: float = FLOAT64_MAX
#
#
		#if not arrays_have_same_content(last_object_ids, object_ids):
			#last_object_ids = object_ids
			#tris.clear()
			##objects.clear()
#
			#for object_id: int in object_ids:
				#var mesh_instance = instance_from_id(object_id)
				#
				##if debug: print(ray_origin - mesh_instance.global_position)
#
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:# and last_object_id == object_id:
					##last_object_id = object_id
					##objects.append(mesh_instance)
					##closest_mesh = mesh_instance
#
					#
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
#
			##var global_aabb: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
			##var res: Variant = global_aabb.intersects_ray(ray_origin, ray_direction)
			##if res is Vector3:
##
				##closest_mesh = find_closest_node_to_point(objects, res)
				##if debug: print("closest_mesh: ", closest_mesh)
#
						##var distance = ray_origin.distance_squared_to(res)
##
						##if distance < min_distance:
							##min_distance = distance
							##closest_mesh = mesh_instance
#
#
#
			##if closest_mesh and last_closest_mesh != closest_mesh:
				##last_closest_mesh = closest_mesh
				##if debug: print("clearing")
				##tris.clear()
				##var verts: PackedVector3Array = closest_mesh.mesh.get_faces()
				##for vert: Vector3 in verts:
					##tris.append(closest_mesh.global_transform * vert)
		##if debug: print(tris.size())
		#if tris.size() > 0:
			#for i: int in range(0, tris.size(), 3):
				#var v0: Vector3 = tris[i + 0]
				#var v1: Vector3 = tris[i + 1]
				#var v2: Vector3 = tris[i + 2]
#
				#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				#if res is Vector3:
					#var len: float = ray_origin.distance_squared_to(res)
					#
					#if len < min_t:
						#min_t = len
						#min_p = res
						#var v0v1: Vector3 = v1 - v0
						#var v0v2: Vector3 = v2 - v0
						#min_n = v0v2.cross(v0v1).normalized()
#
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
		#else:
			#mesh_hit = false


func _physics_process10(delta: float) -> void:
	if scene_preview_3d_active:
		mouse_pos = editor_viewport_3d.get_mouse_position()
		ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		ray_end = ray_origin + ray_direction * 10000
		object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#if debug: print(object_ids)
#TEST





#var last_object_id: int
#var last_closest_mesh: Node
#var verts: PackedVector3Array
#var global_aabb: AABB
#var closest_mesh: Node = null




var tris: PackedVector3Array = []
var last_object_ids: PackedInt64Array
var mouse_pos: Vector2
var ray_origin: Vector3
var ray_direction: Vector3
var ray_end: Vector3
#var scene_root_node: Node3D
var scenario_rid: RID
var object_ids: PackedInt64Array




### Reference: (jgodfrey) https://forum.godotengine.org/t/how-do-i-check-2-arrays-to-see-if-both-size-and-content-match/8049/2 
#func arrays_have_same_content(array1, array2) -> bool:
	#if array1.size() != array2.size(): return false
	#for item in array1:
		#if !array2.has(item): return false
		#if array1.count(item) != array2.count(item): return false
	#return true




#func _process(delta): # Best non thread
	#if scene_preview_3d_active:
		##var ray_end: Vector3 = ray_origin + ray_direction * 1000
		##object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
			####if scene_preview != null:
				####if debug: print("not null")
		##var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
		##for mesh_node: MeshInstance3D in mesh_node_instances:
			##var mesh_node_id: int = mesh_node.get_instance_id()
###
			##if object_ids.has(mesh_node_id):
				##var scene_preview_idex: int = object_ids.find(mesh_node_id, 0)
				####if debug: print("removing scene index")
				##object_ids.remove_at(scene_preview_idex)
#
		#
		#
		#
		##if debug: print("scene_preview_id: ", scene_preview_id)
		##if debug: print("object_ids: ", object_ids)
		##if object_ids.has(scene_preview_id):
			##var scene_preview_idex: int = object_ids.find(scene_preview_id, 0)
			##if debug: print("removing scene index")
			##object_ids.remove_at(scene_preview_idex)
#
		#if object_ids.size() >= 3:
			#for i: int in object_ids.size() - 3:
			###if debug: print("removing entry")
				#object_ids.remove_at(object_ids.size() - 1)
		#if debug: print(object_ids.size())
		#if object_ids.size() > 0:
			#for object_id in object_ids:
				#if not last_object_ids.has(object_id):
					#var mesh_instance = instance_from_id(object_id)
#
					#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#tris.append(transformed_vert)
							## Connect mesh with tris would need dictionary{mesh: [array]}
#
		#last_object_ids = object_ids
		##if debug: print(tris.size())
		#if tris.size() > 0:
			#var min_t: float = FLOAT64_MAX
			#var min_p: Vector3 = Vector3.ZERO
			#var min_n: Vector3 = Vector3.ZERO
#
			## get back mesh with tris get back closest tris and then get it's mesh and then only process that meshs tris next frame?
			#for i: int in range(0, tris.size(), 3):
				#var v0: Vector3 = tris[i + 0]
				#var v1: Vector3 = tris[i + 1]
				#var v2: Vector3 = tris[i + 2]
#
				#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				#if res is Vector3:
					#var len: float = ray_origin.distance_squared_to(res)
					#
					#if len < min_t:
						#min_t = len
						#min_p = res
						#var v0v1: Vector3 = v1 - v0
						#var v0v2: Vector3 = v2 - v0
						#min_n = v0v2.cross(v0v1).normalized()
#
#
			#if min_t < FLOAT64_MAX:
				#scene_preview_snap_to_normal(min_p, min_n)
			#else:
				#mesh_hit = false
		### Yield the thread to prevent it from blocking the main thread
		##await get_tree().process_frame


#var object_tris_cache: Array = []
#
#var thread = Thread.new()
#
#func _process_thread():
	#while true:
		#if scene_preview_3d_active:
			## Preprocess / setup
			##var viewport: SubViewport = viewport_camera.get_viewport()
			##var scenario: RID = EditorInterface.get_edited_scene_root().get_world_3d().scenario
			##var event_position_scale: Vector2 = Vector2.ONE / viewport.get_screen_transform().get_scale()
			##var screen_position: Vector2 = event.position * event_position_scale
#
			## Camera and result variable setup
			##var from: Vector3 = viewport_camera.project_ray_origin(screen_position)
			##var to: Vector3 = viewport_camera.project_ray_normal(screen_position)
#
			#var min_t: float = FLOAT64_MAX
			#var min_p: Vector3 = Vector3.INF
			#var min_n: Vector3
			##object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
			## Get intersecting meshes, convert them from IDs to nodes
			##var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(from, to * common.SCENARIO_RAY_DISTANCE, scenario)
			#var intersected_nodes: Array = Array(object_ids).map(func (id: int) -> Object: return instance_from_id(id))
#
#
#
#
#
			## Loop through the intersecting meshes, add them to a global variable (object_tris_cache) if they're not in it already
			#for node: Object in intersected_nodes:
				## Exclude the node if it's a child of the selected object
				#if selected_nodes.has(node): continue
				#
				## Do not process the mesh instance again if it has already been processed
				#var node_data: Array[Dictionary] = object_tris_cache.filter(func (data: Dictionary) -> bool: return data.node == node)
				#if !node_data.is_empty(): continue
#
				## Otherwise, create the cache
				## Returned format: { node, aabb, global tris }
#
				#if node is MeshInstance3D and scene_preview.get_child(0) != node:
					#var verts: PackedVector3Array = node.mesh.get_faces()
					#for vert in verts:
						#var transformed_vert = node.global_transform * vert
						#object_tris_cache.append(transformed_vert)
						## Connect mesh with tris would need dictionary{mesh: [array]}
#
#
				##if node is MeshInstance3D: object_tris_cache.append(get_mesh_instance_data(node))
				##elif node is CSGShape3D: object_tris_cache.append(get_csg_data(node))
#
			## Get the intersecting meshes cache
			#var intersected_nodes_data = object_tris_cache.filter(func (data: Dictionary) -> bool: return intersected_nodes.has(data.node))
#
			## Find the closest point
			#for data: Dictionary in intersected_nodes_data:
				#var time1: float = Time.get_ticks_usec()
				#var tris: PackedVector3Array = data['tris']
				#for i: int in range(0, tris.size(), 3):
					#var v0: Vector3 = tris[i + 0]
					#var v1: Vector3 = tris[i + 1]
					#var v2: Vector3 = tris[i + 2]
					#var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
					#if res is Vector3:
						#var len: float = from.distance_squared_to(res)
						#if len < min_t:
							#min_t = len
							#min_p = res
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1)
				#if debug: print("Time elapsed: ", Time.get_ticks_usec() - time1)
#
		## Yield the thread to prevent it from blocking the main thread
		#await get_tree().process_frame










#var thread = Thread.new()
#
#func _process_thread():
	#while true:
		#if scene_preview_3d_active:
			#if debug: print("object_ids.size(): ",object_ids.size())
			#
			#
			##var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
			##for mesh_node: MeshInstance3D in mesh_node_instances:
				##var mesh_node_id: int = mesh_node.get_instance_id()
	###
				##if object_ids.has(mesh_node_id):
					##var scene_preview_idex: int = object_ids.find(mesh_node_id, 0)
					##if debug: print("removing scene index")
					##object_ids.remove_at(scene_preview_idex)
			#
			#
			#
			##if object_ids.size() >= 8:
				##object_ids.clear()
			#if object_ids.size() >= 2:
				#for i: int in object_ids.size() - 2:
				###if debug: print("removing entry")
					#object_ids.remove_at(object_ids.size() - 1)
			#if debug: print(object_ids.size())
			#if object_ids.size() > 0:
				#for object_id in object_ids:
					#if not last_object_ids.has(object_id):
						#var mesh_instance = instance_from_id(object_id)
#
						#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
							#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
							#for vert in verts:
								#var transformed_vert = mesh_instance.global_transform * vert
								#tris.append(transformed_vert)
								## Connect mesh with tris would need dictionary{mesh: [array]}
#
			#last_object_ids = object_ids
			#if debug: print("tris.size(): ",tris.size())
			#if tris.size() > 0 and tris.size() < 2000000:
				#var time1: float = Time.get_ticks_usec()
				#var min_t: float = FLOAT64_MAX
				##var min_p: Vector3 = Vector3.ZERO
				#var min_p: Vector3 = Vector3.INF
				#var min_n: Vector3 = Vector3.ZERO
#
				## get back mesh with tris get back closest tris and then get it's mesh and then only process that meshs tris next frame?
				#for i: int in range(0, tris.size(), 3):
					#var v0: Vector3 = tris[i + 0]
					#var v1: Vector3 = tris[i + 1]
					#var v2: Vector3 = tris[i + 2]
#
					#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#if res is Vector3:
						#var len: float = ray_origin.distance_squared_to(res)
						#
						#if len < min_t:
							#min_t = len
							#min_p = res
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
				#if debug: print("Time elapsed: ", Time.get_ticks_usec() - time1)
#
				#if min_t < FLOAT64_MAX:
					#scene_preview_snap_to_normal(min_p, min_n)
				#else:
					#mesh_hit = false
#
			#else:
				#tris.clear()
#
		## Yield the thread to prevent it from blocking the main thread
		#await get_tree().process_frame





























#var thread = Thread.new()

#func _process_thread(): # BEST THREAD
	#while true:
		#if scene_preview_3d_active:
			#var ray_end: Vector3 = ray_origin + ray_direction * 1000
			#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
			##if scene_preview != null:
				##if debug: print("not null")
			#var scene_preview_id: int = scene_preview.get_child(0).get_instance_id()
			#
			#if debug: print("scene_preview_id: ", scene_preview_id)
			#if debug: print("object_ids: ", object_ids)
			#if object_ids.has(scene_preview_id):
				#var scene_preview_idex: int = object_ids.find(scene_preview_id, 0)
				#if debug: print("removing scene index")
				#object_ids.remove_at(scene_preview_idex)
#
#
			##if object_ids.size() >= 2:
				##if debug: print("removing entry")
				##object_ids.remove_at(object_ids.size() - 1)
	#
			#for object_id in object_ids:
				#if not last_object_ids.has(object_id):
					#var mesh_instance = instance_from_id(object_id)
	#
					#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#tris.append(transformed_vert)
							## Connect mesh with tris would need dictionary{mesh: [array]}
	#
			#last_object_ids = object_ids
			#if tris.size() > 0:
				#var min_t: float = FLOAT64_MAX
				#var min_p: Vector3 = Vector3.ZERO
				#var min_n: Vector3 = Vector3.ZERO
	#
				## get back mesh with tris get back closest tris and then get it's mesh and then only process that meshs tris next frame?
				#for i: int in range(0, tris.size(), 3):
					#var v0: Vector3 = tris[i + 0]
					#var v1: Vector3 = tris[i + 1]
					#var v2: Vector3 = tris[i + 2]
	#
					#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
					#if res is Vector3:
						#var len: float = ray_origin.distance_squared_to(res)
						#
						#if len < min_t:
							#min_t = len
							#min_p = res
							#var v0v1: Vector3 = v1 - v0
							#var v0v2: Vector3 = v2 - v0
							#min_n = v0v2.cross(v0v1).normalized()
	#
	#
				#if min_t < FLOAT64_MAX:
					#scene_preview_snap_to_normal(min_p, min_n)
#
		## Yield the thread to prevent it from blocking the main thread
		#await get_tree().process_frame




















#var thread = Thread.new()
## Mutex for thread safety
#var mutex = Mutex.new()
#
#
#
#func _process(delta): # WORKS
	## Main thread logic for handling results (for example, updating the scene)
	#if scene_preview_3d_active and tris.size() > 0:
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
#
		#for i in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
#
#func _process_thread():
	#while true:
		## Perform raycasting and mesh processing in the background thread
		#if scene_preview_3d_active:
			#var ray_end: Vector3 = ray_origin + ray_direction * 1000
			#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
			##if debug: print(object_ids)
			#for object_id in object_ids:
				#if not last_object_ids.has(object_id):
					#var mesh_instance = instance_from_id(object_id)
					#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
						#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
						#for vert in verts:
							#var transformed_vert = mesh_instance.global_transform * vert
							#mutex.lock()  # Lock the mutex before modifying shared data
							#tris.append(transformed_vert)
							#mutex.unlock()
#
			#last_object_ids = object_ids
#
		## Yield the thread to prevent it from blocking the main thread
		#await get_tree().process_frame





#
#
#
#func _process(delta): # WORKS
	## Main thread logic for handling results (for example, updating the scene)
	#if scene_preview_3d_active and tris.size() > 0:
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.ZERO
		#var min_n: Vector3 = Vector3.ZERO
#
		#for i in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
#
			#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
			#if res is Vector3:
				#var len: float = ray_origin.distance_squared_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)

















#var cast_distance: int = 0
#func _physics_process(delta: float) -> void:
	#if scene_preview_3d_active:
	#if scene_preview != null:
	#for id: int in filtered_object_ids:
		#if object_position.has(id):
			#if instance_from_id(id).get_parent_node_3d().get_global_position() != object_position[id]:
				##if debug: print("the obect was moved, clear from cache")
				#rust_script.update_object_tris(id)
				## Update table to objects new position
				#object_position[id] = instance_from_id(id).get_parent_node_3d().get_global_position()
		#else:
			#object_position[id] = instance_from_id(id).get_parent_node_3d().get_global_position()
#
	#mouse_pos = editor_viewport_3d.get_mouse_position()
	#ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
	#ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#var cast_distance: int = 10
		
		#cast_distance += 10
		#if cast_distance == 1000:
			#cast_distance = 0
		#if debug: print(cast_distance)
		#ray_end = ray_origin + ray_direction * 1000
		#var aabb: AABB = AABB(ray_end, Vector3(0.01, 0.01, 0.01))
		#object_ids = RenderingServer.instances_cull_aabb(aabb, scenario_rid)
		#if debug: print(object_ids)
		#if object_ids:
			#
			#return

		#object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)


#TEST








#func _process6(delta): # GOOD WORKING
	#if scene_preview_3d_active:
		##var mouse_pos: Vector2 = editor_viewport_3d.get_mouse_position()
##
		##var ray_origin: Vector3 = editor_camera3d.project_ray_origin(mouse_pos)
		##var ray_direction: Vector3 = editor_camera3d.project_ray_normal(mouse_pos)
##
		##var ray_end: Vector3 = ray_origin + ray_direction * 1000
##
		##var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var tris: PackedVector3Array = []
#
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if scene_preview != null:
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
					#for i: int in range(0, tris.size(), 3):
						#var v0: Vector3 = tris[i + 0]
						#var v1: Vector3 = tris[i + 1]
						#var v2: Vector3 = tris[i + 2]
						#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
#
						#if res is Vector3:
							#var len: float = ray_origin.distance_squared_to(res)
							#if len < min_t:
								#min_t = len
								#min_p = res
								#var v0v1: Vector3 = v1 - v0
								#var v0v2: Vector3 = v2 - v0
								#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t >= FLOAT64_MAX:
			#mesh_hit = false
#
			#return
#
		#scene_preview_snap_to_normal(min_p, min_n)




#func _process8(delta): # GOOD WORKING
	#if scene_preview_3d_active:
		##var mouse_pos: Vector2 = editor_viewport_3d.get_mouse_position()
##
		##var ray_origin: Vector3 = editor_camera3d.project_ray_origin(mouse_pos)
		##var ray_direction: Vector3 = editor_camera3d.project_ray_normal(mouse_pos)
##
		##var ray_end: Vector3 = ray_origin + ray_direction * 1000
##
		##var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
		#var tris: PackedVector3Array = []
#
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if scene_preview != null:
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
					#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
					#for vert: Vector3 in verts:
						#tris.append(mesh_instance.global_transform * vert)
#
					#for i: int in range(0, tris.size(), 3):
						#var v0: Vector3 = tris[i + 0]
						#var v1: Vector3 = tris[i + 1]
						#var v2: Vector3 = tris[i + 2]
						#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
#
						#if res is Vector3:
							#var len: float = ray_origin.distance_squared_to(res)
							#if len < min_t:
								#min_t = len
								#min_p = res
								#var v0v1: Vector3 = v1 - v0
								#var v0v2: Vector3 = v2 - v0
								#min_n = v0v2.cross(v0v1).normalized()
#
		#if min_t >= FLOAT64_MAX:
			#mesh_hit = false
#
			#return
#
		#scene_preview_snap_to_normal(min_p, min_n)









#func _process3(delta): # GOOD WORKING
	#if scene_preview_3d_active:
		##var mouse_pos: Vector2 = editor_viewport_3d.get_mouse_position()
#
		##var ray_origin = editor_camera3d.project_position(mouse_pos, 20)
		##var ray_origin: Vector3 = editor_camera3d.project_ray_origin(mouse_pos)
		##var ray_direction: Vector3 = editor_camera3d.project_ray_normal(mouse_pos)
#
		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
#
		#var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		##object_ids.reverse()
#
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
#
#
		#var tris: PackedVector3Array = []
		#
		#var shortest_distance: float = FLOAT64_MAX
		#var shortest_distance_object: MeshInstance3D
#
		##if debug: print(object_ids.size())
		##for object_id: int in RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid):
		#for object_id: int in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#
			#if scene_preview != null:
				#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
#
					##if debug: print(ray_origin.distance_squared_to(mesh_instance.global_position))
					#var distance: float = ray_origin.distance_squared_to(mesh_instance.global_position)
					#if distance < shortest_distance:
						#shortest_distance = distance
						#shortest_distance_object = mesh_instance
#
		#if debug: print("shortest_distance_object.name: ",shortest_distance_object.name)
		#var verts: PackedVector3Array = shortest_distance_object.mesh.get_faces()
		#for vert: Vector3 in verts:
			#tris.append(shortest_distance_object.global_transform * vert)
##
		#for i: int in range(0, tris.size(), 3):
			#var v0: Vector3 = tris[i + 0]
			#var v1: Vector3 = tris[i + 1]
			#var v2: Vector3 = tris[i + 2]
			##var res: Variant = Geometry3D.ray_intersects_triangle(from, to, v2, v1, v0)
			#var res: Variant = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
			##var res: Variant = Geometry3D.segment_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
			#if res is Vector3:
				##var len: float = from.distance_to(res)
				#var len: float = ray_origin.distance_squared_to(res)
				#if len < min_t:
					#min_t = len
					#min_p = res
					#var v0v1: Vector3 = v1 - v0
					#var v0v2: Vector3 = v2 - v0
					#min_n = v0v2.cross(v0v1).normalized()
					###break
					##scene_preview_snap_to_normal(min_p, min_n)
					##return
					### Early exit: return as soon as the first hit is found
					##if min_t < FLOAT64_MAX:
						##scene_preview_snap_to_normal(min_p, min_n)
						##return
#
#
		#if min_t >= FLOAT64_MAX:
			#mesh_hit = false
#
#
			#return
#
		#scene_preview_snap_to_normal(min_p, min_n)










#func _process(delta):
	#if scene_preview_3d_active:
		#var mouse_pos: Vector2 = editor_viewport_3d.get_mouse_position()
#
		#var ray_origin: Vector3 = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction: Vector3 = editor_camera3d.project_ray_normal(mouse_pos)
#
		#var ray_end: Vector3 = ray_origin + ray_direction * 1000
		#var object_ids: PackedInt64Array = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		## Create a list of mesh instances with their distances from the ray origin
		#var mesh_distances: Array = []
		#for object_id in object_ids:
			#var mesh_instance = instance_from_id(object_id)
			#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
				#var dist = ray_origin.distance_to(mesh_instance.global_position)
				#mesh_distances.append({"mesh_instance": mesh_instance, "distance": dist})
		#
		## Sort meshes by distance (ascending)
		#mesh_distances.sort_custom(func(a, b):
			#return a["distance"] < b["distance"])
#
#
		## Now process the closest mesh first
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
		#var shortest_distance_object: MeshInstance3D
#
		#for mesh_data in mesh_distances:
			#var mesh_instance = mesh_data["mesh_instance"]
			## Get the faces (triangles) for the mesh
			#var verts: PackedVector3Array = mesh_instance.mesh.get_faces()
#
			#for i in range(0, verts.size(), 3):
				#var v0: Vector3 = mesh_instance.global_transform * (verts[i + 0])
				#var v1: Vector3 = mesh_instance.global_transform * (verts[i + 1])
				#var v2: Vector3 = mesh_instance.global_transform * (verts[i + 2])
				#
				## Check if ray intersects this triangle
				#var intersection = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v0, v1, v2)
				#
				#if intersection is Vector3:
					## Calculate the distance from the ray origin to the intersection point
					#var len: float = ray_origin.distance_squared_to(intersection)
					#
					#if len < min_t:
						#min_t = len
						#min_p = intersection
						## Calculate normal of the triangle
						#var v0v1: Vector3 = v1 - v0
						#var v0v2: Vector3 = v2 - v0
						#min_n = v0v2.cross(v0v1).normalized()
#
			## If we found a valid intersection in this mesh, stop processing further meshes
			#if min_t < FLOAT64_MAX:
				#break
#
		## If a valid intersection was found, snap the preview to it
		#if min_t < FLOAT64_MAX:
			#scene_preview_snap_to_normal(min_p, min_n)
		#else:
			#mesh_hit = false






#func _process(delta):
	#if scene_preview_3d_active:
		##var editor_viewport_3d = EditorInterface.get_editor_viewport_3d(0)
		#var editor_camera3d: Camera3D = editor_viewport_3d.get_camera_3d()
		#var mouse_pos = editor_viewport_3d.get_mouse_position()
#
		## Cache ray origin and direction
		#var ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
		#var ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
		#var ray_end = ray_origin + ray_direction * 1000
#
		#var scene_root_node: Node3D = EditorInterface.get_edited_scene_root()
		#var scenario_rid = scene_root_node.get_world_3d().get_scenario()
#
		## Only return relevant mesh instances based on culling
		#var object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
#
		#var min_t: float = FLOAT64_MAX
		#var min_p: Vector3 = Vector3.INF
		#var min_n: Vector3
		#var closest_hit: bool = false
#
		## Avoid creating a new array each frame
		#var tris: Array = []
#
		#for object_id in object_ids:
			#var mesh_instance = instance_from_id(object_id)
#
			## Check if the object is a MeshInstance3D and if it's the correct mesh
			#if mesh_instance is MeshInstance3D and scene_preview.get_child(0).get_instance_id() != object_id:
				#var mesh = mesh_instance.mesh
				#if mesh and mesh_instance.is_visible():  # Ensure mesh is valid and visible
#
					## If vertices are cached, use them
					#var verts: PackedVector3Array
					#if cached_mesh_vertices.has(object_id):
						#verts = cached_mesh_vertices[object_id]
					#else:
						#verts = mesh.get_faces()
						#cached_mesh_vertices[object_id] = verts  # Cache the vertices
#
					## Iterate through the triangles and check for intersection
					#for i in range(0, verts.size(), 3):
						#var v0: Vector3 = mesh_instance.global_transform * verts[i]
						#var v1: Vector3 = mesh_instance.global_transform * verts[i + 1]
						#var v2: Vector3 = mesh_instance.global_transform * verts[i + 2]
						#
						#var res = Geometry3D.ray_intersects_triangle(ray_origin, ray_direction, v2, v1, v0)
						#if res is Vector3:
							#var dist = ray_origin.distance_to(res)
							#if dist < min_t:
								#min_t = dist
								#min_p = res
								#min_n = (v2 - v0).cross(v1 - v0).normalized()  # Normal calculation
								#closest_hit = true
#
		#if closest_hit:
			#scene_preview_snap_to_normal(min_p, min_n)
		#else:
			#mesh_hit = false


var print_all: bool = true


var run_test_flag: bool = true

# TODO Reset to new script and reload only when selected button changes
# FIXME above good for one time offets but not for constantly updating position HOW TO FIX??? OFFSET FLAG??
# STILL UPDATE EVERY FRAME FROM OFFSET BUT JUST DO CHECK IF POSITION == ORINGIAL POSITION = OFFSET
# OR PASS IN FLAG "RUN ONCE" TO TRANSFORM METHOD?
# TODO I want to have the offset scrollable so this would need to run each tick of the scroll wheel Pass in scroll wheel tick?
var script_instance # Reload the script only when new scene button
var process_user_code: bool = true
func evaluate_user_code(code: String, scene_preview: Node, vector_normal: Vector3) -> void:
	#if run_test_flag:
		#run_test_flag = false
	# Create a new GDScript resource
	
	if scene_preview != last_scene_preview:
		last_scene_preview = scene_preview
		
		# Reset back to process every frame
		process_user_code = true
		
		var script = GDScript.new()

		# Set the source code of the script
		script.source_code = code

		# Reload the script to compile it
		script.reload()

		# Create an instance of the script
		script_instance = script.new()

	if process_user_code:
		var process = true
		if script_instance.has_method("transform"):
			# If transform() returns false will set process_user_code to false and stop process
			process_user_code = script_instance.transform(scene_preview, vector_normal, process)

	#return mesh_transform
	#return

## TODO I want to have the offset scrollable so this would need to run each tick of the scroll wheel
#func evaluate_user_code_once(code: String, scene_preview: Node, vector_normal: Vector3) -> Variant:
	##if run_test_flag:
		##run_test_flag = false
	## Create a new GDScript resource
	#if scene_preview != last_scene_preview:
		#last_scene_preview = scene_preview
#
		#var script = GDScript.new()
#
		## Set the source code of the script
		#script.source_code = code
#
		## Reload the script to compile it
		#script.reload()
#
		## Create an instance of the script
		#var script_instance = script.new()
#
		#var result = null
		## Optionally, call the parse_tags method if defined
		#if script_instance.has_method("transform"):
			#result = script_instance.transform(scene_preview, vector_normal)
#
		#return result
	#return




#var mouse_motion_event = InputEventMouseMotion.new()

# FIXME Optimize for when not in use not running  
func _physics_process(delta: float) -> void:
	#print("current_visible_buttons: ", current_visible_buttons.size())
	#if debug: print("scene_viewer_panel_instance size: ", scene_viewer_panel_instance.size)
	#if debug: print(current_main_tab)
	#var main_container: TabContainer = scene_viewer_panel_instance.main_tab_container
	#var main_tab: Control = main_container.get_current_tab_control()
	#if debug: print(main_tab)
	#current_sub_tab = main_tab.sub_tab_container.get_child(main_tab.sub_tab_container.get_current_tab())
	#if debug: print(current_sub_tab)
	#update_selected_buttons_for_tab(1, main_tab)
	#selected_main_tab_changed(1)
	#if debug: print("scene_preview: ", scene_preview)
	#if debug: print("scene_preview_3d_active: ", scene_preview_3d_active)
	#if debug: print("scene_viewer_panel_instance.scene_favorites: ", scene_viewer_panel_instance.scene_favorites)
	#if dragging_node != null and dragging_node.is_inside_tree() == false:
		#dragging_node = null
		#duplicate_dragging_node = false
	#if scene_preview != null and scene_preview.is_inside_tree() == false:
		#scene_preview.queue_free()
		#scene_preview = null
	#if debug: print("dragging_node name: ", dragging_node.name)
	## Match scale of object being attached to
	#if scene_preview and scene_preview.is_inside_tree() and match_scale:
		##if debug: print("MATCHING TAGERGET SCALE")
		#scene_preview.scale = closest_object_scale

	#if debug: print("match_scale: ", match_scale)
	##if debug: print("current_visible_buttons: ", current_visible_buttons)
	#if current_visible_buttons:
		##var selected: Button = null
		#for button: Button in current_visible_buttons:
			#if button.has_focus():
				#if debug: print("button: ", button)
				#if debug: print("button index: ", button.get_index())
	#if debug: print("selected_scene_view_button: ", selected_scene_view_button)
	#evaluate_user_code(snap_flow_manager_graph.code_edit.text)
	#if debug: print("snap_flow_manager_graph.code_edit: ", snap_flow_manager_graph.code_edit.text)
	#if debug: print("snap_flow_manager_graph.selected_scene_view_button tags: ", snap_flow_manager_graph.selected_scene_view_button.tags)
	#if debug: print("selected_scene_view_button: ", selected_scene_view_button)
	#process_snap_flow_manager_connections(scene_preview)
	#if debug: print("snap_flow_manager_graph.get_connection_list(): ", snap_flow_manager_graph.get_connection_list())
	#if SNAP_MANAGER_DATA:
	#if debug: print("store connections: ", ResourceLoader.load("res://addons/scene_snap/resource/snap_manager_data.tres","", ResourceLoader.CACHE_MODE_IGNORE).connections)
	#if debug: print("snap_flow_manager_graph connections: ", snap_connections)
	
	#if snap_flow_manager_graph:
	#if debug: print("snap_flow_manager_graph connections: ", snap_flow_manager_graph.connections)
	#else:
		#if debug: print("snap_flow_manager_graph connections: ", snap_manager_graph_connections)
	
	#if debug: print("snap_flow_manager_graph connections: ", snap_flow_manager_graph.connections)
	#if debug: print("object: ", snap_manager_graph_instance.object.name)
	#if debug: print("object_values: ", snap_manager_graph_instance.object_values)
	if scene_preview_3d_active or dragging_node:
		if not scenario_rid:
			scenario_rid = EditorInterface.get_edited_scene_root().get_world_3d().get_scenario()

		var ray_end: Vector3 = ray_origin + ray_direction * 1000
		object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)
		#for object_id in object_ids:
			#if debug: print("object_ids: ", instance_from_id(object_id))



	#if scene_preview != null:
		#if debug: print("scene_preview: ", scene_preview)
		#if debug: print("scene_preview.is_inside_tree(): ", scene_preview.is_inside_tree())
	#if debug: print("base control children: ", EditorInterface.get_base_control().get_child_count())

	#var base_control = EditorInterface.get_base_control()
	#var output: Array[Node] = [] 
	#get_all_children(output, base_control)
	#if print_all:
		#if debug: print(output)
		#print_all = false
		#for node in output:
			#if node.name == "@TabBar@58":
				#print_all = false
				#if debug: print("node parent: ", node.get_parent())
				#if debug: print("node parent parent: ", node.get_parent().get_parent())
				#if debug: print("node parent parent parent: ", node.get_parent().get_parent().get_parent())
				#if debug: print("node parent parent parent parent: ", node.get_parent().get_parent().get_parent().get_parent())
				##node.tab_hovered.connect(func(tab: int): if debug: print("this tab was hovered: ", tab))
				#node.tab_hovered.connect(func(tab: int):
					#scene_preview_3d_active = false 
					#remove_existing_scene_preview())
				##node.connect("tab_hovered")
				#if debug: print("THIS IS THE TABBAR: ", node.name)
				#
			##if node.name == "TabBar":
			##if debug: print(node.name)
		#print_all = false

	##var editor_tabs = get_child_of_type(EditorInterface.get_base_control(), "EditorTitleBar", true)
	#var editor_tabs = get_child_of_type(EditorInterface.get_base_control(), "TabBar", true)
	##var editor_tabs = get_child_of_type(EditorInterface.get_base_control(), "EditorRunBar", true)
	##if debug: print("editor_tabs: ", editor_tabs.get_child_count())
	#if print_all:
		#for tab in editor_tabs.get_children():
			#if debug: print(tab.name)
		#print_all = false


		##if debug: print(tab.get_child_count())
		#for child in tab.get_children():
			#for c in child.get_children():
				#if debug: print(c.name)
	#for child in base_chidren:
		#if debug: print("child name: ", child.name)
	
	
	
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	for node: Node in selected_nodes:
		if node is Node3D or node is MeshInstance3D:
			pass
			#if debug: print("get position")

	# Keep track of objects positions so that when moved can update tris new position for mesh col calculation
	for id: int in filtered_object_ids:
		#if instance_from_id(id) and get_node(instance_from_id(id).get_path()).is_inside_tree() and get_node(instance_from_id(id).get_path()) != null:
		if instance_from_id(id) and get_node(instance_from_id(id).get_path()) != null:
		#if get_node(instance_from_id(id).get_path()) != null:
			if object_position.has(id):
				if get_node(instance_from_id(id).get_path()).get_global_position() != object_position[id]:
					#dragging_node = null
					#if debug: print("the obect was moved, clear from cache")
					object_tris.erase(id)
					if debug: print("rust_script.update_object_tris(id)")
					# Update table to objects new position
					object_position[id] = get_node(instance_from_id(id).get_path()).get_global_position()
			else:
				object_position[id] = get_node(instance_from_id(id).get_path()).get_global_position()

	mouse_pos = editor_viewport_3d.get_mouse_position()
	ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
	ray_direction = editor_camera3d.project_ray_normal(mouse_pos)


	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		#
		#var aabb_global: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
#
		#if aabb_global.intersects_segment(editor_camera3d.project_ray_origin(mouse_pos), (editor_camera3d.project_ray_origin(mouse_pos) + editor_camera3d.project_ray_normal(mouse_pos) * 1000)):
			#if debug: print("object hit")
	
	
	

	#mouse_pos = editor_viewport_3d.get_mouse_position()
#
	##var ray_origin = editor_camera3d.project_position(mouse_pos, 20)
	#ray_origin = editor_camera3d.project_ray_origin(mouse_pos)
	#ray_direction = editor_camera3d.project_ray_normal(mouse_pos)
#
	#ray_end = ray_origin + ray_direction * 1000




#	object_ids = RenderingServer.instances_cull_ray(ray_origin, ray_end, scenario_rid)














	
	
	
	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		#
		#mouse_motion_event.position = mouse_pos
		#_mesh_snapping(editor_camera3d, mouse_motion_event)

	## Assuming you capture the input event here (maybe from _input())
		#if Input.is_mouse_button_pressed(BUTTON_LEFT):  # Example condition for mouse interaction
			#var mouse_motion_event = InputEventMouseMotion.new()
			#mouse_motion_event.position = Input.get_mouse_position()
#
			#_mesh_snapping(editor_camera3d, mouse_motion_event)




	#var main_container = scene_viewer_panel_instance.main_tab_container
	#if debug: print("main current tab: ", main_container.current_tab)
	#if debug: print("create_as_scene: ", create_as_scene)
	#for node in get_scene_tree_nodes(EditorInterface.get_edited_scene_root()):
		#if debug: print("node: ", node.get_meta("pinned_node"))
		#if debug: print("node: ", node._get_property_list())
		


	#if pinned_tree_item:
		#if pinned_tree_item.has_meta("pinned_node"):
			#if debug: print("This is our node")
			#if debug: print(pinned_tree_item)
	#if pinned_tree_item:
		#if debug: print(pinned_node_name)

	## Restore pinned node when switching between tabs # FIXME move to change scene
	#if pinned_node:
		#if debug: print("pinned_node.name: ", pinned_node.name)

	#if debug: print("scene_pinned_node[EditorInterface.get_edited_scene_root()]: ", scene_pinned_node[EditorInterface.get_edited_scene_root()])


	# Restore pin icon when adding children to pinned node
	if pinned_tree_item:
		if pinned_tree_item.get_button_count(0) == 0 or pinned_tree_item.get_button(0, 0) != pin_icon:
			add_pin_button(pinned_tree_item, true)


	if mouse_over_scene_tree and node_pinning_enabled:
		var mouse_pos: Vector2 = scenedock_tree.get_local_mouse_position()
		hovered_node = scenedock_tree.get_item_at_position(mouse_pos)
		if last_node_hovered != scenedock_tree.get_item_at_position(mouse_pos):
			if last_node_hovered != null:# and not keep_current_pin:

				# Remove pin when no longer hovering over scene tree item
				if last_node_hovered != pinned_tree_item and last_node_hovered.get_button_by_id(0, 10) != -1:
					last_node_hovered.erase_button(0, last_node_hovered.get_button_by_id(0, 10))

			# Show pin when hovering over scene tree item
			last_node_hovered = hovered_node
			if hovered_node != null:
				# Exclude pinning ScenePreview
				var node_path = hovered_node.get_metadata(0)
				var hovered_node_name = EditorInterface.get_edited_scene_root().get_node(node_path).name

				if hovered_node != pinned_tree_item and hovered_node_name != "ScenePreview":
					add_pin_button(hovered_node, false)






	#EditorInterface.edit_node(get_tree().get_edited_scene_root().find_child("Bush", true, false))
	#if debug: print("SHOW COLLISIONS: ", scene_preview_collisions)
	#if debug: print(Viewport)
	#if debug: print(EditorInterface.get_editor_viewport_3d(0).get_child(0).get_environment())
	#if debug: print(current_body_3d_type)

	# Force popup window to front on startup
	if focus_popup_on_start and popup_window_instance != null:
		if not popup_window_instance.has_focus():
			popup_window_instance.grab_focus()
			await get_tree().create_timer(.001).timeout
			focus_popup_on_start = false




# MOVED TO _forward_3d_gui_input
	#if scene_preview_3d_active:
		#var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		#var distance = (0 - editor_camera3d.project_ray_origin(mouse_pos).y) / editor_camera3d.project_ray_normal(mouse_pos).y
		#var snap_position = editor_camera3d.project_position(mouse_pos, distance)
		#if snap_down:
			#if scene_preview_mesh != null:
				#scene_preview_mesh.global_transform.origin = snap_position
			#if scene_preview != null:
				#scene_preview.global_transform.origin = snap_position








			
			
			
			
	#if debug: print(!has_moved)
	#if debug: print("scene_viewer_panel_instance.scene_favorites: ", scene_viewer_panel_instance.scene_favorites)

	#if debug: print(get_editor_interface().get_resource_filesystem().is_scanning())
	#if debug: print("number: ", number)
	
	#if instantiate_panel and scene_viewer_panel_instance.size.x != 0:
		#instantiate_panel = false
	#popup_window_instance.position = scene_viewer_panel_instance.global_position
	#popup_window_instance.size = scene_viewer_panel_instance.size
		#if scene_panel_floating:
			#_open_popup()
		#else:
			#add_control_to_bottom_panel_deferred()
	
	
	
	#if debug: print("scene_panel_floating: ", scene_panel_floating)
	#if debug: print("initialize_scene_preview: ", initialize_scene_preview)
	#if debug: print("scene_number: ", scene_number)
	#if debug: print("scene_viewer_panel_instance.scene_view_instances: ", scene_viewer_panel_instance.scene_view_instances)
	#if debug: print("current_visible_buttons: ", current_visible_buttons)
	#if debug: print("scene_viewer_panel_instance.current_scene_path: ", scene_viewer_panel_instance.current_scene_path)
	#if debug: print("scene_viewer_panel_instance position: ", scene_viewer_panel_instance.get_parent().position)
	#scene_viewer_panel_instance.rect_min_size = Vector2(scene_viewer_panel_instance.rect_min_size.x, size_y)
	#scene_viewer_panel_instance.custom_minimum_size.y = size_y
	#size_y += 1
	
	## Connect signals from buttons when all instanced
	#
	#if connect_scene_view_button_signals and scene_viewer_panel_instance.scene_view_instances != []:
		#connect_scene_view_button_signals = false
		#await get_tree().create_timer(5).timeout
		##if debug: print("scene_viewer_panel_instance.scene_view_instances: ", scene_viewer_panel_instance.scene_view_instances.size())
		#for scene_view_button in scene_viewer_panel_instance.scene_view_instances:
			#scene_view_button.pass_up_scene_number.connect(update_selected_scene_number)
		
	
	## FIXME NOTE TEMP DISABLED
	#if scene_preview != null and not quick_scroll_enabled and scene_preview_mesh.is_visible_in_tree():
	# Keep scene_preview as the selected node in the scene tree
	if scene_preview != null and not quick_scroll_enabled and scene_preview_mesh != null:
		if scene_preview_mesh.is_visible_in_tree():
			# TODO check if this can not be made better
			#var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
			existing_preview = get_tree().get_edited_scene_root().find_child("ScenePreview", true, false)
			if existing_preview and scene_preview_3d_active:
				if not selected_nodes.has(scene_preview_mesh):
					#if debug: print("changing to scenepreview")
					#EditorInterface.edit_node(existing_preview)
					change_selection_to(scene_preview_mesh)

	## Keep dragging_node as the selected node in the scene tree
	elif dragging_node != null:
		if not selected_nodes.has(dragging_node):
			change_selection_to(dragging_node)



	if process_ray:

		# Assuming `center_ray` is the node you want to move
		# and `move_amount` is the distance you want to move up along the local Y-axis
		#if center_ray != null:
		# 1. Get the current global position of the node
		var current_global_position = center_ray.global_transform.origin

		# 2. Convert the current global position to local space relative to the node's parent
		var local_position = center_ray.to_local(current_global_position)

		# 3. Move the position up along the local Y-axis
		local_position.y += 0.001  # Move up by 0.001 units

		# 4. Convert the updated local position back to global space
		var updated_global_position = center_ray.to_global(local_position)

		# 5. Apply the updated global position to the node
		center_ray.global_transform.origin = updated_global_position
		
		center_ray.get_child(0).force_raycast_update()
		
		if center_ray.get_child(0).is_colliding():
			pipe_center_snap_last_position = center_ray.global_transform.origin
			#if debug: print("center_ray position: ", center_ray.global_transform.origin)
		else:
			process_ray = false
			initialize_center_ray = true

	if editor_viewport_3d_active:
		rotation_snapping()




func snap_scene_preview_to_collision_points(delta) -> void:
	if scene_preview_3d_active:
		var editor_camera3d: Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		var mouse_pos = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
		var space_state = editor_camera3d.get_world_3d().direct_space_state
		
		if not scene_preview_mesh == null:

			scene_preview_mesh.position = editor_camera3d.project_position(mouse_pos, 3)


# FIXME probably need to edit to match align_z_axis_with_normal below
func align_y_axis_with_normal(object: Node3D, normal: Vector3) -> void:
	if align_scene_axis:
		var up = Vector3.UP  # The default local Y-axis of the object
		
		# Compute the rotation needed to align the Y-axis with the normal
		var rotation_axis = up.cross(normal).normalized()
		var rotation_angle = acos(up.dot(normal))
		
		if rotation_angle != 0:
			var rotation = Quaternion(rotation_axis, rotation_angle)
			var basis = Basis(rotation)  # Convert the quaternion to a Basis
		
		# Apply the rotation to the object's Basis
			object.transform.basis = basis * object.transform.basis
		align_scene_axis = false



func align_z_axis_with_normal(object: Node3D, normal: Vector3) -> void:
	var forward = -Vector3.FORWARD  # Default Z-axis of the object
	var up = Vector3.UP  # Default Y-axis of the object

	# Normalize the normal vector
	var normalized_normal = normal.normalized()

	# Compute the rotation needed to align the Z-axis with the normal
	var rotation_axis = forward.cross(normalized_normal)
	var rotation_angle = acos(forward.dot(normalized_normal))

	# Check for cases where no rotation is needed
	if abs(rotation_angle) < 1e-6:
		# If the angle is close to zero, the vectors are aligned
		return

	# Handle the special case where rotation_axis is very close to zero
	if rotation_axis.length_squared() < 1e-6:
		# If the vectors are opposite, pick an arbitrary perpendicular axis
		if abs(forward.x) > abs(forward.y):
			rotation_axis = Vector3(0, 1, 0).cross(forward).normalized()
		else:
			rotation_axis = Vector3(1, 0, 0).cross(forward).normalized()
		rotation_angle = PI

	# Normalize the rotation_axis to ensure it is a valid axis
	rotation_axis = rotation_axis.normalized()

	# Compute the quaternion and new basis
	var rotation = Quaternion(rotation_axis, rotation_angle)
	var new_basis = Basis(rotation)
	
	# Set the new basis such that Z aligns with the normal
	var new_z_axis = normalized_normal
	var new_x_axis = up.cross(new_z_axis).normalized()
	var new_y_axis = new_z_axis.cross(new_x_axis).normalized()

	object.transform.basis = Basis(new_x_axis, new_y_axis, new_z_axis)



func snap_snap_ray_cast_3d() -> void:
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()

	for ray_cast_3d: RayCast3D in get_tree().get_nodes_in_group("snap_ray_cast_3d"):
		if ray_cast_3d:
			ray_cast_3d.force_raycast_update()
			
			if selected_nodes.size() > 0:
				for node in selected_nodes:
					if node is StaticBody3D or node is MeshInstance3D:
						var mesh_child = node.get_child(0)
						var aabb
						
						if mesh_child is MeshInstance3D:
							aabb = mesh_child.get_aabb()

						if ray_cast_3d.is_colliding():
							
							if ray_cast_3d.get_collider() == node:
								pass
							else:
								var ray_collision_point = ray_cast_3d.get_collision_point()
								var local_collision_point = node.to_local(ray_collision_point)
								var local_offset = Vector3.ZERO  # Start with default offset
								var snap_flush_offset: int = 0

								if ray_cast_3d.name == "SnapFrontFlush_" + node.name:


									if ray_cast_3d.get_collision_normal().round() == Vector3(0, 0, 1):
										var flush_point = ray_cast_3d.get_collision_point().z

										scene_preview.position.z = flush_point - (aabb.size.z / 2 - snap_flush_offset)



func clear_ray_cast_3d_nodes() -> void:
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	for ray_cast_3d: RayCast3D in get_tree().get_nodes_in_group("snap_ray_cast_3d"):
		if ray_cast_3d:
			if selected_nodes.has(ray_cast_3d.get_parent_node_3d()):
				pass
			else:
				ray_cast_3d.queue_free()




func rotation_snapping() -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes != []:
		for node in selected_nodes:
			if node is Node3D and node.name.begins_with("PivotNode3D_") and node.get_child(0): # Add rotation flag enabled

				node.rotation_degrees.y = fposmod(node.rotation_degrees.y, 360.0)

				#if rotation_45:
				if rotation_15:
					# Snap to closest 45 degree position
					if node.rotation_degrees.y >= 337.5 or node.rotation_degrees.y < 22.5:
						node.rotation_degrees.y = 0.0
					elif node.rotation_degrees.y >= 22.5 and node.rotation_degrees.y < 67.5:
						node.rotation_degrees.y = 45.0
					elif node.rotation_degrees.y >= 67.5 and node.rotation_degrees.y < 112.5:
						node.rotation_degrees.y = 90.0
					elif node.rotation_degrees.y >= 112.5 and node.rotation_degrees.y < 157.5:
						node.rotation_degrees.y = 135.0
					elif node.rotation_degrees.y >= 157.5 and node.rotation_degrees.y < 202.5:
						node.rotation_degrees.y = 180.0
					elif node.rotation_degrees.y >= 202.5 and node.rotation_degrees.y < 247.5:
						node.rotation_degrees.y = 225.0
					elif node.rotation_degrees.y >= 247.5 and node.rotation_degrees.y < 292.5:
						node.rotation_degrees.y = 270.0
					elif node.rotation_degrees.y >= 292.5 and node.rotation_degrees.y < 337.5:
						node.rotation_degrees.y = 315.0

					rotation_value = 45.0




var ray_cast_3d_count: int = 6
var snap_ray_cast_3d_names: Array[String] = ["SnapXLeft_", "SnapXRight_", "SnapZForward_", "SnapZBackward_", "SnapCenterUp_", "SnapCenterDown_", "SnapFrontFlush_"]



func create_snap_ray_cast_3d() -> void:
	var ray_cast_3d_length: float = 0.2
	
	var editor_interface = EditorInterface
	if not editor_interface:
		return
	var selected_nodes: Array[Node] = editor_interface.get_selection().get_selected_nodes()


	for node in selected_nodes:
		if node is StaticBody3D:
			for snap_name: String in snap_ray_cast_3d_names:

				var mesh_child = node.get_child(0)
				# NOTE adjust for none child(0) meshinstance3d children or multiple mesh
				if mesh_child is MeshInstance3D:
					var aabb = mesh_child.get_aabb()

					var ray_cast_3d = RayCast3D.new()
					node.add_child(ray_cast_3d)
					ray_cast_3d.add_to_group("snap_ray_cast_3d", false)
					ray_cast_3d.owner = node

					if not snap_on_rotate: # NOTE WILL ONLY WORK IF SOMEHOW LOCK RAYCAST AFTER IT SNAPS TO WALL, BUT THEN IT ALSO WOULDN'T WORK IF LOCKED
						match snap_name:
							"SnapFrontFlush_":
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_x_offset = aabb.get_center().x - (aabb.size.x / 1.9)
								var ray_cast_3d_y_offset = aabb.get_center().y
								var ray_cast_3d_z_offset = aabb.get_center().z + 2
								ray_cast_3d.position =  Vector3(ray_cast_3d_x_offset, ray_cast_3d_y_offset, ray_cast_3d_z_offset)
								ray_cast_3d.target_position = Vector3(0, 0, -ray_cast_3d_length)
							
							"SnapXLeft_": # X LEFT # FIXME find if ray_cast_3d_x_offset needs to be global and run in process()
								ray_cast_3d.name = snap_name + node.name
								ray_cast_3d_x_offset = aabb.get_center().x - (aabb.size.x / 2)
								ray_cast_3d_y_offset = aabb.get_center().y
								ray_cast_3d.position =  Vector3(ray_cast_3d_x_offset, ray_cast_3d_y_offset, aabb.get_center().z)
								ray_cast_3d.target_position = Vector3(-ray_cast_3d_length, 0, 0)

							"SnapXRight_": # X RIGHT
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_x_offset = aabb.get_center().x + (aabb.size.x / 2)
								var ray_cast_3d_y_offset = aabb.get_center().y
								ray_cast_3d.position =  Vector3(ray_cast_3d_x_offset, ray_cast_3d_y_offset, aabb.get_center().z)
								ray_cast_3d.target_position = Vector3(+ray_cast_3d_length, 0, 0)
								
							"SnapZForward_": # CENTER UP
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_y_offset = aabb.get_center().y + (aabb.size.y / 2)
								ray_cast_3d.position =  Vector3(aabb.get_center().x, ray_cast_3d_y_offset, aabb.get_center().z)
								ray_cast_3d.target_position = Vector3(0, ray_cast_3d_length, 0)
								
							"SnapZBackward_": # CENTER DOWN
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_y_offset = aabb.get_center().y - (aabb.size.y / 2)
								ray_cast_3d.position =  Vector3(aabb.get_center().x, ray_cast_3d_y_offset, aabb.get_center().z)
								ray_cast_3d.target_position = Vector3(0, -ray_cast_3d_length, 0)
								
							"SnapCenterUp_": # Z FORWARD
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_z_offset = aabb.get_center().z + (aabb.size.z / 2)
								var ray_cast_3d_y_offset = aabb.get_center().y
								ray_cast_3d.position =  Vector3(aabb.get_center().x, ray_cast_3d_y_offset, ray_cast_3d_z_offset)
								ray_cast_3d.target_position = Vector3(0, 0, +ray_cast_3d_length)
								
							"SnapCenterDown_": # Z BACKWARD
								ray_cast_3d.name = snap_name + node.name
								var ray_cast_3d_z_offset = aabb.get_center().z - (aabb.size.z / 2)
								var ray_cast_3d_y_offset = aabb.get_center().y
								ray_cast_3d.position =  Vector3(aabb.get_center().x, ray_cast_3d_y_offset, ray_cast_3d_z_offset)
								ray_cast_3d.target_position = Vector3(0, 0, -ray_cast_3d_length)
								




#var scenes_to_keep: Array[String] = []
#
#func remove_unused_scenes_on_exit() -> void:
	## Clear out old entries from folder_project_scenes array
	#scene_viewer_panel_instance.folder_project_scenes.clear()
	## Do fresh scan of collections folders
	#scene_viewer_panel_instance.collect_files_and_dirs("res://collections/")
	#var folder_project_scenes: Array[String] = scene_viewer_panel_instance.folder_project_scenes
#
	#for key in required_scenes_dict.keys():
		#for file_path: String in required_scenes_dict[key]:
			#if not scenes_to_keep.has(file_path):
				#scenes_to_keep.append(file_path)
#
	## Check if scenes in collection folders are within the scenes to keep
	#for file_path: String in folder_project_scenes:
		#if not scenes_to_keep.has(file_path):
			#scene_viewer_panel_instance.remove_file_from_collections(file_path)





func _exit_tree() -> void:
	#thread.wait_to_finish()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, snap_panel_menu)
	snap_panel_menu.queue_free()


	# FIXME TODO Decide if needed and gives ERROR: scene/main/node.cpp:1687 - Condition "p_child->data.parent != this" is true.
	#if snap_flow_manager_graph:
		#remove_control_from_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_flow_manager_graph)
		#snap_flow_manager_graph.queue_free()

	# FIXME TODO Decide if needed and gives ERROR: scene/main/node.h:485 - Parameter "data.tree" is null.
	#if scene_viewer_panel_instance:
		#remove_control_from_bottom_panel(scene_viewer_panel_instance)
		#scene_viewer_panel_instance.queue_free()



	#if popup_window_instance:
		#popup_window_instance.queue_free()

	## Remove the scene_snap_settings_instance
	#if scene_snap_settings_instance:
		#scene_snap_settings_instance.queue_free()

	if EditorInterface.get_selection().is_connected("selection_changed", _on_selection_changed):
		EditorInterface.get_selection().disconnect("selection_changed", _on_selection_changed)
	
	#main_screen_changed.disconnect(current_viewport_window)
	## TEMP DISABLED
	#if snap_flush_scene:
		#snap_flush_scene.queue_free()

	#WorkerThreadPool.wait_for_group_task_completion(task_id)
