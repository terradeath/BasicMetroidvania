extends Node2D

const EnemyDeathEffectScene = preload("res://effects/enemy_death_effect.tscn")

enum DIRECTION { LEFT = -1, RIGHT = 1}

@export var crawling_direction = DIRECTION.RIGHT
@export var max_speed = 150
@export var spin_speed = 600
@export var gravity = 200

var state = crawling_state

@onready var floor_cast = $FloorCast
@onready var wall_cast = $WallCast
@onready var stats = $Stats
@onready var death_effect_spawn = $DeathEffectSpawn
@onready var sprite_2d = $Sprite2D

func _ready():
	wall_cast.target_position.x *= crawling_direction

func _physics_process(delta):
	state.call(delta)

func crawling_state(delta):
	sprite_2d.play("crawl")
	if wall_cast.is_colliding():
		global_position = wall_cast.get_collision_point()
		var wall_normal = wall_cast.get_collision_normal()
		rotation = wall_normal.rotated(deg_to_rad(90.0)).angle()
	else:
		floor_cast.rotation_degrees = -max_speed * crawling_direction * delta
		var while_limit = 30
		while not floor_cast.is_colliding():
			rotation_degrees += crawling_direction
			floor_cast.force_raycast_update()
			while_limit -= 1
			if while_limit <= 0:
				state = falling_state
				break
		if floor_cast.is_colliding():
			global_position = floor_cast.get_collision_point()
			var floor_normal = floor_cast.get_collision_normal()
			rotation = floor_normal.rotated(deg_to_rad(90.0)).angle()

func falling_state(delta):
	sprite_2d.play("fall")
	rotation_degrees += crawling_direction * spin_speed * delta
	position.y += gravity * delta
	if floor_cast.is_colliding() or wall_cast.is_colliding():
		state = crawling_state

func _on_hurt_box_hurt(_hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	Utils._instantiate_scene_on_world(EnemyDeathEffectScene, death_effect_spawn.global_position)
	queue_free()
