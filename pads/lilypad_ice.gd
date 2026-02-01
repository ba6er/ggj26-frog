extends Lilypad

func _ready():
	# Set the custom sprite before calling parent _ready
	custom_sprite = preload("res://asset/Ice.png")
	
	# Run the parent's ready setup (which will apply the sprite)
	super._ready()
	
	# Override settings
	is_safe_for_fly = false
	sinks_over_time = false

# Override the enter logic
func _on_body_entered(body):
	# Still do the fog reveal (call parent logic)
	super._on_body_entered(body)
	
	if body.name == "Frog":
		# Slide - jump again in same direction
		print("Frog slipped on ice!")
		body.jump_again()
