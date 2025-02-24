extends Node2D


signal location_changed(new_location: map_node)
signal store_summoned


@export_color_no_alpha var default_color: Color
@export_color_no_alpha var highlight_color: Color


const MAP_NODE = preload("res://Map/Map Node/map_node.tscn")

const ASTEROID_ICON = preload("res://Map/Map Node/Icons/Asteroid Icon.png")
const MISSILE_ICON = preload("res://Map/Map Node/Icons/Missile Icon.png")
const NEBULA_ICON = preload("res://Map/Map Node/Icons/Nebula Icon.png")
const SNOWFLAKE_ICON = preload("res://Map/Map Node/Icons/Snowflake Icon.png")
const STAR_ICON = preload("res://Map/Map Node/Icons/Star Icon.png")
const QUESTION_ICON = preload("res://Map/Map Node/Icons/Question Icon.png")

const ICONS: Array = [ASTEROID_ICON, MISSILE_ICON, NEBULA_ICON, SNOWFLAKE_ICON, STAR_ICON]

@onready var map_nodes: Node2D = $"Map Nodes"
@onready var map_container: Control = $"Scroll/Map Container"
@onready var scroll: ScrollContainer = $Scroll
@onready var cursor: Sprite2D = $Cursor
@onready var marker: Sprite2D = $Marker
@onready var marker_animator: AnimationPlayer = $"Marker/Marker Animator"
@onready var contents: Control = $"Scroll/Map Container/MarginContainer/Contents"
@onready var input_stopper: Control = $"Input Stopper"
@onready var store_button_link: TextureButton = $"Store Button Background/Store Button"
@onready var fog_1: TextureRect = $"Scroll/Map Container/Fog 1"
@onready var fog_2: TextureRect = $"Scroll/Map Container/Fog 2"

@export var line_color_global: Color

@onready var map_tooltip: PanelContainer = $"Map Tooltip"

const NUM_OF_DELETIONS: int = 20
const LINE_NUM: int = 15
const LINE_LENGTH: int = 5
const POS_X_SPREAD: int = 32
const POS_Y_SPREAD: int = 32

var current_location: map_node = null

var grid: Array[Array] = []
var lines_con: Array = []
var con_start: map_node
var dummy_grid: Dictionary

var line_offset: float = 0.0

var current_level: int = -1


func _ready() -> void:
	fog_1.texture.noise.seed = randi()
	fog_2.texture.noise.seed = randi()
	generate_map()
	scroll.set_deferred(&"scroll_vertical", 1504)


func _physics_process(_delta: float) -> void:
	queue_redraw()
	refresh_tooltips()
	line_offset += _delta / 10
	if line_offset >= 1.0:
		line_offset = 0


func _process(_delta: float) -> void:
	cursor.position = get_global_mouse_position()


func _draw() -> void:
	for row in grid:
		for location in row:
			if location == current_location:
				for target in location.connected_to_nodes:
					if !target.disabled and !location.disabled:
						draw_default_punctured_line(location.global_position, target.global_position)
			else:
				for target in location.connected_to_nodes:
					if !target.disabled and !location.disabled:
						draw_line(target.global_position, location.global_position, line_color_global, 2)
	for location in lines_con:
		if !location.disabled:
			draw_default_punctured_line(con_start.global_position, location.global_position)


func toggle_input(new_state: bool) -> void:
	if new_state:
		input_stopper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		input_stopper.mouse_filter = Control.MOUSE_FILTER_STOP


func draw_default_punctured_line(from: Vector2, to: Vector2) -> void:
	draw_punctured_line(from, to, 4, 30, Color.BLUE, 2)


func draw_punctured_line(from: Vector2, to: Vector2, gap_size: int, segment_length: int, line_color: Color, line_width: int) -> void:
	var diff := to - from
	var is_x_pos: bool = false
	if to.x > from.x:
		is_x_pos = true
	if to.x == from.x:
		to.x -= 0.1
		diff = to - from
	var norm := diff.normalized()
	var gap := norm * gap_size
	var points: Array = []
	var segment_num: int = floori((diff / (norm * segment_length)).length())
	var start_pos: Vector2 = from.lerp(to, line_offset)
	for i in segment_num:
		var current_segment := diff / segment_num
		var pp1 := start_pos + (current_segment * i + gap)
		var pp2 := start_pos + (current_segment * (i + 1) - gap)
		var pp3 := start_pos - (current_segment * i + gap)
		var pp4 := start_pos - (current_segment * (i + 1) - gap)
		if is_x_pos:
			if pp2 >= to:
				pp2 = to
			if pp4 <= from and pp3 > from:
				pp4 = from
			if pp1 <= to:
				points.append([pp1, pp2])
			if pp4 >= from:
				points.append([pp3, pp4])
		else:
			if pp2 <= to:
				pp2 = to
			if pp4 >= from and pp3 < from:
				pp4 = from
			if pp1 >= to:
				points.append([pp1, pp2])
			if pp4 <= from:
				points.append([pp3, pp4])
	for i in points:
		draw_line(i[0], i[1], line_color, line_width)


