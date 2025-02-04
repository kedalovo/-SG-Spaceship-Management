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
@onready var store_button: TextureButton = $"Store Button Background/Store Button"

@export var line_color_global: Color

const NUM_OF_DELETIONS: int = 20
const LINE_NUM: int = 15
const LINE_LENGTH: int = 5
const POS_X_SPREAD: int = 32
const POS_Y_SPREAD: int = 32

var current_location: map_node = null

var grid: Array[Array] = []
var dummy_grid: Dictionary

var line_offset: float = 0.0

var current_level: int = -1


func _ready() -> void:
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
	for i in grid:
		for j in i:
			if j == current_location:
				for target in j.connected_to_nodes:
					if !target.disabled and !j.disabled:
						draw_default_punctured_line(j.global_position, target.global_position)
			else:
				for target in j.connected_to_nodes:
					if !target.disabled and !j.disabled:
						draw_line(target.global_position, j.global_position, line_color_global, 2)


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
			#print_debug("Filling line...")
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
		for j in range(1, LINE_LENGTH - 1):
			grid[i][j].add_connections([grid[i+1][j-1], grid[i+1][j], grid[i+1][j+1]])
		grid[i][LINE_LENGTH - 1].add_connections([grid[i+1][LINE_LENGTH - 2], grid[i+1][LINE_LENGTH - 1]])
	
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
			#print_debug("Line ", i, " was connected, all lines: ", str(sorted_order))
			#var c = 0
			for j in grid[i+1]:
				if !j.disabled:
					j.is_continuation = true
					#prints(i, c)
				#c += 1
	
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
	
	var hazards: Array = game_manager.hazard_types.keys()
	var hazard_buffer: Array = hazards.duplicate()
	var hazard_bin: Array = []
	var intensity: int = 0
	# Visualising result
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
				var picked_hazard: String = hazard_buffer.pop_front()
				hazard_bin.append(picked_hazard)
				line[j].hazards.append(picked_hazard)
				line[j].hazards_intensity.append(intensity)
				line[j].set_texture(ICONS[hazards.find(picked_hazard)])
			elif difficulty > 1:
				hazard_buffer.shuffle()
				var picked_hazard: String = hazard_buffer.pop_front()
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
			if line[j].disabled:
				line[j].hide()
	
	# Showing types of first two lines of locations
	for i in grid[0]:
		i.is_secret = false
		i.is_available = true
		i.update_icon()
	for i in grid[1]:
		i.is_secret = false
		i.update_icon()


func _on_map_node_mouse_enter(node: Node2D) -> void:
	marker.position = node.global_position
	marker_animator.play(&"show")
	cursor.hide()


func _on_map_node_mouse_exit(_node: Node2D) -> void:
	marker_animator.play_backwards(&"show")
	cursor.show()


func _on_map_node_pressed(node: map_node) -> void:
	current_location = node
	current_level += 1
	for i in grid[current_level]:
		i.is_available = false
	for i in current_location.connected_to_nodes:
		i.is_available = true
	location_changed.emit(node)


func _on_store_button_pressed() -> void:
	toggle_input(false)
	store_summoned.emit()


func _on_store_button_mouse_entered() -> void:
	store_button.modulate = highlight_color


func _on_store_button_mouse_exited() -> void:
	store_button.modulate = default_color
