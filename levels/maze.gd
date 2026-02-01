extends Node2D

# --- CONFIGURATION ---
const COLUMNS = 7
const ROWS = 7
const SPACING = 50  # Distance between pads (pixels)
const FLY_CHANCE = 0.1 # 25% chance to spawn a fly


# --- CONFIGURATION ---
const PADS_FOLDER = "res://pads/" # <--- Put all your pads here!


# --- ASSETS ---
# We start with an empty list. The code will fill this up.
var pad_scenes = [] 

func _ready():
	# 1. LOAD THE PADS DYNAMICALLY
	load_all_pads_from_folder(PADS_FOLDER)
	
	# 2. Safety Check
	if pad_scenes.size() == 0:
		printerr("ERROR: No lilypads found in " + PADS_FOLDER)
		return

	# 3. Build map
	generate_maze()
	call_deferred("update_fog", Vector2(0, 0))

func load_all_pads_from_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# We only want .tscn files (Scenes)
			# We verify it doesn't contain ".remap" (an artifact of exporting games)
			if file_name.ends_with(".tscn"):
				var full_path = path + "/" + file_name
				var loaded_scene = load(full_path)
				
				# Check if it loaded correctly
				if loaded_scene:
					pad_scenes.append(loaded_scene)
					print("Loaded pad: " + file_name)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("An error occurred when trying to access the path: " + path)

func pick_weighted_random_pad() -> PackedScene:
	# Calculate total weight by instantiating temporarily to read spawn_weight
	var total_weight = 0.0
	var weights = []
	for scene in pad_scenes:
		var temp = scene.instantiate()
		# Get spawn_weight - check if it was overridden in _init
		var w = temp.spawn_weight
		weights.append(w)
		total_weight += w
		temp.queue_free()
	
	# Pick random based on weight
	var roll = randf() * total_weight
	var cumulative = 0.0
	for i in range(pad_scenes.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return pad_scenes[i]
	return pad_scenes[0]

# --- ASSETS (Code Only - No Dragging) ---
# Make sure these paths match exactly where you saved your scene

var fly_scene = preload("res://objects/Fly.tscn")

# --- STATE ---
# Dictionary to store the grid: { Vector2(x,y): pad_node }
var grid_pads = {} 



func spawn_pad(x: int, y: int, offset):
	# 1. Pick a weighted random pad type
	var chosen_scene = pick_weighted_random_pad()
	
	# OPTIONAL: Force the starting pad (0,0) to ALWAYS be Normal/Safe
	if x == 0 and y == 0:
		for scene in pad_scenes:
			var temp = scene.instantiate()
			if temp.is_safe_for_fly:
				chosen_scene = scene
				temp.queue_free()
				break
			temp.queue_free()
	
	# 2. Create the Pad Instance
	var new_pad = chosen_scene.instantiate()
	add_child(new_pad)
	
	# 3. Position it
	var grid_pos = Vector2(x, y)
	
		# --- NEW POSITION LOGIC ---
	# We take the standard position and subtract the offset
	var half_pad = Vector2(SPACING / 2.0, SPACING / 2.0)
	
	new_pad.position = offset + (grid_pos * SPACING) + half_pad
	
	# ... (Keep your grid_pads storage and fog logic) ...

	
	new_pad.grid_position = grid_pos
	

	# 4. Store in Dictionary for Fog Logic
	grid_pads[grid_pos] = new_pad
	new_pad.player_landed.connect(update_fog)

	# --- IMPORTANT: Move Frog to Start ---
	# If this is the very first pad (0,0), move the frog here!
	if x == 0 and y == 0:
		var frog = get_node_or_null("Frog") # Try to find a node named "Frog"
		if frog:
			frog.position = new_pad.position
		else:
			print("ERROR: Could not find node named 'Frog' in Maze scene.")
	
	# 5. Try to Add a Fly
	# We check the variable 'is_safe_for_fly' inside the pad instance
	if new_pad.is_safe_for_fly:
		# Don't spawn fly on the very first pad (0,0)
		if (x != 0 or y != 0) and randf() < FLY_CHANCE:
			add_fly_to(new_pad)


func generate_maze():
	# 1. Get the screen size automatically (640x360)
	var screen_size = get_viewport_rect().size
	
	# 2. Calculate total size of the maze
	var total_width = COLUMNS * SPACING
	var total_height = ROWS * SPACING
	
	# 3. Calculate the Top-Left corner where the maze should start
	# We divide the empty space by 2 to get the margins
	var start_x = (screen_size.x - total_width) / 2
	var start_y = (screen_size.y - total_height) / 2
	
	var start_offset = Vector2(start_x, start_y)

	for x in range(COLUMNS):
		for y in range(ROWS):
			spawn_pad(x, y, start_offset)


func add_fly_to(pad):
	var fly = fly_scene.instantiate()
	pad.add_child(fly)
	
	# If your pad has a Marker2D named "FlySpot", put the fly there
	if pad.has_node("FlySpot"):
		fly.position = pad.get_node("FlySpot").position
	else:
		# Fallback: Just put it slightly above center
		fly.position = Vector2(0, -20)

# --- FOG OF WAR LOGIC ---
func update_fog(frog_grid_pos: Vector2):
	# 1. Shroud (Hide) EVERYTHING first
	for pos in grid_pads:
		if is_instance_valid(grid_pads[pos]):
			grid_pads[pos].shroud()
		
	# 2. Calculate neighbors to Reveal
	# (Center, Up, Down, Left, Right)
	var neighbors = [
		Vector2(0, 0),
		Vector2(0, -1),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(1, 0)
	]
	
	# 3. Reveal them if they exist
	for offset in neighbors:
		var target = frog_grid_pos + offset
		if grid_pads.has(target) and is_instance_valid(grid_pads[target]):
			grid_pads[target].reveal()

# Called by flower pads to reveal a larger area
func reveal_flower_area(center_pos: Vector2):
	# 3x3 area + 2 tiles in each cardinal direction
	var flower_offsets = [
		# 3x3 corners (not covered by normal reveal)
		Vector2(-1, -1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(1, 1),
		# 2 tiles in each direction
		Vector2(0, -2), Vector2(0, 2),
		Vector2(-2, 0), Vector2(2, 0)
	]
	
	for offset in flower_offsets:
		var target = center_pos + offset
		if grid_pads.has(target) and is_instance_valid(grid_pads[target]):
			grid_pads[target].reveal()
