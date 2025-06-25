@tool
extends HBoxContainer
signal open_graph_editor
#const SNAP_MANAGER_GRAPH = preload("res://addons/scene_snap/plugin_scenes/snap_manager_graph.tscn")
#var snap_manager_graph: CustomGraphEdit

@onready var grap_edit_button: Button = $GrapEditButton

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
