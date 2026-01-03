@tool
extends MainBaseTab


signal selected_collections_from_item_list
signal selected_sub_tab_changed
signal check_collection_dependancy (remove_collection_name: String) ## Check if collection scenes are used within other scenes in project within scene_viewer.gd before removing collection.
#signal update_scene_dependancies (current_collection_path: String, renamed_collection_path: String) ## Update the project scene files ext_resource path= manually from current_collection_path to renamed_collection_path.
signal update_buttons_scene_full_path (current_collection_name: String, new_collection_name: String) ## Update the scene_full_path variable for each of the thumbnail buttons.
#signal do_rename_collection_check (current_collection_path: String, renamed_collection_path: String, rewrite: bool)
#signal do_update_dep_paths (scene_dep_paths: Dictionary[String, Array], current_collection_path: String, renamed_collection_path: String)
signal do_update_dep_paths (current_collection_path: String, renamed_collection_path: String)

signal reload_to_collection_queue (current_collection_name: String, new_collection_name: String) ## When renaming collection needs to go through add_scenes_to_collections() again to fill scene_lookup.has(scene_full_path) and load scenes into memory.

signal recreate_new_collection_folder_structure ## Recreate the New Collection folders in res:// and user:// when the collection is removed.
#signal get_current_project_scenes
# NOTE ScrollContainer and HFlowContainer nodes not used but needed to match MainBaseTab class script

#var scene_buttons: Array[Node] = []
# Pass down scene_buttons to sub collection script


# TEST Distraction Free MODE
@onready var h_box_container: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var sub_collection_h_box_container: HBoxContainer = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var item_list: ItemList = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/ItemList
@onready var add_item_list_tabs_button: Button = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/MarginContainer3/VBoxContainer/AddItemListTabsButton
@onready var open_item_list_button: Button = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/MarginContainer2/OpenItemListButton
@onready var v_sep_margin_container: MarginContainer = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/MarginContainer2/VSepMarginContainer
@onready var margin_container: MarginContainer = $VBoxContainer/MarginContainer

@onready var dummy_button: Button = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/MarginContainer3/VBoxContainer/DummyButton
@onready var filter_2d_3d_button: Button = %Filter2D3DButton
@onready var tab_rename_center_container: CenterContainer = $TabRenameCenterContainer
@onready var tab_name_line_edit: LineEdit = %TabNameLineEdit
@onready var create_new_collection_folder_timer: Timer = $CreateNewCollectionFolderTimer
@onready var scenes_paths: Array[String] = ["user://global_collections/scenes/", "user://shared_collections/scenes/", "res://collections/"]
@onready var path_to_thumbnail_cache_global: String = "user://global_collections/thumbnail_cache_global/"
@onready var path_to_thumbnail_cache_shared: String = "user://shared_collections/thumbnail_cache_shared/"
@onready var tab_bar: TabBar = sub_tab_container.get_tab_bar()
@onready var res_dir = DirAccess.open("res://")
#const SUB_COLLECTION_TAB = preload("res://addons/scene_snap/plugin_scenes/sub_collection_tab.tscn")


var await_start: bool = true
var item_list_active: bool = false
var folder_paths: Dictionary = {}
var current_collection_name: String = ""
var new_collection_name: String = ""
var current_tab_index: int
var tab_bar_active: bool = false
var theme_style: String = ""
#var all_project_scenes: Array[String] = []
var passed_rename_collection_check: bool = false
#var reprocess_collection: bool = false ## Flag to prevent emitting reload_to_collection_queue signal more then once.
#var scene_dep_paths: Dictionary[String, Array] = {}
#var settings


# FIXME NEW COLLECTIONS BEING CREATED ON START 
# FIXME X FOR TAB BAR NOT ALWAYS DISPLAYING AND CAN'T CLOSE
# FIXME TEXT GHOSTING WHEN CHANGING TAB TEXT
func _ready() -> void:
	super()
	#emit_signal("get_current_project_scenes")
	## TEST Doesn't quite work creates a tab but is not hidden
	## NOTE: Also check "Use Hidden Tabs for Min Size" Property
	## Create dummy invisible tab for when text changed with no x to hold min y size value and spacing gets messed up 
	#var new_sub_collection_tab: Control = SUB_COLLECTION_TAB.instantiate()
	#sub_tab_container.add_child(new_sub_collection_tab)
	#new_sub_collection_tab.size.y = 50
	#new_sub_collection_tab.hide()
	## TEST


	#settings = EditorInterface.get_editor_settings()
	settings.settings_changed.connect(check_for_removed_collections)
	
	tab_bar.set_position(Vector2(300.0, 0.0))

	tab_bar.tab_close_pressed.connect(on_tab_close_pressed)
	# Initialize with not showing Tab close button
	tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)

	# NOTE Restrict double click to edit tab titles to only when mouse over TabBar 
	tab_bar.mouse_entered.connect(func(): tab_bar_active = true)
	tab_bar.mouse_exited.connect(func(): tab_bar_active = false)

	
	open_item_list_button.set_button_icon(get_theme_icon(&"Add", &"EditorIcons"))
	add_item_list_tabs_button.set_button_icon(get_theme_icon(&"ArrowRight", &"EditorIcons"))


	#call_deferred("connect_update_signal")
	call_deferred("get_collection_and_thumbnail_filesystem_folder_paths")
	#await get_tree().process_frame
	await get_tree().create_timer(1).timeout
	call_deferred("set_tabs_close_state")
	
	# NOTE should only run the first time the plugin is installed and loaded
	# additional code in script prevents the deletion of the New Collection
	# FIXME getting ERROR: res://addons/scene_snap/scripts/main_collection_tab.gd:137 - Cannot call method 'create_timer' on a null value.
	#await get_tree().create_timer(5).timeout
	call_deferred("ready_new_collection_tab")
	call_deferred("match_theme_style", theme_style)
	# Update so Editor Settings list and folders match on start.
	update_collections_in_editor_settings()
	

