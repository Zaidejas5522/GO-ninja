extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

# Speed of the player
const SPEED = 130.0 

# Track pressed states
var left_pressed := false
var right_pressed := false
var up_pressed := false
var down_pressed := false

var attacking = false
var attacktime = 0.2 # how long the attack lasts

# Track last pressed direction
enum Direction { NONE, LEFT, RIGHT, UP, DOWN }
var last_direction := Direction.NONE
var facing_direction := Direction.DOWN

# Breadcrumbs for enemies
var breadcrumbs: Array[Vector2] = []
const BREADCRUMB_SPACING := 1

func _ready() -> void:
	facing_direction = Direction.DOWN
	print("I am:", self)
	print("My class is:", get_class())

func _process(delta: float) -> void:
	if Global.PlayerHealth <= 0:
		print("gameover")

	if Input.is_action_just_pressed("Attack") and not attacking:
		start_attack()
	
	if attacking:
		# When attacking, don't move
		velocity = Vector2.ZERO
		match facing_direction:
			Direction.LEFT:
				attack_hitbox.rotation = deg_to_rad(0)
				sprite.play("AttackWest")
			Direction.RIGHT:
				attack_hitbox.rotation = deg_to_rad(180)
				sprite.play("AttackEast")
			Direction.UP:
				attack_hitbox.rotation = deg_to_rad(90)
				sprite.play("AttackNorth")
			Direction.DOWN:
				attack_hitbox.rotation = deg_to_rad(270)
				sprite.play("AttackSouth")
			Direction.NONE:
				attack_hitbox.rotation = deg_to_rad(270)
				sprite.play("AttackSouth")
	else:
		_movement(delta)

func start_attack():
	attacking = true
	await get_tree().create_timer(attacktime).timeout
	attacking = false

	# Play idle animation after attack if no keys pressed
	if not (left_pressed or right_pressed or up_pressed or down_pressed):
		match facing_direction:
			Direction.LEFT:
				sprite.play("IdleEast")
			Direction.RIGHT:
				sprite.play("IdleWest")
			Direction.UP:
				sprite.play("IdleNorth")
			Direction.DOWN:
				sprite.play("IdleSouth")
			Direction.NONE:
				sprite.play("IdleSouth")

func _physics_process(delta: float) -> void:
	# Move player
	move_and_slide()

	# Leave breadcrumb
	if breadcrumbs.is_empty() or global_position.distance_to(breadcrumbs[-1]) > BREADCRUMB_SPACING:
		breadcrumbs.append(global_position)

	# Limit breadcrumbs to last 50 positions
	if breadcrumbs.size() > 50:
		breadcrumbs.pop_front()

func _input(event: InputEvent) -> void:
	# Track key presses
	if event.is_action_pressed("ui_left"):
		left_pressed = true
		last_direction = Direction.LEFT
		facing_direction = Direction.LEFT
	elif event.is_action_pressed("ui_right"):
		right_pressed = true
		last_direction = Direction.RIGHT
		facing_direction = Direction.RIGHT
	elif event.is_action_pressed("ui_up"):
		up_pressed = true
		last_direction = Direction.UP
		facing_direction = Direction.UP
	elif event.is_action_pressed("ui_down"):
		down_pressed = true
		last_direction = Direction.DOWN
		facing_direction = Direction.DOWN

	# Track key releases
	if event.is_action_released("ui_left"):
		left_pressed = false
		_update_last_direction()
	elif event.is_action_released("ui_right"):
		right_pressed = false
		_update_last_direction()
	elif event.is_action_released("ui_up"):
		up_pressed = false
		_update_last_direction()
	elif event.is_action_released("ui_down"):
		down_pressed = false
		_update_last_direction()

func _update_last_direction():
	if right_pressed:
		last_direction = Direction.RIGHT
		facing_direction = Direction.RIGHT
	elif left_pressed:
		last_direction = Direction.LEFT
		facing_direction = Direction.LEFT
	elif up_pressed:
		last_direction = Direction.UP
		facing_direction = Direction.UP
	elif down_pressed:
		last_direction = Direction.DOWN
		facing_direction = Direction.DOWN
	else:
		last_direction = Direction.NONE

func _movement(delta):
	velocity = Vector2.ZERO

	if not (left_pressed or right_pressed or up_pressed or down_pressed):
		match facing_direction:
			Direction.LEFT:
				sprite.play("IdleEast")
			Direction.RIGHT:
				sprite.play("IdleWest")
			Direction.UP:
				sprite.play("IdleNorth")
			Direction.DOWN:
				sprite.play("IdleSouth")
		last_direction = Direction.NONE
		return

	# Actual movement
	match last_direction:
		Direction.LEFT:
			sprite.play("WalkEast")
			velocity.x = -SPEED
		Direction.RIGHT:
			sprite.play("WalkWest")
			velocity.x = SPEED
		Direction.UP:
			sprite.play("WalkNorth")
			velocity.y = -SPEED
		Direction.DOWN:
			sprite.play("WalkSouth")
			velocity.y = SPEED
