extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -545.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# Component references
@onready var animation_component: CharacterAnimationComponent = $PlayerSkinComponent
@onready var stats_component: HealthAndEnergyComponent = $HealthAndEnergyComponent

func _ready():
	# Connect to character change signals
	if animation_component:
		animation_component.character_changed.connect(_on_character_changed)
		animation_component.animation_played.connect(_on_animation_played)

func _physics_process(delta: float) -> void:
	# Handle character switching
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("attack"):
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
	
	# Handle movement and animations
	if direction:
		velocity.x = direction * SPEED
		# Play walk animation
		if animation_component:
			animation_component.play_animation("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.x == 0:
			# Play idle animation when not moving
			if animation_component:
				animation_component.play_animation("idle")
	
	# Handle jump animation
	if not is_on_floor() and animation_component:
		animation_component.play_animation("jump")
	
	move_and_slide()
func _perform_attack() -> void:
	var dir: float = 1.0
	if animation_component:
		var sprite: AnimatedSprite2D = animation_component.get_animated_sprite()
		if sprite and sprite.flip_h:
			dir = -1.0
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(70.0, 120.0)
	query.shape_rid = shape.get_rid()
	query.transform = Transform2D(0.0, to_global(Vector2(dir * 45.0, -80.0)))
	query.collision_mask = 4
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var results: Array[Dictionary] = space_state.intersect_shape(query)
	for result: Dictionary in results:
		var collider: Node = result.get("collider") as Node
		if collider and collider != self and collider.has_method("take_damage"):
			collider.take_damage(15.0, self)
	_create_slash_visual(dir)


func _create_slash_visual(dir: float) -> void:
	var line: Line2D = Line2D.new()
	line.position = Vector2(dir * 30.0, -20.0)
	var x_radius: float = 140.0
	var y_radius: float = 110.0
	var num_points: int = 24
	var start_angle: float = -1.5
	var end_angle: float = 1.5
	for i: int in range(num_points + 1):
		var t: float = float(i) / float(num_points)
		var angle: float = lerpf(start_angle, end_angle, t)
		var px: float = cos(angle) * x_radius * dir
		var py: float = sin(angle) * y_radius
		line.add_point(Vector2(px, py))
	line.default_color = Color(1.0, 1.0, 1.0, 0.9)
	line.width = 14.0
	add_child(line)
	var tween: Tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.25)
	tween.tween_callback(line.queue_free)

func _on_character_changed(new_character: String, old_character: String):
	print("Player changed from ", old_character, " to ", new_character)

func _on_animation_played(animation_name: String):
	# Optional: Debug or react to animation changes
	pass
