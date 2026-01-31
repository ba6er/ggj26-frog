extends Sprite2D
class_name LilyFog

static var num_opacity_levels: int = 2
static var time_before_sinking: int = 2

func set_opacity(new_opacity: int) -> void:
	modulate.a = new_opacity

func _ready() -> void:
	set_opacity(num_opacity_levels)
