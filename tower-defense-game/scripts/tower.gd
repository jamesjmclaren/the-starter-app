## Tower entity - handles placement, targeting, and attacks
extends Node2D
class_name Tower

var tower_data: TowerData.Tower
var grid_config: GridConfig
var game_manager: GameManager
var pathfinder: Pathfinder

# Combat
var target: Enemy = null
var attack_cooldown: float = 0.0
var enemies_in_range: Array[Enemy] = []

# Visual
var tower_size: float = 16.0
var range_circle_visible: bool = false

func _init(tower_type: TowerData.TowerType, grid_pos: Vector2i, grid: GridConfig, game_mgr: GameManager, pathfinder_ref: Pathfinder):
	tower_data = TowerData.Tower.new(tower_type, grid_pos)
	grid_config = grid
	game_manager = game_mgr
	pathfinder = pathfinder_ref

	# Set position to center of grid cell
	position = grid_config.grid_to_pixel(grid_pos) + Vector2(grid_config.CELL_SIZE / 2, grid_config.CELL_SIZE / 2)

	# Register tower in pathfinder (blocks cell)
	pathfinder.register_tower(grid_pos)

func _process(delta):
	if tower_data.is_destroyed():
		# Remove tower from pathfinder
		pathfinder.unregister_tower(tower_data.grid_pos)
		queue_free()
		return

	# Update target
	if target == null or target.is_queued_for_deletion() or not is_in_range(target):
		find_target()

	# Attack current target
	if target != null and is_in_range(target):
		attack_target(delta)
	else:
		attack_cooldown = 0.0

	queue_redraw()

func find_target():
	target = null
	var closest_distance = tower_data.range
	var closest_enemy: Enemy = null

	# Find closest enemy in range
	for enemy in enemies_in_range:
		if not enemy.is_queued_for_deletion():
			var distance = position.distance_to(enemy.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

	target = closest_enemy

func is_in_range(enemy: Enemy) -> bool:
	return position.distance_to(enemy.position) <= tower_data.range

func attack_target(delta):
	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		target.take_damage(tower_data.damage)
		attack_cooldown = 1.0 / tower_data.attack_speed

func take_damage(amount: int):
	tower_data.take_damage(amount)

func _on_area_entered(area: Area2D):
	if area is Enemy:
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D):
	if area is Enemy:
		enemies_in_range.erase(area)
		if target == area:
			target = null

func _draw():
	# Draw tower
	draw_circle(Vector2.ZERO, tower_size, Color.YELLOW)

	# Draw health indicator
	var health_percent = float(tower_data.health) / float(tower_data.max_health)
	draw_circle(Vector2.ZERO, tower_size - 2, Color(health_percent, 0, 0, 0.5))

	# Draw range circle if showing
	if range_circle_visible:
		draw_circle(Vector2.ZERO, tower_data.range, Color(1, 1, 0, 0.2))

	# Draw targeting line to target
	if target != null and is_in_range(target):
		draw_line(Vector2.ZERO, (target.position - position).normalized() * tower_data.range, Color.RED, 1.0)
