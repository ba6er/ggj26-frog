extends CharacterBody2D

# --- CONFIGURATION ---
# IMPORTANT: This must match the 'SPACING' in your Maze.gd!
const TILE_SIZE = 50
const JUMP_DURATION = 0.3 # How fast is the jump?

# --- REFERENCES ---
@onready var anim = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var eat_sound = $EatSound

# --- STATE ---
var is_jumping = false
var is_dead = false
var last_direction = Vector2.ZERO # Remember where we faced last
var jump_sounds = []  # Array to hold all jump sound files
var eat_sounds = []  # Array to hold all eat sound files

func _ready():
	# Load all jump sounds from the sounds/frog/jump folder
	var dir = DirAccess.open("res://asset/sounds/frog/jump")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Load audio files (mp3, wav, ogg)
			if file_name.ends_with(".mp3") or file_name.ends_with(".wav") or file_name.ends_with(".ogg"):
				var audio = load("res://asset/sounds/frog/jump/" + file_name)
				if audio:
					jump_sounds.append(audio)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	# Load eat sounds from frog/eat folder
	var eat_dir = DirAccess.open("res://asset/sounds/frog/eat")
	if eat_dir:
		eat_dir.list_dir_begin()
		var eat_file = eat_dir.get_next()
		while eat_file != "":
			if eat_file.ends_with(".mp3") or eat_file.ends_with(".wav") or eat_file.ends_with(".ogg"):
				var audio = load("res://asset/sounds/frog/eat/" + eat_file)
				if audio:
					eat_sounds.append(audio)
			eat_file = eat_dir.get_next()
		eat_dir.list_dir_end()
	
	# Start facing down
	last_direction = Vector2.DOWN
	play_idle_animation()
	# Center the sprite on the frog's position
	anim.centered = true
	# Offset sprite up so frog appears centered (adjust if needed)
	anim.offset = Vector2(0, -14)

func _process(_delta):
	# If we are busy jumping, don't accept input
	if is_jumping:
		return
		
	handle_input()

func handle_input():
	var dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		dir = Vector2(0, -1)
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2(0, 1)
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2(-1, 0)
		anim.flip_h = true # Face left
	elif Input.is_action_pressed("ui_right"):
		dir = Vector2(1, 0)
		anim.flip_h = false # Face right
	
	# If a key was pressed, execute the jump
	if dir != Vector2.ZERO:
		last_direction = dir # Save for bouncy pads
		jump_to(dir)

func jump_to(dir: Vector2):
	is_jumping = true
	
	# Play random jump sound from the loaded sounds
	if jump_sound and jump_sounds.size() > 0:
		jump_sound.stream = jump_sounds.pick_random()
		jump_sound.play()
	
	# 1. Calculate Target
	var start_pos = position
	var target_pos = position + (dir * TILE_SIZE)
	
	# 2. Play directional animation
	var anim_name = "jump"  # fallback
	if dir == Vector2.UP and anim.sprite_frames.has_animation("jump_up"):
		anim_name = "jump_up"
	elif dir == Vector2.DOWN and anim.sprite_frames.has_animation("jump_down"):
		anim_name = "jump_down"
	elif dir == Vector2.LEFT and anim.sprite_frames.has_animation("jump_left"):
		anim_name = "jump_left"
	elif dir == Vector2.RIGHT and anim.sprite_frames.has_animation("jump_right"):
		anim_name = "jump_right"
	
	if anim.sprite_frames.has_animation(anim_name):
		# Calculate speed to match JUMP_DURATION
		var frame_count = anim.sprite_frames.get_frame_count(anim_name)
		var base_fps = anim.sprite_frames.get_animation_speed(anim_name)
		var base_duration = frame_count / base_fps if base_fps > 0 else 1.0
		var speed_scale = base_duration / JUMP_DURATION
		
		anim.speed_scale = speed_scale
		anim.play(anim_name)
	
	# 3. Create a "Tween" to handle smooth movement
	var tween = create_tween()
	
	# Move Position: Slide from A to B
	tween.tween_property(self, "position", target_pos, JUMP_DURATION).set_trans(Tween.TRANS_SINE)
	
	# OPTIONAL: Visual "Hop" (Scale Up/Down)
	# This squeezes the sprite to look like it's jumping high
	var scale_tween = create_tween()
	scale_tween.tween_property(anim, "scale", Vector2(1.2, 1.2), JUMP_DURATION / 2)
	scale_tween.tween_property(anim, "scale", Vector2(1.0, 1.0), JUMP_DURATION / 2)
	
	# 4. Wait for movement tween to finish
	await tween.finished
	
	# 5. Now handle jump completion
	_on_jump_finished()

