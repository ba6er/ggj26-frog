extends Sprite2D
class_name LilyFog

static var num_opacity_levels: int = 2

func set_opacity(new_opacity: int) -> void:
	new_opacity = clamp(new_opacity, 0, num_opacity_levels)
	modulate.a = float(new_opacity) / float(num_opacity_levels)

func _ready() -> void:
	set_opacity(num_opacity_levels)
