extends Node2D


const CURSOR_NORMAL = preload("res://UI/Cursor normal.png")
const CURSOR_POINTER = preload("res://UI/Cursor pointer.png")


@onready var life_support_system: system = $"SubViewportContainer/SubViewport/Life Support System"
@onready var engines_system: system = $"SubViewportContainer/SubViewport/Engines System"
@onready var hull_system: system = $"SubViewportContainer/SubViewport/Hull System"
@onready var electrical_system: system = $"SubViewportContainer/SubViewport/Electrical System"
@onready var external_system: system = $"SubViewportContainer/SubViewport/External System"
@onready var computer_system: system = $"SubViewportContainer/SubViewport/Computer System"

@onready var life_support_sprite: Sprite2D = $"Systems Sprites/LifeSupportSprite"
@onready var engines_sprite: Sprite2D = $"Systems Sprites/EnginesSprite"
@onready var hull_sprite: Sprite2D = $"Systems Sprites/HullSprite"
@onready var electrical_sprite: Sprite2D = $"Systems Sprites/ElectricalSprite"
@onready var external_sprite: Sprite2D = $"Systems Sprites/ExternalSprite"
@onready var computer_sprite: Sprite2D = $"Systems Sprites/ComputerSprite"

@onready var system_container: Control = $"System Container"
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer

@onready var cabin: Node2D = $Cabin
@onready var space: Node2D = $Cabin/SubViewportContainer2/SubViewport/Space
@onready var cabin_view: Sprite2D = $"Cabin/Cabin View"

@onready var map: Node2D = $Map
@onready var map_animator: AnimationPlayer = $Map/Animator

@onready var store: Node2D = $Store
@onready var store_animator: AnimationPlayer = $Store/Animator

@onready var round_timer: Timer = $RoundTimer
@onready var clock: Node2D = $Cabin/Clock

@onready var balance: Node2D = $Balance

@onready var system_fog: Node2D = $"System Fog"

@onready var smoke_1: CPUParticles2D = $"Systems Sprites/EnginesSprite/Smoke Particles/Smoke 1"
@onready var smoke_2: CPUParticles2D = $"Systems Sprites/EnginesSprite/Smoke Particles/Smoke 2"
@onready var smoke_3: CPUParticles2D = $"Systems Sprites/EnginesSprite/Smoke Particles/Smoke 3"
@onready var smoke_4: CPUParticles2D = $"Systems Sprites/EnginesSprite/Smoke Particles/Smoke 4"

const CABIN_ZOOM_LEVEL: float = 1.1

@onready var systems: Array[system] = [
	life_support_system, engines_system, hull_system,
	electrical_system, external_system, computer_system]
@onready var systems_visuals: Array[Sprite2D] = [
	life_support_sprite, engines_sprite, hull_sprite,
	electrical_sprite, external_sprite, computer_sprite]

var current_system_idx: int = -1

