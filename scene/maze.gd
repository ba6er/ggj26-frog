extends Node2D
class_name LilyMaze

@export var size: Vector2i = Vector2i(7, 7)
@export var gap: Vector2i = Vector2i(50, 50)
@export var flies: Array[Vector2i] = []

const LILY_PREFAB := preload("res://scene/lilypad.tscn")
const FLY_PREFAB := preload("res://scene/fly.tscn")
var lily_pads: Array[Array]

@onready var frog := $frog
@onready var max_fog := LilyFog.num_opacity_levels

func try_eat_fly(pos: Vector2i) -> void:
	if pos in flies and lily_pads[pos.y][pos.x].has_fly == true:
		lily_pads[pos.y][pos.x].has_fly = false
		lily_pads[pos.y][pos.x].get_child(2).queue_free()

func set_fog(frog_x: int, frog_y: int, level: int) -> void:
	var frog_left: int = max(frog_x - 1, 0)
	var frog_right: int = min(frog_x + 1, size.x - 1)
	var frog_up: int = max(frog_y - 1, 0)
	var frog_down: int = min(frog_y + 1, size.y - 1)
	lily_pads[frog_y][frog_x].fog.set_opacity(level)
	lily_pads[frog_y][frog_left].fog.set_opacity(level)
	lily_pads[frog_y][frog_right].fog.set_opacity(level)
	lily_pads[frog_up][frog_x].fog.set_opacity(level)
	lily_pads[frog_down][frog_x].fog.set_opacity(level)

func _ready() -> void:
	var lily_pos = Vector2(0, 0)
	lily_pads.resize(size.y)
	for i in size.y:
		lily_pads[i].resize(size.x)
		for j in size.x:
			var lp = LILY_PREFAB.instantiate() as LilyPad
			lp.position = lily_pos
			for fpos in flies:
				if Vector2i(j, i) == fpos:
					var fly = FLY_PREFAB.instantiate() as LilyFly
					fly.position.y = -16
					lp.add_child(fly)
					lp.has_fly = true
			lily_pads[i][j] = lp
			add_child(lp)
			
			lily_pos.x += gap.x
		lily_pos.y += gap.y
		lily_pos.x = 0
	set_fog(frog.on_maze.x, frog.on_maze.y, 0)
