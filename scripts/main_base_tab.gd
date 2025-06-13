@tool
class_name MainBaseTab
extends Control

# CAUTION SEE LINE 122 LOOKING AT LATER I SEE THAT scroll_container.find_children("*", "Control", true, false) WILL ONLY RETURN THE HFLOWCONTAINER CHECK LATER WHY DID THIS? OR MAYBE MISTAKE AND REASON DOES NOT WORK WELL?


var debug = preload("uid://dfb5uhllrlnbf").new().run()
#var print_enabled: bool = false

#signal update_on_screen_buttons
signal change_current_filter_2d_3d
signal enable_panel_button_sizing
signal update_visible_buttons

@onready var settings = EditorInterface.get_editor_settings()
@onready var sub_tab_container: TabContainer = $VBoxContainer/SubTabContainer # Used only by Global and Shared tabs
#@onready var sub_tab_container: TabContainer = $VBoxContainer/SubTabMarginContainer/SubTabContainer

@onready var erase_texture_button: TextureButton = $VBoxContainer/HBoxContainer/EraseTextureButton
@onready var scene_search_line_edit: LineEdit = $VBoxContainer/HBoxContainer/SceneSearchLineEdit

# NOTE: main_collection_tab has dummy ScrollContainer and HFlowContainer nodes
#@onready var h_flow_container: HFlowContainer = $VBoxContainer/ScrollContainer/HFlowContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var h_flow_container: HFlowContainer = %HFlowContainer
#@onready var tag_panel: Control = %TagPanel


@onready var heart_texture_button: TextureButton = $VBoxContainer/HBoxContainer/HeartTextureButton
@onready var global_search_button: TextureButton = $VBoxContainer/HBoxContainer/GlobalSearchButton
@onready var filter_applied_warning: TextureRect = $VBoxContainer/HBoxContainer/FilterAppliedWarning

#@onready var multi_select_box_working_area: Control = $MultiSelectBoxWorkingArea
#@onready var multi_select_box_working_area: Node2D = %MultiSelectBoxWorkingArea
#@onready var multi_select_box_working_area: Panel = $MultiSelectBoxWorkingArea



const MULTI_SELECT_BOX = preload("uid://d3n1sql42sg7q")
# Filters
#var heart_filter_applied: bool = false
#var filter_2d_3d_applied: bool = false
#var folder_filter_applied: bool = false
#var search_filter_applied: bool = false

var filters: Array[String] = []
#var filters: Dictionary [String, Array] = {}

#var scene_buttons: Array[Node] = []
#var folder_filtered_scene_buttons: Array[Node] = []
#var filtered_scene_buttons: Array[Button] = [] # Filled from scene_viewer.gd

var heart_filtered_scene_buttons: Array[Button] = [] # Everything that was not a heart was filtered out and stored here
var heart_on: bool = false

var scene_buttons: Array[Node] = []
# Need to have dict that stores each subtab and it's filtered scene buttons
var tab_filtered_scene_buttons: Dictionary [String, Array] = {}
var tab_heart_filtered_scene_buttons: Dictionary [String, Array] = {}
var sub_tab_name: String = ""
var folder_project_scenes: Array[String] = []
#var last_text: String = ""
#var folder_filter_toggled_on: bool = false
var reset_text: bool = true
#var control_node_count: int = 0
var multi_select_box: Node2D
var theme_accent_color: Color



func _ready() -> void:
	#var p: = PrintDebug.new()
	
	#var debug_print_setting: String = "scene_snap_plugin/enable_plugin_debug_print_statements"
	## Set the print_enabled flag to match what is in settings
	#if settings.has_setting(debug_print_setting):
		#print_enabled = settings.get_setting(debug_print_setting)

	#apply_accent_color()
	settings.settings_changed.connect(apply_accent_color)
	# FIXME Why does this print doubles and both "ProjectScenes" and "Project Scenes"
	#if Settings.PrintState.ENABLED:
		#pass
	if debug: print("self.name: ", self.name)
	#collect_files_and_dirs("res://", true)
	# Load MultiSelecBox NOTE: For global and shared loaded under sub collection tabs
	if self.name == "ProjectScenes" or self.name == "Favorites":
		multi_select_box = MULTI_SELECT_BOX.instantiate()
		h_flow_container.add_child(multi_select_box)
		multi_select_box.set_owner(self)
		#multi_select_box.multi_select_box_state.connect(change_scene_load_state_on_hover)
		multi_select_box.multi_select_box_state.connect(func (state: bool) -> void:
				for button: Button in scene_buttons:
					if button:
						button.multi_select_box = state)

	erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
	scene_search_line_edit.set_right_icon(get_theme_icon(&"Search", &"EditorIcons"))
	############KEEP
	#global_search_button.set_texture_normal(get_theme_icon(&"Environment", &"EditorIcons"))
	############KEEP
	filter_applied_warning.set_texture(preload("res://addons/scene_snap/icons/StatusWarningRed.svg"))
	filter_applied_warning.set_tooltip_text("ACTIVE: Filters are applied to this tab's scenes.")
	#filter_applied_warning.set_texture(get_theme_icon(&"StatusWarning", &"EditorIcons"))
	

	#call_deferred("populate_filtered_scene_buttons")
	#await get_tree().create_timer(5).timeout
	#populate_filtered_scene_buttons() 
	##filtered_scene_buttons = scene_buttons

	call_deferred("connect_sub_tab_changed_signal")
	#await get_tree().create_timer(1).timeout # HACK Cannot filter main tab scenes when intially loading
	#call_deferred("get_scene_buttons")
	#get_scene_buttons()



	#await get_tree().create_timer(2).timeout
	# FIXME USE FOR THUMBNAIL SCALING WITH SCROLL WHEEL AS THAT SEEMS TO NOT ALWAYS WORK CORRECTLY
