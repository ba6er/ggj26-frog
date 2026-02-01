extends Node2D
class_name LilyPad

enum LilyType {
	NORMAL,
	ICE,
	SPIKE,
	FLOWER,
}

const WATER_PREFAB := preload("res://scene/water.tscn")

@export var type := LilyType.NORMAL
@export var shake_time: float = 2
@export var fall_time: float = 5

var has_fly := false
var timer: float = 0.0

@onready var fog := $fog
@onready var sprite := $sprite

func _ready() -> void:
	sprite.frame = type

func _process(delta: float) -> void:
	if timer > shake_time:
		sprite.position.x = sin(timer * 77) * 3
		sprite.position.y = cos(timer * 37) * 2
	if timer > fall_time:
		hide()
		var splash := WATER_PREFAB.instantiate() as Splash
		splash.position.x = position.x
		splash.position.y = position.y - 20
		timer = -100
		get_parent().add_child(splash)
		GameManager.player_die()
