extends Control

@export var tick_seconds: float = 0.1
@export var appear_at: float = 0
@export var disappear_at: float = 5

var ttime: float = 0
var time: float = 0
@onready var text := $text
@onready var ap := $audioplayer

func _process(delta: float) -> void:
	time += delta
	
	if time < appear_at:
		return
	if time >= disappear_at:
		queue_free()
	
	ttime += delta
	
	if text.visible_characters >= len(text.text):
		return
	
	if ttime >= tick_seconds:
		text.visible_characters += 1
		ap.play()
		ttime -= tick_seconds
