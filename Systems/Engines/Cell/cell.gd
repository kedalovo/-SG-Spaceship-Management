extends Node2D

class_name Cell


signal cell_released(cell: Cell)


@onready var outline: Sprite2D = $Outline
@onready var break_sprite: Sprite2D = $Break
@onready var progress: TextureProgressBar = $Progress
@onready var cell_body: CharacterBody2D = $"Cell Body"


var type: game_manager.engine_cell_types

var start_pos: Vector2

var health: int = 100

var is_held: bool = false
var is_depleting: bool = false
var is_depleted: bool = false
var is_destroyed: bool = false


func use(amount: int) -> void:
	if is_depleting and !is_destroyed and !is_held:
		health -= amount
		if health <= 0:
			health = 0
			is_depleting = false
			is_depleted = true
		progress.value = health / 5.55556


func place_into_slot(slot_pos: Vector2, slot_rot: int) -> void:
	position = slot_pos
	rotation_degrees = -slot_rot + 90
	is_depleting = true
	is_held = false
	outline.hide()


func set_type(new_type: game_manager.engine_cell_types) -> void:
	if type != null:
		type = new_type
		if new_type == game_manager.engine_cell_types.FUEL:
			progress.modulate = Color("ffdd00")
		else:
			progress.modulate = Color("0081ff")


func destroy() -> void:
	is_depleting = false
	is_destroyed = true
	break_sprite.show()


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()


func _on_button_mouse_entered() -> void:
	if !is_depleting:
		outline.show()


func _on_button_mouse_exited() -> void:
	if !is_held:
		outline.hide()


func _on_button_button_down() -> void:
	if !is_depleting:
		is_held = true
	if is_depleted:
		queue_free()


func _on_button_button_up() -> void:
	if !is_depleting:
		is_held = false
		outline.hide()
		cell_released.emit(self)
