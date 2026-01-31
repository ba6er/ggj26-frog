extends Node2D
class_name LilyMaze

@export var size: Vector2i = Vector2i(7, 7)
@export var gap: Vector2i = Vector2i(50, 50)

const LILY_PREFAB := preload("res://scene/lilypad.tscn")
var lily_pads: Array[Array]

func _ready() -> void:
	var lily_pos = Vector2(0, 0)
	lily_pads.resize(size.y)
	for i in size.y:
		lily_pads[i].resize(size.x)
		for j in size.x:
			var lp = LILY_PREFAB.instantiate() as LilyPad
			lp.position = lily_pos
			lily_pads[i][j] = lp
			add_child(lp)
			lily_pos.x += gap.x
		lily_pos.y += gap.y
		lily_pos.x = 0

func _process(delta: float) -> void:
	pass
