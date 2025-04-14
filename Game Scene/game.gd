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

@onready var loss_timer: Timer = $"Loss Timer"
@onready var game_over_menu: Control = $"Game Over Menu"

var ambient_audio_animator: AnimationPlayer

@onready var system_hover_audio: AudioStreamPlayer2D = $"Systems Sprites/System Hover Audio"
@onready var coin_audio: AudioStreamPlayer = $"Coin Audio"
@onready var cabin_control_button_hover_audio: AudioStreamPlayer = $"Cabin/Controls/Cabin Control Button Hover Audio"
@onready var cabin_control_button_press_audio: AudioStreamPlayer = $"Cabin/Controls/Cabin Control Button Press Audio"

@onready var physical_audio: AudioStreamPlayer = $"Physical Audio"
@onready var electrical_audio: AudioStreamPlayer = $"Electrical Audio"
@onready var heat_audio: AudioStreamPlayer = $"Heat Audio"
@onready var system_open_audio: AudioStreamPlayer = $"SubViewportContainer/SubViewport/System Open Audio"
@onready var system_close_audio: AudioStreamPlayer = $"SubViewportContainer/SubViewport/System Close Audio"
@onready var round_over_audio: AudioStreamPlayer = $"Round Over Audio"

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

var current_audio: int = -1

