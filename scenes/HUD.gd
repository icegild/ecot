extends CanvasLayer

# ─────────────────────────────────────────────────────────────────────
#  HUD.gd  –  Circular HUD with extending HP/MP bars
#  Godot 4.7  |  Strict-typed, zero warnings
# ─────────────────────────────────────────────────────────────────────
#
#  SETUP
#    1. Create a CanvasLayer node in your scene
#    2. Attach this script to it
#    3. Make sure your player is in the "player" group
#    4. Later: assign player_portrait in the Inspector for skin texture
#
# ─────────────────────────────────────────────────────────────────────


# ── Exports ──────────────────────────────────────────────────────────

@export_group("Layout")
@export var margin_x: int = 30
@export var margin_y: int = 30
@export var circle_radius: int = 36
@export var bar_width: int = 120
@export var bar_height: int = 10
@export var bar_gap: int = 6

@export_group("Colors")
@export var health_color: Color = Color("#ff4757")
@export var health_bg: Color = Color("#3a1515")
@export var mana_color: Color = Color("#3b9eff")
@export var mana_bg: Color = Color("#15253a")
@export var ring_color: Color = Color("#6a6d7e")
@export var circle_fill: Color = Color("#0e0e1a")
@export var text_color: Color = Color("#e0e0e0")

@export_group("Portrait")
@export var player_portrait: Texture2D = null

@export_group("Animation")
@export var smooth_speed: float = 8.0


# ── Internal ────────────────────────────────────────────────────────

var panel: Control = null
var player_ref: CharacterBody2D = null
var stats_component: Node = null
var display_hp: float = 1.0   # 0.0 – 1.0
var display_mp: float = 1.0   # 0.0 – 1.0


# ═══════════════════════════════════════════════════════════════════════
#  LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

func _ready() -> void:
		# Force this layer ABOVE everything else
		layer = 100
		_build_ui()
		print("[HUD] CanvasLayer ready, layer=100, drawing at bottom-right")
		# Give the scene tree a frame to settle, then look for player
		await get_tree().process_frame
		_find_player()


func _process(delta: float) -> void:
		# Always try to find player if we don't have one
		if not player_ref or not is_instance_valid(player_ref):
				player_ref = null
				stats_component = null
				_find_player()

		# Smooth lerp toward target values
		var target_hp: float = 1.0
		var target_mp: float = 1.0
		var hp_text: String = "100/100"
		var mp_text: String = "100/100"

		if stats_component and is_instance_valid(stats_component):
				target_hp = stats_component.get_health_percent() / 100.0
				target_mp = stats_component.get_energy_percent() / 100.0
				hp_text = stats_component.get_health_string()
				mp_text = stats_component.get_energy_string()

		display_hp = lerpf(display_hp, target_hp, smooth_speed * delta)
		display_mp = lerpf(display_mp, target_mp, smooth_speed * delta)

		if absf(display_hp - target_hp) < 0.005:
				display_hp = target_hp
		if absf(display_mp - target_mp) < 0.005:
				display_mp = target_mp

		# ALWAYS redraw, every frame, no matter what
		if panel:
				panel.queue_redraw()


# ═══════════════════════════════════════════════════════════════════════
#  UI CONSTRUCTION  –  single Control, everything drawn in _draw
# ═══════════════════════════════════════════════════════════════════════

func _build_ui() -> void:
		var diam: int = circle_radius * 2
		var total_w: int = diam + 14 + bar_width + 50
		var total_h: int = diam

		panel = Control.new()
		panel.name = "HUDPanel"
		panel.anchor_right = 1.0
		panel.anchor_bottom = 1.0
		panel.offset_left = float(-(margin_x + total_w))
		panel.offset_top = float(-(margin_y + total_h))
		panel.offset_right = float(-margin_x)
		panel.offset_bottom = float(-margin_y)
		panel.custom_minimum_size = Vector2(total_w, total_h)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)

		panel.draw.connect(_on_panel_draw)


# ═══════════════════════════════════════════════════════════════════════
#  DRAWING  –  all visuals in one callback
# ═══════════════════════════════════════════════════════════════════════

