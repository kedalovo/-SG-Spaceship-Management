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
@onready var space: Node2D = $Cabin/SubViewportContainer/SubViewport/Space
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

@onready var systems_cracks: Sprite2D = $"Systems Background/Cracks"

@onready var tooltip_panel: Control = $Tooltip

@onready var pause_menu: Control = $"Pause Menu"
@onready var tutorial: Node = $Tutorial

const CABIN_ZOOM_LEVEL: float = 1.1

const TUTORIAL_ANIMATIONS: Array[StringName] = [
	&"tutorial_1_introduction",
	&"tutorial_2_map",
	&"tutorial_3_timer",
	&"tutorial_4_controls",
	&"tutorial_5_coins",
	&"tutorial_6_shop",
	&"tutorial_7_systems",
	&"tutorial_7_1_life_support",
	&"tutorial_7_2_engines",
	&"tutorial_7_3_hull",
	&"tutorial_7_4_electrical",
	&"tutorial_7_5_external",
	&"tutorial_7_6_computer",
	&"tutorial_8_end",
	]

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
var is_tutorial: bool = true


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND)
	if is_tutorial:
		toggle_map(true)
		setup_tutorial()
	else:
		toggle_map(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		pause_game()
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
		if event.is_action_pressed(&"left") and can_control_via_arrows:
			var moved: bool = space.move(Vector2.LEFT)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"right") and can_control_via_arrows:
			var moved: bool = space.move(Vector2.RIGHT)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"up") and can_control_via_arrows:
			var moved: bool = space.move(Vector2.UP)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
		if event.is_action_pressed(&"down") and can_control_via_arrows:
			var moved: bool = space.move(Vector2.DOWN)
			if moved:
				cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)
	if event.is_action_pressed(&"fullscreen") and can_control_via_arrows:
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
		map.is_active = true
		map.toggle_input(true)
		map_animator.play(&"open")
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		map.cursor.show()
		map.marker.show()
		is_map_open = true
	elif !open and is_map_open:
		map.is_active = false
		map_animator.play(&"close")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		map.cursor.hide()
		map.marker.hide()
		is_map_open = false


func toggle_store(open: bool) -> void:
	if open and !is_store_open:
		is_store_open = true
		store.toggle_input(true)
		tooltip_panel.toggle(true)
		store_animator.play(&"open")
	elif !open and is_store_open:
		is_store_open = false
		tooltip_panel.toggle(false)
		store_animator.play_backwards(&"open")


func start_round() -> void:
	round_timer.start()
	toggle_map(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_manager.is_playing = true
	map.cursor.hide()


func game_over() -> void:
	if is_tutorial:
		return
	game_manager.is_playing = false


func pause_game() -> void:
	if pause_menu.was_just_unpaused:
		pause_menu.was_just_unpaused = false
		return
	pause_menu.show()
	if is_map_open:
		pause_menu.was_in_map = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func quit_game() -> void:
	# Gets rid of the annoying errors and warnings about leaking two textures when closing game (the cursor textures)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func update_balance() -> void:
	balance.value = game_manager.balance


func proceed() -> void:
	if is_tutorial:
		round_timer.start(180.0)
		return
	toggle_store(true)
	space.stop()
	for node in systems:
		node.fix()


func setup_tutorial() -> void:
	round_timer.start()
	tutorial.start()
	space.is_tutorial = true
	life_support_sprite.enabled = false
	engines_sprite.enabled = false
	hull_sprite.enabled = false
	electrical_sprite.enabled = false
	external_sprite.enabled = false
	computer_sprite.enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	map.cursor.hide()
	map.toggle_store_button(false)


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
		if is_tutorial:
			match current_system_idx:
				0: # Life support
					tutorial.proceed()
					life_support_sprite.enabled = false
					engines_sprite.enabled = true
					engines_sprite.damage()
					smoke_1.emitting = true
					smoke_2.emitting = true
					smoke_3.emitting = true
					smoke_4.emitting = true
					engines_system._damage(2, game_manager.damage_types.PHYSICAL)
				1: # Engines
					if !engines_system.is_damaged:
						tutorial.proceed()
						engines_sprite.enabled = false
						hull_sprite.enabled = true
						hull_sprite.damage()
						hull_system._damage(3, game_manager.damage_types.PHYSICAL)
						systems_cracks.show()
				2: # Hull
					if !hull_system.is_damaged:
						tutorial.proceed()
						hull_sprite.enabled = false
						electrical_sprite.enabled = true
						electrical_system._damage(2, game_manager.damage_types.ELECTRICITY)
						for sys in systems_visuals:
							sys.toggle_crazy(true)
						electrical_sprite.toggle_crazy(false)
						electrical_sprite.damage()
				3: # Electrical
					if !electrical_system.is_damaged:
						tutorial.proceed()
						electrical_sprite.enabled = false
						external_sprite.enabled = true
						external_sprite.damage()
						external_system._damage(2, game_manager.damage_types.PHYSICAL)
						cabin.toggle_dirt(true)
				4: # External
					if !external_system.is_damaged:
						tutorial.proceed()
						external_sprite.enabled = false
						computer_sprite.enabled = true
						computer_sprite.damage()
						computer_system._damage(2, game_manager.damage_types.ELECTRICITY)
						clock.is_crazy = true
						round_timer.paused = true
				5: # Computer
					if !computer_system.is_damaged:
						tutorial.proceed()
						computer_sprite.enabled = false
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
				systems_cracks.show()
			electrical_system:
				for sys in systems_visuals:
					sys.toggle_crazy(true)
			external_system:
				cabin.toggle_dirt(true)
			computer_system:
				clock.is_crazy = true
				round_timer.paused = true


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
			systems_cracks.hide()
		electrical_system:
			for sys in systems_visuals:
				sys.toggle_crazy(false)
		external_system:
			cabin.toggle_dirt(false)
		computer_system:
			clock.is_crazy = false
			round_timer.paused = false


func _on_round_timer_timeout() -> void:
	proceed()


func _on_space_new_location_set_up() -> void:
	if is_tutorial:
		tutorial.proceed()
		toggle_map(false)
	else:
		toggle_store(false)
		start_round()


func _on_space_coin_got() -> void:
	balance.value += 1


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
	toggle_store(false)
	toggle_map(true)


func _on_map_store_summoned() -> void:
	toggle_map(false)
	toggle_store(true)


func _on_store_button_hover(btn: store_button) -> void:
	tooltip_panel.set_text(btn.custom_tooltip)
	balance.set_flash(btn.price)


func _on_store_button_hover_stop() -> void:
	tooltip_panel.set_text("")
	balance.set_flash(0)


func _on_tutorial_request(req: String) -> void:
	match req:
		"map":
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			map.cursor.show()
		"map_off":
			map.cursor.hide()
		"coin":
			space.create_coin(5.0)
			space.create_coin(7.5)
			space.create_coin(10.0)
			get_tree().create_timer(10.0).timeout.connect(tutorial.proceed)
		"systems":
			life_support_sprite.enabled = true
			life_support_system._damage(1, game_manager.damage_types.HEAT)
			system_fog.toggle(true)
			life_support_sprite.damage()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
