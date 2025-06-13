@tool
#extends Control
#class_name CustomGraphEdit extends GraphEdit
extends GraphEdit

var debug = preload("uid://dfb5uhllrlnbf").new().run()

#signal graph_updated
signal scene_path_original
signal update_tag_cache  ## A new tag was added so update Dictionary tag cache in scene_snap_plugin.gd.
#signal save_snap_manager(graph_scene_path: String)
#signal save_snap_manager
# Reference: https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/
# Reference: https://norech.com/blog/post/introduction-graphnode-and-graphedit

#@onready var graph_edit: GraphEdit = $GraphEdit
#@onready var line_edit: LineEdit = $GraphEdit/InputTextString/LineEdit
#@onready var line_edit: LineEdit = $InputTextString/LineEdit
#

#@onready var current_connections: Array = snap_manager_data.connections
#@onready var current_nodes: Array = snap_manager_data.nodes
#const SNAP_MANAGER_DATA: SnapManagerData = preload("res://addons/scene_snap/resources/snap_manager_data.tres")
#const SNAP_MANAGER_DATA: SnapManagerData = preload("res://addons/scene_snap/resource/snap_manager_data.tres")


@onready var settings = EditorInterface.get_editor_settings()

const SnapManagerData = preload("res://addons/scene_snap/scripts/snap_flow_manager_data.gd")

var graph_scene_path: String = "res://addons/scene_snap/plugin_scenes/snap_manager_graph.tscn"
#var scene_path: String = "res://addons/scene_snap/plugin_scenes/snap_manager_graph.tscn"
var data_path: String = "res://addons/scene_snap/resources/snap_manager_data.tres"

const SceneSnapPlugin = preload("res://addons/scene_snap/scene_snap_plugin.gd")

# FIXME connect to codeedit nodes as they are instantiated
#@onready var code_edit: CodeEdit = $OutputSnap/CodeEdit
#@onready var code_edit: CodeEdit = $OutputSnap/Label2/CodeEdit


# TEST
#@onready var object_to_snap_2: GraphNode = $ObjectToSnap2


# Array of things to attach to Input frame
var input_graph_nodes: Array[StringName] = ["ObjectToSnap", "IndividualTags"]

var snap_to_objects_frame_nodes: Array[StringName] = ["SnapToObject"]
#var snap_manager_data: SnapManagerData = null

#@onready var plugin_ref = SceneSnapPlugin.new()

#var plugin_ref

#### ORIGINAL WORKS
#func _on_code_changed():
	#var expression = Expression.new()
	## TODO add in to_snap and snap_to nodes (code_edit.text, ["to_snap", "snap_to"]) ??
	#var result = expression.parse(code_edit.text)
	#if result == OK:
		## TODO the variables will need to be passed in here
		## Set the base instance of expression to the code-edit node FIXME this will change.
		## Gives the ability to call all methods defined within that code_edit code block??
		## Example: expression.execute(["to_snap", "snap_to"], code_edit) ??
		#var value = expression.execute()
		#if debug: print("value: ", value)
		## Handle the executed value as needed
	#else:
		#pass
		## Handle errors

#func double(number):
	#return number * 2

#func get_input_tag()



#func _on_code_changed():
	#var expression = Expression.new()
	## TODO add in to_snap and snap_to nodes (code_edit.text, ["to_snap", "snap_to"]) ??
	##var result = expression.parse(code_edit.text, ["to_snap", "snap_to"])
	#var result = expression.parse("double(number)", ["number"])
	#if result == OK:
		## TODO the variables will need to be passed in here
		## Set the base instance of expression to the code-edit node FIXME this will change.
		## Gives the ability to call all methods defined within that code_edit code block??
		## Example: expression.execute(["to_snap", "snap_to"], code_edit) ??
		##var value = expression.execute(["to_snap", "snap_to"], self)
		#var value = expression.execute([40], self)
		#if debug: print("value: ", value)
		## Handle the executed value as needed
	#else:
		#pass
		## Handle errors

var selected_scene_view_button: Button
var selected_scene_view_button_tags:  Array[String] = []

# NOTE can't do below because can not process unless panel open so will need to process connections from scene_snap_plugin.gd
# but signals are recognized? can i pass it in through a signal
# FIXME Handle connections and logic here and pass up pass up transform information???
# Will remove the need: selected_scene_view_button.tags and scene_viewer_panel_instance.scene_tags[closest_object.name]
			## If the object to place has a tag that matches one in the snap flow from_node connections 
			## and the object to snap to has a tag in the to_node connections then follow connection
			#if selected_scene_view_button.tags != [] and selected_scene_view_button.tags.has(node_indices[connection.from_node][connection.from_port]) and \
			#scene_viewer_panel_instance.scene_tags[closest_object.name].has(node_indices[connection.to_node][connection.to_port]):


