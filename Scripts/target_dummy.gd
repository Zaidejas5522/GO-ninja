extends CharacterBody2D
var animation = 0;
var hit =0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	if hit:
		_flash()
	else:
		sprite.modulate=Color(1, 1, 1, 1)
func take_damage(damage:int):
	print("AS GAVAUDAMAGEEE")
	hit=true
	await get_tree().create_timer(0.5).timeout
	hit = false


func _flash(): #animation for getting hit
	if animation<5:
		sprite.modulate = Color(25, 0, 0, 0.5)
		animation+=1;
	else:
		if animation >=5 and animation<15:
			animation+=1
			sprite.modulate=Color(1, 1, 1, 1)
		if animation==15:
			animation=0