# CAUTION LOOKING AT LATER I SEE THAT scroll_container.find_children("*", "Control", true, false) WILL ONLY RETURN THE HFLOWCONTAINER CHECK LATER WHY DID THIS? OR MAYBE MISTAKE AND REASON DOES NOT WORK WELL?
	# TODO Maybe just add the get_buttons 
	var all_control_nodes_in_scroll_container: Array[Node] = scroll_container.find_children("*", "Control", true, false)
	for control: Control in all_control_nodes_in_scroll_container:

		control.mouse_entered.connect(append_control_entered.bind(control.name))
		control.mouse_exited.connect(erase_control_exited.bind(control.name))


func append_control_entered(control_name: String) -> void:
	multi_select_box.controls_with_mouse.append(control_name)


func erase_control_exited(control_name: String) -> void:
	multi_select_box.controls_with_mouse.erase(control_name)

## Load or do not load scene 3D preview based on if multi-select-box is active or not
func change_scene_load_state_on_hover(state: bool) -> void:
	for button: Button in scene_buttons:
		button.multi_select_box = state

# if array
# for button in array
# apply heart
# same for remove if array and heart pressed for button in array remove heart


func _on_heart_texture_button_toggled(toggled_on: bool) -> void:
	# Important for initializing scene_buttons if tab has not been changed after startup
	#if scene_buttons.size() <= 1: # 1 for Node2D MultiSelectBox
	if scene_buttons.is_empty():
		get_scene_buttons()
	# Clear all hearts
	if Input.is_key_pressed(KEY_SHIFT):
		if debug: print("clearing all heart buttons")
		for button: Button in scene_buttons.duplicate():

			if button and button.is_visible_in_tree():
				button.heart_texture_button.button_pressed = false
				
				if self.name == "Favorites":
					button.queue_free()
					scene_buttons.erase(button)
				else:
					self.heart_texture_button.button_pressed = false
					toggled_on = false

	if self.name == "Favorites":
		if heart_texture_button:
			heart_texture_button.set_tooltip_text("NOTE: Hold shift key and press to clear all favorites.")
		return

	if toggled_on:
		if not filters.has("heart"):
			filters.append("heart")
		heart_texture_button.set_tooltip_text("ACTIVE: Show only favorite scenes. NOTE: Hold shift key and press to clear all favorites.")
		filter_buttons()

	else:
		erase_filter("heart")
		heart_texture_button.set_tooltip_text("NOT ACTIVE: Show only favorite scenes. NOTE: Hold shift key and press to clear all favorites.")
		filter_buttons()




func _on_filter_2d_3d_button_pressed() -> void: # FIXME Anyway to get state param from pressed?
	# Important for initializing scene_buttons if tab has not been changed after startup
	#if scene_buttons.size() <= 1: # 1 for Node2D MultiSelectBox
	if scene_buttons.is_empty():
		get_scene_buttons()
	emit_signal("change_current_filter_2d_3d", true)
	filter_buttons()


#func wait_ready() -> bool:
	#var wait_time: int = 0
	#while filtered_scene_buttons.size() == 0:
		#await get_tree().process_frame
		#wait_time += 1
#
		#if wait_time >= 60:
			#return false
#
	#return true




func _on_filter_by_file_system_folder_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if not filters.has("folder"): # This will trigger scene_viewer.gd to refresh the project scenes in the _physics_process
			filters.append("folder")
		# Wait for filtered_scene_buttons to populate from scene_viewer.gd
		#await wait_ready()

		get_scene_buttons()
		#filter_buttons()