func set_tabs_close_state() -> void:
	# HACK FIXME Run when all Tabs are in scene tree not based on timer
	# Set the Tabs close buttons to show if more then one tab open or only 1 and not "New Collection"
	tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY)
	if sub_tab_container.get_tab_count() <= 1:
		# If the last tab is "New Collection"  and the close is pressed do nothing
		for collection in get_or_rename_collections_in_tree("", "", false):
			#if debug: print("collection: ", collection)
			if collection.name == "New Collection":
				tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)

#func _physics_process(delta: float) -> void:
	#print("all_project_scenes: ", all_project_scenes)

## Remove collections from user:// dir that have been removed from either Global or Shared Collections in Editor Settings.
func check_for_removed_collections():

	match self.name:
		"Global Collections":
			var global_collections: String = "scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/global_collections"
			if debug: print("remove these folders from global: ", collections_to_remove(global_collections))
			for remove_collection_name: String in collections_to_remove(global_collections):
				get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, remove_collection_name)

		"Shared Collections":
			var shared_collections: String = "scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/shared_collections"
			#if debug: print("remove these folders from shared: ", collections_to_remove(shared_collections))
			for remove_collection_name: String in collections_to_remove(shared_collections):
				get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, remove_collection_name)


## Compare folders in the user:// dir with collections listed in Editor Settings and return collection name of those removed from Editor Settings.
func collections_to_remove(setting_name: String) -> Array[String]:
	var collections_to_remove: Array[String] = []

	if settings.check_changed_settings_in_group(setting_name):
		if debug: print("folder_path_directories: ", get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, ""))
		# NOTE: Will just return folder_path_directories from get_rename_or_remove_collection_folder_names_in_filesystem
		for collection: String in get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, ""):
			if not settings.get_setting(setting_name).has(collection):
				collections_to_remove.append(collection)
				# FIXME "New Collection" being added here, because "New Collection" is not being added to global_collections: in settings? where in code are they added?
				# Maybe not added in global_collections because it exists in shared_collections?

	return collections_to_remove













func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
	## TODO ADD ESCAPE TO EXIT AND REVERT TO CURRENT TAB NAME
	## TODO ADD UNDO REDO FUNCTIONALITY
	## TODO ADD WARNING IF RENAME MATCHES EXISTING TAB NAME
		if event.is_double_click() and tab_bar_active: # and tab_hovered != -1:
			## Update sub collection names
			#sub_collection_names = []
			#get_sub_collection_names()

			current_tab_index = sub_tab_container.get_current_tab()
			#current_tab_name =  sub_tab_container.get_tab_title(current_tab_index)
			
			current_collection_name =  sub_tab_container.get_tab_title(current_tab_index)
			#push_error("updating current_collection_name to: ", current_collection_name)
			
			# Set LineEdit to match TabTitle name
			#tab_name_line_edit.text = current_tab_name
			tab_name_line_edit.text = current_collection_name

			# tab_rename_center_container position
			var tab_rect: Rect2 = sub_tab_container.get_tab_bar().get_tab_rect(current_tab_index)
			# Adjust renaming box to matching styles text position.
			match theme_style:
				"Classic":
					tab_rename_center_container.position = Vector2(tab_rect.position.x + 41, 46)
				"Modern":
					tab_rename_center_container.position = Vector2(tab_rect.position.x + 50, 47)
				_:
					tab_rename_center_container.position = Vector2(tab_rect.position.x + 34, 38)

			tab_name_line_edit.show()

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not item_list_active:
			if item_list.is_visible_in_tree():
				open_item_list_button.show()
				add_item_list_tabs_button.hide()
				item_list.hide()

	if Input.is_key_pressed(KEY_ENTER):
		add_selected_collections_from_item_list()

		# find old tab name and rename to line_edit.text if old tab name in thumbnail cache folder rename that too.
		if modify_and_hide_line_edit(false):

			var current_collection_path: String = scenes_paths[2].path_join(current_collection_name.to_snake_case())
			var renamed_collection_path: String = scenes_paths[2].path_join(new_collection_name.to_snake_case())
			collection_rename_check(current_collection_path, renamed_collection_path)

			if passed_rename_collection_check:
				if debug: print("passed_rename_collection_check")
				get_or_rename_collections_in_tree(current_collection_name, new_collection_name, true)
			else:
				# FIXME If begin edit and then close editor will reload with wrong name
				#if debug: print("resetting collection name to: ", current_collection_name)
				tab_name_line_edit.text = new_collection_name
				
				tab_name_line_edit.set_caret_force_displayed(true)
				tab_name_line_edit.set_caret_blink_enabled(true)
				tab_name_line_edit.select_all()
				tab_name_line_edit.show()


	if Input.is_key_pressed(KEY_ESCAPE):

		if item_list.is_visible_in_tree():
			open_item_list_button.show()
			add_item_list_tabs_button.hide()
			item_list.hide()

		# Hide LineEdit and reset
		modify_and_hide_line_edit(true)