func _on_panel_draw() -> void:
		var diam: int = circle_radius * 2
		var cx: float = float(circle_radius)
		var cy: float = float(circle_radius)
		var r: float = float(circle_radius)

		# ── 1. Portrait circle ──────────────────────────────────────────
		# Dark fill
		panel.draw_circle(Vector2(cx, cy), r, circle_fill)

		# Portrait texture (if assigned)
		if player_portrait:
				var inset: float = 3.0
				panel.draw_texture_rect(
						player_portrait,
						Rect2(cx - r + inset, cy - r + inset, (r - inset) * 2.0, (r - inset) * 2.0),
						false
				)

		# Outer ring
		panel.draw_arc(Vector2(cx, cy), r, 0.0, TAU, 64, ring_color, 2.0, true)

		# Inner ring
		panel.draw_arc(Vector2(cx, cy), r - 3.0, 0.0, TAU, 48, ring_color * 0.3, 1.0, true)

		# Tick marks
		var tick_count: int = 12
		var i: int = 0
		while i < tick_count:
				var angle: float = float(i) * TAU / float(tick_count)
				var is_major: bool = (i % 3 == 0)
				var inner_r: float = r + 1.0
				var outer_r: float = r + (5.0 if is_major else 3.0)
				var x1: float = cx + cos(angle) * inner_r
				var y1: float = cy + sin(angle) * inner_r
				var x2: float = cx + cos(angle) * outer_r
				var y2: float = cy + sin(angle) * outer_r
				var tick_col: Color = ring_color * (0.8 if is_major else 0.35)
				var tick_w: float = 1.0 if is_major else 0.5
				panel.draw_line(Vector2(x1, y1), Vector2(x2, y2), tick_col, tick_w)
				i += 1

		# ── 2. Connecting lines from circle to bars ─────────────────────
		var bar_x: float = float(diam + 14)
		var bars_h: float = float(bar_height * 2 + bar_gap)
		var bars_y: float = cy - bars_h / 2.0
		var hp_cy: float = bars_y + float(bar_height) / 2.0
		var mp_cy: float = bars_y + float(bar_height + bar_gap) + float(bar_height) / 2.0

		panel.draw_line(Vector2(r + 2, cy - 5.0), Vector2(bar_x - 2.0, hp_cy), ring_color * 0.4, 1.0)
		panel.draw_line(Vector2(r + 2, cy + 5.0), Vector2(bar_x - 2.0, mp_cy), ring_color * 0.4, 1.0)

		# ── 3. HP bar ──────────────────────────────────────────────────
		var hp_text: String = "100/100"
		if stats_component and is_instance_valid(stats_component):
				hp_text = stats_component.get_health_string()
		_draw_bar(bar_x, bars_y, float(bar_width), float(bar_height), display_hp, health_color, health_bg, "HP", hp_text)

		# ── 4. MP bar ──────────────────────────────────────────────────
		var mp_y: float = bars_y + float(bar_height + bar_gap)
		var mp_text: String = "100/100"
		if stats_component and is_instance_valid(stats_component):
				mp_text = stats_component.get_energy_string()
		_draw_bar(bar_x, mp_y, float(bar_width), float(bar_height), display_mp, mana_color, mana_bg, "MP", mp_text)


func _draw_bar(x: float, y: float, w: float, h: float, pct: float, fill_col: Color, bg_col: Color, label: String, value_text: String) -> void:
		var clamped: float = clampf(pct, 0.0, 1.0)
		var fill_w: float = w * clamped

		# Bar background (filled rect)
		panel.draw_rect(Rect2(x, y, w, h), bg_col, true)

		# Bar fill
		if fill_w > 0.5:
				panel.draw_rect(Rect2(x, y, fill_w, h), fill_col, true)

		# Border outline
		panel.draw_rect(Rect2(x, y, w, h), ring_color * 0.5, false, 1.0)

		# Label text (left side inside bar)
		var font: Font = ThemeDB.fallback_font
		panel.draw_string(font, Vector2(x + 4.0, y + h - 1.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, text_color)

		# Value text (right side, outside bar)
		panel.draw_string(font, Vector2(x + w + 5.0, y + h - 1.0), value_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, text_color)


# ═══════════════════════════════════════════════════════════════════════
#  PLAYER DETECTION
# ═══════════════════════════════════════════════════════════════════════

func _find_player() -> void:
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
				player_ref = players[0] as CharacterBody2D
				if player_ref and player_ref.has_node("HealthAndEnergyComponent"):
						stats_component = player_ref.get_node("HealthAndEnergyComponent")
