extends system


class_name engines


const CELL_SCENE = preload("res://Systems/Engines/Cell/cell.tscn")

@onready var cells_container: Node2D = $Cells
@onready var cell_slots: Node2D = $"Cell Slots"

@onready var hovered_slot: int = -1


func add_fuel() -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.position = Vector2(randf_range(-100.0, -70.0), randf_range(-40.0, -10.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360


func add_coolant() -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.position = Vector2(randf_range(-95.0, -70.0), randf_range(26.0, 42.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360


func create_cell(new_type: game_manager.engine_cell_types) -> Cell:
	var new_cell = CELL_SCENE.instantiate()
	cells_container.add_child(new_cell)
	new_cell.set_type(new_type)
	new_cell.cell_released.connect(_on_cell_released)
	return new_cell


func _on_cell_released(cell: Cell):
	#print_debug("Cell was released")
	if hovered_slot >= 0:
		var slot: Area2D = cell_slots.get_child(hovered_slot)
		cell.place_into_slot(slot.position, slot.cell_angle)
	else:
		cell.position = cell.start_pos


func _on_fuel_timer_timeout() -> void:
	pass


func _on_coolant_timer_timeout() -> void:
	pass


func _on_slot_cell_entered(slot_index: int) -> void:
	if hovered_slot == -1:
		hovered_slot = slot_index

func _on_slot_cell_exited(slot_index: int) -> void:
	if hovered_slot == slot_index:
		hovered_slot = -1
