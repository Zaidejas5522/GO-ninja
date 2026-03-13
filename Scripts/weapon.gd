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

var skill_attacking: bool = false  
var cooldown_timer: Timer
var SkillUsed = 0
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
		
		if SkillUsed == 1:
			Global.CurrentSkillCooldown=cooldown_timer.time_left
		if player.attacking:
			sprite.visible=true
		else:
			sprite.visible=true

		# Calculate total offset: base + attack extra
		var total_offset = offset_distance + attack_extra_offset
		
		
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
			pass
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
			tween.tween_property(sprite, "scale:y", original_scale.y * stretch_factor, stretch_duration)
	
			# Retract back
			tween.tween_property(sprite, "scale:y", original_scale.y, retract_duration)
	
			# When done, reset skill_attacking flag
			await tween.finished
			skill_attacking = false
			player.attacking=false
		"Rapier":
			pass
		"Lance":
			pass
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
