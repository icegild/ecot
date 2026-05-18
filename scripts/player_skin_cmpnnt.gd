extends Node2D
class_name CharacterAnimationComponent

# ============================================
# SIGNALS
# ============================================
signal character_changed(character_name: String, previous_character: String)
signal animations_switched(character_name: String)
signal animation_played(animation_name: String)
signal character_order_changed(new_order: Array)
signal animation_resources_loaded(loaded_characters: Array)

# ============================================
# ANIMATION SYSTEM
# ============================================
@export_group("Character Setup")
@export var animated_sprite: AnimatedSprite2D:
	set(value):
		animated_sprite = value
		if animated_sprite and _is_initialized and current_animations:
			update_animation_frames()

@export var current_character: String = "blood":
	set(value):
		if animation_resources.has(value):
			var old_character = current_character
			current_character = value
			if old_character != current_character:
				character_changed.emit(current_character, old_character)
				switch_animations(current_character)
		else:
			push_warning("Character '%s' not found in animation resources" % value)

@export var character_order: Array = ["blood", "dark", "electricity", "fairy", "moon", "shell", "time", "vine"]:
	set(value):
		character_order = value
		character_order_changed.emit(character_order)

@export_group("Animation Settings")
@export var auto_play_idle: bool = true
@export var default_animation: String = "idle"
@export var animation_resource_dir: String = "res://animations/"
@export var animation_file_extension: String = ".tres"

# ============================================
# PRIVATE VARIABLES
# ============================================
var animation_resources: Dictionary = {}
var current_animations: Resource = null
var _is_initialized: bool = false

# ============================================
# INITIALIZATION
# ============================================
func _ready() -> void:
	# If no animated_sprite assigned, try to find one as sibling or child
	if not animated_sprite:
		_try_auto_find_sprite()
	
	load_all_animations()
	
	if animation_resources.has(current_character):
		switch_animations(current_character)
	else:
		push_error("Could not load initial character animations for: ", current_character)
	
	_is_initialized = true

func _try_auto_find_sprite() -> void:
	# Try to find AnimatedSprite2D as a child
	for child in get_children():
		if child is AnimatedSprite2D:
			animated_sprite = child
			return
	
	# Try to find it as a sibling (if this component is a child of the main node)
	if get_parent():
		for sibling in get_parent().get_children():
			if sibling is AnimatedSprite2D and sibling != self:
				animated_sprite = sibling
				return
	
	push_warning("CharacterAnimationComponent: No AnimatedSprite2D found. Please assign one manually.")

# ============================================
# ANIMATION RESOURCE MANAGEMENT
# ============================================

## Loads all animation resources from the character_order array.
func load_all_animations() -> void:
	var loaded_characters = []
	
	for character in character_order:
		if load_character_animation(character):
			loaded_characters.append(character)
	
	animation_resources_loaded.emit(loaded_characters)

## Loads a specific character's animation resource. Returns true if successful.
func load_character_animation(character_name: String) -> bool:
	var resource_path = animation_resource_dir + character_name + animation_file_extension
	
	if ResourceLoader.exists(resource_path):
		animation_resources[character_name] = load(resource_path)
		print("Loaded animation: ", character_name)
		return true
	else:
		push_warning("Could not find animation for ", character_name, " at path: ", resource_path)
		return false

## Reloads all animations from disk.
func reload_animations() -> void:
	animation_resources.clear()
	load_all_animations()
	switch_animations(current_character)

## Unloads a specific character's animation resource to free memory.
func unload_character_animation(character_name: String) -> void:
	if animation_resources.has(character_name) and character_name != current_character:
		animation_resources.erase(character_name)
		print("Unloaded animation: ", character_name)

## Unloads all animations except the current one.
func unload_unused_animations() -> void:
	for character in animation_resources.keys():
		if character != current_character:
			unload_character_animation(character)

# ============================================
# CHARACTER SWITCHING
# ============================================

