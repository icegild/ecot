extends Node2D

# ─────────────────────────────────────────────────────────────────────
#  EnemySpawner.gd  –  Spawns enemies around the player at intervals
#  Godot 4.7  |  Production-quality GDScript (strict-typed, zero warnings)
# ─────────────────────────────────────────────────────────────────────
#
#  SETUP
#    1. Attach this script to a Node2D in your scene.
#    2. Assign the Enemy scene (PackedScene) in the inspector.
#    3. Player must be in the "player" group.
#
# ─────────────────────────────────────────────────────────────────────


# ── Signals ──────────────────────────────────────────────────────────

signal enemy_spawned(enemy: Node)
signal enemy_count_changed(count: int)


# ── Exports ──────────────────────────────────────────────────────────

@export_group("Spawning")
@export var enemy_scene: PackedScene
@export var spawn_interval: float = 4.0
@export var max_enemies: int = 5
@export var min_spawn_distance: float = 300.0
@export var max_spawn_distance: float = 600.0
@export var spawn_above: bool = false
@export var auto_start: bool = true

@export_group("Difficulty Scaling")
@export var decrease_interval_over_time: bool = false
@export var minimum_interval: float = 1.0
@export var interval_decrease_rate: float = 0.1


# ── Internal state ───────────────────────────────────────────────────

var spawn_timer: float = 0.0
var active_enemies: Array[Node] = []
var player_ref: CharacterBody2D = null
var total_spawned: int = 0
var is_active: bool = true


# ═══════════════════════════════════════════════════════════════════════
#  LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_find_player()
	spawn_timer = spawn_interval * 0.5
	get_tree().node_added.connect(_on_node_added)


func _process(delta: float) -> void:
	if not is_active or not auto_start:
		return
	if not enemy_scene:
		return
	_cleanup_dead_enemies()
	if not is_instance_valid(player_ref):
		player_ref = null
		_find_player()
	spawn_timer += delta
	var current_interval: float = _get_current_interval()
	if spawn_timer >= current_interval and active_enemies.size() < max_enemies:
		_spawn_enemy()
		spawn_timer = 0.0


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


func _on_node_added(node: Node) -> void:
	if player_ref:
		get_tree().node_added.disconnect(_on_node_added)
		return
	if node is CharacterBody2D and node.is_in_group("player"):
		player_ref = node as CharacterBody2D


# ═══════════════════════════════════════════════════════════════════════
#  SPAWNING
# ═══════════════════════════════════════════════════════════════════════

func _spawn_enemy() -> void:
	if not player_ref or not is_instance_valid(player_ref):
		return
	var enemy: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
	if not enemy:
		return
	var spawn_pos: Vector2 = _get_spawn_position()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	active_enemies.append(enemy)
	enemy.enemy_died.connect(_on_enemy_died)
	total_spawned += 1
	enemy_spawned.emit(enemy)
	enemy_count_changed.emit(active_enemies.size())


func _get_spawn_position() -> Vector2:
	var pos: Vector2 = Vector2.ZERO
	if is_instance_valid(player_ref):
		if spawn_above:
			var cam: Camera2D = get_viewport().get_camera_2d()
			var view_top: float = player_ref.global_position.y - 600.0
			if cam:
				view_top = cam.global_position.y - get_viewport().get_visible_rect().size.y / 2.0 - 50.0
			var rand_x: float = player_ref.global_position.x + randf_range(-400.0, 400.0)
			pos = Vector2(rand_x, view_top)
		else:
			var offset_x: float = randf_range(min_spawn_distance, max_spawn_distance)
			if randf() < 0.5:
				offset_x = -offset_x
			pos = player_ref.global_position + Vector2(offset_x, -200.0)
	return pos


func _get_current_interval() -> float:
	var interval: float = spawn_interval
	if decrease_interval_over_time:
		var scaled: float = spawn_interval - float(total_spawned) * interval_decrease_rate
		interval = maxf(scaled, minimum_interval)
	return interval


# ═══════════════════════════════════════════════════════════════════════
#  CLEANUP
# ═══════════════════════════════════════════════════════════════════════

func _cleanup_dead_enemies() -> void:
	var valid: Array[Node] = []
	for e: Node in active_enemies:
		if is_instance_valid(e):
			valid.append(e)
	if valid.size() != active_enemies.size():
		active_enemies = valid
		enemy_count_changed.emit(active_enemies.size())


func _on_enemy_died(enemy: Node) -> void:
	active_enemies.erase(enemy)
	enemy_count_changed.emit(active_enemies.size())


# ═══════════════════════════════════════════════════════════════════════
#  PUBLIC CONTROLS
# ═══════════════════════════════════════════════════════════════════════

func start_spawning() -> void:
	is_active = true


func stop_spawning() -> void:
	is_active = false


func kill_all() -> void:
	for e: Node in active_enemies:
		if is_instance_valid(e) and e.has_method("take_damage"):
			e.take_damage(9999.0)
	active_enemies.clear()
	enemy_count_changed.emit(0)


func get_alive_count() -> int:
	_cleanup_dead_enemies()
	return active_enemies.size()


func get_total_spawned() -> int:
	return total_spawned
