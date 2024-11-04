extends Area2D


signal cell_entered(slot_index: int)
signal cell_exited(slot_index: int)


@export var index: int
@export var cell_angle: int

var slot_type: game_manager.engine_cell_types


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Cell Body":
		cell_entered.emit(index)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Cell Body":
		cell_exited.emit(index)