#
		## Is not triggered by filter_buttons() when folders with no scenes, so also added here.
		#filter_applied_warning.show()

	else:
		#filtered_scene_buttons.clear()
		erase_filter("folder")
		get_scene_buttons()
		#filter_buttons()



func erase_filter(filter_name: String) -> void:
	filters.erase(filter_name)
	filters_dict.erase(filter_name)


func _on_erase_texture_button_pressed() -> void:
	scene_search_line_edit.clear()
	erase_filter("text")
	#filters.erase("text")
	#filters_dict.erase("text")
	
	#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
	
	# Reset texture button icon to non blue
	erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
	#apply_filters()
	if debug: print("filters_dict.keys(): ", filters_dict.keys())
	if debug: print("if filters_dict.keys().is_empty():: ", filters_dict.keys().is_empty())
	#call_deferred("filter_buttons")
	
	filter_buttons()

	#emit_signal("update_on_screen_buttons")




func _on_scene_search_line_edit_text_changed(new_text: String) -> void:
	# Important for initializing scene_buttons if tab has not been changed after startup
	#if scene_buttons.size() <= 1: # 1 for Node2D MultiSelectBox
	if scene_buttons.is_empty():
		get_scene_buttons()
	if new_text != "":
		reset_text = true # Reset flag
		apply_accent_color()
		filter_buttons()

	elif reset_text:
		reset_text = false
		erase_filter("text")
		erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
		erase_texture_button.set_self_modulate(Color(1, 1, 1, 1))
		filter_buttons()


func apply_accent_color() -> void:
	if settings.has_setting("interface/theme/accent_color"):
		theme_accent_color = settings.get_setting("interface/theme/accent_color")
		erase_texture_button.set_self_modulate(theme_accent_color)






	#if scene_search_line_edit.text != "":
		#erase_texture_button.set_texture_normal(preload("res://addons/scene_snap/icons/ClearFilter.svg"))
		##reset_text = true # Reset flag
		###if new_text != last_text:
			###last_text = new_text
			###if not filters.has("text"):
				###filters.append("text")
			####if not filters_dict.keys().has("text"):
				####filters_dict["text"] = text_filter(scene_buttons, new_text)
				####erase_texture_button.set_texture_normal(preload("res://addons/scene_snap/icons/ClearFilter.svg"))
			####apply_filters()
		##filter_buttons()
##
	#else:
		#erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
		##erase_filter("text")
		###filters.erase("text")
		###filters_dict.erase("text")
		##if reset_text:
			##reset_text = false
			###erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
		##filter_buttons()







#func apply_filters() -> void:
	#if debug: print("filters: ", filters)
	#if filters != []:
#
#
		#if self.name == "Project Scenes":
			#if folder_filter_toggled_on:
				#if not filters.has("folder"):
					#filters.append("folder")
			#for button: Button in scene_buttons:
				##if filters.has("folder"):
				#filter_tree(button) 
					#
					#
		#else:
			#filters.erase("folder")
			#for button: Button in scene_buttons:
				#
				#filter_tree(button) 
					#
				##pass
#
				##filters["folder"].append(button)
##
			##if filters.has("heart"):
				##if button.heart_texture_button.button_pressed:
					##button.show()
					##filters["heart"].append(button)
				##else:
					##button.hide()
#
			##if filters.has("heart"):
				##if filters["folder"] != []:
				##if filters["folder"].has(button)
				##
			##else:
				##if button.heart_texture_button.button_pressed:
					##button.show()
				##else:
					##button.hide()
#
#
	#else:
		#for button: Button in scene_buttons:
			#button.show()


#var filters_dict: Dictionary [String, Array] = {}
#
## TEST
#var filtered_buttons_to_show : Array[Node] = []
## var filter filterd scenes
#func filter_buttons() -> void:
	#filters_dict.clear()
	#filtered_buttons_to_show.clear()
#
	#if filtered_scene_buttons != []:
		#filters_dict["folder"] = filtered_scene_buttons
	#if filters.has("heart"):
		#filters_dict["heart"] = heart_filter(scene_buttons)
	#if last_text != "":
		#filters_dict["text"] = text_filter(scene_buttons, last_text)
	#
	## ORIGINAL
	##if debug: print("filters_dict.keys(): ", filters_dict.keys())
	##for filter_name in filters_dict.keys():
		##for button in scene_buttons:
			##if filters_dict[filter_name].has(button):
				##if filtered_buttons_to_show == []:
					##filtered_buttons_to_show.append(button)
				##else:
					##if filtered_buttons_to_show.has(button):
						##pass
					##else:
						##filtered_buttons_to_show.erase(button)
