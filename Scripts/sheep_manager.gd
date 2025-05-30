extends Node2D

@onready var spawning_positions: Node = $SpawningPositions

func _ready() -> void:
	var positions = spawning_positions.get_children()
	
