@tool
extends Control


signal process_drop_data_from_tab(origin_file_path: String, path_to_save_scene: String, scene_count: int, sub_collection_tab: Control)
#signal rename_sub_collection_tabs
#signal bubble_up_multi_select_box_state(active: bool) ## Pass signal up to main_collection_tab

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer


@onready var h_flow_container: HFlowContainer = $VBoxContainer/ScrollContainer/HFlowContainer
#@onready var shared_collections_path: String = "user://shared_collections/scenes/"
@onready var scenes_paths: Array[String] = ["user://global_collections/scenes/", "user://shared_collections/scenes/"]

@onready var line_edit: LineEdit = %LineEdit
@onready var control: Control = $Control
@onready var path_to_thumbnail_cache_global: String = "user://global_collections/thumbnail_cache_global/"
@onready var path_to_thumbnail_cache_shared: String = "user://shared_collections/thumbnail_cache_shared/"


const MULTI_SELECT_BOX = preload("res://addons/scene_snap/plugin_scenes/multi_select_box.tscn")
#@onready var color_rect_2: ColorRect = $ColorRect2



var scene_gimbals: Array[Node] = []
var rotate: bool = false
var await_start: bool = true
var initial_gimbal_rotation_y: float = 0.0
var adjust: bool = false
var active_gimbal_count: int = 0
var cached_scene_views: Array[TextureButton] = []
var line_edit_entered: bool
#var main_collection_tab_name: String = ""
var sub_folders_path: String = ""

var existing_tab_names: Array[String] = []
var multi_select_box: Node2D
#var scene_buttons: Array[Node] = []
#var selected_buttons: Array[Button] = []
#var selected_button_style_box = preload("res://addons/scene_snap/resource/scene_view_selected_stylebox.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load MultiSelecBox NOTE: For Project and Favorites loaded under main_base_tab.gd
	multi_select_box = MULTI_SELECT_BOX.instantiate()
	h_flow_container.add_child(multi_select_box)
	multi_select_box.set_owner(self)
	# FIXME NOTE: This operation is done also in main_base_tab.gd get_scene_buttons() but rather then pass up signal
	# Just grabbing here too? TODO: maybe keep or pass up signal through main_collection_tab.gd instantiation happens in scene_viewer.gd 
	# so may need to connect signals up there
	multi_select_box.multi_select_box_state.connect(func (state: bool) -> void:
			#emit_signal("bubble_up_multi_select_box_state", state))
			for button: Node in h_flow_container.get_children():
				if button is Button:
					button.multi_select_box = state)
	
	call_deferred("connect_scene_focused_signal")
	#await get_tree().create_timer(3).timeout
	
	#print("tab position: ", self.name, " / ", get_screen_position())
	#print("just plane old position: ", self.name, " / ", global_position)
	#color_rect_2.position = global_position
	#print("existing_tab_names: ", get_current_sub_collection_tab_titles()["Shared Collections"])
	#print("parent: ", get_parent())
	
	#if get_parent() is TabContainer:
		#var tab_name: String = get_parent().get_tab_title(self.get_index())
		#existing_tab_names.append(tab_name)
			#
	#print("existing_tab_names: ", existing_tab_names)
	
	
		#var current_tab_index: int = get_parent().get_current_tab()
		#
		#print("current tab name: ", get_parent().get_tab_title(current_tab_index))
#
	##line_edit.text = get_parent().get_tab_title(0)
	# NOTE TEMP DISABLED
	#await get_tree().create_timer(5).timeout
	#scene_gimbals = get_tree().get_nodes_in_group("camera_gimbal")
	rotate = true

	# DUPLICATE CODE FROM main_base_tab.gd can this be combined?
	# FIXME USE FOR THUMBNAIL SCALING WITH SCROLL WHEEL AS THAT SEEMS TO NOT ALWAYS WORK CORRECTLY
	var all_control_nodes_in_scroll_container: Array[Node] = scroll_container.find_children("*", "Control", true, false)
	for control: Control in all_control_nodes_in_scroll_container:

		control.mouse_entered.connect(append_control_entered.bind(control.name))
		control.mouse_exited.connect(erase_control_exited.bind(control.name))


