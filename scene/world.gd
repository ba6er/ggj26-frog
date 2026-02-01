extends Node2D
class_name World

enum GameState {PLAY, PAUSE, WIN, LOSE}

var state := GameState.PLAY

@onready var win_display := $ui/win_display
@onready var lose_display := $ui/lose_display
@onready var restart_button := $ui/lose_display/restart_level
@onready var maze := $maze
@onready var frog := $maze/frog

func restart() -> void:
	GameManager.play_level(GameManager.current_maze)

func _ready() -> void:
	maze.generate(GameManager.current_maze)
	print(maze.num_flies)
	
	restart_button.pressed.connect(restart)
	win_display.visible = false
	lose_display.visible = false

func _enter_tree() -> void:
	GameManager.world = self
