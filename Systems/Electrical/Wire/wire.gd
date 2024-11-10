extends Node2D


class_name Wire


signal connected_to_wire(from: Wire, to: Wire)


@onready var top: Sprite2D = $Top
@onready var middle: Sprite2D = $Middle
@onready var area: Area2D = $Top/Area
@onready var own_body: CharacterBody2D = $Body

var candidate: Wire

var is_held: bool = false
var is_receiver: bool = false
var is_connected_to_wire: bool = false
var is_on_candidate: bool = false


func _physics_process(_delta: float) -> void:
	if is_held:
		look_at(get_global_mouse_position())
		top.position.x = get_local_mouse_position().x
		middle.scale.y = top.position.x / 8.0 - 0.5


func set_receiver() -> void:
	is_receiver = true
	area.monitoring = false


func set_tranceiver() -> void:
	is_receiver = false


func connect_to_wire(wire: Wire) -> void:
	look_at(wire.global_position)
	top.position.x = to_local(wire.global_position).x
	middle.scale.y = top.position.x / 8.0 - 0.5
	wire.hide()
	wire.is_connected_to_wire = true
	wire.look_at(global_position)
	is_connected_to_wire = true
	is_on_candidate = false
	connected_to_wire.emit(self, wire)


func _on_button_button_down() -> void:
	if !is_receiver and !is_connected_to_wire:
		is_held = true


func _on_button_button_up() -> void:
	is_held = false
	if is_on_candidate:
		connect_to_wire(candidate)
	else:
		if !is_receiver and !is_connected_to_wire:
			rotation_degrees = 0
			top.position.x = 8
			middle.scale.y = 0.5


func _on_area_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is Wire and parent != self:
		if parent.is_receiver and parent.modulate == modulate:
			candidate = parent
			is_on_candidate = true


func _on_area_body_exited(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is Wire and parent != self:
		if parent.is_receiver and parent.modulate == modulate:
			candidate = null
			is_on_candidate = false
