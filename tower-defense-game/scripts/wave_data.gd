## Wave configuration data
class_name WaveData

class Wave:
	var wave_number: int
	var units: Array[EnemyData.UnitType] = []
	var spawn_delay: float = 0.5  # seconds between each unit spawn

	func _init(p_wave_number: int, p_units: Array[EnemyData.UnitType]):
		wave_number = p_wave_number
		units = p_units

	func get_unit_count() -> int:
		return units.size()

## Wave configuration matrix - easy to modify
## Format: Array of unit types that spawn in each wave
var waves: Array[Array] = [
	# Wave 1: 5 walkers
	[EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER],

	# Wave 2: 3 walkers, 2 flyers
	[EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER],

	# Wave 3: 8 walkers, 2 flyers
	[EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER],

	# Wave 4: 10 walkers, 4 flyers
	[EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER,
	 EnemyData.UnitType.FLYER],

	# Wave 5: 15 walkers, 5 flyers
	[EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER, EnemyData.UnitType.WALKER,
	 EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER,
	 EnemyData.UnitType.FLYER, EnemyData.UnitType.FLYER],
]

func get_wave(wave_number: int) -> Wave:
	if wave_number < 0 or wave_number >= waves.size():
		# Generate infinite scaling waves
		var base_units = waves[-1].size()
		var additional_units = (wave_number - waves.size() + 1) * 5
		var new_wave_units: Array[EnemyData.UnitType] = []

		# Add mostly walkers with some flyers
		var walker_count = base_units * 2 + additional_units
		var flyer_count = base_units / 2 + additional_units / 2

		for i in range(walker_count):
			new_wave_units.append(EnemyData.UnitType.WALKER)
		for i in range(flyer_count):
			new_wave_units.append(EnemyData.UnitType.FLYER)

		return Wave.new(wave_number, new_wave_units)

	return Wave.new(wave_number, waves[wave_number])
