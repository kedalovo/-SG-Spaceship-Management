extends Area2D


signal cell_inserted(slot_idx: int, cell_type: game_manager.engine_cell_types)

@export var index: int
@export var cell_angle: int

var slot_type: game_manager.engine_cell_types


func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	pass


func _on_mouse_exited() -> void:
	pass