func modify_and_hide_line_edit(reset_title: bool) -> bool:
	if tab_name_line_edit:
		if tab_name_line_edit.is_visible():
			if reset_title: # Reset TabTitle to orginal name
				tab_name_line_edit.hide()
				sub_tab_container.set_tab_title(current_tab_index, current_collection_name)
			else: # Rename to new_collection_name
				tab_name_line_edit.hide()
				sub_tab_container.set_tab_title(current_tab_index, new_collection_name)
			return true # Tab was visible
	return false # Tab was not visible


#region New Code Region

## Run at the ready to get the filesystem_folder_paths for that main_collection_tab "Global Collections" or "Shared Collections"
func get_collection_and_thumbnail_filesystem_folder_paths() -> Dictionary:
	match self.name:
		"Global Collections":
			folder_paths["collections_folder_path"] = scenes_paths[0].path_join("Global Collections")
			folder_paths["thumbnails_folder_path"] = path_to_thumbnail_cache_global.path_join("Global Collections")
		"Shared Collections":
			folder_paths["collections_folder_path"] = scenes_paths[1].path_join("Shared Collections")
			folder_paths["thumbnails_folder_path"] = path_to_thumbnail_cache_shared.path_join("Shared Collections")
			
	#folder_paths["collections_folder_path"] = scenes_paths[2]
	return folder_paths





# NOTE This will get all collection nodes currently in the respective "Global Collections" - "Shared Collections" tree
# and will sync to tab titles (refresh when doubleclick to get name conflicts, refresh after rename(Enter key & Button)) 
func get_or_rename_collections_in_tree(current_collection_name: String, new_collection_name: String, rename_collection: bool) -> Array[Node]:
	var collections_in_tree: Array[Node] = []
	for collection in sub_tab_container.get_children():
		if rename_collection:
			# Rename collection to new_collection_name
			if collection.name == current_collection_name:
				collection.name = new_collection_name
		else:
			collections_in_tree.append(collection)

	if rename_collection:
		# Skip rename if collection folder name already exists in filesystem or is empty string ""
		if get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, true, "").has(new_collection_name) or new_collection_name == "": #new_collection_name.is_empty():
			# Reset TabTitle to orginal name
			if debug: print("highlight the Text red or put this as a check when typing in characters")
			sub_tab_container.set_tab_title(current_tab_index, current_collection_name)
			return collections_in_tree

		# Must come AFTER create_folders and BEFORE below check
		get_rename_or_remove_collection_folder_names_in_filesystem(current_collection_name, new_collection_name, true, true, "")

		# Recreate New Collection folder if renamed
		if current_collection_name == "New Collection":
			# Add ability to close Tab that has now been renamed
			tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY)
			# Give sync software ex. Nextcloud time to resolve name conflicts 
			create_new_collection_folder_timer.start()


	return collections_in_tree

# This is used to give sync client time to do name conflict resolution # FIXME No way to know optimal time? 
func _on_create_new_collection_folder_timer_timeout() -> void:
	create_folders(folder_paths["collections_folder_path"].path_join("New Collection".path_join("textures")))
	# After delay and New Collection re-created update so list and folders match.
	update_collections_in_editor_settings()



func update_collections_in_editor_settings() -> void:
	var folder_path_directories: PackedStringArray = DirAccess.get_directories_at(folder_paths["collections_folder_path"])
	if self.name == "Global Collections":
		settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/global_collections", folder_path_directories)
	else:
		settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/shared_collections", folder_path_directories)
	#return folder_path_directories

