extends Node2D
class_name Frog

enum Direction {LEFT, RIGHT, UP, DOWN}

@export var jump_duration: float = 0.3
@export var on_maze: Vector2i = Vector2i(0, 0)
@export var dir: Direction = Direction.DOWN

var can_move := true
var jump_transition : Array[Tween.TransitionType] = [
	Tween.TRANS_CUBIC,
	Tween.TRANS_CUBIC,
	Tween.TRANS_BACK,
	Tween.TRANS_BACK,
]
var jump_easings : Array[Tween.EaseType] = [
	Tween.EASE_OUT,
	Tween.EASE_OUT,
	Tween.EASE_OUT,
	Tween.EASE_IN,
]

@onready var sprite: Sprite2D = $sprite
@onready var maze: LilyMaze = get_parent()

func try_to_move(new_dir: Direction) -> void:
	if new_dir == Direction.LEFT and on_maze.x > 0:
		on_maze.x -= 1
	if new_dir == Direction.RIGHT and on_maze.x < maze.size.x - 1:
		on_maze.x += 1
	if new_dir == Direction.UP and on_maze.y > 0:
		on_maze.y -= 1
	if new_dir == Direction.DOWN and on_maze.y < maze.size.y - 1:
		on_maze.y += 1
	dir = new_dir
	sprite.frame = dir
	
	var new_pos := maze_pos_to_real_pos()
	if new_pos == position:
		return
	
	can_move = false
	var tw := create_tween()
	tw.set_trans(jump_transition[dir])
	tw.set_ease(jump_easings[dir])
	tw.tween_property(self, "position", new_pos, jump_duration)
	await tw.finished
	can_move = true

func maze_pos_to_real_pos() -> Vector2:
	return Vector2(maze.gap.x * on_maze.x, maze.gap.y * on_maze.y)

func _ready() -> void:
	sprite.frame = dir
	position = maze_pos_to_real_pos()

func _process(_delta: float) -> void:
	if can_move == false:
		return
	
	if Input.is_action_just_pressed("move_left"):
		try_to_move(Direction.LEFT)
	if Input.is_action_just_pressed("move_right"):
		try_to_move(Direction.RIGHT)
	if Input.is_action_just_pressed("move_up"):
		try_to_move(Direction.UP)
	if Input.is_action_just_pressed("move_down"):
		try_to_move(Direction.DOWN)
