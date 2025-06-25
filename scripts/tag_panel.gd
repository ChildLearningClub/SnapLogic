@tool
extends Control


# TODO Lose tag imput text focus when mouse leaves area issue when back in 3dviewport and Q typed to start scene_preview getting entered in tag text input box


var debug = preload("res://addons/scene_snap/scripts/print_debug.gd").new().run()
#var scene_data_cache: SceneDataCache = SceneDataCache.new()

signal tag_added_or_removed(scene_view: Button) ## Signal when tag added or removed to scene_view.gd
#signal update_scene_mesh_tags(scene_view: Button, shared_tags: Array[String])

#const TAG = preload("res://addons/scene_snap/plugin_scenes/tag.tscn")
const TAG = preload("res://addons/scene_snap/plugin_scenes/tag.tscn")

const TAG_PANEL_TEXTURE_BUTTON = preload("res://addons/scene_snap/plugin_scenes/tag_panel_texture_button.tscn")

#@onready var grid_container: GridContainer = $ScrollContainer/GridContainer


#@onready var scene_info_label: Label = $VBoxContainer/SceneInfoLabel



#@onready var grid_container_shared_tags: GridContainer = $VFlowContainer/GridContainerSharedTags
#@onready var grid_container_global_tags: GridContainer = $HFlowContainer/ScrollContainer2/GridContainerGlobalTags
#@onready var h_flow_container: HFlowContainer = $HFlowContainer/HFlowContainer

#@onready var flow_scene_views: HFlowContainer = $VBoxContainer/HFlowSceneViews
@onready var flow_scene_views: FlowContainer = $ScrollContainer/VBoxContainer/FlowSceneViews


#@onready var flow_shared_tags: FlowContainer = $VBoxContainer/FlowSharedTags
#@onready var flow_global_tags: FlowContainer = $VBoxContainer/FlowGlobalTags

@onready var flow_shared_tags: FlowContainer = $ScrollContainer/VBoxContainer/FlowSharedTags
@onready var flow_global_tags: FlowContainer = $ScrollContainer/VBoxContainer/FlowGlobalTags




#@onready var h_box_container: HBoxContainer = $HFlowContainer/HBoxContainer
#@onready var scene_views_grid_container: GridContainer = $HFlowContainer/SceneViewsGridContainer


#@onready var button_shared_tags: Button = $VBoxContainer/HFlowSharedTags/ButtonSharedTags
#@onready var button_global_tags: Button = $VBoxContainer/HFlowGlobalTags/ButtonGlobalTags
@onready var button_shared_tags: Button = $ScrollContainer/VBoxContainer/FlowSharedTags/ButtonSharedTags
@onready var button_global_tags: Button = $ScrollContainer/VBoxContainer/FlowGlobalTags/ButtonGlobalTags

@onready var label_shared_tags: RichTextLabel = $ScrollContainer/VBoxContainer/LabelSharedTags
@onready var h_separator: HSeparator = $ScrollContainer/VBoxContainer/HSeparator
@onready var h_separator_2: HSeparator = $ScrollContainer/VBoxContainer/HSeparator2




# Passed in from scene_viewer.gd toggle_current_main_tab_tag_panel()
var scene_view: Button = null 
#var selected_buttons: Array[Button] = []
var selected_buttons: Array[Node] = []
var sharing_disabled: bool = false

var settings = EditorInterface.get_editor_settings()

func _ready() -> void:
	##Create duplicate scene_data_cache so that original resource file can be written to
	#scene_data_cache = ResourceLoader.load("uid://3as6dllcbl36")

	# Get the tags from the individual scenes mesh metadata and display them
	# if multiple buttons selected get them the tag button pressed is one of them 
	await get_tree().process_frame # Allow time for selected_buttons to be filled from scene_viewer.gd

	find_matching_tags_and_selected_count()

	if sharing_disabled:
		label_shared_tags.hide()
		h_separator.hide()
		flow_shared_tags.hide()
		button_shared_tags.hide()
		h_separator_2.hide()

	else:
		label_shared_tags.show()
		h_separator.show()
		flow_shared_tags.show()
		button_shared_tags.show()
		h_separator_2.show()



func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		print("enter key pressed")


## Add a new tag to the Tag Panel under Shared Tags
func _on_button_shared_tags_pressed() -> void:
	var tag_text: String = ""
	add_tag(flow_shared_tags, tag_text)


