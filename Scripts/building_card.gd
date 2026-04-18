extends Node

@export var my_building_data:BuildingData

func _ready():
	setup(my_building_data)

func setup(building):
	$VBoxContainer/Building_name.text = building.display_name
	$VBoxContainer/Building_icon.texture = building.icon
