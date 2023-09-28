extends ColorRect
@onready var tips = $CenterContainer/VBoxContainer/Tips

var tips_array = [
	"The boss is quite weak to parkour..",
	"Just shoot them better maybe?",
	"Anyone know a good pixel art editor?",
	"If you're mad at the amount of plants, I almost made them heat seeking.",
	"There may or may not be a god mode cheatcode. Who knows?",
	"Yeah there's only one good tip in here... Have you seen my level design? Suffer.",
	"The crawling enemies can spin through the floor... Quit bothering the introverts."
]

func _ready():
	tips.text += tips_array.pick_random()

func _on_start_over_button_pressed():
	Sound.play("click", 1.0, -10.0)
	WorldStash.data = {}
	PlayerStats.reset_stats()
	get_tree().change_scene_to_file("res://world.tscn")

func _on_load_button_pressed():
	Sound.play("click", 1.0, -10.0)
	SaveManager.is_loading = true
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_pressed():
	get_tree().quit(0)
