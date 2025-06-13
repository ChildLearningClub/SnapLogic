@tool
extends Node2D

# Reference: https://kidscancode.org/godot_recipes/4.x/input/multi_unit_select/index.html (kidscancode)
signal multi_select_box_state(active: bool) ## Signal buttons to load or not load scene on hover


@onready var settings = EditorInterface.get_editor_settings()

var dragging: bool = false  # Are we currently dragging?
var drag_start = Vector2.ZERO  # Location where drag began.
var drag_distance = Vector2.ZERO # Store drag distance to only activate select/deselect after a certain amount
#var multi_select_box_working_area_rect: Rect2
var controls_with_mouse: Array[String] = []
var theme_accent_color: Color

func _ready() -> void:
	update_box_select_color()
	settings.settings_changed.connect(update_box_select_color)


func update_box_select_color() -> void:
	if settings.has_setting("interface/theme/accent_color"):
		theme_accent_color = settings.get_setting("interface/theme/accent_color")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Mouse clicked inside one of the controls and the control is not "_v_scroll" start dragging
		if event.pressed and not controls_with_mouse.has("_v_scroll") and not controls_with_mouse.is_empty():
			dragging = true
			drag_start = get_local_mouse_position()

		# If the mouse is released and is dragging, stop dragging
		elif dragging:
			dragging = false
			queue_redraw()
			var drag_end = get_local_mouse_position()
			emit_signal("multi_select_box_state", false) # Signal buttons to resume loading of scene on hover

	if event is InputEventMouseMotion and dragging:
		if get_parent() is HFlowContainer:
			queue_redraw()
			drag_distance = drag_start - get_local_mouse_position()
			emit_signal("multi_select_box_state", true) # Signal buttons to stop loading of scene on hover
			if abs(drag_distance).x > 30 or abs(drag_distance).y > 30:
				select_visible_scene_view_buttons_within_box()
				


	# NOTE Possible bug could not use Rect2 and instead used a workaround of getting all Controls within 
	# scrollcontainer (Rect2 size.y does not extent to full height of scroll container)
	#if event is InputEventMouseMotion and dragging:
		#if get_parent() is HFlowContainer:
			## Get the size of the parent Control node
			#var parent_size: Vector2 = get_parent().get_size()
#
			## Get the position of the parent Control node
			#var parent_local_position = get_parent().position
#
			## Convert the global position to screen position (relative to the screen's origin)
			#var parent_position = get_viewport().get_canvas_transform() * global_position
#
			#var parent_rect: Rect2 = Rect2(parent_position, parent_size)
#
			##var parent_rect: Rect2 = get_parent().get_global_rect()
#
			#if parent_rect.encloses(get_selection_rect()):
				#queue_redraw()
				#drag_distance = drag_start - get_local_mouse_position()
				#if abs(drag_distance).x > 30 or abs(drag_distance).y > 30:
					#select_visible_scene_view_buttons_within_box()
			##queue_redraw()



# NOTE Pull color from interface/theme/accent_color
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_local_mouse_position() - drag_start),
			Color(theme_accent_color), false, 1.0)
		draw_rect(Rect2(drag_start, get_local_mouse_position() - drag_start),
			Color(theme_accent_color.r, theme_accent_color.g, theme_accent_color.b, 0.3), true) # NOTE: 0.3 appears to match default editor selection box alpha



func select_visible_scene_view_buttons_within_box() -> void:
	# Get the selection box, ensuring it's always correctly oriented
	var select_box_extents: Rect2 = get_selection_rect()
	
	# Iterate through all buttons in the scene
	for button: Node in get_parent().get_children():
		if button.is_visible_in_tree() and button is Button:
			var button_extents: Rect2 = Rect2(button.position, button.get_size())

			# Check if the button's corners are inside the selection box
			for point: Vector2 in get_button_points(button):
				if select_box_extents.has_point(point):
					if not button.selected_texture_button.button_pressed:
						button.selected_texture_button.button_pressed = true
					break # If at least one point break from loop
				else:
					if button.selected_texture_button.button_pressed:
						button.selected_texture_button.button_pressed = false
						button.selected_texture_button.hide()


func get_button_points(button: Node) -> Array[Vector2]:
	var button_points: Array[Vector2] = []
	button_points.append(button.position) # TOP-LEFT
	button_points.append(button.position + button.get_size()) # BOTTOM-RIGHT
	var button_top_right = Vector2(button.position.x + button.get_size().x, button.position.y)
	button_points.append(button_top_right) # TOP-RIGHT
	var button_bottom_left = Vector2(button.position.x, button.position.y + button.get_size().y)
	button_points.append(button_bottom_left) # BOTTOM-LEFT
	var button_center: Vector2 = Rect2(button.position, button.get_size()).get_center()
	button_points.append(button_center) # CENTER

	return button_points


func get_selection_rect() -> Rect2:
	# Ensure the rect is always drawn from top-left to bottom-right
	var rect_pos = drag_start
	var rect_size = get_local_mouse_position() - drag_start
	if rect_size.x < 0:
		rect_pos.x += rect_size.x
		rect_size.x = abs(rect_size.x)
	if rect_size.y < 0:
		rect_pos.y += rect_size.y
		rect_size.y = abs(rect_size.y)
	return Rect2(rect_pos, rect_size)
