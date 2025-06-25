@tool
#extends TextureButton
extends Button

var debug = preload("res://addons/scene_snap/scripts/print_debug.gd").new().run()

signal add_favorite
signal remove_favorite(scene_full_path: String, scene_view_button: Button) ## Send signal to main_base_tab.gd to re-filter visible buttons
signal clear_favorite
#signal update_favorites
signal scene_snap_mode
signal scene_focused
signal get_scene_number
signal pass_up_scene_number
signal update_selected_scene_view_button(scene_view_button: Button)
signal process_drop_data_from_scene_view
#signal recreate_scene_button
# NOTE: scene is passed in as a placeholder, but is not used
#signal reload_scene(button: Button, scene: Node, scene_full_path: String, sub_viewport: SubViewport)
signal reload_scene(button: Button, scene_full_path: String, sub_viewport: SubViewport)
signal enable_panel_button_sizing # TODO Signal comes from main_base_tab mouse entered too check if conflicts because sometimes does not work
signal button_selected
signal remove_open_tag_panel
signal toggle_tag_panel(scene_view_button_pressed: Button)
signal clear_tags(clear_shared_tags: bool, scene_view_button_pressed: Button)
signal clear_selected_enabled(state: bool)
#signal load_scene_instance(scene_full_path: String)
# NOTE: Changed to instantiating panel in scene_viewer
signal scene_tag_added_or_removed(tagged_scene_full_path: String) ## bubble up from tag_panel.gd to scene_viewer.gd scenes with edited tags
signal get_scene_ready_state(collection_name: String, scene_full_path: String) ## Get if collection_lookup[collection_name][scene_full_path] has scene instance from scene_viewer.gd
#signal set_scenes_default_materials(scene_instance: Node, scene_full_path: String, surface: int, material: StandardMaterial3D) ## Trigger setting default textures for the mesh showen when mouse_entered and 360 rotation preview
#signal button_selected(button_index, selected)
#signal  scene_has_animation

# NOTE left off change node name of scene_instance not just scene view and when duplicate scenes in viewer be able to load them and reference non 2 version 
# NOTE figure out why visbileonscreennotifier is not working in @tool

@onready var settings = EditorInterface.get_editor_settings()

@onready var res_dir = DirAccess.open("res://")
@onready var user_dir = DirAccess.open("user://")
@onready var margin_container: MarginContainer = %MarginContainer

@onready var file_label: Label = %FileLabel
#@onready var v_box_container: VBoxContainer = $VBoxContainer

#@onready var sub_viewport: SubViewport = $VBoxContainer/SubViewportContainer/SubViewport
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var heart_aspect_ratio_container: AspectRatioContainer = $HBoxContainer/HeartAspectRatioContainer
@onready var label_aspect_ratio_container: AspectRatioContainer = $HBoxContainer/LabelAspectRatioContainer
@onready var heart_texture_button: TextureButton = %HeartTextureButton
@onready var _3d_label: Label = %"3DLabel"
@onready var circle_texture_button: TextureButton = %CircleTextureButton

@onready var tags_button: TextureButton = %TagsButton


@onready var h_box_container_additions: HBoxContainer = $HBoxContainerAdditions
@onready var animation_texture_button: TextureButton = %AnimationTextureButton
@onready var multiple_mesh_glb: TextureButton = %MultipleMeshGLB



@onready var selected_texture_button: TextureButton = %SelectedTextureButton
#var selected_button_style_box = preload("res://addons/scene_snap/resource/scene_view_selected_stylebox.tres")
#const SCENE_VIEW_SELECTED_STYLEBOX = preload("res://addons/scene_snap/resources/scene_view_selected_stylebox.tres")


@onready var texture_rect_body: TextureRect = %TextureRectBody
@onready var texture_rect_collision: TextureRect = %TextureRectCollision
@onready var label_3dlod: Label = %Label3DLOD



const SUB_VIEWPORT_CONTAINER_SCENE = preload("res://addons/scene_snap/plugin_scenes/sub_viewport_container.tscn")
const TAG_PANEL_POPUP = preload("res://addons/scene_snap/plugin_scenes/tag_panel_popup.tscn")
const TAG_PANEL = preload("res://addons/scene_snap/plugin_scenes/tag_panel.tscn")

const TAG = preload("uid://lk0x216oxk4h")
const TAG_NOT_ACTIVE = preload("uid://brmknafst68gu")
const TAGS = preload("uid://cfedutr8ohrtn")
const TAGS_NOT_ACTIVE = preload("uid://dyvik5amxqleb")


@onready var shared_collections_path: String = "user://shared_collections/scenes/"
@onready var project_scenes_path: String = "res://collections/"

# FIXME not correct path or used
#@onready var project_scenes_path: String = "res://scenes/"

var scene_file: PackedScene
var scene_full_path: String = ""
var collection_name: String = ""
var min_label_size: int = 200#was 250 #was 121
var full_label_size: int = 270
var min_bclod_display_size: int = 150
var min_3d_label_size: int = 100
var min_heart_size: int = 50
var min_additions_size: int = 150 # NOTE Buttons become unclickable at smaller size
var slider_value: float
var scene_number: int # Gets passed down from scene_snap_plugin to be used to change quick scroll position when button pressed
var show_animation_texture_button: bool = false
#var sub_viewport_container: SubViewportContainer
var scene: Node = null
var animation_player_node: AnimationPlayer
var play_animation_number: int = 0

var child_sprite: Sprite2D = null
#var thumbnail_cache_path: String = ""
#var thumbnail_texture: TextureRect = null
var thumbnail_size_value: float = 0
var file_name: String = ""
# Label/Icon set flags
var set_file_name_visible: bool = true
var set_label_margins_full: bool = true
var set_heart_visible: bool = true
var set_3d_label_visible: bool = true

var multi_select_box: bool = false
var scene_ready: bool = false
#var main_collection_tab_parent: Control = null # Filled by main_base_tab.gd get_scene_buttons()
var main_collection_tab_parent: String = "" # Filled by main_base_tab.gd get_scene_buttons()
#var sub_collection_tab_parent: Control = null
#var collection_ready: bool = false


# On start tags are processed from the scenes in scene_viewer.gd import_mesh_tags() and then stored here
# When tags are created in tag_panel.gd they are also stored here
var tags: Array[String] = []
var shared_tags: Array[String] = []
var global_tags: Array[String] = []

var initialize_show: bool = true
var sharing_disabled: bool = false

## Revisit this mess
#func get_thumbnail() -> void:
	#thumbnail_texture = TextureRect.new()
	#var image: Image = Image.load_from_file(thumbnail_cache_path)
	#image.clear_mipmaps()
	#image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB, Image.ASTC_FORMAT_8x8)
	#thumbnail_texture.texture = ImageTexture.create_from_image(image)
	##thumbnail_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#thumbnail_texture.size_flags_horizontal = TextureRect.SIZE_SHRINK_CENTER
	#v_box_container.add_child(thumbnail_texture)
	#v_box_container.move_child(thumbnail_texture, 0)
#
	#set_scene_view_size(thumbnail_size_value)



