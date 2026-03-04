extends Node2D

var BearScene = preload("res://Scenes/bear.tscn")  # Must be your Bear scene
@onready var bear: CharacterBody2D = $Enemies/Bear

func _ready():
	# Spawn one bear at position (400, 200)
	spawn_bear(Vector2(400, 200))

func spawn_bear(position: Vector2):
	# Instantiate Bear
	var bear: CharacterBody2D = bear.instantiate()  # ✅ correct type

	# Set position
	bear.global_position = position

	# Add to scene tree
	add_child(bear)