# NOTE This will get or rename depending on the rename_collection flag all folder names witin the matching "Global Collections" - "Shared Collections"
# directories in the filesystem, will need to sync ItemList to it (refresh everytime ItemList is opened)
# FIXME With delay in creating new "New Collection" folder "folder_path_directories" is not current. and does not add "New Collection" to Editor Settings.
func get_rename_or_remove_collection_folder_names_in_filesystem(current_collection_name: String, new_collection_name: String, rename_collection: bool, update_editor_settings: bool, remove_collection_name: String) -> PackedStringArray:
	#if debug: print("remove_collection_name: ", remove_collection_name)
	if debug: print("rename_collection: ", rename_collection)
	if debug: print("current_collection_name: ", current_collection_name)
	if debug: print("new_collection_name: ", new_collection_name)
	var folder_path_directories: PackedStringArray = DirAccess.get_directories_at(folder_paths["collections_folder_path"])
	
	if update_editor_settings:
		update_collections_in_editor_settings()
		#folder_path_directories = update_collections_in_editor_settings()
		#if self.name == "Global Collections":
			#settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/global_collections", folder_path_directories)
		#else:
			#settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/shared_collections", folder_path_directories)
		##if debug: print("folder_paths: ", folder_paths)
		##settings.erase("scene_snap_plugin/collections:_warning!_cannot_undo_removed_collections/global_collections")
		##settings.erase("scene_snap_plugin/panel_size")

	if rename_collection:
		update_scene_data_cache_paths(current_collection_name, remove_collection_name, true)
	elif remove_collection_name != "":
		update_scene_data_cache_paths(current_collection_name, remove_collection_name, false)

	if rename_collection or remove_collection_name != "":
		###emit_signal("get_current_project_scenes")
		###push_error("all_project_scenes: ", all_project_scenes)
		###var collection_path: String = folder_paths["collections_folder_path"]
		###var thumb_path: String = folder_paths["thumbnails_folder_path"]
		#var current_collection_path: String = scenes_paths[2].path_join(current_collection_name.to_snake_case())
		#var renamed_collection_path: String = scenes_paths[2].path_join(new_collection_name.to_snake_case())
		###var rewrite: bool = false
		##emit_signal("do_rename_collection_check", current_collection_path, renamed_collection_path, false)
		###push_error("passed_rename_collection_check: ", passed_rename_collection_check)
		#collection_rename_check(current_collection_path, renamed_collection_path)
		## FIXME if fails to pass check revert collection name.
		#if passed_rename_collection_check:
		
		if debug: print("remove_collection_name: ", remove_collection_name)
		rename_or_remove_collection_filesystem_folders(current_collection_name.to_snake_case(), new_collection_name.to_snake_case(), scenes_paths[2], rename_collection, remove_collection_name.to_snake_case(), true) # res:// Collection .tscn/.scn files 
		rename_or_remove_collection_filesystem_folders(current_collection_name, new_collection_name, folder_paths["thumbnails_folder_path"], rename_collection, remove_collection_name) # user:// Thumbnails
		rename_or_remove_collection_filesystem_folders(current_collection_name, new_collection_name, folder_paths["collections_folder_path"], rename_collection, remove_collection_name, false, true) # user:// Collection .glb files

		#var current_collection_path: String = scenes_paths[2].path_join(current_collection_name.to_snake_case())
		#var renamed_collection_path: String = scenes_paths[2].path_join(new_collection_name.to_snake_case())
		#var rewrite: bool = false
		#emit_signal("do_rename_collection_check", current_collection_path, renamed_collection_path, false)

		#emit_signal("do_update_dep_paths", scene_dep_paths, current_collection_path, renamed_collection_path)

		#update_dep_paths(scene_dep_paths: Dictionary[String, Array], current_collection_path: String, renamed_collection_path: String,)


		return []
	else:
		return folder_path_directories

#func pre_check() -> void:
	#var open_scene_roots : Array[Node] = EditorInterface.get_open_scene_roots()
	#for open_scene_root: Node in open_scene_roots:
		#get_packed_scenes(open_scene_root)
	#push_error("scene_instance_packed_scenes: ", scene_instance_packed_scenes)
	## get all scenes of open scenes and check against dep intigrate with function below



### For a given scene return all nodes that contain a scene_file_path (PackedScenes)
#var scene_instance_packed_scenes: Dictionary[Node, String] = {} ## Include node_file_path so that we don't have to look it up again when == dep_path. 
#func get_packed_scenes(node: Node) -> void:
	#for child: Node in node.get_children():
		#var node_file_path: String = child.get_scene_file_path()
		#if node_file_path:
			#scene_instance_packed_scenes[child] = node_file_path
		#get_packed_scenes(child)


## For a given scene return all nodes that contain a scene_file_path (PackedScenes)
#var scene_instance_packed_scenes: Dictionary[Node, String] = {} ## Include node_file_path so that we don't have to look it up again when == dep_path. 
func get_packed_scenes(node: Node) -> void:
	for child: Node in node.get_children():
		var node_file_path: String = child.get_scene_file_path()
		if node_file_path:
			node_file_paths.append(node_file_path)
			#scene_instance_packed_scenes[child] = node_file_path
		get_packed_scenes(child)




#var open_scenes_packed_scenes_paths: Dictionary[Node, Array] = {}
var node_file_paths: Array[String] = []

