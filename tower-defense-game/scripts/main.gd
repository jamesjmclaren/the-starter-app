## Main game scene - handles camera, grid rendering, and game initialization
extends Node2D
class_name Main

var game_manager: GameManager
var grid_config: GridConfig
var camera: Camera2D
var pathfinder: Pathfinder
var ui_manager: UIManager
var start_screen: StartScreen

# Game entities
var towers: Array[Tower] = []
var enemies: Array[Enemy] = []
var spawned_enemies: int = 0
var current_wave_units: Array[EnemyData.UnitType] = []

# Spawning
var spawn_timer: float = 0.0
var spawn_delay: float = 0.5
var wave_started: bool = false
var wave_in_progress: bool = false

# Camera settings
var camera_speed: float = 300.0  # pixels per second
var zoom_min: float = 0.5
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

# Game states
enum GameState { MENU, PLAYING, WAVE_COMPLETE, GAME_OVER }
var current_state: GameState = GameState.MENU

func _ready():
	# Initialize managers
	game_manager = GameManager.new()
	add_child(game_manager)
	grid_config = GridConfig.new()
	pathfinder = Pathfinder.new(grid_config)

	# Setup camera
	camera = Camera2D.new()
	add_child(camera)
	camera.zoom = Vector2(1.0, 1.0)
	center_camera()

	# Add grid renderer
	var grid_renderer = GridRenderer.new()
	add_child(grid_renderer)

	# Add UI Manager
	ui_manager = UIManager.new(game_manager, self)
	add_child(ui_manager)

	# Add start screen
	start_screen = StartScreen.new()
	add_child(start_screen)
	start_screen.start_pressed.connect(_on_start_screen_pressed)

	# Connect game manager signals
	game_manager.gold_changed.connect(_on_gold_changed)
	game_manager.wave_changed.connect(_on_wave_changed)
	game_manager.enemy_escaped.connect(_on_enemy_escaped)
	game_manager.game_over.connect(_on_game_over)

	print("🎮 Tower Defense Game Initialized")
	print("Grid: 100x20 | Defeat at: 50 enemies escape")
	print("Starting game...")
	current_state = GameState.MENU

func _process(delta):
	if camera == null:
		return

	# Handle camera movement
	var camera_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		camera_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		camera_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		camera_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		camera_direction.x += 1

	if camera_direction != Vector2.ZERO:
		camera.global_position += camera_direction.normalized() * camera_speed * delta

	# Clamp camera to grid bounds
	var grid_width = grid_config.GRID_WIDTH * grid_config.CELL_SIZE
	var grid_height = grid_config.GRID_HEIGHT * grid_config.CELL_SIZE
	var viewport_size = get_viewport_rect().size / camera.zoom

	var min_x = viewport_size.x / 2
	var max_x = grid_width - viewport_size.x / 2
	var min_y = viewport_size.y / 2
	var max_y = grid_height - viewport_size.y / 2

	camera.global_position.x = clamp(camera.global_position.x, min_x, max_x)
	camera.global_position.y = clamp(camera.global_position.y, min_y, max_y)

	# Game loop
	match current_state:
		GameState.PLAYING:
			update_spawning(delta)
		GameState.WAVE_COMPLETE:
			check_wave_complete()

func _input(event: InputEvent):
	# Always allow camera controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom += Vector2(zoom_speed, zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
			get_tree().root.set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
			get_tree().root.set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if current_state == GameState.PLAYING:
				place_tower_at_mouse()
			get_tree().root.set_input_as_handled()

	# Handle SPACE based on game state
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		match current_state:
			GameState.MENU:
				pass  # Handled by start_screen
			GameState.PLAYING:
				if not wave_in_progress:
					game_manager.next_wave()
					get_tree().root.set_input_as_handled()
			GameState.WAVE_COMPLETE:
				game_manager.next_wave()
				current_state = GameState.PLAYING
				ui_manager.hide_wave_complete()
				get_tree().root.set_input_as_handled()
			GameState.GAME_OVER:
				# Restart game
				get_tree().reload_current_scene()
				get_tree().root.set_input_as_handled()

func place_tower_at_mouse():
	if not game_manager.is_running:
		return

	# Get mouse position in world space
	var mouse_pos = get_global_mouse_position()
	var grid_pos = grid_config.pixel_to_grid(mouse_pos)

	# Validate tower placement
	if not grid_config.is_valid_grid_pos(grid_pos):
		print("Tower placement out of bounds")
		return

	if not pathfinder.is_walkable(grid_pos):
		print("Tower already placed here")
		return

	# Try to pay for tower
	if not game_manager.remove_gold(100):
		print("Not enough gold")
		return

	# Place tower
	var tower = Tower.new(TowerData.TowerType.ARROW, grid_pos, grid_config, game_manager, pathfinder)
	add_child(tower)
	towers.append(tower)

	# Recalculate paths for all enemies (tower blocks path)
	for enemy in enemies:
		if not enemy.enemy_data.can_fly():
			enemy.calculate_path()

	print("Tower placed at grid (%d, %d)" % [grid_pos.x, grid_pos.y])

func update_spawning(delta):
	if not wave_in_progress:
		return

	spawn_timer -= delta
	if spawn_timer <= 0.0 and spawned_enemies < current_wave_units.size():
		# Spawn next enemy
		var unit_type = current_wave_units[spawned_enemies]
		var enemy = Enemy.new(unit_type, grid_config.spawn_point, grid_config, pathfinder, game_manager)
		add_child(enemy)
		enemies.append(enemy)
		spawned_enemies += 1
		spawn_timer = spawn_delay

		# If all enemies spawned, check for completion
		if spawned_enemies >= current_wave_units.size():
			wave_in_progress = false

func check_wave_complete():
	# Check if all enemies are gone
	enemies = enemies.filter(func(e): return not e.is_queued_for_deletion())
	if enemies.is_empty() and not wave_in_progress:
		print("✨ Wave complete! Press SPACE for next wave")
		current_state = GameState.WAVE_COMPLETE
		ui_manager.show_wave_complete()

func center_camera():
	var grid_center_x = (grid_config.GRID_WIDTH * grid_config.CELL_SIZE) / 2
	var grid_center_y = (grid_config.GRID_HEIGHT * grid_config.CELL_SIZE) / 2
	camera.global_position = Vector2(grid_center_x, grid_center_y)

## Signal callbacks
func _on_start_screen_pressed():
	current_state = GameState.PLAYING
	game_manager.start_game()

func _on_gold_changed(new_gold: int):
	pass  # UI Manager handles display

func _on_wave_changed(wave_number: int):
	current_wave_units = game_manager.get_current_wave_units()
	spawned_enemies = 0
	wave_in_progress = true
	spawn_timer = spawn_delay
	print("🌊 Wave %d started! (%d enemies)" % [wave_number, current_wave_units.size()])

func _on_enemy_escaped():
	print("⚠️ Enemy escaped!")

func _on_game_over(reason: String):
	current_state = GameState.GAME_OVER
	print("💀 Game Over: %s" % reason)
	print("Press SPACE to restart")
