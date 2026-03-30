extends CharacterBody2D

# SETTINGS
var speed := 60
var stop_distance := 20.0

var attack_range := 30
var charge_range := 300

var attack_damage := 4
var charge_damage := 8

# STATES
enum State {
	IDLE,
	WALK,
	ATTACK,
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

# OTHER
var health = 720
var current_axis := ""
var target_breadcrumb: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT
var charge_direction := Vector2.ZERO

func _ready():
	player_reference = get_tree().get_first_node_in_group("player")
	# Išjungiame visas attack zonas pradžioje
	attack_left_area.monitoring = false
	attack_right_area.monitoring = false

# DAMAGE
func take_damage(damage:int):
	health -= damage

	var recoil_strength = 30
	global_position += -facing_direction * recoil_strength

	# HIT ANIMACIJA
	hit_timer = 0.7
	current_state = State.IDLE

	if health <= 0:
		queue_free()

# MAIN LOOP
func _physics_process(delta: float) -> void:
	if not player_reference:
		return

	# HIT STATE
	if hit_timer > 0:
		hit_timer -= delta
		velocity = Vector2.ZERO
		animated_sprite.play("Hit")
		return

	# cooldown mažinimas
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if charge_cooldown > 0:
		charge_cooldown -= delta

	match current_state:
		State.IDLE, State.WALK:
			handle_movement(delta)
			handle_attack_logic()
		
		State.ATTACK:
			update_attack(delta)
		
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
			if abs(delta_pos.x) > abs(delta_pos.y):
				current_axis = "x"
			else:
				current_axis = "y"

		if current_axis == "x":
			direction.x = sign(delta_pos.x)

			if abs(delta_pos.x) < 2:
				current_axis = "y"

			facing_direction = Vector2(direction.x, 0)
			animated_sprite.play("Walking")

		elif current_axis == "y":
			direction.y = sign(delta_pos.y)

			if abs(delta_pos.y) < 2:
				current_axis = "x"

			facing_direction = Vector2(0, direction.y)
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

	# Išjungiame abi attack zonas prieš pradėdami animaciją
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

	# hit moment
	if attack_timer < 0.3 and attack_timer > 0.3 - delta:
		# Patikrinimas, ar žaidėjas kontaktuoja su area
		if facing_direction.x < 0:
			for body in attack_left_area.get_overlapping_bodies():
				if body.has_method("take_damage"):
					body.take_damage(attack_damage)
		else:
			for body in attack_right_area.get_overlapping_bodies():
				if body.has_method("take_damage"):
					body.take_damage(attack_damage)

	if attack_timer <= 0:
		current_state = State.IDLE
		attack_cooldown = 1.5
		# Išjungiame visas attack zonas
		attack_left_area.monitoring = false
		attack_right_area.monitoring = false

# CHARGE
func start_charge():
	current_state = State.CHARGE
	charge_timer = 0.6

	charge_direction = (player_reference.global_position - global_position).normalized()

	if charge_direction.x < 0:
		animated_sprite.play("ChargeLeft")
	else:
		animated_sprite.play("ChargeRight")

func update_charge(delta):
	charge_timer -= delta

	var dash_speed = 300
	velocity = charge_direction * dash_speed
	move_and_slide()

	# hit check
	if global_position.distance_to(player_reference.global_position) < 50:
		if player_reference.has_method("take_damage"):
			player_reference.take_damage(charge_damage)
			charge_timer = 0

	if charge_timer <= 0:
		velocity = Vector2.ZERO
		current_state = State.IDLE
		charge_cooldown = 3.5