func append_control_entered(control_name: String) -> void:
	multi_select_box.controls_with_mouse.append(control_name)


func erase_control_exited(control_name: String) -> void:
	multi_select_box.controls_with_mouse.erase(control_name)





#func get_current_sub_collection_tab_titles() -> Dictionary:
	#var sub_container_tab_titles: Dictionary = {} # { main_container_tab: sub_container_tabs_names,}
	#var main_tab_container: TabContainer = get_parent().get_parent().get_parent().get_parent()
	#
	#for main_tab: TabBar in main_tab_container.get_children():
		#if main_tab.name == "Favorites" or main_tab.name == "Project Scenes":
			#pass
		#else:
			#print("main_tab.name: ", main_tab.name)
			## Save sub tabs order NOTE must use get_tab_title() not sub_tab.name
			#var sub_container_tabs_names: Array[String] = [] # Create a new array for each main_tab
			#for sub_tab in main_tab.sub_tab_container.get_children():
				#var sub_tab_index: int = sub_tab.get_index()
				#var sub_tab_name: String = main_tab.sub_tab_container.get_tab_title(sub_tab_index)
				#sub_container_tabs_names.append(sub_tab_name)
			#sub_container_tab_titles[main_tab.name] = sub_container_tabs_names
#
	#return sub_container_tab_titles


#var dragging = false  # Are we currently dragging?
#var selected = []  # Array of selected units.
#var drag_start = Vector2.ZERO  # Location where drag began.
#var select_rect = RectangleShape2D.new()  # Collision shape for drag box.
#
## Reference: https://kidscancode.org/godot_recipes/4.x/input/multi_unit_select/index.html (kidscancode)
#func _unhandled_input(event):
	##print("unhandled")
	##if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	#if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("HI")
		#if event.pressed:
			#print("pressed")
			## If the mouse was clicked and nothing is selected, start dragging
			#if selected.size() == 0:
				#dragging = true
				#drag_start = event.position
		## If the mouse is released and is dragging, stop dragging
		#elif dragging:
			#dragging = false
			#queue_redraw()
	#if event is InputEventMouseMotion and dragging:
		#queue_redraw()
#
#func _draw():
	#if dragging:
		#draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
			#Color.YELLOW, false, 2.0)








#var current_tab_name: String
#var current_tab_index: int
#var new_tab_name_text: String





#var main_tab_name: String

#func _input(event: InputEvent) -> void:
	#
	## TODO ADD ESCAPE TO EXIT AND REVERT TO CURRENT TAB NAME
	## TODO ADD UNDO REDO FUNCTIONALITY
	## TODO ADD WARNING IF RENAME MATCHES EXISTING TAB NAME
	#if event is InputEventMouseButton:
		#if event.is_double_click() and line_edit_entered:
			#if get_parent() is TabContainer:
				#main_tab_name = get_parent().get_parent().get_parent().name
				#do_name_check(main_tab_name)
				#
				#current_tab_index = get_parent().get_current_tab_control().get_index()
				##current_tab_index = get_parent().get_current_tab()
				##print("current tab name: ", get_parent().get_tab_title(current_tab_index))
				#current_tab_name = get_parent().get_tab_title(current_tab_index)
				#line_edit.text = current_tab_name
			#
			#
			#
				#line_edit.show()
	#
	## find old tab name and rename to line_edit.text if old tab name in thumbnail cache folder rename that too.
	#if Input.is_key_pressed(KEY_ENTER):
		#if get_parent() is TabContainer:
			## If this tab is current tab
			##if (self.get_index(true) - 1) == current_tab_index:
			#if self.get_index() == current_tab_index:
				##print("self.index: ", self.get_index(true))
				##print("this tab name: ", current_tab_name)
				#var new_tab_name: String = new_tab_name_text
				#
				#if new_tab_name == "" or new_tab_name == null:
					#new_tab_name = current_tab_name
				#
				##get_parent().set_tab_title(current_tab_index, new_tab_name)
