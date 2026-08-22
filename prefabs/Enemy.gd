extends CharacterBody2D

# ─────────────────────────────────────────────────────────────────────
#  Enemy.gd  –  Chasing enemy with health, contact damage, patrol AI
#  Godot 4.7  |  Production-quality GDScript (strict-typed, zero warnings)
# ─────────────────────────────────────────────────────────────────────
#
#  SETUP
#    Attach this script to a CharacterBody2D with this child tree:
#
#      Enemy (CharacterBody2D)  ← this script
#      ├── CollisionShape2D      ← CapsuleShape2D
#      ├── HitboxArea (Area2D)   ← contact-damage detector (mask 2)
#      │   └── HitboxShape (CollisionShape2D)
#      └── HealthAndEnergyComponent  ← player_stats_component.gd
#
#  COLLISION LAYERS
#    1 = world (ground / tiles)
#    2 = player
#    3 = enemy
#    Enemy body: layer 4 (enemy only), mask 1 (world only)
#    HitboxArea:  layer 0, mask 2 (player)
#
# ─────────────────────────────────────────────────────────────────────


# ── Signals ──────────────────────────────────────────────────────────

signal enemy_died(enemy: Node)
signal damage_dealt(amount: float, target: Node)


# ── Export groups ─────────────────────────────────────────────────────

@export_group("Movement")
@export var move_speed: float = 120.0
@export var jump_force: float = -350.0

@export_group("Detection")
@export var chase_range: float = 400.0
@export var attack_range: float = 60.0
@export var lose_range: float = 600.0

@export_group("Combat")
@export var max_health: float = 30.0
@export var contact_damage: float = 10.0
@export var knockback_force: float = 200.0
@export var received_knockback_force: float = 250.0
@export var knockback_duration: float = 0.15
@export var damage_cooldown_time: float = 0.5
@export var stomp_damage: float = 15.0
@export var stomp_bounce: float = -300.0

@export_group("Visual")
@export var enemy_color: Color = Color(0.80, 0.20, 0.20)
@export var body_radius: float = 20.0


# ── State machine ────────────────────────────────────────────────────

enum State { IDLE, PATROL, CHASE, DEAD }
var current_state: State = State.IDLE


# ── Internal vars ────────────────────────────────────────────────────

var gravity: float = 0.0
var player_ref: CharacterBody2D = null
var facing_direction: float = 1.0
var patrol_timer: float = 0.0
var patrol_direction: float = 1.0
var damage_cooldown: float = 0.0
var is_dead: bool = false
var knockback_timer: float = 0.0
var knockback_direction: float = 0.0


# ── Node refs ────────────────────────────────────────────────────────

@onready var hitbox_area: Area2D = $HitboxArea
@onready var enemy_sprite: Node2D = get_node_or_null("Sprite2D") if has_node("Sprite2D") else get_node_or_null("AnimatedSprite2D")
@onready var stats: HealthAndEnergyComponent = $HealthAndEnergyComponent

# ═══════════════════════════════════════════════════════════════════════
#  LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

func _ready() -> void:
        # Configure HealthAndEnergyComponent for enemy use
        if stats:
                stats.max_health = max_health
                stats.current_health = max_health
                stats.invulnerability_time = 0.0
                stats.energy_regen_enabled = false
                stats.health_depleted.connect(_on_health_depleted)

        gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float

        # Collision: body exists on enemy layer (4), detects world (1)
        collision_layer = 4
        collision_mask = 1

        # HitboxArea detects player layer (2)
        hitbox_area.collision_layer = 0
        hitbox_area.collision_mask = 2

        _find_player()
        hitbox_area.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
        if is_dead:
                return
        if not is_on_floor():
                velocity.y += gravity * delta
        if damage_cooldown > 0.0:
                damage_cooldown -= delta
        if knockback_timer > 0.0:
                knockback_timer -= delta
                velocity.x = knockback_direction * received_knockback_force
        elif not is_instance_valid(player_ref):
                player_ref = null
                _find_player()
        match current_state:
                State.IDLE:
                        _state_idle(delta)
                State.PATROL:
                        _state_patrol(delta)
                State.CHASE:
                        _state_chase(delta)
                        
        if enemy_sprite:
                enemy_sprite.flip_h = facing_direction > 0.0
        move_and_slide()
        queue_redraw()


