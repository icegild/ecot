extends CanvasLayer

# ─────────────────────────────────────────────────────────────────────
#  HUD.gd  –  Pixel-heart health & energy-drop display
#  Godot 4.7  |  Uses sprite assets from assets/ui/
# ─────────────────────────────────────────────────────────────────────


# ── Exports ──────────────────────────────────────────────────────────

@export_group("Layout")
@export var margin_x: int = 24
@export var margin_y: int = 24
@export var heart_scale: float = 0.55
@export var energy_scale: float = 0.45
@export var spacing: int = 4

@export_group("Hearts")
@export var max_display_hearts: int = 5
@export var hp_per_heart: float = 20.0
@export var heart_full: Texture2D = preload("res://assets/ui/heart_full.png")
@export var heart_half: Texture2D = preload("res://assets/ui/heart_half.png")
@export var heart_empty: Texture2D = preload("res://assets/ui/heart_empty.png")

@export_group("Energy")
@export var max_display_energy: int = 5
@export var ep_per_drop: float = 20.0
@export var energy_full: Texture2D = preload("res://assets/ui/energy_drop.png")
@export var energy_empty: Texture2D = preload("res://assets/ui/energy_empty.png")

@export_group("Animation")
@export var damage_shake_duration: float = 0.3
@export var damage_shake_amount: float = 4.0
@export var heart_pop_scale: float = 1.3
@export var heart_pop_duration: float = 0.15


# ── Internal ────────────────────────────────────────────────────────

var player_ref: CharacterBody2D = null
var stats_component: Node = null
var heart_container: HBoxContainer = null
var energy_container: HBoxContainer = null
var heart_sprites: Array[TextureRect] = []
var energy_sprites: Array[TextureRect] = []
var root_container: VBoxContainer = null
var is_shaking: bool = false


# ═══════════════════════════════════════════════════════════════════════
#  LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

func _ready() -> void:
        layer = 100
        _build_ui()
        # Let scene tree settle, then find player
        await get_tree().process_frame
        _find_player()


# ═══════════════════════════════════════════════════════════════════════
#  UI CONSTRUCTION
# ═══════════════════════════════════════════════════════════════════════

func _build_ui() -> void:
        # Root VBox: hearts on top, energy below
        root_container = VBoxContainer.new()
        root_container.name = "HUDRoot"
        root_container.anchor_left = 0.0
        root_container.anchor_top = 0.0
        root_container.offset_left = float(margin_x)
        root_container.offset_top = float(margin_y)
        root_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
        root_container.add_theme_constant_override("separation", 8)
        add_child(root_container)

        # ── Hearts row ─────────────────────────────────────────────
        heart_container = HBoxContainer.new()
        heart_container.name = "HeartsRow"
        heart_container.add_theme_constant_override("separation", spacing)
        heart_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
        root_container.add_child(heart_container)

        for i in range(max_display_hearts):
                var rect := TextureRect.new()
                rect.name = "Heart%d" % i
                rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                rect.texture = heart_empty
                # Set size based on heart texture
                if heart_empty:
                        var s = heart_empty.get_size() * heart_scale
                        rect.custom_minimum_size = s
                heart_container.add_child(rect)
                heart_sprites.append(rect)

        # ── Energy row ─────────────────────────────────────────────

        energy_container = HBoxContainer.new()
        energy_container.name = "EnergyRow"
        energy_container.add_theme_constant_override("separation", spacing)
        energy_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
        root_container.add_child(energy_container)

        for i in range(max_display_energy):
                var rect := TextureRect.new()
                rect.name = "Energy%d" % i
                rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                rect.texture = energy_empty
                if energy_empty:
                        var s = energy_empty.get_size() * energy_scale
                        rect.custom_minimum_size = s
                energy_container.add_child(rect)
                energy_sprites.append(rect)

        # Initial update
        _update_hearts()
        _update_energy()


# ═══════════════════════════════════════════════════════════════════════
#  DISPLAY UPDATE
# ═══════════════════════════════════════════════════════════════════════

func _update_hearts() -> void:
        if not stats_component or not is_instance_valid(stats_component):
                return

        var hp: float = stats_component.get_health()
        var remaining: float = hp

        for i in range(max_display_hearts):
                var seg: float = hp_per_heart
                var val: float = minf(remaining, seg)
                remaining -= seg

                if val >= seg:
                        heart_sprites[i].texture = heart_full
                elif val >= seg * 0.5:
                        heart_sprites[i].texture = heart_half
                else:
                        heart_sprites[i].texture = heart_empty


func _update_energy() -> void:
        if not stats_component or not is_instance_valid(stats_component):
                return

        var ep: float = stats_component.get_energy()
        var remaining: float = ep

        for i in range(max_display_energy):
                var seg: float = ep_per_drop
                var val: float = minf(remaining, seg)
                remaining -= seg

                if val >= seg * 0.5:
                        energy_sprites[i].texture = energy_full
                else:
                        energy_sprites[i].texture = energy_empty


# ═══════════════════════════════════════════════════════════════════════
#  DAMAGE ANIMATION
# ═══════════════════════════════════════════════════════════════════════

func _on_damage_taken(amount: float, _source: Node) -> void:
        # Shake the HUD container
        if is_shaking:
                return
        is_shaking = true
        var orig_pos: Vector2 = root_container.position
        var elapsed: float = 0.0
        while elapsed < damage_shake_duration:
                var offset_x: float = randf_range(-damage_shake_amount, damage_shake_amount)
                root_container.position = orig_pos + Vector2(offset_x, 0.0)
                await get_tree().process_frame
                elapsed += get_process_delta_time()
        root_container.position = orig_pos
        is_shaking = false

        # Pop animation on lost hearts
        _update_hearts()
        for sprite in heart_sprites:
                if sprite.texture == heart_empty:
                        _pop_sprite(sprite)


func _pop_sprite(sprite: TextureRect) -> void:
        var tween := create_tween()
        tween.tween_property(sprite, "scale", Vector2(heart_pop_scale, heart_pop_scale), heart_pop_duration * 0.5)
        tween.tween_property(sprite, "scale", Vector2.ONE, heart_pop_duration * 0.5)


# ═══════════════════════════════════════════════════════════════════════
#  PLAYER DETECTION & SIGNALS
# ═══════════════════════════════════════════════════════════════════════

func _find_player() -> void:
        var players: Array[Node] = get_tree().get_nodes_in_group("player")
        if players.size() > 0:
                player_ref = players[0] as CharacterBody2D
                if player_ref and player_ref.has_node("HealthAndEnergyComponent"):
                        stats_component = player_ref.get_node("HealthAndEnergyComponent")
                        # Connect signals
                        if not stats_component.health_changed.is_connected(_update_hearts):
                                stats_component.health_changed.connect(_update_hearts)
                        if not stats_component.energy_changed.is_connected(_update_energy):
                                stats_component.energy_changed.connect(_update_energy)
                        if not stats_component.damage_taken.is_connected(_on_damage_taken):
                                stats_component.damage_taken.connect(_on_damage_taken)
                        # Initial update
                        _update_hearts()
                        _update_energy()
                        print("[HUD] Connected to player stats component")


func _process(_delta: float) -> void:
        # Re-find player if lost
        if not player_ref or not is_instance_valid(player_ref):
                player_ref = null
                stats_component = null
                _find_player()
