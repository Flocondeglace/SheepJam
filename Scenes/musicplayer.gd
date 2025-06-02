extends Node

@onready var epic: AudioStreamPlayer = $epic
@onready var normal: AudioStreamPlayer = $normal

@onready var game: Node2D = $".."
var current_progress_percentage = 0
var min_volume = -25
var max_volume = 0
var volume_distance

func _ready():
	volume_distance = max_volume - min_volume

	epic.set_volume_db(min_volume)
	normal.set_volume_db(max_volume)

func _process(_delta):
	current_progress_percentage = clamp(game.progress_percentage,0,0.9)

	if current_progress_percentage > 0.7:
		var volume_percent = (current_progress_percentage - 0.7)/(0.9-0.7)
		var volume_music_1 = min_volume + volume_percent * volume_distance
		var volume_music_0 = max_volume - volume_percent * volume_distance
	
		normal.set_volume_db(volume_music_0)
		epic.set_volume_db(volume_music_1)
