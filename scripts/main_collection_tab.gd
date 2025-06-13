@tool
extends MainBaseTab



signal selected_collections_from_item_list
signal selected_sub_tab_changed

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
@onready var dummy_button: Button = $VBoxContainer/MarginContainer/SubCollectionHBoxContainer/MarginContainer3/VBoxContainer/DummyButton
@onready var filter_2d_3d_button: Button = %Filter2D3DButton
@onready var tab_rename_center_container: CenterContainer = $TabRenameCenterContainer
@onready var tab_name_line_edit: LineEdit = %TabNameLineEdit
@onready var create_new_collection_folder_timer: Timer = $CreateNewCollectionFolderTimer
@onready var scenes_paths: Array[String] = ["user://global_collections/scenes/", "user://shared_collections/scenes/", "res://collections/"]
@onready var path_to_thumbnail_cache_global: String = "user://global_collections/thumbnail_cache_global/"
@onready var path_to_thumbnail_cache_shared: String = "user://shared_collections/thumbnail_cache_shared/"
@onready var tab_bar: TabBar = sub_tab_container.get_tab_bar()

#const SUB_COLLECTION_TAB = preload("res://addons/scene_snap/plugin_scenes/sub_collection_tab.tscn")


var await_start: bool = true
var item_list_active: bool = false
var folder_paths: Dictionary = {}
var current_collection_name: String = ""
var new_collection_name: String = ""
var current_tab_index: int
var tab_bar_active: bool = false
#var settings


# FIXME NEW COLLECTIONS BEING CREATED ON START 
# FIXME X FOR TAB BAR NOT ALWAYS DISPLAYING AND CAN'T CLOSE
# FIXME TEXT GHOSTING WHEN CHANGING TAB TEXT
func _ready() -> void:
	super()
	
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


func check_for_removed_collections():

	match self.name:
		"Global Collections":
			var global_collections: String = "scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/global_collections"
			#if debug: print("remove these folders from global: ", collections_to_remove(global_collections))
			for remove_collection_name: String in collections_to_remove(global_collections):
				get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, remove_collection_name)

		"Shared Collections":
			var shared_collections: String = "scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/shared_collections"
			#if debug: print("remove these folders from shared: ", collections_to_remove(shared_collections))
			for remove_collection_name: String in collections_to_remove(shared_collections):
				get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, remove_collection_name)


func collections_to_remove(setting_name: String) -> Array[String]:
	var collections_to_remove: Array[String] = []

	if settings.check_changed_settings_in_group(setting_name):
		#if debug: print(get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, ""))
		for collection: String in get_rename_or_remove_collection_folder_names_in_filesystem("", "", false, false, ""):
			if not settings.get_setting(setting_name).has(collection):
				collections_to_remove.append(collection)

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
			
			# Set LineEdit to match TabTitle name
			#tab_name_line_edit.text = current_tab_name
			tab_name_line_edit.text = current_collection_name

			# tab_rename_center_container position
			var tab_rect: Rect2 = sub_tab_container.get_tab_bar().get_tab_rect(current_tab_index)
			tab_rename_center_container.position = Vector2(tab_rect.position.x + 34, 37)

			
			tab_name_line_edit.show()
			#await get_tree().process_frame
			#await get_tree().physics_frame
			#await get_tree().create_timer(1).timeout
#			tab_name_line_edit.grab_focus()

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not item_list_active:
			if item_list.is_visible_in_tree():
				open_item_list_button.show()
				add_item_list_tabs_button.hide()
				item_list.hide()

			## Hide LineEdit
			#if tab_name_line_edit.is_visible():
				## Reset TabTitle to orginal name
				#sub_tab_container.set_tab_title(current_tab_index, current_collection_name)
				#tab_name_line_edit.hide()


	if Input.is_key_pressed(KEY_ENTER):
		add_selected_collections_from_item_list()



		# find old tab name and rename to line_edit.text if old tab name in thumbnail cache folder rename that too.
		if modify_and_hide_line_edit(false):
			get_or_rename_collections_in_tree(current_collection_name, new_collection_name, true)

		#if tab_name_line_edit.is_visible():
			#tab_name_line_edit.hide()
			## Set the TabTitle to the new_collection_name that has the strip_edges() applied
			#sub_tab_container.set_tab_title(current_tab_index, new_collection_name)
			## Rename the Folders in the user:// directory and SubTabContainers child nodes
			#get_or_rename_collections_in_tree(current_collection_name, new_collection_name, true)




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