#
	## Start with all buttons and progressively filter them
	#filtered_buttons_to_show = scene_buttons.duplicate()
#
	#if debug: print("filters_dict.keys(): ", filters_dict.keys())
	#for filter_name in filters_dict.keys():
		#var filter_buttons = filters_dict[filter_name]
		#
		#for button in scene_buttons:
			#if filters_dict[filter_name].has(button):
				#if filtered_buttons_to_show == []:
					#filtered_buttons_to_show.append(button)
				#else:
					#if filtered_buttons_to_show.has(button):
						#pass
					#else:
						#filtered_buttons_to_show.erase(button)
#
#
#
#
#
#
						#
						#
	#if filters == []:
		#filtered_buttons_to_show = scene_buttons
	#
	#if debug: print("THESE SHOULD BE THE BUTTONS THAT ARE VISIBLE ON THE SCREEN: ", filtered_buttons_to_show.size())

## TEST

var filters_dict: Dictionary[String, Array] = {}
var filtered_buttons_to_show: Array[Node] = []

## Apply the selected filters in the UI to the scenes within each "MainTab"
# FIXME if tab is Favorites and removed must remove from favorites scene_buttons array
func filter_buttons() -> void:
	#if debug: print("SCENE BUTTONS: ", scene_buttons)
	#var project_buttons: Array[Node] = h_flow_container.get_children()
	#project_buttons = project_buttons.filter(func(button) -> bool: return button is Button)
	#for button in project_buttons:
		#if debug: print("project_buttons: ", button.scene_full_path)
		# Filter against selected folders

	filters_dict.clear()
	filtered_buttons_to_show.clear()
	# Important for initializing scene_buttons if tab has not been changed after startup
	#if scene_buttons.size() <= 1:
		#get_scene_buttons()


	## Add filters to the dictionary
	#if filtered_scene_buttons != []:
		#if debug: print("filtered_scene_buttons: ", filtered_scene_buttons)
		#filters_dict["folder"] = filtered_scene_buttons


	# FIXME IF FILES MOVED BREAKS SO NEED RESCAN OF FILES OR SIMPLY UPDATE SCENE_FULL_PATH OF BUTTONS WHEN MOVED
	if filters.has("folder"):
		filters_dict["folder"] = folder_filter(scene_buttons)


	if filters.has("heart"):
		filters_dict["heart"] = heart_filter(scene_buttons)
	if scene_search_line_edit.text != "":
		filters_dict["text"] = text_filter(scene_buttons, scene_search_line_edit.text)
		if debug: print(filters_dict["text"])

	#if debug: print("this is being processed")
	#if debug: print("filters_dict keys: ", filters_dict.keys())
	if filters_dict.keys().is_empty():
		filter_applied_warning.hide()
		for button: Button in scene_buttons:
			if button: # Favorites will free buttons, so will error without check.
				button.show()
			#elif button and button is Node2D: # Do not hide MultSelectBox
				#button.show()
		
		emit_signal("update_visible_buttons")
		return

	self.filter_applied_warning.show()
	# Start with all buttons and progressively filter them
	filtered_buttons_to_show = scene_buttons.duplicate()

	for filter_name in filters_dict.keys():
		var filter_values = filters_dict[filter_name]
		# Retain only buttons that are in both filtered_buttons_to_show and the current filter
		filtered_buttons_to_show = filtered_buttons_to_show.filter(func(button) -> bool: return filter_values.has(button))

	for button: Button in scene_buttons:
		if button and filtered_buttons_to_show.has(button):
			button.show()
		#elif button and button is Node2D:
			#button.show()
		else: # Remove favorites buttons here?
			button.hide()

	emit_signal("update_visible_buttons")










#func filter_tree(button: Node) -> void:
	#if filtered_scene_buttons != []: # If folder filter on this will have items
		#if filters.has("heart"):
			#if heart_filter(filtered_scene_buttons).has(button):
				#button.show()
			#else:
				#button.hide()
#
		#else: # Revert back to just showing filtered_scene_buttons
			#if filtered_scene_buttons.has(button):
				#button.show()
			#else:
				#button.hide()
			#
	#else: # No "folder" filter
		#if filters.has("heart"): # No "folder" filter but "heart" filter
			#var buttons_with_heart: Array[Node] = heart_filter(scene_buttons)
			#if buttons_with_heart.has(button):
				#button.show()
			#else:
				#button.hide()
		#
		#else: # Revert back to just showing all scene_buttons
			#button.show()
