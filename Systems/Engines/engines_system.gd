extends system


func _on_slot_cell_inserted(slot_idx: int, cell_type: game_manager.engine_cell_types) -> void:
	prints(slot_idx, str(cell_type))


func _on_fuel_area_mouse_entered() -> void:
	print("Fuel entered")


func _on_fuel_area_mouse_exited() -> void:
	print("Fuel exited")


func _on_coolant_area_mouse_entered() -> void:
	print("Coolant entered")


func _on_coolant_area_mouse_exited() -> void:
	print("Coolant exited")