func refresh_tooltips() -> void:
	for node in get_tree().get_nodes_in_group(&"visual_map_nodes"):
		var con_text: String = ""
		if node.color != Color.RED:
			for i in node.get_child(0).connected_to_nodes:
				if !i.disabled:
					con_text += str(i.global_position) + " "
		node.tooltip_text = "Disabled: " + str(node.get_child(0).disabled) + "\nPosition: " + str(node.get_child(0).global_position) + "\nConnected to: " + con_text


func generate_map() -> void:
	# Generating empty grid
	for i in LINE_NUM:
		var level: Array[map_node] = []
		var dummy_line: Array[int] = []
		for j in LINE_LENGTH:
			var new_map_node := MAP_NODE.instantiate()
			map_nodes.add_child(new_map_node)
			level.append(new_map_node)
			dummy_line.append(j)
		grid.append(level)
		dummy_grid[i] = dummy_line
	
	# Deleting random nodes
	for i in NUM_OF_DELETIONS:
		var num: int = dummy_grid.keys().pick_random()
		if dummy_grid[num].is_empty():
			continue
		var deleting: int = dummy_grid[num].pick_random()
		grid[num][deleting].disabled = true
		dummy_grid[num].erase(deleting)
	
	# Filling empty lines
	for i in grid:
		var are_all_disabled: bool = true
		for j in i:
			if !j.disabled:
				are_all_disabled = false
		if are_all_disabled:
			i.pick_random().disabled = false
			i.pick_random().disabled = false
			i.pick_random().disabled = false
	
	# Setting up first line
	for i in grid[dummy_grid.keys().min()]:
		if !i.disabled:
			i.is_continuation = true
	
	# Creating default connections
	var sorted_order: Array = dummy_grid.keys().duplicate()
	sorted_order.sort()
	sorted_order.pop_back()
	for i in sorted_order:
		grid[i][0].add_connections([grid[i+1][0], grid[i+1][1]])
		grid[i+1][0].has_destination = true
		grid[i+1][1].has_destination = true
		for j in range(1, LINE_LENGTH - 1):
			grid[i][j].add_connections([grid[i+1][j-1], grid[i+1][j], grid[i+1][j+1]])
			grid[i+1][j-1].has_destination = true
			grid[i+1][j].has_destination = true
			grid[i+1][j+1].has_destination = true
		grid[i][LINE_LENGTH - 1].add_connections([grid[i+1][LINE_LENGTH - 2], grid[i+1][LINE_LENGTH - 1]])
		grid[i+1][LINE_LENGTH - 2].has_destination = true
		grid[i+1][LINE_LENGTH - 1].has_destination = true
	
	# Disabling nodes in first line without connections
	for i in grid[dummy_grid.keys().min()]:
		if !i.disabled and i.connected_to_nodes.size() == 0:
			i.disabled = true
			i.reason = 2
	
	# Enabling connectivity in first enabled line
	for i in grid[dummy_grid.keys().min()]:
		if !i.disabled:
			i.is_continuation = true
	
	# Enabling connectivity in separated levels
	for i in sorted_order:
		var no_con: bool = true
		for j in grid[i]:
			if !j.connected_to_nodes.is_empty():
				no_con = false
		if no_con:
			for j in grid[i+1]:
				if !j.disabled:
					j.is_continuation = true
	
	# Recreating deleted connections
	for i in sorted_order:
		grid[i][0].add_connections([grid[i+1][0], grid[i+1][1]])
		for j in range(1, LINE_LENGTH - 1):
			grid[i][j].add_connections([grid[i+1][j-1], grid[i+1][j], grid[i+1][j+1]])
		grid[i][LINE_LENGTH - 1].add_connections([grid[i+1][LINE_LENGTH - 2], grid[i+1][LINE_LENGTH - 1]])
	
	# Disabling nodes without previous connections
	for i in dummy_grid.keys():
		for j in grid[i]:
			if !j.disabled and !j.is_continuation:
				j.disabled = true
				j.reason = 1
	
	# Adding wormholes to map nodes without destinations
	for i in grid.size()-1:
		for j in grid[i]:
			j.check_destinations()
			if !j.disabled and j.has_destination:
				j.has_wormhole = true
				var wormhole: map_node = MAP_NODE.instantiate()
				wormhole.is_wormhole = true
				map_nodes.add_child(wormhole)
				wormhole.mouse_entered.connect(_on_map_node_mouse_enter)
				wormhole.mouse_exited.connect(_on_map_node_mouse_exit)
				wormhole.button_pressed.connect(_on_map_node_pressed)
				wormhole.connected_to_nodes = grid[i+1]
				j.wormhole = wormhole
	
	var hazards: Array[game_manager.hazard_types] = [
		game_manager.hazard_types.ASTEROID_FIELD, game_manager.hazard_types.WARZONE, 
		game_manager.hazard_types.NEBULA, game_manager.hazard_types.ICE_FIELD, game_manager.hazard_types.STAR_PROXIMITY]
	var hazard_buffer: Array[game_manager.hazard_types] = hazards.duplicate()
	var hazard_bin: Array[game_manager.hazard_types] = []
	var intensity: int = 0
	# Visualising result and assigning difficulty and hazard types
	for i in range(0, grid.size()):
		intensity += 1
		if intensity > 5:
			intensity = 1
		var line: Array = grid[i]
		for j in LINE_LENGTH:
			@warning_ignore("integer_division")
			var difficulty := i / (grid.size() / 3) + 1
			line[j].reparent(contents)
			line[j].position = Vector2(j * 128 + 224 + randi_range(-POS_X_SPREAD, POS_X_SPREAD), i * -128 + 1884 + randi_range(-POS_Y_SPREAD, POS_Y_SPREAD))
			line[j].z_index = 1
			line[j].mouse_entered.connect(_on_map_node_mouse_enter)
			line[j].mouse_exited.connect(_on_map_node_mouse_exit)
			line[j].button_pressed.connect(_on_map_node_pressed)
			line[j].set_default_texture(QUESTION_ICON)
			if difficulty == 1:
				hazard_buffer.shuffle()
				var picked_hazard: game_manager.hazard_types = hazard_buffer.pop_front()
				hazard_bin.append(picked_hazard)
				line[j].hazards.append(picked_hazard)
				line[j].hazards_intensity.append(intensity)
				line[j].set_texture(ICONS[hazards.find(picked_hazard)])
			elif difficulty > 1:
				hazard_buffer.shuffle()
				var picked_hazard: game_manager.hazard_types = hazard_buffer.pop_front()
				hazard_bin.append(picked_hazard)
				line[j].hazards.append(picked_hazard)
				line[j].set_texture(ICONS[hazards.find(picked_hazard)])
				picked_hazard = hazard_buffer.pop_front()
				hazard_bin.append(picked_hazard)
				line[j].hazards.append(picked_hazard)
				if difficulty == 2:
					line[j].hazards_intensity.append(intensity + 2)
					line[j].hazards_intensity.append(intensity + 2)
				else:
					line[j].hazards_intensity.append(8)
					line[j].hazards_intensity.append(8)
			while hazard_bin.size() > 2:
				hazard_buffer.append(hazard_bin.pop_front())
			line[j].set_difficulty(difficulty)
			if line[j].has_wormhole:
				line[j].setup_wormhole()
			if line[j].disabled:
				line[j].hide()
	
	# Showing types of first two lines of locations
	for i in grid[0]:
		i.is_secret = false
		i.toggle_availability(true)
		i.update_icon()
	for i in grid[1]:
		i.is_secret = false
		i.update_icon()


