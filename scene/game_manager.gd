extends Node

var world: World
var current_maze: Array[String]

var maze0: Array[String] = [
	"3000000",
	"0000000",
	"0003000",
	"0010200",
	"0000000",
	"0000300",
	"0000000",
]

func player_die() -> void:
	world.state = World.GameState.LOSE
	world.lose_display.visible = true

func player_win() -> void:
	world.state = World.GameState.WIN
	world.win_display.visible = true

func toggle_pause() -> void:
	if world.state == World.GameState.PLAY:
		world.state = World.GameState.PAUSE
	elif world.state == World.GameState.PAUSE:
		world.state = World.GameState.PLAY

func play_level(level_strings: Array[String]) -> void:
	get_tree().change_scene_to_file("res://scene/world.tscn")
	current_maze = level_strings

func eat_fly() -> void:
	world.maze.num_flies -= 1
	if world.maze.num_flies <= 0:
		player_win()
