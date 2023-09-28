class_name Door
extends Area2D

@export_file("*.tscn") var new_level_path
@export var connection : DoorConnection

var active = false

@onready var right_cast = $RightCast
@onready var left_cast = $LeftCast

func get_direction():
	if left_cast.is_colliding():
		return -1
	if right_cast.is_colliding():
		return 1
	else:
		return 0

func _physics_process(_delta):
	var player = MainInstances.player as Player
	if not player is Player: return
	if not active: return
	if overlaps_body(player) and new_level_path:
		var player_direction = sign(player.velocity.x)
		var direction = get_direction()
		
		if player_direction == direction:
			Events.door_entered.emit(self)

func _on_timer_timeout():
	active = true
