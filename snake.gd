extends Node2D
class_name Snake

var on_maze: Vector2i
var is_done := false

func is_near_frog() -> bool:
	if GameManager.world.frog == null:
		return false
	var diff: Vector2i = abs(on_maze - GameManager.world.frog.on_maze)
	return (diff.x == 1 and diff.y == 0) or (diff.x == 0 and diff.y == 1)

func _ready() -> void:
	$sprite.play("default")

func _process(_delta: float) -> void:
	if GameManager.world.maze.num_flies <= 0 and is_near_frog():
		GameManager.player_win()
	
	if is_done == false and GameManager.world.maze.num_flies <= 0 and GameManager.is_last_level:
		$sprite.play("reveal")
		$sprite.position.y += 10
		is_done = true
