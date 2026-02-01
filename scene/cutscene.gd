extends Control

var timer: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= 35:
		GameManager.play_level(GameManager.mazes[0] as Array[String])
