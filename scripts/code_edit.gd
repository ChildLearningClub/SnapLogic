@tool
extends CodeEdit

func _ready():
	# Create a new GDScript instance
	var new_script = GDScript.new()

	# Define some source code to be assigned to the script
	var script_code = """
extends Node

func _ready():
	print("Hello from new script!")
	"""

	# Set the source code of the new script
	new_script.source_code = script_code

	# Assign this script to the CodeEdit's source_code property
	self.source_code = new_script.source_code




#@tool
#extends CodeEdit
#
#func _ready() :
	#text_changed.connect(code_request_code_completion)
	#code_completion_enabled = true
#
#func code_request_code_completion():
	#add_code_completion_option(CodeEdit.KIND_FUNCTION, "[display text]", "[text inserted into code]")
	#update_code_completion_options(true)
#
#func _on_text_changed():
	#add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "echo", "echo")
	#update_code_completion_options(true)
#
#
#func _on_code_completion_requested() -> void:
	#add_code_completion_option(CodeEdit.KIND_FUNCTION, "[display text]", "[text inserted into code]")
	#update_code_completion_options(true)