## Add a new tag to the Tag Panel under Global Tags
func _on_button_global_tags_pressed() -> void:
	var tag_text: String = ""
	add_tag(flow_global_tags, tag_text)


#func add_tag(grid_container: GridContainer, button_name: String) -> void:
func add_tag(flow_container: FlowContainer, tag_text: String) -> void:
	# if last tag empty highlight and prevent new tag
	#if debug: print(grid_container.get_child(grid_container.get_child_count() - 2))
	
	#var tag: Control = flow_container.get_child(flow_container.get_child_count() - 2)
	
	
	var last_tag: Control = flow_container.get_child(flow_container.get_child_count() - 2)
	#if last_tag is not Button:
		#await check_for_duplicate_tags(last_tag) # If no duplicate found add new tag. (unless adding new tag to shared that already exists in global)


	# Turn last tag red if attempting to add new tag and last one is not filled out
	if flow_container.get_child_count() > 1 and last_tag.tag_line_edit.get_text() == "":
		highlight_tag(last_tag)
		return


	store_tags_in_button_array(scene_view, flow_container)

	var new_tag: Control = TAG.instantiate()
	flow_container.add_child(new_tag)
	new_tag.tag_line_edit.set_text(tag_text)
	#new_tag._on_tag_line_edit_text_changed(tag_text)
	#new_tag.custom_minimum_size.x = new_tag.tag_line_edit.size.x + new_tag.margin

	# Connect signals
	new_tag.remove_tag.connect(remove_tag_text_from_array)
	new_tag.tag_enter_pressed.connect(on_enter_add_and_switch_to_new_tag)
	new_tag.rebuild_tags.connect(rebuild_scene_view_tag_arrays)
	#new_tag.tag_line_edit.set_text(tag_text)
	
	
	#new_tag.tag_line_edit.set_text("pole")
	new_tag.tag_line_edit.grab_focus()
	new_tag.set_owner(self)
	

	#new_tag.custom_minimum_size.x = new_tag.tag_text.length() + new_tag.margin

	# Move + button to the end
	if flow_container.name == "FlowSharedTags":
		flow_container.move_child(button_shared_tags, flow_container.get_child_count() - 1)
	else:
		flow_container.move_child(button_global_tags, flow_container.get_child_count() - 1)
	

	#await get_tree().create_timer(0.1).timeout
	#if debug: print("tag added and text is: ", tag_text)
	#new_tag._on_tag_line_edit_text_changed(tag_text)
	#new_tag.custom_minimum_size.x = new_tag.tag_line_edit.size.x + new_tag.margin


	#var button: Button = grid_container.find_child(button_name, true, true)
	#
	#if button != grid_container.get_child(grid_container.get_child_count() - 1):
#
		#move_child(child_node: Node, to_index: int)
#
		#grid_container.remove_child(button) # Remove from current position
		#grid_container.add_child(button) # Add button to the end
		#button.set_owner(self)

	#encrypt_global_tags()



#func find_matching_tags_and_selected_count() -> void:
	#var view_count: int = 1
	#if scene_view and selected_buttons.has(scene_view):
		#view_count = selected_buttons.size()
		#var first_button: Button = null
		#var last_selected_button_shared_tags: Array[String] = []
		#var last_selected_button_global_tags: Array[String] = []
		#var matching_shared_tags_array: Array[String] = []
		#var matching_global_tags_array: Array[String] = []
#
		#for selected_button: Button in selected_buttons:
			#prep_scene_view_button(selected_button, view_count)
			#last_selected_button_shared_tags = selected_button.shared_tags
			#last_selected_button_global_tags = selected_button.global_tags
#
			#if debug: print("last_selected_button_shared_tags: ", last_selected_button_shared_tags)
			#if debug: print("last_selected_button_global_tags: ", last_selected_button_global_tags)
#
#
			#if not first_button: # Skip first button from being processed
				#first_button = selected_button
#
			#else:
				#for shared_tag_text: String in selected_button.shared_tags:
					#matching_shared_tags_array = matching_shared_tags_array.filter(func() -> bool: return last_selected_button_shared_tags.has(shared_tag_text))
#
				#for shared_tag_text: String in selected_button.global_tags:
					#matching_global_tags_array = matching_global_tags_array.filter(func() -> bool: return last_selected_button_global_tags.has(shared_tag_text))
