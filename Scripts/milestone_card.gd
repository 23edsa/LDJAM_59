extends Control

signal unlock_requested(milestone: MilestoneData)
@export var my_milestone:MilestoneData
@export var resource_manager:Node2D
var milestone_unlocked:bool = false
var resources:Dictionary = {}


func _ready():
	setup(my_milestone)

func setup(milestone):
	my_milestone = milestone
	$VBoxContainer/Top/HBoxContainer/RichTextLabel.text = milestone.display_name
	$VBoxContainer/Top/HBoxContainer/TextureRect.texture = milestone.building_to_unlock.icon
	$VBoxContainer/Bottom/Control2/HBoxContainer/Cost.text = str(milestone.resource_cost)
	$VBoxContainer/Bottom/Control2/HBoxContainer/Currency.text = milestone.resource_type
	resources[milestone.resource_type] = milestone.resource_cost

func _process(delta):
	if not milestone_unlocked:
		if resource_manager == null:
			return
		if resource_manager.resources[my_milestone.resource_type] >= my_milestone.resource_cost:
			modulate = Color(1,1,1,1)
		else: modulate = Color(0.4,0.4,0.4,1)

func _on_button_pressed():
	if resource_manager.try_consume(resources):
		milestone_unlocked = true
		unlock_requested.emit(my_milestone)
		modulate = Color(1,1,1,1)
		$VBoxContainer/Bottom/Control/Button.queue_free()
		var unlocked_label:Label = Label.new()
		unlocked_label.text = "UNLOCKED"
		unlocked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unlocked_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		unlocked_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		$VBoxContainer/Bottom/Control.add_child(unlocked_label)
	else: print("you dont have enough to unlock this")
	
