extends AnimatedSprite2D
class_name Splash

func _ready() -> void:
	play("default")
	await animation_finished
	queue_free()
