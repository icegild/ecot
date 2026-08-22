extends CharacterBody2D

# ─────────────────────────────────────────────────────────────────────
#  player_controller.gd  –  Full player controller
#  Godot 4.7  |  Extends CharacterBody2D (player group)
#  Handles: movement, jump, attack, melee, knockback, health, death, VFX
# ─────────────────────────────────────────────────────────────────────


# ── Movement constants ─────────────────────────────────────────────

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -550.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


# ── VFX anchor points (Marker2D nodes in scene) ────────────────────

@onready var vfx_feet: Marker2D = $VFXFeet
@onready var vfx_center: Marker2D = $VFXCenter


# ── Component references ──────────────────────────────────────────

@onready var animation_component: CharacterAnimationComponent = $PlayerSkinComponent
@onready var stats_component: HealthAndEnergyComponent = $HealthAndEnergyComponent


# ── Attack system ───────────────────────────────────────────────────

var attack_area: Area2D
var is_attacking: bool = false
var attack_damage: float = 20.0
const ATTACK_DURATION: float = 0.45
const ATTACK_COOLDOWN: float = 0.5
var attack_timer: float = 0.0


# ── Melee slash (X key) ──────────────────────────────────────────

var is_meleeing: bool = false
var melee_damage: float = 15.0
const MELEE_DURATION: float = 0.25
const MELEE_COOLDOWN: float = 0.35
var melee_timer: float = 0.0


# ── State ──────────────────────────────────────────────────────────

var is_dead: bool = false
var was_on_floor: bool = true
var run_dust_timer: float = 0.0
const RUN_DUST_INTERVAL: float = 0.12


# ── Knockback ────────────────────────────────────────────────────

var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DURATION: float = 0.15
const KNOCKBACK_FORCE_X: float = 250.0
const KNOCKBACK_FORCE_Y: float = -150.0


# ═══════════════════════════════════════════════════════════════════════
#  LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

func _ready():
        # Connect to character change signals
        if animation_component:
                animation_component.character_changed.connect(_on_character_changed)
                animation_component.animation_played.connect(_on_animation_played)

        # Connect to health signals
        if stats_component:
                stats_component.health_depleted.connect(_on_health_depleted)
                stats_component.damage_taken.connect(_on_damage_taken)

        # Build the attack hitbox (Area2D with CircleShape2D)
        # collision_mask = 4 detects enemies on layer 3
        attack_area = Area2D.new()
        attack_area.name = "AttackHitbox"
        attack_area.collision_layer = 0
        attack_area.collision_mask = 4  # enemy layer

        var attack_shape := CircleShape2D.new()
        attack_shape.radius = 55.0
        var col := CollisionShape2D.new()
        col.shape = attack_shape
        col.position = Vector2(35.0, -20.0)  # offset in front of player
        attack_area.add_child(col)
        add_child(attack_area)


func _physics_process(delta: float) -> void:
        if is_dead:
                return

        # Tick attack cooldown
        if attack_timer > 0.0:
                attack_timer -= delta
                if attack_timer <= 0.0:
                        is_attacking = false

        # Tick melee cooldown
        if melee_timer > 0.0:
                melee_timer -= delta
                if melee_timer <= 0.0:
                        is_meleeing = false

        # Tick knockback
        if knockback_timer > 0.0:
                knockback_timer -= delta
                velocity.x = knockback_velocity.x
                if is_on_floor() and knockback_velocity.y >= 0.0:
                        knockback_timer = 0.0
                        velocity.x = move_toward(velocity.x, 0, SPEED)
                else:
                        velocity.y += gravity * delta
                        move_and_slide()
                        return

        # Dust on landing
        if is_on_floor() and not was_on_floor:
                VFXController.spawn_dust(vfx_feet.global_position)
        was_on_floor = is_on_floor()

        # Running dust trail
        if is_on_floor() and absf(velocity.x) > 100.0:
                run_dust_timer -= delta
                if run_dust_timer <= 0.0:
                        var dust_dir: float = signf(velocity.x)
                        VFXController.spawn_run_dust(vfx_feet.global_position + Vector2(-dust_dir * 5, 0), dust_dir)
                        run_dust_timer = RUN_DUST_INTERVAL
        else:
                run_dust_timer = 0.0

        # Add the gravity.
        if not is_on_floor():
                velocity.y += gravity * delta

        # Handle Jump.
        if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
                velocity.y = JUMP_VELOCITY

        # Handle Attack (F key).
        if Input.is_action_just_pressed("attack") and not is_attacking and attack_timer <= 0.0:
                _perform_attack()

        # Handle Melee Slash (X key).
        if Input.is_action_just_pressed("melee") and not is_meleeing and melee_timer <= 0.0 and not is_attacking:
                _perform_melee()

        # Get the input direction and handle the movement/deceleration.
        var direction := Input.get_axis("ui_left", "ui_right")

        # Handle sprite flipping based on direction
        if animation_component:
                var sprite = animation_component.get_animated_sprite()
                if sprite:
                        if direction > 0:
                                sprite.flip_h = false
                        elif direction < 0:
                                sprite.flip_h = true

        # Handle movement and animations (skip during attack/melee)
        if direction:
                velocity.x = direction * SPEED
                if animation_component and not is_attacking and not is_meleeing:
                        animation_component.play_animation("walk")
        else:
                velocity.x = move_toward(velocity.x, 0, SPEED)
                if velocity.x == 0:
                        if animation_component and not is_attacking and not is_meleeing:
                                animation_component.play_animation("idle")

        # Handle jump animation
        if not is_on_floor() and animation_component and not is_attacking and not is_meleeing:
                animation_component.play_animation("jump")

        move_and_slide()


