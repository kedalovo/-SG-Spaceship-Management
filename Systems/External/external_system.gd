extends system


const MODULE = preload("res://Systems/External/Module/module.tscn")
const MODULE_BLUEPRINT = preload("res://Systems/External/Module Blueprint/module_blueprint.tscn")

@onready var module_1: Node2D = $"Module Places/Module 1"
@onready var module_2: Node2D = $"Module Places/Module 2"
@onready var module_3: Node2D = $"Module Places/Module 3"
@onready var module_4: Node2D = $"Module Places/Module 4"
@onready var modules: Node2D = $Modules
@onready var module_blueprints: Node2D = $"Module Blueprints"
@onready var pos_h_box: HBoxContainer = $HBox
@onready var camera: Camera2D = $Camera2D
@onready var lose_timer: Timer = $"Lose Timer"

@onready var module_spaces: Array[Node2D] = [module_1, module_2, module_3, module_4]

var busy_blueprint_spots: Array[bool] = [false, false, false, false]
var installed_blueprint_spots: Array[bool] = [false, false, false, false]


func _ready() -> void:
	super._ready()
	setup_blueprints()
	for i in game_manager.module_types.values():
		add_module(i)
		add_module(i)
		add_module(i)


func setup_blueprints() -> void:
	for module in module_spaces:
		for child in module.get_children():
			child.queue_free()
	module_spaces.shuffle()
	for i in 4:
		module_spaces[i].add_child(create_blueprint(i))
		for module in modules.get_children():
			if module.type == i and !module.is_installed:
				module.position = module_spaces[i].position
				module.initial_position = module_spaces[i].position


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	_strength = clamp(_strength, 1, busy_blueprint_spots.count(false))
	match _type:
		game_manager.damage_types.PHYSICAL:
			for i in _strength:
				print("📡External system: damaged")
				add_blueprint(game_manager.module_types.PATCH)
		game_manager.damage_types.HEAT:
			for i in _strength:
				print("📡External system: damaged")
				add_blueprint(game_manager.module_types.HEATER)
		game_manager.damage_types.ELECTRICITY:
			for i in _strength:
				print("📡External system: damaged")
				add_blueprint(randi_range(1, 2))
	if _strength > 0:
		lose_timer.start()


func open() -> void:
	var count: = 0
	for i in 4:
		for j in modules.get_children():
			if j.type == i:
				count += 1
		for k in (3 - count):
			add_module(i)
	setup_blueprints()
	super.open()


func create_blueprint(type: game_manager.module_types) -> Blueprint:
	var blueprint: Blueprint = MODULE_BLUEPRINT.instantiate()
	blueprint.set_type(type)
	return blueprint


func add_blueprint(type: game_manager.module_types) -> void:
	var blueprint := create_blueprint(type)
	for i in 4:
		if !busy_blueprint_spots[i]:
			var pos := pos_h_box.get_child(i)
			pos.show()
			busy_blueprint_spots[i] = true
			pos.add_child(blueprint)
			blueprint.enable_area()
			blueprint.position.y = blueprint.y_offset
			is_damaged = true
			break


func add_module(type: game_manager.module_types) -> void:
	var module: Module = MODULE.instantiate()
	module.set_type(type)
	for place in module_spaces:
		if place.name.ends_with(str(type+1)):
			modules.add_child(module)
			module.position = place.position
			module.installed.connect(_on_module_installed)
			break


func check_completion() -> void:
	if installed_blueprint_spots == busy_blueprint_spots:
		busy_blueprint_spots = [false, false, false, false]
		installed_blueprint_spots = [false, false, false, false]
		fix()
		lose_timer.stop()


func clear() -> void:
	for module in modules.get_children():
		if module.is_installed:
			add_module(module.type)
			module.queue_free()
	for pos in pos_h_box.get_children():
		pos.hide()
		for child in pos.get_children():
			child.queue_free()


func stop() -> void:
	lose_timer.stop()


func _on_module_installed(blueprint: Blueprint, _module: Module) -> void:
	installed_blueprint_spots[blueprint.get_parent().get_index()] = true
	print("Module installed. Module position: ", _module.position, ", blueprint position: ", blueprint.position)
	check_completion()


func _on_finished_animation(is_open: bool) -> void:
	if !is_open:
		clear()


func _on_lose_timer_timeout() -> void:
	print("[LOSE] External system lost")
	lose.emit()
