extends Node

@onready var play_button := $ui/playbutton

func start_game() -> void:
	play_button.disabled = true
	GameManager.play_level(GameManager.mazes[0] as Array[String])

func _ready() -> void:
	play_button.pressed.connect(start_game)
