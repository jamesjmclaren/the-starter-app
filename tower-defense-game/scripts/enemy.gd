## Enemy entity - handles movement, combat, and behavior
extends Node2D
class_name Enemy

var enemy_data: EnemyData.EnemyInstance
var grid_config: GridConfig
var pathfinder: Pathfinder
var game_manager: GameManager

# Movement
var waypoints: Array[Vector2i] = []
var current_path: Array[Vector2i] = []
var current_path_index: int = 0
var is_moving: bool = false

# Combat
var attacking_tower: TowerData.Tower = null
var attack_cooldown: float = 0.0
var attack_damage_per_frame: float = 1.0  # Damage dealt to towers

# Visual
var circle_radius: float = 12.0
var color: Color = Color.WHITE

func _init(unit_type: EnemyData.UnitType, grid_pos: Vector2i, grid: GridConfig, pathfinder_ref: Pathfinder, game_mgr: GameManager):
	enemy_data = EnemyData.EnemyInstance.new(unit_type, grid_pos)
	grid_config = grid
	pathfinder = pathfinder_ref
	game_manager = game_mgr

	# Set color based on unit type
	match unit_type:
		EnemyData.UnitType.WALKER:
			color = Color.CYAN
		EnemyData.UnitType.FLYER:
			color = Color.MAGENTA

	# Set up waypoints (top -> middle -> bottom)
	waypoints = [grid_config.spawn_point, grid_config.point_b, grid_config.point_c]

	position = grid_config.grid_to_pixel(grid_pos) + Vector2(grid_config.CELL_SIZE / 2, grid_config.CELL_SIZE / 2)

func _ready():
	calculate_path()

func _process(delta):
	if enemy_data.is_dead():
		queue_free()
		return

	if is_moving:
		move_along_path(delta)
	elif attacking_tower and attacking_tower.is_destroyed():
		# Tower was destroyed, recalculate path
		attacking_tower = null
		calculate_path()
	elif attacking_tower:
		# Keep attacking tower
		attack_tower(delta)
	else:
		# Check if we reached the end
		if current_path_index >= current_path.size():
			reached_destination()
			return

		# Try to move to next waypoint
		if current_path.is_empty():
			calculate_path()
		else:
			is_moving = true

func move_along_path(delta):
	if current_path_index >= current_path.size():
		is_moving = false
		return

	var target_grid_pos = current_path[current_path_index]
	var target_pixel_pos = grid_config.grid_to_pixel(target_grid_pos) + Vector2(grid_config.CELL_SIZE / 2, grid_config.CELL_SIZE / 2)
	var direction = (target_pixel_pos - position).normalized()
	var distance_to_target = position.distance_to(target_pixel_pos)

	# Move towards target
	var move_distance = enemy_data.speed * delta
	if distance_to_target <= move_distance:
		position = target_pixel_pos
		enemy_data.grid_pos = target_grid_pos
		current_path_index += 1
	else:
		position += direction * move_distance

func calculate_path():
	if enemy_data.can_fly():
		# Flying units go straight
		current_path = [grid_config.spawn_point, grid_config.point_b, grid_config.point_c]
	else:
		# Ground units use A* pathfinding
		current_path = pathfinder.find_path_with_waypoints(enemy_data.grid_pos, waypoints)

	if current_path.is_empty():
		# Can't find path, try walking around tower
		current_path = [enemy_data.grid_pos]

	current_path_index = 0

func take_damage(amount: int):
	enemy_data.take_damage(amount)
	if enemy_data.is_dead():
		die()

func die():
	game_manager.add_gold(enemy_data.reward_gold)
	queue_free()

func reached_destination():
	game_manager.enemy_escaped_point_c()
	queue_free()

## Start attacking a tower (called when path is blocked)
func start_attacking_tower(tower: TowerData.Tower):
	if not enemy_data.can_fly():
		attacking_tower = tower
		is_moving = false

func attack_tower(delta):
	if attacking_tower == null:
		return

	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		attacking_tower.take_damage(int(attack_damage_per_frame))
		attack_cooldown = 0.5  # Attack every 0.5 seconds

		if attacking_tower.is_destroyed():
			attacking_tower = null
			calculate_path()

func _draw():
	# Draw health bar above unit
	var health_percent = float(enemy_data.health) / float(enemy_data.max_health)
	var health_bar_width = 20.0
	var health_bar_height = 4.0

	draw_rect(Rect2(-health_bar_width / 2, -circle_radius - 10, health_bar_width, health_bar_height), Color.RED)
	draw_rect(Rect2(-health_bar_width / 2, -circle_radius - 10, health_bar_width * health_percent, health_bar_height), Color.GREEN)

	# Draw unit circle
	draw_circle(Vector2.ZERO, circle_radius, color)
	queue_redraw()
