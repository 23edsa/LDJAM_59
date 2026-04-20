extends Control

@export var my_building_data:BuildingData
@export var resource_manager:Node2D


func _ready():
	setup(my_building_data)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(building):
	my_building_data = building
	$MarginContainer/VBoxContainer/Building_name.text = building.display_name
	var temp_building = building.building_scene.instantiate()
	var building_texture = temp_building.get_node("Sprite2D").texture
	$MarginContainer/VBoxContainer/Building_icon.texture = building_texture
	$MarginContainer/VBoxContainer/Label.text = "$" + str(building.building_cost)
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
		"icon": $MarginContainer/VBoxContainer/Building_icon.texture}
	TooltipManager.hide_tooltip()

func _process(delta):
	if my_building_data == null or resource_manager == null:
		return
	if resource_manager.resources["money"] >= my_building_data.building_cost:
		modulate = Color(1,1,1,1)
	else: modulate = Color(0.4,0.4,0.4,1)

func _on_mouse_entered():
	
	if my_building_data == null or my_building_data.building_scene == null:
		return
		
	# Instantiate a temporary copy to read its variables
	var temp = my_building_data.building_scene.instantiate()
	
	var text = "[ " + my_building_data.display_name + " ]\n"
	text += "Cost: " + str(my_building_data.building_cost) + " Money\n"
	
	if not temp.produces.is_empty():
		text += "\nProduces:\n"
		for key in temp.produces.keys():
			text += " + " + str(temp.produces[key]) + " " + key + "\n"
			
	if not temp.consumes.is_empty():
		text += "\nConsumes:\n"
		for key in temp.consumes.keys():
			text += " - " + str(temp.consumes[key]) + " " + key + "\n"
			
	if not temp.adjacency_rules.is_empty():
		text += "\nAffects Neighbors:\n"
		for neighbor in temp.adjacency_rules.keys():
			var rules = temp.adjacency_rules[neighbor]
			text += " > " + neighbor + ": "
			if rules.has("prod_mod"): text += "Prod x" + str(rules["prod_mod"]) + " "
			if rules.has("cons_mod"): text += "Cons x" + str(rules["cons_mod"]) + " "
			if rules.has("speed_mod"): text += "Speed x" + str(rules["speed_mod"])
			text += "\n"
			
	temp.queue_free() # Clean up the copy!
	TooltipManager.show_tooltip(text)

func _on_mouse_exited():
	
	TooltipManager.hide_tooltip()
