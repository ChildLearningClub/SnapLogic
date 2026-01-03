@tool
class_name TerraBrushHelper
extends Node3D

var terra_brush = null
var current_zone_position: Vector2i
var current_image_position: Vector2i


func get_mouse_click_to_zone_height(from: Vector3, direction: Vector3) -> Vector3:
	if terra_brush == null:
		return Vector3.INF

	# ORIGINAL
	#for i in range(20000):
		#var position = from + (direction * i * 0.1) - terra_brush.global_position
	for i in range(2000):
		var position = from + (direction * i * 1.1) - terra_brush.global_position

		get_pixel_to_zone_info(
			position.x + (terra_brush.zonesSize / 2),
			position.z + (terra_brush.zonesSize / 2),
			terra_brush.zonesSize,
			terra_brush.resolution
		)

		var zone = null
		if terra_brush.terrainZones != null:
			zone = get_zone_for_zone_info(current_zone_position)

		if zone != null and zone.get_heightMapImage() != null:
			var height_map_image: Image = zone.get_heightMapImage()
			var zone_height = height_map_image.get_pixelv(current_image_position).r

			if zone_height >= position.y:
				return Vector3(position.x, zone_height, position.z) + terra_brush.global_position

	return Vector3.INF



func get_pixel_to_zone_info(x: float, y: float, zones_size: int, resolution: int) -> void:
	var adj_x = x
	var adj_y = y
	if zones_size % 2 == 0:
		adj_x -= 0.5
		adj_y -= 0.5

	var zone_x_position = int(floor(adj_x / (zones_size - 1)))
	var zone_y_position = int(floor(adj_y / (zones_size - 1)))
	var zone_position = Vector2i(zone_x_position, zone_y_position)

	var fx = (adj_x / (zones_size - 1)) - zone_x_position
	var fy = (adj_y / (zones_size - 1)) - zone_y_position

	var zone_brush_x_position = int(round(fx * (zones_size - 1)))
	var zone_brush_y_position = int(round(fy * (zones_size - 1)))

	var resolution_zone_brush_x = zone_brush_x_position
	var resolution_zone_brush_y = zone_brush_y_position

	if resolution != 1:
		var image_size = get_image_size_for_resolution(zones_size, resolution)
		resolution_zone_brush_x = int(round( lerp(0, float(image_size - 1), float(zone_brush_x_position) / float(zones_size - 1) ) ))
		resolution_zone_brush_y = int(round( lerp(0, float(image_size - 1), float(zone_brush_y_position) / float(zones_size - 1) ) ))

	current_zone_position = zone_position
	current_image_position = Vector2i(resolution_zone_brush_x, resolution_zone_brush_y)



func get_image_size_for_resolution(zone_size: int, resolution: float) -> int:
	return int( ceil(zone_size / resolution) )



func get_zone_for_zone_info(current_zone_position: Vector2i) -> Variant:
	for zone: Variant in terra_brush.get_terrainZones().get_zones():
		if zone.zonePosition == current_zone_position:
			return zone
	return null