# FIXME BUG? EditorInterface.get_open_scenes() Does not always seems to get open scenes?
# FIXME TODO Adding scene to scene in tree and then changing collection name before saving scene results in dep error need to check current open scenes tree before rename too. 
func collection_rename_check(current_collection_path: String, renamed_collection_path: String) -> void:
	#scene_dep_paths.clear()
	var conflicting_open_scenes: Array[String] = []
	#var open_scenes : PackedStringArray = EditorInterface.get_open_scenes()
	#push_error("open_scenes: ", open_scenes)
	##collect_files_and_dirs("res://", true)
	#emit_signal("get_current_project_scenes")
	##push_error("all_project_scenes: ", all_project_scenes)

	# Do Pre-Check for scenes that are open that have collections scenes added, but that have not been saved to disk yet.
	var open_scene_roots : Array[Node] = EditorInterface.get_open_scene_roots()
	for open_scene_root: Node in open_scene_roots:
		node_file_paths.clear()
		get_packed_scenes(open_scene_root)
		for node_file_path: String in node_file_paths:
			if node_file_path.contains(current_collection_path):
				var scene_file_path: String = open_scene_root.get_scene_file_path()
				if not conflicting_open_scenes.has(scene_file_path):
					conflicting_open_scenes.append(scene_file_path)



	##await get_tree().process_frame
	#push_error("current_collection_path: ", current_collection_path)
	#push_error("scene_instance_packed_scenes: ", scene_instance_packed_scenes)
	#for scene: Node in scene_instance_packed_scenes.keys():
		##var scene_path: String = str(scene_instance_packed_scenes[scene])
		##if scene_path.contains(current_collection_path):
		#if scene_instance_packed_scenes[scene].contains(current_collection_path):
		##if scene_instance_packed_scenes[scene] == current_collection_path:
			#var scene_file_path: String = scene.get_scene_file_path()
			#if not conflicting_open_scenes.has(scene_file_path):
				#conflicting_open_scenes.append(scene_file_path)




	## Do Check for all scenes in the entire project that have collections scene references that need to be updated.
	#for file_path: String in all_project_scenes:
		#if res_dir.file_exists(file_path):
			## Get file_path to all scenes that are dependencies of other scenes in project
			#var dep_paths: Array[String] = []
			#for dep in ResourceLoader.get_dependencies(file_path):
				## Split dep to get just the file_path
				#var dep_path: String = dep.get_slice("::", 2)
				#dep_paths.append(dep_path)
				#if dep_path.contains(current_collection_path):
					#scene_dep_paths[file_path] = dep_paths
					## Check if scene open and if yes push error to close first
					#if open_scenes.has(file_path):
						#if not conflicting_open_scenes.has(file_path):
							#conflicting_open_scenes.append(file_path)







	if conflicting_open_scenes:
		# TODO Add popup for more visibility.
		push_warning("Please save and close the following scene(s): ", conflicting_open_scenes, " before renaming the collection.")
		passed_rename_collection_check = false
		modify_and_hide_line_edit(true)
	else:
		passed_rename_collection_check = true



# FIXME Renaming collection loses link to scenes they are dependacies of.
func rename_or_remove_collection_filesystem_folders(current_collection_name: String, new_collection_name: String, collection_or_thumb_path: String, rename_collection: bool, remove_collection_name: String, check_dep: bool = false, reprocess_collection: bool = false) -> void:
	var current_collection_path: String = collection_or_thumb_path.path_join(current_collection_name)
	if DirAccess.dir_exists_absolute(current_collection_path):
		if rename_collection:
			# Handle res:// files differently. copy_absolute(from: String, to: String, chmod_flags: int = -1)
			#var current_collection_path: String = collection_or_thumb_path.path_join(current_collection_name)
			var renamed_collection_path: String = collection_or_thumb_path.path_join(new_collection_name)


			if DirAccess.rename_absolute(current_collection_path, renamed_collection_path) != OK:
				printerr("Could not rename collection folder from ", current_collection_name, " to ", new_collection_name)
			if not EditorInterface.get_resource_filesystem().is_scanning():
				EditorInterface.get_resource_filesystem().scan()

			# TODO a file access read and find the old file path and change to the new file path will this work for .scn files?
			# for files with dependacies that match current_collection_name will need to find all cases of path="res://collections/current_collection_name/
			# and change them to path="res://collections/new_collection_name/
			if collection_or_thumb_path.begins_with("res://collections/"): # NOTE: all scenes in project that use these files as dependacies need to be updated with the new path to these files.

				emit_signal("do_update_dep_paths", current_collection_path, renamed_collection_path)

				#if reprocess_collection:
					#reprocess_collection = false
					#while EditorInterface.get_resource_filesystem().is_scanning():
						#await get_tree().process_frame
					## TODO Can this be minimized to not reloading the entire collection from top of the stack?
					## NOTE: Done here because current_collection_name, new_collection_name will be the non snake_case version.
					#emit_signal("reload_to_collection_queue", current_collection_name, new_collection_name)

			else:
				# FIXME buttons collection name var also needs to be updated
				emit_signal("update_buttons_scene_full_path", current_collection_name, new_collection_name)

				if reprocess_collection:
					#reprocess_collection = false
					while EditorInterface.get_resource_filesystem().is_scanning():
						await get_tree().process_frame
					# TODO Can this be minimized to not reloading the entire collection from top of the stack?
					# NOTE: Done here because current_collection_name, new_collection_name will be the non snake_case version.
					emit_signal("reload_to_collection_queue", current_collection_name, new_collection_name)





				#if DirAccess.rename_absolute(current_collection_path, renamed_collection_path) != OK:
					#printerr("Could not rename collection folder from ", current_collection_name, " to ", new_collection_name)

			if not EditorInterface.get_resource_filesystem().is_scanning():
				EditorInterface.get_resource_filesystem().scan()

			#update_scene_data_cache_paths(current_collection_name, remove_collection_name, true)








		# NOTE: The user:// dir scenes and thumbnails will be removed, but the res://collection scenes will remain if they are dependancies of other scenes in the project.
		else:# NOTE IF REMOVE_ABSOLUTE MUST FIRST REMOVE ALL FILES IN FOLDER
			## FIXME PUT LOCK ON DELETING "NEW COLLECTION" EITHER DON'T LIST OR RECREATE OR JUST PASS HERE, BUT LEAVES ITEMS IN NEW COLLECTION TAB
			## FIXME REMOVING COLLECTIONS THAT HAVE USED SCENES WILL BREAK THE SCENE THAT USE THEM. DO CHECK IF FILE TO REMOVE IS A DEPENDACY OF ANOTHER SCENE.
			#await remove_files_in_folder_recursive(collection_or_thumb_path.path_join(remove_collection_name))
			## NOTE Giving false negative because file is removed
			##if DirAccess.remove_absolute(collection_or_thumb_path.path_join(remove_collection_name)) != OK:
				##printerr("Could not remove directory ", remove_collection_name, " from ", collection_or_thumb_path)
			#DirAccess.remove_absolute(collection_or_thumb_path.path_join(remove_collection_name))

			if not check_dep:
				await remove_files_in_folder_recursive(collection_or_thumb_path.path_join(remove_collection_name))
				DirAccess.remove_absolute(collection_or_thumb_path.path_join(remove_collection_name))
			else: # For folders within the project check that individual files are not dependacies for other scenes in the project before removing. 
