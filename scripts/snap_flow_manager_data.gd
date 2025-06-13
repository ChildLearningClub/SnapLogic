class_name SnapManagerData
extends Resource

#const GraphNodeScript = preload("res://addons/scene_snap/scripts/graph_node_script.gd")




#enum snap_options {
	#FLOOR,
	#CIELING,
	#LEFT,
	#RIGHT
#}

#var output_flags: Array[bool] = []

@export var connections: Array
@export var nodes: Array

#@export var name: String
#@export var title: String
#@export var type: String
#@export var offset: Vector2
#@export var size: Vector2
##@export var data = {}
#
##@export var graph_node_data: Dictionary[String, Array] = 
#
#@export var data: Dictionary[String, Array] = {}

# Connections will modified through the Graphedit but saved and output from here 

#func save_data(file_name):
	#var graph_data = SnapManagerData.new()
	#graph_data.connections = $Graph.get_connection_list()
	#for node in $Graph.get_children():
		#if node is GraphNode:
			#var node_data = NodeData.new()
			#node_data.name = node.name
			#node_data.type = node.type
			#node_data.offset = node.offset
			#node_data.data = node.data
			#graph_data.nodes.append(node_data)
	#if ResourceSaver.save(graph_data, file_name) == OK:
		#print("saved")
	#else:
		#print("Error saving graph_data")

#func output_result() -> Array[bool]:
	#output_flags.append(snap_options)
	#return output_flags
