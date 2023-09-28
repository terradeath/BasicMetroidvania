extends CharacterBody2D

const EnemyDeathEffectScene = preload("res://effects/enemy_death_effect.tscn")

@export var acceleration = 100
@export var max_speed = 40

var spawned_in = false
var deleted = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var stats = $Stats
@onready var waypoint_pathfinding = $WaypointPathfinding
@onready var visible_on_screen_enabler_2d = $VisibleOnScreenEnabler2D

func _ready():
	spawned_in = true

func _physics_process(delta):
	var player = MainInstances.player
	if player is CharacterBody2D:
		move_toward_position(waypoint_pathfinding.pathfinding_next_position, delta)
		if spawned_in and not deleted: 
			visible_on_screen_enabler_2d.queue_free()
			deleted = true

func move_toward_position(target_position, delta):
	var direction = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	animated_sprite_2d.flip_h = global_position < target_position
	move_and_slide()

func _on_hurt_box_hurt(_hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	Utils._instantiate_scene_on_world(EnemyDeathEffectScene, global_position)
	queue_free()
