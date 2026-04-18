extends Area2D
class_name BasicBuilding

# Base stats that all buildings share
@export var building_name:String = "Basic Building"
@export var Generator_time:float = 5.0
@export var click_boost_amount:float = 0.5

# Keys should be Strings (e.g., "power"), Values should be Numbers (e.g., 5)
@export var produces: Dictionary = {"money": 0}
@export var consumes: Dictionary = {}

signal resource_transaction_requested(consume_dict:Dictionary, produce_dict:Dictionary)

#space for upgrades variables
var current_level:int = 1
var upgrade_currency
var upgrade_cost

@onready var timer = $GeneratorTimer

func _ready():
	timer.timeout.connect(_on_generator_timer_timeout)
	timer.wait_time = Generator_time
	timer.start()


func _on_generator_timer_timeout():
	generate_resources()
	timer.start(Generator_time)
	
func generate_resources():
	resource_transaction_requested.emit(consumes, produces)


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_clicked()

func on_clicked():
	var current_time_left = timer.time_left
	var new_time = max(0.01, current_time_left-click_boost_amount)
	timer.start(new_time)
	print(building_name + " clicked! Time remaining: " + str(new_time))

func upgrade():
	pass
	
	
	
