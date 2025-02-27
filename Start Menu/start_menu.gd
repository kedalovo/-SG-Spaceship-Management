extends Control


const CURSOR_NORMAL = preload("res://UI/Cursor normal.png")
const CURSOR_POINTER = preload("res://UI/Cursor pointer.png")


@onready var noise: TextureRect = $"Background Container/Noise"
@onready var noise_2: TextureRect = $"Background Container/Noise 2"


var loading_progress: Array = []

var is_loading_game: bool = false


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND)
	noise.texture.noise.seed = randi()
	noise_2.texture.noise.seed = randi()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func _process(_delta: float) -> void:
	if is_loading_game:
		ResourceLoader.load_threaded_get_status("res://Game Scene/game.tscn", loading_progress)
		print(loading_progress)


func quit_game() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func _on_start_button_pressed() -> void:
	ResourceLoader.load_threaded_request("res://Game Scene/game.tscn")
	is_loading_game = true


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_tutorial_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	quit_game()
