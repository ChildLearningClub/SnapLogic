@tool
extends MainBaseTab

#@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer # Required for scroll focus
#@onready var scroll_container: ScrollContainer = $VBoxContainer/ButtonTagsHBox/ScrollContainer

@onready var filter_2d_3d_button: Button = %Filter2D3DButton
#@onready var tag_panel: Control = %TagPanel

#func _on_global_search_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#if debug: print("enable global")
	#else:
		#if debug: print("disable global")
