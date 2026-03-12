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

# --- END ----

var item_damage = 0
var item_health = 0
var item_speed  = 0

var taken = 0

var player_is_here = 0

var weapons = ["Axe", "Katana", "Stick"]
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

func _process(delta: float) -> void:
	if player_is_here:
		if Input.is_action_just_pressed("Interact") and taken == 0 and slot.slots < slot.MaxSlots:
			Global._addHealth(item_health)
			Global._addSpeed(item_speed)
			Global._addDamage(item_damage)
			sprite.play(str(weapon)+"Hand")
			taken_slot = slot.addWeapon(weapon)
			Global.IsHovering = false
			taken=1
			
			
	if Input.is_action_just_pressed("Drop") and taken == 1 and Global.WeaponSlot == taken_slot:
		Global._minusHealth(item_health)
		Global._minusSpeed(item_speed)
		Global._minusDamage(item_damage)
		slot.minusWeapon(taken_slot)
		sprite.play(str(weapon))
		rotation = 0.0
		taken_slot = -1
		taken=0
		
	if taken == 1 and Global.WeaponSlot == taken_slot:
		Global.CurrentItemDamage = item_damage
		Global.CurrentItemHealth=item_health
		Global.CurrentItemSpeed=item_speed
		
		
		if player.attacking and not was_attacking:
			start_attack_motion()
		was_attacking = player.attacking

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
	
