extends Node2D
class_name Frog

enum Direction {LEFT, RIGHT, UP, DOWN}

@export var jump_duration: float = 0.6
@export var on_maze: Vector2i = Vector2i(0, 0)
@export var dir: Direction = Direction.DOWN

var can_move := true
var jump_transition: Array[Tween.TransitionType] = [
	Tween.TRANS_EXPO,
	Tween.TRANS_EXPO,
	Tween.TRANS_BACK,
	Tween.TRANS_BACK,
]
var jump_easings: Array[Tween.EaseType] = [
	Tween.EASE_IN_OUT,
	Tween.EASE_IN_OUT,
	Tween.EASE_OUT,
	Tween.EASE_IN,
]
var jump_animation_names: Array[String] = [
	"jump_left",
	"jump_right",
	"jump_up", # up
	"jump_down", #down
]
var idle_animation_names: Array[String] = [
	"idle_left", # left
	"idle_right", # right
	"idle_up", # up
	"idle_down", # down
]

@onready var sprite: AnimatedSprite2D = $sprite
@onready var maze: LilyMaze = get_parent()

func try_to_move(new_dir: Direction) -> void:
	if can_move == false:
		return
	var old_on_maze := on_maze
	
	if new_dir == Direction.LEFT and on_maze.x > 0:
		on_maze.x -= 1
	if new_dir == Direction.RIGHT and on_maze.x < maze.size.x - 1:
		on_maze.x += 1
	if new_dir == Direction.UP and on_maze.y > 0:
		on_maze.y -= 1
	if new_dir == Direction.DOWN and on_maze.y < maze.size.y - 1:
		on_maze.y += 1
	dir = new_dir
	
	var new_pos := maze_pos_to_real_pos()
	if new_pos == position:
		return
	
	maze.set_fog(on_maze.x, on_maze.y, 0)
	sprite.play(jump_animation_names[dir])
	can_move = false
	
	var tw := create_tween()
	tw.set_trans(jump_transition[dir])
	tw.set_ease(jump_easings[dir])
	tw.tween_property(self, "position", new_pos, jump_duration)
	await tw.finished
	
	maze.set_fog(old_on_maze.x, old_on_maze.y, maze.max_fog)
	maze.set_fog(on_maze.x, on_maze.y, 0)
	sprite.play(idle_animation_names[dir])
	maze.try_eat_fly(on_maze)
	can_move = true

func maze_pos_to_real_pos() -> Vector2:
	return Vector2(maze.gap.x * on_maze.x, maze.gap.y * on_maze.y)

func _ready() -> void:
	position = maze_pos_to_real_pos()
	sprite.play(idle_animation_names[dir])
	
	for anim in jump_animation_names:
		sprite.sprite_frames.set_animation_speed(anim, 6 / jump_duration)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		try_to_move(Direction.LEFT)
	if Input.is_action_just_pressed("move_right"):
		try_to_move(Direction.RIGHT)
	if Input.is_action_just_pressed("move_up"):
		try_to_move(Direction.UP)
	if Input.is_action_just_pressed("move_down"):
		try_to_move(Direction.DOWN)