var is_mouse_inside: bool
var can_control_via_arrows: bool
var is_store_open: bool
var is_map_open: bool


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND)
	#toggle_map(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		quit_game()
	if event.is_action_pressed(&"test1"):
		#map_animator.play(&"open")
		#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		#map.cursor.show()
		#balance.value = 5
		#print(balance.value)
		pass
	if event.is_action_pressed(&"test"):
		#map_animator.play_backwards(&"open")
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#map.cursor.hide()
		#balance.value = 10
		#print(balance.value)
		pass
	if game_manager.is_playing:
		if event.is_action_pressed(&"left"):
			var moved: bool = space.move(Vector2.LEFT)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"right"):
			var moved: bool = space.move(Vector2.RIGHT)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"up"):
			var moved: bool = space.move(Vector2.UP)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"down"):
			var moved: bool = space.move(Vector2.DOWN)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
	if event.is_action_pressed(&"fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func _physics_process(_delta: float) -> void:
	cabin_view.scale = lerp(cabin_view.scale, Vector2.ONE, 0.1)
	clock.set_time(round_timer.time_left)


func toggle_map(open: bool) -> void:
	if open and !is_map_open:
		map.toggle_input(true)
		map_animator.play(&"open")
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		map.cursor.show()
	elif !open and is_map_open:
		map_animator.play_backwards(&"open")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		map.cursor.hide()


func toggle_store(open: bool) -> void:
	if open and !is_store_open:
		is_store_open = true
		store.toggle_input(true)
		store_animator.play(&"open")
	elif !open and is_store_open:
		store_animator.play_backwards(&"open")


func start_round() -> void:
	round_timer.start()
	map_animator.play_backwards(&"open")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	map.cursor.hide()


func game_over() -> void:
	pass


func quit_game() -> void:
	# Gets rid of the annoying errors and warnings about leaking two textures when closing game (the cursor textures)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func update_balance() -> void:
	balance.value = game_manager.balance


func proceed() -> void:
	toggle_store(true)
	space.stop()
	for node in systems:
		node.fix()


func _on_system_sprite_pressed(system_index: int) -> void:
	if current_system_idx == -1:
		systems[system_index].open()
		current_system_idx = system_index
		GameManager.is_in_system = true
		system_container.show()
		sub_viewport_container.show()


func _on_system_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and GameManager.is_in_system:
		systems[current_system_idx].close()
		GameManager.is_in_system = false
		current_system_idx = -1


func _on_system_animation_finished(is_open: bool) -> void:
	if !is_open:
		system_container.hide()
		sub_viewport_container.hide()


func _on_left_button_pressed() -> void:
	space.move(Vector2.LEFT)


func _on_down_button_pressed() -> void:
	space.move(Vector2.DOWN)


func _on_right_button_pressed() -> void:
	space.move(Vector2.RIGHT)


func _on_up_button_pressed() -> void:
	space.move(Vector2.UP)


func _on_damaged(strength: int, type: game_manager.damage_types) -> void:
	var damage_variants: Array[system] = []
	match type:
		game_manager.damage_types.PHYSICAL:
			damage_variants = [hull_system, engines_system, electrical_system, external_system]
		game_manager.damage_types.HEAT:
			damage_variants = [life_support_system, engines_system, external_system]
		game_manager.damage_types.ELECTRICITY:
			damage_variants = [electrical_system, computer_system, external_system]
	for i in strength:
		var picked_system_idx: int = randi()% damage_variants.size()
		damage_variants[picked_system_idx]._damage(1, type)
		systems_visuals[systems.find(damage_variants[picked_system_idx])].damage()
		match damage_variants[picked_system_idx]:
			life_support_system:
				system_fog.toggle(true)
			engines_system:
				smoke_1.emitting = true
				smoke_2.emitting = true
				smoke_3.emitting = true
				smoke_4.emitting = true
			hull_system:
				pass
			electrical_system:
				pass
			external_system:
				pass
			computer_system:
				pass


func _on_system_fixed(fixed_system: system) -> void:
	systems_visuals[systems.find(fixed_system)].fix()
	match fixed_system:
		life_support_system:
			system_fog.toggle(false)
		engines_system:
			smoke_1.emitting = false
			smoke_2.emitting = false
			smoke_3.emitting = false
			smoke_4.emitting = false
		hull_system:
			pass
		electrical_system:
			pass
		external_system:
			pass
		computer_system:
			pass


func _on_round_timer_timeout() -> void:
	proceed()


func _on_space_new_location_set_up() -> void:
	toggle_store(false)
	start_round()


func _on_space_coin_got() -> void:
	game_manager.balance += 1


func _on_store_item_bought(item: game_manager.store_items) -> void:
	update_balance()
	match item:
		game_manager.store_items.NONE:
			push_error("'NONE' item can not be bought at the store")
		game_manager.store_items.LIFE_SUPPORT_1:
			life_support_system.upgrade(1)
		game_manager.store_items.LIFE_SUPPORT_2:
			life_support_system.upgrade(2)
		game_manager.store_items.ENGINES:
			engines_system.upgrade(1)
		game_manager.store_items.HULL_1:
			hull_system.upgrade(1)
		game_manager.store_items.HULL_2:
			hull_system.upgrade(2)
		game_manager.store_items.CONTROLS:
			can_control_via_arrows = true
		game_manager.store_items.BALLISTIC:
			#TODO: Ballistic prediction needs to be implemented. Basically, a hazard visualization - when it hits and where
			pass
		game_manager.store_items.NAVIGATION:
			#TODO: Here we'll just set a global variable in game_manager of the scan range to a higher value
			pass
		game_manager.store_items.ALGAE:
			life_support_system.add_fuel()
		game_manager.store_items.FUEL_CELL:
			engines_system.add_fuel()
		game_manager.store_items.COOLANT_CELL:
			engines_system.add_coolant()
		game_manager.store_items.PATCH:
			hull_system.add_patch()


func _on_store_map_summoned() -> void:
	toggle_map(true)


func _on_map_store_summoned() -> void:
	toggle_map(false)
	toggle_store(true)
