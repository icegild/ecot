extends Node2D
# ─────────────────────────────────────────────────────────────────────
#  MeleeSlash.gd  –  Sharp pointed arc-slash VFX tied to skin colors
#  Godot 4.7  |  Spawned by player_walk.gd on melee (X key)
# ─────────────────────────────────────────────────────────────────────
#
#  The slash is a thin crescent / leaf shape:
#    – pointed (zero width) at both tips
#    – maximum thickness at the arc midpoint
#    – no rounded edges
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

const SLASH_DURATION: float = 0.25
const ARC_RADIUS: float = 70.0
const ARC_MAX_THICKNESS: float = 14.0   # max distance between outer & inner edge
const ARC_SPAN: float = 1.6            # total angular span in radians (~92 deg)
const ARC_SEGMENTS: int = 20           # polygon resolution


# ── Internal ─────────────────────────────────────────────────────

var _facing: float = 1.0
var _colors: Array = [Color.WHITE, Color.GRAY, Color.LIGHT_GRAY]
var _timer: float = 0.0
var _slash_polygon: Polygon2D
var _glow_polygon: Polygon2D
var _inner_polygon: Polygon2D


# ═══════════════════════════════════════════════════════════════════
#  INIT
# ═══════════════════════════════════════════════════════════════════

func _init(facing: float, skin_name: String) -> void:
	_facing = facing
	if SKIN_COLORS.has(skin_name):
		_colors = SKIN_COLORS[skin_name]


func _ready() -> void:
	z_index = 10

	# Main slash
	_slash_polygon = Polygon2D.new()
	_slash_polygon.color = Color.TRANSPARENT
	add_child(_slash_polygon)

	# Glow layer (wider, softer)
	_glow_polygon = Polygon2D.new()
	_glow_polygon.color = Color.TRANSPARENT
	add_child(_glow_polygon)

	# Inner bright edge (thinner, brighter)
	_inner_polygon = Polygon2D.new()
	_inner_polygon.color = Color.TRANSPARENT
	add_child(_inner_polygon)


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
	# The visible arc window sweeps forward during the animation
	var sweep_progress: float = 0.3 + progress * 0.7   # arc grows from 30% to 100% span
	var base_angle: float = -0.8 * _facing               # starting angle (upper-back)
	var visible_span: float = ARC_SPAN * sweep_progress
	var mid_angle: float = base_angle + visible_span * 0.5

	# Radius pulses slightly
	var radius: float = ARC_RADIUS * (0.85 + 0.15 * sin(progress * PI))

	# Fade out in last 35%
	var alpha: float = 1.0
	if raw_t > 0.65:
		alpha = 1.0 - ((raw_t - 0.65) / 0.35)

	# ── Main slash ───────────────────────────────────────────────
	var points := _build_crescent_points(mid_angle, visible_span, radius, ARC_MAX_THICKNESS)
	if points.size() >= 3:
		_slash_polygon.polygon = points
		_slash_polygon.color = _colors[0] * Color(1, 1, 1, alpha * 0.95)

	# ── Glow (wider, softer) ─────────────────────────────────────
	var glow_points := _build_crescent_points(mid_angle, visible_span * 1.1, radius * 1.15, ARC_MAX_THICKNESS * 1.8)
	if glow_points.size() >= 3:
		_glow_polygon.polygon = glow_points
		_glow_polygon.color = _colors[1] * Color(1, 1, 1, alpha * 0.2)

	# ── Inner bright edge (thinner, brighter) ─────────────────────
	var inner_points := _build_crescent_points(mid_angle, visible_span * 0.7, radius * 0.75, ARC_MAX_THICKNESS * 0.4)
	if inner_points.size() >= 3:
		_inner_polygon.polygon = inner_points
		_inner_polygon.color = _colors[2] * Color(1, 1, 1, alpha * 0.8)


## Builds a sharp pointed crescent / leaf shape.
## Thickness follows a sine curve: zero at tips, max at midpoint.
func _build_crescent_points(center_angle: float, span: float, radius: float, max_thickness: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var half_span: float = span * 0.5
	var offset := Vector2(_facing * 25.0, -15.0)

	# Outer edge: from tip-A to tip-B (left to right along arc)
	for i: int in range(ARC_SEGMENTS + 1):
		var frac: float = float(i) / float(ARC_SEGMENTS)  # 0..1
		var angle: float = center_angle - half_span + frac * span

		# Thickness envelope: sin curve → 0 at tips, 1 at center
		var thickness_factor: float = sin(frac * PI)
		var r: float = radius + max_thickness * 0.5 * thickness_factor

		points.append(Vector2(cos(angle) * r, sin(angle) * r) + offset)

	# Inner edge: from tip-B back to tip-A (right to left)
	for i: int in range(ARC_SEGMENTS, -1, -1):
		var frac: float = float(i) / float(ARC_SEGMENTS)
		var angle: float = center_angle - half_span + frac * span

		var thickness_factor: float = sin(frac * PI)
		var r: float = radius - max_thickness * 0.5 * thickness_factor

		points.append(Vector2(cos(angle) * r, sin(angle) * r) + offset)

	return points
