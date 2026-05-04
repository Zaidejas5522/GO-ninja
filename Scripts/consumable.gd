extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var isShop = 0
var cost =0
# Randomly chosen name for this instance
var item_name: String = ""

func _ready() -> void:
	# Pick a random name from the list
	randomize()

	var names: Array[String] = ["Heal1", "Upgrade", "MoneyBag"]
	item_name = names[randi() % names.size()]
	

	#var names: Array[String] =[""];
	if isShop == 0:
		names = ["Heal1", "Upgrade", "MoneyBag","MaxHealth"]
	else:
		names = ["Heal1", "Upgrade","MaxHealth"]


		
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
	
	# --- Special effect based on item name ---
	match item_name:
		"Heal1":
			Global.PlayerHealth+=10;
			pass
		"Upgrade":
			var upgrade_options = ["PlayerSpeed", "PlayerDamage"]
			var chosen = upgrade_options[randi() % upgrade_options.size()]
			match chosen:
				"PlayerSpeed":
					Global.PlayerSpeed += 5
				"PlayerDamage":
					Global.PlayerDamage += 5
			pass
		"MoneyBag":
			Global.Money += 10
			pass
		"MaxHealth":
			Global.MaxPlayerHealth += 20
			pass
	
	# Remove the item from the scene
	queue_free()
