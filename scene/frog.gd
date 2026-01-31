extends Node2D

@onready var maze: LilyMaze = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		position.x -= maze.maze_gap_x
	if Input.is_action_just_pressed("move_right"):
		position.x += maze.maze_gap_x
	if Input.is_action_just_pressed("move_up"):
		position.y -= maze.maze_gap_y
	if Input.is_action_just_pressed("move_down"):
		position.y += maze.maze_gap_y
