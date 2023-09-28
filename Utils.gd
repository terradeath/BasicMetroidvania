extends Node

func _instantiate_scene_on_world(scene : PackedScene, position : Vector2):
	var instance = scene.instantiate()
	MainInstances.world.add_child.call_deferred(instance)
	instance.global_position = position
	return instance
