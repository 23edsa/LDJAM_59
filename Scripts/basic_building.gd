extends Area2D
class_name BasicBuilding

# Base stats that all buildings share
@export var building_name:String = "Basic Building"
@export var Generator_time:float = 5.0
@export var click_boost_amount:float = 0.5
#Structure for adjacency bonuses 
#{ "NeighborName": {"prod_mod": 1.5, "cons_mod": 1.2, "speed_mod": 0.8} }
@export var adjacency_rules: Dictionary = {}

var current_prod_mod:float = 1.0
var current_cons_mod:float = 1.0
var current_speed_mod:float = 1.0
var active_affectors_count:int = 0



# Keys should be Strings (e.g., "power"), Values should be Numbers (e.g., 5)
@export var produces: Dictionary = {"money": 0}
@export var consumes: Dictionary = {}
var resource_manager:Node2D
var is_working:bool = false
var refund_value:float = 0
var display_name: String = ""



signal resource_transaction_requested(consume_dict:Dictionary, produce_dict:Dictionary)

#space for upgrades variables
var current_level:int = 1
var upgrade_currency
var upgrade_cost

@onready var timer = $GeneratorTimer
var retry_timer:Timer
var tooltip_timer:Timer
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
	$AdjacencyLabel.visible = false
	


func calculate_adjacency(neighbor_names:Array):
	current_prod_mod = 1.0
	current_cons_mod = 1.0
	current_speed_mod = 1.0
	active_affectors_count = 0
	
	for neighbor in neighbor_names:
		if adjacency_rules.has(neighbor):
			var rules = adjacency_rules[neighbor]
			if rules.has("prod_mod"): current_prod_mod *= rules["prod_mod"]
			if rules.has("cons_mod"): current_cons_mod *= rules["cons_mod"]
			if rules.has("speed_mod"): current_speed_mod *= rules["speed_mod"]
			active_affectors_count += 1
	var new_wait_time = max(0.01, Generator_time*current_speed_mod)
	if timer.wait_time != new_wait_time:
		var time_left_ratio = 0.0
		if timer.wait_time > 0:
			time_left_ratio = timer.time_left / timer.wait_time
		timer.wait_time = new_wait_time
		if is_working and timer.time_left > 0:
			timer.start(timer.wait_time * time_left_ratio)
	if active_affectors_count >0:
		$AdjacencyLabel.visible = true
		$AdjacencyLabel.text = str(active_affectors_count)
	if active_affectors_count == 0:
		$AdjacencyLabel.visible = false
		
func try_start_generation():
	if resource_manager == null:
		return
		
	var actual_consumes = {}
	for key in consumes.keys():
		actual_consumes[key] = consumes[key]*current_cons_mod
	
	
	if actual_consumes.is_empty() or resource_manager.try_consume(actual_consumes):
		is_working = true
		timer.start(timer.wait_time)
	else:
		is_working = false
		timer.stop()
		retry_timer.start()
	

func _on_generator_timer_timeout():
	if not is_working:
		return
		
	if resource_manager != null and not produces.is_empty():
		var actual_produces ={}
		for key in produces.keys():
			actual_produces[key] = produces[key]*current_prod_mod
			#print(actual_produces[key])

		resource_manager.produce_resources(actual_produces)

	is_working = false
	try_start_generation()
	AudioManager.play_sfx("pop")
	


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


#tooltip functionality:

func get_tooltip_text() -> String:
	var text = "[ " + display_name + " ]\n"

	var actual_time = Generator_time * current_speed_mod
	var time_diff = round((current_speed_mod - 1.0) * 100)
	
	var time_diff_text = ""
	if time_diff > 0:

		time_diff_text = " (+" + str(time_diff) + "%)" 
	elif time_diff < 0:

		time_diff_text = " (" + str(time_diff) + "%)" 
		
	text += "\nCycle Time: " + str(snapped(actual_time, 0.01)) + "s" + time_diff_text + "\n"

	
	if not produces.is_empty():
		text += "\nProduces:\n"
		for key in produces.keys():
			var base_val = produces[key]
			var actual_val = base_val * current_prod_mod
			

			var perc_diff = round((current_prod_mod - 1.0) * 100)
			
			var diff_text = ""
			if perc_diff > 0:
				diff_text = " (+" + str(perc_diff) + "%)"
			elif perc_diff < 0:
				diff_text = " (" + str(perc_diff) + "%)" 
				

			text += " + " + str(snapped(actual_val, 0.01)) + " " + key + diff_text + "\n"
			
	if not consumes.is_empty():
		text += "\nConsumes:\n"
		for key in consumes.keys():
			var base_val = consumes[key]
			var actual_val = base_val * current_cons_mod
			
			var perc_diff = round((current_cons_mod - 1.0) * 100)
			
			var diff_text = ""
			if perc_diff > 0:
				diff_text = " (+" + str(perc_diff) + "%)"
			elif perc_diff < 0:
				diff_text = " (" + str(perc_diff) + "%)"
				

			text += " - " + str(snapped(actual_val, 0.01)) + " " + key + diff_text + "\n"
			
	if not adjacency_rules.is_empty():
		text += "\nAffected by these neighbors:\n"
		for neighbor in adjacency_rules.keys():
			var rules = adjacency_rules[neighbor]
			text += " > " + neighbor + ": "
			if rules.has("prod_mod") and rules["prod_mod"] != 1.0:
				text += "Productivity x" + str(rules["prod_mod"]) + " "
			if rules.has("cons_mod") and rules["cons_mod"] != 1.0:
				text += "Consumption x" + str(rules["cons_mod"]) + " "
			if rules.has("speed_mod") and rules["speed_mod"] != 1.0:
				text += "Speed x" + str(rules["speed_mod"])
			text += "\n"
			
	return text
	

func _exit_tree():
	TooltipManager.hide_tooltip()
