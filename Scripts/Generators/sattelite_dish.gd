extends Area2D

@export var collection_time: float = 5.0
@export var click_boost_amount: float = 0.5
@export var signal_value: int = 1

@onready var timer = $CollectionTimer

func _ready():
	timer.wait_time = collection_time
	timer.start()
	
#click mechanic
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_dish_clicked()
		
func on_dish_clicked():
	var current_time_left = timer.time_left
	var new_time = max(0.01, current_time_left - click_boost_amount)
	
	timer.start(new_time)
	print("dish clicked, time remaining: ", new_time)
	
#collection mechanic
func _on_collection_timer_timeout():
	#can add more here to Resource_manager when ready
	print("Collected ", signal_value, " signal!")
	timer.start(collection_time)
