@tool
extends MainBaseTab


signal allow_one_time_scan
signal show_all_scenes


#@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer # Required for scroll focus
#@onready var scroll_container: ScrollContainer = $VBoxContainer/ButtonsTagsHBox/ScrollContainer # Required for scroll focus
#@onready var scroll_container: ScrollContainer = $VBoxContainer/ButtonsTagsHBox/HSplitContainer/ScrollContainer
#@onready var tag_panel: Control = $VBoxContainer/ButtonsTagsHBox/HSplitContainer/TagPanel

@onready var filter_by_file_system_folder_button: Button = $VBoxContainer/HBoxContainer/FilterByFileSystemFolderButton
@onready var filter_2d_3d_button: Button = %Filter2D3DButton
# FIXME REMOVE AND CONVERT OVER TO MULTI MESH VIEWER AND PUT AT BOTTOM 
@onready var tag_panel: Control = %TagPanel

#@onready var node_2d: Node2D = $Node2D


## NOTE Move to mainbasetab class for all
#@onready var multi_select_box_working_area: Control = $MultiSelectBoxWorkingArea


#var folder_filter_applied: bool = false
#var filters: Array[String] = []
#var filter_by_file_system_folder: bool = false

#func _ready() -> void:
	#if debug: print("node_2d rect2: ", node_2d.get_rect())
	#if debug: print("multi_select_box_working_area rect2: ", multi_select_box_working_area.get_rect())

#func connect_scene_focused_signal() -> void:
	#var scene_buttons: Array[Node] = h_flow_container.get_children()
	#for scene_button in scene_buttons:
		#scene_button.update_favorites.connect(hide_scene)
		## Connect to ScrollContainer to maintain follow focus that breaks when changing to popup window and back
		#scene_button.scene_focused.connect(func (scene_full_path: String, selected_scene: Button) -> void: scroll_container.ensure_control_visible(selected_scene))

#var last_text: String = ""
#
#func _on_scene_search_line_edit_text_changed(new_text: String) -> void:
	#super(new_text)
#
	#if scene_search_line_edit.text != "":
		#reset_text = true # Reset flag
		#if new_text != last_text:
			#last_text = new_text
			#if not filters.has("text"):
				#filters.append("text")
			###if not filters_dict.keys().has("text"):
				###filters_dict["text"] = text_filter(scene_buttons, new_text)
				###erase_texture_button.set_texture_normal(preload("res://addons/scene_snap/icons/ClearFilter.svg"))
			###apply_filters()
			#filter_buttons()
#
	#else:
		#erase_filter("text")
#
		#if reset_text:
			#reset_text = false
			##erase_texture_button.set_texture_normal(get_theme_icon(&"Clear", &"EditorIcons"))
		#filter_buttons()




func hide_scene(scene) -> void:
	if debug: print(scene)
	# Hide button only when favorites filter is on and removed from favorites
	if heart_texture_button.button_pressed:
		scene.hide()


func _on_filter_by_file_system_folder_button_toggled(toggled_on: bool) -> void:
	super(toggled_on) # Connect signal up to MainBaseTab func with same name
	#filtered_scene_buttons.clear()
	if toggled_on:
		filter_by_file_system_folder_button.set_tooltip_text("ACTIVE: Show scenes by selected file system folder. NOTE: Directories that contain 'addon' are excluded.")
		#folder_filter_applied = true
		#filter_by_file_system_folder = true
		#filters.append("folder")
		#filter_applied_warning.show()
		
		emit_signal("allow_one_time_scan")
	else:
		filter_by_file_system_folder_button.set_tooltip_text("NOT ACTIVE: Show scenes by selected file system folder. NOTE: Directories that contain 'addon' are excluded.")
		#folder_filter_applied = false
		#filter_by_file_system_folder = false
		#filters.erase("folder")
		#if filters == []:
			#filter_applied_warning.hide()

		## CAUTION DID I REPLACE THIS WITH filter_buttons() IN main_base_tab.gd?
		#emit_signal("show_all_scenes")





func _on_global_search_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if debug: print("enable global")
	else:
		if debug: print("disable global")


#func _on_multi_select_box_working_area_mouse_entered() -> void:
	#if debug: print("mouse entered")
	#pass # Replace with function body.
#
#
#func _on_multi_select_box_working_area_mouse_exited() -> void:
	#if debug: print("mouse exited")
	#pass # Replace with function body.
