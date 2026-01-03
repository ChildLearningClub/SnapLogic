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


V0.8.4-alpha
- **Fix:** On initial creation of collections scene_view buttons now always created even if thumbnails already exist.
- **Fix:** "tags" are now referenced from cache, making them available immediately, rather then "tags" stored in the button or directly from the scene's metadata.
- **Fix:** "tags" now properly being saved to packed .tscn project scenes. - Moved embed_shared_and_decrypted_global_tags_in_scene() before save_and_instantiate_scene().
- **Fix:** Unwanted rotation and scaling issues when placing scene fixed by locking the scene preview. REFERENCE: https://github.com/godotengine/godot-proposals/issues/3046
- **Fix:** Newly added tags no longer overwrite existing tags in Snap Flow Manager.
- **Fix:** "remove_tag" signal properly connected for tags added to Snap Flow Manager after session start.
- **FIX:** Connections added to existing connections in Snap Flow Manager now actually get added to the connection.
- **FIX:** Removed Icon from ChangeMaterialButton in scene_viewer.tscn to stop "ERROR: Path to node is invalid: Subviewport" on plugin activation.
- **FIX:** Set scale snapping to value of 0.001 to avoid engine node warning of non-uniform scaling.
- **REFACTORED:** create_scene_preview function to reuse scene_preview. Benefits: less code redundancy, easier maintenance, and less bugs.
- **FIX:** Folder filter running constantly through physics_process when enabled.


V0.8.5-alpha
- **Added:** Support for Terrain3D Objects height will change with deformed terrain height maintaining offset.
- **CHANGED:**  Godot 4.5+ Using new foldable container
- **FIX:** Cyclic referencing on initial startup.
- **Added:** Drag line and drag path multi-mesh instances with collisions with Terrain3D surface height matching of line points. filtered by location relative to deformation.
- **FIX:** Spawning error message when attempting to create scene preview with no 3D Scene. 
- **FIX:** Main tabs signal connection now connected on initial plugin activation.
- **FIX:** Filters and last selected tabs now correctly re-applied at editor restart.
- **FIX:** Stop favorite button from propagating up and creating Scene Preview when pressed.
- **CHANGED:** Bumped up default thumbnail size in Scene Viewer Panel.
- **Added:** Resize thumbnails to panel best fit within slider value.
- **FIX:** Proper reloading of collection order and applying of filters.


V0.8.6-alpha
- **FIX:** Single-threaded blocking on import, Reworked collection import code.
- **CHANGED:** All Materials in project loaded into VRAM on project start single-threaded to Materials loaded into VRAM multi-threaded on collection open.
- **CHANGED:** Simplified best fit code.
- **FIX:** Scene Preview's position is kept more current so next Scene Preview's starting position matches previous one.
- **FIX:** Scene Viewer Panel background now follows theme base color.
- **Added:** Support for Godot 4.6 and style consistency with new modern style.
- **FIX:** ERROR: Cannot call method 'find_child' on a null value. When removing favorite and collection with matching favorite not open.
- **Added:** Support for .obj filetype in project. 


V0.8.7-alpha main-branch - 2026-01-03
- **FIX:** Renaming collections and scene dependency paths. 
- **FIX:** BUG _handles changed to exclude which caused crash with TerraBrush
- **FIX:** Exclude TerraBrush from tri sorting so TerraBrush collision at 0.0 not registered with non_collision_object_snapping function.
- **CHANGED:** dragline added to tree as displayed as folded
- **CHANGED:** ScenePreview created as local and folded for more visible collision shapes.
- **Added:** Better support for Terrain3d and TerraBrush
- **Added:** UI cycle button and icons for draw_line Path3D Line and Path3D Draw.
- **FIX:** draw_line Path3D line and draw line fixes. and addition of "Y_UP", "ALIGN_NORMAL" and "SKEW_TO_CURVE".
- **FIX:** Errors related to scene_preview not being in scene tree when ScenePreview node deleted from tree.

V0.8.8-dev dev-branch - Active
