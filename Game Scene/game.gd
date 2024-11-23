extends Node2D


@onready var life_support_system: system = $"SubViewportContainer/SubViewport/Life Support System"
@onready var engines_system: system = $"SubViewportContainer/SubViewport/Engines System"
@onready var hull_system: system = $"SubViewportContainer/SubViewport/Hull System"
@onready var electrical_system: system = $"SubViewportContainer/SubViewport/Electrical System"
@onready var external_system: system = $"SubViewportContainer/SubViewport/External System"
@onready var computer_system: system = $"SubViewportContainer/SubViewport/Computer System"

@onready var system_container: Control = $"System Container"
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer

@onready var cabin: Node2D = $Cabin
@onready var space: Node2D = $Cabin/SubViewportContainer2/SubViewport/Space

@onready var systems: Array[system] = [
	life_support_system, engines_system, hull_system,
	electrical_system, external_system, computer_system]

var current_system_idx: int = -1

var is_mouse_inside: bool


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		get_tree().quit()
	if event.is_action_pressed(&"test1"):
		pass
	if event.is_action_pressed(&"test"):
		pass
	if event.is_action_pressed(&"left"):
		space.move(Vector2.RIGHT)
	if event.is_action_pressed(&"right"):
		space.move(Vector2.LEFT)
	if event.is_action_pressed(&"up"):
		space.move(Vector2.DOWN)
	if event.is_action_pressed(&"down"):
		space.move(Vector2.UP)


func _on_system_sprite_pressed(system_index: int) -> void:
	if current_system_idx == -1:
		systems[system_index].open()
		current_system_idx = system_index
		GameManager.is_in_system = true
		system_container.show()
		sub_viewport_container.show()


func _on_system_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and GameManager.is_in_system:
		systems[current_system_idx].close()
		GameManager.is_in_system = false
		current_system_idx = -1


func _on_system_animation_finished(is_open: bool) -> void:
	if !is_open:
		system_container.hide()
		sub_viewport_container.hide()
