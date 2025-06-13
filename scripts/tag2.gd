@tool
extends Control

@onready var tags: NinePatchRect = $Tags
@onready var tag_line_edit: LineEdit = $TagLineEdit
@onready var button: Button = $Tags/Button

var margin: int = 35
var min_size: int = 120

# Extend NinePathRect to the length of the LineEdit + margin
func _on_tag_line_edit_text_changed(new_text: String) -> void:
	tags.custom_minimum_size.x = tag_line_edit.size.x + margin
	if button.visible: # Extend current length by button size
		tags.custom_minimum_size.x += button.size.x
	else: # Return length back to LineEdit + margin
		tags.custom_minimum_size.x = tag_line_edit.size.x + margin
	set_root_to_ninepathrect_size()

# Extend current length by button size
func _on_mouse_entered() -> void:
	tags.custom_minimum_size.x += button.size.x - 10
	set_root_to_ninepathrect_size()
	button.show()

# Retract current length by button size
func _on_mouse_exited() -> void:
	tags.custom_minimum_size.x -= button.size.x - 10
	set_root_to_ninepathrect_size()
	button.hide()

# Remove tag
func _on_button_pressed() -> void:
	queue_free()

# For UI updates root control min size must also be updated 
func set_root_to_ninepathrect_size() -> void:
	if tags.custom_minimum_size.x >= min_size:
		custom_minimum_size.x = tags.custom_minimum_size.x
	else: # always keep above min_size
		custom_minimum_size.x = min_size
