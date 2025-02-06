extends Sprite2D


signal system_pressed(idx)


@export var system_index: int

@onready var outline: Sprite2D = $Outline
@onready var warning_light: AnimatedSprite2D = $"Warning Light"
@onready var light: PointLight2D = $"Warning Light/Light"
@onready var animator: AnimationPlayer = $"Warning Light/Light/Animator"


var is_mouse_inside: bool
var is_damaged: bool
var is_crazy: bool


func damage() -> void:
	if !is_damaged:
		is_damaged = true
		if !is_crazy:
			warning_light.play(&"warning")
			light.show()
			animator.play(&"idle")


func fix() -> void:
	if is_damaged:
		is_damaged = false
		if !is_crazy:
			warning_light.play(&"default")
			light.hide()
			animator.stop()


func toggle_crazy(on: bool) -> void:
	is_crazy = on
	match on:
		true:
			warning_light.play(&"warning")
			light.show()
			animator.play(&"crazy")
			animator.speed_scale = 1.0 + randf()
		false:
			animator.speed_scale = 1.0
			if is_damaged:
				warning_light.play(&"warning")
				light.show()
				animator.play(&"idle")
			else:
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
