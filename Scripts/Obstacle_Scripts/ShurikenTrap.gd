extends Area2D



@export var damage = 20
@export var speed = 150.0
#@export var move_distance = 300.0
@onready var ray = $RayCast2D
#var start_pos: Vector2
var direction = Vector2.LEFT
#var direction = {"left": Vector2.LEFT, "right": Vector2.RIGHT, "up": Vector2.UP, "down": Vector2.DOWN}
#var accdirection = direction.keys().pick_random() #starting position
#var distance_traveled = 0.0

func _ready():
	ray.add_exception(self)
	ray.enabled = true

func _process(delta):
	position += direction * speed * delta
	ray.target_position = direction * 30
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		
		# Tikriname, ar tai, į ką atsitrenkėme, yra "Walls" sluoksnis
		# Galime tikrinti pagal mazgo pavadinimą
		if collider is TileMapLayer and "AddOnElements" in collider.name:
			direction *= -1
			ray.target_position = direction * 30
			ray.force_raycast_update()
			#position += direction * 20 # Atstumiame nuo sienos
		
func _on_body_entered(body):
	if body is CharacterBody2D:
		body.take_damage(damage)
		print("hp: ", Global.PlayerHealth)
