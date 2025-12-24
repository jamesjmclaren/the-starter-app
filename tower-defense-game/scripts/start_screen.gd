## Start screen - simple menu
extends CanvasLayer
class_name StartScreen

var title_label: Label
var subtitle_label: Label
var instructions_label: Label

signal start_pressed

func _ready():
	# Title
	title_label = Label.new()
	add_child(title_label)
	title_label.text = "🏰 TOWER DEFENSE 🏰"
	title_label.anchor_left = 0.5
	title_label.anchor_top = 0.3
	title_label.anchor_right = 0.5
	title_label.anchor_bottom = 0.3
	title_label.offset_left = -150
	title_label.offset_top = -50
	title_label.add_theme_font_size_override("font_size", 48)

	# Subtitle
	subtitle_label = Label.new()
	add_child(subtitle_label)
	subtitle_label.text = "Build mazes to defend your castle"
	subtitle_label.anchor_left = 0.5
	subtitle_label.anchor_top = 0.42
	subtitle_label.anchor_right = 0.5
	subtitle_label.anchor_bottom = 0.42
	subtitle_label.offset_left = -200
	subtitle_label.offset_top = 0
	subtitle_label.add_theme_font_size_override("font_size", 20)

	# Instructions
	instructions_label = Label.new()
	add_child(instructions_label)
	instructions_label.text = "Press SPACE to begin"
	instructions_label.anchor_left = 0.5
	instructions_label.anchor_top = 0.55
	instructions_label.anchor_right = 0.5
	instructions_label.anchor_bottom = 0.55
	instructions_label.offset_left = -100
	instructions_label.offset_top = 0
	instructions_label.add_theme_font_size_override("font_size", 16)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		hide()
		start_pressed.emit()
		get_tree().root.set_input_as_handled()

func show_menu():
	modulate.a = 1.0

func hide_menu():
	modulate.a = 0.0
