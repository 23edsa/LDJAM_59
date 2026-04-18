extends Area2D

@export var process_time: float = 3.0
@export var signal_consumed: int = 1
@export var cash_produced: int = 10

@onready var timer = $ProcessTimer

func _ready():
	timer.wait_time = process_time
	timer.start()
	
#processing loop
func _on_process_timer_timeout():
	var has_signal = true
	
	if has_signal:
		process_data()
	else:
		print("Waiting for raw signal to process.")
	
	timer.start(process_time)

func process_data():
	#remove the raw resource via resource manager? 
	#add money
	
	print("Processing complete: Used ", signal_consumed, " signal. Gained $", cash_produced)
