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
	setup_slots()
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


func add_fuel() -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.FUEL)
	new_cell.position = Vector2(randf_range(-100.0, -70.0), randf_range(-40.0, -10.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_fuel.append(new_cell)
	game_manager.fuel_cell_amount += 1
	return new_cell


func add_coolant() -> Cell:
	var new_cell := create_cell(game_manager.engine_cell_types.COOLANT)
	new_cell.position = Vector2(randf_range(-95.0, -70.0), randf_range(26.0, 42.0))
	new_cell.start_pos = new_cell.position
	new_cell.rotation_degrees = randf() * 360
	cells_coolant.append(new_cell)
	game_manager.coolant_cell_amount += 1
	return new_cell


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


func _damage(_strength: int, _type: game_manager.damage_types):
	if _type == game_manager.damage_types.PHYSICAL or _type == game_manager.damage_types.HEAT:
		var _cells: Array[Node] = []
		for cell in cells_container.get_children():
			if cell.is_depleting or cell.is_depleted:
				_cells.append(cell)
		for i in _strength * 2:
			print("Engines system: damaged [", i+1, "]/[", _strength * 2, "]")
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
		var slot: Area2D = cell_slots.get_child(hovered_slot)
		hovered_slot = -1
		if slot.slot_type == cell.type and !slot.is_busy:
			cell.place_into_slot(slot)
		else:
			cell.position = cell.start_pos
	else:
		cell.position = cell.start_pos


func _on_cell_being_deleted(cell: Cell) -> void:
	cell_slots.get_child(cell.in_slot).is_busy = false
	if cell.type == game_manager.engine_cell_types.FUEL:
		cells_fuel.erase(cell)
		game_manager.fuel_cell_amount -= 1
	else:
		if cell.type == game_manager.engine_cell_types.COOLANT:
			cells_coolant.erase(cell)
			game_manager.coolant_cell_amount -= 1
	if cell.is_destroyed:
		destroyed_cells -= 1
	if destroyed_cells == 0 and is_damaged:
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
		print("Fuel out for a while!!!")


func _on_empty_coolant_timer_timeout() -> void:
	var active_cells: Array[Cell] = []
	for cell in cells_fuel:
		if cell.is_depleting and !cell.is_depleted and !cell.is_destroyed and !cell.is_held:
			active_cells.append(cell)
	if active_cells.size() == 0:
		is_damaged = true
		is_empty_coolant = true
		coolant_cells_ran_out.emit()
		print("Coolant out for a while!!!")
