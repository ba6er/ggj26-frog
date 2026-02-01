extends Lilypad

# Reference to death animation sprite
@onready var death_anim = $DeathSprite

func _ready():
	# Set the custom sprite before calling parent _ready
	custom_sprite = preload("res://asset/spike.png")
	
	# Run the parent's ready setup (which will apply the sprite)
	super._ready()
	
	# Override settings
	is_safe_for_fly = false
	sinks_over_time = false
	
	# Hide death animation initially and set up clipping
	if death_anim:
		death_anim.visible = false
		# Use clip_children on parent to crop the animation
		# Or position it so only 50x50 shows from the left side
		death_anim.centered = true

# Override the enter logic
func _on_body_entered(body):
	# Still do the fog reveal (call parent logic)
	super._on_body_entered(body)
	
	if body.name == "Frog":
		# Custom Spike Logic:
		print("Frog stepped on spikes!")
		
		# Hide frog and play death animation on spike
		body.set_process(false)
		body.hide()
		
		# Play death animation on the spike pad
		if death_anim:
			death_anim.visible = true
			death_anim.play("default")
			await death_anim.animation_finished
		
		# Reload scene
		get_tree().reload_current_scene()