func _on_jump_finished():
	is_jumping = false
	
	# Reset animation speed
	anim.speed_scale = 1.0
	
	# Don't check if already dead
	if is_dead:
		return
	
	# Check if we landed on any pad
	var landed_on_pad = false
	var areas = get_tree().get_nodes_in_group("pads")
	if areas.size() == 0:
		# Try getting pads from parent (maze)
		var maze = get_parent()
		if maze and maze.has_method("get") and "grid_pads" in maze:
			for pos in maze.grid_pads:
				var pad = maze.grid_pads[pos]
				if is_instance_valid(pad):
					var pad_pos = pad.global_position
					if global_position.distance_to(pad_pos) < 30:
						landed_on_pad = true
						break
	else:
		for pad in areas:
			if is_instance_valid(pad):
				var pad_pos = pad.global_position
				if global_position.distance_to(pad_pos) < 30:
					landed_on_pad = true
					break
	
	if not landed_on_pad:
		# Fell off the map!
		print("Frog fell into the water!")
		die()
		return
	
	play_idle_animation()

# Helper function to play the correct idle animation based on direction
func play_idle_animation():
	var idle_name = "idle"  # fallback
	if last_direction == Vector2.UP and anim.sprite_frames.has_animation("idle_up"):
		idle_name = "idle_up"
	elif last_direction == Vector2.DOWN and anim.sprite_frames.has_animation("idle_down"):
		idle_name = "idle_down"
	elif last_direction == Vector2.LEFT and anim.sprite_frames.has_animation("idle_left"):
		idle_name = "idle_left"
	elif last_direction == Vector2.RIGHT and anim.sprite_frames.has_animation("idle_right"):
		idle_name = "idle_right"
	
	if anim.sprite_frames.has_animation(idle_name):
		anim.play(idle_name)

# --- FUNCTIONS CALLED BY PADS ---

func die():
	# Prevent double death
	if is_dead:
		return
	is_dead = true
	
	print("FROG DIED!")
	set_process(false) # Disable controls
	
	if anim.sprite_frames.has_animation("die"):
		anim.play("die")
		# Wait for animation to finish
		await anim.animation_finished
	else:
		hide() # If no die animation, just vanish
		# Small delay before reload
		await get_tree().create_timer(0.5).timeout
	
	if get_tree():
		get_tree().reload_current_scene()
	# Don't forget to reset GameManager here if needed!
	# GameManager.reset_game()

func jump_again():
	# Called by Bouncy Pads.
	# We wait a split second, then jump in the SAME direction we were moving.
	await get_tree().create_timer(0.1).timeout
	
	if last_direction == Vector2.ZERO:
		last_direction = Vector2(1, 0) # Default right if stationary
		
	jump_to(last_direction)

func bounce_back():
	# Called by Ice Pads.
	# We wait a split second, then jump in the OPPOSITE direction.
	await get_tree().create_timer(0.1).timeout
	
	if last_direction == Vector2.ZERO:
		last_direction = Vector2(1, 0) # Default right if stationary
	
	jump_to(-last_direction)

func play_eat_sound():
	# Called by Fly when collected
	if eat_sound and eat_sounds.size() > 0:
		eat_sound.stream = eat_sounds.pick_random()
		eat_sound.play()
