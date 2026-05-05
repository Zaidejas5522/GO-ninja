extends CharacterBody2D

# SETTINGS
var speed := 60
var stop_distance := 20.0

var attack_range := 30
var charge_range := 300

var attack_damage := 8
var charge_damage := 12


var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0

# STATES
enum State {
	IDLE,
	WALK,
	ATTACK,
	BEFORE_CHARGE,
	CHARGE
}

var current_state = State.IDLE

# TIMERS
var attack_timer := 0.0
var attack_cooldown := 3.0

var charge_timer := 0.0
var charge_cooldown := 8.0

var hit_timer := 0.0

# REFERENCES
var player_reference: Node = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_left_area: Area2D = $AttackLeftArea
@onready var attack_right_area: Area2D = $AttackRightArea
@onready var ray_cast: RayCast2D = $RayCast2D

# OTHER
var health = 720
var current_axis := ""
var target_breadcrumb: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT
var charge_direction := Vector2.ZERO

var player_visible := false


func _ready():
	player_reference = get_tree().get_first_node_in_group("player")

	attack_left_area.monitoring = false
	attack_right_area.monitoring = false


# LOS
func _update_vision():
	ray_cast.target_position = to_local(player_reference.global_position)
	ray_cast.force_raycast_update()

	player_visible = (ray_cast.get_collider() == player_reference)


# DAMAGE
func take_damage(damage:int):
	health -= damage
	$AudioStreamPlayer2D.play()

	knockback_velocity = -facing_direction * 200
	knockback_timer = 0.15

	hit_timer = 0.7
	current_state = State.IDLE

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


func _physics_process(delta: float) -> void:
	if not player_reference:
		return

	_update_vision()
	
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
	
	# HIT LOCK
	if hit_timer > 0:
		hit_timer -= delta
		velocity = Vector2.ZERO
		animated_sprite.play("Hit")
		return

	# cooldowns
	attack_cooldown = max(attack_cooldown - delta, 0)
	charge_cooldown = max(charge_cooldown - delta, 0)

	# JEI NEMATO → TIK STOVI
	if not player_visible:
		_idle()
		return
	
	# MATO → AI
	match current_state:
		State.IDLE, State.WALK:
			handle_movement(delta)
			handle_attack_logic()

		State.ATTACK:
			update_attack(delta)

		State.BEFORE_CHARGE:
			update_before_charge(delta)

		State.CHARGE:
			update_charge(delta)


# MOVEMENT
func handle_movement(delta):

	if player_reference.breadcrumbs.size() == 0:
		return

	target_breadcrumb = player_reference.breadcrumbs[-1]

	var delta_pos = target_breadcrumb - global_position
	var distance = delta_pos.length()

	if distance > stop_distance:
		current_state = State.WALK

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

		animated_sprite.play("Walking")

		velocity = direction * speed
		move_and_slide()

	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		animated_sprite.stop()
		current_axis = ""

		if distance < 5:
			global_position = target_breadcrumb
			player_reference.breadcrumbs.pop_front()


# IDLE
func _idle():
	current_state = State.IDLE
	velocity = Vector2.ZERO
	animated_sprite.stop()
	move_and_slide()


# ATTACK LOGIC
func handle_attack_logic():
	var distance = global_position.distance_to(player_reference.global_position)

	if distance < attack_range and attack_cooldown <= 0:
		start_attack()
	elif distance < charge_range and charge_cooldown <= 0:
		if randi() % 2 == 0:
			start_charge()


# ATTACK
func start_attack():
	current_state = State.ATTACK
	attack_timer = 0.6

	velocity = Vector2.ZERO

	attack_left_area.monitoring = false
	attack_right_area.monitoring = false

	if facing_direction.x < 0:
		animated_sprite.play("AttackRight")
		attack_left_area.monitoring = true
	else:
		animated_sprite.play("AttackLeft")
		attack_right_area.monitoring = true


func update_attack(delta):
	attack_timer -= delta

	if attack_timer < 0.3 and attack_timer > 0.3 - delta:
		if facing_direction.x < 0:
			for body in attack_left_area.get_overlapping_bodies():
				if body.is_in_group("player") and body.has_method("take_damage"):
					body.take_damage(attack_damage)
		else:
			for body in attack_right_area.get_overlapping_bodies():
				if body.is_in_group("player") and body.has_method("take_damage"):
					body.take_damage(attack_damage)

	if attack_timer <= 0:
		current_state = State.IDLE
		attack_cooldown = 1.5

		attack_left_area.monitoring = false
		attack_right_area.monitoring = false


# CHARGE
func start_charge():
	current_state = State.BEFORE_CHARGE
	charge_timer = 1.0

	velocity = Vector2.ZERO
	charge_direction = (player_reference.global_position - global_position).normalized()

	animated_sprite.play("BeforeCharge")
	$AudioStreamPlayer2D2.play()


func update_before_charge(delta):
	charge_timer -= delta
	velocity = Vector2.ZERO

	if charge_timer <= 0:
		current_state = State.CHARGE
		charge_timer = 0.6

		if charge_direction.x < 0:
			animated_sprite.play("ChargeLeft")
		else:
			animated_sprite.play("ChargeRight")


func update_charge(delta):
	charge_timer -= delta

	var dash_speed = 300
	velocity = charge_direction * dash_speed
	move_and_slide()

	if global_position.distance_to(player_reference.global_position) < 50:
		if player_reference.has_method("take_damage"):
			player_reference.take_damage(charge_damage)
			charge_timer = 0

	if charge_timer <= 0:
		velocity = Vector2.ZERO
		current_state = State.IDLE
		charge_cooldown = 3.5
