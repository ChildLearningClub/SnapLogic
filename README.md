# SnapLogic

## Important please stucture the plugin files as shown below. Renaming SnapLogic-main to scene_snap my be required.
```
res://
└── addons
    └── scene_snap
        └── fonts
        └── icons
        └── plugin_scenes
        └── etc.....
```

SnapLogic User Manual V0.8.2-alpha (Until have proper docs page) 

To get started create a collection under the "Global Collections" Main Tab and drag scenes into the scene viewer panel


Alternatively outside your project for example on Windows:

Drag and drop your .glb files into the designated collection folder found within the user:// directory

C:\Users\username\AppData\Roaming\Godot\scene_snap\global_collections\scenes\Global Collections\New Collection  

This is also where the thumbnail cache is stored, simply removing the thumbnail_cache_global folder or the matching collection folder name within it will force a refresh on next start.

Removing unwanted collections can be done within the Editor -> Editor Settings -> Scene Snap Plugin


KEYBOARD INPUTS:

--------------------------
SCENE PREVIEW

KEY Q & RIGHT MOUSE CLICK:
With scene viewer panel and collection open creates a scene preview.

KEY Q & RIGHT MOUSE CLICK Again will remove scene preview



KEY Q & LEFT MOUSE CLICK WITH OBJECT SELECTED IN TREE WILL GRAB AND TREAT IT LIKE THE SCENE PREVIEW:
LEFT CLICK TO PLACE BACK DOWN


NOTE: BELOW INPUTS REQUIRE ACTIVE SCENE PREVIEW
--------------------------
CYCLE SCENE PREVIEW

KEY SHIFT AND MOUSE SCROLL WHEEL


--------------------------
CYCLE PHYSICS BODY

KEY B AND MOUSE SCROLL WHEEL


--------------------------
CYCLE COLLISIONS

KEY C AND MOUSE SCROLL WHEEL

--------------------------
CYCLE MATERIALS

KEY M AND MOUSE SCROLL WHEEL


--------------------------
SCALE AND ROTATION

KEY R AND E RESPECTIVELY (NOTE: WITH KEY PRESSED, RIGHT MOUSE CLICK FOR FINER CONTROL)



------------------------------------------------------------------------------
LIMITATIONS:

CURRENTLY A LOT:
- THE MATERIAL APPLIED TO A SCENE THAT IS PLACED CANNOT BE CHANGED THROUGH THE MATERIAL CYCLE BUTTON.
- NO DRAG AND DROP OR SCENE BUTTON PRESS TO ADD INTO SCENE
- SNAPPING WHICH IS A PRIMARY FOCUS OF THE ADDON IS NOT EVEN IMPLEMETED!
- A LOT THINGS ARE STILL BROKEN
- EXPECT ERRORS AND MAYBE CRASHES!

TROUBLESHOOTING:
Sometimes the editor will freeze while textures are being written to the filesystem, just give it a bit of time and if still frozen restart the editor.
if you close the editor and some but not all the textures are copied to the filesystem, you will need to remove the respective collection folder name under collections folder for the import process to be triggered again after editor restart.
