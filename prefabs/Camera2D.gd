extends Camera2D

# ─────────────────────────────────────────────────────────────────────
#  Camera2D.gd  –  Horizontal-only follow (no vertical on jump)
#  Godot 4.7  |  Attach to your Camera2D node (child of Player)
# ─────────────────────────────────────────────────────────────────────

var _origin_parent_y: float = 0.0
var _origin_local_y: float = 0.0


func _ready() -> void:
	_origin_parent_y = get_parent().global_position.y
	_origin_local_y = position.y


func _process(_delta: float) -> void:
	# Counteract parent's vertical movement so global Y stays fixed
	var parent_dy: float = get_parent().global_position.y - _origin_parent_y
	position.y = _origin_local_y - parent_dy
