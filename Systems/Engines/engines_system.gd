extends system


const CELL_SCENE = preload("res://Systems/Engines/Cell/cell.tscn")

@onready var cells_container: Node2D = $Cells
@onready var cell_slots: Node2D = $"Cell Slots"
@onready var fuel_timer: Timer = $FuelTimer
@onready var coolant_timer: Timer = $CoolantTimer
@onready var camera: Camera2D = $Camera2D

@onready var slots_fuel: Array[int] = []
@onready var slots_coolant: Array[int] = []

@onready var cells_fuel: Array[Cell] = []
@onready var cells_coolant: Array[Cell] = []

@onready var hovered_slot: int = -1


func _ready() -> void:
	super._ready()
	setup_slots()
	setup_cells()
	fuel_timer.start()
	coolant_timer.start()


func setup_slots() -> void:
	slots_fuel = []
	slots_coolant = []
	var _slots := cell_slots.get_children()
	for i in 5:
		var idx := randi()%_slots.size()
		_slots[idx].set_slot_type(game_manager.engine_cell_types.FUEL)
		slots_fuel.append(_slots[idx].index)
		_slots.remove_at(idx)
	for slot in _slots:
		slot.set_slot_type(game_manager.engine_cell_types.COOLANT)
		slots_coolant.append(slot.index)


func setup_cells() -> void:
	for i in 3:
		var slot = cell_slots.get_children()[slots_fuel[i]]
		var new_cell := add_fuel()
		new_cell.place_into_slot(slot)
		add_fuel()
	for i in 3:
		var slot = cell_slots.get_children()[slots_coolant[i]]
		var new_cell = add_coolant()
		new_cell.place_into_slot(slot)
		add_coolant()


func reset_cells() -> void:
	#print_debug("Fuel cells: ", cells_fuel.size())
	for cell_idx in cells_fuel.size():
		var cell: Cell = cells_fuel[cell_idx]
		if cell.is_depleted or cell.is_depleting or cell.is_destroyed:
			var slot = cell_slots.get_children()[slots_fuel[cell_idx]]
			cell.place_into_slot(slot)
	for cell_idx in cells_coolant.size():
		var cell: Cell = cells_coolant[cell_idx]
		if cell.is_depleted or cell.is_depleting or cell.is_destroyed:
			var slot = cell_slots.get_children()[slots_coolant[cell_idx]]
			cell.place_into_slot(slot)


func add_fuel() -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.position = Vector2(randf_range(-100.0, -70.0), randf_range(-40.0, -10.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_fuel.append(new_cell)
	return new_cell


func add_coolant() -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.position = Vector2(randf_range(-95.0, -70.0), randf_range(26.0, 42.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_coolant.append(new_cell)
	return new_cell


func create_cell(new_type: game_manager.engine_cell_types) -> Cell:
	var new_cell = CELL_SCENE.instantiate()
	cells_container.add_child(new_cell)
	new_cell.set_type(new_type)
	new_cell.cell_released.connect(_on_cell_released)
	new_cell.being_deleted.connect(_on_cell_being_deleted)
	return new_cell


func open() -> void:
	setup_slots()
	reset_cells()
	super.open()


func _damage(_strength: int, _type: game_manager.damage_types):
	if _type == game_manager.damage_types.PHYSICAL or _type == game_manager.damage_types.HEAT:
		var _cells: Array[Node] = []
		for cell in cells_container.get_children():
			if cell.is_depleting or cell.is_depleted:
				_cells.append(cell)
		for i in _strength * 2:
			_cells.pop_at(randi()%_cells.size()).destroy()


func get_fuel_health() -> int:
	var health := 0
	for cell in cells_fuel:
		if cell.is_depleting:
			health += cell.health
	return health


func get_coolant_health() -> int:
	var health := 0
	for cell in cells_coolant:
		if cell.is_depleting:
			health += cell.health
	return health


func _on_cell_released(cell: Cell) -> void:
	if hovered_slot >= 0:
		var slot: Area2D = cell_slots.get_child(hovered_slot)
		hovered_slot = -1
		if slot.slot_type == cell.type:
			cell.place_into_slot(slot)
		else:
			cell.position = cell.start_pos
	else:
		cell.position = cell.start_pos


func _on_cell_being_deleted(cell: Cell) -> void:
	cell_slots.get_child(cell.in_slot).is_busy = false
	if cell.type == game_manager.engine_cell_types.FUEL:
		cells_fuel.erase(cell)
	else:
		if cell.type == game_manager.engine_cell_types.COOLANT:
			cells_coolant.erase(cell)
	cell.queue_free()


func _on_fuel_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_fuel:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() > 0:
		active_cells.pick_random().use(1)


func _on_coolant_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_coolant:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() > 0:
		active_cells.pick_random().use(1)


func _on_slot_cell_entered(slot_index: int) -> void:
	if hovered_slot == -1:
		hovered_slot = slot_index


func _on_slot_cell_exited(slot_index: int) -> void:
	if hovered_slot == slot_index:
		hovered_slot = -1
