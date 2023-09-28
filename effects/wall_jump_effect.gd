extends "res://effects/effect.gd"


func _ready():
	super()
	Sound.play("jump", randf_range(0.8, 1.1), -5.0)
