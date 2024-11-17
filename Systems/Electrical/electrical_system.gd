extends system


const WIRE = preload("res://Systems/Electrical/Wire/wire.tscn")

const RECEIVER_POSITIONS: Array[Vector2] = [
	Vector2(72, -32), Vector2(72, -16), Vector2(72, 0), Vector2(72, 16), Vector2(72, 32)]
const TRANCEIVER_POSITIONS: Array[Vector2] = [
	Vector2(-72, -32), Vector2(-72, -16), Vector2(-72, 0), Vector2(-72, 16), Vector2(-72, 32)]


@onready var wires: Node2D = $Wires
@onready var camera: Camera2D = $Camera2D

var receiver_states: Array[bool] = [false, false, false, false, false]
var tranceiver_states: Array[bool] = [false, false, false, false, false]
var color_states: Array[bool] = [false, false, false, false, false]

var last_color: int = -1


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	if _type == game_manager.damage_types.PHYSICAL or _type == game_manager.damage_types.ELECTRICITY:
		var free_receiver_slots: Array[int] = []
		var free_tranceiver_slots: Array[int] = []
		for idx in receiver_states.size():
			if !receiver_states[idx]:
				free_receiver_slots.append(idx)
		for idx in tranceiver_states.size():
			if !tranceiver_states[idx]:
				free_tranceiver_slots.append(idx)
		if free_receiver_slots.size() > 0:
			for i in clamp(_strength, 0, free_receiver_slots.size()):
				add_receiver_wire(free_receiver_slots.pop_at(randi()%free_receiver_slots.size()))
				add_tranceiver_wire(free_tranceiver_slots.pop_at(randi()%free_tranceiver_slots.size()))


func close():
	for wire in wires.get_children():
		if wire.is_connected_to_wire:
			wire.queue_free()
	super.close()


func create_wire() -> Node:
	var new_wire = WIRE.instantiate()
	wires.add_child(new_wire)
	return new_wire


func add_receiver_wire(slot: int) -> void:
	if last_color != -1:
		push_error("Last color is not empty for a receiver")
	if receiver_states[slot]:
		push_error("Receiver slot ", slot, " is already occupied!")
	var new_wire = create_wire()
	new_wire.set_receiver()
	new_wire.position = RECEIVER_POSITIONS[slot]
	receiver_states[slot] = true
	var free_color_states: Array[int] = []
	for idx in color_states.size():
		if !color_states[idx]:
			free_color_states.append(idx)
	last_color = free_color_states.pick_random()
	new_wire.modulate = game_manager.WIRE_COLORS[last_color]
	new_wire.rotation_degrees = 180
	color_states[last_color] = true


func add_tranceiver_wire(slot: int) -> void:
	if last_color == -1:
		push_error("Last color is not set for a tranceiver")
	if tranceiver_states[slot]:
		push_error("Tranceiver slot ", slot, " is already occupied!")
	var new_wire = create_wire()
	new_wire.set_tranceiver()
	new_wire.position = TRANCEIVER_POSITIONS[slot]
	tranceiver_states[slot] = true
	new_wire.modulate = game_manager.WIRE_COLORS[last_color]
	color_states[last_color] = true
	last_color = -1
