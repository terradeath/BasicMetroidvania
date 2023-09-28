extends Projectile

func _ready():
	super()
	Sound.play("explosion")

func _on_hit_box_body_entered(body):
	super(body)
	if body is Brick: body.queue_free()
