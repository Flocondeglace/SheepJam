extends AudioStreamPlayer


@onready var game: Node2D = $".."
var current_progress_percentage = 0
var min_volume = -60
var max_volume = 0
var volume_distance

func _ready():
	volume_distance = max_volume - min_volume
	stream.set_sync_stream_volume(1,min_volume)
	stream.set_sync_stream_volume(0,max_volume)

func _process(_delta):
	current_progress_percentage = game.progress_percentage

	if current_progress_percentage > 0.8:
		var volume_percent = (current_progress_percentage - 0.8) * 5
		print(volume_percent)
		var volume_music_1 = min_volume + volume_percent * volume_distance
		var volume_music_0 = max_volume - volume_percent * volume_distance
	
		stream.set_sync_stream_volume(0,volume_music_0)
		stream.set_sync_stream_volume(1,volume_music_1)
