@tool
extends HBoxContainer
signal open_graph_editor
signal create_snap_plane
signal clear_virtual_planes
signal change_path_shape_3d ## Change the Path3D line type.
#signal enable_create_as_line ## Toggle the Path3D from creating line to free draw. 
#const SNAP_MANAGER_GRAPH = preload("res://addons/scene_snap/plugin_scenes/snap_manager_graph.tscn")
#var snap_manager_graph: CustomGraphEdit

@onready var grap_edit_button: Button = $GrapEditButton
#@onready var change_draw_line: Button = $ChangeDrawLine
@onready var path_shape_3d_button: Button = $PathShape3DButton


const PATH_3D_LINE = preload("res://addons/scene_snap/icons/Path3DLine.svg")



func _ready() -> void:
	grap_edit_button.set_button_icon(get_theme_icon(&"GraphEdit", &"EditorIcons"))

func _on_grap_edit_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		emit_signal("open_graph_editor", true)
	else:
		emit_signal("open_graph_editor", false)
	#snap_manager_graph = SNAP_MANAGER_GRAPH.instantiate()
	#EditorPlugin.add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, snap_manager_graph)
	
	#pass # Replace with function body.


func _on_create_snap_plane_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		emit_signal("clear_virtual_planes") 
		print("clear all virtual planes")
	else:
		emit_signal("create_snap_plane", true)


#func _on_create_snap_plane_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#emit_signal("create_snap_plane", true)
	#else:
		#emit_signal("create_snap_plane", false)


#func _on_change_draw_line_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#path_shape_3d_button.set_button_icon(PATH_3D_LINE)
		#emit_signal("enable_create_as_line", true)
	#else:
		#path_shape_3d_button.set_button_icon(get_theme_icon(&"Path3D", &"EditorIcons"))
		#emit_signal("enable_create_as_line", false)




### TODO Update later for additional shapes square and circle.
#enum Path_3D_State {
	#PATH3DLINE,
	#PATH3DDRAW,
	##PATH3DSQUARE,
	##PATH3DCIRCLE,
#}
#
#var next_3d_path_state: Path_3D_State = Path_3D_State.PATH3DLINE
#
## Function to toggle state in the given direction
#func toggle_3d_path_state(direction: int) -> void:
	## Get the current index of the state using the enum values
	#var current_index = int(next_3d_path_state)
	## Move up (direction = 1) or down (direction = -1)
	#current_index += direction
	## Wrap around if needed (ensure index stays within bounds)
	#if current_index < 0:
		#current_index = Path_3D_State.size() - 1
	#elif current_index >= Path_3D_State.size():
		#current_index = 0
	#
	## Update the next state (use the enum value by its index)
	#next_3d_path_state = Path_3D_State.values()[current_index]
	#update_3d_path_state_button()
	### TODO make func so that both buttons can call and do same check when pressed
	##do_button_conflict_matching()
#
#
## FIXME "Multiple Convex" shape very small and giving ERROR: res://addons/scene_snap/scene_snap_plugin.gd:3722 - Trying to assign invalid previously freed instance.
#
## Function to update the button and tooltip based on the current state
#func update_3d_path_state_button() -> void:
	#push_error("updating button")
	#match next_3d_path_state:
		#Path_3D_State.PATH3DLINE:
			#path_shape_3d_button.set_button_icon(PATH_3D_LINE)
			#path_shape_3d_button.tooltip_text = "Line"
		#Path_3D_State.PATH3DDRAW:
			#path_shape_3d_button.set_button_icon(get_theme_icon("Path3D", "EditorIcons"))
			#path_shape_3d_button.tooltip_text = "Draw"
		### NOTE: Stubbed out for additional path shapes. 
		##Path_3D_State.PATH3DSQUARE:
			##path_shape_3d_button.set_button_icon(get_theme_icon("CapsuleShape3D", "EditorIcons"))
			##path_shape_3d_button.tooltip_text = "CapsuleShape3D"
		##Path_3D_State.PATH3DCIRCLE:
			##path_shape_3d_button.set_button_icon(get_theme_icon("CylinderShape3D", "EditorIcons"))
			##path_shape_3d_button.tooltip_text = "CylinderShape3D Note: CapsuleShape3D or BoxShape3D is recommended due to known bugs with cylinder path shapes."
#
#
## Toggle up function (Move forward in the list)
#func toggle_3d_path_state_up() -> void:
	#toggle_3d_path_state(-1)
	#update_path_shape_3d_variables()
#
## Toggle down function (Move backward in the list)
#func toggle_3d_path_state_down() -> void:
	#toggle_3d_path_state(1)
	#update_path_shape_3d_variables()
#
#var current_3d_path_state: String = "" 
#
## Button press handler
#func _on_change_path_shape_3d_button_pressed() -> void:
	#toggle_3d_path_state_down()  # Example: Change state down when the button is pressed
	##path_shape_3d_info()
#
#
#func update_path_shape_3d_variables() -> void:
	#current_3d_path_state = Path_3D_State.find_key(next_3d_path_state) # Get path name as string
	##path_3d_number.set_text(str(next_3d_path_state))
	#emit_signal("change_path_shape_3d", current_3d_path_state)



enum Path3DState {
	LINE,
	DRAW,
	# SQUARE,
	# CIRCLE,
}

var current_state: Path3DState = Path3DState.DRAW  # initial state

func _on_change_path_shape_3d_button_pressed() -> void:
	# rotate state
	current_state = Path3DState.values()[(int(current_state) + 1) % Path3DState.size()]
	_update_path_shape_ui_and_state()

func _update_path_shape_ui_and_state() -> void:
	match current_state:
		Path3DState.LINE:
			path_shape_3d_button.set_button_icon(PATH_3D_LINE)
			path_shape_3d_button.tooltip_text = "Line"
		Path3DState.DRAW:
			path_shape_3d_button.set_button_icon(get_theme_icon("Path3D", "EditorIcons"))
			path_shape_3d_button.tooltip_text = "Draw"
		# add more states here when needed
	emit_signal("change_path_shape_3d", current_state)
