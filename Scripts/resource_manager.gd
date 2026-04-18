extends Node2D

@onready var money_label= $HBoxContainer/Money_Label
@onready var data_label = $HBoxContainer/Data_Label
@onready var power_label = $HBoxContainer/Power_Label

var resources: Dictionary ={
	"raw_data": 10.0,
	"money": 10.0,
	"power": 10.0
}

func _ready():
	update_ui_labels(resources)

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
		
	update_ui_labels(resources)

func update_ui_labels(resources):
	
	money_label.text = "Money: " + str(resources["money"])
	data_label.text = "Data: " + str(resources["raw_data"])
	power_label.text = "Power: " + str(resources["power"])
