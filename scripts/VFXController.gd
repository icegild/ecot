extends Node

# ─────────────────────────────────────────────────────────────────────
#  VFXController.gd  –  Reusable particle VFX spawner
#  Godot 4.7  |  Static methods, auto-cleanup
# ─────────────────────────────────────────────────────────────────────
#
#  USAGE
#    VFXController.spawn_dust(position)
#    VFXController.spawn_hit_spark(position, direction)
#    VFXController.spawn_death_burst(position, color)
#    VFXController.spawn_slash_impact(position)
#    VFXController.spawn_heal_effect(position)
#
# ─────────────────────────────────────────────────────────────────────


# ── Preloaded textures ─────────────────────────────────────────────

var _dust_tex: Texture2D
var _dust_light_tex: Texture2D
var _spark_white_tex: Texture2D
var _spark_yellow_tex: Texture2D
var _spark_red_tex: Texture2D
var _death_burst_tex: Texture2D
var _death_burst_dark_tex: Texture2D
var _heal_tex: Texture2D
var _impact_ring_tex: Texture2D
var _circle_energy_tex: Texture2D


func _ready() -> void:
        _dust_tex = preload("res://assets/vfx/particles/dust.png")
        _dust_light_tex = preload("res://assets/vfx/particles/dust_light.png")
        _spark_white_tex = preload("res://assets/vfx/particles/spark_white.png")
        _spark_yellow_tex = preload("res://assets/vfx/particles/spark_yellow.png")
        _spark_red_tex = preload("res://assets/vfx/particles/spark_red.png")
        _death_burst_tex = preload("res://assets/vfx/particles/death_burst.png")
        _death_burst_dark_tex = preload("res://assets/vfx/particles/death_burst_dark.png")
        _heal_tex = preload("res://assets/vfx/particles/heal.png")
        _impact_ring_tex = preload("res://assets/vfx/particles/impact_ring.png")
        _circle_energy_tex = preload("res://assets/vfx/particles/circle_energy.png")


# ═══════════════════════════════════════════════════════════════════════
#  DUST  –  landing, running, wall-slide
# ═══════════════════════════════════════════════════════════════════════

## Spawns a small dust puff (landing, skidding).
static func spawn_dust(pos: Vector2, count: int = 6) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl or not ctrl._dust_tex:
                return
        var particles := _make_particles(
                pos, ctrl._dust_tex, count,
                {
                        "direction": Vector2(-1.0, -0.5),
                        "spread": Vector2(180.0, 120.0),
                        "gravity": Vector2(0, 80),
                        "initial_velocity_min": 30.0,
                        "initial_velocity_max": 80.0,
                        "scale_min": 0.6,
                        "scale_max": 1.4,
                        "lifetime": 0.4,
                        "lifetime_randomness": 0.3,
                        "color": Color(0.7, 0.6, 0.5, 0.6),
                }
        )
        _add_to_scene(particles)


## Spawns running dust trail.
static func spawn_run_dust(pos: Vector2, direction: float = 1.0) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl or not ctrl._dust_light_tex:
                return
        var particles := _make_particles(
                pos, ctrl._dust_light_tex, 2,
                {
                        "direction": Vector2(-direction, -0.8),
                        "spread": Vector2(60.0, 40.0),
                        "gravity": Vector2(0, 20),
                        "initial_velocity_min": 15.0,
                        "initial_velocity_max": 40.0,
                        "scale_min": 0.4,
                        "scale_max": 0.9,
                        "lifetime": 0.3,
                        "lifetime_randomness": 0.4,
                        "color": Color(0.65, 0.55, 0.45, 0.4),
                }
        )
        _add_to_scene(particles)


# ═══════════════════════════════════════════════════════════════════════
#  HIT SPARKS  –  enemy hit, slash impact
# ═══════════════════════════════════════════════════════════════════════

