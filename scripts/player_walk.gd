extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -550.0

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


func _on_character_changed(new_character: String, old_character: String):
	print("Player changed from ", old_character, " to ", new_character)

func _on_animation_played(animation_name: String):
	# Optional: Debug or react to animation changes
	pass
