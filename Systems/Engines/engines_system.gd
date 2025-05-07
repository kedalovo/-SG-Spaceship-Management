extends system


signal fuel_cells_ran_out
signal coolant_cells_ran_out
signal fuel_cell_added
signal coolant_cell_added


const CELL_SCENE = preload("res://Systems/Engines/Cell/cell.tscn")

@onready var cells_container: Node2D = $Cells
@onready var cell_slots: Node2D = $"Cell Slots"
@onready var fuel_timer: Timer = $FuelTimer
@onready var coolant_timer: Timer = $CoolantTimer
@onready var camera: Camera2D = $Camera2D
@onready var label: Label = $Label
@onready var empty_fuel_timer: Timer = $"Empty Fuel Timer"
@onready var empty_coolant_timer: Timer = $"Empty Coolant Timer"
@onready var lose_timer: Timer = $"Lose Timer"

@onready var slots_fuel: Array[int] = []
@onready var slots_coolant: Array[int] = []

@onready var cells_fuel: Array[Cell] = []
@onready var cells_coolant: Array[Cell] = []

@onready var hovered_slot: int = -1

var destroyed_cells: int = 0

var is_empty_fuel: bool
var is_empty_coolant: bool


func _ready() -> void:
	super._ready()
	upgrade_tiers = 1
	setup_slots()
	if !game_manager.is_loading_save:
		for i in 8:
			add_fuel()
			add_coolant()
		setup_cells()
	hovered_slot = -1


func _physics_process(_delta: float) -> void:
	label.text = str(hovered_slot)


func start() -> void:
	fuel_timer.start()
	coolant_timer.start()


func stop() -> void:
	fuel_timer.stop()
	coolant_timer.stop()
	empty_fuel_timer.stop()
	empty_coolant_timer.stop()
	lose_timer.stop()
	is_empty_fuel = false
	is_empty_coolant = false


func setup_slots() -> void:
	slots_fuel = []
	slots_coolant = []
	var _slots := cell_slots.get_children()
	for i in 5:
		var idx := randi()%_slots.size()
		_slots[idx].set_slot_type(game_manager.engine_cell_types.FUEL)
		_slots[idx].get_node("Line2D").default_color = Color("ffdd00")
		slots_fuel.append(_slots[idx].index)
		_slots.remove_at(idx)
	for slot in _slots:
		slot.set_slot_type(game_manager.engine_cell_types.COOLANT)
		slot.get_node("Line2D").default_color = Color("0081ff")
		slots_coolant.append(slot.index)


func setup_cells() -> void:
	for i in 3:
		var slot := get_free_slot(game_manager.engine_cell_types.FUEL)
		var cell := get_unused_cell(game_manager.engine_cell_types.FUEL)
		cell.place_into_slot(slot)
	for i in 3:
		var slot := get_free_slot(game_manager.engine_cell_types.COOLANT)
		var cell := get_unused_cell(game_manager.engine_cell_types.COOLANT)
		cell.place_into_slot(slot)


func reset_cells() -> void:
	var installed_cells_fuel: Array = []
	var installed_cells_coolant: Array = []
	for i in cells_fuel:
		if i.in_slot >= 0:
			installed_cells_fuel.append(i)
	for i in cells_coolant:
		if i.in_slot >= 0:
			installed_cells_coolant.append(i)
	for cell_idx in installed_cells_fuel.size():
		var cell: Cell = installed_cells_fuel[cell_idx]
		if cell.is_depleted or cell.is_depleting or cell.is_destroyed:
			var slot = cell_slots.get_children()[slots_fuel[cell_idx]]
			cell.place_into_slot(slot)
	for cell_idx in installed_cells_coolant.size():
		var cell: Cell = installed_cells_coolant[cell_idx]
		if cell.is_depleted or cell.is_depleting or cell.is_destroyed:
			var slot = cell_slots.get_children()[slots_coolant[cell_idx]]
			cell.place_into_slot(slot)


