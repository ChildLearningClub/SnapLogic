@tool
class_name BaseTagGraphNode
extends GraphNode

#signal update_tag_cache(tag_text: String, tag_index: int, store_tag: bool) ## A new tag was added so update Dictionary tag cache in scene_snap_plugin.gd.
signal update_tag_cache(tag: Control, store_tag: bool) ## A new tag was added so update Dictionary tag cache in scene_snap_plugin.gd.
#signal new_tag_added

const TAG = preload("res://addons/scene_snap/plugin_scenes/tag.tscn")
#const SNAP_MANAGER_DATA = preload("res://addons/scene_snap/resources/snap_flow_manager_data.tres")
#const SnapManagerGraph = preload("res://addons/scene_snap/scripts/snap_manager_graph.gd")

# FIXME change to single String var tag because children will always only have one tag
# This holds all tags?
#var graphnode_tags: Dictionary[StringName, Array] = {}
var current_tags: Array[String] = []




func _ready() -> void:
	# Restore data from snap_manager_data.tres to tags
	# EDIT Restore tag text from the tag.names rather then in .tres
	for child: Control in get_children():
		# Connect to signals
		if child.has_signal("remove_tag"):
			child.remove_tag.connect(handle_removing_tag)
		if child.has_meta("tag_text"):
			# Create array of current tags for duplicate checking during drag and drop.
			current_tags.append(child.get_meta("tag_text"))
			#print("current_tags: ", current_tags)
			child.tag_line_edit.set_text(child.get_meta("tag_text"))



func _can_drop_data(position, data):
	return data.name.contains("Tag")


func _drop_data(position, data):
	
	var tag_text: String = data.tag_line_edit.get_text()
	print("position: ", position)
	# If the tag is empty do not place.
	if tag_text == "":
		return

	# Highlight tags that already exist and do not place.
	if current_tags.has(tag_text):
		for tag: Control in get_children():
			if tag.has_meta("tag_text") and tag.get_meta("tag_text") == tag_text:
				highlight_tag(tag)
		return



	var tag: Control = TAG.instantiate()
	add_child(tag)
	tag.set_owner(get_parent_control())
	tag.tag_line_edit.set_text(tag_text)

	# Store the tag_text into the tag nodes metadata to make it persistent.
	tag.set_meta("tag_text", tag_text)

	# Add enable and color slot for new tag NOTE: Use set_slot() that includes all parameters or individual functions.
	configure_slots(tag)
	
	#print("tag index: ", tag.get_index())
	
	# Update tag cache in scene_snap_plugin.gd 
	emit_signal("update_tag_cache", tag, true)
	#emit_signal("update_tag_cache", tag_text, tag.get_index(), true)
	#emit_signal("new_tag_added")
	#set_slot_enabled_right(tag.get_index(), true)
	#set_slot_color_right(tag.get_index(), Color(0.846, 0.399, 0.0))

	# Store tag data in res://addons/scene_snap/resources/snap_manager_data.tres


# FIXME TODO Remove connections on removal
func handle_removing_tag(tag: Object) -> void:
	#var tag_text: String = tag.tag_line_edit.get_text()
	print("need to remove connections too")
	emit_signal("update_tag_cache", tag, false)
	#emit_signal("update_tag_cache", tag_text, tag.get_index(), false)

	
	#emit_signal("save_graph_edit")
func configure_slots(tag: Control) -> void:
	pass
	## Add enable and color slot for new tag NOTE: Use set_slot() that includes all parameters or individual functions.
	#set_slot_enabled_right(tag.get_index(), true)
	#set_slot_color_right(tag.get_index(), Color(0.846, 0.399, 0.0))


## Highlight the tag when duplicate found or when creating new tag but last tag empty.
func highlight_tag(tag: Control) -> void:
	# Resources are shared across instances, so we need to duplicate it
	# to avoid modifying the appearance of all other buttons.
	var new_stylebox_normal = tag.panel.get_theme_stylebox("panel").duplicate()
	var original_bg_color: Color = new_stylebox_normal.get_bg_color()
	new_stylebox_normal.set_bg_color(Color(1.0, 0.124, 0.093))
	tag.panel.add_theme_stylebox_override("panel", new_stylebox_normal)
	# Set color back to original
	await get_tree().create_timer(1).timeout
	new_stylebox_normal.set_bg_color(original_bg_color)
