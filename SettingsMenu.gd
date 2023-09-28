extends ColorRect

func _ready():
	Music.play(Music.main_theme)

func _on_main_menu_button_pressed():
	Sound.play("click", 1.0, -10.0)
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")

func _on_full_screen_toggle_toggled(button_pressed):
	var window = get_window()
	if button_pressed:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
