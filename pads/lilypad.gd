class_name Lilypad extends Area2D

# 1. SIGNALS
signal player_landed(grid_pos)

# 2. CONFIGURATION
# We use this boolean so the Maze knows if it's safe to put a fly here
@export var is_safe_for_fly: bool = true 
# Does this pad sink? (Normal = true, Ice/Poison = false)
@export var sinks_over_time: bool = true
# Optional: Set a custom sprite texture (for regular Sprite2D)
@export var custom_sprite: Texture2D
# Spawn weight - higher = more likely to spawn (used by maze generator)
@export var spawn_weight: float = 2.0

# 3. REFERENCES
@onready var fog_sprite = $Fog # Rename this to FogSprite in editor!
@onready var sink_timer = $SinkTimer
@onready var anim_sprite = $Sprite

# 4. STATE
var grid_position: Vector2
var is_shaking := false

func _ready():
	# Apply custom sprite if set (replaces AnimatedSprite2D with static Sprite2D)
	if custom_sprite:
		var static_sprite = Sprite2D.new()
		static_sprite.texture = custom_sprite
		static_sprite.name = "Sprite"
		anim_sprite.replace_by(static_sprite)
		anim_sprite.queue_free()
		anim_sprite = static_sprite
	
	# Connect signals locally
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	sink_timer.timeout.connect(_on_sink_timeout)
	
	# Start shrouded
	shroud()

# --- FOG LOGIC ---
func reveal():
	fog_sprite.visible = false

func shroud():
	fog_sprite.visible = true

# --- INTERACTION LOGIC ---
func _on_body_entered(body):
	if body.name == "Frog": # Ensure your player is named "Frog"
		# 1. Tell the Maze we are here
		player_landed.emit(grid_position)
		
		# 2. Start Sinking Sequence (if applicable)
		if sinks_over_time:
			start_shaking()

func _on_body_exited(body):
	if body.name == "Frog":
		# If frog jumps away safely, stop the destruction
		stop_shaking()

# --- SINKING LOGIC ---
func start_shaking():
	if not is_shaking:
		is_shaking = true
		sink_timer.start()
		if anim_sprite is AnimatedSprite2D:
			anim_sprite.play("shaking")
			# After 0.5 seconds, switch to more intense shaking
			await get_tree().create_timer(0.5).timeout
			if is_shaking and anim_sprite is AnimatedSprite2D and anim_sprite.sprite_frames.has_animation("more_shaking"):
				anim_sprite.play("more_shaking")

func stop_shaking():
	is_shaking = false
	sink_timer.stop()
	if anim_sprite is AnimatedSprite2D:
		anim_sprite.play("idle")

func _on_sink_timeout():
	# Time is up! 
	print("Glub glub... Pad sank.")
	# Hide the pad visual first
	if anim_sprite:
		anim_sprite.visible = false
	
	# Get the frog
	var frog = get_tree().get_first_node_in_group("player")
	if not frog or not is_instance_valid(frog) or frog.is_dead:
		await get_tree().create_timer(1.0).timeout
		queue_free()
		return
	
	# Check if frog is on this pad
	var distance = frog.global_position.distance_to(global_position)
	if distance >= 30:
		# Frog already left, just delete pad
		await get_tree().create_timer(1.0).timeout
		queue_free()
		return
	
	# Store frog's initial position
	var frog_start_pos = frog.global_position
	
	# Wait for coyote time
	await get_tree().create_timer(0.2).timeout
	
	# Check if frog moved (jumped away) or is now jumping
	if not is_instance_valid(frog) or frog.is_dead:
		await get_tree().create_timer(1.0).timeout
		queue_free()
		return
	
	# If frog moved or is jumping, they escaped!
	if frog.is_jumping or frog.global_position.distance_to(frog_start_pos) > 5:
		print("Frog escaped in time!")
	else:
		# They didn't move, they die
		frog.die()
	
	# Wait a moment then delete the pad
	await get_tree().create_timer(1.0).timeout
	queue_free()