# ═══════════════════════════════════════════════════════════════════════
#  ATTACK
# ═══════════════════════════════════════════════════════════════════════

func _perform_attack() -> void:
        is_attacking = true
        attack_timer = ATTACK_DURATION + ATTACK_COOLDOWN

        # Play attack animation
        if animation_component:
                animation_component.play_animation("attack")

        # Determine facing direction
        var facing: float = 1.0
        if animation_component:
                var sprite = animation_component.get_animated_sprite()
                if sprite and sprite.flip_h:
                        facing = -1.0

        # Check all bodies overlapping the attack hitbox
        if attack_area:
                var bodies = attack_area.get_overlapping_bodies()
                for body in bodies:
                        if body == self:
                                continue
                        if body.has_method("take_damage"):
                                # Only hit enemies in the direction the player faces
                                var dir_to_target = signf(body.global_position.x - global_position.x)
                                if dir_to_target == facing or absf(body.global_position.x - global_position.x) < 40.0:
                                        body.take_damage(attack_damage, self)
                                        VFXController.spawn_hit_spark(body.global_position, facing)


# ═══════════════════════════════════════════════════════════════════════
#  MELEE  (X key — close-range slash with skin-colored VFX)
# ═══════════════════════════════════════════════════════════════════════

func _perform_melee() -> void:
        is_meleeing = true
        melee_timer = MELEE_DURATION + MELEE_COOLDOWN

        # Play attack animation
        if animation_component:
                animation_component.play_animation("attack")

        # Determine facing direction
        var facing: float = 1.0
        if animation_component:
                var sprite = animation_component.get_animated_sprite()
                if sprite and sprite.flip_h:
                        facing = -1.0

        # Spawn the visual slash effect (skip for electricity)
        var skin_name: String = "blood"
        if animation_component:
                skin_name = animation_component.get_current_character()
        if skin_name != "electricity":
                var slash = preload("res://scripts/melee_slash.gd").new(facing, skin_name)
                add_child(slash)

        # Damage enemies in melee range (smaller than F-attack)
        var melee_area := _get_melee_overlap(facing)
        for body in melee_area:
                if body == self:
                        continue
                if body.has_method("take_damage"):
                        var dir_to_target = signf(body.global_position.x - global_position.x)
                        if dir_to_target == facing or absf(body.global_position.x - global_position.x) < 80.0:
                                body.take_damage(melee_damage, self)
                                VFXController.spawn_hit_spark(body.global_position, facing)
                                VFXController.spawn_slash_impact((global_position + body.global_position) / 2.0)


func _get_melee_overlap(facing: float) -> Array:
        # Use a direct space-state shape cast for precise melee hitbox
        var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
        var query := PhysicsShapeQueryParameters2D.new()
        var shape := CircleShape2D.new()
        shape.radius = 75.0
        query.shape = shape
        query.transform = Transform2D(0.0, global_position + Vector2(facing * 45.0, -10.0))
        query.collision_mask = 4  # enemy layer
        var results = space_state.intersect_shape(query)
        var bodies: Array = []
        for r: Dictionary in results:
                if r.has("collider") and r["collider"] is Node2D:
                        bodies.append(r["collider"])
        return bodies


# ═══════════════════════════════════════════════════════════════════════
#  HEALTH & DEATH
# ═══════════════════════════════════════════════════════════════════════

func _on_damage_taken(amount: float, source: Node) -> void:
        # Apply knockback away from the damage source
        if source and is_instance_valid(source):
                var dir: float = signf(global_position.x - source.global_position.x)
                if dir == 0.0:
                        dir = 1.0
                knockback_velocity = Vector2(dir * KNOCKBACK_FORCE_X, KNOCKBACK_FORCE_Y)
                knockback_timer = KNOCKBACK_DURATION

        # Red flash on damage
        modulate = Color(2.0, 0.5, 0.5)
        var tween := create_tween()
        tween.tween_property(self, "modulate", Color.WHITE, 0.2)
        VFXController.spawn_damage_spark(vfx_center.global_position)


func _on_health_depleted() -> void:
        is_dead = true
        print("[Player] Health depleted — respawning...")
        # Disable collision so nothing else interacts with the corpse
        collision_layer = 0
        collision_mask = 0
        # Brief pause, then reload the scene
        await get_tree().create_timer(1.0).timeout
        get_tree().reload_current_scene()


# ═══════════════════════════════════════════════════════════════════════
#  SIGNAL CALLBACKS
# ═══════════════════════════════════════════════════════════════════════

func _on_character_changed(new_character: String, old_character: String):
        print("Player changed from ", old_character, " to ", new_character)


func _on_animation_played(animation_name: String):
        pass
