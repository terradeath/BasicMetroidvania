extends Control

@onready var empty = $Empty
@onready var full = $Full

# Called when the node enters the scene tree for the first time.
func _ready():
	update_max_health_ui()
	update_health_ui()
	PlayerStats.health_changed.connect(update_health_ui)
	PlayerStats.max_health_changed.connect(update_max_health_ui)

func update_health_ui():
	full.size.x = PlayerStats.health * 5 + 1

func update_max_health_ui():
	empty.size.x = PlayerStats.max_health * 5 + 1
