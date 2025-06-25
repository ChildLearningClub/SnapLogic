# SnapLogic CHANGELOG

V0.8.2-alpha main-branch - 2025-06-13
- Fixed search filtering not working on initial start before changing tabs
- Re-worked materials buttons and functionality
- Remember material favorites between sessions
- Fixed button favorite unfavorite issues and visibility when heart filter active
- Fixed preview collision shapes scaling issue when cycling collisions
- Changed back to saving to project filesystem as .tscn
- Added .scn scene files to the unused collection scenes cleanup function 
- clearing stale scene buttons from Favorites collection when unfavorite from other tabs
- update_item_list_collections() on rename of tab
- Project collection folders are renamed and removed in-sync with tab renaming and collection removal 
- scene_viewer_panel_instance.custom_minimum_size bumped up from 173 to 216 as a result of added material select button
- Fixed error when no sub tabs exists when changing to either "Global Collections or "Shared Collections" main tabs
- batch adding to collections while skipping duplicates (Entire import/load system still seems a bit buggy)
- When adding collection tab the newly added tab now gets focus. (Still small issue where previous tab is still lit up)
- Fixed Spawning of errors from process() if scene_preview or dragging_node removed prematurely from scene tree.   
- Added fallback Scene loading directly from disk when not available in lookup
- Fixed viewing and instancing of project scenes
- Refactored filesystem filter by folder
- Fixed broken cycling of scenes when filters applied in non popup window mode.


V0.8.3-alpha main-branch - 2025-06-25
- Scene data cache properly cleaned up at start and collection removal
- Scene data cache updated when collection renamed
- KEY_SHIFT and mouse button click on tags updated from removing all tags to only removing global tags
- Removing all tags updated to long pressing active tags for 1 sec or more
- Enable/Disable shared collections shared tags and refactored updating of tag icon. Disable shared collections this is now the default.
- Creation of scene_view buttons has been moved to after scene_data_cache is filled with the current tags
- Selecting scene_view_button updates scene_preview
- When tags are removed in snap manager, connections are now removed with them
- Clicking scene button now instances scene in 3D viewport
- Refactored thumbnail camera view for multiple mesh scenes
- Added ESCAPE Key to exit scene_preview mode
- Added functionality to match scale and rotation of previous object. This is now the default.
- Fixed initial load ERROR Unrecognized UID: "uid://dfb5uhllrlnbf" for debug script by switching to full path (Thanks dnbroo | Discord)
- Enabled tags in this version.


V0.8.4-dev dev-branch - Active