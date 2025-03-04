extends Control


var was_in_map: bool = false
var was_just_unpaused: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		continue_game()


func continue_game() -> void:
	was_just_unpaused = true
	hide()
	if was_in_map:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		was_in_map = false
	get_tree().paused = false


func _on_continue_button_pressed() -> void:
	continue_game()


func _on_exit_button_pressed() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()