func _ready() -> void:
	
	# Hide button until after thumbnail and button sizes set
	visible = false
	#call_deferred("get_thumbnail")
	#if debug: print("thumbnail_cache_path: ", thumbnail_cache_path)
	#v_box_container.move_child(thumbnail_texture, 0)
	#v_box_container.move_child(thumbnail_texture, 0)
	

	multiple_mesh_glb.texture_normal = get_theme_icon("FileThumbnail", "EditorIcons")
	animation_texture_button.texture_normal = get_theme_icon("MainMovieWrite", "EditorIcons")
	selected_texture_button.texture_normal = get_theme_icon("GuiCheckedDisabled", "EditorIcons")
	selected_texture_button.texture_pressed = get_theme_icon("GuiChecked", "EditorIcons")

	
	
	# NOTE await is used to give time for button name to be updated from scene_viewer.gd to filename
	# FIXME filenames with no "-" or "_" are not being displayed
	await get_tree().create_timer(0.001).timeout
	# Split file name at "_" and "-" to display
	var scene_name_split: PackedStringArray
	
	if self.name.contains("_"):
		scene_name_split = self.name.split("_", false, 0)
	elif self.name.contains("-"):
		scene_name_split = self.name.split("-", false, 0)

	if not scene_name_split: # If single word filenames
		file_name = self.name
	else:
		for index: int in scene_name_split.size():
			file_name += scene_name_split[index] + " "
		
	file_name.strip_edges()
	
	#if debug: print("scene_name_split: ", scene_name_split)
	#if debug: print("file_name: ", file_name)
	
	file_label.set_text(file_name)
	tooltip_text = file_name
	
	#file_label.set_text(self.name)
	#tooltip_text = self.name

	#call_deferred("set_thumbnail_size")
	#await ready
	call_deferred("set_size_flags")
	call_deferred("get_collection_name")

	#set_size_flags()
	#set_scene_view_size(thumbnail_size_value)
	#set_thumbnail_size()

	#if show_animation_texture_button:
		#animation_texture_button.show()
		#emit_signal("scene_has_animation", scene_full_path)

	#call_deferred("set_animation_texture_button_state")
#
#
#func set_animation_texture_button_state() -> void:
	#await get_tree().create_timer(1).timeout
	#if show_animation_texture_button:
		#animation_texture_button.show()
		#emit_signal("scene_has_animation", scene_full_path)
	#await get_tree().create_timer(5).timeout
	#call_deferred("get_has_animation_state")
#
#
#func get_has_animation_state() -> void:
	#if has_meta("has_animation"):
		#show_animation_texture_button = get_meta("has_animation")
		#if show_animation_texture_button:
			#animation_texture_button.show()
	
	#var animation_player_node_instances: Array[Node] = self.find_children("*", "AnimationPlayer", true, false)
	#if animation_player_node_instances.size() >= 1:
		#self.show_animation_texture_button = true
		##scene_has_animation.append(scene_full_path)
	#await get_tree().create_timer(5).timeout
	#if debug: print("report position: ", global_position)

#func move_thumbnail_texture() -> void:
	#if v_box_container:
		#v_box_container.move_child(child_sprite, 0)
	#set_scene_view_size(thumbnail_size_value)

#func set_thumbnail_size() -> void:
	##await get_tree().create_timer(5).timeout
	##if debug: print("setting button size now to size: ", thumbnail_size_value)
	#set_scene_view_size(thumbnail_size_value)


# How can I implement drag and drop into the scene from my EditorPlugin? (idbrii)
# REFERENCE: https://forum.godotengine.org/t/how-can-i-implement-drag-and-drop-into-the-scene-from-my-editorplugin/3804/2
# FIXME NOT USED CURRENTLY NO DROPPING TO THE BUTTON THEMESELVES.
func _get_drag_data(position: Vector2) -> Variant:
	#EditorInterface.get_editor_viewport_3d(0).set_input_as_handled()
	var scene = self.find_child("SubViewport").get_child(0)
	var scene_path: String = scene.get_scene_file_path()
	var scene_file: String = scene.get_scene_file_path().get_file()
	#if debug: print(scene_file)
	var scene_name_split: PackedStringArray = scene_file.split("--", false, 0)
	if debug: print("scene_name_split: ", scene_name_split)
	# NOTE If not using --tags will end in .tscn so needs to be removed
	if scene_name_split[0].ends_with(".tscn"):
		#scene_name_split[0] = scene_name_split[0].rstrip(".tscn")
		scene_name_split[0] = scene_name_split[0].substr(0, scene_name_split[0].length() - 5) # The length of .tscn = 5
	#if debug: print("getting dependencies")
	#for dep in ResourceLoader.get_dependencies(scene_path):
		#if debug: print(dep)
		#if debug: print(dep.get_slice("::", 0)) # Prints UID.
		#if debug: print(dep.get_slice("::", 2)) # Prints path.


	if res_dir:
		# Skip reimporting if file exists # TODO add option to skip this step if user wants to overwrite existing scenes
		# TODO user defind storage location
		if res_dir.file_exists(project_scenes_path.path_join(scene_name_split[0] + ".tscn")):
			pass

		else:
			var result = res_dir.copy(scene_path, project_scenes_path.path_join(scene_name_split[0] + ".tscn"))
			if result == OK:
				pass
				#if debug: print("File copied successfully.")
			else:
				if debug: print("Failed to copy file.")
			# Scan the filesystem to update
			var editor_filesystem = EditorInterface.get_resource_filesystem()
			editor_filesystem.scan()

	# Pass current scene in res:// filesystem to snap_manager
	#SceneSnapGlobal.current_scene = "res://local_scenes/" + self.name + ".tscn"

	return {
		files = [project_scenes_path.path_join(self.name + ".tscn")], # something like "res://assets/truck.tscn"
		type = "files",
	}

# FIXME TODO match drag and drop to panel change return false back to return true
func _can_drop_data(position, data):
	# NOTE Will need to get dependencies and copy them over to host filesystem at user://
	#return true
	return false
	#if debug: print(typeof(data))
	#return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(position, data):
	
	var file_paths = data["files"]
	
	for file_path: String in file_paths:
		await get_tree().process_frame
		await get_tree().create_timer(1).timeout
		var loaded_scene: PackedScene = load(file_path)
		#if debug: print("scene_full_path: ", scene_full_path)
		var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 4)
		var path_to_save_scene: String = shared_collections_path.path_join(scene_full_path_split[2].path_join(scene_full_path_split[3])) #scene_full_path_split[3] + "/"
		if debug: print("path_to_save_file uhduhaduhadh: ", path_to_save_scene)
		var new_sub_collection_tab: Control = get_parent().get_parent().get_parent().get_parent()
		#emit_signal("process_drop_data_from_scene_view", loaded_scene, path_to_save_scene, new_sub_collection_tab)
		emit_signal("process_drop_data_from_scene_view", file_path, path_to_save_scene, new_sub_collection_tab)
	
	
	
	
	
	## NOTE Will need to get dependencies and copy them over to project filesystem at res://
	#var scene = self.find_child("SubViewport").get_child(0)
	#var scene_path: String = scene.get_scene_file_path()
	#var file_paths = data["files"]
	#
	#for path in file_paths:
		#if debug: print(path)
		#if user_dir:
			## Skip reimporting if file exists # TODO add option to skip this step if user wants to overwrite existing scenes
			## TODO user defind storage location
			#if user_dir.file_exists(scene.get_scene_file_path() + path.get_file()):
				#if debug: print("file exists")
				#pass
