extends Node

signal unlock_requested(milestone: MilestoneData)
@export var my_milestone:MilestoneData

func _ready():
	setup(my_milestone)

func setup(milestone):
	my_milestone = milestone
	$VBoxContainer/Top/HBoxContainer/RichTextLabel.text = milestone.display_name
	$VBoxContainer/Top/HBoxContainer/TextureRect.texture = milestone.building_to_unlock.icon
	$VBoxContainer/Bottom/Control2/HBoxContainer/Cost.text = str(milestone.resource_cost)
	$VBoxContainer/Bottom/Control2/HBoxContainer/Currency.text = milestone.resource_type

func _on_button_pressed():
	unlock_requested.emit(my_milestone)
