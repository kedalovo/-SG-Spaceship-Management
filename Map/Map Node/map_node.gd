extends Node2D


class_name map_node


var connected_to_nodes: Array = []

var reason: int = 0

var disabled: bool = false
var is_continuation: bool = false


func add_connections(new_connections: Array) -> void:
	if is_continuation:
		for i in new_connections:
			if !i.disabled and i not in connected_to_nodes:
				connected_to_nodes.append(i)
				i.is_continuation = true
