extends Level

@onready var bricks = $Bricks
@onready var trigger = $Trigger
@onready var brick_2 = $Bricks/Brick2
@onready var brick_3 = $Bricks/Brick3
@onready var save_station = $SaveStation

func _ready():
	bricks.hide()
	#await Music.fade()
	#Music.play(Music.main_theme)

func _on_trigger_trigger_entered():
	var level = MainInstances.level
	
	Events.boss_triggered.emit(level.name)
	
	var freed = WorldStash.retrieve(level.name+"_boss", "freed")
	if not freed:
		bricks.show()
		trigger.is_active = false

func _on_boss_enemy_tree_exited():
	brick_2.queue_free()
	brick_3.queue_free()
	save_station.show()