# ALERT Also do collection_rename_check and get result of flag for scenes that have scenes added but not yet saved, before removing collection.
# But maybe not necessay? .tscn exists as soon as placed. so as long as the open scene is saved it will use the res://collection scene
# But check_collection_dependancy will need to be updated to include open scene files collection name matching not just check resource dep. or unsaved scene files that have
# collections removed will have broken dep when scene removed on restart
				emit_signal("check_collection_dependancy", remove_collection_name)
				# Pass up signal to scene_viewer.gd to handle scene dependacy checking.


			# FIXME New Collection is not removed so need to clear thumbnails or refresh existing
			# Remove the collection tab of removed collection if open in Scene Viewer
			var collection_tabs = sub_tab_container.get_children()
			for tab in collection_tabs:
				if tab.name == remove_collection_name:
					var tab_index = sub_tab_container.get_tab_idx_from_control(tab)
					on_tab_close_pressed(tab_index)
				if tab.name == "New Collection": # New Collection is not removed so need to free scene_view_buttons
					for scene_view_button: Node in tab.h_flow_container.get_children():
						if scene_view_button is Button: # Do not remove the Node2D box select node.
							scene_view_button.queue_free()
					## Recreate the folder structure.
					await get_tree().process_frame
					emit_signal("recreate_new_collection_folder_structure")
					## NEED 1. create_folders("res://", "collections".path_join(collection_name_snake_case.path_join("textures"))) from scene_viewer.gd
					## 3. 

			#update_scene_data_cache_paths(current_collection_name, remove_collection_name, false)

		# Scan to update folder name in filesystem
		if debug: print("scanning filesystem to update removed collection folder: ", remove_collection_name)
		EditorInterface.get_resource_filesystem().scan()
		update_item_list_collections()

#func defer_update_dep_paths(scene_dep_paths: Dictionary[String, Array], current_collection_path: String, renamed_collection_path: String) -> void:
	#emit_signal("do_update_dep_paths", scene_dep_paths, current_collection_path, renamed_collection_path)


# NOTE Renaming works perfect FIXME Removing broken
func update_scene_data_cache_paths(current_collection_name: String, remove_collection_name: String,  rename_collection: bool, scene_file_path: String = "") -> void:
	var scene_data_cache: SceneDataCache = ResourceLoader.load("res://addons/scene_snap/resources/scene_data_cache.tres")
	var new_scene_data: Dictionary = {}

	# Removes single entry from a collection NOTE: Run from scene_viewer.gd import_mesh_tags() during import, to cleanup empty entries.
	if scene_file_path: # scene_full_path chenged to not conflict
		for scene_full_path in scene_data_cache.scene_data.keys():
			if scene_full_path == scene_file_path:
				scene_data_cache.scene_data.erase(scene_full_path)
			else: # Copy over items from collections not removed
				new_scene_data[scene_full_path] = scene_data_cache.scene_data[scene_full_path]

	else:
		# Removes all entries from a specific collection
		if not rename_collection:
			for scene_full_path in scene_data_cache.scene_data.keys():
				var collection_name = scene_full_path.get_base_dir().get_file()
				if collection_name == remove_collection_name:
					scene_data_cache.scene_data.erase(scene_full_path)
				else: # Copy over items from collections not removed
					new_scene_data[scene_full_path] = scene_data_cache.scene_data[scene_full_path]

		# Renames all entries from a specific collection
		if rename_collection:
			for scene_full_path in scene_data_cache.scene_data.keys():
				var collection_name = scene_full_path.get_base_dir().get_file()
				if collection_name == current_collection_name:
					var dir = scene_full_path.get_base_dir().get_base_dir()
					var file = scene_full_path.get_file()
					var new_scene_path = dir.path_join(new_collection_name).path_join(file)
					new_scene_data[new_scene_path] = scene_data_cache.scene_data[scene_full_path]
				else: # Copy over items from collections not renamed
					new_scene_data[scene_full_path] = scene_data_cache.scene_data[scene_full_path]

	# Update the cache in-place
	scene_data_cache.scene_data.clear()
	for key in new_scene_data:
		scene_data_cache.scene_data[key] = new_scene_data[key]

	# Save the updated resource
	if ResourceSaver.save(scene_data_cache, "res://addons/scene_snap/resources/scene_data_cache.tres") != OK:
		push_error("Failed to save scene_data_cache.tres")
	#else:
		#if rename_collection:
			#print("Scene paths updated from ", current_collection_name + " to ",  new_collection_name)
		#else:
			#print("Collection ", current_collection_name + " removed from cache and saved successfully!")















