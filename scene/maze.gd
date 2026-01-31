extends Node2D
class_name LilyMaze

@export var maze_width: int = 7
@export var maze_height: int = 7
@export var maze_gap_x: int = 48
@export var maze_gap_y: int = 48

const LILY_PREFAB := preload("res://scene/lilypad.tscn")
var lily_pads: Array[Array]

func _ready() -> void:
	var lily_pos = Vector2(0, 0)
	lily_pads.resize(maze_height)
	for i in maze_height:
		lily_pads[i].resize(maze_width)
		for j in maze_width:
			var lp = LILY_PREFAB.instantiate() as LilyPad
			lp.position = lily_pos
			lily_pads[i][j] = lp
			add_child(lp)
			lily_pos.x += maze_gap_x
		lily_pos.y += maze_gap_y
		lily_pos.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
