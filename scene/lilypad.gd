extends Node2D
class_name LilyPad

enum LilyType {
	NORMAL,
	ICE,
	SPIKE,
	FLOWER,
}

const TIMERS := [
	Vector2(0.25, 1),
	Vector2(100, 200),
	Vector2(100, 200),
	Vector2(800, 900),
]

const WATER_PREFAB := preload("res://scene/water.tscn")

@export var type := LilyType.NORMAL

var has_snake := false
var has_fly := false
var timer: float = 0.0

@onready var fog := $fog
@onready var sprite := $sprite

func _ready() -> void:
	sprite.frame = type

func _process(_delta: float) -> void:
	if timer > TIMERS[type].x:
		sprite.position.x = sin(timer * 77) * 3
		sprite.position.y = cos(timer * 37) * 2
	if timer > TIMERS[type].y:
		hide()
		var splash := WATER_PREFAB.instantiate() as Splash
		splash.position.x = position.x
		splash.position.y = position.y - 20
		timer = -10
		get_parent().add_child(splash)
		GameManager.player_die()
