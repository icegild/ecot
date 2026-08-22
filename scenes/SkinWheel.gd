extends Control

# ─────────────────────────────────────────────────────────────────────
#  SkinWheel.gd  –  Radial skin selector with animated slice assembly
#  Godot 4.7  |  Production-quality GDScript (strict-typed, zero warnings)
# ─────────────────────────────────────────────────────────────────────
#
#  CONTROLS
#    Hold Ctrl          → slices fly out from centre, staggered
#    Release Ctrl       → slices collapse back and disappear
#    Ctrl + Tab         → cycle selected skin (while visible)
#
#  SETUP
#    1. Attach this script to a Control node in your scene tree.
#    2. Place 64×64 icon PNGs at  res://ui/skin_icons/<name>.png
#       (blood, dark, electricity, fairy, moon, shell, time, vine)
#    3. The wheel auto-centres itself in the viewport.
#
# ─────────────────────────────────────────────────────────────────────


# ── Element catalogue ────────────────────────────────────────────────

const SKINS: PackedStringArray = [
	"blood", "dark", "electricity", "fairy",
	"moon", "shell", "time", "vine",
]

var selected_skin: int = 0


# ── Geometry ─────────────────────────────────────────────────────────

const RADIUS       : float = 340.0  # outer edge of each slice
const INNER_RADIUS : float = 90.0   # inner cutout
const ICON_RADIUS  : float = 250.0  # distance of icons from centre
const ICON_SIZE    : float = 64.0   # icon texture size in pixels


# ── Animation tuning ─────────────────────────────────────────────────

const STAGGER_DELAY  : float = 0.055  # seconds between consecutive slices
const SLIDE_DURATION : float = 0.32   # time for one slice to reach full extension
const POP_IMPULSE    : float = 0.20   # initial velocity kick of the pop spring
const POP_STIFFNESS  : float = 64.0   # spring constant (higher = snappier)
const POP_DAMPING    : float = 12.0   # damping ratio (higher = less bounce)
const COLAPSE_SPEED  : float = 0.24   # collapse is faster than assembly


# ── State machine ────────────────────────────────────────────────────

enum Phase { HIDDEN, ASSEMBLING, IDLE, DISASSEMBLING }
var phase: Phase = Phase.HIDDEN
var anim_clock: float = 0.0

# Per-slice animation data (avoid "scale" — shadows Control.scale)
var progress : Array[float] = []   # 0 = collapsed, 1 = fully extended
var slice_sc : Array[float] = []   # spring-driven scale multiplier
var vel      : Array[float] = []   # spring velocity
var popped   : Array[bool]  = []   # has this slice popped yet?


# ── Colour palettes ──────────────────────────────────────────────────

const FILL_COLORS: Dictionary = {
	"blood":       Color(0.35, 0.08, 0.08, 0.92),
	"dark":        Color(0.16, 0.09, 0.25, 0.92),
	"electricity": Color(0.40, 0.34, 0.06, 0.92),
	"fairy":       Color(0.36, 0.15, 0.34, 0.92),
	"moon":        Color(0.08, 0.17, 0.37, 0.92),
	"shell":       Color(0.08, 0.30, 0.32, 0.92),
	"time":        Color(0.34, 0.29, 0.20, 0.92),
	"vine":        Color(0.08, 0.28, 0.10, 0.92),
}

const GLOW_COLORS: Dictionary = {
	"blood":       Color(0.85, 0.15, 0.15),
	"dark":        Color(0.52, 0.32, 0.90),
	"electricity": Color(1.00, 0.90, 0.18),
	"fairy":       Color(1.00, 0.45, 0.90),
	"moon":        Color(0.50, 0.70, 1.00),
	"shell":       Color(0.25, 0.95, 1.00),
	"time":        Color(0.90, 0.80, 0.60),
	"vine":        Color(0.20, 0.90, 0.30),
}


# ── Icon textures (loaded at runtime) ───────────────────────────────

var icon_tex: Dictionary = {}

func _load_icons() -> void:
	for skin: String in SKINS:
		var path: String = "res://ui/skin_icons/%s.png" % skin
		if ResourceLoader.exists(path):
			icon_tex[skin] = load(path)


# ── Lifecycle ────────────────────────────────────────────────────────

func _ready() -> void:
	# Initialise per-slice arrays
	for i: int in SKINS.size():
		progress.append(0.0)
		slice_sc.append(1.0)
		vel.append(0.0)
		popped.append(false)

	# Centre the wheel in the current viewport
	size = Vector2(800, 800)
	centre_in_viewport()

	# Start hidden
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_load_icons()


