extends CanvasLayer

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/MarginContainer/Label

func _ready():
	panel.visible = false
	panel.z_index=500

func _process(_delta):
	if panel.visible:
		var mouse_pos = panel.get_global_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size

		var offset = Vector2(15, 15)
		var final_pos = mouse_pos + offset
		
		if final_pos.x + panel.size.x > viewport_size.x:
			final_pos.x = mouse_pos.x - panel.size.x - offset.x
			

		if final_pos.y + panel.size.y > viewport_size.y:
			final_pos.y = mouse_pos.y - panel.size.y - offset.y
			
		panel.global_position = final_pos

func show_tooltip(text: String):
	if panel != null and label != null:
		label.text = text
		panel.size = Vector2.ZERO 
		panel.visible = true


func hide_tooltip():
	if panel != null and panel.visible:
		panel.visible = false