#
		#if debug: print("matching_shared_tags_array: ", matching_shared_tags_array)
		#if debug: print("matching_global_tags_array: ", matching_global_tags_array)
#
		#for tag_text: String in matching_shared_tags_array:
			#add_tag(flow_shared_tags, tag_text)
			#
		#for tag_text: String in matching_global_tags_array:
			#add_tag(flow_global_tags, tag_text)
#
	## otherwise just get the the single selected one
	#elif scene_view:
		#create_tags(scene_view)
		#prep_scene_view_button(scene_view, view_count)
#
#
#
	### Start with all buttons and progressively filter them
	##filtered_buttons_to_show = scene_buttons.duplicate()
##
	##for filter_name in filters_dict.keys():
		##var filter_values = filters_dict[filter_name]
		### Retain only buttons that are in both filtered_buttons_to_show and the current filter
		##filtered_buttons_to_show = filtered_buttons_to_show.filter(func (button): return filter_values.has(button))
##
	##for button: Node in scene_buttons:
		##if button and filtered_buttons_to_show.has(button):
			##button.show()
		##else:
			##button.hide()






# FIXME CAN SCENE_VIEW JUST BE ADDED TO SELECTED_TAGS AND THEN CUT OUT REDUNDANT CODE?
# WHAT ABOUT WHEN GETTING PANEL VIEW BUT IT IS NOT IN SELECTED GROUP? I GUESS WOULD BREAK?
func find_matching_tags_and_selected_count() -> void:
	if not scene_view:
		return

	var view_count: int = 1
	if scene_view and selected_buttons.has(scene_view):
		view_count = selected_buttons.size()
		var first_button: Button = null
		var all_shared_tags: Array[String] = [] # Stores all shared tags from the first button
		var all_global_tags: Array[String] = [] # Stores all global tags from the first button
		var matching_shared_tags_array: Array[String] = []
		var matching_global_tags_array: Array[String] = []

		for selected_button: Button in selected_buttons:
			prep_scene_view_button(selected_button, view_count)
			
			if not first_button: # First button, initialize all tags arrays
				first_button = selected_button
				all_shared_tags = selected_button.shared_tags.duplicate()
				all_global_tags = selected_button.global_tags.duplicate()
			else: # Subsequent buttons, filter matching tags
				all_shared_tags = all_shared_tags.filter(func(tag: String) -> bool: return selected_button.shared_tags.has(tag))
				all_global_tags = all_global_tags.filter(func(tag: String) -> bool: return selected_button.global_tags.has(tag))

		matching_shared_tags_array = all_shared_tags.duplicate()
		matching_global_tags_array = all_global_tags.duplicate()

		if debug: print("matching_shared_tags_array: ", matching_shared_tags_array)
		if debug: print("matching_global_tags_array: ", matching_global_tags_array)

		for tag_text: String in matching_shared_tags_array:
			add_tag(flow_shared_tags, tag_text)
			
		for tag_text: String in matching_global_tags_array:
			add_tag(flow_global_tags, tag_text)

	# otherwise just get the single selected one
	elif scene_view:
		create_tags(scene_view)
		prep_scene_view_button(scene_view, view_count)

###  Update scene_view tags and scene_data_cache tags
#func update_stored_tags() -> void:
	#scene_view.shared_tags.clear()
	#scene_view.global_tags.clear()
	#scene_view.tags.clear()
	#pass


#func update_scene_data_tags_cache(scene_full_path: String, tags: Array[String], shared_tags: Array[String], global_tags: Array[String]) -> void:
	#var scene_data_dict: Dictionary[String, Array] = {
		#"tags": tags,
		#"shared_tags": shared_tags,
		#"global_tags": global_tags
	#}
#
	#scene_data_cache.scene_data[scene_full_path] = scene_data_dict
#
	#if ResourceSaver.save(scene_data_cache, "res://addons/scene_snap/resources/scene_data_cache.tres") == OK:
		#if debug: print("Successfully updated tags for: ", scene_full_path, " in scene_data_cache")
	#else:
		#if debug: push_error("Failed to update tags for: ", scene_full_path, " in scene_data_cache")