# ═══════════════════════════════════════════════════════════════════════
#  PLAYER DETECTION
# ═══════════════════════════════════════════════════════════════════════

func _find_player() -> void:
        if player_ref and is_instance_valid(player_ref):
                return
        var players: Array[Node] = get_tree().get_nodes_in_group("player")
        if players.size() > 0:
                player_ref = players[0] as CharacterBody2D
                return
        var root: Node = get_tree().current_scene
        if not root:
                return
        for child: Node in root.get_children():
                if child is CharacterBody2D and child.has_node("PlayerSkinComponent"):
                        player_ref = child as CharacterBody2D
                        return


func _distance_to_player() -> float:
        if not player_ref or not is_instance_valid(player_ref):
                return INF
        return global_position.distance_to(player_ref.global_position)


# ═══════════════════════════════════════════════════════════════════════
#  STATE: IDLE
# ═══════════════════════════════════════════════════════════════════════

func _state_idle(_delta: float) -> void:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * _delta)
        patrol_timer += _delta
        if patrol_timer > 2.0:
                current_state = State.PATROL
                patrol_timer = 0.0
                patrol_direction = randf_range(-1.0, 1.0)
                if absf(patrol_direction) < 0.3:
                        patrol_direction = 1.0
        _check_detect_player()


# ═══════════════════════════════════════════════════════════════════════
#  STATE: PATROL
# ═══════════════════════════════════════════════════════════════════════

func _state_patrol(_delta: float) -> void:
        velocity.x = patrol_direction * move_speed * 0.4
        facing_direction = patrol_direction
        patrol_timer += _delta
        if patrol_timer > 3.0:
                current_state = State.IDLE
                patrol_timer = 0.0
        if is_on_wall():
                patrol_direction *= -1.0
                facing_direction = patrol_direction
        elif is_on_floor() and not _check_floor_ahead():
                patrol_direction *= -1.0
                facing_direction = patrol_direction
        _check_detect_player()


# ═══════════════════════════════════════════════════════════════════════
#  STATE: CHASE
# ═══════════════════════════════════════════════════════════════════════

func _state_chase(_delta: float) -> void:
        if not player_ref or not is_instance_valid(player_ref):
                current_state = State.IDLE
                patrol_timer = 0.0
                return
        var dist: float = _distance_to_player()
        if dist > lose_range:
                current_state = State.IDLE
                patrol_timer = 0.0
                return
        var dir: float = signf(player_ref.global_position.x - global_position.x)
        facing_direction = dir
        velocity.x = dir * move_speed
        if is_on_floor() and player_ref.global_position.y < global_position.y - 60.0:
                velocity.y = jump_force
        if dist < attack_range and damage_cooldown <= 0.0:
                _deal_damage()
                damage_cooldown = damage_cooldown_time


func _check_detect_player() -> void:
        if _distance_to_player() < chase_range:
                current_state = State.CHASE


func _check_floor_ahead() -> bool:
        var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
        var from: Vector2 = global_position + Vector2(facing_direction * 25.0, 0.0)
        var to: Vector2 = from + Vector2(0.0, 50.0)
        var params: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to, 1)
        var result: Dictionary = space_state.intersect_ray(params)
        return not result.is_empty()


# ═══════════════════════════════════════════════════════════════════════
#  COMBAT
# ═══════════════════════════════════════════════════════════════════════

func _deal_damage() -> void:
        if not player_ref or not is_instance_valid(player_ref):
                return
        var player_stats: Node = player_ref.get_node_or_null("HealthAndEnergyComponent")
        if player_stats and player_stats.has_method("take_damage"):
                player_stats.take_damage(contact_damage, self)
                damage_dealt.emit(contact_damage, player_ref)


