extends Control

@export var my_building_data:BuildingData

func _ready():
	setup(my_building_data)

func setup(building):
	my_building_data = building
	$VBoxContainer/Building_name.text = building.display_name
	var temp_building = building.building_scene.instantiate()
	var building_texture = temp_building.get_node("Sprite2D").texture
	$VBoxContainer/Building_icon.texture = building_texture
	temp_building.queue_free()


func _get_drag_data(at_positon:Vector2):
	if my_building_data == null or my_building_data.building_scene == null:
		return null

	var invis_preview_control = Control.new()
	set_drag_preview(invis_preview_control)
	return {"is_new":true,
		"building_data": my_building_data,
		"icon": $VBoxContainer/Building_icon.texture
	}