#
				##var main_tab_name: String = get_parent().get_parent().get_parent().name
#
				#line_edit_entered = false
				#line_edit.hide()
				#control.show()
				#
#
				#
				#rename_sub_collection_folders(main_tab_name, current_tab_name, new_tab_name)
#
#
	#if Input.is_key_pressed(KEY_ESCAPE):
		#if get_parent() is TabContainer:
			#if self.get_index() == current_tab_index:
				#get_parent().set_tab_title(current_tab_index, current_tab_name)
				#line_edit_entered = false
				#line_edit.hide()
				#control.show()

#var tab_titles: Array[String]
#func do_name_check(main_tab_name: String) -> void:
	#match main_tab_name:
		#"Global Collections":
			#tab_titles = get_current_sub_collection_tab_titles()["Global Collections"]
		#"Shared Collections":
			#tab_titles = get_current_sub_collection_tab_titles()["Shared Collections"]
			#
			#
#func rename_sub_collection_folders(main_tab_name: String, current_tab_name: String, new_tab_name: String) -> void:
	#print(" 1st main_tab_name: ", main_tab_name)
	#print("1st current_tab_name: ", current_tab_name)
	#print("1st new_tab_name: ", new_tab_name)
	#var collection_folder_path: String
	#var thumbnail_folder_path: String
	##var tab_titles: Array[String]
	#match main_tab_name:
		#"Global Collections":
			##tab_titles = get_current_sub_collection_tab_titles()["Global Collections"]
			#collection_folder_path= scenes_paths[0].path_join("Global Collections")
			#thumbnail_folder_path = path_to_thumbnail_cache_global.path_join("Global Collections")
		#"Shared Collections":
			##tab_titles = get_current_sub_collection_tab_titles()["Shared Collections"]
			#collection_folder_path = scenes_paths[1].path_join("Shared Collections")
			#thumbnail_folder_path = path_to_thumbnail_cache_shared.path_join("Shared Collections")
	#
	#print("tab_titles HERE: ", tab_titles)
	#if tab_titles.has(new_tab_name):
		#printerr("Tab with the same name exists!")
		## Reset back to original name
		#get_parent().set_tab_title(current_tab_index, current_tab_name)
	#else:
		#get_parent().set_tab_title(current_tab_index, new_tab_name)
		#rename_folder(collection_folder_path, current_tab_name, new_tab_name)
		#rename_folder(thumbnail_folder_path, current_tab_name, new_tab_name)
		##await get_tree().process_frame
	#
#
#
#func rename_folder(folder_path: String, current_tab_name: String, new_tab_name: String):
	#print("2nd folder_path: ", folder_path)
	#print("2nd current_tab_name: ", current_tab_name)
	#print("2nd new_tab_name: ", new_tab_name)
	#var dir = DirAccess.open(folder_path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#print("2nd file_name", file_name)
		#if file_name == current_tab_name:
			#var error = dir.rename(current_tab_name, new_tab_name)
			#if error != OK:
				#printerr("Could not rename folder")
			#else:
				#pass
#
	#else:
		#print("An error occurred when trying to access the path.")


# FIXME Fix wait time to match when everything loaded not to a set time
func connect_scene_focused_signal() -> void:
	#await get_tree().create_timer(3).timeout
	var scene_buttons: Array[Node] = h_flow_container.get_children()
	#var scene_buttons = find_child("HFlowContainer", true, false).get_children()
	for scene_button in scene_buttons:
		if scene_button is Button:
			# Connect to ScrollContainer to maintain follow focus that breaks when changing to popup window and back
			scene_button.scene_focused.connect(func (scene_full_path: String, selected_scene: Button) -> void: scroll_container.ensure_control_visible(selected_scene))
		##scene_button.button_selected.connect(func (button: Button, selected: bool) -> void: 
		##scene_button.button_selected.connect(get_selected_buttons.bind(scene_buttons))
		#scene_button.button_selected.connect(get_selected_buttons)
