extends Sprite2D


signal system_pressed(idx)


@export var system_index: int

@onready var outline: Sprite2D = $Outline
@onready var warning_light: AnimatedSprite2D = $"Warning Light"
@onready var light: PointLight2D = $"Warning Light/Light"
@onready var animator: AnimationPlayer = $"Warning Light/Light/Animator"


var is_mouse_inside: bool
var is_damaged: bool


func damage() -> void:
	if !is_damaged:
		is_damaged = true
		warning_light.play(&"warning")
		light.show()
		animator.play(&"idle")


func fix() -> void:
	if is_damaged:
		is_damaged = false
		warning_light.play(&"default")
		light.hide()
		animator.stop()


func _on_button_mouse_entered() -> void:
	if (!GameManager.is_in_system):
		outline.show()


func _on_button_mouse_exited() -> void:
	if (!GameManager.is_in_system):
		outline.hide()


func _on_button_pressed() -> void:
	system_pressed.emit(system_index)
	outline.hide()