func _ready() -> void:

	#code_edit.text_changed.connect(_on_code_changed)
	#if debug: print("self.get_path(): ", self.get_path())
	for input_node: StringName in input_graph_nodes:
		attach_graph_element_to_frame(input_node, "InputFilters")
		
	for snap_to_node: StringName in snap_to_objects_frame_nodes:
		attach_graph_element_to_frame(snap_to_node, "SnapToObjectsFrame")
		
	#plugin_ref = SceneSnapPlugin.new()
	#var tag_node: Control = find_child("Tag")
	#tag_node.name = "BLOBY"
	

	#save_connections(data_path)
	#var snap_manager_data = SnapManagerData.new()
	pass
	#if scene_path == "":
		#scene_path = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_original.tscn"
		#emit_signal("scene_path_original", true)
	#else:
		#scene_path = "res://addons/scene_snap/plugin_scenes/snap_manager_graph_copy.tscn"
		#emit_signal("scene_path_original", false)
	##load_snap_manager_data(res://addons/scene_snap/resource/snap_manager_data.tres)
	#load_data("res://addons/scene_snap/resource/snap_manager_data.tres")

#func load_snap_manager_data(data: SnapManagerData) -> void:
	#snap_manager_data = data

#var values: Array[String] = []
#var object_values: Dictionary[Object, Array] = {}
#var object: Object = null
var scene_name: String = ""


#func _physics_process(delta: float) -> void:
	#if debug: print("tags: ", selected_scene_view_button.tags)



func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# I think you process the data here
	if debug: print("from_node: ", from_node)
	if debug: print("from_port: ", from_port)
	if debug: print("to_node: ", to_node)
	if debug: print("to_port: ", to_port)
	#if from_node == "ObjectToSnap2":
		#var object_to_snap_tags = object_to_snap_2.get_child(0).get_text()
		#object_to_snap_tags = object_to_snap_tags.strip_edges().to_lower()
		#var packed_string_array: PackedStringArray = object_to_snap_tags.split(",")
		## Trim whitespace from each element in the array
		#for i in range(packed_string_array.size()):
			#packed_string_array[i] = packed_string_array[i].strip_edges()
		#if debug: print("packed_string_array: ", packed_string_array)
		#if packed_string_array.has("House"):
			#if debug: print("it has HOUSE!!")
		#if object_to_snap_tags.contains("house"):
			#if debug: print("it has HOUSE!!")
		#if debug: print("object_to_snap_tags: ", object_to_snap_tags)
		#if debug: print("connected to ObjectToSnap2")

		#if debug: print("")
	#if debug: print("get_connection_list(): ", get_connection_list())
	## Prevent multiple same connections Reference: https://norech.com/blog/post/introduction-graphnode-and-graphedit
	#for connection in get_connection_list():
		#if debug: print("connection: ", connection)
		#if connection.to_node == to_node and connection.to_port == to_port:
			#return
	connect_node(from_node, from_port, to_node, to_port)
	#emit_signal("update_tag_cache")
	

	#var from_node_inst = find_child(from_node) as CustomGraphNode
	#var to_node_inst = find_child(to_node) as CustomGraphNode
#
	#from_node_inst.on_connect("output", from_port, to_node_inst, to_port)
	#to_node_inst.on_connect("input", to_port, from_node_inst, from_port)
	#save_connections(data_path)
	#emit_signal("save_snap_manager")
	#plugin_ref.save_snap_manager_data(graph_scene_path)
	
	#save_scene_and_data(scene_path, data_path)
	
	#for child: Control in get_children():
		#if child is CustomGraphNode:
			#if debug: print("child data test: ", child.graph_node_data["title"])
			#if debug: print("child name: ", child.name)
			#if debug: print("ports_connected: ", child.ports_connected)
	

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if debug: print("from_node: ", from_node)
	if debug: print("from_port: ", from_port)
	if debug: print("to_node: ", to_node)
	if debug: print("to_port: ", to_port)
	#if debug: print("get_connection_list(): ", get_connection_list())
	disconnect_node(from_node, from_port, to_node, to_port)
	#emit_signal("update_tag_cache")
	
	
	#var from_node_inst = find_child(from_node) as CustomGraphNode
	#var to_node_inst = find_child(to_node) as CustomGraphNode
#
	#from_node_inst.on_disconnect("output", from_port, to_node_inst, to_port)
	#to_node_inst.on_disconnect("input", to_port, from_node_inst, from_port)
	#save_connections(data_path)
	#emit_signal("save_snap_manager")
	#plugin_ref.save_snap_manager_data(graph_scene_path)
	#save_scene_and_data(scene_path, data_path)


#func _physics_process(delta: float) -> void:
	#if debug: print("get_connection_list(): ", get_connection_list())


func pass_scene_name(scene_name: String) -> void:
	scene_name = scene_name
	#if debug: print("scene_name: ", scene_name)

