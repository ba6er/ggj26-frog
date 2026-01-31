extends Node2D
class_name LilyPad

enum LilyType {
	NORMAL,
	TIMED,
	SPIKE,
	ICE,
	FLOWER,
}

@onready var fog := $fog

var has_fly := false
