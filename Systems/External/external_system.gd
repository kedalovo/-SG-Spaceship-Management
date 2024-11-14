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

@onready var module_spaces: Array[Node2D] = [module_1, module_2, module_3, module_4]

var busy_blueprint_spots: Array[bool] = [false, false, false, false]
var installed_blueprint_spots: Array[bool] = [false, false, false, false]


func _ready() -> void:
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
	for i in _strength:
		add_blueprint(randi()%4)


func open() -> void:
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
			break
	for module in modules.get_children():
		if module.is_installed:
			print("Moved from: ", module.global_position)
			module.global_position = module.installed_on.global_position
			print("\t To: ", module.global_position)


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
		for module in modules.get_children():
			if module.is_installed:
				module.queue_free()
		for pos in pos_h_box.get_children():
			pos.hide()
			for child in pos.get_children():
				child.queue_free()
		busy_blueprint_spots = [false, false, false, false]
		installed_blueprint_spots = [false, false, false, false]


func _on_module_installed(blueprint: Blueprint, module: Module) -> void:
	installed_blueprint_spots[blueprint.get_parent().get_index()] = true
	check_completion()