var is_mouse_inside: bool
var can_control_via_arrows: bool
var is_store_open: bool
var is_map_open: bool


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND)
	if game_manager.is_tutorial:
		toggle_map(true)
		setup_tutorial()
	elif game_manager.is_loading_save:
		load_game()
		toggle_store(true)
	else:
		toggle_map(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"esc"):
		pause_game()
	if event.is_action_pressed(&"test_space"):
		round_timer.stop()
		proceed()
		pass
	if event.is_action_pressed(&"test_quote"):
		pass
	if game_manager.is_playing:
		if event.is_action_pressed(&"left") and can_control_via_arrows:
			_on_left_button_pressed()
		if event.is_action_pressed(&"right") and can_control_via_arrows:
			_on_right_button_pressed()
		if event.is_action_pressed(&"up") and can_control_via_arrows:
			_on_up_button_pressed()
		if event.is_action_pressed(&"down") and can_control_via_arrows:
			_on_down_button_pressed()
	if event.is_action_pressed(&"fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			print("FULLSCREEN: On")
		elif DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			print("FULLSCREEN: Off")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func _physics_process(_delta: float) -> void:
	cabin_view.scale = lerp(cabin_view.scale, Vector2.ONE, 0.1)
	clock.set_time(round_timer.time_left)


func _process(_delta: float) -> void:
	$HBox/Label.text = "Algae: " + str(game_manager.algae_amount)
	$HBox/Label2.text = "Fuel cells: " + str(game_manager.fuel_cell_amount)
	$HBox/Label3.text = "Coolant cells: " + str(game_manager.coolant_cell_amount)
	$HBox/Label4.text = "Patch: " + str(game_manager.patch_amount)


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
		store.update_labels()
		tooltip_panel.toggle(true)
		store_animator.play(&"open")
	elif !open and is_store_open:
		is_store_open = false
		tooltip_panel.toggle(false)
		store_animator.play_backwards(&"open")


func start_round() -> void:
	print("Round started!")
	round_timer.start()
	toggle_map(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_manager.is_playing = true
	life_support_system.start()
	engines_system.start()
	map.cursor.hide()


func game_over() -> void:
	print("Game over!")
	if game_manager.is_tutorial:
		return
	game_manager.is_playing = false
	game_over_menu.show()


func pause_game() -> void:
	if pause_menu.was_just_unpaused:
		pause_menu.was_just_unpaused = false
		return
	print("PAUSE: Game is paused")
	pause_menu.show()
	if is_map_open:
		pause_menu.was_in_map = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func quit_game() -> void:
	print("Game closed")
	# Gets rid of the annoying errors and warnings about leaking two textures when closing game (the cursor textures)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	get_tree().quit()


func proceed() -> void:
	if game_manager.is_tutorial:
		round_timer.start(180.0)
		return
	else:
		save_game()
	print("Round over, proceeding")
	round_over_audio.play()
	toggle_store(true)
	life_support_system.stop()
	engines_system.stop()
	if GameManager.is_in_system:
		print("Was in system, closed")
		systems[current_system_idx].close()
		current_system_idx = -1
		GameManager.is_in_system = false
	space.stop()
	for node in systems:
		node.fix()


func save_game() -> void:
	var consumed_algae: Array[float] = []
	var consumed_fuel_cell: Array[float] = []
	var consumed_coolant_cell: Array[float] = []
	
	var temp = life_support_system.algae_container.get_children()
	for i in temp:
		if (!i.is_cooked and i.is_cooking) or i.is_cooked:
			consumed_algae.append(i.health)
	temp = engines_system.cells_fuel
	for i in temp:
		if (!i.is_depleted and i.is_depleting) or i.is_depleted:
			consumed_fuel_cell.append(i.health)
	temp = engines_system.cells_coolant
	for i in temp:
		if (!i.is_depleted and i.is_depleting) or i.is_depleted:
			consumed_coolant_cell.append(i.health)
	
	var map_data: Array[Array] = []
	var level: Array[map_node_save_template]
	for i in map.grid:
		for j in i:
			level.append(map_node_save_template.new(j))
		map_data.append(level.duplicate())
		level.clear()
	
	var new_save_data: save_game_template = save_game_template.new()
	
	new_save_data.life_support_tier = life_support_system.current_tier
	new_save_data.engines_tier = engines_system.current_tier
	new_save_data.hull_tier = hull_system.current_tier
	new_save_data.is_ballistic = game_manager.is_ballistic
	new_save_data.can_control_via_arrows = can_control_via_arrows
	new_save_data.scan_distance = game_manager.scan_distance
	
	new_save_data.algae_amount = game_manager.algae_amount
	new_save_data.fuel_cell_amount = game_manager.fuel_cell_amount
	new_save_data.coolant_cell_amount = game_manager.coolant_cell_amount
	new_save_data.patch_amount = game_manager.patch_amount
	
	new_save_data.consumed_algae = consumed_algae
	new_save_data.consumed_fuel_cells = consumed_fuel_cell
	new_save_data.consumed_coolant_cells = consumed_coolant_cell
	
	new_save_data.map_data = map_data
	new_save_data.balance = balance.value
	new_save_data.map_path = map.path
	new_save_data.current_location_index = space.current_location.map_index
	new_save_data.current_map_level = map.current_level
	ResourceSaver.save(new_save_data, "user://save.tres")
	print("[SAVE] Save complete.")


func load_game() -> void:
	var save_data: save_game_template = ResourceLoader.load("user://save.tres")
	for i in save_data.life_support_tier:
		life_support_system.upgrade(i+1)
	for i in save_data.engines_tier:
		engines_system.upgrade(i+1)
	for i in save_data.hull_tier:
		hull_system.upgrade(i+1)
	game_manager.is_ballistic = save_data.is_ballistic
	can_control_via_arrows = save_data.can_control_via_arrows
	game_manager.scan_distance = save_data.scan_distance
	
	for i in save_data.algae_amount:
		life_support_system.add_fuel()
	for i in save_data.fuel_cell_amount:
		engines_system.add_fuel()
	for i in save_data.coolant_cell_amount:
		engines_system.add_coolant()
	for i in save_data.patch_amount:
		hull_system.add_patch()
	
	for i in save_data.consumed_algae:
		life_support_system.add_consumed_fuel(i)
	for i in save_data.consumed_fuel_cells:
		engines_system.add_consumed_fuel(i)
	for i in save_data.consumed_coolant_cells:
		engines_system.add_consumed_coolant(i)
	
	map.load_map_data(save_data.map_data)
	balance.value = save_data.balance
	map.path = save_data.map_path
	space.current_location = map.get_map_node(save_data.current_location_index)
	map.current_level = save_data.current_map_level
	map.current_location = space.current_location
	map.update_secrecy()
	print("[LOAD] Load complete.")


func setup_tutorial() -> void:
	print("Setting up tutorial...")
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
	print("Pressed on system: ", system_index, ", current: ", current_system_idx)
	if current_system_idx == -1:
		AudioServer.set_bus_mute(system_index + 1, false)
		systems[system_index].open()
		system_open_audio.play()
		current_system_idx = system_index
		GameManager.is_in_system = true
		system_container.show()
		sub_viewport_container.show()


func _on_system_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and GameManager.is_in_system:
		if game_manager.is_tutorial:
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
					else:
						return
				2: # Hull
					if hull_system.get_holes_num() == 0:
						tutorial.proceed()
						hull_sprite.enabled = false
						hull_sprite.fix()
						electrical_sprite.enabled = true
						electrical_system._damage(2, game_manager.damage_types.ELECTRICITY)
						for sys in systems_visuals:
							sys.toggle_crazy(true)
						electrical_sprite.toggle_crazy(false)
						electrical_sprite.damage()
					else:
						return
				3: # Electrical
					if !electrical_system.is_damaged:
						tutorial.proceed()
						electrical_sprite.enabled = false
						external_sprite.enabled = true
						external_sprite.damage()
						external_system._damage(1, game_manager.damage_types.PHYSICAL)
						external_system._damage(1, game_manager.damage_types.HEAT)
						external_system._damage(1, game_manager.damage_types.ELECTRICITY)
						cabin.toggle_dirt(true)
					else:
						return
				4: # External
					if !external_system.is_damaged:
						tutorial.proceed()
						external_sprite.enabled = false
						computer_sprite.enabled = true
						computer_sprite.damage()
						computer_system._damage(2, game_manager.damage_types.ELECTRICITY)
						clock.is_crazy = true
						round_timer.paused = true
					else:
						return
				5: # Computer
					if !computer_system.is_damaged:
						tutorial.proceed()
						computer_sprite.enabled = false
					else:
						return
		AudioServer.set_bus_mute(current_system_idx + 1, true)
		systems[current_system_idx].close()
		system_close_audio.play()
		GameManager.is_in_system = false
		print("Exited system: ", current_system_idx)
		current_system_idx = -1


func _on_system_animation_finished(is_open: bool) -> void:
	if !is_open:
		system_container.hide()
		sub_viewport_container.hide()


func _on_left_button_pressed() -> void:
	cabin_control_button_press_audio.play()
	var moved: bool = space.move(Vector2.LEFT)
	if moved:
		cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)


func _on_down_button_pressed() -> void:
	cabin_control_button_press_audio.play()
	var moved: bool = space.move(Vector2.DOWN)
	if moved:
		cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)