#
			#else:
				#var result = user_dir.copy(path, scene.get_scene_file_path() + path.get_file())
				#if result == OK:
					##pass
					#if debug: print("File copied successfully.")
				#else:
					#if debug: print("Failed to copy file.")


#var set_min: bool = true
func set_size_flags() -> void:
	if debug: print("thumbnail_size_value: ", thumbnail_size_value)
	if thumbnail_size_value <= full_label_size:
		set_label_margins_full = false
	else:
		set_label_margins_full = true
	set_scene_view_size(thumbnail_size_value)

func get_collection_name() -> void:
	collection_name = scene_full_path.split("/")[-2].to_snake_case()


# NOTE: Called for every button in collection for every step in the slider so should reduce load by using flags
func set_scene_view_size(size: float) -> void:
	slider_value = size
	#if debug: print("size: ", size)

	var scale_size = slider_value / 256
	if child_sprite:
		child_sprite.scale = Vector2(scale_size, scale_size)

	self.custom_minimum_size.x = size
	self.custom_minimum_size.y = size * 1.3

	# File name
	if size <= min_label_size:
		if not set_file_name_visible:
			set_file_name_visible = true
			if debug: print("set file name hidden")
			tooltip_text = file_name
			margin_container.hide()

	else:
		if set_file_name_visible:
			set_file_name_visible = false
			if debug: print("set file name visible")
			tooltip_text = ""
			margin_container.custom_minimum_size.x = size * 0.8
			margin_container.show()

		# File name margins
		if size <= full_label_size:
			if not set_label_margins_full: # Our issue breaks if not initially moving from large to small
				set_label_margins_full = true
				if debug: print("set margins small")
				margin_container.add_theme_constant_override("margin_left", 30)
				margin_container.add_theme_constant_override("margin_right", 30)
				margin_container.add_theme_constant_override("margin_bottom", -20)

		elif size > full_label_size:
			if set_label_margins_full:
				set_label_margins_full = false
				if debug: print("set margins full")
				margin_container.add_theme_constant_override("margin_left", 0)
				margin_container.add_theme_constant_override("margin_right", 0)
				margin_container.add_theme_constant_override("margin_bottom", 20)

	# Heart icon
	if size <= min_heart_size:
		if not set_heart_visible:
			set_heart_visible = true
			if debug: print("set heart hidden")
			heart_texture_button.hide()
			circle_texture_button.show()
	else:
		if set_heart_visible:
			set_heart_visible = false
			if debug: print("set heart visible")
			circle_texture_button.hide()
			heart_texture_button.show()

	# 3D icon
	if size <= min_3d_label_size:
		if not set_3d_label_visible:
			set_3d_label_visible = true
			if debug: print("set 3d hidden")
			heart_aspect_ratio_container.set_stretch_mode(int(2)) # STRETCH_FIT
			label_aspect_ratio_container.hide()
			#animation_texture_button.hide()
			#texture_rect_body.hide()
			#texture_rect_collision.hide()
			#label_3dlod.hide()
	else:
		if set_3d_label_visible:
			set_3d_label_visible = false
			if debug: print("set 3d visible")
			heart_aspect_ratio_container.set_stretch_mode(int(3)) # STRETCH_COVER
			label_aspect_ratio_container.show()
			#if show_animation_texture_button:
				#animation_texture_button.show()

			#animation_texture_button.show()
			#
			#texture_rect_body.show()
			#texture_rect_collision.show()
			#label_3dlod.show()

	# Additionals
	if size <= min_additions_size:
		h_box_container_additions.hide()
		if debug: print("FIND REPLACEMENT INDICATOR FOR HIDDEN ADDITIONALS")
		#circle_texture_button.show()
	else:
		#circle_texture_button.hide()
		h_box_container_additions.show()


	#if size <= min_bclod_display_size:
		#texture_rect_body.hide()
		#texture_rect_collision.hide()
		#label_3dlod.hide()
	#else:
		## TODO Display if body or collision show both
		## TODO Display is LOD show LOD
		#texture_rect_body.show()
		#texture_rect_collision.show()
		#label_3dlod.show()
	# Show button only after thumbnail and button sizes set
	if initialize_show: 
		initialize_show = false
		visible = true









### FIXME sometimes really large or offset
#func _update_texture() -> void:
	#var scale_size = slider_value / 230
	## Get the new_sprite created in scene_viewer.gd and scale it to the slider size
	##var new_sprite: Node = self.find_child("NewSprite", true, false)
	##if debug: print("new_sprite: ", new_sprite)
	#thumbnail_texture.scale = Vector2(scale_size, scale_size)
	##thumbnail_texture.scale = Vector2(scale_size, scale_size)
	##if debug: print("scaling child: ", get_child(0).get_child(0))
	##get_child(0).get_child(0).scale = Vector2(scale_size, scale_size)
	##queue_redraw()






# Will need to get dependencies and copy them over to filesystem 

# FIXME Needs cleanup and consolidation
# NOTE: I don't know what I was doing here? 
# NOTE: This should update the scene preview to the button pressed
func _on_pressed() -> void:
	#EditorInterface.open_scene_from_path(scene_full_path, false)
	if allow_press and scene_full_path:# and thumbnail_cache_path:
		emit_signal("update_selected_scene_view_button", self)
		emit_signal("scene_snap_mode", scene_full_path)
		# HACK FIXME
		emit_signal("pass_up_scene_number", scene_number)
		# FIXME Will this get the same result for both below code?
		emit_signal("get_scene_number", get_parent().get_parent().get_parent().get_parent())
		#emit_signal("get_scene_number", main_collection_tab_parent)
		





# Pass focus to snap_manager to change scene preview
# FIXME utilize last selected and get_focus() to hold focus position even after placing object
func _on_focus_entered() -> void:
	#if debug: print("focused: ", self)
	emit_signal("scene_focused", scene_full_path, self)


func _on_heart_texture_button_toggled(toggled_on: bool) -> void:
	if debug: print("toggling heart button: ", main_collection_tab_parent)
	if toggled_on:
		circle_texture_button.button_pressed = true
		# HACK
		#if not get_parent().get_parent().get_parent().get_parent().name == "Favorites":
		if not main_collection_tab_parent == "Favorites":

			emit_signal("add_favorite", scene_full_path, false)
	else:
		circle_texture_button.button_pressed = false
		emit_signal("remove_favorite", scene_full_path, self)
		# HACK
		#if get_parent().get_parent().get_parent().get_parent().name == "Favorites":
		if main_collection_tab_parent == "Favorites":
			emit_signal("clear_favorite", scene_full_path, false, false)
		## Signal to hide button when collection tab heart filter is on and scene is removed from favorites
		#emit_signal("update_favorites", self)





func _on_circle_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		heart_texture_button.button_pressed = true
	else:
		heart_texture_button.button_pressed = false


func _on_animation_texture_button_pressed() -> void:
	animation_player_node.stop()
	play_animation_number += 1
	animation_texture_button.set_tooltip_text(play_animation(play_animation_number))



