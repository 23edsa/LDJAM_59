extends Node2D

@onready var money_label= $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Money_Label
@onready var data_label = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Data_Label
@onready var power_label = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Power_Label
@onready var signal_label = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Control2/Label
@onready var endgame_goal:float = 1000000
@onready var progress = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Control2/ProgressBar

var has_won:float = false
var victory_screen = preload("res://Scenes/VictoryScreen.tscn")

var resources: Dictionary ={
	"raw_data": 10.0,
	"money": 600.0,
	"power": 0.0,
	"signal":0.0
}

func _ready():
	update_ui_labels(resources)
	
func try_consume(consumes:Dictionary) -> bool:
	for req_type in consumes.keys():
		var req_amount = consumes[req_type]
		if not resources.has(req_type) or resources[req_type] < req_amount:
			return false
	for req_type in consumes.keys():
		resources[req_type] -= consumes[req_type]
	update_ui_labels(resources)
	return true

func produce_resources(produces:Dictionary):
	for prod_type in produces.keys():
		var prod_amount = produces[prod_type]
		if resources.has(prod_type):
			resources[prod_type] += prod_amount
		else: resources[prod_type] = prod_amount
	update_ui_labels(resources)
		

#old transaction code, not used
func process_building_transaction(consumes:Dictionary, produces:Dictionary):
	for req_type in consumes.keys():
		var req_amount = consumes[req_type]
		if not resources.has(req_type) or resources[req_type] < req_amount:
			return #not enough of required resources
	for req_type in consumes.keys():
		var req_amount = consumes[req_type]
		resources[req_type] -= req_amount 
	
	for prod_type in produces.keys():
		var prod_amount = produces[prod_type]
		if resources.has(prod_type):
			resources[prod_type] += prod_amount
		else: return 
		
	update_ui_labels(resources) #old transaction code, not used

func update_ui_labels(resources):
	
	money_label.text = "Money: " + str(snapped(resources["money"],0.1))
	data_label.text = "Data: " + str(snapped(resources["raw_data"],0.1))
	power_label.text = "Power: " + str(snapped(resources["power"],0.1))
	signal_label.text = str(snapped(resources["signal"],1)) + "/" + str(snapped(endgame_goal,1))
	progress.value = remap(snapped(resources["signal"],1),0,endgame_goal,0,100)
	check_win_conditions()

func check_win_conditions():
	if has_won:
		return
		
	if resources["signal"] >= endgame_goal:
		has_won = true
		print("you win")
		var vic_sceen = victory_screen.instantiate()
		add_child(vic_sceen)