#
			#
		##if debug: print("heart_filter(filtered_scene_buttons): ", heart_filter(filtered_scene_buttons))
		##if heart_filter(filtered_scene_buttons).has(button):
			##button.show()
		##else:
			##button.hide()
#
#
#
#
		##button.show()
		##filters["heart"].append(button)
	##else:
		##button.hide()




	# 1 Folder
	# 2 Heart
	# 3 2D/3D
	#4 text


#region Filter logic

func folder_filter(buttons_to_filter: Array[Node]) -> Array[Button]:
	var filtered_buttons: Array[Button] = []
	var current_selected_directory: String = EditorInterface.get_current_directory()
	
	#var project_buttons: Array[Node] = h_flow_container.get_children()
	#project_buttons = project_buttons.filter(func(button) -> bool: return button is Button) # Filter out Node2D BoxSelection
	#for project_button: Button in project_buttons:
		#if project_button.scene_full_path.contains(current_selected_directory):
			#filtered_buttons.append(project_button)

	for button: Button in buttons_to_filter:
		if button.scene_full_path.contains(current_selected_directory):
			filtered_buttons.append(button)



		#if debug: print("project_buttons: ", project_button.scene_full_path)
	
	#
	#for button: Button in buttons_to_filter:
		#
		#if button and button.heart_texture_button.button_pressed:
			#filtered_buttons.append(button)

	return filtered_buttons



func heart_filter(buttons_to_filter: Array[Node]) -> Array[Button]:
	var filtered_buttons: Array[Button] = []
	for button: Button in buttons_to_filter:
		if button and button.heart_texture_button.button_pressed:
			filtered_buttons.append(button)

	return filtered_buttons


func filter_2d_3d(buttons_to_filter: Array[Node]) -> Array[Button]:
	var filtered_buttons: Array[Button] = []
	for button: Button in buttons_to_filter:
		if button:
			pass
		# Filter logic here (maybe finding if has scene has meshinstance3d)

	return filtered_buttons

# FIXME Further Tweak 
func text_filter(buttons_to_filter: Array[Node], new_text: String) -> Array[Button]:
	if debug: print("new_text: ", new_text)
	if debug: print("buttons_to_filter: ", buttons_to_filter)
	var filtered_buttons: Array[Button] = []
	for button: Button in buttons_to_filter:
		if button and new_text.to_lower() != "":
			var threshold = 0 # NOTE Currently turned off
			#if levenshtein(new_text, button.name.to_lower()) <= threshold:
				#filtered_buttons.append(button)
			
			if button.name.to_lower().contains(new_text.to_lower()) or levenshtein_distance(new_text, button.name.to_lower()) <= threshold:
				filtered_buttons.append(button)
			# FIXME Add more granular searching with button toggle magnifier with little icon with? 
			# NAME ONLY | SHARED TAGS | GLOBAL TAGS | TAGS ONLY | ALL If shared tags disabled NAME ONLY | TAGS ONLY | ALL 
			# If shared in editor settings enabled and toggle filter:

			for shared_tag: String in button.shared_tags:
				if shared_tag.contains(new_text.to_lower()) or levenshtein_distance(new_text, shared_tag.to_lower()) <= threshold:
					filtered_buttons.append(button)


			for global_tag: String in button.global_tags:
				if global_tag.contains(new_text.to_lower()) or levenshtein_distance(new_text, global_tag.to_lower()) <= threshold:
					filtered_buttons.append(button)

			#if button.shared_tags.has(new_text.to_lower()):
				#filtered_buttons.append(button)
			#if button.global_tags.has(new_text.to_lower()):
				#filtered_buttons.append(button)

	return filtered_buttons

#endregion

# Function to calculate the Levenshtein distance between two strings
func levenshtein(a: String, b: String) -> int:
	var len_a = a.length()
	var len_b = b.length()
	var matrix = []

	# Initialize the first row of the matrix
	for i in range(len_a + 1):
		matrix.append([i])

	# Initialize the rest of the matrix
	for i in range(len_a + 1):
		for j in range(1, len_b + 1):
			if i == 0:
				matrix[i].append(j)
			else:
				var cost = 0 if a[i - 1] == b[j - 1] else 1
				matrix[i].append(min(matrix[i - 1][j] + 1,  # Deletion
					matrix[i][j - 1] + 1,  # Insertion
					matrix[i - 1][j - 1] + cost))  # Substitution

	return matrix[len_a][len_b]

