extends Area2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 100

func _physics_process(delta):
	position += direction * speed * delta

func _on_screen_exited():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(6)
		queue_free()
