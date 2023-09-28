extends Projectile

@onready var stats = $Stats

func _on_hurtbox_hurt(_hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	queue_free()