# TODO Combine store_tags_in_button_array() remove_tag_text_from_array() and rebuild_scene_view_tag_arrays() into one func with flags
# FIXME Does not work for multi selected if selected and button in selected carry over to all selected
## When drag and drop tags clear and rebuild both tag arrays from visible tags on screen
func rebuild_scene_view_tag_arrays() -> void:
	if selected_buttons and selected_buttons.has(scene_view):
		for button: Button in selected_buttons:
			rebuild_scene_view_tag_arrays_extended(button)
	else:
		rebuild_scene_view_tag_arrays_extended(scene_view)


# TODO combine into less code
func rebuild_scene_view_tag_arrays_extended(scene_view: Button) -> void:
	#var tags: Array[String] = []
	scene_view.shared_tags.clear()
	scene_view.global_tags.clear()
	scene_view.tags.clear()
	
	# Save to scene_data_cache
	# Copy data stored in cache to script variables
	#scene_data_cache.scene_data[scene_view.scene_full_path][tags].clear()

	process_tags(scene_view, flow_shared_tags, scene_view.shared_tags)
	process_tags(scene_view, flow_global_tags, scene_view.global_tags)
	#for tag: Variant in flow_shared_tags.get_children():
		#if tag is not Button:
			#var text: String = tag.tag_line_edit.get_text()
			#if text != "":
				#scene_view.shared_tags.append(text)
				#scene_view.tags.append(text)
#
	#for tag: Variant in flow_global_tags.get_children():
		#if tag is not Button:
			#var text: String = tag.tag_line_edit.get_text()
			#if text != "":
				#scene_view.global_tags.append(text)
				#scene_view.tags.append(text)

	
	#update_scene_data_tags_cache(scene_view.scene_full_path, scene_view.tags, scene_view.shared_tags, scene_view.global_tags)
	# Emit in order to signal to save changes on tag drag and drop
	emit_signal("tag_added_or_removed", scene_view)
	#emit_signal("update_scene_mesh_tags", scene_view, scene_view.shared_tags)


func process_tags(scene_view: Button, container: Node, target_array: Array) -> void:
	for tag: Variant in container.get_children():
		if tag is not Button:
			var text: String = tag.tag_line_edit.get_text()
			if text != "":
				target_array.append(text)
				scene_view.tags.append(text)


## Highlight the tag when duplicate found or when creating new tag but last tag empty.
func highlight_tag(tag: Control) -> void:
	# Resources are shared across instances, so we need to duplicate it
	# to avoid modifying the appearance of all other buttons.
	var new_stylebox_normal = tag.panel.get_theme_stylebox("panel").duplicate()
	var original_bg_color: Color = new_stylebox_normal.get_bg_color()
	new_stylebox_normal.set_bg_color(Color(1.0, 0.124, 0.093))
	tag.panel.add_theme_stylebox_override("panel", new_stylebox_normal)
	# Set color back to original
	await get_tree().create_timer(1).timeout
	new_stylebox_normal.set_bg_color(original_bg_color)




# TODO Combine store_tags_in_button_array() remove_tag_text_from_array() and rebuild_scene_view_tag_arrays() into one func with flags
## Remove the tag_text from scene_view array when X button pressed.
func remove_tag_text_from_array(tag: Control) -> void:
	var tag_text: String = tag.tag_line_edit.get_text()

	if scene_view and selected_buttons.has(scene_view):
		for selected_button: Button in selected_buttons:
			remove_tag_text_from_array_extended(tag, selected_button)

	elif scene_view:
		remove_tag_text_from_array_extended(tag, scene_view)



func remove_tag_text_from_array_extended(tag: Control, scene_view: Button) -> void:
	var tag_text: String = tag.tag_line_edit.get_text()
	
	if tag.get_parent().name == "FlowSharedTags":
		if scene_view.shared_tags.has(tag_text):
			scene_view.shared_tags.erase(tag_text)

	else:
		if scene_view.global_tags.has(tag_text):
			scene_view.global_tags.erase(tag_text)

	if scene_view.tags.has(tag_text):
		scene_view.tags.erase(tag_text)

	scene_view.update_tags_icon()
	#if scene_view.shared_tags.is_empty() and scene_view.global_tags.is_empty(): 
		#scene_view.tags_button_active.hide()
		#scene_view.tags_button_not_active.hide()

	#update_scene_data_tags_cache(scene_view.scene_full_path, scene_view.tags, scene_view.shared_tags, scene_view.global_tags)

	emit_signal("tag_added_or_removed", scene_view)
	#emit_signal("update_scene_mesh_tags", scene_view, scene_view.shared_tags)






