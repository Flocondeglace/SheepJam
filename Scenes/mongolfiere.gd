extends Node2D
@onready var mongolfiere_back: Sprite2D = $MongolfiereBack

@export var color_list:Array[Color]
var can_be_destroyed:bool=false
func _ready() -> void:
	var random_color:Color=color_list[randi()%color_list.size()]
	$MongolfiereBack.modulate=random_color

func _process(delta: float) -> void:
	position.y -= 2


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	can_be_destroyed=true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if can_be_destroyed:
		queue_free()