# FIXME Not sure how will react to more then one animationplayer I assume cycle through all animations in the scene
# FIXME cannot clear subviewport when playing animation
func play_animation(animation_number: int) -> String:
	var animation_player_node_instances: Array[Node] = scene.find_children("*", "AnimationPlayer", true, false)
	var animation_name: String
	for animation_player in animation_player_node_instances:
		animation_player_node = animation_player
		var animation_list: PackedStringArray = animation_player.get_animation_list()
		animation_name = animation_list[animation_number]

		#sub_viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
		sub_viewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
		
		#sub_viewport.set_update_mode(SubViewport.UPDATE_WHEN_VISIBLE)

		if animation_number >= animation_list.size() - 1:
			play_animation_number = 0

		var current_animation: Animation = animation_player.get_animation(animation_list[animation_number])
		
		current_animation.set_loop_mode(current_animation.LOOP_LINEAR)
		
		animation_player.play(animation_list[animation_number])

	return animation_name








func _on_animation_texture_button_mouse_entered() -> void:
	animation_texture_button.set_tooltip_text(play_animation(play_animation_number))
	# Stop camera 360 rotation
	rotate_scene = false



func _on_animation_texture_button_mouse_exited() -> void:
	if animation_player_node:
		animation_player_node.stop()
		# Resume camera 360 rotation check if exit bottom if stops like it should
		rotate_scene = true

#var selected_buttons: Array[Button] = []

#func _input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_SHIFT) and selected_texture_button.button_pressed:
		#for child: Button in get_parent_control().get_children():
			#if child.selected_texture_button.button_pressed:
				#selected_buttons.append(child)
				#if debug: print("last entered: ", selected_buttons.back().get_index())
				##if debug: print("child index: ", child.get_index())
		##if debug: print(get_parent_control().get_class())
		##if debug: print("button index: ", get_index())







## DUPLICATE FROM SCENE_SNAP_PLUGIN.GD
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
		var editor_filesystem = EditorInterface.get_resource_filesystem()
		editor_filesystem.scan()
		#if debug: print("filesystem was scanned")
		return true
	else:
		printerr("The directory: ", dir, " is not valid")
		return false



## CODE FROM GEMINI 2.0 FLASH
#func test() -> void:
	#var gltf_document = GLTFDocument.new()
	#var gltf_state = GLTFState.new()
#
	## --- IMPORTANT:  Choose ONE of these path options ---
#
	## Option 1: Absolute Path (Less portable)
	#var gltf_path = "C:/Users/YourName/Documents/Models/my_model.gltf" # Replace with your actual path
#
	## Option 2: Relative Path (More portable, but requires careful path construction)
	##  This assumes the gltf file is in a directory called "external_models"
	##  at the same level as your project.godot file.
	## var gltf_path = "../external_models/my_model.gltf"
#
	## ----------------------------------------------------
#
	## Check if the file exists (important for error handling)
	#var file = FileAccess.open(gltf_path, FileAccess.READ)
	#if file == null:
		#printerr("Error: Could not open glTF file at path: ", gltf_path)
		#return # Exit the function if the file can't be opened
	#file.close() # Close the file after checking
#
	## Import the scene
	#var scene = gltf_document.import_scene(gltf_path, gltf_state)
#
	#if scene:
		#add_child(scene)
	#else:
		#printerr("Failed to import glTF scene from: ", gltf_path)
#
#
#
#
#func test2() -> void:
	#var gltf_document = GLTFDocument.new()
	#var gltf_state = GLTFState.new()
#
	## Path to the glTF file in the user:// directory
	#var gltf_path = "user://models/my_model.gltf"
#
	## Check if the file exists
	#var file = FileAccess.open(gltf_path, FileAccess.READ)
	#if file == null:
		#printerr("Error: Could not open glTF file at path: ", gltf_path)
		#return
#
	#file.close()
#
	## Import the scene
	#var scene = gltf_document.import_scene(gltf_path, gltf_state)
#
	#if scene:
		#add_child(scene)
	#else:
		#printerr("Failed to import glTF scene from: ", gltf_path)




#func load_external_gltf(file_path: String) -> Node:
	#var gltf_scene = PackedScene.new()
	#var err = gltf_scene.pack(ResourceLoader.load(file_path))
	#if err != OK:
		#if debug: print("Error loading GLTF file: ", err)
		#return null
	#var instance = gltf_scene.instance()
	#return instance

#func _ready():
	#var external_gltf_path = "file:///path/to/your/external/file.gltf"
	#var loaded_scene = load_external_gltf(external_gltf_path)
	#if loaded_scene:
		#add_child(loaded_scene)



####################### ORIGINAL WORKING
## FIXME check if can reuse code from load_scene_instance() in scene_viewer.gd
#func _on_mouse_entered() -> void:
	## Show selection button
	#selected_texture_button.show()
	#if not tags_button.visible:
		#tags_button_not_active.show()
	#
	#
	##if not selected_texture_button.button_pressed:
		##remove_theme_stylebox_override("normal")
#
#
#
#
		##self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		##add_theme_stylebox_override("normal", selected_button_style_box)
		###self_modulate = Color(0.318, 0.318, 0.318, 0.882)
	##else:
		##remove_theme_stylebox_override("normal")
#
#
	#emit_signal("clear_selected_enabled", false)
	#emit_signal("enable_panel_button_sizing")
	#
	## Prep scene structure for loaded scene
	#sub_viewport_container = SUB_VIEWPORT_CONTAINER.instantiate()
	#v_box_container.add_child(sub_viewport_container)
	#v_box_container.move_child(sub_viewport_container, 0)
	#sub_viewport_container.name = "SubViewportContainer"
	#sub_viewport_container.owner = self
#
	## Load in scene
	#var scene: Node = load_scene_instance(scene_full_path)
	##if load_scene_instance(scene_full_path) == null:
		##scene = call_deferred("load_scene_instance").bind(scene_full_path)
	###var scene: Node = load_scene_instance(scene_full_path)
	##else:
		##scene = load_scene_instance(scene_full_path)
#
	#sub_viewport = sub_viewport_container.get_child(0)
#
	##sub_viewport_container.position = Vector2(0.0, -20.0)
	#sub_viewport.size = Vector2(slider_value, slider_value)
#
	## Reload button with scene and 3d camera rotation
	#emit_signal("reload_scene", self, scene, scene_full_path, sub_viewport)
#
	#thumbnail_texture = v_box_container.find_child("NewSprite", true, false)
	#thumbnail_texture.hide()
#
	## Apply 360 rotation
	#camera_gimbal = sub_viewport.find_child("NewCamera3D", true, false)
	#rotate_scene = true





#func deferred_mouse_exit() -> void:
	#if thumbnail_texture and sub_viewport_container:
		#thumbnail_texture.show()
		#rotate_scene = false
		## Move down to physics process because of load delay
		#sub_viewport_container.queue_free()
		##sub_viewport_container.free()
#
#
#
		#emit_signal("clear_selected_enabled", true)



# NOTE: Other objects handled in scene_viewer.gd reload_scene_view_button() with loading scene delay from thread
func _on_mouse_exited() -> void:
	if not multi_select_box:
		update_tags_icon()
		#tags_button_not_active.hide()


		if selected_texture_button.button_pressed:
			selected_texture_button.show()
		else:
			selected_texture_button.hide()

## ORIGINAL
		#if thumbnail_texture and sub_viewport_container:
			#thumbnail_texture.show()
			#rotate_scene = false
			#sub_viewport_container.queue_free()
			##sub_viewport_container.free()

# TEST
		#call_deferred("deferred_mouse_exit")
		#if thumbnail_texture and sub_viewport_container:
			#thumbnail_texture.show()
			#rotate_scene = false
			## Move down to physics process because of load delay
			#sub_viewport_container.queue_free()
			##sub_viewport_container.free()
