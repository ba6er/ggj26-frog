extends Lilypad

func _ready():
	# Set the custom sprite before calling parent _ready
	custom_sprite = preload("res://asset/Flower.png")
	
	# Run the parent's ready setup (which will apply the sprite)
	super._ready()
	
	# Override settings
	is_safe_for_fly = true
	sinks_over_time = false

# Override the enter logic
func _on_body_entered(body):
	if body.name == "Frog":
		# 1. Tell the Maze we are here (this triggers fog update)
		player_landed.emit(grid_position)
		
		# 2. Reveal extra tiles in 3x3 area
		# The maze will handle the normal cross pattern,
		# we need to tell it to also reveal the corners and extra distance
		var maze = get_parent()
		if maze and maze.has_method("reveal_flower_area"):
			maze.reveal_flower_area(grid_position)
