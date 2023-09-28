class_name Projectile
extends Node2D

const ExplosionEffectScene = preload("res://effects/explosion_effect.tscn")

@export var speed = 250

@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D

var velocity = Vector2.ZERO

func _ready():
	Events.level_changed.connect(changing_levels)

func update_velocity():
	velocity.x = speed
	velocity = velocity.rotated(rotation) # Possibly rotation_degrees

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func changing_levels():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_hit_box_body_entered(_body):
	if visible_on_screen_notifier_2d.is_on_screen():
		Utils._instantiate_scene_on_world(ExplosionEffectScene, global_position)
	queue_free()

func _on_hit_box_area_entered(_area):
	if visible_on_screen_notifier_2d.is_on_screen():
		Utils._instantiate_scene_on_world(ExplosionEffectScene, global_position)
	queue_free()
