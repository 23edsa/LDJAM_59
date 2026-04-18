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

	var preview_texture = TextureRect.new()
	preview_texture.texture = my_building_data.icon
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = Vector2(64,64)
	preview_texture.modulate = Color(1,1,1,0.5)
	
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -preview_texture.custom_minimum_size/2
	set_drag_preview(preview_control)
	return my_building_data
