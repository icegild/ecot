extends CharacterBody2D

# ─────────────────────────────────────────────────────────────────────
#  player_walk.gd  –  Player movement, attack, health, and death
#  Godot 4.7  |  Extends CharacterBody2D (player group)
# ─────────────────────────────────────────────────────────────────────


# ── Movement constants ─────────────────────────────────────────────

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -550.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


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


# ── State ──────────────────────────────────────────────────────────

var is_dead: bool = false


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

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Attack (F key).
	if Input.is_action_just_pressed("attack") and not is_attacking and attack_timer <= 0.0:
		_perform_attack()

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

	# Handle movement and animations (skip during attack)
	if direction:
		velocity.x = direction * SPEED
		if animation_component and not is_attacking:
			animation_component.play_animation("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.x == 0:
			if animation_component and not is_attacking:
				animation_component.play_animation("idle")

	# Handle jump animation
	if not is_on_floor() and animation_component and not is_attacking:
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


# ═══════════════════════════════════════════════════════════════════════
#  HEALTH & DEATH
# ═══════════════════════════════════════════════════════════════════════

func _on_damage_taken(amount: float, source: Node) -> void:
	# Red flash on damage
	modulate = Color(2.0, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)


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
