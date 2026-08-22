extends Node2D
# ─────────────────────────────────────────────────────────────────────
#  MeleeSlash.gd  –  Procedural arc-slash VFX tied to skin colors
#  Godot 4.7  |  Spawned by player_walk.gd on melee (X key)
# ─────────────────────────────────────────────────────────────────────
#
#  USAGE
#    var slash = MeleeSlash.new(facing_direction, skin_name)
#    add_child(slash)
#    slash spawns, animates, and queue_frees itself.
#
# ─────────────────────────────────────────────────────────────────────


# ── Skin color palette ─────────────────────────────────────────────
#  Each entry: [primary, secondary, tertiary]

const SKIN_COLORS: Dictionary = {
	"blood": [
		Color("#ff2233"),   # red
		Color("#cc0011"),   # darker red
		Color("#ff6666"),   # light red
	],
	"dark": [
		Color("#1a0a2e"),   # deep black-purple
		Color("#3d1a6e"),   # purple shade
		Color("#5c2d91"),   # lighter purple
	],
	"electricity": [
		Color("#ffdd00"),   # yellow
		Color("#1a1a1a"),   # black shade
		Color("#ffaa00"),   # orange-yellow
	],
	"fairy": [
		Color("#ff69b4"),   # hot pink
		Color("#ff8ecf"),   # light pink
		Color("#d63384"),   # deep pink
	],
	"moon": [
		Color("#1a1a4e"),   # dark blue
		Color("#ffd700"),   # yellow
		Color("#2a2a6e"),   # medium dark blue
	],
	"shell": [
		Color("#0077b6"),   # ocean blue
		Color("#00b4d8"),   # lighter ocean
		Color("#023e8a"),   # deep ocean
	],
	"time": [
		Color("#8b5e3c"),   # brown
		Color("#d4a843"),   # yellow-brown
		Color("#6b3f1f"),   # dark brown
	],
	"vine": [
		Color("#228b22"),   # green
		Color("#145214"),   # dark green
		Color("#3cb043"),   # lighter green
	],
}


# ── Config ───────────────────────────────────────────────────────

const SLASH_DURATION: float = 0.3
const ARC_RADIUS: float = 70.0
const ARC_THICKNESS: float = 8.0
const ARC_SPAN: float = 1.8   # radians (~103 degrees)


# ── Internal ─────────────────────────────────────────────────────

var _facing: float = 1.0
var _colors: Array = [Color.WHITE, Color.GRAY, Color.LIGHT_GRAY]
var _timer: float = 0.0
var _slash_polygon: Polygon2D


# ═══════════════════════════════════════════════════════════════════
#  INIT
# ═══════════════════════════════════════════════════════════════════

func _init(facing: float, skin_name: String) -> void:
	_facing = facing
	if SKIN_COLORS.has(skin_name):
		_colors = SKIN_COLORS[skin_name]


func _ready() -> void:
	z_index = 10

	# Main slash polygon
	_slash_polygon = Polygon2D.new()
	_slash_polygon.color = Color.TRANSPARENT
	add_child(_slash_polygon)

	# Glow layer (wider, more transparent)
	var glow = Polygon2D.new()
	glow.name = "Glow"
	glow.color = _colors[0] * Color(1, 1, 1, 0.25)
	_slash_polygon.add_child(glow)

	# Inner bright edge
	var inner = Polygon2D.new()
	inner.name = "Inner"
	inner.color = _colors[2] * Color(1, 1, 1, 0.6)
	_slash_polygon.add_child(inner)


# ═══════════════════════════════════════════════════════════════════
#  LOOP
# ═══════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	_timer += delta
	var t: float = clampf(_timer / SLASH_DURATION, 0.0, 1.0)

	# Ease-out for smooth deceleration
	var eased_t: float = 1.0 - (1.0 - t) * (1.0 - t)

	if t >= 1.0:
		queue_free()
		return

	_draw_slash(eased_t, t)


# ═══════════════════════════════════════════════════════════════════
#  DRAWING
# ═══════════════════════════════════════════════════════════════════

func _draw_slash(progress: float, raw_t: float) -> void:
	# Arc sweeps from back-top to front-bottom
	var start_angle: float = (-0.9 + progress * ARC_SPAN) * _facing
	var end_angle: float = (-0.9 + (progress + 0.45) * ARC_SPAN) * _facing
	var sweep: float = (end_angle - start_angle) * 0.5
	var mid_angle: float = (start_angle + end_angle) * 0.5

	# Expand radius slightly during swing
	var radius: float = ARC_RADIUS * (0.8 + 0.2 * sin(progress * PI))

	# Fade out in last 40%
	var alpha: float = 1.0
	if raw_t > 0.6:
		alpha = 1.0 - ((raw_t - 0.6) / 0.4)

	# Build arc polygon points
	var points := _build_arc_points(mid_angle, sweep, radius)
	if points.size() < 3:
		return

	# Main slash
	_slash_polygon.polygon = points
	_slash_polygon.color = _colors[0] * Color(1, 1, 1, alpha * 0.9)
	_slash_polygon.position = Vector2.ZERO

	# Glow (wider arc, softer)
	var glow_points := _build_arc_points(mid_angle, sweep * 1.15, radius * 1.12)
	var glow_node: Polygon2D = _slash_polygon.get_node("Glow")
	if glow_node and glow_points.size() >= 3:
		glow_node.polygon = glow_points
		glow_node.color = _colors[1] * Color(1, 1, 1, alpha * 0.3)

	# Inner bright edge (thinner arc)
	var inner_points := _build_arc_points(mid_angle, sweep * 0.6, radius * 0.7)
	var inner_node: Polygon2D = _slash_polygon.get_node("Inner")
	if inner_node and inner_points.size() >= 3:
		inner_node.polygon = inner_points
		inner_node.color = _colors[2] * Color(1, 1, 1, alpha * 0.7)


## Generates polygon vertices for an arc segment
func _build_arc_points(center_angle: float, half_span: float, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segments: int = 12
	var outer_r: float = radius
	var inner_r: float = radius * 0.35

	# Outer arc (left to right)
	for i: int in range(segments + 1):
		var frac: float = float(i) / float(segments)
		var angle: float = center_angle - half_span + frac * half_span * 2.0
		points.append(Vector2(cos(angle) * outer_r, sin(angle) * outer_r))

	# Inner arc (right to left, to close the shape)
	for i: int in range(segments, -1, -1):
		var frac: float = float(i) / float(segments)
		var angle: float = center_angle - half_span + frac * half_span * 2.0
		points.append(Vector2(cos(angle) * inner_r, sin(angle) * inner_r))

	# Offset the whole slash forward and slightly up from player center
	var offset := Vector2(_facing * 25.0, -15.0)
	for i: int in range(points.size()):
		points[i] += offset

	return points
