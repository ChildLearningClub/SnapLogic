@tool
extends Label

signal save_manager_state ## Save the current state of graph when save_manager_state emitted
signal redraw_connections ## HACK Since connections do not redraw when openning or closing code-edit.
signal remove_connection(code_snippet: Label, snippet_index: int) ## Remove connections to this code_snippet.
 ##Preload available default scripts
#const SnapOffset = preload("uid://bhcdlumqdls3m")
#const ZAlignNormal = preload("uid://dfwpeku578xa0")
@export var user_code_snippet: String ## Storage of user code when text changed

@onready var code_edit: CodeEdit = $CodeEdit
@onready var code_tab_collapse_button: Button = $CodeTabCollapseButton
@onready var remove_code_snippet_button: Button = $RemoveCodeSnippetButton

#const SnapFlowManagerData = preload("res://addons/scene_snap/resources/snap_flow_manager_data.gd")


#var script_lookup: Dictionary[String, Script] = {
	#"Z Align Normal": ZAlignNormal,
	#"Set Offset": SetOffset
#}

var script_lookup: Dictionary[String, String] = {
	"Z Align Normal": "uid://dfwpeku578xa0",
	"Offset Snap": "uid://bhcdlumqdls3m"
}



func _ready():
	# NOTE: Currently closes all code snippets on start TODO Store state and restore. 
	_on_code_tab_collapse_button_toggled(true)
	#code_tab_collapse_button.set_button_icon(get_theme_icon("PinPressed", "EditorIcons"))
	
	#var snap_flow_manager_data = SnapFlowManagerData.new()
	#code_edit.text_changed.connect(_on_code_edit_code_completion_requested)
	#script_lookup[self.name]


	# Override defaults if user code snippet exists.
	if user_code_snippet != "":
		code_edit.set_text(user_code_snippet)

	else:
		# FIXME reverts to default does not save edited code snippet
		# If Label matches pre-defined Label text and code_edit empty load the script for it
		var label: String = get_text().strip_edges()
		for key: String in script_lookup.keys():
			if label == key:# and code_edit.get_text() == "":
				load_script_as_text(script_lookup[label])
				code_edit.set_text(load_script_as_text(script_lookup[label]))
				#code_edit.set_text(str(script_lookup[get_text()]))
	
	

	
	
	#if name == "Z Align Normal":
		#code_edit.set_text(str(ZAlignNormal))
		
	code_edit.code_completion_enabled = true

func _on_code_edit_item_rect_changed() -> void:
	await ready
	custom_minimum_size = code_edit.size


func _on_code_tab_collapse_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		code_edit.hide()
		remove_code_snippet_button.show()
		custom_minimum_size = Vector2.ZERO
		#get_parent_control().size = Vector2(300.0, 0.0)
		code_tab_collapse_button.set_button_icon(get_theme_icon("Forward", "EditorIcons"))
		# HACK
		emit_signal("redraw_connections")
	else:
		code_edit.show()
		remove_code_snippet_button.hide()
		custom_minimum_size = Vector2(848.0, 747.0)
		print("code_edit size: ", code_edit.size)
		# FIXME get OutputSnap resizing fixed to fit expanded and closed code snippets. 
		get_parent_control().size = code_edit.size + Vector2(30.0, 300.0)
		print("parent name: ", get_parent_control().name)
		
		code_tab_collapse_button.set_button_icon(get_theme_icon("Collapse", "EditorIcons"))
		# HACK
		emit_signal("redraw_connections")

	#custom_minimum_size = 
	#pass # Replace with function body.


func _on_code_edit_code_completion_requested() -> void:
	code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "[display text]", "[text inserted into code]")
	code_edit.update_code_completion_options(true)
	#for each in function_names:
		#add_code_completion_option(CodeEdit.KIND_FUNCTION, each, each+"()", syntax_highlighter.function_color)
	#for each in variable_names:
		#add_code_completion_option(CodeEdit.KIND_VARIABLE, each, each)
	#update_code_completion_options(true)
	#changed = true



func load_from_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content




func load_script_as_text(script_path) -> String:
	var script = FileAccess.open(script_path, FileAccess.READ)
	var content = script.get_as_text()
	return content


func _on_code_edit_text_changed() -> void:
	#code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:", "func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:")
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "extends", "extends", Color(0.9, 0.29, 0.3, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "TransformBase", "TransformBase", Color(0.77, 1, 0.93, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "func", "func", Color(0.9, 0.29, 0.3, 1), load("res://addons/scene_snap/icons/red_heart.svg"))
	code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "transform(", "transform(", Color(0.40, 0.89, 1, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:", "func transform(object_to_snap: Node3D, vector_normal: Vector3, process: bool = true) -> bool:")
	
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "object_to_snap", "object_to_snap")
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "Node3D", "Node3D", Color(0.25, 1, 0.75, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "vector_normal", "vector_normal")
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "Vector3", "Vector3", Color(0.25, 1, 0.75, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "true", "true", Color(0.9, 0.29, 0.3, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "false", "false", Color(0.9, 0.29, 0.3, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "bool", "bool", Color(0.25, 1, 0.75, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "print", "print")
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "return", "return", Color(1, 0.55, 0.80, 1))
	code_edit.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "process", "process")
	code_edit.update_code_completion_options(true)
	user_code_snippet = code_edit.text
	emit_signal("save_manager_state")
	#save_user_code_snippets()
	#
#
#
#func save_user_code_snippets() -> void:
	#print("code_edit.text: ", code_edit.text)
	#print("saving user code snippet")
	#var user_code_snippets: Array[String] = ResourceLoader.load("res://addons/scene_snap/resources/snap_flow_manager_data.tres","", ResourceLoader.CACHE_MODE_IGNORE).user_code_snippets
	#
	##ResourceLoader.load("res://addons/scene_snap/resources/snap_flow_manager_data.tres")
	##snap_flow_manager_data



func _on_remove_code_snippet_button_pressed() -> void:
	print("button pressed remove code snippet and connections")
	#print("The Labels index: ", self.get_index())
	emit_signal("remove_connection", self, self.get_index() -1) # NOTE: -1 To account for the button in slot_index 0
	queue_free()
						## Get the to_node and to_port from the matching connection
					#var connections: Array[Dictionary] = snap_flow_manager_graph.get_connection_list()
					#if debug: print("connections: ", connections)
					#if debug: print("tag parent: ", tag.get_parent().name)
					#if debug: print("tag_index: ", tag_index)
					## Remove connections to and from the deleted tag
					#for connection: Dictionary in connections:
						#var to_node: String = connection.to_node
						#var to_port: int = connection.to_port
						#var from_node: String = connection.from_node
						#var from_port: int = connection.from_port
#
						#if to_node == tag.get_parent().name and to_port == tag_index:
							#snap_flow_manager_graph.disconnect_node(from_node, from_port, tag.get_parent().name, tag_index)
						#if from_node == tag.get_parent().name and from_port == tag_index:
							#snap_flow_manager_graph.disconnect_node(tag.get_parent().name, tag_index, to_node, to_port)
#
					### Remove the actual tag itself from the node_indices.
					##node_indices[graphnode_name].erase(tag_index)
					##if debug: print("remove from node_indices")
					##if debug: print("node_indices: ", node_indices)
						###node_indices[graphnode_name]
#
	#save_snap_flow_manager_state()