func _on_right_button_pressed() -> void:
	cabin_control_button_press_audio.play()
	var moved: bool = space.move(Vector2.RIGHT)
	if moved:
		cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)


func _on_up_button_pressed() -> void:
	cabin_control_button_press_audio.play()
	var moved: bool = space.move(Vector2.UP)
	if moved:
		cabin_view.scale = Vector2(CABIN_ZOOM_LEVEL, CABIN_ZOOM_LEVEL)


func _on_damaged(strength: int, type: game_manager.damage_types) -> void:
	var damage_variants: Array[system] = []
	match type:
		game_manager.damage_types.PHYSICAL:
			physical_audio.play()
			damage_variants = [hull_system, engines_system, electrical_system, external_system]
		game_manager.damage_types.HEAT:
			heat_audio.play()
			damage_variants = [life_support_system, engines_system, external_system]
		game_manager.damage_types.ELECTRICITY:
			electrical_audio.play()
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
	var num: int = 0
	for i in systems:
		if i.is_damaged:
			num += 1
	if num > 2 and loss_timer.is_stopped():
		loss_timer.start()


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
	var num: int = 0
	for i in systems:
		if i.is_damaged:
			num += 1
	if num < 3:
		loss_timer.stop()


func _on_round_timer_timeout() -> void:
	proceed()


func _on_space_new_location_set_up() -> void:
	if game_manager.is_tutorial:
		tutorial.proceed()
		toggle_map(false)
	else:
		print("New location set")
		if current_audio != space.current_location.difficulty:
			match space.current_location.difficulty:
				2:
					ambient_audio_animator.play(&"ambience_2")
					current_audio = 2
				3:
					ambient_audio_animator.play(&"ambience_3")
					current_audio = 3
				0:
					push_error("Shouldn't happen")
		toggle_store(false)
		start_round()


func _on_space_coin_got() -> void:
	balance.value += 1
	coin_audio.play()
	print("Coin got, balance is: ", balance.value)


func _on_store_item_bought(item: game_manager.store_items, price: int) -> void:
	balance.value -= price
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
			game_manager.is_ballistic = true
		game_manager.store_items.NAVIGATION:
			game_manager.scan_distance = 3
			map.update_secrecy()
		game_manager.store_items.ALGAE:
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			store.update_labels()
		game_manager.store_items.FUEL_CELL:
			engines_system.add_fuel()
			engines_system.add_fuel()
			store.update_labels()
		game_manager.store_items.COOLANT_CELL:
			engines_system.add_coolant()
			engines_system.add_coolant()
			store.update_labels()
		game_manager.store_items.PATCH:
			hull_system.add_patch()
			store.update_labels()


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
			life_support_system.start()
			life_support_system._damage(1, game_manager.damage_types.HEAT)
			system_fog.toggle(true)
			life_support_sprite.damage()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()
			life_support_system.add_fuel()


func _on_loss_timer_timeout() -> void:
	game_over()


func _on_game_over_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Start Menu/start_menu.tscn")


func _on_life_support_system_algae_ran_out() -> void:
	system_fog.toggle(true)
	life_support_sprite.damage()
	print("Algae ran out!")


func _on_life_support_system_algae_added() -> void:
	system_fog.toggle(false)
	life_support_sprite.fix()
	print("Algae added after running out.")


func _on_engines_system_fuel_cells_ran_out() -> void:
	smoke_1.emitting = true
	smoke_2.emitting = true
	smoke_3.emitting = true
	smoke_4.emitting = true
	engines_sprite.damage()
	print("Fuel cells ran out!")


func _on_engines_system_coolant_cells_ran_out() -> void:
	smoke_1.emitting = true
	smoke_2.emitting = true
	smoke_3.emitting = true
	smoke_4.emitting = true
	engines_sprite.damage()
	print("Coolant cells ran out!")


func _on_engines_system_fuel_cell_added() -> void:
	smoke_1.emitting = false
	smoke_2.emitting = false
	smoke_3.emitting = false
	smoke_4.emitting = false
	engines_sprite.fix()
	print("Fuel cell added after running out.")


func _on_engines_system_coolant_cell_added() -> void:
	smoke_1.emitting = false
	smoke_2.emitting = false
	smoke_3.emitting = false
	smoke_4.emitting = false
	engines_sprite.fix()
	print("Coolant cell added after running out.")


func _on_system_hovered(idx: int) -> void:
	system_hover_audio.global_position = systems_visuals[idx].global_position
	system_hover_audio.play()


func _on_cabin_control_button_mouse_entered() -> void:
	cabin_control_button_hover_audio.play()
