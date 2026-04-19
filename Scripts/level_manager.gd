extends Control

@export var resource_manager:Node2D
@export var grid_size = Vector2(64,64)
var occupied_cells:Dictionary = {}
var moving_building_data:Dictionary = {}

var ghost_preview:TextureRect

func _ready():
	ghost_preview = TextureRect.new()
	ghost_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost_preview.size = grid_size
	ghost_preview.z_index = 100
	ghost_preview.visible = false
	ghost_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ghost_preview)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var is_new_building = typeof(data) == TYPE_DICTIONARY and data.has("is_new")
	
	var is_moving_building = false
	if typeof(data) == TYPE_DICTIONARY and data.has("is_move"):
		is_moving_building = true
		
	if is_new_building or is_moving_building:
		var target_grid_pos = get_grid_position(at_position)
		
		# Set the preview texture
		ghost_preview.texture = data["icon"]
			
		ghost_preview.position = target_grid_pos - (grid_size / 2.0)
		ghost_preview.size = grid_size 
		ghost_preview.visible = true
		ghost_preview.move_to_front() 
		
		# Check if the cell is blocked
		if occupied_cells.has(target_grid_pos):
			ghost_preview.modulate = Color(1, 0.5, 0.5, 0.5) # Turn red
			return false 
			
		ghost_preview.modulate = Color(1, 1, 1, 0.5) # Turn normal
		return true
		
	return false

func _drop_data(at_position, data):
	var target_grid_pos = get_grid_position(at_position)
	
	if typeof(data) == TYPE_DICTIONARY and data.has("is_new"):
		var building_data = data["building_data"] as BuildingData
		var new_building = building_data.building_scene.instantiate()
		
		if resource_manager != null:
			new_building.resource_transaction_requested.connect(resource_manager.process_building_transaction)
			new_building.resource_manager = resource_manager
	
		add_child(new_building)
		new_building.position = target_grid_pos
		occupied_cells[target_grid_pos] = new_building
		
	elif typeof(data) == TYPE_DICTIONARY and data.has("is_move"):
		var building = data["node"]
		building.position  = target_grid_pos
		building.visible = true
		building.timer.paused = false
		occupied_cells[target_grid_pos] = building
		
		moving_building_data = {}
	
	ghost_preview.visible = false
	
	
func get_grid_position(pos:Vector2):
	var x = round(pos.x / grid_size.x) * grid_size.x
	var y = round(pos.y / grid_size.y) * grid_size.y
	return Vector2(x, y)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if ghost_preview:
			ghost_preview.visible = false
			
		if not moving_building_data.is_empty():
			var building = moving_building_data["node"]
			
			building.queue_free()
			moving_building_data = {}
			
func _get_drag_data(at_positon:Vector2):
	var grid_pos = get_grid_position(at_positon)
	
	if occupied_cells.has(grid_pos):
		var building_to_move = occupied_cells[grid_pos]
		
		moving_building_data = {
			"is_move":true,
			"node":building_to_move,
			"original_pos":grid_pos,
			"icon": building_to_move.get_node("Sprite2D").texture
			}
		building_to_move.visible = false
		occupied_cells.erase(grid_pos)
		building_to_move.timer.paused = true
		
		var invis_preview = Control.new()
		invis_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_drag_preview(invis_preview)
		
		return moving_building_data
	return null
		

func _process(_delta: float) -> void:
	if ghost_preview != null and ghost_preview.visible:
		var local_mouse = get_local_mouse_position()
		var manager_bounds = Rect2(Vector2.ZERO, size)
		if not manager_bounds.has_point(local_mouse):
			ghost_preview.visible = false