func add_fuel(from_save: bool = false) -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.position = Vector2(randf_range(-100.0, -70.0), randf_range(-40.0, -10.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_fuel.append(new_cell)
	if !from_save:
		game_manager.fuel_cell_amount += 1
	print("[VALUE+] Fuel cell added, now ", game_manager.fuel_cell_amount)
	return new_cell


func add_consumed_fuel(health: float) -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.health = health
	new_cell.is_depleting = true
	cells_fuel.append(new_cell)
	if get_free_slot_count(game_manager.engine_cell_types.FUEL) > 0:
		new_cell.place_into_slot(get_free_slot(game_manager.engine_cell_types.FUEL))


func add_coolant(from_save: bool = false) -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.position = Vector2(randf_range(-95.0, -70.0), randf_range(26.0, 42.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_coolant.append(new_cell)
	if !from_save:
		game_manager.coolant_cell_amount += 1
	print("[VALUE+] Coolant cell added, now ", game_manager.coolant_cell_amount)
	return new_cell


func add_consumed_coolant(health: float) -> void:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.health = health
	new_cell.is_depleting = true
	cells_coolant.append(new_cell)
	if get_free_slot_count(game_manager.engine_cell_types.COOLANT) > 0:
		new_cell.place_into_slot(get_free_slot(game_manager.engine_cell_types.COOLANT))


func create_cell(new_type: game_manager.engine_cell_types) -> Cell:
	var new_cell = CELL_SCENE.instantiate()
	cells_container.add_child(new_cell)
	new_cell.set_type(new_type)
	new_cell.cell_released.connect(_on_cell_released)
	new_cell.being_deleted.connect(_on_cell_being_deleted)
	new_cell.held.connect(_on_cell_held)
	return new_cell


func open() -> void:
	setup_slots()
	reset_cells()
	super.open()


func close() -> void:
	super.close()
	for i in cell_slots.get_children():
		i.get_node("Line2D").hide()


func _damage(_strength: int, _type: game_manager.damage_types):
	if _type in [game_manager.damage_types.PHYSICAL, game_manager.damage_types.HEAT]:
		var _cells: Array[Node] = []
		for cell in cells_container.get_children():
			if cell.is_depleting or cell.is_depleted:
				_cells.append(cell)
		for i in clampi(_strength, 0, _cells.size()):
			print("Engines system: damaged")
			_cells.pop_at(randi()%_cells.size()).destroy()
			is_damaged = true
			destroyed_cells += 1


func get_fuel_health() -> float:
	var health := 0.0
	for cell in cells_fuel:
		if cell.is_depleting:
			health += cell.health
	return health


func get_coolant_health() -> float:
	var health := 0.0
	for cell in cells_coolant:
		if cell.is_depleting:
			health += cell.health
	return health


func get_free_slot_count(type: game_manager.engine_cell_types) -> int:
	var result: int = 0
	for i in cell_slots.get_children():
		if !i.is_busy and i.slot_type == type:
			result += 1
	return result


func get_free_slot(type: game_manager.engine_cell_types) -> cell_slot:
	for i in cell_slots.get_children():
		if !i.is_busy and i.slot_type == type:
			return i
	push_error("No free cell slots available")
	return cell_slot.new()


func get_unused_cell_count(type: game_manager.engine_cell_types) -> int:
	var result: int = 0
	for cell in cells_container.get_children():
		if cell.type == type and cell.is_depleting and !cell.is_depleted and !cell.is_destroyed:
			result += 1
	return result


func get_unused_cell(type: game_manager.engine_cell_types) -> Cell:
	var result: Cell = Cell.new()
	for cell in cells_container.get_children():
		if cell.type == type and !cell.is_depleting and !cell.is_depleted and !cell.is_destroyed:
			return cell
	push_error("There are no cells of type ", type, " that are unused!")
	return result


func _on_cell_held(type: game_manager.engine_cell_types) -> void:
	if current_tier == 1:
		for i in cell_slots.get_children():
			if i.slot_type == type:
				i.get_node("Line2D").show()


func _on_cell_released(cell: Cell) -> void:
	if current_tier == 1:
		for i in cell_slots.get_children():
			i.get_node("Line2D").hide()
	if hovered_slot >= 0:
		var slot: cell_slot = cell_slots.get_child(hovered_slot)
		hovered_slot = -1
		if slot.slot_type == cell.type and !slot.is_busy:
			cell.place_into_slot(slot)
		else:
			cell.position = cell.start_pos
	else:
		cell.position = cell.start_pos


func _on_cell_being_deleted(cell: Cell) -> void:
	for i in cell_slots.get_children():
		i.get_node("Line2D").hide()
	cell_slots.get_child(cell.in_slot).is_busy = false
	if cell.type == game_manager.engine_cell_types.FUEL:
		cells_fuel.erase(cell)
	else:
		if cell.type == game_manager.engine_cell_types.COOLANT:
			cells_coolant.erase(cell)
	if cell.is_destroyed:
		destroyed_cells -= 1
	if destroyed_cells == 0 and is_damaged and !(is_empty_coolant or is_empty_fuel):
		fix()
	cell.queue_free()


func _on_fuel_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_fuel:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() > 0:
		if is_empty_fuel:
			print("Added fuel, stopped timer")
			if destroyed_cells == 0 and is_damaged and !is_empty_coolant:
				fix()
			if !is_empty_coolant:
				lose_timer.stop()
			is_empty_fuel = false
			empty_fuel_timer.stop()
			fuel_cell_added.emit()
		active_cells.pick_random().use(0.5)
	else:
		is_empty_fuel = true
		if empty_fuel_timer.is_stopped() and !is_damaged and !game_manager.is_tutorial:
			empty_fuel_timer.start()
			print("Fuel is empty, starting timer...")


func _on_coolant_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_coolant:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() > 0:
		if is_empty_coolant:
			print("Added coolant, stopped timer")
			if destroyed_cells == 0 and is_damaged and !is_empty_fuel:
				fix()
			if !is_empty_fuel:
				lose_timer.stop()
			is_empty_coolant = false
			empty_coolant_timer.stop()
			coolant_cell_added.emit()
		active_cells.pick_random().use(0.5)
	else:
		is_empty_coolant = true
		if empty_coolant_timer.is_stopped() and !is_damaged and !game_manager.is_tutorial:
			empty_coolant_timer.start()
			print("Coolant is empty, starting timer...")


func _on_slot_cell_entered(slot_index: int) -> void:
	hovered_slot = slot_index


func _on_slot_cell_exited(_slot_index: int) -> void:
	pass


func _on_empty_fuel_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_fuel:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() == 0:
		is_damaged = true
		is_empty_fuel = true
		fuel_cells_ran_out.emit()
		lose_timer.start()
		print("Fuel out for a while!!!")


func _on_empty_coolant_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_coolant:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() == 0:
		is_damaged = true
		is_empty_coolant = true
		coolant_cells_ran_out.emit()
		lose_timer.start()
		print("Coolant out for a while!!!")


func _on_lose_timer_timeout() -> void:
	print("[LOSE] Engines system lost")
	lose.emit()
