extends Node2D
class_name HealthAndEnergyComponent

# ============================================
# HEALTH SYSTEM
# ============================================
signal health_changed(current_health: float, max_health: float)
signal health_depleted()
signal health_increased(amount: float)
signal health_decreased(amount: float)
signal damage_taken(amount: float, source: Node)
signal healed(amount: float)
signal max_health_changed(new_max_health: float)

@export_group("Health")
@export var max_health: float = 100.0:
	set(value):
		var old_max = max_health
		max_health = max(1.0, value)
		if old_max != max_health:
			max_health_changed.emit(max_health)
			if current_health > max_health:
				current_health = max_health

@export var current_health: float = 100.0:
	set(value):
		var old_health = current_health
		current_health = clamp(value, 0.0, max_health)
		if current_health == old_health:
			return

		health_changed.emit(current_health, max_health)

		if current_health > old_health:
			health_increased.emit(current_health - old_health)
		elif current_health < old_health:
			health_decreased.emit(old_health - current_health)

		if current_health <= 0.0:
			health_depleted.emit()

@export_group("Health Options")
@export var invulnerable: bool = false
@export var invulnerability_time: float = 1.0
@export var start_with_max_health: bool = true

# ============================================
# ENERGY SYSTEM
# ============================================
signal energy_changed(current_energy: float, max_energy: float)
signal energy_depleted()
signal energy_full()
signal energy_increased(amount: float)
signal energy_decreased(amount: float)
signal energy_consumed(amount: float)
signal energy_restored(amount: float)
signal max_energy_changed(new_max_energy: float)

@export_group("Energy")
@export var max_energy: float = 100.0:
	set(value):
		var old_max = max_energy
		max_energy = max(0.0, value)
		if old_max != max_energy:
			max_energy_changed.emit(max_energy)
			if current_energy > max_energy:
				current_energy = max_energy

@export var current_energy: float = 100.0:
	set(value):
		var old_energy = current_energy
		current_energy = clamp(value, 0.0, max_energy)
		if current_energy == old_energy:
			return

		energy_changed.emit(current_energy, max_energy)

		if current_energy > old_energy:
			energy_increased.emit(current_energy - old_energy)
		elif current_energy < old_energy:
			energy_decreased.emit(old_energy - current_energy)

		if current_energy <= 0.0:
			energy_depleted.emit()
		elif current_energy >= max_energy:
			energy_full.emit()

@export_group("Energy Regen")
@export var energy_regen_enabled: bool = true
@export var energy_regen_rate: float = 5.0
@export var energy_regen_delay: float = 2.0
@export var start_with_max_energy: bool = true

var _energy_regen_timer: float = 0.0
var _energy_regen_active: bool = false

# ============================================
# INITIALIZATION
# ============================================
func _ready() -> void:
	if start_with_max_health:
		current_health = max_health
	if start_with_max_energy:
		current_energy = max_energy

func _process(delta: float) -> void:
	_handle_energy_regeneration(delta)

## Internal regen logic: waits for delay, then regenerates energy per second.
func _handle_energy_regeneration(delta: float) -> void:
	if not energy_regen_enabled or current_energy >= max_energy:
		_energy_regen_active = false
		return

	if _energy_regen_active:
		add_energy(energy_regen_rate * delta)
	else:
		_energy_regen_timer += delta
		if _energy_regen_timer >= energy_regen_delay:
			_energy_regen_active = true
			_energy_regen_timer = 0.0

# ============================================
# HEALTH METHODS
# ============================================

## Returns current health value.
func get_health() -> float:
	return current_health

## Returns maximum health.
func get_max_health() -> float:
	return max_health

## Returns health as a fraction [0.0, 1.0].
func get_health_percent() -> float:
	return 0.0 if max_health <= 0.0 else current_health / max_health

## Returns a formatted string "current / max".
func get_health_string() -> String:
	return "%d / %d" % [current_health, max_health]

## Adds health (heals). Does nothing if amount <= 0.
func add_health(amount: float) -> void:
	if amount <= 0:
		return
	var old_health = current_health
	current_health += amount
	healed.emit(min(amount, max_health - old_health))

## Decreases health (damage). Optional source node. Does nothing if invulnerable or amount <= 0.
func decrease_health(amount: float, source: Node = null) -> void:
	if amount <= 0 or invulnerable:
		return
	current_health -= amount
	damage_taken.emit(amount, source)
	if invulnerability_time > 0.0 and current_health > 0.0:
		_start_invulnerability()

## Alias for [method decrease_health].
func take_damage(amount: float, source: Node = null) -> void:
	decrease_health(amount, source)

## Alias for [method add_health].
func heal(amount: float) -> void:
	add_health(amount)

## Sets current health directly (clamped).
func set_health(value: float) -> void:
	current_health = value

