extends Node2D

const EnemyPlantBullet = preload("res://enemies/enemy_plant_bullet.tscn")
const EnemyDeathEffectScene = preload("res://effects/enemy_death_effect.tscn")

@export var bullet_speed = 30
@export var spread = 30

@onready var stats = $Stats
@onready var bullet_spawn_point = $BulletSpawnPoint
@onready var fire_direction = $FireDirection

func fire_bullet():
	var bullet = Utils._instantiate_scene_on_world(EnemyPlantBullet, bullet_spawn_point.global_position) as Projectile
	var direction = global_position.direction_to(fire_direction.global_position)
	var velocity = direction.normalized() * bullet_speed
	velocity = velocity.rotated(randf_range(deg_to_rad(-spread/2.0), deg_to_rad(spread/2.0)))
	bullet.velocity = velocity

func _on_hurt_box_hurt(_hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	Utils._instantiate_scene_on_world(EnemyDeathEffectScene, bullet_spawn_point.global_position)
	queue_free()
