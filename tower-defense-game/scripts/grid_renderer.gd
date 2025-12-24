## Grid renderer - draws the 100x20 grid with waypoints
extends CanvasLayer
class_name GridRenderer

var grid_config: GridConfig
var grid_texture: CanvasItem

func _ready():
	grid_config = GridConfig.new()
	queue_redraw()

func _draw():
	if grid_config == null:
		return

	var cell_size = grid_config.CELL_SIZE
	var grid_width = grid_config.GRID_WIDTH
	var grid_height = grid_config.GRID_HEIGHT
	var grid_color = Color(0.3, 0.3, 0.3, 0.5)
	var waypoint_color = Color.YELLOW
	var waypoint_size = 8

	# Draw grid lines
	for x in range(grid_width + 1):
		var start = Vector2(x * cell_size, 0)
		var end = Vector2(x * cell_size, grid_height * cell_size)
		draw_line(start, end, grid_color, 1.0)

	for y in range(grid_height + 1):
		var start = Vector2(0, y * cell_size)
		var end = Vector2(grid_width * cell_size, y * cell_size)
		draw_line(start, end, grid_color, 1.0)

	# Draw waypoints
	var spawn_pixel = grid_config.grid_to_pixel(grid_config.spawn_point)
	var point_b_pixel = grid_config.grid_to_pixel(grid_config.point_b)
	var point_c_pixel = grid_config.grid_to_pixel(grid_config.point_c)

	draw_circle(spawn_pixel + Vector2(cell_size / 2, cell_size / 2), waypoint_size, Color.RED)
	draw_circle(point_b_pixel + Vector2(cell_size / 2, cell_size / 2), waypoint_size, Color.GREEN)
	draw_circle(point_c_pixel + Vector2(cell_size / 2, cell_size / 2), waypoint_size, Color.BLUE)

	# Draw waypoint labels
	draw_string(ThemeDB.fallback_font, spawn_pixel + Vector2(cell_size / 2 + 15, cell_size / 2), "Spawn", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.RED)
	draw_string(ThemeDB.fallback_font, point_b_pixel + Vector2(cell_size / 2 + 15, cell_size / 2), "Point B", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.GREEN)
	draw_string(ThemeDB.fallback_font, point_c_pixel + Vector2(cell_size / 2 + 15, cell_size / 2), "Point C", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.BLUE)