func on_enter_add_and_switch_to_new_tag(new_text: String, tag: Control) -> void:
	print("enter signal received")
	#if not await check_for_duplicate_tags(tag): # If no duplicate found add new tag. (unless adding new tag to shared that already exists in global)
		#var tag_text: String = ""
#
		#if tag.get_parent().name == "FlowSharedTags":
			#add_tag(flow_shared_tags, button_shared_tags, tag_text)
		#else:
			#add_tag(flow_global_tags, button_global_tags, tag_text)

	await check_for_duplicate_tags(tag) # If no duplicate found add new tag. (unless adding new tag to shared that already exists in global)
	var tag_text: String = ""

	
	if tag.get_parent().name == "FlowSharedTags":
		add_tag(flow_shared_tags, tag_text)
	else:
		add_tag(flow_global_tags, tag_text)




# Check for duplicate tags in and between shared and global tags (global tags inherit shared tags and will be moved to shared if duplicate between)
func check_for_duplicate_tags(tag: Control) -> void:
	var tag_text: String = tag.tag_line_edit.get_text()

	if tag.get_parent().name == "FlowSharedTags":
		# Shared tags already has new shared tag -> Highlight non new duplicate shared tag and recreate new shared tag.
		if scene_view.shared_tags.has(tag_text):
			highlight_tag(tag.get_parent().get_child(get_duplicate_tag_index(flow_shared_tags, tag)))
			tag.queue_free()

		# Global tags already has new shared tag -> 
		# Highlight non new duplicate global tag, wait, remove non new duplicate global tag and add as new shared tag.
		elif scene_view.global_tags.has(tag_text):
			highlight_tag(flow_global_tags.get_child(get_duplicate_tag_index(flow_global_tags, tag)))
			await get_tree().create_timer(1).timeout
			flow_global_tags.get_child(get_duplicate_tag_index(flow_global_tags, tag)).queue_free()

	else:
		# Shared tags already has new global tag -> Highlight shared tag and recreate new global tag.
		if scene_view.shared_tags.has(tag_text):
			highlight_tag(flow_shared_tags.get_child(get_duplicate_tag_index(flow_shared_tags, tag)))
			tag.queue_free()

		# Global tags already has new global tag -> Highlight non new duplicate global tag and recreate new global tag.
		if scene_view.global_tags.has(tag_text):
			highlight_tag(tag.get_parent().get_child(get_duplicate_tag_index(flow_global_tags, tag)))
			tag.queue_free()




func get_duplicate_tag_index(flow_container: FlowContainer, tag: Control) -> int:
	if tag.get_parent().get_child_count() > 1:
		for tag_sibling: Variant in flow_container.get_children():
			if tag_sibling is not Button and tag_sibling.tag_line_edit.get_text() == tag.tag_line_edit.get_text():
				if debug: print("tag_sibling.get_index(): ", tag_sibling.get_index())
				return tag_sibling.get_index()
	return -1




func encrypt_global_tags() -> void:
	if flow_global_tags.get_child_count() > 1:
		for tag: Control in flow_global_tags.get_children():
			var tag_text: String = tag.tag_line_edit.get_text()
			#encrypt_tag(tag_text)
			encrypt_tag1(tag_text)
			#if debug: print("tag_text: ", tag_text)




func _on_close_tag_panel_button_pressed() -> void:
	# Save all unsaved tags
	hide()

## Clear previous displayed texture buttons
func clear_scene_views() -> void:
	if flow_scene_views.get_child_count() > 0:
		for scene_index: int in flow_scene_views.get_child_count():
			flow_scene_views.get_child(scene_index).queue_free()


## Clear previous displayed shared and global_tags
func clear_tags(flow_container: HFlowContainer) -> void:
	if flow_container.get_child_count() > 1:
		for tag: Variant in flow_container.get_children():
			if tag is not Button:
				tag.queue_free()




#func _on_visibility_changed() -> void:
	#
