extends Node2D

@export var acceleration = 200
@export var max_speed = 800
@export var targets : Array[NodePath]
@export var missile_spawn: Marker2D

const EnemyDeathEffectScene = preload("res://effects/enemy_death_effect.tscn")
const StingerScene = preload("res://enemies/stinger.tscn")
const MissilePowerupScene = preload("res://Powerups/missile_powerup.tscn")

var velocity = Vector2.ZERO
var state = recenter_state : set = set_state
var state_init = true : get = get_state_init

var STATE_OPTIONS = [fire_random_state, fire_circle_state, fire_circle_state, rush_state, rush_state]
var state_options_left = []

@onready var stats = $Stats
@onready var death_effect_spawn = $Body/DeathEffectSpawn
@onready var stinger_pivot = $Body/StingerPivot
@onready var stinger_muzzle = $Body/StingerPivot/StingerMuzzle
@onready var stinger_timer = $StingerTimer
@onready var animation_player = $AnimationPlayer
@onready var state_timer = $StateTimer

func set_state(value):
	state = value
	state_init = true

func get_state_init():
	var was = state_init
	state_init = false
	return was

func rush_state(delta):
	if state_init:
		state_timer.start(randf_range(4, 6))
		state_timer.timeout.connect(set_state.bind(decelerate_state), CONNECT_ONE_SHOT)
	
	var player = MainInstances.player
	if not player is Player: return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction * max_speed , acceleration * delta)
	move(delta)

func fire_circle_state(_delta):
	if state_init:
		state_timer.start(randf_range(3, 6))
		state_timer.timeout.connect(set_state.bind(recenter_state), CONNECT_ONE_SHOT)
	
	if stinger_timer.time_left == 0:
		stinger_pivot.rotation_degrees += 17
		
		stinger_timer.start()
		var stinger = Utils._instantiate_scene_on_world(StingerScene, stinger_muzzle.global_position)
		stinger.rotation = stinger_pivot.rotation
		stinger.update_velocity()

func fire_random_state(_delta):
	if state_init:
		state_timer.start(randf_range(3, 6))
		state_timer.timeout.connect(set_state.bind(recenter_state), CONNECT_ONE_SHOT)
	
	if stinger_timer.time_left == 0:
		stinger_pivot.rotation_degrees += rad_to_deg(randi_range(1, 20))
		
		stinger_timer.start()
		var stinger = Utils._instantiate_scene_on_world(StingerScene, stinger_muzzle.global_position)
		stinger.rotation = stinger_pivot.rotation
		stinger.update_velocity()

func recenter_state(_delta):
	assert(not targets.is_empty())
	
	if state_init:
		var center_node = get_node(targets.pick_random())
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "global_position", center_node.global_position, 2.0)
		await tween.finished
		
		state_timer.start(0.5)
		await state_timer.timeout
		
		if state_options_left.is_empty():
			state_options_left = STATE_OPTIONS.duplicate()
			state_options_left.shuffle()
		
		var triggered = WorldStash.retrieve(MainInstances.level.name+"_boss", "triggered")
		
		if triggered == true:
			state = state_options_left.pop_back()
		else:
			state = recenter_state

func decelerate_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move(delta)
	if velocity == Vector2.ZERO: state = recenter_state

func move(delta):
	translate(velocity * delta)

func _ready():
	animation_player.play("fly")
	Events.boss_triggered.connect(boss_triggered)
	var freed = WorldStash.retrieve(MainInstances.level.name+"_boss", "freed")
	if freed: queue_free()

func boss_triggered(level):
	if level != MainInstances.level.name: return
	
	WorldStash.stash(MainInstances.level.name+"_boss", "triggered", true)

func _process(delta):
	state.call(delta)

func _on_hurt_box_hurt(_hitbox, damage):
	if WorldStash.retrieve(MainInstances.level.name+"_boss", "triggered"):
		stats.health -= damage

func _on_stats_no_health():
	Utils._instantiate_scene_on_world(EnemyDeathEffectScene, death_effect_spawn.global_position)
	WorldStash.stash(MainInstances.level.name+"_boss", "freed", true)
	assert(missile_spawn is Marker2D)
	
	Utils._instantiate_scene_on_world(MissilePowerupScene, missile_spawn.global_position)
	
	#heal player after tough fight + increases max a little
	PlayerStats.max_health += 4
	PlayerStats.health = PlayerStats.max_health
	queue_free()
