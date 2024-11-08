extends Node2D


class_name Patch


signal patch_installed(patch: Patch, hole: Hole)
signal patch_completed(patch: Patch, hole: Hole)


@onready var mark_1: Sprite2D = $"Screw Marks/Mark 1"
@onready var mark_2: Sprite2D = $"Screw Marks/Mark 2"
@onready var mark_3: Sprite2D = $"Screw Marks/Mark 3"
@onready var mark_4: Sprite2D = $"Screw Marks/Mark 4"
@onready var sprite: Sprite2D = $Sprite
@onready var outline: Sprite2D = $Outline
@onready var button: Button = $Button

var initial_pos: Vector2

var mounted_on_hole: Hole
var index: int = -1

var is_held: bool = false
var is_1_set: bool = false
var is_2_set: bool = false
var is_3_set: bool = false
var is_4_set: bool = false
var is_halved: bool = false
var is_hovering_hole: bool = false


func set_marks() -> void:
	if is_halved:
		mark_2.show()
		mark_4.show()
		sprite.region_rect = Rect2(Vector2(0, 15), Vector2(48, 18))
	else:
		mark_1.show()
		mark_2.show()
		mark_3.show()
		mark_4.show()
		sprite.region_rect = Rect2(Vector2.ZERO, Vector2(48, 48))


func check_completion() -> void:
	if is_halved:
		if is_2_set and is_4_set:
			patch_completed.emit(self, mounted_on_hole)
	else:
		if is_1_set and is_2_set and is_3_set and is_4_set:
			patch_completed.emit(self, mounted_on_hole)


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()


func _on_mark_1_pressed() -> void:
	mark_1.modulate = Color.WHITE
	is_1_set = true
	check_completion()


func _on_mark_2_pressed() -> void:
	mark_2.modulate = Color.WHITE
	is_2_set = true
	check_completion()


func _on_mark_3_pressed() -> void:
	mark_3.modulate = Color.WHITE
	is_3_set = true
	check_completion()


func _on_mark_4_pressed() -> void:
	mark_4.modulate = Color.WHITE
	is_4_set = true
	check_completion()


func _on_button_button_down() -> void:
	is_held = true


func _on_button_button_up() -> void:
	outline.hide()
	is_held = false
	if is_hovering_hole:
		patch_installed.emit(self, mounted_on_hole)
		button.hide()
	else:
		position = initial_pos


func _on_button_mouse_entered() -> void:
	outline.show()


func _on_button_mouse_exited() -> void:
	outline.hide()
