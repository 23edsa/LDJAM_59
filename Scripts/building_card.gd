extends Control

@export var my_building_data:BuildingData

func _ready():
	setup(my_building_data)

func setup(building):
	my_building_data = building
	$VBoxContainer/Building_name.text = building.display_name
	$VBoxContainer/Building_icon.texture = building.icon

func _get_drag_data(at_positon:Vector2):
	if my_building_data == null or my_building_data.building_scene == null:
		return null

	var invis_preview_control = Control.new()
	set_drag_preview(invis_preview_control)
	return my_building_data
