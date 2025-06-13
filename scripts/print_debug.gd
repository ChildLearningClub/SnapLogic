@tool
extends Node

## Quickly enable and disable debug print statments within the plugin
## Setting found at Editor -> Editor Settings -> Scene Snap Plugin -> Enable Plugin debug print Statements
func run() -> bool:
	var settings = EditorInterface.get_editor_settings()
	var debug_print_setting: String = "scene_snap_plugin/enable_plugin_debug_print_statements"
	if not settings.has_setting(debug_print_setting):
		settings.set_setting(debug_print_setting, false)
		return false

	else: # set the print_enabled flag to match what is in settings
		return settings.get_setting(debug_print_setting)