#
#
#var last_button_index: int = -1
#
#func get_selected_buttons(button: Button, scene_buttons: Array[Node], selected: bool) -> void:
#
	#if Input.is_key_pressed(KEY_SHIFT):
		#var selected_button_index: int = button.get_index()
#
		#if last_button_index == -1:
			#last_button_index = selected_button_index
#
		#if last_button_index < selected_button_index: # Normal left to right selection (top down)
			#for index: int in range(last_button_index, selected_button_index + 1):
				#update_scene_view_button(scene_buttons[index], selected)
		#if last_button_index > selected_button_index: # non normal right to left selection (bottom up)
			#for index: int in range(selected_button_index, last_button_index + 1):
				#update_scene_view_button(scene_buttons[index], selected)
#
	#else:
		#update_scene_view_button(button, selected)
	#
	#button.selected_texture_button.show() # do not hide last buttons selection box
	##print("selected_buttons: ", selected_buttons)
#
#
#func update_scene_view_button(button: Button, selected: bool) -> void:
	#if button.is_visible_in_tree(): # Restrict if filtered scenes
		#if selected:
			#button.selected_texture_button.button_pressed = true
			#button.selected_texture_button.show()
			#button.self_modulate = Color(1.0, 1.0, 1.0, 0.6)
			#button.add_theme_stylebox_override("normal", selected_button_style_box)
			#if not selected_buttons.has(button):
				#selected_buttons.append(button)
#
		#else:
			#button.selected_texture_button.button_pressed = false
			#button.selected_texture_button.hide()
			#button.self_modulate = Color(1.0, 1.0, 1.0, 0.18)
			#button.remove_theme_stylebox_override("normal")
			#if selected_buttons.has(button):
				#selected_buttons.erase(button)
#
		#last_button_index = button.get_index()










#func get_selected_buttons(button: Button, selected: bool, scene_buttons: Array[Node]) -> void:
	#print("selected: ", selected)
	#var selected_button_index: int = button.get_index()
	#
	#if selected and selected_buttons == []:
		#last_button_toggled_index = selected_button_index
		#last_button_toggled_on = selected  # Update last_button_toggled_on immediately
		#
		#update_scene_view_button(button, scene_buttons, selected_button_index, selected)
		#
	#if Input.is_key_pressed(KEY_SHIFT):
		#print("last_button_toggled_on: ", last_button_toggled_on)
		#
		#if (last_button_toggled_on or selected):
			#get_button_range(button, scene_buttons, selected, selected_button_index)
			#
			#selected_buttons.append(button)
			#update_scene_view_button(button, scene_buttons, selected_button_index, selected)
			#
			## Update last_button variables after appending
			#last_button_toggled_index = selected_button_index
			#last_button_toggled_on = selected
		#else:
			#get_button_range(button, scene_buttons, selected, selected_button_index)
			#
			#if button in selected_buttons:  # Check if the button is in the list before erasing
				#selected_buttons.erase(button)
				#update_scene_view_button(button, scene_buttons, selected_button_index, selected)
				#
			## Update last_button variables after erasing
			#last_button_toggled_index = -1  # Deselecting, so reset to -1 or remove if needed
			#last_button_toggled_on = false
			#
	#print("selected_buttons: ", selected_buttons)
	#
	## Ensure these are updated based on the current state
	#if button in selected_buttons:
		#last_button_toggled_index = button.get_index()
		#last_button_toggled_on = true
	#else:
		#last_button_toggled_index = -1
		#last_button_toggled_on = false
	
















#func get_selected_buttons(button: Button, selected: bool, scene_buttons: Array[Node]) -> void:
	#var selected_button_index: int = button.get_index()
	#
	#if selected:
		#if Input.is_key_pressed(KEY_SHIFT):
			#if selected_buttons != []:
				#var last_button_index: int = selected_buttons.back().get_index()
