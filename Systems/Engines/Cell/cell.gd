extends Node2D

class_name Cell


signal cell_released(cell: Cell)
signal being_deleted(cell: Cell)
signal held(type: game_manager.engine_cell_types)


@onready var outline: Sprite2D = $Outline
@onready var break_sprite: Sprite2D = $Break
@onready var progress: TextureProgressBar = $Progress
@onready var cell_body: CharacterBody2D = $"Cell Body"
@onready var sound: AudioStreamPlayer2D = $Sound


var type: game_manager.engine_cell_types

var start_pos: Vector2

var health: float = 100.0
var in_slot: int = -1

var is_held: bool = false
var is_depleting: bool = false
var is_depleted: bool = false
var is_destroyed: bool = false
var is_mouse_on_top: bool = false


func use(amount: float) -> void:
	if is_depleting and !is_destroyed and !is_held:
		var total_amount: float = 0.0
		if type == game_manager.engine_cell_types.FUEL:
			total_amount = amount * game_manager.wear_modifier
		elif type == game_manager.engine_cell_types.COOLANT:
			total_amount = amount / game_manager.wear_modifier
		health -= total_amount
		if health <= 0:
			health = 0
			is_depleting = false
			is_depleted = true
			modulate = Color("707070")
			if is_mouse_on_top:
				outline.show()
		progress.value = health / 5.55556


func place_into_slot(slot: Node) -> void:
	if !is_depleting and in_slot < 0:
		match type:
			game_manager.engine_cell_types.FUEL:
				game_manager.fuel_cell_amount -= 1
				print("[VALUE-] Fuel cell removed, now ", game_manager.fuel_cell_amount)
			game_manager.engine_cell_types.COOLANT:
				game_manager.coolant_cell_amount -= 1
				print("[VALUE-] Coolant cell removed, now ", game_manager.coolant_cell_amount)
	in_slot = slot.index
	slot.is_busy = true
	position = slot.position
	rotation_degrees = -slot.cell_angle + 90
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
	print("[CELL] Destroying")
	is_depleting = false
	is_destroyed = true
	break_sprite.show()


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()


func _on_button_mouse_entered() -> void:
	is_mouse_on_top = true
	if !is_depleting:
		sound.pitch_scale = 0.9
		sound.play()
		outline.show()


func _on_button_mouse_exited() -> void:
	is_mouse_on_top = false
	if !is_held:
		outline.hide()


func _on_button_button_down() -> void:
	if !is_depleting:
		print("[CELL] Picked up")
		is_held = true
		held.emit(type)
		sound.pitch_scale = 1.0
		sound.play()
	if is_depleted or is_destroyed:
		print("[CELL] Deleting destroyed")
		being_deleted.emit(self)


func _on_button_button_up() -> void:
	if !is_depleting:
		print("[CELL] Put down")
		sound.pitch_scale = 1.1
		sound.play()
		is_held = false
		outline.hide()
		cell_released.emit(self)
