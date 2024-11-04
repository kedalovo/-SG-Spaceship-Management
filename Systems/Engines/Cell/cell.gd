extends Node2D

class_name Cell


@onready var outline: Sprite2D = $Outline
@onready var break_sprite: Sprite2D = $Break
@onready var progress: TextureProgressBar = $Progress


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
	rotation_degrees = slot_rot
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


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_held = true


func _on_area_mouse_entered() -> void:
	if !is_depleting:
		outline.show()


func _on_area_mouse_exited() -> void:
	if !is_depleting and !is_held:
		outline.hide()
