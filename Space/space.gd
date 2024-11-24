extends Node2D


signal damaged(strength: int, type: game_manager.damage_types)


const HAZARD = preload("res://Hazards/hazard.tscn")

@onready var particles: Node2D = $Particles
@onready var far_particles: GPUParticles2D = $"Particles/Far Particles"
@onready var middle_particles: GPUParticles2D = $"Particles/Middle Particles"
@onready var close_particles: GPUParticles2D = $"Particles/Close Particles"
@onready var grid: Node2D = $Grid
@onready var incoming_hazards: Node2D = $"Incoming Hazards"

const MIDDLE_POSITION: Vector2 = Vector2(128, 192)
const TWEEN_TIME: float = 0.3

var hazard_spots: Dictionary

var current_pos: Vector2 = Vector2.ZERO

var is_moving: bool = false


func _ready() -> void:
	create_hazard(Vector2.UP, 1.0, 2, [game_manager.damage_types.PHYSICAL, game_manager.damage_types.HEAT])


func create_hazard(spot: Vector2, time: float, strength: int, types: Array[game_manager.damage_types]) -> void:
	if spot in hazard_spots:
		print_debug("Tried creating a hazard in ", spot, ", which is busy")
		return
	var hazard := HAZARD.instantiate()
	hazard.strength = strength
	hazard.types = types
	hazard.spot = spot
	hazard.finished.connect(hit)
	hazard_spots[spot] = hazard
	hazard.set_time(time)
	incoming_hazards.add_child(hazard)
	hazard.position = spot * 64


func hit(spot: Vector2, strength: int, type: game_manager.damage_types) -> void:
	if spot == current_pos:
		damaged.emit(strength, type)
		print_debug("Damaged!")
	hazard_spots.erase(spot)


func move(to: Vector2) -> void:
	if is_moving:
		return
	var is_set: bool = false
	var tween: Tween = get_tree().create_tween()
	match to:
		Vector2.UP:
			if current_pos.y >= 0:
				current_pos.y -= 1
				var new_pos := current_pos.y * 64
				var new_pos_mid := current_pos.y * 48
				var new_pos_close := current_pos.y * 32
				var hazard_pos := current_pos.y * 56
				tween.set_parallel()
				tween.tween_property(far_particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:y", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:y", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:y", MIDDLE_POSITION.y + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(incoming_hazards, "position:y", MIDDLE_POSITION.y + hazard_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.DOWN:
			if current_pos.y <= 0:
				current_pos.y += 1
				var new_pos := current_pos.y * 64
				var new_pos_mid := current_pos.y * 48
				var new_pos_close := current_pos.y * 32
				var hazard_pos := current_pos.y * 56
				tween.set_parallel()
				tween.tween_property(far_particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:y", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:y", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:y", MIDDLE_POSITION.y + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(incoming_hazards, "position:y", MIDDLE_POSITION.y + hazard_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.LEFT:
			if current_pos.x >= 0:
				current_pos.x -= 1
				var new_pos := current_pos.x * 64
				var new_pos_mid := current_pos.x * 48
				var new_pos_close := current_pos.x * 32
				var hazard_pos := current_pos.x * 56
				tween.set_parallel()
				tween.tween_property(far_particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:x", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:x", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:x", MIDDLE_POSITION.x + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(incoming_hazards, "position:x", MIDDLE_POSITION.x + hazard_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.RIGHT:
			if current_pos.x <= 0:
				current_pos.x += 1
				var new_pos := current_pos.x * 64
				var new_pos_mid := current_pos.x * 48
				var new_pos_close := current_pos.x * 32
				var hazard_pos := current_pos.x * 56
				tween.set_parallel()
				tween.tween_property(far_particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:x", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:x", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:x", MIDDLE_POSITION.x + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(incoming_hazards, "position:x", MIDDLE_POSITION.x + hazard_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
	if is_set:
		tween.tween_callback(func(): is_moving = false).set_delay(TWEEN_TIME-0.1)
		is_moving = true
	else:
		tween.kill()
