extends Node2D
class_name LilyPad

enum LilyType {
	NORMAL,
	ICE,
	SPIKE,
	FLOWER,
}

@export var type := LilyType.NORMAL

var has_fly := false

@onready var fog := $fog
@onready var sprite := $sprite

func _ready() -> void:
	sprite.frame = type
