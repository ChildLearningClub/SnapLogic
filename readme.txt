NOTES on Editing Plugin Scenes:
	
	1. When editing scene_viewer.tscn Control Nodes "Project Scenes", "Favorites", "Global Collections" and "Shared Collections" will be generated
	under "MainTabContainer" and should be removed before saving and closing the scene.
	
	2. When editing either sub_collection_tab.tscn, main_project_scenes_tab.tscn or main_favorites_tab.tscn a Node2D "MultiSelectBox" will be generated 
	under "HFLOWContainer" and should be removed before saving and closing the scene.
	
	3. Nodes referenced in main_base_tab.gd script must match node hierarchy for inherited scenes:
	main_collection_tab.tscn, main_favorites_tab.tscn, and main_project_scenes_tab.tscn
	
	
	RE-WRITE LATER WHEN FRESH IN MIND HOW THIS IS EFFECTED
	4. When editing snap_flow_manager_graph and the panel is open in within the 3D viewport, any changes within the 3D viewport will overwrite the master version. 
	This is because it saves over itself
