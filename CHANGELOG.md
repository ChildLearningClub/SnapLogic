# SnapLogic CHANGELOG

V0.8.2-alpha - 2025-06-13
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


V0.8.3-dev dev-branch - Active
- Scene data cache properly cleaned up at start and collection removal
- Scene data cache updated when collection renamed
- KEY_SHIFT and mouse button click on tags updated from removing all tags to only removing global tags
- Removing all tags updated to long pressing active tags for 1 sec or more
- Enable/Disable shared collections shared tags and refactored updating of tag icon
- Creation of scene_view buttons moved to after scene_data_cache filled to current tags