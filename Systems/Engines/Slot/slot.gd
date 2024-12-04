extends Area2D


signal cell_entered(slot_index: int)
signal cell_exited(slot_index: int)


@export var index: int
@export var cell_angle: int

var slot_type: game_manager.engine_cell_types = game_manager.engine_cell_types.NONE

var is_busy: bool = false


func set_slot_type(new_type: game_manager.engine_cell_types) -> void:
	is_busy = false
	slot_type = new_type
	if get_child_count() == 3:
		get_child(2).queue_free()
	var icon: Sprite2D = Sprite2D.new()
	add_child(icon)
	if new_type == game_manager.engine_cell_types.FUEL:
		icon.texture = game_manager.FUEL_ICON
	else:
		icon.texture = game_manager.COOLANT_ICON


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Cell Body":
		#print(index, ": ✔️")
		cell_entered.emit(index)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Cell Body":
		#print(index, ": ❌")
		cell_exited.emit(index)
