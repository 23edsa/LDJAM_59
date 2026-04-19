extends Control

@export var my_building_data:BuildingData
@export var resource_manager:Node2D


func _ready():
	setup(my_building_data)

func setup(building):
	my_building_data = building
	$VBoxContainer/Building_name.text = building.display_name
	var temp_building = building.building_scene.instantiate()
	var building_texture = temp_building.get_node("Sprite2D").texture
	$VBoxContainer/Building_icon.texture = building_texture
	$VBoxContainer/Label.text = "$" + str(building.building_cost)
	temp_building.queue_free()


func _get_drag_data(at_positon:Vector2):
	if my_building_data == null or my_building_data.building_scene == null:
		return null

	if resource_manager.resources["money"] < my_building_data.building_cost:
		print("not enough money to build this")
		return null
	
	
	var invis_preview_control = Control.new()
	set_drag_preview(invis_preview_control)
	return {"is_new":true,
		"building_data": my_building_data,
		"icon": $VBoxContainer/Building_icon.texture}

func _process(delta):
	if my_building_data == null or resource_manager == null:
		return
	if resource_manager.resources["money"] >= my_building_data.building_cost:
		modulate = Color(1,1,1,1)
	else: modulate = Color(0.4,0.4,0.4,1)