#
#
	#
	#
	#if debug: print("selected_buttons tag panel: ", selected_buttons)
	## FIXME Will need to move out of here so that triggered also when more items selected 
	#if flow_scene_views:
		##clear_scene_views()
		##clear_tags(flow_shared_tags)
		##clear_tags(flow_global_tags)
		### Clear previous displayed texture buttons
		##if flow_scene_views.get_child_count() > 0:
			##for scene_index: int in flow_scene_views.get_child_count():
				##flow_scene_views.get_child(scene_index).queue_free()
				#
		## Clear previous displayed shared_tags
		 #
				#
				#
				#
		## Get the tags from the individual scenes mesh metadata and display them
		## if multiple buttons selected get them the tag button pressed is one of them 
		#if scene_view and selected_buttons.has(scene_view):
			#for selected_button: Button in selected_buttons:
				## FIXME if multi selected only display tags that all selected buttons have in common
				#prep_scene_view_button(selected_button)
				#store_tags_in_button_array(selected_button, flow_shared_tags, selected_button.shared_tags)
				#store_tags_in_button_array(selected_button, flow_global_tags, selected_button.global_tags)
		#
		#
		## otherwise just get the the single selected one
		#elif scene_view:
			#
			#create_tags(scene_view)
			#if debug: print("scene_view: ", scene_view)
			#if debug: print("scene_view.shared_tags: ", scene_view.shared_tags)
			#prep_scene_view_button(scene_view)
			#
			#if debug: print("SCENE VIEW: ", scene_view)
			#store_tags_in_button_array(scene_view, flow_shared_tags, scene_view.shared_tags)
			#store_tags_in_button_array(scene_view, flow_global_tags, scene_view.global_tags)
			#
			#
			#
			##var new_scene_view = scene_view.duplicate()
			##scene_views_grid_container.add_child(new_scene_view)
			##new_scene_view._3d_label.hide()
			##new_scene_view.heart_texture_button.hide()
			##new_scene_view.selected_texture_button.hide()
			##new_scene_view.set_owner(self)
		#
		##else:
			##scene_view.queue_free()
#
##func prep_scene_view_button(scene_view: Button) -> void:
	###var subviewport_container: Control = scene_view.get_child(0).get_child(0)
	###subviewport_container.queue_free()
	##if debug: print("new_scene_view.get_child(1): ", scene_view.get_child(0).get_child(1))
	#### Give time for UI to update before trying to duplicate
	###await get_tree().create_timer(2).timeout
	###
	###var new_scene_view = scene_view.duplicate()
	###if debug: print("new_scene_view: ", new_scene_view)
	###new_scene_view.set_disabled(true)
	####new_scene_view._3d_label.hide()
	####new_scene_view.heart_texture_button.hide()
	####new_scene_view.selected_texture_button.hide()
	####new_scene_view.tags_button_active.hide()
	####new_scene_view.tags_button_not_active.hide()
	###scene_views_grid_container.add_child(new_scene_view)
	###new_scene_view.set_owner(self)
#
##func store_tags_in_button_array(scene_view: Button) -> void:
	##if scene_view:
		##if flow_shared_tags.get_child_count() > 1:
			##for shared_tag: Variant in flow_shared_tags.get_children():
				##if shared_tag is Control and not scene_view.shared_tags.has(shared_tag):
					##scene_view.shared_tags.append(shared_tag)
					#
#
##var button_tag_array_names: Array[String] = ["shared_tags", "global_tags"]




# TODO Combine store_tags_in_button_array() remove_tag_text_from_array() and rebuild_scene_view_tag_arrays() into one func with flags
## Store the Shared and Global tags within the scene_view button shared_tags and global_tags and tags variables
func store_tags_in_button_array(scene_view: Button, flow_container: FlowContainer) -> void:
	if not scene_view:
		return

	# Store tags in all selected buttons if currently edited button is part of selection
	if selected_buttons.has(scene_view):
		for selected_button: Button in selected_buttons:
			store_tags_in_button_array_extended(selected_button, flow_container)

	# Store the tag in the individual selected button
	elif scene_view:
		store_tags_in_button_array_extended(scene_view, flow_container)


