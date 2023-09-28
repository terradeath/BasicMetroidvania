extends "res://effects/effect.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	Sound.play("jump", randf_range(0.8, 1.1), -5.0)
