@tool
extends Node3D


@export var mesh_material_override: StandardMaterial3D:
	set(value):
		print("Setter called with", value)
		mesh_material_override = value
		update_mesh()






func _ready() -> void:
	update_mesh()



func update_mesh() -> void:
	var child: MeshInstance3D = get_child(0)
	child.set_surface_override_material(0, mesh_material_override)
