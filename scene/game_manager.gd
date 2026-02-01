extends Node

var world: World
var current_maze: Array[String]
var maze_index: int = 0
var is_last_level := false

var maze0: Array[String] = [
	"0000000",
	"0000000",
	"0003000",
	"0019200",
	"0080000",
	"0000000",
	"0000000",
]
var maze1: Array[String] = [
	"0202020",
	"2000009",
	"8020200",
	"0000002",
	"0202000",
	"0000232",
	"0200000",
]
var maze2: Array[String] = [
	"0029001",
	"2222102",
	"2001000",
	"0002003",
	"0102012",
	"1300002",
	"2002008",
]
var maze3: Array[String] = [
	"2231012",
	"9022002",
	"2001202",
	"2020000",
	"2000220",
	"2022210",
	"2000128",
]
var maze4: Array[String] = [
	"1113118",
	"1101000",
	"1113101",
	"1111101",
	"2101010",
	"1122111",
	"1911021",
]

var mazes := [maze1, maze2, maze3, maze4]

func player_die() -> void:
	world.state = World.GameState.LOSE
	world.lose_display.visible = true
	world.frog.shadow.visible = false
	world.frog.sprite.position.y += 16
	world.frog.sprite.play("death")
	await world.frog.sprite.animation_finished
	world.frog.queue_free()

func player_win() -> void:
	if GameManager.is_last_level:
		world.maze.reveal_fog()
	world.state = World.GameState.WIN
	world.win_display.visible = true

func toggle_pause() -> void:
	if world.state == World.GameState.PLAY:
		world.state = World.GameState.PAUSE
	elif world.state == World.GameState.PAUSE:
		world.state = World.GameState.PLAY

func next_level() -> void:
	maze_index = (maze_index + 1) % len(mazes)
	is_last_level = maze_index == len(mazes) - 1
	play_level(mazes[maze_index])

func play_level(level_strings: Array[String]) -> void:
	get_tree().change_scene_to_file("res://scene/world.tscn")
	current_maze = level_strings

func eat_fly() -> void:
	world.maze.num_flies -= 1