func store_tags_in_button_array_extended(scene_view: Button, flow_container: FlowContainer) -> void:
	if flow_container.get_child_count() > 1:
		for tag: Variant in flow_container.get_children():
			if flow_container.name == "FlowSharedTags":
				if tag is not Button and not scene_view.shared_tags.has(tag.tag_line_edit.get_text()):
					scene_view.shared_tags.append(tag.tag_line_edit.get_text())
					scene_view.tags.append(tag.tag_line_edit.get_text())
					# Display active tags button
					scene_view.update_tags_icon()
					#scene_view.tags_button_active.show()
					#scene_view.tags_button_not_active.hide()

			else:
				if tag is not Button and not scene_view.global_tags.has(tag.tag_line_edit.get_text()):
					scene_view.global_tags.append(tag.tag_line_edit.get_text())
					scene_view.tags.append(tag.tag_line_edit.get_text())
					# Display active tags button
					scene_view.update_tags_icon()
					#scene_view.tags_button_active.show()
					#scene_view.tags_button_not_active.hide()


		#update_scene_data_tags_cache(scene_view.scene_full_path, scene_view.tags, scene_view.shared_tags, scene_view.global_tags)

	emit_signal("tag_added_or_removed", scene_view)
	#emit_signal("update_scene_mesh_tags", scene_view, scene_view.shared_tags)





func create_tags(scene_view: Button) -> void:
	for tag_text: String in scene_view.shared_tags:
		add_tag(flow_shared_tags, tag_text)
	for tag_text: String in scene_view.global_tags:
		add_tag(flow_global_tags, tag_text)




func prep_scene_view_button(scene_view: Button, view_count: int) -> void:
	# Position of sprite is moved when mouse enters button so need to find rather then direct path
	#if debug: print("NewSprite: ", scene_view.get_child(0).get_child(0))
	if debug: print("scene_view children: ", scene_view.get_children())
	if scene_view:
		#var sprite: Sprite2D
		var sprite: Sprite2D = scene_view.find_child('*Sprite2D*', true, false)
		#if scene_view.get_child(0).get_child(0) is Sprite2D:
			#if debug: print("found sprite")
			#sprite = scene_view.get_child(0).get_child(0)
		#else:
			#sprite = scene_view.get_child(0).get_child(1)
		if debug: print("sprite: ", sprite)
		

		var new_texture_buttun: TextureButton = TAG_PANEL_TEXTURE_BUTTON.instantiate()
		#var new_texture_buttun: TextureButton = TextureButton.new()
		if sprite:
			var sprite_duplicate: Sprite2D = sprite.duplicate()
			#sprite_duplicate.scale = Vector2(0.1, 0.1)
			#sprite_duplicate.set_scale(Vector2(0.1, 0.1))
			new_texture_buttun.set_texture_normal(sprite_duplicate.get_texture())
			#new_texture_buttun.set_scale(Vector2(0.1, 0.1))
			# Scale factor based on panel size and count
			#var view_count: int = flow_scene_views.get_child_count()
			## FIXME TWEAK MORE
			#if debug: print("view_count: ", view_count)
			#var factor: int = view_count / 2
			#var scale_factor_x: float = size.x/factor
			#var scale_factor_y: float = size.y/factor
			#if view_count == 1:
				#new_texture_buttun.custom_minimum_size = Vector2(200, 250)
			#
			#else: # Factor of size
				#new_texture_buttun.custom_minimum_size = Vector2(scale_factor_x, scale_factor_y)
			#if debug: print("size: ", size)
			flow_scene_views.add_child(new_texture_buttun)
		#var sprite: Sprite2D = scene_view.get_child(0).find_child("NewSprite", true, true)
		#var sprite_duplicate: Sprite2D = sprite.duplicate()
		#scene_views_grid_container.add_child(sprite_duplicate)




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
		if debug: push_error("No encryption key found in Project Settings!")
		return ""




func encrypt_tag1(tag_text: String) -> void:
	var tags = ["house", "tree", "car", "book", "lamp"]  # Example tags
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
	var aes = AESContext.new()
	
	#var key = "My16ByteKey12345"  # Example 16-byte key
	aes.start(AESContext.MODE_ECB_ENCRYPT, get_key(true).to_utf8_buffer())
	var encrypted_data = aes.update(combined_tags)
	aes.finish()
	
	# Step 5: The 'encrypted_data' variable now contains the encrypted tags
	# You can store or transmit this data as needed
	if debug: print("Encrypted data size: ", encrypted_data.size())
	if debug: print("Encrypted data: ", encrypted_data)

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
	if debug: print("Decrypted tags: ", decrypted_tags)






var aes = AESContext.new()

func encrypt_tag(tag_text: String) -> void:
	

