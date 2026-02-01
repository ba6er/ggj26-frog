extends Area2D

@onready var sprite = $FlySprite
@onready var sound = $FlySound

func _ready():
	# 1. Tell the manager "I exist"
	GameManager.register_fly()
	
	# 2. Listen for the frog
	body_entered.connect(_on_body_entered)
	sprite.play()

func _on_body_entered(body):
	if body.name == "Frog":
		# 3. Tell manager "I was caught"
		GameManager.collect_fly()
		
		# 4. Frog plays eating sound
		if body.has_method("play_eat_sound"):
			body.play_eat_sound()
		
		# 5. Disappear immediately (don't wait for sound)
		queue_free()
