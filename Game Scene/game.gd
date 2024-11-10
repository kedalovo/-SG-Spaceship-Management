extends Node2D


@onready var life_support_system: system = $"Systems/Life Support System"
@onready var engines_system: engines = $"Systems/Engines System"
@onready var hull_system: system = $"Systems/Hull System"
@onready var electrical_system: system = $"Systems/Electrical System"
@onready var external_system: system = $"Systems/External System"
@onready var computer_system: system = $"Systems/Computer System"

@onready var system_container: Control = $"System Container"

@onready var systems: Array[system] = [
	life_support_system, engines_system, hull_system,
	electrical_system, external_system, computer_system]

var current_system_idx: int = -1

var is_mouse_inside: bool


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()
	if event.is_action_pressed("test1"):
		electrical_system._damage(2, game_manager.damage_types.PHYSICAL)
	if event.is_action_pressed("test"):
		pass


func _on_system_sprite_pressed(system_index: int) -> void:
	if current_system_idx == -1:
		systems[system_index].open()
		current_system_idx = system_index
		GameManager.is_in_system = true
		system_container.show()


func _on_system_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and GameManager.is_in_system:
		systems[current_system_idx].close()
		system_container.hide()
		GameManager.is_in_system = false
		current_system_idx = -1
