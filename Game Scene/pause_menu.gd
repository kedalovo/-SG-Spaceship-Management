extends Control

@onready var button_press_audio: AudioStreamPlayer = $"Button Press Audio"
@onready var button_hover_audio: AudioStreamPlayer = $"Button Hover Audio"

var was_in_map: bool = false
var was_just_unpaused: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		continue_game()
	if event.is_action_pressed(&"fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			print("FULLSCREEN: On")
		elif DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			print("FULLSCREEN: Off")


func continue_game() -> void:
	print("PAUSE: Game is unpaused")
	was_just_unpaused = true
	hide()
	if was_in_map:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		was_in_map = false
	get_tree().paused = false


func _on_continue_button_pressed() -> void:
	button_press_audio.play()
	continue_game()


func _on_exit_button_pressed() -> void:
	button_press_audio.play()
	print("Game closed")
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func _on_continue_button_mouse_entered() -> void:
	button_hover_audio.play()


func _on_exit_button_mouse_entered() -> void:
	button_hover_audio.play()
