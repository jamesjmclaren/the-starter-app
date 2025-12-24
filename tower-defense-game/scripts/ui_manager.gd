## UI Manager - displays game information and UI elements
extends CanvasLayer
class_name UIManager

var game_manager: GameManager
var main: Main

# UI Labels
var gold_label: Label
var wave_label: Label
var escaped_label: Label
var instructions_label: Label
var game_over_label: Label
var wave_complete_label: Label

func _init(game_mgr: GameManager, main_ref: Main):
	game_manager = game_mgr
	main = main_ref

func _ready():
	# Create labels
	gold_label = Label.new()
	add_child(gold_label)
	gold_label.text = "💰 Gold: 500"
	gold_label.anchor_left = 0.0
	gold_label.anchor_top = 0.0
	gold_label.offset_left = 10
	gold_label.offset_top = 10
	gold_label.add_theme_font_size_override("font_size", 16)

	wave_label = Label.new()
	add_child(wave_label)
	wave_label.text = "🌊 Wave: 0"
	wave_label.anchor_left = 0.0
	wave_label.anchor_top = 0.0
	wave_label.offset_left = 10
	wave_label.offset_top = 35
	wave_label.add_theme_font_size_override("font_size", 16)

	escaped_label = Label.new()
	add_child(escaped_label)
	escaped_label.text = "⚠️ Escaped: 0/50"
	escaped_label.anchor_left = 0.0
	escaped_label.anchor_top = 0.0
	escaped_label.offset_left = 10
	escaped_label.offset_top = 60
	escaped_label.add_theme_font_size_override("font_size", 16)

	instructions_label = Label.new()
	add_child(instructions_label)
	instructions_label.text = "SPACE: Start Wave | CLICK: Place Tower (100g) | ARROW KEYS: Move | SCROLL: Zoom"
	instructions_label.anchor_left = 0.0
	instructions_label.anchor_top = 1.0
	instructions_label.anchor_right = 1.0
	instructions_label.offset_top = -30
	instructions_label.add_theme_font_size_override("font_size", 12)
	instructions_label.alignment = TextServer.HORIZONTAL_ALIGNMENT_CENTER

	wave_complete_label = Label.new()
	add_child(wave_complete_label)
	wave_complete_label.text = ""
	wave_complete_label.anchor_left = 0.5
	wave_complete_label.anchor_top = 0.5
	wave_complete_label.anchor_right = 0.5
	wave_complete_label.anchor_bottom = 0.5
	wave_complete_label.offset_left = -100
	wave_complete_label.offset_top = -50
	wave_complete_label.add_theme_font_size_override("font_size", 24)
	wave_complete_label.modulate.a = 0.0

	game_over_label = Label.new()
	add_child(game_over_label)
	game_over_label.text = ""
	game_over_label.anchor_left = 0.5
	game_over_label.anchor_top = 0.5
	game_over_label.anchor_right = 0.5
	game_over_label.anchor_bottom = 0.5
	game_over_label.offset_left = -150
	game_over_label.offset_top = -100
	game_over_label.add_theme_font_size_override("font_size", 32)
	game_over_label.modulate.a = 0.0

	# Connect signals
	game_manager.gold_changed.connect(_on_gold_changed)
	game_manager.wave_changed.connect(_on_wave_changed)
	game_manager.enemy_escaped.connect(_on_enemy_escaped)
	game_manager.game_over.connect(_on_game_over)

func _on_gold_changed(new_gold: int):
	gold_label.text = "💰 Gold: %d" % new_gold

func _on_wave_changed(wave_number: int):
	wave_label.text = "🌊 Wave: %d" % wave_number
	wave_complete_label.modulate.a = 0.0

func _on_enemy_escaped():
	escaped_label.text = "⚠️ Escaped: %d/50" % game_manager.escaped_enemies

func _on_game_over(reason: String):
	game_over_label.text = reason
	game_over_label.modulate.a = 1.0
	game_manager.is_running = false

func show_wave_complete():
	wave_complete_label.text = "✨ WAVE COMPLETE! ✨\nPress SPACE for next wave"
	wave_complete_label.modulate.a = 1.0

func hide_wave_complete():
	wave_complete_label.modulate.a = 0.0