## Sets maximum health (clamps current if needed).
func set_max_health(value: float) -> void:
	max_health = value

## Restores health to maximum.
func reset_health() -> void:
	current_health = max_health

## Returns true if current_health > 0.
func is_alive() -> bool:
	return current_health > 0.0

## Returns true if current_health <= 0.
func is_dead() -> bool:
	return current_health <= 0.0

## Returns missing health amount.
func get_missing_health() -> float:
	return max_health - current_health

## Heals by a percentage of max health.
func heal_percent(percent: float) -> void:
	add_health(max_health * (percent / 100.0))

## Damages by a percentage of max health.
func damage_percent(percent: float, source: Node = null) -> void:
	decrease_health(max_health * (percent / 100.0), source)

## Activates temporary invulnerability.
func _start_invulnerability() -> void:
	invulnerable = true
	await get_tree().create_timer(invulnerability_time).timeout
	invulnerable = false

## Sets invulnerability state manually.
func set_invulnerable(value: bool) -> void:
	invulnerable = value

## Returns true if currently invulnerable.
func is_invulnerable() -> bool:
	return invulnerable

# ============================================
# ENERGY METHODS
# ============================================

## Returns current energy.
func get_energy() -> float:
	return current_energy

## Returns maximum energy.
func get_max_energy() -> float:
	return max_energy

## Returns energy as a fraction [0.0, 1.0].
func get_energy_percent() -> float:
	return 0.0 if max_energy <= 0.0 else current_energy / max_energy

## Returns a formatted string "current / max".
func get_energy_string() -> String:
	return "%d / %d" % [current_energy, max_energy]

## Adds energy (restores). Does nothing if amount <= 0.
func add_energy(amount: float) -> void:
	if amount <= 0:
		return
	var old_energy = current_energy
	current_energy += amount
	energy_restored.emit(min(amount, max_energy - old_energy))

## Decreases energy by amount. Returns true if successful, false if insufficient energy.
func decrease_energy(amount: float) -> bool:
	if amount <= 0:
		return true
	if current_energy >= amount:
		current_energy -= amount
		energy_consumed.emit(amount)
		_reset_energy_regen()
		return true
	return false

## Alias for [method decrease_energy]. Use for ability costs.
func consume_energy(amount: float) -> bool:
	return decrease_energy(amount)

## Alias for [method add_energy].
func restore_energy(amount: float) -> void:
	add_energy(amount)

## Sets current energy directly (clamped).
func set_energy(value: float) -> void:
	current_energy = value

## Sets maximum energy (clamps current if needed).
func set_max_energy(value: float) -> void:
	max_energy = value

## Restores energy to maximum.
func reset_energy() -> void:
	current_energy = max_energy

## Returns true if current energy >= amount (default 1.0).
func has_energy(amount: float = 1.0) -> bool:
	return current_energy >= amount

## Returns true if energy is full.
func is_energy_full() -> bool:
	return current_energy >= max_energy

## Returns true if energy is empty.
func is_energy_empty() -> bool:
	return current_energy <= 0.0

## Returns missing energy amount.
func get_missing_energy() -> float:
	return max_energy - current_energy

## Restores energy by a percentage of max energy.
func restore_energy_percent(percent: float) -> void:
	add_energy(max_energy * (percent / 100.0))

## Consumes energy by a percentage of max energy. Returns true if successful.
func consume_energy_percent(percent: float) -> bool:
	return decrease_energy(max_energy * (percent / 100.0))

## Resets the regen timer and disables active regen.
func _reset_energy_regen() -> void:
	_energy_regen_timer = 0.0
	_energy_regen_active = false

## Enables or disables automatic energy regeneration.
func set_energy_regen_enabled(value: bool) -> void:
	energy_regen_enabled = value
	if not value:
		_reset_energy_regen()

## Sets the energy regeneration rate (per second).
func set_energy_regen_rate(rate: float) -> void:
	energy_regen_rate = max(0.0, rate)

## Sets the delay before regeneration begins after energy use.
func set_energy_regen_delay(delay: float) -> void:
	energy_regen_delay = max(0.0, delay)

# ============================================
# COMBINED UTILITY
# ============================================

## Returns a status string like "HP: 75 / 100 | EP: 50 / 100".
func get_status_string() -> String:
	return "HP: %s | EP: %s" % [get_health_string(), get_energy_string()]

## Returns a status string with percentages like "HP: 75% | EP: 50%".
func get_status_percent_string() -> String:
	return "HP: %.0f%% | EP: %.0f%%" % [get_health_percent() * 100, get_energy_percent() * 100]

## Resets both health and energy to their maximums.
func reset_all() -> void:
	reset_health()
	reset_energy()

## Returns true if both health and energy are at maximum.
func is_fully_charged() -> bool:
	return current_health >= max_health and current_energy >= max_energy
