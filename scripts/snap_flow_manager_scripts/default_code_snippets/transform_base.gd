@tool
extends Node3D
class_name TransformBase

# NOTE: object_to_snap is any mesh that has a tag
# that is connected to this Output
# Get scene_preview and other node from connections?
#var change_pivot: bool



func transform(object_to_snap: Node3D, vector_normal: Vector3, run_continuus: bool = true) -> bool:
# YOUR TRANSFORM CODE HERE
	return run_continuus
