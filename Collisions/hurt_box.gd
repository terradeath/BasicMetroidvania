class_name Hurtbox
extends Area2D

var is_invincible = false:
	set(value):
		is_invincible = value
		disable.call_deferred(value)

signal hurt(hitbox, damage)

func take_hit(hitbox, damage):
	if is_invincible: return
	hurt.emit(hitbox, damage)

func toggle_invincibility():
	is_invincible = !is_invincible

func disable(value: bool):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = value
