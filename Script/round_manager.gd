extends Node

@onready var trap_layer: TileMapLayer = $TrapLayer

@onready var spawn_point_sheep: Marker2D = $SpawnPointSheep
@export var sheep_scene: PackedScene
@export var round_sheep_numbers: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var current_round: int = 0
var current_sheep_number: int = 0
@onready var timer_round: Timer = $TimerRound
@onready var timer_between_sheep: Timer = $TimerBetweenSheep
@export var between_sheep_duration: float = 0.4
@export var round_duration: float = 1.0

func _ready():
	reset_round()

func spawn_sheep():
	var sheep = sheep_scene.instantiate()
	sheep.position = spawn_point_sheep.position
	add_child(sheep)
	
func reset_round():
	current_round = 0
	current_sheep_number = 0
	timer_round.start(round_duration)
	
func next_round():
	current_round += 1
	if current_round < round_sheep_numbers.size():
		current_sheep_number = 0
		set_traps_for_round()
		timer_between_sheep.start(between_sheep_duration)
	else:
		reset_round()

func set_traps_for_round():
	print("Setting traps")
	for trap in trap_layer.get_children():
		if trap is Trap:
			trap.on_next_round_begin()

func _on_timer_round_timeout():
	next_round()

func _on_timer_between_sheep_timeout():
	spawn_sheep()
	current_sheep_number += 1
	if current_sheep_number < round_sheep_numbers[current_round]:
		timer_between_sheep.start(between_sheep_duration)
	else:
		timer_round.start(round_duration)
		