func _process(delta: float) -> void:
	match phase:
		Phase.ASSEMBLING:
			_tick_assemble(delta)
		Phase.DISASSEMBLING:
			_tick_disassemble(delta)
		Phase.IDLE:
			_tick_springs(delta)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var ke: InputEventKey = event as InputEventKey
	if ke.echo:
		return

	# ── Ctrl held / released ──
	if ke.keycode == KEY_CTRL:
		if ke.pressed and phase == Phase.HIDDEN:
			_start_assemble()
			get_viewport().set_input_as_handled()
		elif not ke.pressed and phase in [Phase.ASSEMBLING, Phase.IDLE]:
			_start_disassemble()
			get_viewport().set_input_as_handled()
		return

	# ── Ctrl+Tab to cycle ──
	if phase == Phase.IDLE:
		if ke.pressed and ke.keycode == KEY_TAB and ke.ctrl_pressed:
			selected_skin = (selected_skin + 1) % SKINS.size()
			_kick_pop(selected_skin)
			get_viewport().set_input_as_handled()


# ── Public helpers ───────────────────────────────────────────────────

## Re-centre after a viewport resize.
func centre_in_viewport() -> void:
	var vp: Rect2 = get_viewport_rect()
	position = (vp.size - size) / 2.0

## Returns the name of the currently selected skin.
func get_selected() -> String:
	return SKINS[selected_skin]


# ═══════════════════════════════════════════════════════════════════════
#  ASSEMBLY  –  slices fly out from centre, staggered
# ═══════════════════════════════════════════════════════════════════════

func _start_assemble() -> void:
	phase = Phase.ASSEMBLING
	anim_clock = 0.0
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	for i: int in SKINS.size():
		progress[i] = 0.0
		slice_sc[i] = 0.25
		vel[i]      = 0.0
		popped[i]   = false


func _tick_assemble(delta: float) -> void:
	anim_clock += delta
	var all_done: bool = true
	var n: int = SKINS.size()

	for i: int in n:
		var delay: float = float(i) * STAGGER_DELAY
		var local_t: float = anim_clock - delay

		# Slice hasn't started yet
		if local_t <= 0.0:
			progress[i] = 0.0
			slice_sc[i] = 0.25
			all_done = false
			continue

		# Ease-out quart for the radial slide
		var t: float = clampf(local_t / SLIDE_DURATION, 0.0, 1.0)
		var eased: float = 1.0 - pow(1.0 - t, 4.0)
		progress[i] = eased

		# Scale catches up slightly faster than the slide
		var st: float = clampf(local_t / (SLIDE_DURATION * 0.75), 0.0, 1.0)
		slice_sc[i] = 0.25 + 0.75 * (1.0 - pow(1.0 - st, 3.0))

		# Trigger the pop spring the instant the slice reaches full extension
		if t >= 1.0 and not popped[i]:
			popped[i] = true
			_kick_pop(i)

		if t < 1.0:
			all_done = false

	if all_done:
		phase = Phase.IDLE


# ═══════════════════════════════════════════════════════════════════════
#  DISASSEMBLY  –  slices collapse back to centre, reverse stagger
# ═══════════════════════════════════════════════════════════════════════

func _start_disassemble() -> void:
	phase = Phase.DISASSEMBLING
	anim_clock = 0.0

	# Snap any in-flight spring so the collapse looks clean
	for i: int in SKINS.size():
		progress[i] = 1.0
		slice_sc[i] = 1.0
		vel[i]     = 0.0
		popped[i]  = false


func _tick_disassemble(delta: float) -> void:
	anim_clock += delta
	var all_done: bool = true
	var n: int = SKINS.size()

	for i: int in n:
		# Reverse stagger: last slice starts collapsing first
		var delay: float = float(n - 1 - i) * (STAGGER_DELAY * 0.8)
		var local_t: float = anim_clock - delay

		if local_t <= 0.0:
			all_done = false
			continue

		# Ease-in cubic for the collapse
		var t: float = clampf(local_t / COLAPSE_SPEED, 0.0, 1.0)
		var eased: float = t * t * t
		progress[i] = 1.0 - eased
		slice_sc[i] = 1.0 - eased * 0.75

		if t < 1.0:
			all_done = false

	if all_done:
		phase = Phase.HIDDEN
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE


# ═══════════════════════════════════════════════════════════════════════
#  POP SPRING  –  damped harmonic oscillator for the snap effect
# ═══════════════════════════════════════════════════════════════════════

func _kick_pop(index: int) -> void:
	vel[index] += POP_IMPULSE


func _tick_springs(delta: float) -> void:
	for i: int in SKINS.size():
		var disp: float = slice_sc[i] - 1.0
		var accel: float = -POP_STIFFNESS * disp - POP_DAMPING * vel[i]
		vel[i]     += accel * delta
		slice_sc[i] += vel[i] * delta
		slice_sc[i] = clampf(slice_sc[i], 0.1, 2.0)


