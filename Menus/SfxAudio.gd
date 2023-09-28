extends "res://Menus/Audio Slider.gd"


func _on_value_changed(value: float):
	super(value)
	Sound.play("explosion")
