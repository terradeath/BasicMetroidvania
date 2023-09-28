extends Node2D

const BulletScene = preload("res://player/bullet.tscn") as PackedScene
const MissileScene = preload("res://player/missile.tscn") as PackedScene

@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle

func _process(_delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()

func fire_bullet():
	var bullet = Utils._instantiate_scene_on_world(BulletScene, muzzle.global_position) as Projectile
	bullet.rotation = blaster_sprite.rotation
	bullet.update_velocity()

func fire_missile():
	var missile = Utils._instantiate_scene_on_world(MissileScene, muzzle.global_position) as Projectile
	missile.rotation = blaster_sprite.rotation
	missile.update_velocity()
