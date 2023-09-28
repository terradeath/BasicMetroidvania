extends StaticBody2D

@onready var animation_player = $AnimationPlayer

func _on_area_2d_body_entered(_player):
	PlayerStats.refill()
	Sound.play("powerup", .6, -10)
	SaveManager.save_game()
	animation_player.play("save")