#
				#if last_button_index < selected_button_index: # Normal left to right selection (top down)
					#for index: int in range(last_button_index + 1, selected_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
#
				#if last_button_index > selected_button_index: # non normal right to left selection (bottom up)
					#for index: int in range(selected_button_index + 1, last_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
			#
			#selected_buttons.append(button)
		#else:
			#if selected_buttons != []:
				#var last_button_index: int = selected_buttons.back().get_index()
#
				#if last_button_index < selected_button_index:
					#for index: int in range(last_button_index + 1, selected_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
				#
				#if last_button_index > selected_button_index:
					#for index: int in range(selected_button_index + 1, last_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
#
			## Only select one button at a time without shift
			#if not selected_buttons.has(button):
				#selected_buttons.append(button)
	#else:
		#if Input.is_key_pressed(KEY_SHIFT):
			#if selected_buttons != []:
				#var last_button_index: int = selected_buttons.back().get_index()
#
				#if last_button_index < selected_button_index:
					#for index: int in range(last_button_index + 1, selected_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
				#
				#if last_button_index > selected_button_index:
					#for index: int in range(selected_button_index + 1, last_button_index):
						#update_scene_view_button(button, scene_buttons, index, selected)
#
		## Deselect all without shift
		#if selected_buttons.has(button):
			#selected_buttons.erase(button)
	#
	#print("selected_buttons: ", selected_buttons)




# FIXME TODO Restrict to only files that are ok.
func _can_drop_data(position, data):
	# NOTE Will need to get dependencies and copy them over to host filesystem at user://
	return true
	#print(typeof(data))
	#return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(position, data):
	# FIXME Make it so user friendly so that user is not required to drag and drop dependencies in for them to be copied over
	# FIXME Will need to get dependencies and copy them over to host filesystem at user:// 
	var origin_file_paths = data["files"]

	for origin_file_path: String in origin_file_paths: 
		var path_to_save_scene: String = sub_folders_path.path_join(self.name)
		#match main_collection_tab_name:
			#"Global Collections": # user://global_collections/scenes/Global Collections/sub_collection_tab_name (self.name)
				#path_to_save_scene = scenes_paths[0].path_join(main_collection_tab_name.path_join(self.name))
			#"Shared Collections":
				#path_to_save_scene = scenes_paths[1].path_join(main_collection_tab_name.path_join(self.name))

		emit_signal("process_drop_data_from_tab", origin_file_path, path_to_save_scene, origin_file_paths.size(), self)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#await get_tree().create_timer(1).timeout
	#print("current_tab_index: ", current_tab_index)
	#if get_parent() is TabContainer:
		#get_parent().set_tab_title(0, new_tab_name_text)
		#print(get_parent())
	#print(get_parent().get_tab_title(0))
	#get_parent().set_tab_title(0, new_tab_name_text)
	#print(line_edit_entered)
	#print(h_flow_container.get_children())
	#if adjust:
		#adjust_rotation_speed()
	#
	#for scene in h_flow_container.get_children():
		
		#var scene_gimbal = scene.find_child("CameraGimbal", true, false)
	if rotate:
		for gimbal in scene_gimbals:
			gimbal.rotation.y += 0.1 * delta
	#for gimbal in scene_gimbals:
		#gimbal.rotation.y += 0.4 * delta
	pass

#func adjust_rotation_speed():
	#for gimbal in scene_gimbals:
		#gimbal.rotation.y = 0.0
	#adjust = false


