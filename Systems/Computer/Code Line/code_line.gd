extends Node2D


class_name CodeLine

signal installed_correct_line(line: CodeLine, slot: CodeLine)
signal mouse_entered
signal button_down
signal button_up


@onready var label: Label = $Label
@onready var own_body: CharacterBody2D = $Body
@onready var area: Area2D = $Area
@onready var button: Button = $Button

var hovered_over: CodeLine
var installed_on: CodeLine

var length: int = 0
var slot_length: int = 0

var is_on_right: bool = false
var is_held: bool = false
var is_slot: bool = false
var is_installed: bool = false
var is_correct: bool = false


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
		modulate = Color("fffc4a")
		area.monitoring = false
		area.hide()
		own_body.show()
		own_body.get_child(0).disabled = false
		button.show()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		modulate = Color("ffffff")
		area.monitoring = false
		area.hide()
		own_body.hide()
		own_body.get_child(0).disabled = true
		button.hide()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


func set_slot(new_length: int) -> void:
	if label == null or own_body == null or area == null or button == null:
		label = $Label
		own_body = $Body
		area = $Area
		button = $Button
	slot_length = new_length
	modulate = Color("ffffff64")
	area.monitoring = true
	area.show()
	own_body.hide()
	own_body.get_child(0).disabled = true
	button.hide()


func set_text(text: String) -> void:
	label.text = text
	length = text.length()


func hide_label() -> void:
	label.hide()


func show_label() -> void:
	label.show()


func check_if_correct(installed_length: int) -> bool:
	if installed_length == slot_length:
		is_correct = true
	else:
		is_correct = false
	return is_correct


func _on_button_button_down() -> void:
	if is_on_right:
		button_down.emit()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		is_held = true
		if is_installed:
			installed_on.show_label()
			installed_on.is_correct = false


func _on_button_button_up() -> void:
	if is_held:
		button_up.emit()
		is_held = false
	if hovered_over != null:
		global_position = hovered_over.global_position
		installed_on = hovered_over
		installed_on.hide_label()
		if installed_on.check_if_correct(length):
			installed_on.installed_correct_line.emit(self, installed_on)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		is_installed = true
	else:
		position = Vector2.ZERO


func _on_area_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is CodeLine:
		parent.hovered_over = self


func _on_area_body_exited(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is CodeLine:
		parent.hovered_over = null
		if parent.is_held and parent.is_installed:
			parent.is_installed = false
			parent.installed_on = null


func _on_button_mouse_entered() -> void:
	mouse_entered.emit()
