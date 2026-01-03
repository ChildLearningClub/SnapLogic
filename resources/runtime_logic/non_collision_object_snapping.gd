@tool
extends Node

func will_this_run_at_runtime() -> void:
	print("BOTH")
	if Engine.is_editor_hint():
		print("this is running in editor!")
	else:
		print("this is running at runtime!")
