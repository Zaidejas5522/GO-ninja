extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

# Door.gd skripte
func close():
	$AnimatedSprite2D.play("close")
	$CollisionShape2D.set_deferred("disabled", false) # Įjungiam sieną

func open():
	$AnimatedSprite2D.play("open")
	$CollisionShape2D.set_deferred("disabled", true) # Išjungiam sieną