# Reference:  https://www.reddit.com/r/godot/comments/11fndr6/godot_4_trivia_game_accept_orthographic_error/ (erik90mx)
func levenshtein_distance(a: String, b: String) -> int:
	# Create an empty matrix with the dimensions of the lengths of the strings plus one
	var matrix = []
	for i in range(len(a) + 1):
		matrix.append([])
		for j in range(len(b) + 1):
			matrix[i].append(0)

	# Initialize the first row and column with the indices of the strings
	for i in range(len(a) + 1):
		matrix[i][0] = i
	for j in range(len(b) + 1):
		matrix[0][j] = j

	# Fill the rest of the matrix with the minimum values of the possible operations
	for i in range(1, len(a) + 1):
		for j in range(1, len(b) + 1):
			var cost
			# If the characters are equal, there is no additional cost
			if a[i - 1] == b[j - 1]:
				cost = 0
			else:
				cost = 1
			# The value of the cell is the minimum between deleting, inserting or replacing the character
			matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)

	# The last value of the matrix is ​​the Levenshtein distance between the two strings
	return matrix[len(a)][len(b)]




func connect_sub_tab_changed_signal() -> void:
	if self.name != "Project Scenes" and self.name != "Favorites":
		self.selected_sub_tab_changed.connect(func (tab: int) -> void: get_scene_buttons())


# NOTE: Called from scene_viewer.gd when Main Tab changed on sub_tab_changed_signal and when scene_buttons empty when filtering
func get_scene_buttons() -> void:
	#if debug: print("getting scene buttons")
	scene_buttons = []

	if self.name == "Project Scenes" or self.name == "Favorites":
		scene_buttons = h_flow_container.get_children()

	# FIXME Does not get sub_tab are intial editor loading
	else: # NOTE: Updates to current sub tab on connect_sub_tab_changed_signal() above
		var sub_tab: Control = sub_tab_container.get_current_tab_control()
		if sub_tab:
			scene_buttons = sub_tab.h_flow_container.get_children()
			if debug: print("scene_buttons: ", scene_buttons)


	# filter out Node2D MultiSelectBox here so (button is Button) not required everywhere used
	if scene_buttons:
		scene_buttons = scene_buttons.filter(func(button) -> bool: return button is Button)

	# Connect heart removed signal to apply filter and remove button from visible
	for button: Button in scene_buttons:
		button.main_collection_tab_parent = self.name
		if button:
			# Connect back to when the heart button is pressed in "Favorites" to remove from scene_buttons array and remove the button
			button.remove_favorite.connect(func(scene_full_path: String, scene_view_button: Button) -> void:
					#if debug: print("self.name: ", self.name)
					if self.name == "Favorites":
						if debug: print("clearing from favorites")
						scene_view_button.queue_free()
						scene_buttons.erase(scene_view_button)
					else: # Hide button from view if removed from favorites and favorite filter is active
						if debug: print("remove favorite from Favorites scene_buttons")
						#if debug: print("scene_buttons: ", scene_buttons)
						if filters.has("heart"):
							scene_view_button.hide())

	filter_buttons()


## NOTE Still issue with freed object collection favorite item change to favorite change back to collection and unfavorite switch back to favorite get error
#func _physics_process(delta: float) -> void:
	##if debug: print("scene_buttons: ", scene_buttons)
	##filter_buttons()
	#if self.name == "Favorites":
		##scene_buttons.clear()
		#if debug: print("scene_buttons: ", scene_buttons)





#func update_visible_scene_buttons() -> void:
	#for button: Button in scene_buttons:
		#if self.name == "Project Scenes" or self.name == "Favorites":
			#if tab_filtered_scene_buttons[self.name].has(button):
				#button.show()
			#else:
				#button.hide()
		#else:
			#if tab_filtered_scene_buttons[sub_tab_name].has(button):
				#button.show()
			#else:
				#button.hide()


#func _on_heart_texture_button_toggled(toggled_on: bool) -> void:
	## NOTE FIXME add all tabs into dict????
	##sub_tab_filtered_scene_buttons[sub_tab_container.get_current_tab_control().name] = 
	#if debug: print("heart filter toggled")
	##if debug: print("get_scene_buttons(): ", get_scene_buttons().size())
	## Restrict filtered_scene_buttons further to only heart buttons for 
	## other applied filters. Example: specific folder with heart and text filter
	#if toggled_on: # Iterate on duplicate because will be editing filtered_scene_buttons
		##for button: Node in filtered_scene_buttons.duplicate():
		#for button: Button in scene_buttons:
			#if not button.heart_texture_button.button_pressed:
				##button.hide()
				## Store scene_buttons that will be removed then remove them
				##if not heart_filtered_scene_buttons.has(button):
					##heart_filtered_scene_buttons.append(button)
				#if self.name == "Project Scenes" or self.name == "Favorites":
					#if not tab_heart_filtered_scene_buttons[self.name].has(button):
						#tab_heart_filtered_scene_buttons[self.name].append(button)
					#tab_filtered_scene_buttons[self.name].erase(button)
				#else:
					#if not tab_heart_filtered_scene_buttons[sub_tab_name].has(button):
						#tab_heart_filtered_scene_buttons[sub_tab_name].append(button)
					#tab_filtered_scene_buttons[sub_tab_name].erase(button)
				##filtered_scene_buttons.erase(button)
				#
			##else:
				##button.show()
		#update_visible_scene_buttons()