func get_scene_aabb(scene_preview: Object) -> AABB:
	var scene_aabb: AABB
	var mesh_node_instances: Array[Node] = scene_preview.find_children("*", "MeshInstance3D", true, false)
	for mesh_node: MeshInstance3D in mesh_node_instances:
		scene_aabb = scene_aabb.merge(mesh_node.mesh.get_aabb())
	return scene_aabb


## Saved here and through scene_snap_plugin.gd _enter_tree() TODO Move into one maybe signal up to save
#func save_connections(data_path) -> void:
	#var snap_manager_data = SnapManagerData.new()
	#snap_manager_data.connections = get_connection_list()
	#if ResourceSaver.save(snap_manager_data, data_path) == OK:
		#if debug: print("saved data")
	#else:
		#if debug: print("Error saving graph_data")


# NOTE I think I found that this can all be replaced with using save_connections()?
func save_scene_and_data(scene_path: String, data_path: String):
	pass
	#if debug: print("saving to file path: ", scene_path)
	##if debug: print("self: ", self)
	##EditorInterface.save_scene()
	##var snap_manager_data = SnapManagerData.new()
	##snap_manager_data.connections = get_connection_list()
	##if ResourceSaver.save(snap_manager_data, data_path) == OK:
		##if debug: print("saved data")
	##else:
		##if debug: print("Error saving graph_data")
	#
	#if debug: print("connections: ", connections)
	#var packed_scene = PackedScene.new()
	##for child: Variant in get_children():
		###if debug: print("child: ", child)
		##
		##child.set_owner(self)
		##for grandchild: Variant in child.get_children():
			###if debug: print("grandchild: ", grandchild)
			##grandchild.set_owner(self)
			##for greatgrandchild: Variant in grandchild.get_children():
				##if debug: print("greatgrandchild: ", greatgrandchild)
	#var result = packed_scene.pack(self)
	#if result == OK:
		#var error = ResourceSaver.save(packed_scene, scene_path)
		##var error = ResourceSaver.save(packed_scene, "res://my_scene.tscn")
		#if error != OK:
			#push_error("An error occurred while saving the scene to disk.")
		#else:
			#if debug: print("saved scene")
			#emit_signal("graph_updated")
	
	
	
	#var snap_manager_data = SnapManagerData.new()
	#snap_manager_data.connections = get_connection_list()
	##var index: int = 0
	#for node in get_children():
		#if node is GraphNode:
#
			#var node_data = SnapManagerData.new()
			#for child: Control in node.get_children():
				#if debug: print("child: ", child)
			#
			#var node_data_array: Array[Variant] = []
			#
			#node_data_array.append(node.get_name()) #1
			#node_data_array.append(node.get_title()) #2
			#node_data_array.append(node.get_position_offset()) #3
			#node_data_array.append(node.get_size()) #4
			#
			#node_data_array.append(node.get_slot_color_left(0)) #5
			#node_data_array.append(node.get_slot_color_right(0)) #6
			##node_data_array.append(node.get_input_port_color(0))
			#
			##node_data_array.append(node.get_size())
			##node_data_array.append(node.get_size())
			##node_data_array.append(node.get_size())
			##node_data_array.append(node.get_size())
			##node_data_array.append(node.get_size())
			##node_data_array.append(node.get_size())
			##node_data.name = node.get_name()
			##node_data.title = node.get_title()
			##node_data.type = node.type
			##node_data.offset = node.get_position_offset()
			##node_data.data = node.data
			##node_data.data = node.item
			##node_data.size = node.get_size()
			##node_data.data[node.name] = node_data_array
			#snap_manager_data.data[node.name] = node_data_array
			##snap_manager_data.data[index] = node_data_array
			##index += 1
			##snap_manager_data.nodes.append(node_data)
	#if ResourceSaver.save(snap_manager_data, save_path) == OK:
		#if debug: print("saved")
	#else:
		#if debug: print("Error saving graph_data")


#func load_data(save_path: String):
	## Use load() instead of preload() if the path isn't known at compile-time.
	#var scene = preload("res://my_scene.tscn").instantiate()
	## Add the node as a child of the node the script is attached to.
	#add_child(scene)
	
	
	#if ResourceLoader.exists(save_path):
		#var graph_data = ResourceLoader.load(save_path)
		#if SNAP_MANAGER_DATA is SnapManagerData:
			#init_graph(SNAP_MANAGER_DATA)
		#else:
			## Error loading data
			#pass
	#else:
		## File not found
		#pass