#
#
#
			#emit_signal("clear_selected_enabled", true)


### Will load .gltf and play 360 mesh on mouse entered
#func load_glb_for_360_view() -> Node:
	#var base_path: String
	#var scene_instance: Node
#
	#if scene_full_path.begins_with("res:"):
		#base_path = scene_full_path
	#else:
		#
		#var scene_full_path_split: PackedStringArray = scene_full_path.split("/", false, 0)
		#if debug: print("scene_full_path_split: ", scene_full_path_split)
		##var path_to_save_scene: String = shared_collections_path.path_join(scene_full_path_split[2].path_join(scene_full_path_split[3]))
		#base_path = project_scenes_path.path_join(scene_full_path_split[2].path_join(scene_full_path_split[3]))
		#if debug: print("base_path: ", base_path)
		#
#
	#var gltf := GLTFDocument.new()
	#gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
#
	#var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
	#if scene_file:
		#var file_bytes = scene_file.get_buffer(scene_file.get_length())
		#scene_file.close()
#
		#var gltf_state := GLTFState.new()
		#gltf.append_from_buffer(file_bytes, base_path, gltf_state, 8)
#
		#scene_instance = gltf.generate_scene(gltf_state)
#
	#return scene_instance


##var thread = Thread.new()
## Thread start
## FIXME Check if loaded_threaded can be used here
########################## ORIGINAL WORKS 
#
#func load_scene_instance(scene_full_path: String) -> Node:
	#
	##var start: int = Time.get_ticks_msec()
	#var scene_instance: Node
	#if scene_full_path.get_extension() == "glb":# or scene_full_path.get_extension() == "gltf":
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
#
				## Get the path in the res:// project filesystem where we will store the textures.
				#var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures".path_join("/")))
				##var imported_textures_path: String = project_scenes_path.path_join(scene_full_path.split("/")[-2].path_join("textures/"))
				## Pass in the path of imported textures
				## NOTE: Gives out of index error sometimes but when working will import the textures when mouse entered
				## .glb will stop to import textures for each button hovered
				## .gltf with the textures folder copied in on start will load quickly 
				#gltf.append_from_buffer(file_bytes, imported_textures_path, gltf_state, 8)
				## NOTE: Gives Warning:
				##gltf.append_from_buffer(file_bytes, "", gltf_state, 8)
				## NOTE: Unpacks in the user:// dir and Gives ERROR: Can't find file 'user://....' during file reimport
				##gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
				## NOTE with textures already compressed and added with .import files to textures folder in user://
				##gltf.append_from_buffer(file_bytes, scene_full_path.path_join("textures".path_join("/")), gltf_state, 8)
#
				#var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
				#for mesh in meshes:
					#if debug: print("mesh: ", mesh)
#
				#scene_instance = gltf.generate_scene(gltf_state)
		##var end: int = Time.get_ticks_msec()
		##if debug: print("total .glb load time: ", end - start)
#
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	#return scene_instance
#
		### Yield the thread to prevent it from blocking the main thread
		##await get_tree().process_frame
#
#
##var load_and_rotate_scene: bool = false

var continue_function: bool = false

#func _on_mouse_entered() -> void:
	#if debug: print("scene_full_path: ", scene_full_path)
	#if debug: print("collection_name: ", collection_name)
	#if not scene_full_path.is_empty() and not collection_name.is_empty():
		##if debug: print("get_scene_ready_state")
		#emit_signal("get_scene_ready_state", collection_name, scene_full_path)
	## NOTE: check needs to be done here for if collection_lookup[collection_name][scene_full_path] has scene instance
	#await get_tree().process_frame # allow time to get return scene_ready state of from signal above 
	##if debug: print("scene_ready: ", scene_ready)
	#if not multi_select_box and scene_ready:
		## Show selection button
		#selected_texture_button.show()
		#if not tags_button.visible:
			#tags_button_not_active.show()
#
		#emit_signal("clear_selected_enabled", false)
		#emit_signal("enable_panel_button_sizing")
#
		### Only load scene if hovered for more then 1.0 secs
		##await get_tree().create_timer(1).timeout # Do not open unless hovering for 1.0
		##if is_hovered(): # After 1.0 check if still hovering
#
		## Prep scene structure for loaded scene
		#if not find_child("SubViewportContainer", false, false):
			##if debug: print("Creating new SubViewportContainer for button")
			#sub_viewport_container = SUB_VIEWPORT_CONTAINER_SCENE.instantiate()
			#add_child(sub_viewport_container) # THE LOADED SCENE
			## Center loaded scene on button
			#sub_viewport_container.position = Vector2(0.0, 13.0)
#
			## Hide so does not share same space with Sprite2D
			#sub_viewport_container.hide() 
#
			## Move the loaded scene viewport to position 0 to replace thumbnail sprite
			##move_child(sub_viewport_container, 0)
			#sub_viewport_container.name = "SubViewportContainer"
			#sub_viewport_container.owner = self
#
		#else:
			#push_warning("SubViewportContainer exists and was not properly freed during the _process function")
#
		#sub_viewport = sub_viewport_container.get_child(0)
		#sub_viewport.size = Vector2(slider_value, slider_value)
#
		## Reload button with scene and 3d camera rotation
		#emit_signal("reload_scene", self, scene_full_path, sub_viewport)
#
			### Set default textures for 360 mesh preview
		##emit_signal("set_scenes_default_materials", scene_full_path, -1, null)

# FIXME Disable on box selection
func _on_mouse_entered() -> void:
	if debug: print("scene_full_path: ", scene_full_path)
	if debug: print("collection_name: ", collection_name)
	if not scene_full_path.is_empty() and not collection_name.is_empty():
		#if debug: print("get_scene_ready_state")
		emit_signal("get_scene_ready_state", collection_name, scene_full_path)
	# NOTE: check needs to be done here for if collection_lookup[collection_name][scene_full_path] has scene instance
	await get_tree().process_frame # allow time to get return scene_ready state of from signal above 
	#if debug: print("scene_ready: ", scene_ready)
	if not multi_select_box and scene_ready:
		# Show selection button
		selected_texture_button.show()
		# FIXME MERGE BUTTONS
		update_tags_icon(true)
		#if not tags_button.visible:
			#tags_button_not_active.show()

		emit_signal("clear_selected_enabled", false)
		emit_signal("enable_panel_button_sizing")

		## Only load scene if hovered for more then 1.0 secs
		#await get_tree().create_timer(1).timeout # Do not open unless hovering for 1.0
		#if is_hovered(): # After 1.0 check if still hovering

		# Prep scene structure for loaded scene
		if not find_child("SubViewportContainer", false, false):
			#if debug: print("Creating new SubViewportContainer for button")
			sub_viewport_container = SUB_VIEWPORT_CONTAINER_SCENE.instantiate()
			add_child(sub_viewport_container) # THE LOADED SCENE
			# Center loaded scene on button
			sub_viewport_container.position = Vector2(0.0, 13.0)

			# Hide so does not share same space with Sprite2D
			sub_viewport_container.hide() 

			# Move the loaded scene viewport to position 0 to replace thumbnail sprite
			#move_child(sub_viewport_container, 0)
			sub_viewport_container.name = "SubViewportContainer"
			sub_viewport_container.owner = self

		else:
			push_warning("SubViewportContainer exists and was not properly freed during the _process function")

		sub_viewport = sub_viewport_container.get_child(0)
		sub_viewport.size = Vector2(slider_value, slider_value)

		# Reload button with scene and 3d camera rotation
		emit_signal("reload_scene", self, scene_full_path, sub_viewport)

			## Set default textures for 360 mesh preview
		#emit_signal("set_scenes_default_materials", scene_full_path, -1, null)