func tooltip_popup(node: map_node) -> void:
	if node.is_wormhole or node.is_secret:
		return
	map_tooltip.set_text(game_manager.get_map_node_tooltip(node))
	match node.difficulty:
		1:
			map_tooltip.self_modulate = Color("00cb00")
		2:
			map_tooltip.self_modulate = Color("cbc800")
		3:
			map_tooltip.self_modulate = Color("cb0000")
	map_tooltip.global_position = node.global_position + Vector2(16.0, 16.0)
	if map_tooltip.global_position.y + map_tooltip.get_rect().size.y > 508.0:
		map_tooltip.global_position = Vector2(16.0, -map_tooltip.get_rect().size.y - 16.0)
	if map_tooltip.global_position.x + map_tooltip.get_rect().size.x > 928.0:
		map_tooltip.global_position += Vector2(-map_tooltip.get_rect().size.x - 36.0, 16.0)
	map_tooltip.toggle_open(true)


func _on_map_node_mouse_enter(node: map_node) -> void:
	marker.position = node.global_position
	tooltip_popup(node)
	if node.is_wormhole:
		con_start = node
		lines_con = node.connected_to_nodes
		for n in node.connected_to_nodes:
			n.toggle_highlight(true)
	marker_animator.play(&"show")
	cursor.hide()


func _on_map_node_mouse_exit(node: map_node) -> void:
	map_tooltip.toggle_open(false)
	lines_con = []
	con_start = null
	for n in node.connected_to_nodes:
		n.toggle_highlight(false)
	marker_animator.play_backwards(&"show")
	cursor.show()


func _on_map_node_pressed(node: map_node) -> void:
	current_location = node
	current_level += 1
	for i in grid[current_level]:
		i.toggle_availability(false)
	for i in current_location.connected_to_nodes:
		i.toggle_availability(true)
	location_changed.emit(node)


func _on_store_button_pressed() -> void:
	toggle_input(false)
	store_summoned.emit()


func _on_store_button_mouse_entered() -> void:
	store_button_link.modulate = highlight_color


func _on_store_button_mouse_exited() -> void:
	store_button_link.modulate = default_color


func _on_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and !event.pressed:
		Input.warp_mouse(get_local_mouse_position())
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and !event.pressed:
		Input.warp_mouse(get_local_mouse_position())
