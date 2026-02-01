extends Node2D
class_name LilyMaze

@export var size: Vector2i = Vector2i(7, 7)
@export var gap: Vector2i = Vector2i(50, 50)

const LILY_PREFAB := preload("res://scene/lilypad.tscn")
const FLY_PREFAB := preload("res://scene/fly.tscn")
var lily_pads: Array[Array]
var num_flies: int = 0

@onready var frog := $frog
@onready var max_fog := LilyFog.num_opacity_levels

func get_lily_type_on(pos: Vector2i) -> LilyPad.LilyType:
	return lily_pads[pos.y][pos.x].type

func try_eat_fly(pos: Vector2i) -> void:
	if lily_pads[pos.y][pos.x].type == LilyPad.LilyType.FLOWER and lily_pads[pos.y][pos.x].has_fly == true:
		lily_pads[pos.y][pos.x].has_fly = false
		lily_pads[pos.y][pos.x].get_child(2).queue_free()
		GameManager.eat_fly()

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

func generate(input: Array[String]) -> void:
	lily_pads.resize(size.y)
	for i in size.y:
		lily_pads[i].resize(size.x)
		for j in size.x:
			var lp := LILY_PREFAB.instantiate() as LilyPad
			lp.position.x = j * gap.x
			lp.position.y = i * gap.y
			var ltype := int(input[i][j])
			if ltype == 9:
				frog.on_maze = Vector2i(j, i)
				frog.position = frog.maze_pos_to_real_pos()
				ltype = 0
			lp.type = ltype
			if (lp.type == LilyPad.LilyType.FLOWER):
				var fly := FLY_PREFAB.instantiate() as LilyFly
				fly.position.y = -16
				lp.add_child(fly)
				lp.has_fly = true
				num_flies += 1
			lily_pads[i][j] = lp
			add_child(lp)
	set_fog(frog.on_maze.x, frog.on_maze.y, 0)

func _ready() -> void:
	num_flies = 0
