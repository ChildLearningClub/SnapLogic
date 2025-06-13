class_name CustomGraphNode 
extends GraphNode
# Reference: https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/
# Reference: https://norech.com/blog/post/introduction-graphnode-and-graphedit


var ports_connected = {
	"input": {},
	"output": {}
}

# some code ...

func is_port_connected(self_port_type: String, self_port: int) -> bool:
	for port_idx in ports_connected[self_port_type].keys():
		if ports_connected[self_port_type][port_idx]:
			return true
	return false

# ...

func on_connect(self_port_type: String, self_port: int, other_node: CustomGraphNode, other_port: int) -> void:
	print("I am connected to ", other_node, " on ", self_port_type, " port ", other_port)
	ports_connected[self_port_type][self_port] = true

func on_disconnect(self_port_type: String, self_port: int, other_node: CustomGraphNode, other_port: int) -> void:
	print("I am disconnected to ", other_node, " on ", self_port_type, " port ", other_port)
	ports_connected[self_port_type][self_port] = false