# NOTE DISABLED
#func _on_visibility_changed() -> void:
	##print("the visibility was changed")
	#if h_flow_container:
		#if h_flow_container.get_child_count() > 0:
			##var scene_views: Array[Node] = h_flow_container.get_children()
			#SceneSnapGlobal.sub_collection_tab_scenes = h_flow_container.get_children()
			##if not scene_views == null:
				##for scene in scene_views:
					##print(scene)




	if await_start:
		await get_tree().create_timer(2).timeout
		await_start = false
	
	
	if visible:
		for child in h_flow_container.get_children():
			child.set_process_mode(Node.PROCESS_MODE_INHERIT)
	else:
		for child in h_flow_container.get_children():
			child.set_process_mode(Node.PROCESS_MODE_DISABLED)







	
	#print("gimbal_rotation_y:", initial_gimbal_rotation_y)
	#var scene_nodes = self.find_child("HFlowContainer", true, false).get_children()
	#if visible:
		#for child in scene_nodes:
				#child.show()
				#child.set_process(true)
	#else:
		#for child in scene_nodes:
			##child.queue_free()
			#child.hide()
			#child.set_process(false)



	#if await_start:
		#await get_tree().create_timer(2).timeout
		#for gimbal in scene_gimbals:
			#initial_gimbal_rotation_y = gimbal.rotation.y
		##scene_gimbals.clear()
		#await_start = false
		#
	#for child in h_flow_container.get_children():
		#child.set_process_mode(Node.PROCESS_MODE_DISABLED)
		#cached_scene_views.append(child)
		#h_flow_container.remove_child(child)
		#
		#
	#if visible:
		#for scene in cached_scene_views:
			#var scene_gimbal = scene.find_child("CameraGimbal", true, false)
			#if scene.get_parent() == h_flow_container:
				#pass
			#else:
				#h_flow_container.add_child(scene)
				#scene.set_process_mode(Node.PROCESS_MODE_INHERIT)
				#scene_gimbals.append(scene_gimbal)
#
		#print("tab is visible: ", self.name)
		#
	#else:
		#for scene in cached_scene_views:
			#var scene_gimbal = scene.find_child("CameraGimbal", true, false)
			#scene_gimbals.erase(scene_gimbal)
			#scene.queue_free()
	
	#print("active_gimbal_count: ", active_gimbal_count)
	#print("gimbal_array_size: ", scene_gimbals.size())



#var surface_material 
#
##var surface_material = preload("res://materials/new_standard_material_3d.tres")
##surface_material = preload("res://base_assets/kenny_food.tres")
##var surface_material = preload("res://textures/Dekogon Pipes-Drainage/Textures/TX_Pipe_Set_02a_ALB.PNG")
#
#
#var child_0_not_mesh: bool = false
#
#func process_drop_file(scene: Node3D, path_to_save_scene: String, new_sub_collection_tab: Control):
	#await get_tree().process_frame
	#await get_tree().create_timer(1).timeout
	##print("path_to_save_scene: ", path_to_save_scene)
	##print("scene: ", scene)
	##print("scene.get_scene_file_path(): ", scene.get_scene_file_path())
	##print("scene.name: ", scene.name)
	##print(scene.transform)
	#
	#print("Starting post-import processing.")
	## Ensure there is exactly one child (the main MeshInstance3D)
	##if scene.get_child_count() != 1:
		##push_error("Scene should have exactly one child.")
		##return scene
#
	## Get the main MeshInstance3D
	##var scene_children = scene.get_children()
	##print(scene_children)
	##EditorInterface.get_edited_scene_root().add_child(scene)
	##scene.owner = EditorInterface.get_edited_scene_root()
	#
	#var mesh_model: MeshInstance3D
	#
	#if scene.get_child(0) is MeshInstance3D:
		#mesh_model = scene.get_child(0)
		#pass
		#
	#elif scene.get_child(0).get_child(0) is MeshInstance3D:
			#child_0_not_mesh = true
			#mesh_model = scene.get_child(0).get_child(0)
	#else:
		#push_error("Could not find MeshInstance3D.")
		#return scene
#
#
#
	## Check if the child is a MeshInstance3D
	## This is used for the MeshInstance3D on the imported model
	##if not mesh_model is MeshInstance3D:
		##push_error("Scene's first child should be MeshInstance3D.")
		##return scene
	#
	##if mesh_model is not MeshInstance3D:
		##push_error("Scene's first child should be MeshInstance3D.")
		##return scene
	#
	## Check that all granchildren are MeshInstance3D
	## These are used for the convex collision shapes
	#for child in mesh_model.get_children():
		##if not child is MeshInstance3D and child.mesh:
		#if child is not MeshInstance3D and child.mesh:
			#push_error("All Grandchildren should be of type MeshInstance3D.")
			#return scene
	#
	#