#func init_graph(snap_manager_data: SnapManagerData):
	##clear_graph()
	#for node in snap_manager_data.nodes:
		## Get new node from factory autoload (singleton)
		##var gnode = PartFactory.get_node(node.type)
		##var node_instance = node.instantiate()
		#var node_instance = GraphNode.new()
		##node_instance.offset = node.offset
		#node_instance.name = node.name
		#graph_edit.add_child(node_instance)
		##gnode.offset = node.offset
		##gnode.name = node.name
		##graph_edit.add_child(gnode)
	#for connection in snap_manager_data.connections:
		#graph_edit.connect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)


#func init_graph(snap_manager_data: SnapManagerData):
	##clear_graph()  # Clear existing nodes and connections
	##for node in snap_manager_data.nodes:
	##for child: Control in get_children():
		##if child is CustomGraphNode:
			##if debug: print("child name: ", child.name)
			##if debug: print("ports_connected: ", child.ports_connected)
	#
	#if debug: print("snap_manager_data.data.size(): ", snap_manager_data.data.size())
	#for key in snap_manager_data.data.keys():
		#if debug: print("key: ", key)
	##for index in range(0, snap_manager_data.data.size()):
		##if debug: print("index: ", index)
		###pass
		##
		#if debug: print("saved node data: ", snap_manager_data.data[key][0])
		#var node_instance = GraphNode.new()
		#node_instance.set_name(snap_manager_data.data[key][0])
		#node_instance.set_title(snap_manager_data.data[key][1])
		#node_instance.set_position_offset(snap_manager_data.data[key][2])
		#node_instance._set_size(snap_manager_data.data[key][3])
		##node_instance.set_slot_color_left(0, snap_manager_data.data[key][4])
		##node_instance.set_input_port_color(0, snap_manager_data.data[key][5])
		#node_instance.set_slot(0, true, 0, snap_manager_data.data[key][4], true, 0, snap_manager_data.data[key][5])
#
		#
		#
		#add_child(node_instance)
		#
		##if debug: print("node: ", node.name)
		##if debug: print("data: ", node_data.data)
		##var node_instance = GraphNode.new()
		###node_instance.position_offset = node.position_offset
		##node_instance.set_name(node.name)
		##node_instance.set_title(node.title)
		##node_instance.set_position_offset(node.offset)
##
		##
		##node_instance._set_size(node.size)
		###if debug: print("node data: ", node.data)
		##graph_edit.add_child(node_instance)
	#for connection in snap_manager_data.connections:
		#if debug: print("connection: ", connection)
		#connect_node(
			#connection.from_node,
			#connection.from_port,
			#connection.to_node,
			#connection.to_port
		#)
#
#
#
#func clear_graph():
	#clear_connections()
	#var nodes = get_children()
	#for node in nodes:
		#if node is GraphNode:
			#node.queue_free()
			##node.free()


#func _on_snap_to_object_position_offset_changed() -> void:
	#save_scene_and_data(scene_path, data_path)
#
#
#func _on_output_snap_position_offset_changed() -> void:
	#save_scene_and_data(scene_path, data_path)
#
#
#func _on_object_to_snap_position_offset_changed() -> void:
	#save_scene_and_data(scene_path, data_path)

#func _on_snap_to_object_position_offset_changed() -> void:
	##save_connections(data_path)
	#emit_signal("save_snap_manager")
	##save_scene_and_data(scene_path, data_path)


#func _on_output_snap_position_offset_changed() -> void:
	#
	##save_connections(data_path)
	#emit_signal("save_snap_manager")
	##save_scene_and_data(scene_path, data_path)


#func _on_object_to_snap_position_offset_changed() -> void:
	##save_connections(data_path)
	#emit_signal("save_snap_manager")
	##save_scene_and_data(scene_path, data_path)


#func _on_object_to_snap_2_save_graph_edit() -> void:
	##save_connections(data_path)
	#emit_signal("save_snap_manager")

# NOTE: Must be called from root graphedit node because it owns it 
func _on_object_to_snap_2_rename_tag(tag: Control, new_name: String) -> void:
	tag.name = new_name
	#pass # Replace with function body.


#func rename_tag(tag: Control, new_name: String) -> void:
	#tag.name = new_name
	##var tag_node: Control = find_child("Tag")
	##tag_node.name = "BLOBY"


func _on_add_new_input_tags_box_pressed() -> void:
	if debug: print("add new group tag box")
	
	pass # Replace with function body.

# FIXME Will need to fix to connect to this signal as user creates new graphnodes in snap flow manager.
func _on_individual_tags_update_tag_cache() -> void:
	emit_signal("update_tag_cache")
	pass # Replace with function body.


#func _on_individual_tags_new_tag_added() -> void:
	#emit_signal("update_tag_cache")
	##pass # Replace with function body.


## FIXME SELF CONTAIN IN lABEL TO MAKE MODULAR AND CAN INSTANCE 
#func _on_button_toggled(toggled_on: bool) -> void:
	## FIXME HACK TO TEST
	#if toggled_on:
		#code_edit.hide()
	#else:
		#code_edit.show()
