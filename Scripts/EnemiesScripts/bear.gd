extends CharacterBody2D

var speed := 60

var stop_distance := 15.0

var player_reference: Node = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

var health = 90

var current_axis := ""
var target_breadcrumb: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT

var player_visible := false

var has_seen_player := false
var last_known_breadcrumb: Vector2 = Vector2.ZERO

# KNOCKBACK
var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0


func _ready():
	player_reference = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if not player_reference:
		return

	
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		return

	_update_vision()

	if not has_seen_player:
		_idle()
		return

	if player_visible:
		_follow_breadcrumbs()
	else:
		_follow_last_seen()


func take_damage(damage:int):
	health -= damage
	$AudioStreamPlayer2D.play()

	
	var recoil_strength = 180
	knockback_velocity = -facing_direction * recoil_strength
	knockback_timer = 0.15

	if health <= 0:
		die()


func die():
	const MONEY_SCENE = preload("res://Scenes/PlayerStuff/Money.tscn")
	const CONSUMABLE_SCENE = preload("res://Scenes/PlayerStuff/Consumable.tscn")

	var rare_chance = 0.1

	var drop_scene = MONEY_SCENE
	if randf() < rare_chance:
		drop_scene = CONSUMABLE_SCENE

	var drop = drop_scene.instantiate()
	drop.global_position = global_position
	get_parent().add_child(drop)

	queue_free()


# LINE OF SIGHT
func _update_vision():
	ray_cast.target_position = to_local(player_reference.global_position)
	ray_cast.force_raycast_update()

	var seen_now = (ray_cast.get_collider() == player_reference)

	if seen_now:
		has_seen_player = true

	player_visible = seen_now and has_seen_player

	if player_visible and player_reference.breadcrumbs.size() > 0:
		last_known_breadcrumb = player_reference.breadcrumbs[-1]


# FOLLOW BREADCRUMBS
func _follow_breadcrumbs():

	if player_reference.breadcrumbs.size() == 0:
		return

	target_breadcrumb = player_reference.breadcrumbs[-1]

	var delta_pos = target_breadcrumb - global_position
	var distance = delta_pos.length()

	if distance <= stop_distance:
		velocity = Vector2.ZERO
		animated_sprite.stop()

		if distance < 5:
			global_position = target_breadcrumb
			player_reference.breadcrumbs.pop_front()

		return

	var direction = Vector2.ZERO

	if current_axis == "":
		current_axis = "x" if abs(delta_pos.x) > abs(delta_pos.y) else "y"

	if current_axis == "x":
		direction.x = sign(delta_pos.x)
		facing_direction = Vector2(direction.x, 0)

		if abs(delta_pos.x) < 2:
			current_axis = "y"

	elif current_axis == "y":
		direction.y = sign(delta_pos.y)
		facing_direction = Vector2(0, direction.y)

		if abs(delta_pos.y) < 2:
			current_axis = "x"

	_update_animation(direction)

	velocity = direction * speed
	move_and_slide()


# FOLLOW LAST SEEN
func _follow_last_seen():

	var delta_pos = last_known_breadcrumb - global_position
	var distance = delta_pos.length()

	if distance <= 5:
		velocity = Vector2.ZERO
		animated_sprite.stop()
		return

	var direction = delta_pos.normalized()

	facing_direction = direction
	current_axis = ""

	_update_animation(direction)

	velocity = direction * speed
	move_and_slide()


# IDLE
func _idle():
	velocity = Vector2.ZERO
	animated_sprite.stop()
	move_and_slide()


# ANIMATION
func _update_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			if animated_sprite.animation != "WalkingRight":
				animated_sprite.play("WalkingRight")
		else:
			if animated_sprite.animation != "WalkingLeft":
				animated_sprite.play("WalkingLeft")
	else:
		if direction.y > 0:
			if animated_sprite.animation != "WalkingDown":
				animated_sprite.play("WalkingDown")
		else:
			if animated_sprite.animation != "WalkingUp":
				animated_sprite.play("WalkingUp")
