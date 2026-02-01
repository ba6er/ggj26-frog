extends Node

@onready var play_button: Button = $ui/playbutton

func start_game() -> void:
	play_button.disabled = true
	GameManager.play_level(GameManager.maze0)

func _ready() -> void:
	play_button.pressed.connect(start_game)
