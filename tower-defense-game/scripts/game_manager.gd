## GameManager - Singleton that manages game state, currency, and progression
extends Node
class_name GameManager

# Singleton
var _instance: GameManager

func _enter_tree():
	if _instance == null:
		_instance = self
		add_to_group("game_manager")
	else:
		queue_free()

# Game state
var is_running: bool = false
var is_paused: bool = false
var current_wave: int = 0
var escaped_enemies: int = 0
var defeated: bool = false

# Currency
var gold: int = 500  # Starting gold
var gold_per_interest: float = 1.1  # 10% interest on saved gold each wave
var gold_earned_this_wave: int = 0

# Grid reference
var grid_config: GridConfig = GridConfig.new()

# Signals
signal gold_changed(new_gold: int)
signal wave_changed(wave_number: int)
signal enemy_escaped
signal game_over(reason: String)
signal game_started

func _ready():
	add_child(self) if not is_in_group("game_manager") else null

## Start a new game
func start_game():
	is_running = true
	is_paused = false
	current_wave = 0
	escaped_enemies = 0
	defeated = false
	gold = 500
	gold_earned_this_wave = 0
	game_started.emit()
	next_wave()

## Move to next wave
func next_wave():
	current_wave += 1

	# Apply interest to remaining gold
	var interest_gain = int(gold * (gold_per_interest - 1.0))
	gold += interest_gain

	gold_earned_this_wave = 0
	wave_changed.emit(current_wave)

## Add gold when enemy dies
func add_gold(amount: int):
	gold += amount
	gold_earned_this_wave += amount
	gold_changed.emit(gold)

## Remove gold when tower placed
func remove_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

## Track escaped enemy
func enemy_escaped_point_c():
	escaped_enemies += 1
	enemy_escaped.emit()

	if escaped_enemies >= 50:
		defeated = true
		is_running = false
		game_over.emit("50 enemies escaped!")

## Get current wave configuration
func get_current_wave_units() -> Array[EnemyData.UnitType]:
	var wave_data = WaveData.new()
	var wave = wave_data.get_wave(current_wave - 1)
	return wave.units

## Pause/unpause game
func toggle_pause():
	if is_running:
		is_paused = !is_paused
		get_tree().paused = is_paused

func pause_game():
	if is_running:
		is_paused = true
		get_tree().paused = true

func resume_game():
	is_paused = false
	get_tree().paused = false