#
	#else: # Add back in buttons before heart filter removed them
		#if self.name == "Project Scenes" or self.name == "Favorites":
			#tab_filtered_scene_buttons[self.name].append_array(tab_heart_filtered_scene_buttons[self.name])
			#tab_heart_filtered_scene_buttons[self.name].clear()
		#else:
			#tab_filtered_scene_buttons[sub_tab_name].append_array(tab_heart_filtered_scene_buttons[sub_tab_name])
			#tab_heart_filtered_scene_buttons[sub_tab_name].clear()
		##filtered_scene_buttons.append_array(heart_filtered_scene_buttons)
		##heart_filtered_scene_buttons.clear()
		##for button: Node in filtered_scene_buttons:
			##button.show()
		#update_visible_scene_buttons()
#
#
#
#
#
#
#
	## Restrict filtered_scene_buttons further to only heart buttons for 
	## other applied filters. Example: specific folder with heart and text filter
	#if toggled_on: # Iterate on duplicate because will be editing filtered_scene_buttons
		#for button: Node in filtered_scene_buttons.duplicate():
			#if not button.heart_texture_button.button_pressed:
				#button.hide()
				## Store scene_buttons that will be removed then remove them
				#if not heart_filtered_scene_buttons.has(button):
					#heart_filtered_scene_buttons.append(button)
				#filtered_scene_buttons.erase(button)
			#else:
				#button.show()
#
	#else: # Add back in buttons before heart filter removed them
		#filtered_scene_buttons.append_array(heart_filtered_scene_buttons)
		#heart_filtered_scene_buttons.clear()
		#for button: Node in filtered_scene_buttons:
			#button.show()
#
#
#
#
	##heart_filtered_scene_buttons.clear()
	#
	## Clear all hearts
	#if Input.is_key_pressed(KEY_SHIFT):
		#for button: Node in get_scene_buttons():
			#button.heart_texture_button.button_pressed = false
			#if self.name != "Favorites": # Keep the Favorites Tab heart red even when pressed
				#self.heart_texture_button.button_pressed = false
				#toggled_on = false
#
#
	#for button: Node in filtered_scene_buttons:
#
		#if self.name != "Favorites":
			#if toggled_on:
				#heart_texture_button.set_tooltip_text("ACTIVE: Show only favorite scenes. NOTE: Hold shift key and press to clear all favorites.")
				#if scene_search_line_edit.text != "":
					#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
				#heart_on = true
#
				#if button.heart_texture_button.button_pressed:
					#button.show()
#
				#else:
					#button.hide()
#
					## Store scene_buttons that will be removed
					#if not heart_filtered_scene_buttons.has(button):
						#heart_filtered_scene_buttons.append(button)
#
				##if filtered_scene_buttons.has(button) and button.heart_texture_button.button_pressed:
					##button.show()
##
				##else:
					##button.hide()
#
#
#
			#else:
				#heart_texture_button.set_tooltip_text("NOT ACTIVE: Show only favorite scenes. NOTE: Hold shift key and press to clear all favorites.")
				#if scene_search_line_edit.text != "":
					#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
				#heart_on = false
#
				##if filtered_scene_buttons == []:
					##button.show()
##
				##elif filtered_scene_buttons.has(button):
				#button.show()
#
				### Remove from filtered scenes
				##if button.heart_texture_button.button_pressed:# and filtered_scene_buttons.has(button):
					##filtered_scene_buttons.erase(button)
#
#
#
#
#
#
		#else:
			#heart_texture_button.set_tooltip_text("NOTE: Hold shift key and press to clear all favorites.")