## Spawns white/yellow spark burst when hitting an enemy.
static func spawn_hit_spark(pos: Vector2, dir: float = 1.0) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl:
                return
        # White sparks
        var p1 := _make_particles(
                pos, ctrl._spark_white_tex, 8,
                {
                        "direction": Vector2(dir, -0.3),
                        "spread": Vector2(160.0, 160.0),
                        "gravity": Vector2(0, 200),
                        "initial_velocity_min": 80.0,
                        "initial_velocity_max": 200.0,
                        "scale_min": 0.5,
                        "scale_max": 1.5,
                        "lifetime": 0.25,
                        "lifetime_randomness": 0.3,
                        "color": Color(1.0, 1.0, 0.9, 1.0),
                }
        )
        _add_to_scene(p1)
        # Yellow sparks (delayed slightly by randomness)
        var p2 := _make_particles(
                pos, ctrl._spark_yellow_tex, 5,
                {
                        "direction": Vector2(dir, -0.5),
                        "spread": Vector2(120.0, 120.0),
                        "gravity": Vector2(0, 150),
                        "initial_velocity_min": 60.0,
                        "initial_velocity_max": 150.0,
                        "scale_min": 0.4,
                        "scale_max": 1.2,
                        "lifetime": 0.35,
                        "lifetime_randomness": 0.3,
                        "color": Color(1.0, 0.85, 0.3, 0.9),
                }
        )
        _add_to_scene(p2)


## Spawns red sparks for damage indication.
static func spawn_damage_spark(pos: Vector2) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl:
                return
        var p := _make_particles(
                pos, ctrl._spark_red_tex, 6,
                {
                        "direction": Vector2(0.0, -1.0),
                        "spread": Vector2(200.0, 200.0),
                        "gravity": Vector2(0, 300),
                        "initial_velocity_min": 50.0,
                        "initial_velocity_max": 120.0,
                        "scale_min": 0.5,
                        "scale_max": 1.3,
                        "lifetime": 0.3,
                        "lifetime_randomness": 0.3,
                        "color": Color(1.0, 0.3, 0.2, 1.0),
                }
        )
        _add_to_scene(p)


## Spawns slash impact ring.
static func spawn_slash_impact(pos: Vector2) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl:
                return
        var p := _make_particles(
                pos, ctrl._impact_ring_tex, 3,
                {
                        "direction": Vector2(0.0, 0.0),
                        "spread": Vector2(0.0, 0.0),
                        "gravity": Vector2(0, 0),
                        "initial_velocity_min": 0.0,
                        "initial_velocity_max": 0.0,
                        "scale_min": 0.8,
                        "scale_max": 1.5,
                        "lifetime": 0.2,
                        "lifetime_randomness": 0.1,
                        "color": Color(1.0, 1.0, 1.0, 0.7),
                }
        )
        _add_to_scene(p)


# ═══════════════════════════════════════════════════════════════════════
#  DEATH BURST  –  enemy death
# ═══════════════════════════════════════════════════════════════════════

## Spawns a death burst at position with optional color tint.
static func spawn_death_burst(pos: Vector2, tint: Color = Color.WHITE) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl:
                return
        # Main burst
        var p1 := _make_particles(
                pos, ctrl._death_burst_tex, 12,
                {
                        "direction": Vector2(0.0, -0.5),
                        "spread": Vector2(360.0, 360.0),
                        "gravity": Vector2(0, 100),
                        "initial_velocity_min": 80.0,
                        "initial_velocity_max": 200.0,
                        "scale_min": 0.5,
                        "scale_max": 2.0,
                        "lifetime": 0.5,
                        "lifetime_randomness": 0.4,
                        "color": tint,
                }
        )
        _add_to_scene(p1)
        # Dark secondary burst
        var p2 := _make_particles(
                pos, ctrl._death_burst_dark_tex, 8,
                {
                        "direction": Vector2(0.0, -0.3),
                        "spread": Vector2(360.0, 360.0),
                        "gravity": Vector2(0, 60),
                        "initial_velocity_min": 40.0,
                        "initial_velocity_max": 120.0,
                        "scale_min": 0.3,
                        "scale_max": 1.5,
                        "lifetime": 0.7,
                        "lifetime_randomness": 0.5,
                        "color": tint * Color(0.5, 0.3, 0.3, 0.7),
                }
        )
        _add_to_scene(p2)


# ═══════════════════════════════════════════════════════════════════════
#  HEAL  –  player heal effect
# ═══════════════════════════════════════════════════════════════════════

