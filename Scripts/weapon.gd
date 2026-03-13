extends Area2D

@onready var sprite: AnimatedSprite2D = $WeaponSprites
@onready var player = get_tree().get_first_node_in_group("player")
@onready var slot = get_tree().get_first_node_in_group("WeaponSlot")

# ---ATTACK STUFF ----

@export var offset_distance: float = 0
@export var attack_extra_distance: float = 17.0 # Extra distance during attack , WILL NEED TO TWEAK FOR EACH DIFFERENT WEAPON
@export var attack_duration: float = 0.3   

var attack_extra_offset: float = 0.0            # Current extra offset (0 when idle)
var was_attacking: bool = false                 # Track previous attack state
var current_attack_tween: Tween = null          # To manage attack tweens

#SKILL RELATED----
var skill_attacking: bool = false  
var cooldown_timer: Timer
var SkillUsed = 0

var extra_offset: float = 0.0

var is_spinning := false       # Specific flag for the axe spin
var spin_angle := 0.0

var is_lance_dashing := false       # Specific flag for lance dash
var dash_dir := Vector2.ZERO

#------
# --- END ----

var item_damage = 0
var item_health = 0
var item_speed  = 0

var taken = 0

var player_is_here = 0

var weapons = ["Axe", "Katana", "Stick","Rapier","Lance"]
var weapon=""
var taken_slot = -1
 
func _ready() -> void:
	sprite.flip_h=false
	sprite.flip_v=false
	randomize()
	weapon = weapons[randi() % weapons.size()]
	sprite.play(str(weapon))
	item_damage=round(randf_range(1,10))
	item_health=round(randf_range(1,10))
	item_speed=round(randf_range(10,100))
	_choose_item_stats(weapon)
	
	#-----
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)
	
func _on_cooldown_timeout():
	Global.SkillReady = true
	SkillUsed = 0

func _process(delta: float) -> void:
	if SkillUsed == 1:
			Global.CurrentSkillCooldown=cooldown_timer.time_left
	if player_is_here:
		if Input.is_action_just_pressed("Interact") and taken == 0 and slot.slots < slot.MaxSlots:
			Global._addHealth(item_health)
			Global._addSpeed(item_speed)
			Global._addDamage(item_damage)
			sprite.play(str(weapon)+"Hand")
			taken_slot = slot.addWeapon(weapon)
			Global.IsHovering = false
			sprite.visible=false
			taken=1
			
			
			
	if Input.is_action_just_pressed("Drop") and taken == 1 and Global.WeaponSlot == taken_slot:
		Global._minusHealth(item_health)
		Global._minusSpeed(item_speed)
		Global._minusDamage(item_damage)
		slot.minusWeapon(taken_slot)
		sprite.play(str(weapon))
		rotation = 0.0
		taken_slot = -1
		sprite.visible=true
		taken=0
		
	if taken == 1 and Global.WeaponSlot == taken_slot:
		player.attacktime=attack_duration
		Global.CurrentItemDamage = item_damage
		Global.CurrentItemHealth=item_health
		Global.CurrentItemSpeed=item_speed
		
		
		if player.attacking and not was_attacking:
			start_attack_motion()

		was_attacking = player.attacking
		
		if  Input.is_action_just_pressed("Skill") and not skill_attacking and Global.SkillReady:
			SkillUsed = 1
			Global.SkillReady = false
			cooldown_timer.start(Global.SkillCooldown)
			skill_attack()
		
		
		if player.attacking:
			sprite.visible=true
		else:
			sprite.visible=true

		# Calculate total offset: base + attack extra
		var total_offset = offset_distance + attack_extra_offset
		
		if skill_attacking==false:
			var facing = player.facing_direction
		
			match facing:
				player.Direction.DOWN:
					sprite.flip_v = false
					global_position = player.global_position + Vector2(0, total_offset)
					rotation = 0.0
				player.Direction.UP:
					sprite.flip_v = false
					global_position = player.global_position + Vector2(0, -total_offset)
					rotation = PI
				player.Direction.LEFT:
					sprite.flip_v = true
					global_position = player.global_position + Vector2(-total_offset, 0)
					rotation = -PI / 2
				player.Direction.RIGHT:
					sprite.flip_v = true
					global_position = player.global_position + Vector2(total_offset, 0)
					rotation = PI / 2
				_:
			# Default (if facing NONE) – face down
					global_position = player.global_position + Vector2(0, total_offset)
					rotation = 0.0
		elif is_spinning:
				global_position = player.global_position + (Vector2(cos(spin_angle), sin(spin_angle)) * offset_distance)
				rotation = spin_angle
				sprite.flip_v = false   # Disable flip during spin
		elif is_lance_dashing:
		# Position = player's position + direction * (base offset + extra offset)
			position = player.global_position + dash_dir * (offset_distance + extra_offset)
			# Rotate to face the dash direction
			if dash_dir == Vector2.LEFT or dash_dir == Vector2.RIGHT:
				rotation = dash_dir.angle() + deg_to_rad(90)
			else:
				rotation = dash_dir.angle() - deg_to_rad(90)
			# Flip sprite for left/right if necessary
			sprite.flip_v = (dash_dir == Vector2.LEFT or dash_dir == Vector2.RIGHT)

			
	elif taken == 1:
		global_position=player.global_position
