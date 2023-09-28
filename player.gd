class_name Player
extends CharacterBody2D

const DustEffectScene = preload("res://effects/dust_effect.tscn")
const JumpEffectScene = preload("res://effects/jump_effect.tscn")
const WallJumpEffectScene = preload("res://effects/wall_jump_effect.tscn")

@export var acceleration = 512
@export var max_velocity = 64
@export var friction = 256
@export var air_friction = 64
@export var gravity = 200
@export var jump_force = 128
@export var max_fall_speed = 140
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128

var air_jump = false
var state = move_state

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var player_blaster = $PlayerBlaster
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var camera_2d = $Camera2D
@onready var hurt_box = $HurtBox
@onready var blinking_animation_player = $BlinkingAnimationPlayer
@onready var center = $Center

func _ready():
	PlayerStats.no_health.connect(player_death)
	Events.camera_limits_changed.connect(update_limits)

func _enter_tree():
	MainInstances.player = self

func update_limits(left, right, top, bottom):
	camera_2d.limit_left = left
	camera_2d.limit_right = right
	camera_2d.limit_top = top
	camera_2d.limit_bottom = bottom

func _exit_tree():
	MainInstances.player = null

func _physics_process(delta):
	state.call(delta)
	
	if Input.is_action_pressed("Fire") and fire_rate_timer.time_left == 0:
		fire_rate_timer.start()
		player_blaster.fire_bullet()
	
	if (Input.is_action_pressed("FireMissile") 
	and fire_rate_timer.time_left == 0
	and PlayerStats.missiles > 0):
		fire_rate_timer.start()
		player_blaster.fire_missile()
		PlayerStats.missiles -= 1
	
	if Input.is_action_just_pressed("god_mode"):
		hurt_box.toggle_invincibility()

func move_state(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("Left", "Right")
	
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
	
	jump_check()
	
	if Input.is_action_just_pressed("Crouch") and not is_on_wall():
		set_collision_mask_value(2, false)
		drop_timer.start()
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_left_edge = was_on_floor and not is_on_floor()
	if just_left_edge:
		coyote_jump_timer.start()
	wall_check()

func wall_slide_state(delta):
	var wall_normal = get_wall_normal()
	animation_player.play("wall_slide")
	sprite_2d.scale.x = sign(wall_normal.x)
	velocity.y = clampf(velocity.y, -max_wall_slide_speed/2.0, max_wall_slide_speed)
	
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta, sign(wall_normal.x))

func wall_check():
	if not is_on_floor() and is_on_wall():
		state = wall_slide_state
		create_dust_effect()
		air_jump = true

func wall_detach(delta, wall_axis):
	if Input.is_action_just_pressed("Right") and wall_axis == 1:
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed("Left") and wall_axis == -1:
		velocity.x = -acceleration * delta
		state = move_state
	if not is_on_wall() or is_on_floor():
		state = move_state

func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("Jump"):
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * 0.75, false)
		var wall_jump_effect_position = global_position + Vector2(wall_axis * 3, -2)
		var wall_jump_effect = Utils._instantiate_scene_on_world(WallJumpEffectScene, wall_jump_effect_position)
		wall_jump_effect.scale.x = wall_axis

func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("Crouch"):
		slide_speed = max_wall_slide_speed
		Utils._instantiate_scene_on_world(DustEffectScene, global_position)
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)

func is_moving(input_axis):
	return input_axis != 0

func create_dust_effect():
	Sound.play("step", randf_range(.8, 1.1), -5.0)
	Utils._instantiate_scene_on_world(DustEffectScene, global_position)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

func apply_acceleration(delta, input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func jump_check():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump"):
			jump(jump_force)
	if not is_on_floor():
		if Input.is_action_just_released("Jump") and velocity.y < -jump_force / 2.0:
			velocity.y = -jump_force/2.0
		
		if Input.is_action_just_pressed("Jump") and air_jump:
			jump(jump_force *0.75)
			air_jump = false

func jump(force, create_effect = true):
	velocity.y = -force
	if create_effect:
		Utils._instantiate_scene_on_world(JumpEffectScene, global_position)

func update_animations(input_axis):
	sprite_2d.scale.x = sign(get_local_mouse_position().x)
	if round(sprite_2d.scale.x) == 0: sprite_2d.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("Run")
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play("Idle")
	
	if not is_on_floor():
		animation_player.play("Jump")

func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)

func _on_hurt_box_hurt(_hitbox, damage):
	Events.add_screenshake.emit(3, .2)
	PlayerStats.health -= damage
	Sound.play("hurt")
	blinking_animation_player.play("blink")

func player_death():
	camera_2d.reparent(get_tree().current_scene)
	Events.player_died.emit()
	queue_free()