#func move_me():
	#var padded_tag_text = pad_tag_text(tag_text)
	#var key = "My secret key!!!" # Key must be either 16 or 32 bytes.
	#var tag_text = "My secret text!!" # Data size must be multiple of 16 bytes, apply padding if needed.
	# Encrypt ECB
	aes.start(AESContext.MODE_ECB_ENCRYPT, get_key(true).to_utf8_buffer())
	var encrypted = aes.update(tag_text.to_utf8_buffer())
	#var encrypted = aes.update(padded_tag_text)
	aes.finish()
	# Decrypt ECB
	aes.start(AESContext.MODE_ECB_DECRYPT, get_key(true).to_utf8_buffer())
	var decrypted = aes.update(encrypted)
	aes.finish()
	# Check ECB
	assert(decrypted == tag_text.to_utf8_buffer())
	#assert(decrypted == padded_tag_text)
	if debug: print("tag_text: ", decrypted.get_string_from_utf8())


#func pad_tag_text(tag_text: String) -> void:
	## Calculate padding needed to reach the next 16-byte boundary
	#var padding_needed = 16 - (tag_text.length() % 16)
	#if padding_needed == 16:
		#padding_needed = 0  # Data is already a multiple of 16
	## Apply padding (this is a simplified example; actual padding schemes may vary)
	#for _i in range(padding_needed):
		#tag_text.append(padding_needed)
	#
	#encrypt_tag(tag_text)
	##return data

func pad_tag_text(tag_text: String) -> PackedByteArray:
	# Convert string to bytes
	var data_bytes = tag_text.to_utf8_buffer()
	
	# Calculate padding needed to reach the next 16-byte boundary
	var padding_needed = 16 - (data_bytes.size() % 16)
	if padding_needed == 16:
		padding_needed = 0  # Data is already a multiple of 16
	
	# Apply padding (PKCS#7 padding scheme)
	for _i in range(padding_needed):
		data_bytes.append(padding_needed)
	
	return data_bytes


#func pad_data(data: PackedByteArray) -> PackedByteArray:
	## Calculate padding needed to reach the next 16-byte boundary
	#var padding_needed = 16 - (data.size() % 16)
	#if padding_needed == 16:
		#padding_needed = 0  # Data is already a multiple of 16
	## Apply padding (this is a simplified example; actual padding schemes may vary)
	#for _i in range(padding_needed):
		#data.append(padding_needed)
	#return data




### Duplicate code from scene_viewer.gd
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
			#new_sprite.name = "NewSprite"
#
#
			#scene_views_grid_container.add_child(new_sprite)
			#vbox_container.move_child(new_sprite, 0)
#
			#await get_tree().create_timer(0.001).timeout
			#new_scene_view.set_scene_view_size(thumbnail_size_value)



#func _on_flow_shared_tags_rebuild_tags() -> void:
	#rebuild_scene_view_tag_arrays(flow_shared_tags)
#
#
#func _on_flow_global_tags_rebuild_tags() -> void:
	#rebuild_scene_view_tag_arrays(flow_global_tags)





func _on_flow_shared_tags_rebuild_tags() -> void:
	rebuild_scene_view_tag_arrays()



func _on_flow_global_tags_rebuild_tags() -> void:
	rebuild_scene_view_tag_arrays()


func _on_item_rect_changed() -> void:
	if flow_scene_views and flow_scene_views.get_child_count() > 0:
		for texture_button: TextureButton in flow_scene_views.get_children():
			texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
			
			#texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			#texture_button.scale.x = size.x /2
			#texture_button.position = get_global_mouse_position()
			##texture_button.StretchMode.STRETCH_KEEP_ASPECT
			#texture_button.STRETCH_KEEP_ASPECT_CENTERED
			#texture_button.size.x = size.x / 2


#func _on_item_rect_changed() -> void:
	#if flow_scene_views and flow_scene_views.get_child_count() > 0:
		#for texture_button: TextureButton in flow_scene_views.get_children():
			## Set the stretch mode to maintain aspect ratio and center the texture
			#texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
#
			## Calculate the target size while maintaining aspect ratio
			#var target_width = size.x / 2
			#var aspect_ratio = texture_button.get_texture_normal().get_size().aspect()
			#var target_height = target_width / aspect_ratio
#
			## Set the new size
			#texture_button.size = Vector2(target_width, target_height)
