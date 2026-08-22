extends Node2D
# ─────────────────────────────────────────────────────────────────────
#  MeleeSlash.gd  –  Texture-based slash VFX tinted by skin colors
#  Godot 4.7  |  Spawned by player_walk.gd on melee (X key)
# ─────────────────────────────────────────────────────────────────────
#
#  Uses a pre-made transparent slash texture (assets/vfx/slash.png)
#  tinted at runtime via modulate.  No procedural polygons.
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
const SWEEP_ANGLE_MAX: float = 120.0   # degrees the slash rotates through
const SCALE_START: float = 0.5
const SCALE_PEAK: float = 1.3
const SCALE_END: float = 1.0


# ── Internal ─────────────────────────────────────────────────────

var _facing: float = 1.0
var _colors: Array = [Color.WHITE, Color.GRAY, Color.LIGHT_GRAY]
var _timer: float = 0.0
var _main_sprite: Sprite2D
var _glow_sprite: Sprite2D
var _core_sprite: Sprite2D
var _slash_tex: Texture2D


# ═══════════════════════════════════════════════════════════════════
#  INIT
# ═══════════════════════════════════════════════════════════════════

func _init(facing: float, skin_name: String) -> void:
	_facing = facing
	if SKIN_COLORS.has(skin_name):
		_colors = SKIN_COLORS[skin_name]


func _ready() -> void:
	z_index = 10

	# Load the transparent slash texture once
	_slash_tex = load("res://assets/vfx/slash.png")
	if not _slash_tex:
		push_warning("MeleeSlash: failed to load res://assets/vfx/slash.png")
		queue_free()
		return

	var base_size: Vector2 = _slash_tex.get_size()

	# ── Glow layer (larger, softer) ────────────────────────────────
	_glow_sprite = Sprite2D.new()
	_glow_sprite.texture = _slash_tex
	_glow_sprite.centered = true
	_glow_sprite.modulate = _colors[1] * Color(1, 1, 1, 0.25)
	_glow_sprite.scale = Vector2(1.6, 1.6)
	_glow_sprite.position = Vector2(_facing * 25.0, -15.0)
	add_child(_glow_sprite)

	# ── Main slash layer ───────────────────────────────────────────
	_main_sprite = Sprite2D.new()
	_main_sprite.texture = _slash_tex
	_main_sprite.centered = true
	_main_sprite.modulate = _colors[0] * Color(1, 1, 1, 0.95)
	_main_sprite.scale = Vector2(SCALE_START, SCALE_START)
	_main_sprite.position = Vector2(_facing * 25.0, -15.0)
	add_child(_main_sprite)

	# ── Core bright layer (smaller, brighter accent) ───────────────
	_core_sprite = Sprite2D.new()
	_core_sprite.texture = _slash_tex
	_core_sprite.centered = true
	_core_sprite.modulate = _colors[2] * Color(1, 1, 1, 0.7)
	_core_sprite.scale = Vector2(SCALE_START * 0.6, SCALE_START * 0.6)
	_core_sprite.position = Vector2(_facing * 25.0, -15.0)
	add_child(_core_sprite)

	# Flip horizontally when facing left
	if _facing < 0:
		_glow_sprite.flip_h = true
		_main_sprite.flip_h = true
		_core_sprite.flip_h = true


# ═══════════════════════════════════════════════════════════════════
#  LOOP
# ═══════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	_timer += delta
	var t: float = clampf(_timer / SLASH_DURATION, 0.0, 1.0)

	# Ease-out
	var eased: float = 1.0 - (1.0 - t) * (1.0 - t)

	if t >= 1.0:
		queue_free()
		return

	_animate_slash(eased, t)


# ═══════════════════════════════════════════════════════════════════
#  ANIMATION
# ═══════════════════════════════════════════════════════════════════

func _animate_slash(progress: float, raw_t: float) -> void:
	# Rotation: sweep through arc
	var start_rot: float = -SWEEP_ANGLE_MAX * 0.5
	var rotation_deg: float = start_rot + progress * SWEEP_ANGLE_MAX
	if _facing < 0:
		rotation_deg = -rotation_deg

	# Scale: quick expand then settle
	var s: float
	if raw_t < 0.2:
		s = lerpf(SCALE_START, SCALE_PEAK, raw_t / 0.2)
	else:
		s = lerpf(SCALE_PEAK, SCALE_END, (raw_t - 0.2) / 0.8)

	# Fade out in last 35%
	var alpha: float = 1.0
	if raw_t > 0.65:
		alpha = 1.0 - ((raw_t - 0.65) / 0.35)

	# Apply to main sprite
	_main_sprite.rotation_degrees = rotation_deg
	_main_sprite.scale = Vector2(s, s)
	_main_sprite.modulate = _colors[0] * Color(1, 1, 1, alpha * 0.95)

	# Glow follows with offset
	_glow_sprite.rotation_degrees = rotation_deg
	_glow_sprite.scale = Vector2(s * 1.6, s * 1.6)
	_glow_sprite.modulate = _colors[1] * Color(1, 1, 1, alpha * 0.25)

	# Core follows tighter
	_core_sprite.rotation_degrees = rotation_deg
	_core_sprite.scale = Vector2(s * 0.6, s * 0.6)
	_core_sprite.modulate = _colors[2] * Color(1, 1, 1, alpha * 0.7)
