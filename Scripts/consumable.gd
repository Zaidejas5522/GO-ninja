extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Randomly chosen name for this instance
var item_name: String = ""

func _ready() -> void:
	# Pick a random name from the list
	randomize()
	var names: Array[String] = ["Heal1", "Upgrade", "MoneyBag"]
	item_name = names[randi() % names.size()]
	
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
	
	# Remove the item from the scene
	queue_free()
