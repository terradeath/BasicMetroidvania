extends ColorRect

var show_settings = false:
	set(value):
		show_settings = value
		visible = show_settings

func _ready():
	Music.play(Music.main_theme)

func _on_main_menu_button_pressed():
	Sound.play("click", 1.0, -10.0)
	show_settings = false

func _on_full_screen_toggle_toggled(button_pressed):
	var window = get_window()
	if button_pressed:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
