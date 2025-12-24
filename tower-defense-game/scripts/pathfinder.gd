## A* Pathfinding algorithm for ground units
extends Object
class_name Pathfinder

class Node:
	var position: Vector2i
	var g_cost: float  # Distance from start
	var h_cost: float  # Heuristic distance to goal
	var parent: Node = null

	func f_cost() -> float:
		return g_cost + h_cost

	func _init(pos: Vector2i, g: float, h: float):
		position = pos
		g_cost = g
		h_cost = h

var grid_config: GridConfig
var occupied_cells: Dictionary = {}  # Grid positions occupied by towers

func _init(grid: GridConfig):
	grid_config = grid

## Register a tower at a grid position (marks cell as occupied)
func register_tower(grid_pos: Vector2i):
	occupied_cells[grid_pos] = true

## Unregister a tower (marks cell as unoccupied)
func unregister_tower(grid_pos: Vector2i):
	occupied_cells.erase(grid_pos)

## Check if a cell is walkable (not occupied and within bounds)
func is_walkable(grid_pos: Vector2i) -> bool:
	if not grid_config.is_valid_grid_pos(grid_pos):
		return false
	if occupied_cells.has(grid_pos):
		return false
	return true

## Get neighbors for a grid position (4-directional movement)
func get_neighbors(grid_pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for dir in directions:
		var neighbor = grid_pos + dir
		if is_walkable(neighbor):
			neighbors.append(neighbor)

	return neighbors

## Heuristic function (Manhattan distance)
func heuristic(pos: Vector2i, goal: Vector2i) -> float:
	return float(abs(pos.x - goal.x) + abs(pos.y - goal.y))

## Find path from start to goal using A*
func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	if not is_walkable(start) or not is_walkable(goal):
		return []

	var open_set: Array[Node] = []
	var closed_set: Dictionary = {}
	var start_node = Node.new(start, 0.0, heuristic(start, goal))
	open_set.append(start_node)

	while open_set.size() > 0:
		# Find node with lowest f_cost
		var current_idx = 0
		for i in range(open_set.size()):
			if open_set[i].f_cost() < open_set[current_idx].f_cost():
				current_idx = i

		var current = open_set[current_idx]

		if current.position == goal:
			return reconstruct_path(current)

		open_set.remove_at(current_idx)
		closed_set[current.position] = true

		for neighbor_pos in get_neighbors(current.position):
			if closed_set.has(neighbor_pos):
				continue

			var tentative_g = current.g_cost + 1.0
			var neighbor_node = null

			# Check if neighbor is already in open_set
			for node in open_set:
				if node.position == neighbor_pos:
					neighbor_node = node
					break

			if neighbor_node == null:
				neighbor_node = Node.new(neighbor_pos, tentative_g, heuristic(neighbor_pos, goal))
				open_set.append(neighbor_node)
			elif tentative_g < neighbor_node.g_cost:
				neighbor_node.g_cost = tentative_g

			neighbor_node.parent = current

	return []  # No path found

## Reconstruct path from goal node back to start
func reconstruct_path(node: Node) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = node

	while current != null:
		path.insert(0, current.position)
		current = current.parent

	return path

## Simplified pathfinding that returns waypoints through key points
func find_path_with_waypoints(start: Vector2i, waypoints: Array[Vector2i]) -> Array[Vector2i]:
	var full_path: Array[Vector2i] = []

	for i in range(waypoints.size()):
		var from = start if i == 0 else waypoints[i - 1]
		var to = waypoints[i]
		var segment = find_path(from, to)

		if segment.is_empty():
			return []  # No path possible

		# Avoid duplicates at junction points
		if i > 0:
			segment.remove_at(0)

		full_path.append_array(segment)

	return full_path
