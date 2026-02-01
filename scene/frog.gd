extends Node2D
class_name Frog

enum Direction {LEFT, RIGHT, UP, DOWN}

const BLOOD_PREFAB := preload("res://scene/blood.tscn")

@export var jump_duration: float = 0.6
@export var on_maze: Vector2i = Vector2i(0, 0)
@export var dir: Direction = Direction.DOWN

var can_move := true
var jump_transition: Array[Tween.TransitionType] = [
	Tween.TRANS_EXPO,
	Tween.TRANS_EXPO,
	Tween.TRANS_BACK,
	Tween.TRANS_EXPO,
]
var jump_easings: Array[Tween.EaseType] = [
	Tween.EASE_IN_OUT,
	Tween.EASE_IN_OUT,
	Tween.EASE_OUT,
	Tween.EASE_IN_OUT,
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

@onready var shadow := $shadow
@onready var sprite := $sprite
@onready var maze: LilyMaze = get_parent()

func land_on_lily(lilytype: LilyPad.LilyType) -> void:
	if lilytype == LilyPad.LilyType.ICE:
		try_to_move(dir)
	if lilytype == LilyPad.LilyType.SPIKE:
		var splash := BLOOD_PREFAB.instantiate() as Splash
		splash.position.x = position.x
		splash.position.y = position.y - 30
		get_parent().add_child(splash)
		GameManager.player_die()

func try_to_move(new_dir: Direction) -> void:
	if can_move == false:
		return
	var new_on_maze := on_maze
	
	if new_dir == Direction.LEFT and on_maze.x > 0:
		new_on_maze.x -= 1
	if new_dir == Direction.RIGHT and on_maze.x < maze.size.x - 1:
		new_on_maze.x += 1
	if new_dir == Direction.UP and on_maze.y > 0:
		new_on_maze.y -= 1
	if new_dir == Direction.DOWN and on_maze.y < maze.size.y - 1:
		new_on_maze.y += 1
	dir = new_dir
	
	var new_pos := Vector2(maze.gap.x * new_on_maze.x, maze.gap.y * new_on_maze.y)
	if new_pos == position or maze.lily_pads[new_on_maze.y][new_on_maze.x].has_snake:
		return
	
	maze.lily_pads[on_maze.y][on_maze.x].timer = 0
	sprite.play(jump_animation_names[dir])
	can_move = false
	
	var tw := create_tween()
	tw.set_trans(jump_transition[dir])
	tw.set_ease(jump_easings[dir])
	tw.tween_property(self, "position", new_pos, jump_duration)
	await tw.finished
	
	maze.set_fog(on_maze.x, on_maze.y, maze.max_fog)
	maze.set_fog(new_on_maze.x, new_on_maze.y, 0)
	sprite.play(idle_animation_names[dir])
	maze.try_eat_fly(new_on_maze)
	can_move = true
	
	on_maze = new_on_maze
	land_on_lily(maze.get_lily_type_on(on_maze))

func maze_pos_to_real_pos() -> Vector2:
	return Vector2(maze.gap.x * on_maze.x, maze.gap.y * on_maze.y)

func _ready() -> void:
	position = maze_pos_to_real_pos()
	sprite.play(idle_animation_names[dir])
	
	for anim in jump_animation_names:
		sprite.sprite_frames.set_animation_speed(anim, 6 / jump_duration)

func _process(delta: float) -> void:
	if GameManager.world.state != World.GameState.PLAY:
		return
	
	if can_move:
		maze.lily_pads[on_maze.y][on_maze.x].timer += delta
	
	if Input.is_action_just_pressed("move_left"):
		try_to_move(Direction.LEFT)
	if Input.is_action_just_pressed("move_right"):
		try_to_move(Direction.RIGHT)
	if Input.is_action_just_pressed("move_up"):
		try_to_move(Direction.UP)
	if Input.is_action_just_pressed("move_down"):
		try_to_move(Direction.DOWN)
