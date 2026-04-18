extends Control

@export var grid_size = Vector2(64,64)
var occupied_cells:Dictionary = {}

func _can_drop_data(at_position:Vector2, data):
	if data is BuildingData:
		var target_grid_position = get_grid_position(at_position)

		if occupied_cells.has(target_grid_position):
			return false
		return true

func _drop_data(at_position, data):
	var building_data = data as BuildingData
	var target_grid_position = get_grid_position(at_position)
	var new_building = building_data.building_scene.instantiate()
	add_child(new_building)
	new_building.position = target_grid_position
	occupied_cells[target_grid_position] = new_building
	

func get_grid_position(pos:Vector2):
	var x = floor(pos.x / grid_size.x) * grid_size.x
	var y = floor(pos.y / grid_size.y) * grid_size.y
	return Vector2(x, y)
