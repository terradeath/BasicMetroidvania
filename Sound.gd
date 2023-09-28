extends Node

var sounds_path = "res://music_and_sounds/"

@onready var sound_players = get_children()

func play(sound_string, pitch_scale = 1.0, volume_db = 0.0):
	for sound_player in sound_players:
		if not sound_player.playing:
			sound_player.pitch_scale = pitch_scale
			sound_player.volume_db = volume_db
			sound_player.stream = load(sounds_path+sound_string+".wav")
			sound_player.play()
			return
	
	print("Too many sounds playing at once!")