## Switches to a specific character by name.
func switch_to_character(character_name: String) -> bool:
	if not animation_resources.has(character_name):
		push_error("Animation resource not found for: ", character_name)
		return false
	
	if character_name == current_character:
		return true
	
	current_character = character_name
	return true

## Switches to the next character in the order (wraps around).
func switch_to_next_character() -> String:
	var current_index = character_order.find(current_character)
	
	if current_index == -1:
		push_error("Current character '%s' not found in character_order" % current_character)
		return current_character
	
	var next_index = (current_index + 1) % character_order.size()
	var next_character = character_order[next_index]
	
	switch_to_character(next_character)
	return next_character

## Switches to the previous character in the order (wraps around).
func switch_to_previous_character() -> String:
	var current_index = character_order.find(current_character)
	
	if current_index == -1:
		push_error("Current character '%s' not found in character_order" % current_character)
		return current_character
	
	var prev_index = (current_index - 1 + character_order.size()) % character_order.size()
	var prev_character = character_order[prev_index]
	
	switch_to_character(prev_character)
	return prev_character

## Switches to a random character from the available characters.
func switch_to_random_character() -> String:
	if character_order.is_empty():
		return current_character
	
	var random_character = character_order[randi() % character_order.size()]
	switch_to_character(random_character)
	return random_character

## Switches to a specific character by index in the order.
func switch_to_character_by_index(index: int) -> bool:
	if index < 0 or index >= character_order.size():
		push_error("Invalid character index: ", index)
		return false
	
	return switch_to_character(character_order[index])

func switch_animations(character_name: String) -> void:
	if not animation_resources.has(character_name):
		push_error("Animation resource not found for: ", character_name)
		return
	
	current_animations = animation_resources[character_name]
	update_animation_frames()
	animations_switched.emit(character_name)

func update_animation_frames() -> void:
	if not current_animations or not animated_sprite:
		return
	
	animated_sprite.sprite_frames = current_animations
	
	if auto_play_idle:
		play_animation(default_animation)
	
	print("Successfully switched to: ", current_character, " - Playing idle animation")

# ============================================
# ANIMATION CONTROL
# ============================================

## Plays a specific animation by name.
func play_animation(animation_name: String) -> void:
	if not animated_sprite:
		push_error("No AnimatedSprite2D reference found")
		return
	
	if not current_animations or not current_animations.has_animation(animation_name):
		push_warning("Animation '%s' not found in current character '%s'" % [animation_name, current_character])
		return
	
	animated_sprite.animation = animation_name
	animated_sprite.play()
	animation_played.emit(animation_name)

## Stops the current animation.
func stop_animation() -> void:
	if animated_sprite:
		animated_sprite.stop()

## Pauses the current animation.
func pause_animation() -> void:
	if animated_sprite:
		animated_sprite.pause()

## Returns a list of all available animations for the current character.
func get_available_animations() -> Array:
	if not current_animations:
		return []
	
	var animation_list = []
	for anim in current_animations.get_animation_names():
		animation_list.append(anim)
	
	return animation_list

## Returns true if the current character has a specific animation.
func has_animation(animation_name: String) -> bool:
	if not current_animations:
		return false
	return current_animations.has_animation(animation_name)

# ============================================
# GETTERS
# ============================================

## Returns the name of the current character.
func get_current_character() -> String:
	return current_character

## Returns the index of the current character in the order.
func get_current_character_index() -> int:
	return character_order.find(current_character)

## Returns the total number of characters available.
func get_character_count() -> int:
	return character_order.size()

## Returns the number of characters with loaded animations.
func get_loaded_animation_count() -> int:
	return animation_resources.size()

## Returns true if there are characters available to switch to.
func can_switch_characters() -> bool:
	return character_order.size() > 1

## Returns the current animation resource.
func get_current_animation_resource() -> Resource:
	return current_animations

