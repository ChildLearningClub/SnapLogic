@tool
extends Label


 ##Preload available default scripts
#const SnapOffset = preload("uid://bhcdlumqdls3m")
#const ZAlignNormal = preload("uid://dfwpeku578xa0")


@onready var code_edit: CodeEdit = $CodeEdit

#var script_lookup: Dictionary[String, Script] = {
	#"Z Align Normal": ZAlignNormal,
	#"Set Offset": SetOffset
#}

var script_lookup: Dictionary[String, String] = {
	"Z Align Normal": "uid://dfwpeku578xa0",
	"Offset Snap": "uid://bhcdlumqdls3m"
}



func _ready() :
	#code_edit.text_changed.connect(_on_code_edit_code_completion_requested)
	#script_lookup[self.name]
	
	# FIXME reverts to default does not save edited code snippet
	# If Label matches pre-defined Label text and code_edit empty load the script for it
	var label: String = get_text().strip_edges()
	for key: String in script_lookup.keys():
		if label == key and code_edit.get_text() == "":
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
	else:
		code_edit.show()
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
