extends Node2D


const MAP_NODE = preload("res://Map/Map Node/map_node.tscn")

@onready var map_nodes: Node2D = $"Map Nodes"
#@onready var v_box: VBoxContainer = $Scroll/VBox
@onready var map_container: Control = $"Scroll/Map Container"
@onready var scroll: ScrollContainer = $Scroll
@onready var cursor: Sprite2D = $Cursor
@onready var marker: Sprite2D = $Marker

const NUM_OF_DELETIONS: int = 20
const LINE_NUM: int = 15
const LINE_LENGTH: int = 5
const POS_X_SPREAD: int = 32
const POS_Y_SPREAD: int = 32

var grid: Array[Array] = []
var dummy_grid: Dictionary


func _ready() -> void:
	generate_map()
	scroll.set_deferred(&"scroll_vertical", 1504)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _physics_process(_delta: float) -> void:
	queue_redraw()
	refresh_tooltips()


func _process(_delta: float) -> void:
	cursor.position = get_global_mouse_position()


func _draw() -> void:
	for i in grid:
		for j in i:
			for target in j.connected_to_nodes:
				if !target.disabled and !j.disabled:
					draw_line(j.global_position, target.global_position, Color.DARK_BLUE, 2)


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
	
	# Visualising result
	for i in range(grid.size() - 1, -1, -1):
		var line: Array = grid[i]
		#var h_box: HBoxContainer = HBoxContainer.new()
		#v_box.add_child(h_box)
		#h_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
		#var console_line: String = ""
		for j in LINE_LENGTH:
			var color_rect: ColorRect = ColorRect.new()
			#h_box.add_child(color_rect)
			map_container.add_child(color_rect)
			color_rect.z_index = 1
			color_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
			color_rect.custom_minimum_size = Vector2(10, 10)
			color_rect.position = Vector2(j * 128 + 224 + randi_range(-POS_X_SPREAD, POS_X_SPREAD), i * 128 + 128 + randi_range(-POS_Y_SPREAD, POS_Y_SPREAD))
			#var text := Label.new()
			#text.text = str(line[j].reason)
			line[j].reparent(color_rect)
			#color_rect.add_child(text)
			line[j].position = Vector2.ZERO
			color_rect.add_to_group(&"visual_map_nodes")
			color_rect.mouse_entered.connect(_on_rect_enter.bind(color_rect))
			color_rect.mouse_exited.connect(_on_rect_exit.bind(color_rect))
			#var s: String = "[1] "
			if line[j].disabled:
				color_rect.hide()
				#s = "[0] "
				color_rect.color = Color("ff00001e")
			else:
				color_rect.color = Color("00ff00")
			#console_line += s
		#print(console_line)


func _on_rect_enter(rect: ColorRect) -> void:
	marker.position = rect.global_position + Vector2(5,5)
	marker.show()
	cursor.hide()


func _on_rect_exit(rect: ColorRect) -> void:
	marker.hide()
	cursor.show()