## Returns the AnimatedSprite2D node reference.
func get_animated_sprite() -> AnimatedSprite2D:
	return animated_sprite

## Returns the currently playing animation name.
func get_current_animation_name() -> String:
	if animated_sprite:
		return animated_sprite.animation
	return ""

## Returns true if the animation is currently playing.
func is_playing() -> bool:
	if animated_sprite:
		return animated_sprite.is_playing()
	return false

## Returns the current frame of the animation.
func get_current_frame() -> int:
	if animated_sprite:
		return animated_sprite.frame
	return 0

## Returns all character names that have loaded animation resources.
func get_loaded_characters() -> Array:
	return animation_resources.keys()

## Returns a copy of the character order.
func get_character_order() -> Array:
	return character_order.duplicate()

## Returns the next character name in the sequence without switching.
func get_next_character_name() -> String:
	var current_index = character_order.find(current_character)
	if current_index == -1:
		return ""
	
	var next_index = (current_index + 1) % character_order.size()
	return character_order[next_index]

## Returns the previous character name in the sequence without switching.
func get_previous_character_name() -> String:
	var current_index = character_order.find(current_character)
	if current_index == -1:
		return ""
	
	var prev_index = (current_index - 1 + character_order.size()) % character_order.size()
	return character_order[prev_index]

# ============================================
# SETTERS
# ============================================

## Sets the AnimatedSprite2D node to control.
func set_animated_sprite(sprite: AnimatedSprite2D) -> void:
	animated_sprite = sprite
	if _is_initialized and current_animations:
		update_animation_frames()

## Sets the animation resource directory path.
func set_animation_resource_dir(dir: String) -> void:
	animation_resource_dir = dir
	if not animation_resource_dir.ends_with("/"):
		animation_resource_dir += "/"

## Sets the animation file extension (e.g., ".tres", ".res").
func set_animation_file_extension(ext: String) -> void:
	if not ext.begins_with("."):
		ext = "." + ext
	animation_file_extension = ext

## Sets the default animation to play when switching characters.
func set_default_animation(animation_name: String) -> void:
	default_animation = animation_name

## Toggles auto-playing idle animation on character switch.
func set_auto_play_idle(enabled: bool) -> void:
	auto_play_idle = enabled

# ============================================
# UTILITY METHODS
# ============================================

## Adds a new character to the order and optionally loads its animation.
func add_character(character_name: String, load_now: bool = true) -> void:
	if character_name in character_order:
		return
	
	character_order.append(character_name)
	
	if load_now:
		load_character_animation(character_name)

## Removes a character from the order and optionally unloads its animation.
func remove_character(character_name: String, unload_now: bool = true) -> void:
	if character_name == current_character and character_order.size() <= 1:
		push_error("Cannot remove the only remaining character")
		return
	
	var index = character_order.find(character_name)
	if index != -1:
		# If we're removing the current character, switch first
		if character_name == current_character:
			var next_char = get_next_character_name()
			if next_char and next_char != character_name:
				switch_to_character(next_char)
		
		character_order.remove_at(index)
		
		if unload_now:
			unload_character_animation(character_name)

## Shuffles the character order randomly.
func shuffle_character_order() -> void:
	character_order.shuffle()
	character_order_changed.emit(character_order)

## Resets the component to its initial state.
func reset() -> void:
	stop_animation()
	if not character_order.is_empty():
		switch_to_character(character_order[0])

## Returns a string representation of the current state.
func get_state_string() -> String:
	return "Character: %s (%d/%d) - Animation: %s - Playing: %s" % [
		current_character,
		get_current_character_index() + 1,
		get_character_count(), 
		get_current_animation_name(),
		"yes" if is_playing() else "no"
	]

## Prints current component state to the console.
func print_state() -> void:
	print(get_state_string())
	print("Available animations: ", get_available_animations())
	print("Loaded characters: ", get_loaded_characters())
