extends Camera2D

var shake = 0

@onready var screenshake_timer = $ScreenshakeTimer

func _ready():
	Events.add_screenshake.connect(start_screenshake)

func _process(_delta):
	offset.x = randf_range(-shake, shake)
	offset.y = randf_range(-shake, shake)

func start_screenshake(amount, duration):
	shake = amount
	screenshake_timer.wait_time = duration
	screenshake_timer.start()

func _on_screenshake_timer_timeout():
	shake = 0
