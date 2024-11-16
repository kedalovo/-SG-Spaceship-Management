extends Node2D


class_name CodeLine


@onready var label: Label = $Label
@onready var own_body: CharacterBody2D = $Body
@onready var area: Area2D = $Area
@onready var button: Button = $Button

var is_on_right: bool = false
var is_held: bool = false
var is_slot: bool = false


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position() + Vector2(-74, 0)


func set_type(is_right: bool) -> void:
	if label == null or own_body == null or area == null or button == null:
		label = $Label
		own_body = $Body
		area = $Area
		button = $Button
	is_on_right = is_right
	if is_right:
		area.monitoring = false
		area.hide()
		own_body.show()
		own_body.get_child(0).disabled = false
		button.show()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		area.monitoring = false
		area.hide()
		own_body.hide()
		own_body.get_child(0).disabled = true
		button.hide()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


func set_slot() -> void:
	if label == null or own_body == null or area == null or button == null:
		label = $Label
		own_body = $Body
		area = $Area
		button = $Button
	area.monitoring = true
	area.show()
	own_body.hide()
	own_body.get_child(0).disabled = true
	button.hide()


func set_text(text: String) -> void:
	label.text = text


func _on_button_button_down() -> void:
	if is_on_right:
		is_held = true


func _on_button_button_up() -> void:
	if is_held:
		is_held = false
		position = Vector2.ZERO


func _on_area_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is CodeLine:
		print("Code line entered!")


func _on_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
