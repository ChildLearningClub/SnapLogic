@tool
extends FlowContainer

signal rebuild_tags


func _can_drop_data(position, data):
	print("data.name: ", data.name)
	return data.name.contains("Tag")


func _drop_data(position, data):
	if data.tag_line_edit.get_text() == "":
		return
	data.reparent(self)
	data.name = "Tag" # Give name so can be redragged and dropped again
	# Move tag just before new empty tag
	#print("get_child(get_child_count() - 3).tag_line_edit.get_text(): ", get_child(get_child_count() - 2).tag_line_edit.get_text())
	# NOTE data.reparent(self) above intially adds data to end position putting + button at -2.
	var end_tag_text: String
	if get_child(get_child_count() - 2) is not Button:
		end_tag_text = get_child(get_child_count() - 2).tag_line_edit.get_text()
	else:
		end_tag_text = get_child(get_child_count() - 3).tag_line_edit.get_text()

	if end_tag_text == "" and end_tag_text != data.tag_line_edit.get_text():
		move_child(data, get_child_count() - 3)
	else: # Move tag to just before + tag button
		move_child(data, get_child_count() - 2)
	emit_signal("rebuild_tags")
		