## FIXME Disable on box selection
#func _on_mouse_entered() -> void:
	#if not multi_select_box:
		## Show selection button
		#selected_texture_button.show()
		#if not tags_button.visible:
			#tags_button_not_active.show()
		#
		#
		##if not selected_texture_button.button_pressed:
			##remove_theme_stylebox_override("normal")
#
#
#
#
			##self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			##add_theme_stylebox_override("normal", selected_button_style_box)
			###self_modulate = Color(0.318, 0.318, 0.318, 0.882)
		##else:
			##remove_theme_stylebox_override("normal")
		##await get_tree().create_timer(1.15).timeout # Do not open unless hovering for .15
		##if self.is_hovered(): # After .15 check if still hovering
#
		#emit_signal("clear_selected_enabled", false)
		#emit_signal("enable_panel_button_sizing")
#
		### FIXME Causes  ERROR: res://addons/scene_snap/scripts/scene_view.gd:632 - Cannot call method 'queue_free' on a previously freed instance.
		### Only load scene if hovered for more then 1.0 secs
		### Used when not multi-threading as loading scene will block main thread
		##await get_tree().create_timer(1.0).timeout # Do not open unless hovering for 1.0
		##if is_hovered(): # After 1.0 check if still hovering
#
		###await get_tree().process_frame
		##await get_tree().create_timer(3).timeout # Do not open unless hovering for 1.0
		##if is_hovered(): # After 1.0 check if still hovering
#
		## FIXME Somewhere things are getting shifted around 
		## Maybe match size and position of image to viewport and back when switching?
		## Prep scene structure for loaded scene
		## TEST removing new sprite
		#v_box_container.get_child(0).hide()
		##v_box_container.remove_child(v_box_container.get_child(0))
		#if debug: print("children: ", v_box_container.get_children())
		#if debug: print("child0: ", v_box_container.get_child(0))
		#sub_viewport_container = SUB_VIEWPORT_CONTAINER.instantiate()
		#v_box_container.add_child(sub_viewport_container)
		#v_box_container.move_child(sub_viewport_container, 0)
		#sub_viewport_container.name = "SubViewportContainer"
		#sub_viewport_container.owner = self
#
		#if debug: print("children again: ", v_box_container.get_children())
		#if debug: print("child0: ", v_box_container.get_child(0))
#
		## Await so that does not load immediatly on mouse enter
		## Load in scene
		##emit_signal("load_scene_instance", scene_full_path)
		##var scene: Node = load_scene_instance(scene_full_path)
		##if load_scene_instance(scene_full_path) == null:
			##scene = call_deferred("load_scene_instance").bind(scene_full_path)
		###var scene: Node = load_scene_instance(scene_full_path)
		##else:
			##scene = load_scene_instance(scene_full_path)
#
		#sub_viewport = sub_viewport_container.get_child(0)
#
		##sub_viewport_container.position = Vector2(0.0, -20.0)
		##sub_viewport_container.position = Vector2(0.0, 20.0)
		#sub_viewport.size = Vector2(slider_value, slider_value)
#
#
		## Reload button with scene and 3d camera rotation
		#emit_signal("reload_scene", self, scene, scene_full_path, sub_viewport)
		##await get_tree().process_frame
		## Hold flag to wait for scene to finish loading from drive
		#while not continue_function:
			#await get_tree().process_frame
#
		##thumbnail_texture = v_box_container.find_child("NewSprite", true, false)
		##thumbnail_texture.hide()
#
		## Apply 360 rotation
		#camera_gimbal = sub_viewport.find_child("NewCamera3D", true, false)
		##if debug: print("camera_gimbal: ", camera_gimbal)
		#
		#if is_hovered():
			#rotate_scene = true



## Callback function once the scene is fully loaded
#func _on_scene_loaded(scene_full_path: String) -> void:
	## After loading, we can now call load_scene_instance safely
	#var scene: Node = load_scene_instance(scene_full_path)
	#
	## Set up SubViewport
	#sub_viewport = sub_viewport_container.get_child(0)
	#sub_viewport.size = Vector2(slider_value, slider_value)
#
	## Reload button with scene and 3D camera rotation
	#emit_signal("reload_scene", self, scene, scene_full_path, sub_viewport)
#
	#thumbnail_texture = v_box_container.find_child("NewSprite", true, false)
	#thumbnail_texture.hide()
#
	## Apply 360 rotation
	#camera_gimbal = sub_viewport.find_child("NewCamera3D", true, false)
	#rotate_scene = true



#var gltf_loader: GLTFLoader
#var scene_instance: Node = null
#var is_loading: bool = false  # Flag to track if the scene is still loading
##var thread = Thread.new()
## Thread start
## FIXME Check if loaded_threaded can be used here
#func load_scene_instance(scene_full_path: String) -> Node:
	#
	#var start: int = Time.get_ticks_msec()
	#
	#if is_loading:
		## Return the scene if it is already loaded or still loading
		#return scene_instance
	#
	#is_loading = true  # Set the loading flag
	#
	#var scene_instance: Node
	#if scene_full_path.get_extension() == "glb" or scene_full_path.get_extension() == "gltf":
		#if scene_full_path.begins_with("res://"):
			#var scene_loaded: PackedScene = load(scene_full_path)
			#scene_instance = scene_loaded.instantiate()
		#else:
			##gltf_loader = GLTFLoader.new("res://path/to/your_scene.gltf")
			## Create GLTFLoader instance
			#gltf_loader = GLTFLoader.new(scene_full_path)
			#var start_result = gltf_loader.load_gltf_async()
			#if start_result == OK:
				#if debug: print("Thread started successfully.")
			#else:
				#if debug: print("Failed to start thread.")
			### Will load and create thumbnail for mesh
			##var gltf := GLTFDocument.new()
			##gltf.register_gltf_document_extension(GLTFDocumentExtensionConvertImporterMesh.new(), true)
			##
			##var scene_file = FileAccess.open(scene_full_path, FileAccess.READ)
			##if scene_file:
				##var file_bytes = scene_file.get_buffer(scene_file.get_length())
				##scene_file.close()
				##
				##var gltf_state := GLTFState.new()
				###var base_path: String = "res://collections/test/"
				###var base_path: String = ""
				### FIXME Check if in "res://collections" if not copy in and then reference that?
				##gltf.append_from_buffer(file_bytes, scene_full_path, gltf_state, 8)
##
				##var meshes = gltf_state.get_meshes() # get meshes from the GLTFState
				##for mesh in meshes:
					##if debug: print("mesh: ", mesh)
##
				##scene_instance = gltf.generate_scene(gltf_state)
		#var end: int = Time.get_ticks_msec()
		#if debug: print("total .glb load time: ", end - start)
#
	#else:
		## NOTE Need to turn .obj into PackedScene or reconfigure
		#var scene_loaded: PackedScene = load(scene_full_path)
		#scene_instance = scene_loaded.instantiate()
