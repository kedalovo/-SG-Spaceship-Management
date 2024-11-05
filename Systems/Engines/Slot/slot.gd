extends Area2D


signal cell_entered(slot_index: int)
signal cell_exited(slot_index: int)


@export var index: int
@export var cell_angle: int

var slot_type: game_manager.engine_cell_types = -1


func set_slot_type(new_type: game_manager.engine_cell_types):
	slot_type = new_type
	if get_child_count() == 2:
		get_child(1).queue_free()
	var icon: Sprite2D = Sprite2D.new()
	add_child(icon)
	if new_type == game_manager.engine_cell_types.FUEL:
		icon.texture = game_manager.FUEL_ICON
	else:
		icon.texture = game_manager.COOLANT_ICON


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Cell Body":
		cell_entered.emit(index)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Cell Body":
		cell_exited.emit(index)
