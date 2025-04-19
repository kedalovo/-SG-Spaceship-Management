extends Resource


class_name map_node_save_template


@export var node_name: String = ""
@export var true_icon_path: String = "res://Map/Map Node/Icons/Question Icon.png"
@export var connected_to_nodes: Array[Vector2i] = []
@export var hazards: Array[game_manager.hazard_types] = []
@export var hazards_intensity: Array[int] = []
@export var hazards_types: Array[Array] = []
@export var map_index: Vector2i = Vector2i(-1, -1)
@export var wormhole_index: Vector2i = Vector2i(-1, -1)
@export var global_position: Vector2 = Vector2(-1.0, -1.0)

@export var reason: int = -1
@export var difficulty: int = -1

@export var disabled: bool = false
@export var is_continuation: bool = false
@export var is_secret: bool = false
@export var is_available: bool = false
@export var has_destination: bool = false
@export var has_wormhole: bool = false
@export var is_wormhole: bool = false


func _init(new_map_node: map_node = map_node.new()) -> void:
	node_name = new_map_node.name
	true_icon_path = new_map_node.true_texture.resource_path
	for i in new_map_node.connected_to_nodes:
		connected_to_nodes.append(i.map_index)
	hazards = new_map_node.hazards
	hazards_intensity = new_map_node.hazards_intensity
	hazards_types = new_map_node.hazards_types
	map_index = new_map_node.map_index
	if new_map_node.has_wormhole:
		wormhole_index = new_map_node.wormhole.map_index
	global_position = new_map_node.position
	
	difficulty = new_map_node.difficulty
	
	disabled = new_map_node.disabled
	is_continuation = new_map_node.is_continuation
	is_secret = new_map_node.is_secret
	is_available = new_map_node.is_available
	has_destination = new_map_node.has_destination
	has_wormhole = new_map_node.has_wormhole
	is_wormhole = new_map_node.is_wormhole
