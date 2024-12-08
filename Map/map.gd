extends Node2D


const MAP_NODE = preload("res://Map/Map Node/map_node.tscn")

@onready var map_nodes: Node2D = $"Map Nodes"
@onready var v_box: VBoxContainer = $Scroll/VBox

var grid: Array[Array] = []
var dummy_grid: Dictionary


func _ready() -> void:
	generate_map()


func _physics_process(_delta: float) -> void:
	queue_redraw()
	refresh_tooltips()


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
	for i in 10:
		var level: Array[map_node] = []
		for j in 6:
			var new_map_node := MAP_NODE.instantiate()
			map_nodes.add_child(new_map_node)
			level.append(new_map_node)
		grid.append(level)
		dummy_grid[i] = [0, 1, 2, 3, 4, 5]
	
	# Creating default connections
	for i in 9:
		grid[i][0].connected_to_nodes = [grid[i+1][0], grid[i+1][1]]
		for j in range(1, 5):
			grid[i][j].connected_to_nodes = [grid[i+1][j-1], grid[i+1][j], grid[i+1][j+1]]
		grid[i][5].connected_to_nodes = [grid[i+1][4], grid[i+1][5]]
	
	# Deleting random nodes
	for i in 18:
		var num: int = dummy_grid.keys().pick_random()
		var deleting: int = dummy_grid[num].pick_random()
		grid[num][deleting].disabled = true
		dummy_grid[num].erase(deleting)
		if dummy_grid[num].size() == 0:
			dummy_grid.erase(num)
	
	# Visualising result
	for i in grid:
		var h_box: HBoxContainer = HBoxContainer.new()
		v_box.add_child(h_box)
		v_box.move_child(h_box, 0)
		h_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
		var line: String = ""
		for j in 6:
			var color_rect: ColorRect = ColorRect.new()
			h_box.add_child(color_rect)
			color_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
			color_rect.custom_minimum_size = Vector2(10, 10)
			i[j].reparent(color_rect)
			i[j].position = Vector2.ZERO
			color_rect.add_to_group(&"visual_map_nodes")
			var s: String = "[V] "
			if i[j].disabled:
				s = "[X] "
				color_rect.color = Color("ff0000")
			else:
				color_rect.color = Color("00ff00")
			line += s
		print(line)
