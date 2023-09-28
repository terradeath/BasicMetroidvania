extends Level

@onready var hidden_by_trigger = $Powerups/HiddenByTrigger

func _ready():
	hidden_by_trigger.hide()

func _on_trigger_trigger_entered():
	hidden_by_trigger.show()
