## Enemy data structure
class_name EnemyData

enum UnitType { WALKER, FLYER }

class EnemyInstance:
	var type: UnitType
	var health: int
	var max_health: int
	var speed: float  # pixels per second
	var reward_gold: int
	var grid_pos: Vector2i
	var path: Array[Vector2i] = []
	var current_path_index: int = 0

	func _init(p_type: UnitType, p_grid_pos: Vector2i):
		type = p_type
		grid_pos = p_grid_pos

		match type:
			UnitType.WALKER:
				health = 20
				max_health = 20
				speed = 30.0  # pixels per second
				reward_gold = 10
			UnitType.FLYER:
				health = 15
				max_health = 15
				speed = 50.0  # pixels per second (faster)
				reward_gold = 15

	func take_damage(amount: int):
		health -= amount

	func is_dead() -> bool:
		return health <= 0

	func can_fly() -> bool:
		return type == UnitType.FLYER

## Enemy registry - easy to add more unit types later
var unit_types = {
	EnemyData.UnitType.WALKER: {
		"name": "Walker",
		"health": 20,
		"speed": 30.0,
		"reward": 10
	},
	EnemyData.UnitType.FLYER: {
		"name": "Flyer",
		"health": 15,
		"speed": 50.0,
		"reward": 15
	}
}
