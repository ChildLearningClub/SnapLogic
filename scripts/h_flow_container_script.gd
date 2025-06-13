@tool
extends HFlowContainer

func _on_line_edit_text_changed(new_text: String) -> void:
	var scene_nodes = self.get_children()
	for child in scene_nodes:
		if new_text != "" and not child.name.contains(new_text):
			child.hide()
		else:
			child.show()
