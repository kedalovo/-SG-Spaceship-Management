extends Control


const CURSOR_NORMAL = preload("res://UI/Cursor normal.png")
const CURSOR_POINTER = preload("res://UI/Cursor pointer.png")


@onready var noise: TextureRect = $"Background Container/Noise"
@onready var noise_2: TextureRect = $"Background Container/Noise 2"
@onready var progress: ProgressBar = $"Background Container/Margin/VBox/Progress"
@onready var animator: AnimationPlayer = $"Background Container/Animator"

var game_scene: Node

var loading_progress: Array = []

var last_progress: float = 0.0

var is_loading_game: bool = false
var is_finished_loading: bool = false


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND)
	noise.texture.noise.seed = randi()
	noise_2.texture.noise.seed = randi()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		quit_game()
	if event.is_action_pressed(&"fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _process(_delta: float) -> void:
	if is_loading_game:
		ResourceLoader.load_threaded_get_status("res://Game Scene/game.tscn", loading_progress)
		if last_progress < loading_progress[0]:
			last_progress = loading_progress[0]
			var tween: = get_tree().create_tween()
			tween.tween_property(progress, "value", loading_progress[0] * 100, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			if last_progress == 1.0:
				tween.finished.connect(_on_loading_finished)
				game_scene = ResourceLoader.load_threaded_get("res://Game Scene/game.tscn").instantiate()
				is_loading_game = false


func quit_game() -> void:
	print("Game closed")
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func switch_scene() -> void:
	print("Switching scenes...")
	get_tree().set_current_scene(game_scene)
	queue_free()


func _on_loading_finished() -> void:
	get_tree().root.add_child(game_scene)
	get_tree().root.move_child(game_scene, 1)
	animator.play(&"start_game")


func _on_start_button_pressed() -> void:
	print("Starting new game")
	ResourceLoader.load_threaded_request("res://Game Scene/game.tscn")
	is_loading_game = true


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_tutorial_button_pressed() -> void:
	print("Starting tutorial")
	ResourceLoader.load_threaded_request("res://Game Scene/game.tscn")
	is_loading_game = true
	game_manager.is_tutorial = true


func _on_exit_button_pressed() -> void:
	quit_game()


func _on_check_button_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			print("Set locale to russian")
			TranslationServer.set_locale("ru")
		false:
			print("Set locale to english")
			TranslationServer.set_locale("en")