func start_attack_motion():

	# Kill any ongoing tween to avoid conflicts
	if current_attack_tween:
		current_attack_tween.kill()

	# Create a new tween for the thrust motion
	current_attack_tween = create_tween()
	# Extend forward (half the attack time)
	current_attack_tween.tween_property(self, "attack_extra_offset", attack_extra_distance, attack_duration * 0.5)
	# Retract back (remaining half)
	current_attack_tween.tween_property(self, "attack_extra_offset", 0.0, attack_duration * 0.5)

	
func skill_attack():
	match weapon:
		"Axe":
			skill_attacking = true
			is_spinning = true
			player.attacking=true
			var old_scale = self.scale
			self.scale = self.scale * 7

			# Determine starting angle based on player's facing direction
			var start_angle := 0.0
			match player.facing_direction:
				player.Direction.RIGHT:
					start_angle = 0.0
				player.Direction.DOWN:
					start_angle = PI / 2
				player.Direction.LEFT:
					start_angle = PI
				player.Direction.UP:
					start_angle = 3 * PI / 2
				_:
					start_angle = PI / 2   # fallback

			spin_angle = start_angle
			var rotations = 3.0
			var target_angle = start_angle + 2 * PI * rotations
			var spin_duration = 1.0   # Total time for three spins

			var tween = create_tween()
			tween.tween_property(self, "spin_angle", target_angle, spin_duration)
			await tween.finished

			# Clean up after spin
			is_spinning = false
			skill_attacking = false
			player.attacking=false
			self.scale = old_scale
		"Katana":
			pass
		"Stick":
			# Prevent multiple skill attacks at once
			if skill_attacking:
				return
			skill_attacking = true
			player.attacking=true
	
			# Store original scale
			var original_scale = sprite.scale
	
			# Determine stretch direction based on player's facing
			# We'll stretch along the weapon's length (local Y axis)
			var stretch_factor = 30  # How much to stretch (adjust as needed)
			var stretch_duration = 0.3  # Time to stretch out
			var retract_duration = 0.2  # Time to retract
	
			# Create tween for stretching
			var tween = create_tween()
			tween.set_parallel(false)  # Sequential
	
			# Stretch out
			tween.tween_property(self, "scale:y", original_scale.y * stretch_factor, stretch_duration)
	
			# Retract back
			tween.tween_property(self, "scale:y", original_scale.y, retract_duration)
	
			# When done, reset skill_attacking flag
			await tween.finished
			skill_attacking = false
			player.attacking=false
		"Rapier":
			skill_attacking = true
			player.attacking=true

	
			var thrusts = 6
			var thrust_distance = 30.0      # How far the rapier thrusts forward
			var thrust_duration = 0.04       # Time to extend
			var return_duration = 0.04        # Time to retract
			var pause_between = 0.02          # Pause between thrusts
	
			# Determine base position (where the weapon normally rests)
			var base_pos = Vector2.ZERO
			match player.facing_direction:
				player.Direction.DOWN:
					base_pos = player.global_position + Vector2(0, offset_distance)
				player.Direction.UP:
					base_pos =player.global_position + Vector2(0, -offset_distance)
				player.Direction.LEFT:
					base_pos = player.global_position + Vector2(-offset_distance, 0)
				player.Direction.RIGHT:
					base_pos = player.global_position + Vector2(offset_distance, 0)
				_:
					base_pos = player.global_position + Vector2(0, offset_distance)
	
			# Direction unit vector for thrust
			var thrust_dir := Vector2.ZERO
			match player.facing_direction:
				player.Direction.DOWN:
					thrust_dir = Vector2.DOWN
				player.Direction.UP:
					thrust_dir = Vector2.UP
				player.Direction.LEFT:
					thrust_dir = Vector2.LEFT
				player.Direction.RIGHT:
					thrust_dir = Vector2.RIGHT
				_:
					thrust_dir = Vector2.DOWN
	
			# Ensure we start at base position
			position = base_pos
	
			var tween = create_tween()
			tween.set_parallel(false)
	
			for i in range(thrusts):
				# Thrust out
				tween.tween_property(self, "position", base_pos + thrust_dir * thrust_distance, thrust_duration)
				# Thrust back
				tween.tween_property(self, "position", base_pos, return_duration)
				# Small pause between thrusts (except after last)
				if i < thrusts - 1 and pause_between > 0:
					tween.tween_interval(pause_between)
	
			await tween.finished
	
			# Ensure we end at base position
			position = base_pos
			skill_attacking = false
			player.attacking=false
		"Lance":
			is_lance_dashing = true
			skill_attacking = true
			player.isdashing = true

		# Parameters
			var dash_distance := 150.0        # How far the player moves
			var dash_duration := 0.4           # Total dash time
			var peek_distance := 20.0          # How far the lance extends
			var extend_time := 0.1             # Time to extend lance
			var retract_time := 0.1            # Time to retract lance at the end

			# Get base position and direction based on player's facing
			
			match player.facing_direction:
				player.Direction.DOWN:
					dash_dir = Vector2.DOWN
				player.Direction.UP:
					dash_dir = Vector2.UP
				player.Direction.LEFT:
					dash_dir = Vector2.LEFT
				player.Direction.RIGHT:
					dash_dir = Vector2.RIGHT


			# Ensure weapon starts at normal position
			extra_offset = 0.0

			# Create tweens for dash and lance extension
			var tween = create_tween()
			tween.set_parallel(true)   # Run animations together

			# 1. Move the player forward
			var target_player_pos =  player.global_position + dash_dir * dash_distance

			var OLDSPEED=player.SPEED
			player.SPEED=OLDSPEED*2
			# 2. Extend the lance (peek) – we do this in two steps: extend quickly, hold, then retract.
			#    Since we're in parallel, we need to sequence the lance animation separately.
			#    We'll use a second tween for the lance, chained sequentially.
			var lance_tween = create_tween()
			lance_tween.set_parallel(false)
			lance_tween.tween_property(self, "extra_offset", peek_distance, extend_time)
			lance_tween.tween_interval(dash_duration - extend_time - retract_time)
			lance_tween.tween_property(self, "extra_offset", 0.0, retract_time)

			# Wait for both tweens to finish
			await lance_tween.finished

			# Cleanup
			extra_offset = 0.0
			player.SPEED=OLDSPEED
			is_lance_dashing = false
			player.isdashing = false
			skill_attacking = false

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		if taken == 0:
			Global.IsHovering = true
			player_is_here = 1
		
		Global.PotentialPlayerDamage = item_damage
		Global.PotentialPlayerHealth = item_health
		Global.PotentialPlayerSpeed=item_speed
		

		

func _on_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		if taken == 0:
			Global.IsHovering = false
			player_is_here = 0
	
func _choose_item_stats(name):
	match name:
		"Axe":
			attack_extra_distance = 20
			attack_duration = 0.3
		"Katana":
			attack_extra_distance = 12
			attack_duration = 0.2
		"Stick":
			attack_extra_distance = 27
			attack_duration = 0.4 
		"Rapier":
			attack_extra_distance = 15
			attack_duration = 0.25
		"Lance":
			attack_extra_distance = 32
			attack_duration = 0.5
