extends Node


const TEST_PATH = "res://save.txt"
const PROD_PATH = "user://metroidvania_save.save"

var master_index = AudioServer.get_bus_index("Master")
var music_index = AudioServer.get_bus_index("Music")
var sfx_index = AudioServer.get_bus_index("Sfx")

var save_path = TEST_PATH
var is_loading = false

func save_game():
	WorldStash.stash("level", "file_path", MainInstances.level.scene_file_path)
	var player: Player = MainInstances.player
	WorldStash.stash("player", "x", player.global_position.x)
	WorldStash.stash("player", "y", player.global_position.y)
	
	PlayerStats.stash_stats()
	
	#settings
	WorldStash.stash("settings", "master_audio", AudioServer.get_bus_volume_db(master_index))
	WorldStash.stash("settings", "music_audio", AudioServer.get_bus_volume_db(music_index))
	WorldStash.stash("settings", "sfx_audio", AudioServer.get_bus_volume_db(sfx_index))
	WorldStash.stash("settings", "fullscreen", get_window().mode)
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var data_string = JSON.stringify(WorldStash.data)
	
	save_file.store_string(data_string)
	save_file.close()
	
func load_game():
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	
	if not save_file is FileAccess: return null
	
	var data = JSON.parse_string(save_file.get_line())
	WorldStash.data = data
	
	var file_path = WorldStash.retrieve("level", "file_path")
	var player_x = WorldStash.retrieve("player", "x")
	var player_y = WorldStash.retrieve("player", "y")
	var player: Player = MainInstances.player
	MainInstances.world.load_level(file_path)
	player.global_position = Vector2(player_x, player_y)
	
	PlayerStats.retrieve_stats()
	
	AudioServer.set_bus_volume_db(master_index, WorldStash.retrieve("settings", "master_audio"))
	AudioServer.set_bus_volume_db(music_index, WorldStash.retrieve("settings", "music_audio"))
	AudioServer.set_bus_volume_db(sfx_index, WorldStash.retrieve("settings", "sfx_audio"))
	var window = get_window()
	window.mode = WorldStash.retrieve("settings", "fullscreen")
	
	save_file.close()
