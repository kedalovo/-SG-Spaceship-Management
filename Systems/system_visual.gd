extends Sprite2D


signal system_pressed(idx: int)
signal system_hovered(idx: int)

@export var system_index: int

@onready var outline: Sprite2D = $Outline
@onready var warning_light: AnimatedSprite2D = $"Warning Light"
@onready var light: PointLight2D = $"Warning Light/Light"
@onready var animator: AnimationPlayer = $"Warning Light/Light/Animator"
@onready var sound: AudioStreamPlayer2D = $"Warning Light/Sound"


var is_mouse_inside: bool
var is_damaged: bool
var is_crazy: bool
var enabled: bool = true


func damage() -> void:
	if !is_damaged:
		is_damaged = true
		if !is_crazy:
			warning_light.play(&"warning")
			sound.play()
			light.show()
			animator.play(&"idle")


func fix() -> void:
	if is_damaged:
		is_damaged = false
		if !is_crazy:
			warning_light.play(&"default")
			sound.stop()
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
				sound.stop()
				light.hide()
				animator.stop()


func _on_button_mouse_entered() -> void:
	if (!GameManager.is_in_system and enabled):
		system_hovered.emit(system_index)
		outline.show()


func _on_button_mouse_exited() -> void:
	if (!GameManager.is_in_system):
		outline.hide()


func _on_button_pressed() -> void:
	if enabled:
		system_pressed.emit(system_index)
		outline.hide()
