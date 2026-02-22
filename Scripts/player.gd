extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

#Speed of the player
const SPEED = 130.0 

#Track pressed states
var left_pressed := false
var right_pressed := false
var up_pressed := false
var down_pressed := false

#Track last pressed direction
enum Direction { NONE, LEFT, RIGHT, UP, DOWN }
var last_direction := Direction.NONE


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_movement(delta) #The movement script is not final might change
	
func _physics_process(delta: float) -> void:
	move_and_slide()


func _input(event: InputEvent) -> void:
	
	# Track key presses 
	if event.is_action_pressed("ui_left"):
		left_pressed = true
		last_direction = Direction.LEFT
	elif event.is_action_pressed("ui_right"):
		right_pressed = true
		last_direction = Direction.RIGHT
	elif event.is_action_pressed("ui_up"):
		up_pressed = true
		last_direction = Direction.UP
	elif event.is_action_pressed("ui_down"):
		down_pressed = true
		last_direction = Direction.DOWN
	
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
	elif left_pressed:
		last_direction = Direction.LEFT
	elif up_pressed:
		last_direction = Direction.UP
	elif down_pressed:
		last_direction = Direction.DOWN
func _movement(delta):
	velocity = Vector2.ZERO
	
	#check if any of the keys are pressed before moving
	if not (left_pressed or right_pressed or up_pressed or down_pressed):
		match last_direction:
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
