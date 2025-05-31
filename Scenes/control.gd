extends Control
@onready var mouton: Sprite2D = $Mouton
@onready var basslidder: Marker2D = $basslidder
@onready var hautslider: Marker2D = $hautslider
@onready var root: Node2D = $"../.."

var y_max = 100
var y_min = 0

func _ready() -> void:
	y_max = hautslider.position.y
	y_min = basslidder.position.y

func _process(_delta: float) -> void:
	var progress_percentage = root.progress_percentage
	var y_progress = y_min + (y_max - y_min) * progress_percentage
	# print("Le y min est ",y_min)
	# print("Le y max est ",y_max)
	# print("Le progress percentage est ",progress_percentage)
	# print("Le y progress est ",y_progress)
	mouton.position.y = y_progress
