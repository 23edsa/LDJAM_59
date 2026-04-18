extends Area2D

# can buy battery tier upgrades to increase bonus
@export var capacity_bonus: int = 50

func _ready():
	print("Signal Buffer installed. Providing +", capacity_bonus, " max storage.")
	
	# For later: Resource manager increases max capacity of satellites here