## Spawns rising green cross particles.
static func spawn_heal_effect(pos: Vector2) -> void:
        var ctrl: VFXController = _get_controller()
        if not ctrl:
                return
        var p := _make_particles(
                pos, ctrl._heal_tex, 5,
                {
                        "direction": Vector2(0.0, -1.0),
                        "spread": Vector2(40.0, 20.0),
                        "gravity": Vector2(0, -20),
                        "initial_velocity_min": 30.0,
                        "initial_velocity_max": 60.0,
                        "scale_min": 0.6,
                        "scale_max": 1.2,
                        "lifetime": 0.6,
                        "lifetime_randomness": 0.3,
                        "color": Color(0.3, 1.0, 0.5, 0.8),
                }
        )
        _add_to_scene(p)


# ═══════════════════════════════════════════════════════════════════════
#  INTERNAL HELPERS
# ═══════════════════════════════════════════════════════════════════════

static func _get_controller() -> VFXController:
        var tree := Engine.get_main_loop() as SceneTree
        if not tree:
                return null
        for node: Node in tree.root.get_children():
                if node is VFXController:
                        return node
        return null


static func _make_particles(
                pos: Vector2,
                texture: Texture2D,
                amount: int,
                params: Dictionary
) -> GPUParticles2D:
        var particles := GPUParticles2D.new()
        particles.name = "VFX"
        particles.position = pos
        particles.amount = amount
        particles.one_shot = true
        particles.emitting = true
        particles.explosiveness = 0.8
        particles.randomness = 0.5
        particles.local_coords = false
        # Z-index above most things but below UI
        particles.z_index = 50

        # ── Material ─────────────────────────────────────────────
        var mat := ParticleProcessMaterial.new()
        mat.particle_flag_align_y = false
        mat.particle_flag_rotate_y = false

        var dir2: Vector2 = params.get("direction", Vector2(0, -1))
        var vel_min: float = params.get("initial_velocity_min", 50.0)
        var vel_max: float = params.get("initial_velocity_max", 150.0)
        var avg_speed: float = (vel_min + vel_max) * 0.5
        var dir_len: float = dir2.length()
        if dir_len > 0.001:
                var normalized: Vector2 = dir2 / dir_len
                mat.direction = Vector3(normalized.x * avg_speed, normalized.y * avg_speed, 0.0)
        else:
                mat.direction = Vector3(0.0, -avg_speed, 0.0)

        # Spread (float, degrees)
        var sp: Vector2 = params.get("spread", Vector2(180, 180))
        mat.spread = maxf(sp.x, sp.y)

        var grav: Vector2 = params.get("gravity", Vector2.ZERO)
        mat.gravity = Vector3(grav.x, grav.y, 0.0)

        mat.scale_min = params.get("scale_min", 0.5)
        mat.scale_max = params.get("scale_max", 1.5)

        # Color
        var col: Color = params.get("color", Color.WHITE)
        mat.color_ramp = _make_color_ramp(col)

        # Lifetime
        var lt: float = params.get("lifetime", 0.5)
        mat.lifetime_randomness = params.get("lifetime_randomness", 0.3)

        # Emission shape (small sphere)
        mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
        mat.emission_sphere_radius = 5.0

        particles.process_material = mat

        # Set lifetime (on the GPUParticles2D node, NOT the material)
        particles.lifetime = lt
        particles.texture = texture

        # Store lifetime info for auto-destroy timer
        particles.set_meta("vfx_lt", lt)
        particles.set_meta("vfx_lt_rand", mat.lifetime_randomness)

        return particles


static func _make_color_ramp(base_color: Color) -> GradientTexture1D:
        var gradient := Gradient.new()
        gradient.colors = PackedColorArray([
                Color(base_color.r, base_color.g, base_color.b, 1.0),
                Color(base_color.r, base_color.g, base_color.b, 0.0)
        ])
        gradient.offsets = PackedFloat32Array([0.0, 1.0])
        var tex := GradientTexture1D.new()
        tex.gradient = gradient
        tex.width = 4
        return tex


static func _add_to_scene(particles: GPUParticles2D) -> void:
        var tree := Engine.get_main_loop() as SceneTree
        if not tree or not tree.current_scene:
                return
        tree.current_scene.add_child(particles)
        # Auto-destroy after emission finishes
        var lt_val: float = particles.get_meta("vfx_lt")
        var lt_rand: float = particles.get_meta("vfx_lt_rand")
        var lifetime: float = lt_val * (1.0 + lt_rand) + 0.5
        tree.create_timer(lifetime).timeout.connect(particles.queue_free)
