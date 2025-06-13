@tool
extends Window

#var scene_viewer_panel_instance
#var mouse_inside_window: bool = false
#func _ready() -> void:
	#get_tree().get_root().set_transparent_background(true)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	#scene_viewer_panel_instance = self.get_child(0)
	#var root_viewport = get_tree().get_root().find_child("")
	
signal attach_dock



func _on_close_requested() -> void:
	emit_signal("attach_dock")
	#if mouse_inside_window:
	#print("close button pressed")
	self.hide()

# TODO (Low Priority) Replace with proper DisplayServer function if there is one for multi-screen because
# I don't think solution in physics_process will work for multi-screen
func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_ENTER:
			if not has_focus():
				grab_focus()


func _physics_process(delta: float) -> void:
	#print("get_size_with_decorations: ", get_size_with_decorations())
	#var popup_panel: Rect2i = Rect2i(position, size)
	var popup_panel: Rect2i = Rect2i(get_position_with_decorations(), get_size_with_decorations())
	if popup_panel.has_point(DisplayServer.mouse_get_position()):
		if not has_focus():
			grab_focus()
