@tool
class_name SceneDataCache
extends Resource

@export var scene_favorites: Array[String] = []
@export var scene_data: Dictionary[String, Dictionary] = {}

## On import store a cache of information about the scene
## Used to avoid reloading each scene every restart to get data from scene file
# NOTE: update cache when scene file read, remove from cache if collection removed

# If to combine into one possible favorites entry
# Example Favorites: -> scene_full_path: "favorites": [true]

# Dictionary[String, Dictionary[String, Array[String]]]
# Example Tags: -> scene_full_path: "tags": [tag1, tag2, tag3]
# Example Animations: -> scene_full_path: "animations": [animation1, animation2, animation3]

# TODO Cleanup dict on collection removed
#@export var scene_data: Dictionary[String, Dictionary] = {}