#
	#
	## Restrict filtered_scene_buttons further to only heart buttons for 
	## other applied filters. Example: specific folder with heart and text filter
	#if toggled_on:
		#if debug: print("filtering out all but hearts")
		##if filtered_scene_buttons != []:
		##var buttons_to_remove: Array[Node] = filtered_scene_buttons
		#for button: Node in filtered_scene_buttons.duplicate():
			#if not button.heart_texture_button.button_pressed:
				#button.hide()
				## Store scene_buttons that will be removed
				#if not heart_filtered_scene_buttons.has(button):
					#heart_filtered_scene_buttons.append(button)
				#filtered_scene_buttons.erase(button)
			#else:
				#button.show()
		#
					#
	#else: # Add back in buttons before heart filter removed them
		#filtered_scene_buttons.append_array(heart_filtered_scene_buttons)
		#heart_filtered_scene_buttons.clear()
		#
		#filtered_scene_buttons.append_array(heart_filtered_scene_buttons)
#
	##emit_signal("update_on_screen_buttons")


#func _on_filter_2d_3d_button_pressed() -> void:
	#emit_signal("change_current_filter_2d_3d", true)
#
#
#func _on_erase_texture_button_pressed() -> void:
	#scene_search_line_edit.clear()
	#filters.erase("text")
	#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
#
	##emit_signal("update_on_screen_buttons")
#
#
#func _on_scene_search_line_edit_text_changed(new_text: String) -> void:
	#pass
	#var scene_buttons: Array[Node]
	#
	#if filtered_scene_buttons != []:
		#scene_buttons = filtered_scene_buttons
		#text_filter(scene_buttons, new_text)
#
	#else:
		#if self.name == "Project Scenes" or self.name == "Favorites":
			## FIXME must get filtered_buttons to apply multiple filters on top of each other
			#scene_buttons = h_flow_container.get_children()
#
		#else:
			#var collection_tabs = sub_tab_container.get_children()
			#for tab in collection_tabs:
				#scene_buttons = tab.h_flow_container.get_children()
				#
		#text_filter(scene_buttons, new_text)



# either store state of folder items or toggle off and back on folder filter every text entry
#var filtered_scene_buttons: Array[Node] = []

#func text_filter(scene_buttons: Array[Node], new_text: String) -> void:
	##if debug: print("new_text.to_lower(): ", new_text)
	##if debug: print("scene_buttons.size: ", scene_buttons.size())
	#if filtered_scene_buttons == []:
		#for button in scene_buttons:
			##if filters == []:
			#if new_text.to_lower() != "" and not button.name.to_lower().contains(new_text.to_lower()):
				#button.hide()
			#else:
				#button.show()
#
			##else:
				##if button.is_visible():
					##filtered_scene_buttons.append(button)
	#else:
		#for button in filtered_scene_buttons:
			#if new_text.to_lower() != "" and not button.name.to_lower().contains(new_text.to_lower()):
				#button.hide()
			#else:
				#button.show()
#
			#
			##_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
			#
			##if self.name == "Project Scenes":
				##if heart_on and not child.heart_texture_button.button_pressed:
					##child.hide()
				##else:
					##child.show()
			##else:
				##child.show()
	##emit_signal("update_on_screen_buttons")


func _on_mouse_entered() -> void:
	emit_signal("enable_panel_button_sizing")


var within_scroll_container: bool = false


func _on_scroll_container_mouse_entered() -> void:
	within_scroll_container = true
	if debug: print("scroll container mouse entered")
	pass # Replace with function body.


func _on_scroll_container_mouse_exited() -> void:
	within_scroll_container = false
	if debug: print("scroll container mouse exited")
	pass # Replace with function body.



#func _on_multi_select_box_working_area_mouse_entered() -> void:
	#if debug: print("mouse entered")
	#pass # Replace with function body.
#
#
#func _on_multi_select_box_working_area_mouse_exited() -> void:
	#if debug: print("mouse exited")
	#pass # Replace with function body.


#
##func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
	##if debug: print(scene_search_line_edit.get_text())
	##if scene_search_line_edit.get_text() == str(""):
		##if debug: print("we have empty text")
#
	##if debug: print("filters_dict.keys(): ", filters_dict.keys())
	##if debug: print("filters: ", filters)
	##if self.name == "Project Scenes":
		###if debug: print("h_flow_container.get_children(): ", h_flow_container.get_children().size())
		##
		##if debug: print("filtered_scene_buttons: ", filtered_scene_buttons.size())
	##if debug: print("filters: ", filters)
	##if debug: print("scene_search_line_edit.text: ", scene_search_line_edit.text)
	##if scene_search_line_edit.text != "":
		##erase_texture_button.set_texture_normal(preload("res://addons/scene_snap/icons/ClearFilter.svg"))
	#_on_scene_search_line_edit_text_changed(scene_search_line_edit.text)
		##filter_buttons()
	##else:
		##erase_filter("text")
		##erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
		##filter_buttons()