func remove_files_in_folder_recursive(collection_path: String) -> void:
	if collection_path: # Prevent deletion of entire project like I did when refreshing Favorites.
		if debug: print("removing files from: ", collection_path)
		var dir = DirAccess.open(collection_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				var full_path = collection_path.path_join(file_name)
				if dir.current_is_dir():
					#if debug: print("Found directory: " + file_name)
					# Recursively call the function to delete contents of the directory
					remove_files_in_folder_recursive(full_path)
					# After the contents are deleted, remove the directory itself
					dir.remove_absolute(full_path)
					#if dir.dir_exists_absolute(full_path) and dir.remove_absolute(full_path) != OK:
						##if debug: print("full_path: ", full_path)
						#printerr("Could not remove directory ", file_name, " from ", collection_path)
				else:
					# Remove the file
					dir.remove_absolute(full_path)
					#if dir.remove_absolute(full_path) != OK:
						#printerr("Could not remove file ", file_name, " from ", collection_path)
				file_name = dir.get_next()
			dir.list_dir_end()



# Refresh everytime ItemList is opened or on rename of tab
func update_item_list_collections() -> void:
	# Clear ItemList
	item_list.clear()
	# Recreate ItemList from folder names in filesystem
	for collection: String in get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, true, ""):
		# Create matching thumbnails for items
		# NOTE Consider adding small thumbnail texture as icon
		var new_texture_icon = Texture2D.new()
		if self.name == "Global Collections":
			new_texture_icon = preload("res://addons/scene_snap/icons/GlobalIcon.svg")
		else:
			new_texture_icon = preload("res://addons/scene_snap/icons/SharedIcon.svg")


		# Add updated folder names from user:// filesystem 
		item_list.add_item(collection, new_texture_icon)

	# Pin "New Collection" to top
	for item_idex: int in item_list.get_item_count():
		if item_list.get_item_text(item_idex) == "New Collection":
			item_list.move_item(item_idex, 0)



func _on_open_item_list_button_pressed() -> void:
	modify_and_hide_line_edit(true)
	update_item_list_collections()
	open_item_list_button.hide()
	set_open_item_list_margins()
	add_item_list_tabs_button.show()
	item_list.show()



func add_selected_collections_from_item_list() -> void:
	if item_list.visible:
		tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY)
		var collection_names_in_tree: Array[String] = []
		for collection: Control in get_or_rename_collections_in_tree("", "", false):
			collection_names_in_tree.append(collection.name)

		var selected_collections: Array[String] = []
		for collection_index: int in item_list.get_selected_items():
			var selected_collection_name: String = item_list.get_item_text(collection_index)
			# Do not append to selected_scenes if already open
			if collection_names_in_tree.has(selected_collection_name):
				# If adding "New Collection" and "New Collection" is the only open tab revert to preventing close
				if selected_collection_name == "New Collection" and get_or_rename_collections_in_tree("", "", false).size() == 1 \
				and item_list.get_selected_items().size() == 1:
					tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)
			else:
				selected_collections.append(selected_collection_name)

		emit_signal("selected_collections_from_item_list", selected_collections, self)



func _on_add_item_list_tabs_button_pressed() -> void:
	add_selected_collections_from_item_list()
	open_item_list_button.show()
	add_item_list_tabs_button.hide()
	item_list.hide()



func create_folders(scene_folder_path: String) -> void:
	if DirAccess.dir_exists_absolute(scene_folder_path):
		if debug: print("the directory exists!! this continues to print FIXME")
		return
	if not DirAccess.dir_exists_absolute(scene_folder_path):
		DirAccess.make_dir_recursive_absolute(scene_folder_path)


func _on_tab_name_line_edit_text_changed(new_text: String) -> void:
	sub_tab_container.set_tab_title(current_tab_index, new_text)
	#new_tab_name_text = new_text.strip_edges()
	new_collection_name = new_text.strip_edges()
	if debug: print("new_text: ", new_text)


# NOTE CODE BELOW THIS LINE NEEDS TO BE CLEANED UP AND COPIED ABOVE
#endregion



# FIXME Maybe can be removed causes duplicate New Collections to be generated at startup.NOTE See below can not remove
# FIXME On initial plugin install and load with no Collections tabs created by this get errors maybe await ready
func ready_new_collection_tab() -> void:
	if debug: print("sub_tab_container.get_tab_count(): ", sub_tab_container.get_tab_count())
	#await ready
	pass
	#if sub_tab_container.get_tab_count() == 0:
		#tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)
		#var new_collection_array: Array[String] = ["New Collection"]
		#emit_signal("selected_collections_from_item_list", new_collection_array, self)

## Adjust sub tab container bar spacing for Modern and Classic themes on start.
func match_theme_style(theme_style: String) -> void:
	if sub_tab_container != null:
		match theme_style:
			"Classic":
				v_sep_margin_container.show()
				v_sep_margin_container.add_theme_constant_override("margin_right", -36)
				margin_container.add_theme_constant_override("margin_bottom", -37)
				sub_tab_container.add_theme_constant_override("side_margin", 35)
			"Modern":
				v_sep_margin_container.hide()
				margin_container.add_theme_constant_override("margin_bottom", -46)
				sub_tab_container.add_theme_constant_override("side_margin", 40)
			_:
				v_sep_margin_container.show()
				v_sep_margin_container.add_theme_constant_override("margin_right", -30)
				margin_container.add_theme_constant_override("margin_bottom", -31)
				sub_tab_container.add_theme_constant_override("side_margin", 29)