# Run at the ready to get the filesystem_folder_paths for that main_collection_tab "Global Collections" or "Shared Collections"
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



# NOTE This will get or rename depending on the rename_collection flag all folder names witin the matching "Global Collections" - "Shared Collections"
# directories in the filesystem, will need to sync ItemList to it (refresh everytime ItemList is openned)
func get_rename_or_remove_collection_folder_names_in_filesystem(current_collection_name: String, new_collection_name: String, rename_collection: bool, update_editor_settings: bool, remove_collection_name: String) -> PackedStringArray:
	if debug: print("remove_collection_name: ", remove_collection_name)
	if debug: print("rename_collection: ", rename_collection)
	if debug: print("current_collection_name: ", current_collection_name)
	if debug: print("new_collection_name: ", new_collection_name)
	var folder_path_directories: PackedStringArray = DirAccess.get_directories_at(folder_paths["collections_folder_path"])
	
	if update_editor_settings:
		if self.name == "Global Collections":
			settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/global_collections", folder_path_directories)
		else:
			settings.set_setting("scene_snap_plugin/collections:_warning!_removing_collections_will_permanently_delete_them/shared_collections", folder_path_directories)
		#if debug: print("folder_paths: ", folder_paths)
		#settings.erase("scene_snap_plugin/collections:_warning!_cannot_undo_removed_collections/global_collections")
		#settings.erase("scene_snap_plugin/panel_size")
	
	if rename_collection or remove_collection_name != "":
		rename_or_remove_collection_filesystem_folders(current_collection_name.to_snake_case(), new_collection_name.to_snake_case(), scenes_paths[2], rename_collection, remove_collection_name.to_snake_case())
		rename_or_remove_collection_filesystem_folders(current_collection_name, new_collection_name, folder_paths["collections_folder_path"], rename_collection, remove_collection_name)
		rename_or_remove_collection_filesystem_folders(current_collection_name, new_collection_name, folder_paths["thumbnails_folder_path"], rename_collection, remove_collection_name)
		
		return []
	else:
		return folder_path_directories


# TODO Update settings list more often
func rename_or_remove_collection_filesystem_folders(current_collection_name: String, new_collection_name: String, collection_or_thumb_path: String, rename_collection: bool, remove_collection_name: String) -> void:
	if DirAccess.dir_exists_absolute(collection_or_thumb_path.path_join(current_collection_name)):
		if rename_collection:
			if debug: print("collection_or_thumb_path.path_join(current_collection_name): ", collection_or_thumb_path.path_join(current_collection_name))
			if debug: print("collection_or_thumb_path.path_join(new_collection_name): ", collection_or_thumb_path.path_join(new_collection_name))
			var rename_collection_folder = DirAccess.rename_absolute(collection_or_thumb_path.path_join(current_collection_name), collection_or_thumb_path.path_join(new_collection_name))
			if rename_collection_folder != OK:
				printerr("Could not rename collection folder from ", current_collection_name, " to ", new_collection_name)
			#if collection_or_thumb_path == scenes_paths[2]: # Scan to update folder name in filesystem
				#EditorInterface.get_resource_filesystem().scan()
		else:# NOTE IF REMOVE_ABSOLUTE MUST FIRST REMOVE ALL FILES IN FOLDER
			# FIXME PUT LOCK ON DELETING "NEW COLLECTION" EITHER DON'T LIST OR RECREATE OR JUST PASS HERE, BUT LEAVES ITEMS IN NEW COLLECTION TAB
			await remove_files_in_folder_recursive(collection_or_thumb_path.path_join(remove_collection_name))
			# NOTE Giving false negative because file is removed
			#if DirAccess.remove_absolute(collection_or_thumb_path.path_join(remove_collection_name)) != OK:
				#printerr("Could not remove directory ", remove_collection_name, " from ", collection_or_thumb_path)
			DirAccess.remove_absolute(collection_or_thumb_path.path_join(remove_collection_name))

			# Remove the collection tab of removed collection if open in Scene Viewer
			var collection_tabs = sub_tab_container.get_children()
			for tab in collection_tabs:
				if tab.name == remove_collection_name:
					var tab_index = sub_tab_container.get_tab_idx_from_control(tab)
					on_tab_close_pressed(tab_index)

