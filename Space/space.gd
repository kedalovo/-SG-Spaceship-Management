extends Node2D


signal damaged(strength: int, type: game_manager.damage_types)


const HAZARD = preload("res://Hazards/hazard.tscn")
const ASTEROID = preload("res://Hazards/Asteroid/asteroid.tscn")

@onready var particles: Node2D = $Particles
@onready var far_particles: GPUParticles2D = $"Particles/Far Particles"
@onready var middle_particles: GPUParticles2D = $"Particles/Middle Particles"
@onready var close_particles: GPUParticles2D = $"Particles/Close Particles"
@onready var grid: Node2D = $Grid
@onready var incoming_hazards: Node2D = $"Incoming Hazards"
@onready var hazard_visuals: Node2D = $"Grid/Hazard visuals"

const RANDOM_ROTATION: Array[float] = [0.0, 90.0, 180.0, 270.0]
const MIDDLE_POSITION: Vector2 = Vector2(128, 192)
const TWEEN_TIME: float = 0.3

var hazard_spots: Dictionary

var current_grid_pos: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO

var is_moving: bool = false


func create_asteroid(size: game_manager.asteroid_types, spot: Vector2, time: float, is_vertical: bool = false, types: Array[game_manager.damage_types] = [game_manager.damage_types.PHYSICAL]) -> void:
	spot = clamp(spot, -Vector2.ONE, Vector2.ONE)
	var asteroid := ASTEROID.instantiate()
	match size:
		game_manager.asteroid_types.SMALL:
			if spot in hazard_spots:
				push_warning("Tried creating a small asteroid in ", spot, ", which is busy")
				return
			asteroid.set_types(types)
			asteroid.set_time(time)
			asteroid.set_visuals(size, false)
			hazard_visuals.add_child(asteroid)
			asteroid.position = Vector2(spot.x * 64, spot.y * 64)
			create_hazard(spot, time, 1, types)
		game_manager.asteroid_types.MEDIUM:
			if is_vertical:
				for i in 3:
					if Vector2(spot.x, spot.y + i) in hazard_spots or spot.y + i > 1:
						push_warning("Tried creating a medium asteroid in ", spot, ", which is busy or out of bounds at ", spot.y + i, ", vertical: ", is_vertical)
						return
				asteroid.position = Vector2(spot.x * 64, (spot.y + 1) * 64)
			else:
				for i in 3:
					if Vector2(spot.x + i, spot.y) in hazard_spots or spot.x + i > 1:
						push_warning("Tried creating a medium asteroid in ", spot, ", which is busy or out of bounds at ", spot.x + i, ", vertical: ", is_vertical)
						return
				asteroid.position = Vector2((spot.x + 1) * 64, spot.y * 64)
			asteroid.set_types(types)
			asteroid.set_time(time)
			asteroid.set_visuals(size, is_vertical)
			hazard_visuals.add_child(asteroid)
			if is_vertical:
				for i in 3:
					create_hazard(Vector2(spot.x, spot.y + i), time, 2, types)
			else:
				for i in 3:
					create_hazard(Vector2(spot.x + i, spot.y), time, 2, types)
		game_manager.asteroid_types.LARGE:
			if is_vertical:
				for i in 3:
					for j in 2:
						if Vector2(spot.x - j, spot.y + i) in hazard_spots or spot.y + i > 1 or spot.x - j < -1:
							push_warning("Tried creating a large asteroid in ", spot, ", which is busy or out of bounds at ", Vector2(spot.x - j, spot.y + i), ", vertical: ", is_vertical)
							return
				asteroid.position = Vector2((spot.x - 0.5) * 64, (spot.y + 1) * 64)
			else:
				for i in 3:
					for j in 2:
						if Vector2(spot.x + i, spot.y + j) in hazard_spots or spot.y + j > 1 or spot.x + i > 1:
							push_warning("Tried creating a large asteroid in ", spot, ", which is busy or out of bounds at ", Vector2(spot.x + i, spot.y + j), ", vertical: ", is_vertical)
							return
				asteroid.position = Vector2((spot.x + 1) * 64, (spot.y + 0.5) * 64)
			asteroid.set_types(types)
			asteroid.set_time(time)
			asteroid.set_visuals(size, is_vertical)
			hazard_visuals.add_child(asteroid)
			if is_vertical:
				for i in 3:
					for j in 2:
						create_hazard(Vector2(spot.x - j, spot.y + i), time, 3, types)
			else:
				for i in 3:
					for j in 2:
						create_hazard(Vector2(spot.x + i, spot.y + j), time, 3, types)


func create_hazard(spot: Vector2, time: float, strength: int, types: Array[game_manager.damage_types]) -> void:
	if spot in hazard_spots:
		push_warning("Tried creating a hazard in ", spot, ", which is busy")
		return
	var hazard := HAZARD.instantiate()
	hazard.strength = strength
	hazard.types = types
	hazard.spot = spot
	hazard.finished.connect(hit)
	hazard_spots[spot] = hazard
	hazard.set_time(time)
	incoming_hazards.add_child(hazard)
	hazard.position = Vector2(spot.x * 64, spot.y * 64)


func hit(spot: Vector2, strength: int, type: game_manager.damage_types) -> void:
	if spot == -current_grid_pos:
		damaged.emit(strength, type)
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
				current_grid_pos.y += 1
				var new_pos := current_grid_pos.y * 64
				var new_pos_mid := current_grid_pos.y * 48
				var new_pos_close := current_grid_pos.y * 32
				var hazard_pos := current_grid_pos.y * 56
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
				current_grid_pos.y -= 1
				var new_pos := current_grid_pos.y * 64
				var new_pos_mid := current_grid_pos.y * 48
				var new_pos_close := current_grid_pos.y * 32
				var hazard_pos := current_grid_pos.y * 56
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
				current_grid_pos.x += 1
				var new_pos := current_grid_pos.x * 64
				var new_pos_mid := current_grid_pos.x * 48
				var new_pos_close := current_grid_pos.x * 32
				var hazard_pos := current_grid_pos.x * 56
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
				current_grid_pos.x -= 1
				var new_pos := current_grid_pos.x * 64
				var new_pos_mid := current_grid_pos.x * 48
				var new_pos_close := current_grid_pos.x * 32
				var hazard_pos := current_grid_pos.x * 56
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
