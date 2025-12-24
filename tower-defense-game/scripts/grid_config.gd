## Grid configuration for the tower defense game
class_name GridConfig

const GRID_WIDTH: int = 100
const GRID_HEIGHT: int = 20
const CELL_SIZE: int = 32  # pixels per cell

## Waypoint positions in grid coordinates
var spawn_point: Vector2i = Vector2i(50, 0)      # Top middle
var point_b: Vector2i = Vector2i(50, 10)         # Middle
var point_c: Vector2i = Vector2i(50, 19)         # Bottom

## Convert grid coordinates to pixel coordinates
func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos) * CELL_SIZE

## Convert pixel coordinates to grid coordinates
func pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	return (pixel_pos / CELL_SIZE).round()

## Check if a grid position is within bounds
func is_valid_grid_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_WIDTH and pos.y >= 0 and pos.y < GRID_HEIGHT
