extends Area2D
class_name BasicBuilding

# Base stats that all buildings share
@export var building_name:String = "Basic Building"
@export var Generator_time:float = 5.0
@export var click_boost_amount:float = 0.5

# Keys should be Strings (e.g., "power"), Values should be Numbers (e.g., 5)
@export var produces: Dictionary = {"money": 0}
@export var consumes: Dictionary = {}
var resource_manager:Node2D
var is_working:bool = false



signal resource_transaction_requested(consume_dict:Dictionary, produce_dict:Dictionary)

#space for upgrades variables
var current_level:int = 1
var upgrade_currency
var upgrade_cost

@onready var timer = $GeneratorTimer
var retry_timer:Timer
@export var retry_timer_period:float = 1.0

func _ready():
	timer.timeout.connect(_on_generator_timer_timeout)
	
	#1 second retry timer if there was not enough resources to launch production
	retry_timer = Timer.new()
	retry_timer.wait_time = retry_timer_period
	retry_timer.one_shot = true
	retry_timer.timeout.connect(try_start_generation)
	add_child(retry_timer)
	call_deferred("try_start_generation") 
	
	timer.wait_time = Generator_time
	timer.start()
	timer.one_shot = true

func try_start_generation():
	if resource_manager == null:
		return
		
	if consumes.is_empty() or resource_manager.try_consume(consumes):
		is_working = true
		timer.start(Generator_time)
	else:
		is_working = false
		timer.stop()
		retry_timer.start()
	

func _on_generator_timer_timeout():
	#generate_resources()
	#timer.start(Generator_time)
	if not is_working:
		return
		
	if resource_manager != null and not produces.is_empty():
		resource_manager.produce_resources(produces)
	
	is_working = false
	
	try_start_generation()
	
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
	
func _process(delta):
	if is_working:
		$ProgressBar.value = remap($GeneratorTimer.time_left,Generator_time, 0, 0, 100)
	else:
		$ProgressBar.value = 0
	
	
