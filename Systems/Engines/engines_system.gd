extends system


class_name engines


const CELL_SCENE = preload("res://Systems/Engines/Cell/cell.tscn")

@onready var cells_container: Node2D = $Cells


func add_fuel() -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.position = Vector2(randf_range(-100.0, -70.0), randf_range(-40.0, -10.0))
	new_cell.rotation_degrees = randf() * 360


func add_coolant() -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.position = Vector2(randf_range(-95.0, -70.0), randf_range(26.0, 42.0))
	new_cell.rotation_degrees = randf() * 360


func create_cell(new_type: game_manager.engine_cell_types) -> Cell:
	var new_cell = CELL_SCENE.instantiate()
	cells_container.add_child(new_cell)
	new_cell.set_type(new_type)
	return new_cell


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("Released")


func _on_slot_cell_inserted(slot_idx: int, cell_type: game_manager.engine_cell_types) -> void:
	pass


func _on_fuel_area_mouse_entered() -> void:
	pass


func _on_fuel_area_mouse_exited() -> void:
	pass


func _on_coolant_area_mouse_entered() -> void:
	pass


func _on_coolant_area_mouse_exited() -> void:
	pass


func _on_fuel_timer_timeout() -> void:
	pass # Replace with function body.


func _on_coolant_timer_timeout() -> void:
	pass # Replace with function body.
