## Tower data structure
class_name TowerData

enum TowerType { ARROW }

class Tower:
	var type: TowerType
	var cost: int
	var range: float  # in pixels
	var attack_speed: float  # attacks per second
	var damage: int
	var grid_pos: Vector2i
	var health: int
	var max_health: int

	func _init(p_type: TowerType, p_grid_pos: Vector2i):
		type = p_type
		grid_pos = p_grid_pos

		match type:
			TowerType.ARROW:
				cost = 100
				range = 200.0
				attack_speed = 1.0
				damage = 10
				max_health = 50
				health = max_health

	func take_damage(amount: int):
		health -= amount

	func is_destroyed() -> bool:
		return health <= 0

## Tower registry - easy to add more tower types later
var tower_types = {
	TowerData.TowerType.ARROW: {
		"name": "Arrow Tower",
		"cost": 100,
		"range": 200.0,
		"attack_speed": 1.0,
		"damage": 10,
		"max_health": 50
	}
}
