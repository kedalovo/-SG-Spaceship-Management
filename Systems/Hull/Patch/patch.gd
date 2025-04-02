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
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var bearing_sound: AudioStreamPlayer2D = $"Bearing sound"

var initial_pos: Vector2

var mounted_on_hole: Hole
var index: int = -1

var is_held: bool = false
var is_1_set: bool = false
var is_2_set: bool = false
var is_3_set: bool = false
var is_4_set: bool = false
var is_halved: bool = false
var is_bigger: bool = false
var is_hovering_hole: bool = false
var is_completed: bool = false


func set_marks() -> void:
	if is_bigger:
		mark_1.scale = Vector2(2.5, 2.5)
		mark_2.scale = Vector2(2.5, 2.5)
		mark_3.scale = Vector2(2.5, 2.5)
		mark_4.scale = Vector2(2.5, 2.5)
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


func reset() -> void:
	mark_1.hide()
	mark_2.hide()
	mark_3.hide()
	mark_4.hide()
	mark_1.modulate = Color("0000005b")
	mark_2.modulate = Color("0000005b")
	mark_3.modulate = Color("0000005b")
	mark_4.modulate = Color("0000005b")
	is_1_set = false
	is_2_set = false
	is_3_set = false
	is_4_set = false
	is_hovering_hole = false
	sprite.region_rect = Rect2(Vector2(15, 15), Vector2(18, 18))
	button.show()
	position = initial_pos


func check_completion() -> void:
	if is_halved:
		if is_2_set and is_4_set:
			patch_completed.emit(self, mounted_on_hole)
			complete()
	else:
		if is_1_set and is_2_set and is_3_set and is_4_set:
			patch_completed.emit(self, mounted_on_hole)
			complete()


func complete() -> void:
	is_completed = true
	sprite.region_rect = Rect2(Vector2(15, 15), Vector2(18, 18))
	mark_1.hide()
	mark_2.hide()
	mark_3.hide()
	mark_4.hide()


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()


func _on_mark_1_pressed() -> void:
	mark_1.modulate = Color.WHITE
	is_1_set = true
	bearing_sound.play()
	check_completion()


func _on_mark_2_pressed() -> void:
	mark_2.modulate = Color.WHITE
	is_2_set = true
	bearing_sound.play()
	check_completion()


func _on_mark_3_pressed() -> void:
	mark_3.modulate = Color.WHITE
	is_3_set = true
	bearing_sound.play()
	check_completion()


func _on_mark_4_pressed() -> void:
	mark_4.modulate = Color.WHITE
	is_4_set = true
	bearing_sound.play()
	check_completion()


func _on_button_button_down() -> void:
	is_held = true
	sound.pitch_scale = 1.0
	sound.play()


func _on_button_button_up() -> void:
	outline.hide()
	is_held = false
	sound.pitch_scale = 1.1
	sound.play()
	if is_hovering_hole:
		patch_installed.emit(self, mounted_on_hole)
		button.hide()
	else:
		position = initial_pos


func _on_button_mouse_entered() -> void:
	outline.show()
	sound.pitch_scale = 0.9
	sound.play()


func _on_button_mouse_exited() -> void:
	outline.hide()
