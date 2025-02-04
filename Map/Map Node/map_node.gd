extends Node2D


class_name map_node


signal mouse_entered(node: map_node)
signal mouse_exited(node: map_node)
signal button_pressed(node: map_node)


@onready var icon: Sprite2D = $Icon

var true_texture: Texture2D

var connected_to_nodes: Array = []

var hazards: Array = []
var hazards_intensity: Array = []

var reason: int = 0
var difficulty: int = 0

var disabled: bool = false
var is_continuation: bool = false
var is_secret: bool = true
var is_available: bool = false


func add_connections(new_connections: Array) -> void:
	if is_continuation:
		for i in new_connections:
			if !i.disabled and i not in connected_to_nodes:
				connected_to_nodes.append(i)
				i.is_continuation = true


func update_icon() -> void:
	if !is_secret:
		icon.texture = true_texture


func set_default_texture(new_texture: Texture2D) -> void:
	icon.texture = new_texture


func set_texture(new_texture: Texture2D) -> void:
	true_texture = new_texture


func set_difficulty(new_difficulty: int) -> void:
	if difficulty == 0 and new_difficulty > difficulty:
		difficulty = new_difficulty
		match new_difficulty:
			1:
				icon.modulate = Color("00cb00")
			2:
				icon.modulate = Color("cbc800")
			3:
				icon.modulate = Color("cb0000")


func _on_mouse_grab_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_mouse_grab_mouse_exited() -> void:
	mouse_exited.emit(self)


func _on_button_pressed() -> void:
	if is_available:
		button_pressed.emit(self)