func take_damage(amount: float, source: Node = null) -> void:
        if is_dead:
                return
        # Apply knockback from the damage source's direction
        if source and is_instance_valid(source):
                var dir: float = signf(global_position.x - source.global_position.x)
                if dir == 0.0:
                        dir = -facing_direction
                knockback_direction = dir
                knockback_timer = knockback_duration
        if stats:
                stats.take_damage(amount, source)
        # Visual flash on hit
        modulate = Color(2.0, 0.5, 0.5)
        var tween: Tween = create_tween()
        tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _on_health_depleted() -> void:
        _die()


func _die() -> void:
        is_dead = true
        current_state = State.DEAD
        enemy_died.emit(self)
        VFXController.spawn_death_burst(global_position, enemy_color)
        var tween: Tween = create_tween()
        tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
        tween.tween_property(self, "modulate.a", 0.0, 0.3)
        tween.tween_callback(queue_free)


func _is_player_stomping(player: CharacterBody2D) -> bool:
        if player.global_position.y > global_position.y:
                return false
        if player.velocity.y < 0:
                return false
        var h_dist: float = absf(player.global_position.x - global_position.x)
        return h_dist < body_radius * 2.0


func _on_hitbox_body_entered(body: Node2D) -> void:
        if body != player_ref:
                return
        if is_dead:
                return
        if damage_cooldown > 0.0:
                return
        if _is_player_stomping(body as CharacterBody2D):
                take_damage(stomp_damage, body)
                player_ref.velocity = Vector2(player_ref.velocity.x, stomp_bounce)
                damage_cooldown = 0.3
                return
        _deal_damage()
        damage_cooldown = damage_cooldown_time


# ═══════════════════════════════════════════════════════════════════════
#  DRAWING  (placeholder visuals — replace with sprites later)
# ═══════════════════════════════════════════════════════════════════════

func _draw() -> void:
        return
        if is_dead:
                return
        var r: float = body_radius

        # Shadow
        draw_ellipse(
                Vector2(0.0, r * 0.7),
                r * 0.8,
                r * 0.2,
                Color(0.0, 0.0, 0.0, 0.25))

        # Body
        draw_circle(Vector2(0.0, -r * 0.3), r, enemy_color)

        # Highlight
        draw_circle(
                Vector2(-r * 0.25 * facing_direction, -r * 0.7),
                r * 0.2,
                Color(1.0, 1.0, 1.0, 0.3))

        # Eyes
        var eye_y: float = -r * 0.5
        var eye_spread: float = r * 0.3
        var eye_size: float = r * 0.22
        var pupil_size: float = eye_size * 0.55
        var eye_drift: float = facing_direction * 1.5
        var le_x: float = -eye_spread
        draw_circle(Vector2(le_x, eye_y), eye_size, Color.WHITE)
        draw_circle(Vector2(le_x + eye_drift, eye_y), pupil_size, Color.BLACK)
        var re_x: float = eye_spread
        draw_circle(Vector2(re_x, eye_y), eye_size, Color.WHITE)
        draw_circle(Vector2(re_x + eye_drift, eye_y), pupil_size, Color.BLACK)

        # Health bar (reads from HealthAndEnergyComponent)
        var hp: float = stats.get_health() if stats else 0.0
        var mhp: float = stats.get_max_health() if stats else 1.0
        if hp < mhp:
                var bar_w: float = r * 2.5
                var bar_h: float = 4.0
                var bar_y: float = -r * 2.0 - 8.0
                var pct: float = hp / mhp if mhp > 0.0 else 0.0
                draw_rect(
                        Rect2(-bar_w / 2.0, bar_y, bar_w, bar_h),
                        Color(0.15, 0.15, 0.15, 0.8))
                var health_col: Color = Color.GREEN
                if pct < 0.5:
                        health_col = Color.YELLOW
                if pct < 0.25:
                        health_col = Color.RED
                draw_rect(
                        Rect2(-bar_w / 2.0, bar_y, bar_w * pct, bar_h),
                        health_col)
                draw_rect(
                        Rect2(-bar_w / 2.0, bar_y, bar_w, bar_h),
                        Color(0.0, 0.0, 0.0, 0.5), false, 1.0)


func get_health() -> float:
        if stats:
                return stats.get_health()
        return 0.0


func is_alive() -> bool:
        return not is_dead
