extends Node

@onready var play_button := $ui/playbutton

func start_game() -> void:
	play_button.disabled = true
	get_tree().change_scene_to_file("res://scene/cutscene.tscn")
	
func _ready() -> void:
	play_button.pressed.connect(start_game)
