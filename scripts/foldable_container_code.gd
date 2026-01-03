@tool
extends FoldableContainer


signal save_manager_state ## Save the current state of graph when save_manager_state emitted
signal redraw_connections ## HACK Since connections do not redraw when openning or closing code-edit.
signal remove_connection(code_snippet: FoldableContainer, snippet_index: int) ## Remove connections to this code_snippet.

@export var user_code_snippet: String ## Storage of user code when text changed
@onready var code_edit: CodeEdit = $CodeEdit
@onready var remove_code_snippet_button: Button = $MarginContainer/RemoveCodeSnippetButton



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
	#code_tab.remove_connection.connect(do_connection_removal)
	custom_minimum_size.y = code_edit.get_line_count() * code_edit.get_line_height()
	var output_snap: GraphNode = get_parent_control()
	if self.get_index() > 0:
		output_snap.set_slot_enabled_left(self.get_index() -1, true)

	if output_snap:
		output_snap.clear_slot(output_snap.get_child_count() - 1)
	#output_snap.set_slot_enabled_left(self.get_index(), true)

	#output_snap.set_slot_enabled_left(self.get_index() -1, true)
	#output_snap.set_slot_enabled_left(output_snap.get_child_count() -1, false)
	
	# Override defaults if user code snippet exists.
	if user_code_snippet != "":
		code_edit.set_text(user_code_snippet)

	else:
		# FIXME reverts to default does not save edited code snippet
		# If Label matches pre-defined Label text and code_edit empty load the script for it
		var title: String = get_title().strip_edges()
		for key: String in script_lookup.keys():
			if title == key:# and code_edit.get_text() == "":
				load_script_as_text(script_lookup[title])
				code_edit.set_text(load_script_as_text(script_lookup[title]))

	#if name == "Z Align Normal":
		#code_edit.set_text(str(ZAlignNormal))
		
	code_edit.code_completion_enabled = true

	if not has_connections("folding_changed"): # Existing nodes from last session will already have connection. 
		folding_changed.connect(_on_folding_changed)




func _on_code_edit_code_completion_requested() -> void:
	code_edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, "[display text]", "[text inserted into code]")
	code_edit.update_code_completion_options(true)



func load_from_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content




func load_script_as_text(script_path) -> String:
	var script = FileAccess.open(script_path, FileAccess.READ)
	var content = script.get_as_text()
	return content


func _on_code_edit_text_changed() -> void:
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


func _on_remove_code_snippet_button_pressed() -> void:
	var outputsnap_graphnode: GraphNode = get_parent_control()
	print("button pressed remove code snippet and connections")
	#print("The Labels index: ", self.get_index())
	#emit_signal("remove_connection", self, self.get_index() -1) # NOTE: -1 To account for the button in slot_index 0
	#get_parent_control().C(self.get_index())
	#get_parent_control().clear_all_slots()
	#for index in get_parent_control().get_child_count() - 2:
		#get_parent_control().set_slot_enabled_left(index, true)
	print_debug("get_parent_control().get_child_count(): ", outputsnap_graphnode.get_child_count() - 1)
	print_debug("self.get_index(): ", self.get_index())
	#get_parent_control().set_slot_enabled_left(get_parent_control().get_child_count(), false)
	outputsnap_graphnode.clear_slot(get_parent_control().get_child_count() - 2)
	#get_parent_control().size.y = 0 # Reset the GraphNode Container to the min vertical size.
	
	#custom_minimum_size.y = 0
	#size.y = 0
	#outputsnap_graphnode.custom_minimum_size.y = 0
	##await get_tree().process_frame
	#outputsnap_graphnode.size.y = 0 # Reset the GraphNode Container to the min vertical size.
	#await get_tree().process_frame
	print("parent size: ", outputsnap_graphnode.size.y)
	
	emit_signal("remove_connection", self, self.get_index())

	await get_tree().process_frame # Time for remove_connection to finish.
	free() # Will not collapse outputsnap_graphnode if queue_free().

	outputsnap_graphnode.size.y = 0 # Reset the GraphNode Container to the min vertical size.



func _on_folding_changed(is_folded: bool) -> void:
	print("code_edit.get_line_count(): ", code_edit.get_line_count())
	print("code_edit.get_line_height(): ", code_edit.get_line_height())

	if is_folded:
		custom_minimum_size.y = 0
	else:
		custom_minimum_size.y = code_edit.get_line_count() * code_edit.get_line_height()

	#custom_minimum_size.y = 0
	#custom_minimum_size.y = code_edit.get_line_count() * code_edit.get_line_height()
	
	get_parent_control().custom_minimum_size.y = 0
	get_parent_control().size.y = 0 # Reset the GraphNode Container to the min vertical size.
	#get_parent_control().size.y = 0 # Reset the GraphNode Container to the min vertical size.
	# FIXME NOT WORKING TO RESET CONNECTION LOCATION
	#emit_signal("redraw_connections")

#func _physics_process(delta: float) -> void:
	#if get_parent_control():
		#print(get_parent_control().size.y)
		#get_parent_control().custom_minimum_size.y = 0
		#get_parent_control().size.y = 0