#
	#return scene_instance
#
		### Yield the thread to prevent it from blocking the main thread
		##await get_tree().process_frame




## _process method to check the thread status
#func _process(delta: float) -> void:
	#if gltf_loader and gltf_loader.is_alive():
		#if debug: print("GLTF Loader is still running...")
	#elif gltf_loader and gltf_loader.is_started():
		#if debug: print("GLTF Loader has finished.")
		#var scene_instance = gltf_loader.wait_for_result()
		#if scene_instance:
			#if debug: print("scene_instance: ", scene_instance)
			#scene_instance = scene_instance
			##add_child(scene_instance)
			##scene_instance.owner = self  # Set the owner of the loaded scene instance
		#else:
			#if debug: print("Failed to load GLTF scene")
		#gltf_loader = null  # Clear the reference after use to allow cleanup
		#is_loading = false  # Reset loading flag


var camera_gimbal: Node3D
var rotate_scene: bool = false


func _physics_process(delta: float) -> void:
	#if debug: print("shared tags: ", shared_tags)
	#if debug: print("collection_name: ", collection_name)
	#if debug: print("thumbnail_size_value: ",thumbnail_size_value)
	#set_scene_view_size(thumbnail_size_value)
	#if debug: print("thumbnail_texture postion: ", thumbnail_texture.position)
	#_update_texture()
	# TODO Make adjustable?
	if rotate_scene and camera_gimbal:
		camera_gimbal.rotation.y += 0.5 * delta

	#if debug: print(slider_value)

	## NOTE: Run here because sometimes scene loading finishes after mouse_exit and need to cleanup 
	## NOTE: Moved from on mouse exit because of delay, Another option is to keep a list of buttons entered and remove from queue?
	#if sub_viewport_container and child_sprite and not is_hovered():
		##if debug: print("removing scene instance 2")
		#
		## Get and remove the loaded scene file so that it is not freed from memory
		#var scene: Node = sub_viewport_container.get_child(0).get_child(0)
		#sub_viewport_container.get_child(0).remove_child(scene)
		##if debug: print("sub_viewport children: ", sub_viewport_container.get_child(0).get_children())
		#sub_viewport_container.queue_free()
		##sub_viewport_container.hide()
		##_update_texture()
		#
		##child_sprite.size = Vector2(slider_value, slider_value)
		##if debug: print("margin_container position: ", margin_container.position)
		##move_child(child_sprite, 0)
		#child_sprite.show()
		##if debug: print("margin_container position: ", margin_container.position)
		#
		##if debug: print("sprite scale 1", get_child(0).get_child(0).scale)
		##_update_texture()
		##if debug: print("sprite scale 2", get_child(0).get_child(0).scale)
		##if debug: print("sub_viewport_container size: ", sub_viewport_container.size)
		##if debug: print("sub_viewport_container position: ", sub_viewport_container.position)
		##child_sprite
		##if debug: print("child_sprite.size: ", child_sprite.get_rect())
		##if debug: print("self size", self.size)
		#rotate_scene = false
		##var sub_viewport_containers: Array[Node] = v_box_container.find_children("*", "SubViewportContainer", false, false)
		###if debug: print("sub_viewport_containers: ", sub_viewport_containers)
		##for container: SubViewportContainer in sub_viewport_containers:
		#
		#
		##if debug: print("texture size: ", child_sprite.get_texture().get_size())
#
		#emit_signal("clear_selected_enabled", true)


func _process(delta: float) -> void:
	# NOTE: Run here because sometimes scene loading finishes after mouse_exit and need to cleanup 
	# NOTE: Moved from on mouse exit because of delay, Another option is to keep a list of buttons entered and remove from queue?
	if sub_viewport_container and child_sprite and scene_ready and not is_hovered():
		#if debug: print("removing scene instance 2")
		
		# Get and remove the loaded scene file so that it is not freed from memory
		#if sub_viewport_container.get_child(0).name == "SubViewport" and sub_viewport_container.get_child(0).get_child(0).name == "Node3D":
		#if debug: print("sub_viewport_container.get_child(0): ", sub_viewport_container.get_child(0))
		#if debug: print("sub_viewport_container.get_child(0).get_child(0): ", sub_viewport_container.get_child(0).get_child(0))
		#if sub_viewport_container.get_child_count() > 0:
		var scene: Node = sub_viewport_container.get_child(0).get_child(0)
		sub_viewport_container.get_child(0).remove_child(scene)
		#if debug: print("sub_viewport children: ", sub_viewport_container.get_child(0).get_children())
		sub_viewport_container.queue_free()
		#sub_viewport_container.hide()
		#_update_texture()
		
		#child_sprite.size = Vector2(slider_value, slider_value)
		#if debug: print("margin_container position: ", margin_container.position)
		#move_child(child_sprite, 0)
		child_sprite.show()
		#if debug: print("margin_container position: ", margin_container.position)
		
		#if debug: print("sprite scale 1", get_child(0).get_child(0).scale)
		#_update_texture()
		#if debug: print("sprite scale 2", get_child(0).get_child(0).scale)
		#if debug: print("sub_viewport_container size: ", sub_viewport_container.size)
		#if debug: print("sub_viewport_container position: ", sub_viewport_container.position)
		#child_sprite
		#if debug: print("child_sprite.size: ", child_sprite.get_rect())
		#if debug: print("self size", self.size)
		rotate_scene = false
		#var sub_viewport_containers: Array[Node] = v_box_container.find_children("*", "SubViewportContainer", false, false)
		##if debug: print("sub_viewport_containers: ", sub_viewport_containers)
		#for container: SubViewportContainer in sub_viewport_containers:
		
		
		#if debug: print("texture size: ", child_sprite.get_texture().get_size())

		emit_signal("clear_selected_enabled", true)



func _on_selected_texture_button_toggled(toggled_on: bool) -> void:
	if get_parent():
		#if debug: print("main_collection_tab_parent: ", main_collection_tab_parent)
		#if debug: print("parent name: ", get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().name)
		# Get all the scenes in the collection
		var scene_buttons: Array[Node] = get_parent().get_children()
		#if debug: print("scene_buttons: ", scene_buttons)
		# filter out Node2D MultiSelectBox here so (button is Button) not required everywhere used
		if scene_buttons:
			scene_buttons = scene_buttons.filter(func(button) -> bool: return button is Button)
		
		if toggled_on:
			emit_signal("button_selected", self, scene_buttons, true)
		else:
			#if debug: print("working")
			emit_signal("button_selected", self, scene_buttons, false)

	#if self.name == "Favorites":
		#scene_buttons.clear()




func _on_multiple_mesh_glb_pressed() -> void:
	if debug: print("button pressed")
	pass # Replace with function body.


func _on_multiple_mesh_glb_mouse_entered() -> void:
	if debug: print("show popup")
	pass # Replace with function body.


func _on_multiple_mesh_glb_mouse_exited() -> void:
	if debug: print("hide popup")
	pass # Replace with function body.


@onready var pointer: Vector2

func _input(event):
	if InputEventMouseButton.new().is_pressed():
		pointer = event.position
		

	#if event.pressed:
		#pointer = event.position

var new_editor_plugin_instance: EditorPlugin = EditorPlugin.new()
#func signal_open_tag_panel() -> void:
	#emit_signal("open_tag_panel", self.name)
	#if debug: print("openning tag panel now")

