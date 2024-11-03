extends Area2D


signal cell_inserted(slot_idx: int, cell_type: game_manager.engine_cell_types)

@export var index: int

var slot_type: game_manager.engine_cell_types


func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	print("Entered slot: ", index)


func _on_mouse_exited() -> void:
	print("Exited slot: ", index)
