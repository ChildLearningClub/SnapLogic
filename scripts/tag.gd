@tool
extends Control


signal remove_tag
signal tag_enter_pressed
signal rebuild_tags
#@onready var tags: NinePatchRect = $Tags
@onready var tag_line_edit: LineEdit = $TagLineEdit
@onready var panel: Panel = $Panel

@onready var button: Button = $Panel/Button
@onready var snap_flow_button: TextureButton = $Panel/SnapFlowButton



#const TAG_2_TEST = preload("res://addons/scene_snap/plugin_scenes/tag2test.tscn")

var margin: int = 40
var min_size: int = 120

# Set to name "Tag" so can drag and drop
func _ready() -> void:
	self.name = "Tag"
	#await get_tree().create_timer(0.1).timeout
	await get_tree().process_frame
	custom_minimum_size.x = tag_line_edit.size.x + margin
	apply_accent_color()
	snap_flow_button.set_texture_normal(get_theme_icon("GraphEdit", "EditorIcons"))
	


## Extend Tag to the length of the LineEdit + margin
# FIXME TODO Find same tags between tag_panel <-> snap_flow_manager and change together to avoid breaking flows
func _on_tag_line_edit_text_changed(new_text: String) -> void:
	custom_minimum_size.x = tag_line_edit.size.x + margin
	#print("setting meta now")
	#set_meta("tag_text", new_text)
	#ResourceSaver.save()
	
	
	#tags.custom_minimum_size.x = tag_line_edit.size.x + margin
	#if button.visible: # Extend current length by button size
		#tags.custom_minimum_size.x += button.size.x
	#else: # Return length back to LineEdit + margin
		#tags.custom_minimum_size.x = tag_line_edit.size.x + margin
	#set_root_to_ninepathrect_size()

## Extend current length by button size
#func _on_mouse_entered() -> void:
	#tags.custom_minimum_size.x += button.size.x - 10
	#set_root_to_ninepathrect_size()
	#button.show()

# Retract current length by button size
#func _on_mouse_exited() -> void:
	#tags.custom_minimum_size.x -= button.size.x - 10
	#set_root_to_ninepathrect_size()
	#button.hide()

# TODO FIXME Can this be unified to call all items that need to be updated to new accent color when changed
# redundant code
func apply_accent_color() -> void:
	var settings = EditorInterface.get_editor_settings()
	# Connect to settings changed signal to automatically update accent color
	if not settings.settings_changed.is_connected(apply_accent_color):
		settings.settings_changed.connect(apply_accent_color)
	if settings.has_setting("interface/theme/accent_color"):
		var new_stylebox_normal = panel.get_theme_stylebox("panel")
		new_stylebox_normal.set_border_color(settings.get_setting("interface/theme/accent_color"))
		panel.add_theme_stylebox_override("panel", new_stylebox_normal)






# Remove tag
func _on_button_pressed() -> void:
	emit_signal("remove_tag", self)
	queue_free()

## For UI updates root control min size must also be updated 
#func set_root_to_ninepathrect_size() -> void:
	#if tags.custom_minimum_size.x >= min_size:
		#custom_minimum_size.x = tags.custom_minimum_size.x
	#else: # always keep above min_size
		#custom_minimum_size.x = min_size


### Duplicate the current tag and return as drag data and set it to the drag preview 
#func _get_drag_data(position):
	#var mydata = self.duplicate()
	#set_drag_preview(mydata)
	#print("data: ", mydata)
	#return mydata
	

#func save_metadata():
	#var file = FileAccess.open(metadata_file_path, FileAccess.WRITE)
	#if file:
		#var metadata = get_tree().root.get_children()
		#for node in metadata:
			#if node.has_meta("example_key"):
				#file.store_line(node.get_meta("example_key"))
		#file.close()



## Return current tag and set a tag duplicate to the drag preview 
func _get_drag_data(position):
	var tag_duplicate = self.duplicate()
	tag_duplicate.set_modulate(get_parent().get_modulate())
	set_drag_preview(tag_duplicate)
	return self


func _can_drop_data(position, data):
	return data.name.contains("Tag")


func _drop_data(position, data):
	if data.tag_line_edit.get_text() == "":
		return

	var flow_container: FlowContainer = get_parent()
	data.reparent(flow_container)
	data.name = "Tag" # Give "Tag" name so can be redragged and dropped again.

	## Replace current tags position with dropped tag
	if tag_line_edit.get_text() == "":
		flow_container.move_child(data, get_index() - 1)
	else:
		flow_container.move_child(data, get_index())
	# Remove data from dictionary
	# Add data to dictionary
	emit_signal("rebuild_tags")



	#if data.tag_line_edit.get_text() == "":
		#return
	#data.reparent(self)
	#data.name = "Tag" # Give name so can be redragged and dropped again
	## Move tag just before new empty tag
	#if get_child(get_child_count() - 3).tag_line_edit.get_text() == "":
		#move_child(data, get_child_count() - 3)
	#else: # Move tag to just before + tag button
		#move_child(data, get_child_count() - 2)




func _on_tag_line_edit_text_submitted(new_text: String) -> void:
	emit_signal("tag_enter_pressed", new_text, self)
