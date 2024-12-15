extends Node2D


class_name map_node


signal mouse_entered(node: map_node)
signal mouse_exited(node: map_node)


@onready var icon: Sprite2D = $Icon

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


func set_texture(new_texture: Texture2D) -> void:
	icon.texture = new_texture


func _on_mouse_grab_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_mouse_grab_mouse_exited() -> void:
	mouse_exited.emit(self)