#
	#mesh_model.owner = null
#
	#if child_0_not_mesh:
		#scene.get_child(0).remove_child(mesh_model)
	#else:
		#scene.remove_child(mesh_model)
	#
	## Detach the main MeshInstance3D from the scene
	##mesh_model.set_owner(null) # Seems like this shouldn't need to be here, but it does. Perhaps a bug.
	##scene.remove_child(mesh_model) # without the line above, this makes a warning
#
#
#
#
#
	## Create a new RigidBody3D and configure it
	## This will be the root node of the returned scene
	##var rigid_body = RigidBody3D.new()
	##rigid_body.name = mesh_model.name + "_rigid"
	#var static_body = StaticBody3D.new()
	#static_body.name = mesh_model.name + "--Tags"
	#
	## Add the main MeshInstance3D as a child of the new RigidBody3D
	##static_body.add_child(mesh_model)
	##mesh_model.set_owner(static_body)
#
	#static_body.add_child(mesh_model)
	##mesh_model.owner = static_body
	#mesh_model.set_owner(static_body)
#
#
#
#
	## Iterate through MeshInstance3D children to create individual collision shapes
	##for child in mesh_model.get_children():
	#for child in static_body.get_children():
		##var mesh_shape = child.mesh.create_convex_shape()
		#if child is MeshInstance3D and child.mesh:
			#child.set_surface_override_material(0, surface_material)
		#var mesh_shape = child.mesh.create_trimesh_shape()
		#var collision_shape = CollisionShape3D.new()
		#collision_shape.shape = mesh_shape
		#collision_shape.name = child.name + "_collision"
		## Apply the original mesh child's transform to the collision shape
		#collision_shape.transform = child.transform
		## Add the collision shape to the RigidBody3D
		#static_body.add_child(collision_shape)
		## Set the owner to ensure it's saved with the rigid_body # scene
		#collision_shape.set_owner(static_body)
		#print("Added CollisionShape3D for: ", child.name)
		## Remove the original MeshInstance3D as it's now represented by a collision shape
		##mesh_model.remove_child(child)
		##child.queue_free()
	#
	## Free the original scene root, as it's no longer needed
	#scene.queue_free()
	#
	#print("Finished setting up RigidBody3D and collision shapes.")
	#
	## Create and save scene
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(static_body)
	##var save_path = "res://" + static_body.name + ".tscn"
	#var save_path = path_to_save_scene.path_join(static_body.name + ".tscn")
	#print("Saving scene... " + save_path)
	#ResourceSaver.save(packed_scene, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)
	#
	## Create scene view button
	#var scene_full_path = path_to_save_scene.path_join(static_body.name + ".tscn")
	##var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 4)
	##var scenes_path: String = "user://scenes".path_join(scene_full_path_split[2].path_join(scene_full_path_split[3]))
	##print()
	#
	#
	##await get_tree().create_timer(3).timeout
	#await get_tree().process_frame
	#print("scene_full_path: ", scene_full_path)
	##load_scene_primer(path_to_save_scene)
	#create_scene_buttons(scene_full_path, new_sub_collection_tab)
	#
	#
	#
	#
	#
	#
	##return static_body
#
#








#func _on_line_edit_text_changed(new_text: String) -> void:
	#get_parent().set_tab_title(current_tab_index, new_text)
	#new_tab_name_text = new_text
	#print(new_text)
	#pass # Replace with function body.








func _on_control_mouse_entered() -> void:
	#print("line-edit area entered")
	line_edit_entered = true
	control.hide()


#func _on_control_mouse_exited() -> void:
	#print("lin-edit area exited")
	#var line_edit_entered = false




func close_line_edit() -> void:
	line_edit_entered = false
	line_edit.hide()
	control.show()
