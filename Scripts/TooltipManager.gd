extends CanvasLayer

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/MarginContainer/Label

func _ready():
	panel.visible = false
	panel.z_index=500

func _process(_delta):
	if panel.visible:
		panel.global_position = panel.get_global_mouse_position() + Vector2(15, 15)

func show_tooltip(text: String):
	if panel != null and label != null:
		label.text = text
		panel.size = Vector2.ZERO 
		panel.visible = true


func hide_tooltip():
	if panel != null and panel.visible:
		panel.visible = false