# ═══════════════════════════════════════════════════════════════════════
#  DRAWING
# ═══════════════════════════════════════════════════════════════════════

func _draw() -> void:
	if phase == Phase.HIDDEN:
		return

	var centre: Vector2 = size / 2.0
	var n: int = SKINS.size()
	var slice_angle: float = TAU / float(n)

	# ── Centre hub (fades in with the first slice) ──
	var hub_alpha: float = _peak_progress() * 0.9
	if hub_alpha > 0.01:
		draw_circle(centre, INNER_RADIUS * _peak_scale(),
			Color(0.05, 0.05, 0.05, hub_alpha))

	# ── Slices ──
	for i: int in range(n):
		var p: float = progress[i]
		if p < 0.005:
			continue

		var sc: float = slice_sc[i]
		var start_a: float = float(i) * slice_angle - PI / 2.0
		var end_a: float = start_a + slice_angle

		# Animated radii: both inner and outer grow from the centre
		var outer_r: float = lerpf(INNER_RADIUS * 0.4, RADIUS, p)
		var inner_r: float = lerpf(4.0, INNER_RADIUS, p)

		# Apply pop-scale around the slice's midpoint radius
		var mid_r: float = (inner_r + outer_r) / 2.0
		var half_span: float = (outer_r - inner_r) / 2.0 * sc
		var draw_in: float = maxf(mid_r - half_span, 1.0)
		var draw_out: float = mid_r + half_span

		# ── Fill colour ──
		var fill_src: Color = FILL_COLORS[SKINS[i]]
		var glow_src: Color = GLOW_COLORS[SKINS[i]]
		var col: Color = fill_src if i != selected_skin else glow_src
		col.a *= p

		draw_colored_polygon(
			_annular_sector(centre, draw_in, draw_out, start_a, end_a),
			col)

		# ── Separator line ──
		var sep_origin: Vector2 = centre + Vector2.from_angle(start_a) * draw_in
		var sep_end: Vector2 = centre + Vector2.from_angle(start_a) * draw_out
		draw_line(sep_origin, sep_end, Color(0.0, 0.0, 0.0, 0.55 * p), 2.5)

		# ── Icon ──
		var mid_a: float = start_a + slice_angle / 2.0
		var icon_r: float = lerpf(INNER_RADIUS * 0.5, ICON_RADIUS, p) * sc
		var icon_pos: Vector2 = centre + Vector2.from_angle(mid_a) * icon_r

		# Selection glow ring
		if i == selected_skin and p > 0.75:
			var ga: float = (p - 0.75) / 0.25 * 0.30
			draw_circle(icon_pos, 54.0 * sc, Color(1.0, 1.0, 1.0, ga))

		# Texture
		var tex: Texture2D = icon_tex.get(SKINS[i])
		if tex:
			var sz: float = ICON_SIZE * sc
			draw_texture_rect(tex,
				Rect2(icon_pos - Vector2.ONE * sz / 2.0, Vector2.ONE * sz),
				false)

		# ── Label ──
		var label: String = SKINS[i].to_upper()
		var font: Font = ThemeDB.fallback_font
		var fsz: int = 16
		var tw: float = font.get_string_size(label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x
		draw_string(font,
			icon_pos + Vector2(-tw / 2.0, 54.0 * sc),
			label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fsz,
			Color(1.0, 1.0, 1.0, p))

	# ── Outer / inner rings ──
	var ring_alpha: float = _peak_progress() * 0.45
	if ring_alpha > 0.01:
		draw_arc(centre, RADIUS, 0, TAU, 96,
			Color(0.8, 0.8, 0.8, ring_alpha), 4)
		draw_arc(centre, INNER_RADIUS, 0, TAU, 96,
			Color(0.8, 0.8, 0.8, ring_alpha * 0.6), 3)


# ── Geometry helper: annular-sector (donut slice) ────────────────────

func _annular_sector(
	centre: Vector2,
	inner_r: float,
	outer_r: float,
	start_a: float,
	end_a: float,
	steps: int = 36,
) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()

	# Outer arc  (start → end)
	for i: int in range(steps + 1):
		var a: float = lerpf(start_a, end_a, float(i) / float(steps))
		pts.append(centre + Vector2.from_angle(a) * outer_r)

	# Inner arc  (end → start, reversed to close the shape)
	for i: int in range(steps, -1, -1):
		var a: float = lerpf(start_a, end_a, float(i) / float(steps))
		pts.append(centre + Vector2.from_angle(a) * inner_r)

	return pts


# ── Utility ──────────────────────────────────────────────────────────

func _peak_progress() -> float:
	var mx: float = 0.0
	for v: float in progress:
		if v > mx:
			mx = v
	return mx


func _peak_scale() -> float:
	var mx: float = 0.0
	for v: float in slice_sc:
		if v > mx:
			mx = v
	return mx