#var new_tag_panel_popup: Control = null
var close_panel_on_exit: bool = true

# FIXME PASS UP OPEN PANELS TO DO CHECK BETWEEN OTHER SCENE-VIEW OPEN PANELS
func open_tag_panel(open: bool) -> void:
	#emit_signal("remove_open_tag_panel", new_tag_panel)
	
	#var new_tag_panel_popup: Control = TAG_PANEL_POPUP.instantiate()
	# FIXME should be moved to plugin.gd and on ready added with hide and show used here
	# although new each time will reset it to default without need to clear so maybe keep like this

	if debug: print("new_tag_panel: ", new_tag_panel)
	if debug: print("open: ", open)
	# FIXME does not account for when closing dock through ui would need to reset flag then
	if open:
		#if new_tag_panel:
			#open_tag_panel(false)
		
		#emit_signal("toggle_")
		
		#if new_tag_panel: # If button was clicked and panel already exists do not close when mouse exits
			#close_panel_on_exit = false
		#if not new_tag_panel:
			#close_panel_on_exit = true


		
		new_tag_panel = TAG_PANEL.instantiate()
		new_tag_panel.tag_added_or_removed.connect(pass_up_scene_tag_added_or_removed)
		#emit_signal("remove_open_tag_panel", new_editor_plugin_instance, new_tag_panel)
		
		
		new_tag_panel.scene_view = self
		#add_child(new_tag_panel_popup)
		#new_tag_panel_popup.set_owner(self)
		
		# FIXME Make so that will reopen in the same location closed or last session
		new_editor_plugin_instance.add_control_to_dock(new_editor_plugin_instance.DOCK_SLOT_RIGHT_BL, new_tag_panel)
	else: # Close panel when button clicked a second time
		if new_tag_panel:# and tag_panel_hover_opened:# and close_panel_on_exit:
			new_editor_plugin_instance.remove_control_from_docks(new_tag_panel)
			new_tag_panel.queue_free()
			new_tag_panel = null
		#_on_tags_button_active_mouse_exited()
		

	
	#await get_tree().create_timer(115).timeout
	#
	#new_editor_plugin_instance.remove_control_from_docks(new_tag_panel_popup)
	#if debug: print("get_global_mouse_position(): ", get_global_mouse_position())
	##new_tag_panel_popup.set_position(get_global_mouse_position())
	#new_tag_panel_popup.hide()
	#new_tag_panel_popup.position = pointer
	#new_tag_panel_popup.show()
	#new_tag_panel_popup.position = get_global_mouse_position()
	#new_tag_panel_popup.set_position(DisplayServer.mouse_get_position())

	## Get the global mouse position in screen coordinates
	#var mouse_pos = get_global_mouse_position()
#
	## Convert the global mouse position to the local coordinates of the parent node
	#var local_pos = new_tag_panel_popup.get_parent().get_global_transform().affine_inverse() * mouse_pos
#
	## Set the position of the new_tag_panel_popup to the local coordinates
	#new_tag_panel_popup.position = local_pos








## Pass up scene_full_path to exclude non changed from saving
func pass_up_scene_tag_added_or_removed(tagged_scene_full_path: String) -> void:
	emit_signal("scene_tag_added_or_removed", tagged_scene_full_path)
	#var tag_count: int = shared_tags.size() + global_tags.size()
	#emit_signal("scene_tag_count", scene_full_path, tag_count)




# Clear shared tags 1s timer
var timer: Timer
var timer_started: bool = false
var allow_press: bool = true

### If active tags button is held down for longer then 1 second will also clear Shared Tags
func _on_tags_button_active_button_down() -> void:
	allow_press = false # Ignore so mouse that is passed up to button does not trigger scene_preview
	if Input.is_key_pressed(KEY_SHIFT):
		timer_started = true
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.start(1)
		if debug: print("down")



func _on_tags_button_active_button_up() -> void:
	if timer_started and timer.time_left == 0.0:
		emit_signal("clear_tags", true, self)
		emit_signal("scene_tag_added_or_removed", scene_full_path)

		if debug: print("clear shared tags too")
	# Reset timer_started
	timer_started = false
	# Re-enable scene_preview after delay
	await get_tree().create_timer(0.1).timeout 
	allow_press = true



# FIXME Tag Panel tags are not refreshed to show tags removed
# FIXME CHANGE COLOR OF TAGS BUTTON ICON TO BLUE WHEN OPEN?
func _on_tags_button_active_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		emit_signal("clear_tags", false, self)
		emit_signal("scene_tag_added_or_removed", scene_full_path)
		# HACK # To refresh tag panel tags FIXME Only if already open when 
		# If tag panel open:
		# FIXME ERRORS WHEN PANEL CLOSE AND CLEARING TAGS?
		# ERROR: res://addons/scene_snap/scripts/tag_panel.gd:108 - Invalid call. Nonexistent function 'set_text' in base 'Nil'.
		emit_signal("toggle_tag_panel", self)
		emit_signal("toggle_tag_panel", self)

	else: # Open the tag panel on button down if KEY_SHIFT not pressed.
		emit_signal("toggle_tag_panel", self)




func _on_tags_button_not_active_pressed() -> void:
	emit_signal("toggle_tag_panel", self)

## Update the icon for the tags button based on filled tags and sharing settings
func update_tags_icon(mouse_entered: bool = false) -> void:
	# No Tags or shared tags with sharing disabled
	if global_tags.is_empty() and shared_tags.is_empty() or (global_tags.is_empty() and not shared_tags.is_empty() and sharing_disabled): 
		if sharing_disabled: # # TODO Add Settings sharing disabled check here
			tags_button.set_texture_normal(TAG_NOT_ACTIVE)
		else:
			tags_button.set_texture_normal(TAGS_NOT_ACTIVE)

		if mouse_entered:
			tags_button.show()
		else:
			tags_button.hide()
		return

	# Either Global or Shared tags when sharing enabled
	if (global_tags.is_empty() and not shared_tags.is_empty()) \
	or (not global_tags.is_empty() and shared_tags.is_empty()): 
		tags_button.set_texture_normal(TAG)

	# Both Global and Shared tags. Changed based on sharing enabled/diabled
	else:
		if sharing_disabled: 
			tags_button.set_texture_normal(TAG)
		else:
			tags_button.set_texture_normal(TAGS)
	tags_button.show()




var new_tag_panel: Control = null
var tag_panel_hover_opened: bool = false

#func _on_tags_button_active_mouse_entered() -> void:
	#await get_tree().create_timer(.15).timeout # Do not open unless hovering for .15
	#if tags_button.is_hovered(): # After .15 check if still hovering
		#tag_panel_hover_opened = true
		#var open: bool = true
		#open_tag_panel(open)
		##new_tag_panel_popup = TAG_PANEL.instantiate()
		###new_tag_panel_popup.set_owner(self)
		##new_editor_plugin_instance.add_control_to_dock(new_editor_plugin_instance.DOCK_SLOT_RIGHT_BL, new_tag_panel_popup)
#
#
#func _on_tags_button_active_mouse_exited() -> void:
	#if new_tag_panel and tag_panel_hover_opened and close_panel_on_exit:
		#new_editor_plugin_instance.remove_control_from_docks(new_tag_panel)
		#new_tag_panel.queue_free()
		#new_tag_panel = null
