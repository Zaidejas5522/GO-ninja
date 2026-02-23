extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

#Speed of the player
const SPEED = 130.0 

#Track pressed states
var left_pressed := false
var right_pressed := false
var up_pressed := false
var down_pressed := false

var attacking = 0
var attacktime= 0.2 #how much the attack should last

#Track last pressed direction
enum Direction { NONE, LEFT, RIGHT, UP, DOWN }
var last_direction := Direction.NONE # Last pressed direction for movement
var facing_direction := Direction.NONE  # Direction the player is facing for idle/attack


func _ready() -> void:
	facing_direction = Direction.DOWN

func _process(delta: float) -> void:
	if Global.PlayerHealth <= 0:
		print("gameover")
	if Input.is_action_just_pressed("Attack") and not attacking:
		start_attack()
	
	if attacking:
		# When attacking, don't move and play attack animation
		velocity = Vector2.ZERO
		match facing_direction:
			Direction.LEFT:
				attack_hitbox.rotation=deg_to_rad(0) #rotating the attack hitbox depending on direction
				sprite.play("AttackWest")
			Direction.RIGHT:
				attack_hitbox.rotation=deg_to_rad(180)
				sprite.play("AttackEast")
			Direction.UP:
				attack_hitbox.rotation=deg_to_rad(90)
				sprite.play("AttackNorth")
			Direction.DOWN:
				attack_hitbox.rotation=deg_to_rad(270)
				sprite.play("AttackSouth")
			Direction.NONE:
				attack_hitbox.rotation=deg_to_rad(270)
				sprite.play("AttackSouth") # default if no direction
	else:
		_movement(delta)

func start_attack():
	attacking = true
	await get_tree().create_timer(attacktime).timeout # attack timer, can modify
	attacking = false
	# After attack finishes, play the appropriate idle animation
	if not (left_pressed or right_pressed or up_pressed or down_pressed):
		match facing_direction:
			Direction.LEFT:
				sprite.play("IdleWest")
			Direction.RIGHT:
				sprite.play("IdleEast")
			Direction.UP:
				sprite.play("IdleNorth")
			Direction.DOWN:
				sprite.play("IdleSouth")
			Direction.NONE:
				sprite.play("IdleSouth")
	
func _physics_process(delta: float) -> void:
	move_and_slide()


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
	# Check pressed keys in priority order
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
		
func _movement(delta):
	velocity = Vector2.ZERO
	
	#check if any of the keys are pressed before moving
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
	

	#actual movement
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
