extends ColorRect

@onready var in_game_settings = $InGameSettings
@onready var pause_menu = $PauseMenu

var paused = false:
	set(value):
		paused = value
		get_tree().paused = paused
		visible = paused
		pause_menu.visible = paused
		if paused:
			Sound.play("pause", 1.0, -10.0)
		else:
			Sound.play("unpause", 1.0, -10.0)


func _process(_delta):
	if not MainInstances.player is Player: return
	if Input.is_action_just_pressed("Pause"):
		paused = !paused
		
	if in_game_settings.show_settings != false:
		pause_menu.visible = false
	else:
		pause_menu.visible = true

func _on_resume_pressed():
	paused = false
	Sound.play("click", 1.0, -10.0)

func _on_quit_pressed():
	get_tree().quit(0)

func _on_quit_to_menu_pressed():
	paused = false
	WorldStash.data = {}
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")

func _on_load_game_pressed():
	Sound.play("click", 1.0, -10.0)
	SaveManager.is_loading = true
	paused = false
	get_tree().change_scene_to_file("res://world.tscn")


func _on_settings_button_pressed():
	Sound.play("click", 1.0, -10.0)
	in_game_settings.show_settings = true
	
