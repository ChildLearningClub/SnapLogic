@tool
extends Node
#extends EditorPlugin

# FIXME Need to decouple snapping logic into their own scripts from scene_viewer.gd and scene_snap_plugin.gd to reuse them here.


#func _ready() -> void:
	#print("the snap logic runtime is ready")
#const SceneViewer = preload("res://addons/scene_snap/scripts/scene_viewer.gd")
const NonCollisionObjectSnapping = preload("res://addons/scene_snap/resources/runtime_logic/non_collision_object_snapping.gd")


var new_scene_snap

func _ready() -> void:
	new_scene_snap = NonCollisionObjectSnapping.new()

func _physics_process(delta: float) -> void:
	pass
	#if new_scene_snap:
		#new_scene_snap.will_this_run_at_runtime()
