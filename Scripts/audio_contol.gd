extends CanvasLayer

@onready var music = $MarginContainer/VBoxContainer/Music_volume
@onready var sfx = $MarginContainer/VBoxContainer/SFX_volume
@onready var mute = $MarginContainer/VBoxContainer/CheckButton

func _ready():
	music.value = AudioManager.music_volume * 100
	sfx.value = AudioManager.sfx_volume * 100
	mute.button_pressed = AudioManager.is_muted
	send_update()

func send_update():
	AudioManager.update_audio_man(music.value, sfx.value, mute.button_pressed)


func _on_music_volume_value_changed(_value):
	send_update()

func _on_sfx_volume_value_changed(_value):
	send_update()


func _on_check_button_toggled(_toggled_on):
	send_update()
