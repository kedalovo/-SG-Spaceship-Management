extends Control


@onready var button_press_audio: AudioStreamPlayer = $"Button Press Audio"
@onready var button_hover_audio: AudioStreamPlayer = $"Button Hover Audio"


func _on_menu_button_pressed() -> void:
	button_press_audio.play()
	get_tree().change_scene_to_file("res://Start Menu/start_menu.tscn")


func _on_menu_button_mouse_entered() -> void:
	button_hover_audio.play()


func _on_exit_button_pressed() -> void:
	button_press_audio.play()
	print("Game closed")
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func _on_exit_button_mouse_entered() -> void:
	button_hover_audio.play()
