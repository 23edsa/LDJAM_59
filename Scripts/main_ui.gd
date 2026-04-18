extends CanvasLayer

@export var all_buildings:Array[BuildingData]
@export var all_milestones:Array[MilestoneData]

@export var building_card_scene:PackedScene
@export var milestone_card_scene:PackedScene

#Probably would want to initialize resources here as well
@onready var resource_manager = $Background/MilestoneSplit/LeftSide/ResourcePanel/ResourceManager

var unlocked_buildings:Array[BuildingData] = []

@onready var buildings_container = $Background/MilestoneSplit/LeftSide/BuildingsManagerPanel/Buildings_Hbox
@onready var milestones_container = $Background/MilestoneSplit/RightSide/PanelContainer/MilestoneScrollContainer/Milestones_VBox

func _ready():
	#init starting buildings and populate building list
	for buildings in all_buildings:
		if buildings.initially_unlocked:
			unlock_building(buildings)
	#populate milestones
	for milestone in all_milestones:
		var milestone_card = milestone_card_scene.instantiate()
		milestones_container.add_child(milestone_card)
		milestone_card.setup(milestone)
		milestone_card.unlock_requested.connect(_on_milestone_unlock_requested)

func unlock_building(building:BuildingData):
	if not unlocked_buildings.has(building):
		unlocked_buildings.append(building)
		var building_card = building_card_scene.instantiate()
		buildings_container.add_child(building_card)
		building_card.setup(building)

func _on_milestone_unlock_requested(milestone:MilestoneData):
	var resource_type = milestone.resource_type
	var cost = milestone.resource_cost
	var current_amount = resource_manager.get(resource_type)
	
	if current_amount == null:
		push_warning("resource type '" + resource_type + "' doesnt exist")
		return	
	if current_amount >= cost:
		resource_manager.set(resource_type, current_amount - cost)
		print("milestone unlocked!")
		unlock_building(milestone.building_to_unlock)
	else: print("not enough resources!")
