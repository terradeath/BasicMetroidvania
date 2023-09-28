extends Projectile

func _ready():
	super()
	Sound.play("bullet", randf_range(0.6, 1.2))
	set_process(false)
