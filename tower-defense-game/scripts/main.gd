## Main game scene - handles camera, grid rendering, and game initialization
extends Node2D
class_name Main

var game_manager: GameManager
var grid_config: GridConfig
var camera: Camera2D

# Camera settings
var camera_speed: float = 300.0  # pixels per second
var zoom_min: float = 0.5
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

func _ready():
	# Initialize managers
	game_manager = GameManager.new()
	add_child(game_manager)
	grid_config = GridConfig.new()

	# Setup camera
	camera = Camera2D.new()
	add_child(camera)
	camera.zoom = Vector2(1.0, 1.0)
	center_camera()

	# Add grid renderer
	var grid_renderer = GridRenderer.new()
	add_child(grid_renderer)

	# Connect game manager signals
	game_manager.gold_changed.connect(_on_gold_changed)
	game_manager.wave_changed.connect(_on_wave_changed)
	game_manager.enemy_escaped.connect(_on_enemy_escaped)
	game_manager.game_over.connect(_on_game_over)

	print("Game initialized - Grid: 100x20")
	print("Use Arrow Keys to move camera")
	print("Use Mouse Wheel to zoom")

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

func _input(event: InputEvent):
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom += Vector2(zoom_speed, zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
			get_tree().root.set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
			get_tree().root.set_input_as_handled()

func center_camera():
	var grid_center_x = (grid_config.GRID_WIDTH * grid_config.CELL_SIZE) / 2
	var grid_center_y = (grid_config.GRID_HEIGHT * grid_config.CELL_SIZE) / 2
	camera.global_position = Vector2(grid_center_x, grid_center_y)

## Signal callbacks
func _on_gold_changed(new_gold: int):
	print("Gold: %d" % new_gold)

func _on_wave_changed(wave_number: int):
	print("Wave %d started" % wave_number)

func _on_enemy_escaped(count: int = -1):
	print("Enemy escaped! Total escaped: %d" % game_manager.escaped_enemies)

func _on_game_over(reason: String):
	print("Game Over: %s" % reason)
