extends Area2D

@export var efficiency_bonus: float = 0.2 

func _ready():
	print("Cooling station added. Boosting signal processing by ", efficiency_bonus * 100, "%")
	
	# Resource manager lowers "process_time" of all data centers
