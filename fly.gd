extends Node2D
class_name LilyFly

@export var amplitude := 6
@export var periode := 2.0

var time: float = 0

@onready var sprite := $sprite

func _process(delta: float) -> void:
	sprite.position.y = sin(time * periode) * amplitude
	time += delta
