extends Sprite2D


signal system_pressed(idx)


@export var system_index: int

@onready var outline: Sprite2D = $Outline

var is_mouse_inside: bool


func _on_button_mouse_entered() -> void:
	if (!GameManager.is_in_system):
		outline.show()


func _on_button_mouse_exited() -> void:
	if (!GameManager.is_in_system):
		outline.hide()


func _on_button_pressed() -> void:
	system_pressed.emit(system_index)
	outline.hide()
