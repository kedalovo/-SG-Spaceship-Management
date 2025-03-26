extends Control


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
	continue_game()


func _on_exit_button_pressed() -> void:
	print("Game closed")
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()
