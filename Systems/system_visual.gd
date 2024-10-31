extends Sprite2D


signal system_pressed(idx)


@export var system_index: int

@onready var outline: Sprite2D = $Outline

var is_mouse_inside: bool


func _on_mouse_area_mouse_entered() -> void:
	if (!GameManager.is_in_system):
		outline.show()
		is_mouse_inside = true


func _on_mouse_area_mouse_exited() -> void:
	if (!GameManager.is_in_system):
		outline.hide()
		is_mouse_inside = false


func _on_mouse_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and is_mouse_inside:
		system_pressed.emit(system_index)
		outline.hide()
		is_mouse_inside = false
