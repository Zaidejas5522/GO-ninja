extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var item_damage = 0
var item_health = 0
var item_speed  = 0

var taken = 0

var player_is_here = 0

var weapons = ["Axe", "Katana", "Stick"]
var weapon=""

 
func _ready() -> void:
	randomize()
	weapon = weapons[randi() % weapons.size()]
	sprite.play(str(weapon))
	item_damage=round(randf_range(1,10))
	item_health=round(randf_range(1,10))
	item_speed=round(randf_range(1,10))

func _process(delta: float) -> void:
	if player_is_here:
		if Input.is_action_just_pressed("Interact") and taken == 0:
			Global._addHealth(item_health)
			sprite.play(str(weapon)+"Hand")
			taken=1
	if taken == 1:
		global_position=player.position

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		print("entered")
		player_is_here = 1
		


func _on_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		print("left")
		player_is_here = 0
