extends Control
@onready var mouton: Sprite2D = $Mouton
@onready var basslidder: Marker2D = $basslidder
@onready var hautslider: Marker2D = $hautslider
@onready var root: Node2D = $"../.."
@onready var mask: TextureRect = $TextureRect5

var y_max = 100
var y_min = 0

func _ready() -> void:
	y_max = hautslider.position.y
	y_min = basslidder.position.y

func _process(delta: float) -> void:
	var progress_percentage = root.progress_percentage
	var y_progress = y_min + (y_max - y_min) * progress_percentage
	mouton.position.y = y_progress
	mask.size.x = abs((y_max - y_min) * progress_percentage)-10