# FIXME DID NOT SEEM TO UPDATE FILESYSTEM COLLECTION WHEN IT WAS REMOVED STILL SHOWING BUT CAN NOT OPEN AND GET ERROR
		# Scan to update folder name in filesystem
		if debug: print("scanning filesystem to update removed collection folder: ", remove_collection_name)
		EditorInterface.get_resource_filesystem().scan()
		update_item_list_collections()



func remove_files_in_folder_recursive(collection_path: String) -> void:
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
					#if debug: print("full_path: ", full_path)
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
		if debug: print("the directory exists!!")
		return
	if not DirAccess.dir_exists_absolute(scene_folder_path):
		DirAccess.make_dir_recursive_absolute(scene_folder_path)


func _on_tab_name_line_edit_text_changed(new_text: String) -> void:
	sub_tab_container.set_tab_title(current_tab_index, new_text)
	#new_tab_name_text = new_text.strip_edges()
	new_collection_name = new_text.strip_edges()
	#if debug: print(new_text)


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

	elif sub_tab_container.get_tab_count() <= 2:
		for collection in get_or_rename_collections_in_tree("", "", false):
			if collection.name == "New Collection" and selected_tab_title != "New Collection":
				tab_bar.set_tab_close_display_policy(tab_bar.CLOSE_BUTTON_SHOW_NEVER)

	# Remove matching Sub Collection
	var sub_collection_node: Control = sub_tab_container.find_child(selected_tab_title, false, true)
	sub_collection_node.queue_free()



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







func _on_visibility_changed() -> void:
	modify_and_hide_line_edit(true)


	if sub_tab_container != null:
		sub_tab_container.add_theme_constant_override("side_margin", 29)
		v_sep_margin_container.show()
		dummy_button.custom_minimum_size = Vector2(0, 0)

	if await_start:
		await get_tree().create_timer(.001).timeout
		await_start = false
	
	
	var scene_view_children = sub_tab_container.get_children()
	if visible:
		for scene in scene_view_children:
			scene.set_process_mode(Node.PROCESS_MODE_INHERIT)
	else:
		for scene in scene_view_children:
			scene.set_process_mode(Node.PROCESS_MODE_DISABLED)

	#emit_signal("update_on_screen_buttons")


## FIXME NOTE: This operation is done also in main_base_tab.gd get_scene_buttons() and sub_collection_tab.gd ready()
#func connect_update_signal() -> void:
	#
	#var collection_tabs = sub_tab_container.get_children()
#
	#for tab in collection_tabs:
		##var scene_buttons = tab.find_child("HFlowContainer", true, false).get_children()
		#var scene_buttons: Array[Node] = tab.h_flow_container.get_children()
		##if debug: print("scene_buttons from main_collection_tab.gd: ", scene_buttons)
		#for scene_button in scene_buttons:
			#if scene_button is Button:
				#scene_button.update_favorites.connect(hide_scene)
			## NOTE Find how .bind is intended to work
			##scene_button.update_favorites.connect(hide_scene.bind(scene_button))
#
##if filters.has("heart"):
	#
##filter_buttons()
#
#func hide_scene(scene) -> void:
	##if debug: print("hiding button")
	## Hide button only when favorites filter is on and removed from favorites
	#if heart_texture_button.button_pressed:
		#scene.hide()










#func _on_sub_tab_bar_tab_changed(tab: int) -> void:
	#pass # Replace with function body.












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








func _on_item_list_hidden() -> void:
	if sub_tab_container != null:
		sub_tab_container.add_theme_constant_override("side_margin", 29)
	v_sep_margin_container.show()
	dummy_button.custom_minimum_size = Vector2(0, 0)



func _on_open_item_list_button_hidden() -> void:
	#add_item_list_tabs_button.set_focus_mode(Control.FOCUS_ALL)
	#add_item_list_tabs_button.grab_focus()
	#sub_tab_container.theme_override_constants.side_margin = 350
	sub_tab_container.add_theme_constant_override("side_margin", 335)
	v_sep_margin_container.hide()
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
