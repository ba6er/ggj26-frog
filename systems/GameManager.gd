extends Node

# SIGNALS
signal exit_unlocked
signal score_updated(current, total)

# STATE
var total_flies_in_level = 0
var collected_flies = 0

func _ready():
	reset_game()

func reset_game():
	total_flies_in_level = 0
	collected_flies = 0

# Called by the Fly script when it spawns
func register_fly():
	total_flies_in_level += 1
	emit_signal("score_updated", collected_flies, total_flies_in_level)

# Called by the Fly script when collected
func collect_fly():
	collected_flies += 1
	print("Fly collected! " + str(collected_flies) + "/" + str(total_flies_in_level))
	
	emit_signal("score_updated", collected_flies, total_flies_in_level)
	
	if collected_flies >= total_flies_in_level:
		unlock_exit()

func unlock_exit():
	print("ALL FLIES COLLECTED! EXIT OPEN!")
	emit_signal("exit_unlocked")
