extends Node2D

# Enemy movement speed
var speed := 50

# Minimum distance before stopping
var stop_distance := 15.0

var player_reference: Node = null
<<<<<<< Updated upstream
var animated_sprite: AnimatedSprite2D = null
=======

#var animated_sprite: AnimatedSprite2D = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var mob_health_bar: ProgressBar = $mob_health_bar

var health = 50




>>>>>>> Stashed changes

var current_axis := "" 

var target_breadcrumb: Vector2 = Vector2.ZERO
var player

func _ready():
<<<<<<< Updated upstream
	player_reference = get_node("res://Scenes/Player.tscn")
	animated_sprite = get_node("/root/MainScene/Enemies/Bear/AnimatedSprite2D")
=======
	player_reference=get_tree().get_first_node_in_group("player")
	mob_health_bar.set_mob_health_bar(health)

func take_damage(damage:int):
	health -= damage
	if health <= 0:
		queue_free()

>>>>>>> Stashed changes



func _physics_process(delta: float) -> void:
	if not player_reference:
		return

	if player_reference.breadcrumbs.size() == 0:
		return

	target_breadcrumb = player_reference.breadcrumbs[-1]

	var delta_pos = target_breadcrumb - global_position
	var distance = delta_pos.length()

	# Only move if not close enough
	if distance > stop_distance:

		var direction = Vector2.ZERO

		if current_axis == "":
			if abs(delta_pos.x) > abs(delta_pos.y):
				current_axis = "x"
			else:
				current_axis = "y"

		if current_axis == "x":
			direction.x = sign(delta_pos.x)

			if abs(delta_pos.x) < 2:
				current_axis = "y"

			if direction.x > 0:
				if animated_sprite.animation != "WalkingRight":
					animated_sprite.play("WalkingRight")
			else:
				if animated_sprite.animation != "WalkingLeft":
					animated_sprite.play("WalkingLeft")

		elif current_axis == "y":
			direction.y = sign(delta_pos.y)

			if abs(delta_pos.y) < 2:
				current_axis = "x"

			if direction.y > 0:
				if animated_sprite.animation != "WalkingDown":
					animated_sprite.play("WalkingDown")
			else:
				if animated_sprite.animation != "WalkingUp":
					animated_sprite.play("WalkingUp")

		global_position += direction * speed * delta

	else:
		animated_sprite.stop()
		current_axis = ""

		if distance < 5:
			global_position = target_breadcrumb

		player_reference.breadcrumbs.pop_front()
