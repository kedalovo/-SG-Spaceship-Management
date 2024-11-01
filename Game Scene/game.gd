extends Node2D


@onready var life_support_system: system = $"Systems/Life Support System"
@onready var engines_system: system = $"Systems/Engines System"
@onready var hull_system: system = $"Systems/Hull System"
@onready var electrical_system: system = $"Systems/Electrical System"
@onready var external_system: system = $"Systems/External System"
@onready var computer_system: system = $"Systems/Computer System"

@onready var system_close_up_marker: Panel = $SystemCloseUpMarker

@onready var systems: Array[system] = [
	life_support_system, engines_system, hull_system,
	electrical_system, external_system, computer_system]

var current_system_idx: int = -1

var is_mouse_inside: bool


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and GameManager.is_in_system and !is_mouse_inside:
		systems[current_system_idx].close()
		system_close_up_marker.hide()
		GameManager.is_in_system = false
		current_system_idx = -1
	if event.is_action_pressed("esc"):
		get_tree().quit()


func _on_active_area_mouse_entered() -> void:
	is_mouse_inside = true


func _on_active_area_mouse_exited() -> void:
	is_mouse_inside = false


func _on_system_sprite_pressed(system_index: int) -> void:
	if current_system_idx == -1:
		systems[system_index].open()
		current_system_idx = system_index
		GameManager.is_in_system = true
		system_close_up_marker.show()
