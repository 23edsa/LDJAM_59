extends Control

@export var resource_manager:Node2D
@export var grid_size = Vector2(64,64)
var occupied_cells:Dictionary = {}
var moving_building_data:Dictionary = {}

var moving_continues:bool = false

var ghost_preview:TextureRect
var current_hovered_cell: Vector2 = Vector2(-999, -999)

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
		if not moving_continues:
			AudioManager.play_sfx("pickup")
		moving_continues = true
		
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
		if resource_manager.resources["money"] < building_data.building_cost:
			ghost_preview.visible = false
			return
		
		resource_manager.resources["money"] -= building_data.building_cost
		var new_building = building_data.building_scene.instantiate()
		
		if resource_manager != null:
			new_building.resource_transaction_requested.connect(resource_manager.process_building_transaction)
			new_building.resource_manager = resource_manager
			new_building.refund_value = building_data.building_cost
			new_building.display_name = building_data.display_name
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
	moving_continues = false
	AudioManager.play_sfx("construct")
	update_local_adjacencies(target_grid_pos)
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
			
			if resource_manager !=null:
				resource_manager.resources["money"] += building.refund_value
			
			building.queue_free()
			moving_continues = false
			AudioManager.play_sfx("deconstruct")

			moving_building_data = {}
		TooltipManager.hide_tooltip()
			
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
	update_local_adjacencies(grid_pos)
	TooltipManager.hide_tooltip()
	
	return null
	

func _process(_delta: float) -> void:
	if ghost_preview != null and ghost_preview.visible:
		var local_mouse = get_local_mouse_position()
		var manager_bounds = Rect2(Vector2.ZERO, size)
		if not manager_bounds.has_point(local_mouse):
			ghost_preview.visible = false
	if ghost_preview != null and not ghost_preview.visible:
		var local_mouse = get_local_mouse_position()
		var manager_bounds = Rect2(Vector2.ZERO, size)
		if manager_bounds.has_point(local_mouse):
			var grid_pos = get_grid_position(local_mouse)
			if grid_pos != current_hovered_cell:
				current_hovered_cell = grid_pos
				
				if occupied_cells.has(grid_pos):
					var building = occupied_cells[grid_pos]
					if building.has_method("get_tooltip_text"):
						TooltipManager.show_tooltip(building.get_tooltip_text())
				else: TooltipManager.hide_tooltip()
		else:
			# The mouse left the Level Manager completely
			if current_hovered_cell != Vector2(-999, -999):
				current_hovered_cell = Vector2(-999, -999)
				TooltipManager.hide_tooltip()


func update_local_adjacencies(center_pos:Vector2):
	
	var directions = [Vector2(0,-grid_size.y), Vector2(0,grid_size.y),
	Vector2(-grid_size.x,0),Vector2(grid_size.x,0)]
	
	var cells_to_update = [center_pos]
	for dir in directions:
		cells_to_update.append(center_pos+dir)
	
	for pos in cells_to_update:
		if occupied_cells.has(pos):
			var building = occupied_cells[pos]

			var my_neighbors = []
			for dir in directions:
				var neighbor_pos = pos+dir
				if occupied_cells.has(neighbor_pos):
					my_neighbors.append(occupied_cells[neighbor_pos].building_name)
					

			if building.has_method("calculate_adjacency"):
				building.calculate_adjacency(my_neighbors)
