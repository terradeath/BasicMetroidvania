class_name Powerup
extends Area2D

func _ready():
	var id = WorldStash.get_id(self)
	var freed = WorldStash.retrieve(id, "freed")
	if freed: queue_free()

func pickup():
	WorldStash.stash(WorldStash.get_id(self), "freed", true)
	Sound.play("powerup")
	queue_free()

func _on_body_entered(_body):
	pickup()
