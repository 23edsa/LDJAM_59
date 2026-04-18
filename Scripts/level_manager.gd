extends Control

@export var resource_manager:Node2D
@export var grid_size = Vector2(64,64)
var occupied_cells:Dictionary = {}

var ghost_preview:TextureRect

func _ready():
	ghost_preview = TextureRect.new()
	ghost_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost_preview.size = grid_size
	ghost_preview.z_index = 100
	ghost_preview.visible = false
	ghost_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ghost_preview)


func _can_drop_data(at_position:Vector2, data):
	if data is BuildingData:
		var target_grid_position = get_grid_position(at_position)
		
		ghost_preview.texture = data.icon
		ghost_preview.position = target_grid_position
		ghost_preview.visible = true

		if occupied_cells.has(target_grid_position):
			ghost_preview.modulate = Color(1, 0.5, 0.5, 0.5)
			return false
		ghost_preview.modulate = Color(1, 1, 1, 0.5)
		return true

func _drop_data(at_position, data):
	var building_data = data as BuildingData
	var target_grid_position = get_grid_position(at_position)
	var new_building = building_data.building_scene.instantiate()
	if resource_manager != null:
		new_building.resource_transaction_requested.connect(resource_manager.process_building_transaction)
	else:
		push_error("You forgot to assign the Resource Manager in the Level Manager inspector!")
	add_child(new_building)
	new_building.position = target_grid_position + (grid_size / 2.0)
	occupied_cells[target_grid_position] = new_building
	ghost_preview.visible = false
	

func get_grid_position(pos:Vector2):
	var x = floor(pos.x / grid_size.x) * grid_size.x
	var y = floor(pos.y / grid_size.y) * grid_size.y
	return Vector2(x, y)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if ghost_preview:
			ghost_preview.visible = false

func _process(_delta: float) -> void:
	if ghost_preview != null and ghost_preview.visible:
		var local_mouse = get_local_mouse_position()
		var manager_bounds = Rect2(Vector2.ZERO, size)
		if not manager_bounds.has_point(local_mouse):
			ghost_preview.visible = false
