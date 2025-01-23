extends Button


@export var upgrade: game_manager.store_items
@export var is_bottom_button: bool = false
@export var time: float = 3.0

@onready var sprite: Sprite2D = $Sprite
@onready var progress: TextureProgressBar = $Progress
@onready var timer: Timer = $Timer

var sprite_outline: Sprite2D


func _ready() -> void:
	if is_bottom_button:
		sprite_outline = $Sprite/Outline


func _process(_delta: float) -> void:
	progress.value = roundf(time / timer.time_left)


func _on_button_down() -> void:
	timer.start(time)


func _on_button_up() -> void:
	timer.stop()


func _on_mouse_entered() -> void:
	if is_bottom_button:
		sprite_outline.show()
	else:
		sprite.modulate = Color("2dff00")


func _on_mouse_exited() -> void:
	if !timer.is_stopped():
		timer.stop()
	if is_bottom_button:
		sprite_outline.hide()
	else:
		sprite.modulate = Color("378a0c")


func _on_timer_timeout() -> void:
	pass # Replace with function body.