# FIXME If new tab created and renamed and close before new New Collection can be generated will cause error
func on_tab_close_pressed(tab: int) -> void:
	modify_and_hide_line_edit(true)
	var selected_tab_title: String = sub_tab_container.get_tab_title(tab)

	if sub_tab_container.get_tab_count() <= 1:
		# If the last tab is "New Collection"  and the close is pressed do nothing
		for collection in get_or_rename_collections_in_tree("", "", false):
			if collection.name == "New Collection":
				return
			else: # Add a new tab "New Collection" and disable the ability to close it
				tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)
				var new_collection_array: Array[String] = ["New Collection"]
				emit_signal("selected_collections_from_item_list", new_collection_array, self)
				update_collections_in_editor_settings()

	elif sub_tab_container.get_tab_count() <= 2:
		for collection in get_or_rename_collections_in_tree("", "", false):
			if collection.name == "New Collection" and selected_tab_title != "New Collection":
				tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)

	# Remove matching Sub Collection
	var sub_collection_node: Control = sub_tab_container.find_child(selected_tab_title, false, true)
	sub_collection_node.queue_free()

	## Remove matching res:// collection folder if empty.
	#emit_signal("clean_up_empty_collection_folders", selected_tab_title)




#func _process(delta: float) -> void:
	## HACK Trouble getting to update without large timer delay so running here for quickest response
	## Does not seem to effect performance to any degree
	## Objects are filtered at start but then get updated with the favorites so best solution is to have a signal fire when 
	## finished updating to run line_edit.text update
	#if scene_search_line_edit.text != "":
		#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
	#pass






# REFERENCE Mansur Isaev and Contributors Scene Library Plugin
# https://github.com/4d49/scene-library/blob/master/scripts/scene_library.gd#L198
func _update_position_new_collection_btn() -> void:
	var tab_bar_total_width := float(sub_tab_container.get_theme_constant(&"h_separation"))
	for i in sub_tab_container.get_tab_count():
		pass






# FIXME Causing issues
func _on_visibility_changed() -> void:
	modify_and_hide_line_edit(true)


	#if sub_tab_container != null:
		#sub_tab_container.add_theme_constant_override("side_margin", 29)
		#v_sep_margin_container.show()
		#dummy_button.custom_minimum_size = Vector2(0, 0)

	if await_start:
		await get_tree().create_timer(.001).timeout
		await_start = false
	
	# TODO Looks like code from when 360 rotation of all objects, so can probably be removed?
	var scene_view_children = sub_tab_container.get_children()
	if visible:
		for scene in scene_view_children:
			scene.set_process_mode(Node.PROCESS_MODE_INHERIT)
	else:
		for scene in scene_view_children:
			scene.set_process_mode(Node.PROCESS_MODE_DISABLED)



#region ItemList Active
func _on_item_list_mouse_entered() -> void:
	item_list_active = true

func _on_item_list_mouse_exited() -> void:
	item_list_active = false


func _on_add_item_list_tabs_button_mouse_entered() -> void:
	item_list_active = true

func _on_add_item_list_tabs_button_mouse_exited() -> void:
	item_list_active = false
#endregion






## Margins and style to return to when collection selection list closed.
func _on_item_list_hidden() -> void:
	if sub_tab_container != null:
		match theme_style:
			"Classic":
				v_sep_margin_container.show()
				v_sep_margin_container.add_theme_constant_override("margin_right", -36)
				sub_tab_container.add_theme_constant_override("side_margin", 35)
			"Modern":
				sub_tab_container.add_theme_constant_override("side_margin", 40)
			_:
				v_sep_margin_container.show()
				v_sep_margin_container.add_theme_constant_override("margin_right", -30)
				sub_tab_container.add_theme_constant_override("side_margin", 29)

	dummy_button.custom_minimum_size = Vector2(0, 0)


## Margins and style when the collection selection list is open.
#func _on_open_item_list_button_hidden() -> void:
func set_open_item_list_margins() -> void:
	v_sep_margin_container.hide()

	match theme_style:
		"Classic":
			sub_tab_container.add_theme_constant_override("side_margin", 345)
			dummy_button.custom_minimum_size = Vector2(0, 61)
		"Modern":
			sub_tab_container.add_theme_constant_override("side_margin", 350)
			dummy_button.custom_minimum_size = Vector2(0, 47)
			#dummy_button.custom_minimum_size = Vector2(0, 61)
		_:
			sub_tab_container.add_theme_constant_override("side_margin", 335)
			dummy_button.custom_minimum_size = Vector2(0, 61)





func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	add_item_list_tabs_button.grab_focus()





func _on_sub_tab_container_tab_changed(tab: int) -> void:
	modify_and_hide_line_edit(true)
	emit_signal("selected_sub_tab_changed", tab)




func _on_global_search_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if debug: print("enable global")
	else:
		if debug: print("disable global")
