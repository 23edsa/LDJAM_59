extends Node

var sounds: Dictionary = {
	"bgm": preload("res://Assets/Audio/Signal_02_eq.mp3"),
	"deconstruct": preload("res://Assets/Audio/building_destroy.wav"),
	"pickup": preload("res://Assets/Audio/Pickup.wav"),
	"construct": preload("res://Assets/Audio/Construct.wav"),
	"click": preload("res://Assets/Audio/Click.wav"),
	"pop": preload("res://Assets/Audio/pop_2.wav")
}
var music_volume = 0.3
var sfx_volume = 0.3




func play_bgm():
	var bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.stream = sounds["bgm"]
	bgm_player.volume_linear = music_volume
	bgm_player.play()
	bgm_player.finished.connect(bgm_player.play)
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			play_sfx("click")
	

func play_sfx(sound_name: String):

	if not sounds.has(sound_name):
		push_error("AudioManager: Sound '" + sound_name + "' not found!")
		return

	var player = AudioStreamPlayer.new()

	player.stream = sounds[sound_name]
	player.pitch_scale = randf_range(0.9,1.1)
	player.volume_linear = sfx_volume
	
	
	add_child(player)
	player.play()
	
	player.finished.connect(player.queue_free)
