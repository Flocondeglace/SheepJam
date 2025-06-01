extends Node2D

@onready var sheep: Sheep = $SheepsContainer/Sheep
@onready var animation_transition: AnimationPlayer = $CanvasLayer/Transition/AnimationPlayer
var transition : bool = false

# menu
@onready var credit: PanelContainer = $CanvasLayer/OtherWindows/Credit
@onready var settings: PanelContainer = $CanvasLayer/OtherWindows/Settings

@onready var master_slider: HSlider = $CanvasLayer/OtherWindows/Settings/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer3/MasterSlider
@onready var background_music_slider: HSlider = $CanvasLayer/OtherWindows/Settings/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/BackgroundMusicSlider
@onready var sound_effect_slider: HSlider = $CanvasLayer/OtherWindows/Settings/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer2/SoundEffectSlider


func _ready() -> void:
	credit.visible = false
	settings.visible = false
	var bus_index = AudioServer.get_bus_index("Master")
	var value = AudioServer.get_bus_volume_linear(bus_index)
	master_slider.value = value
	bus_index = AudioServer.get_bus_index("Music")
	value = AudioServer.get_bus_volume_linear(bus_index)
	background_music_slider.value = value
	bus_index = AudioServer.get_bus_index("SFX")
	value = AudioServer.get_bus_volume_linear(bus_index)
	sound_effect_slider.value = value

func _process(_delta):
	if sheep.have_collided && !transition:
		transition = true
		do_transition()

func do_transition():
	await get_tree().create_timer(1).timeout
	animation_transition.play("transition")
	await animation_transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_credit_button_pressed() -> void:
	print("Menu : Credit")
	credit.visible = true


func _on_settings_button_pressed() -> void:
	print("Menu : Settings")
	settings.visible = true


func _on_back_pressed() -> void:
	print("Menu : Back")
	settings.visible = false
	credit.visible = false


func _on_background_music_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_sound_effect_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	sheep.meh.play()
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_master_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
