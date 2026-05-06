extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var max_health_sfx: AudioStreamPlayer2D = $MaxHealthSFX
@onready var heal_sfx: AudioStreamPlayer2D = $HealSFX
@onready var upgrade_damage_sfx: AudioStreamPlayer2D = $UpgradeDamageSFX
@onready var upgrade_speed_sfx: AudioStreamPlayer2D = $UpgradeSpeedSFX
@onready var money_bag_sfx: AudioStreamPlayer2D = $MoneyBagSFX
@onready var weapon_slot = get_tree().get_first_node_in_group("WeaponSlot")


#DA REAL SCRIPT
var isShop=0
var cost = 0

# Randomly chosen name for this instance
var item_name: String = ""

func _ready() -> void:
	# Pick a random name from the list
	randomize()
	var names: Array[String] =[""];
	if isShop == 0:
		names = ["Heal1", "Upgrade", "MoneyBag","MaxHealth","MoreSlot"]
	else:
		names = ["Heal1", "Upgrade","MaxHealth","MoreSlot"]


		
	item_name = names[randi() % names.size()]
	
	if isShop == 1:
		var label: Label = $Label3
		match item_name:
			"Heal1":
				cost = 1;
				pass
			"Upgrade":
				cost = 2;
				pass
			"MaxHealth":
				cost = 3;
				pass
			"MoreSlot":
				cost = 3;
				pass
		var label_3: Label = $Label3
		label_3.text = str(cost)

	# Play the corresponding animation
	animated_sprite.play(item_name)
	
	# Connect the body_entered signal (if not connected in editor)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Only react if the entering body belongs to the "player" group
	if not body.is_in_group("player"):
		return
	
	if cost > Global.Money:
		return
	else:
		Global.Money-=cost
	# --- Special effect based on item name ---
	match item_name:
		"Heal1":
			Global.PlayerHealth+=10;
			heal_sfx.play()
			await heal_sfx.finished
			pass
		"Upgrade":
			var upgrade_options = ["PlayerSpeed", "PlayerDamage"]
			var chosen = upgrade_options[randi() % upgrade_options.size()]
			match chosen:
				"PlayerSpeed":
					Global.PlayerSpeed += 5
					upgrade_speed_sfx.play()
					await upgrade_speed_sfx.finished
				"PlayerDamage":
					Global.PlayerDamage += 5
					upgrade_damage_sfx.play()
					await upgrade_damage_sfx.finished
			pass
		"MoneyBag":
			Global.Money += 10
			money_bag_sfx.play()
			await money_bag_sfx.finished
			pass
		"MaxHealth":
			Global.MaxPlayerHealth += 20
			Global.PlayerHealth = Global.MaxPlayerHealth
			max_health_sfx.play()
			await max_health_sfx.finished
			pass
		"MoreSlot":
			weapon_slot.addSlot()
			upgrade_speed_sfx.play()
			await upgrade_speed_sfx.finished
			pass
	
	# Remove the item from the scene
	queue_free()
