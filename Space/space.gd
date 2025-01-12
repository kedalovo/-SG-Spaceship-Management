extends Node2D


signal damaged(strength: int, type: game_manager.damage_types)
signal new_location_set_up
signal coin_got


const HAZARD = preload("res://Hazards/hazard.tscn")
const ASTEROID = preload("res://Hazards/Asteroid/asteroid.tscn")
const NEBULA = preload("res://Hazards/Nebula/nebula.tscn")
const ROCKET = preload("res://Hazards/Rocket/rocket.tscn")
const STAR = preload("res://Hazards/Star Proximity/star.tscn")

const COIN = preload("res://Coin/coin.tscn")


@onready var particles: Node2D = $Particles
@onready var far_particles: GPUParticles2D = $"Particles/Far Particles"
@onready var middle_particles: GPUParticles2D = $"Particles/Middle Particles"
@onready var close_particles: GPUParticles2D = $"Particles/Close Particles"
@onready var grid: Node2D = $Grid
@onready var incoming_hazards: Node2D = $"Incoming Hazards"
@onready var hazard_visuals: Node2D = $"Grid/Hazard visuals"
@onready var camera: Camera2D = $Camera
@onready var hazard_timer_1: Timer = $"Hazard Timer 1"
@onready var hazard_timer_2: Timer = $"Hazard Timer 2"
@onready var hazard_timers: Array = [hazard_timer_1, hazard_timer_2]
@onready var coin_timer: Timer = $"Coin Timer"

@onready var separators: Node2D = $Grid/Separators

var current_location: map_node

const RANDOM_ROTATION: Array[float] = [0.0, 90.0, 180.0, 270.0]
const MIDDLE_POSITION: Vector2 = Vector2(128, 192)
const TWEEN_TIME: float = 0.3

var hazard_spots: Dictionary
var hazard_nebula_spots: Dictionary

var current_grid_pos: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO

var is_moving: bool = false


func _ready() -> void:
	#separators.modulate = Color.WHITE
	#create_rocket(2.0, 3.5, 1)
	#create_star(10.0, 1)
	pass


func start() -> void:
	match current_location.hazards_intensity[0]:
		1:
			coin_timer.start(10)
		2:
			coin_timer.start(9)
		3:
			coin_timer.start(8)
		4:
			coin_timer.start(7)
		5:
			coin_timer.start(6)
		6:
			coin_timer.start(5)
		7:
			coin_timer.start(4)
		8:
			coin_timer.start(3)
	for idx in current_location.hazards.size():
		var hazard: String = current_location.hazards[idx]
		var intensity: int = current_location.hazards_intensity[idx]
		var hazard_timer: Timer = hazard_timers[idx]
		match hazard:
			&"ASTEROID_FIELD":
				@warning_ignore("integer_division")
				hazard_timer.wait_time = 30.0 - (intensity / 2) * 5.0 + idx * 2.0
				hazard_timer.start()
			&"WARZONE":
				@warning_ignore("integer_division")
				hazard_timer.wait_time = 30.0 - (intensity / 2) * 5.0 + idx * 2.0
				hazard_timer.start()
			&"NEBULA":
				@warning_ignore("integer_division")
				hazard_timer.wait_time = 30.0 - (intensity / 2) * 5.0 + idx * 2.0
				hazard_timer.start()
			&"ICE_FIELD":
				create_ice_world(floorf(0.6 + 0.5 * intensity))
			&"STAR_PROXIMITY":
				match intensity:
					1:
						create_star(30, 1)
					2:
						create_star(20, 1)
					3:
						create_star(20, 2)
					4:
						create_star(25, 2)
					5:
						create_star(20, 2)
					6:
						create_star(15, 2)
					7:
						create_star(15, 3)
					8:
						create_star(10, 3)


func propagate_hazard(idx: int) -> void:
	var hazard: String = current_location.hazards[idx]
	var intensity: int = current_location.hazards_intensity[idx]
	match hazard:
		&"ASTEROID_FIELD":
			var picked_option: int = 0
			if randi() == 0:
				picked_option = intensity
			elif intensity != 1:
				picked_option = randi_range(1, intensity - 1)
			else:
				picked_option = 1
			match picked_option:
				1:
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 10.0)
				2:
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 9.0)
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 9.0)
				3:
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 8.0)
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 8.0)
					create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 8.0)
				4:
					if randi() == 0:
						create_asteroid(game_manager.asteroid_types.MEDIUM, [-Vector2.ONE, Vector2.LEFT, Vector2.LEFT + Vector2.DOWN].pick_random(), 7.0)
					else:
						create_asteroid(game_manager.asteroid_types.MEDIUM, [-Vector2.ONE, Vector2.UP, Vector2.UP + Vector2.RIGHT].pick_random(), 7.0, true)
				5:
					if randi() == 0:
						var list: Array = [-Vector2.ONE, Vector2.LEFT, Vector2.LEFT + Vector2.DOWN]
						var picked_spot: Vector2 = list.pick_random()
						list.erase(picked_spot)
						create_asteroid(game_manager.asteroid_types.MEDIUM, picked_spot, 6.0)
						create_asteroid(game_manager.asteroid_types.MEDIUM, list.pick_random(), 6.0)
					else:
						var list: Array = [-Vector2.ONE, Vector2.UP, Vector2.UP + Vector2.RIGHT]
						var picked_spot: Vector2 = list.pick_random()
						list.erase(picked_spot)
						create_asteroid(game_manager.asteroid_types.MEDIUM, picked_spot, 6.0, true)
						create_asteroid(game_manager.asteroid_types.MEDIUM, list.pick_random(), 6.0, true)
				6:
					if randi() == 0:
						var list: Array = [-Vector2.ONE, Vector2.LEFT, Vector2.LEFT + Vector2.DOWN]
						var p1: Vector2 = list.pick_random()
						list.erase(p1)
						var p2: Vector2 = list.pick_random()
						list.erase(p2)
						create_asteroid(game_manager.asteroid_types.MEDIUM, p1, 5.0)
						create_asteroid(game_manager.asteroid_types.MEDIUM, p2, 5.0)
						create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 5.0)
					else:
						var list: Array = [-Vector2.ONE, Vector2.UP, Vector2.UP + Vector2.RIGHT]
						var p1: Vector2 = list.pick_random()
						list.erase(p1)
						var p2: Vector2 = list.pick_random()
						list.erase(p2)
						create_asteroid(game_manager.asteroid_types.MEDIUM, p1, 5.0, true)
						create_asteroid(game_manager.asteroid_types.MEDIUM, p2, 5.0, true)
						create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 5.0)
				7:
					if randi() == 0:
						create_asteroid(game_manager.asteroid_types.LARGE, [-Vector2.ONE, Vector2.LEFT].pick_random(), 4.0)
					else:
						create_asteroid(game_manager.asteroid_types.LARGE, [Vector2.UP, Vector2.UP + Vector2.RIGHT].pick_random(), 4.0, true)
				8:
					if randi() == 0:
						create_asteroid(game_manager.asteroid_types.LARGE, [-Vector2.ONE, Vector2.LEFT].pick_random(), 3.0)
						create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 3.0)
					else:
						create_asteroid(game_manager.asteroid_types.LARGE, [Vector2.UP, Vector2.UP + Vector2.RIGHT].pick_random(), 3.0, true)
						create_asteroid(game_manager.asteroid_types.SMALL, get_free_spot(), 3.0)
		&"WARZONE":
			match intensity:
				1:
					create_rocket(0.6, 7.0, 1)
				2:
					create_rocket(0.8, 6.5, 1)
				3:
					for i in randi()%2:
						create_rocket(1.0, 6.0, 2, i * 2.5)
				4:
					for i in randi()%2:
						create_rocket(1.2, 5.5, 2, i * 2.5)
				5:
					for i in randi()%2:
						create_rocket(1.4, 5.0, 2, i * 2.5)
				6:
					for i in randi()%3:
						create_rocket(1.6, 4.5, 3, i * 2.0)
				7:
					for i in randi()%3:
						create_rocket(1.8, 4.0, 3, i * 2.0)
				8:
					for i in randi()%3:
						create_rocket(2.0, 3.5, 3, i * 2.0)
		&"NEBULA":
			var picked_option: int = 0
			if randi() == 0:
				picked_option = clamp(intensity, 1, 7)
			elif intensity != 1:
				picked_option = randi_range(1, intensity - 1)
			else:
				picked_option = 1
			match picked_option:
				1:
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 30, false, 5.0)
				2:
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 30, false, 4.5)
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 30, false, 4.5)
				3:
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 25, false, 4.0)
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 25, false, 4.0)
					create_nebula(game_manager.nebula_types.SMALL, get_free_nebula_spot(), 25, false, 4.0)
				4:
					create_nebula(game_manager.nebula_types.SMALL, Vector2.ONE, 25, false, 3.5)
					create_nebula(game_manager.nebula_types.SMALL, -Vector2.ONE, 25, false, 3.5)
					create_nebula(game_manager.nebula_types.SMALL, Vector2.UP + Vector2.RIGHT, 25, false, 3.5)
					create_nebula(game_manager.nebula_types.SMALL, -(Vector2.UP + Vector2.RIGHT), 25, false, 3.5)
				5:
					create_nebula(game_manager.nebula_types.MEDIUM, [-Vector2.ONE, Vector2.UP, Vector2.LEFT, Vector2.ZERO].pick_random(), 20, false, 3.0)
				6:
					var picked_corner: Vector2 = [-Vector2.ONE, Vector2.UP, Vector2.LEFT, Vector2.ZERO].pick_random()
					match picked_corner:
						-Vector2.ONE:
							create_nebula(game_manager.nebula_types.MEDIUM, -Vector2.ONE, 20, false, 2.5)
							create_nebula(game_manager.nebula_types.SMALL, [Vector2.UP + Vector2.RIGHT, Vector2.DOWN + Vector2.LEFT].pick_random(), 20, false, 2.5)
						Vector2.UP:
							create_nebula(game_manager.nebula_types.MEDIUM, Vector2.UP, 20, false, 2.5)
							create_nebula(game_manager.nebula_types.SMALL, [Vector2.UP + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT].pick_random(), 20, false, 2.5)
						Vector2.LEFT:
							create_nebula(game_manager.nebula_types.MEDIUM, Vector2.LEFT, 20, false, 2.5)
							create_nebula(game_manager.nebula_types.SMALL, [Vector2.UP + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT].pick_random(), 20, false, 2.5)
						Vector2.ZERO:
							create_nebula(game_manager.nebula_types.MEDIUM, Vector2.ZERO, 20, false, 2.5)
							create_nebula(game_manager.nebula_types.SMALL, [Vector2.UP + Vector2.RIGHT, Vector2.DOWN + Vector2.LEFT].pick_random(), 20, false, 2.5)
				7:
					if randi() == 0:
						create_nebula(game_manager.nebula_types.LARGE, [Vector2.UP + Vector2.LEFT, Vector2.LEFT].pick_random(), 15, false, 2.0)
					else:
						create_nebula(game_manager.nebula_types.LARGE, [Vector2.UP, Vector2.UP + Vector2.RIGHT].pick_random(), 15, false, 2.0, true)


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


func create_nebula(size: game_manager.nebula_types, spot: Vector2, time: float, is_instant: bool = true, hurt_time: float = 0.0, is_vertical: bool = false, types: Array[game_manager.damage_types] = [game_manager.damage_types.ELECTRICITY]) -> void:
	spot = clamp(spot, -Vector2.ONE, Vector2.ONE)
	var nebula := NEBULA.instantiate()
	match size:
		game_manager.nebula_types.SMALL:
			if spot in hazard_nebula_spots:
				push_warning("Tried creating a small nebula in ", spot, ", which is busy")
				return
			nebula.set_types(types)
			nebula.set_time(time)
			nebula.set_visuals(size, false)
			hazard_visuals.add_child(nebula)
			nebula.position = Vector2(spot.x * 64, spot.y * 64)
			create_hazard(spot, time + 1.0, 1, types, is_instant, hurt_time)
		game_manager.nebula_types.MEDIUM:
			for i in 2:
				for j in 2:
					if Vector2(spot.x + i, spot.y + j) in hazard_nebula_spots or spot.y + j > 1 or spot.x + i > 1:
						push_warning("Tried creating a medium nebula in ", spot, ", which is busy or out of bounds at ", spot.x + i, ", vertical: ", is_vertical)
						return
			nebula.position = Vector2((spot.x + 0.5) * 64, (spot.y + 0.5) * 64)
			nebula.set_types(types)
			nebula.set_time(time)
			nebula.set_visuals(size, is_vertical)
			hazard_visuals.add_child(nebula)
			for i in 2:
				for j in 2:
					create_hazard(Vector2(spot.x + i, spot.y + j), time + 1.0, 2, types, is_instant, hurt_time)
		game_manager.nebula_types.LARGE:
			if is_vertical:
				for i in 3:
					for j in 2:
						if Vector2(spot.x - j, spot.y + i) in hazard_nebula_spots or spot.y + i > 1 or spot.x - j < -1:
							push_warning("Tried creating a large nebula in ", spot, ", which is busy or out of bounds at ", Vector2(spot.x - j, spot.y + i), ", vertical: ", is_vertical)
							return
				nebula.position = Vector2((spot.x - 0.5) * 64, (spot.y + 1) * 64)
			else:
				for i in 3:
					for j in 2:
						if Vector2(spot.x + i, spot.y + j) in hazard_nebula_spots or spot.y + j > 1 or spot.x + i > 1:
							push_warning("Tried creating a large nebula in ", spot, ", which is busy or out of bounds at ", Vector2(spot.x + i, spot.y + j), ", vertical: ", is_vertical)
							return
				nebula.position = Vector2((spot.x + 1) * 64, (spot.y + 0.5) * 64)
			nebula.set_types(types)
			nebula.set_time(time)
			nebula.set_visuals(size, is_vertical)
			hazard_visuals.add_child(nebula)
			if is_vertical:
				for i in 3:
					for j in 2:
						create_hazard(Vector2(spot.x - j, spot.y + i), time + 1.0, 3, types, is_instant, hurt_time)
			else:
				for i in 3:
					for j in 2:
						create_hazard(Vector2(spot.x + i, spot.y + j), time + 1.0, 3, types, is_instant, hurt_time)


func create_rocket(speed: float, time: float, damage: int, offset: float = 0.0) -> void:
	var new_rocket := ROCKET.instantiate()
	new_rocket.set_time(time)
	new_rocket.set_start_time(clampf(offset, 0.001, 15.0))
	new_rocket.target = camera
	new_rocket.speed = speed
	new_rocket.damage = clampi(damage, 1, 5)
	new_rocket.finished.connect(_on_rocket_hit)
	hazard_visuals.add_child(new_rocket)
	new_rocket.position = Vector2(64, 64)


func create_star(period: float, damage: int) -> void:
	var star := STAR.instantiate()
	star.damage = damage
	star.hit.connect(_on_star_flare_hit)
	star.set_time(period)
	hazard_visuals.add_child(star)


func create_ice_world(modifier: float) -> void:
	game_manager.wear_modifier = modifier


func create_hazard(spot: Vector2, time: float, strength: int, types: Array[game_manager.damage_types], is_instant: bool = true, hurt_time: float = 0.0) -> void:
	if spot in hazard_spots and is_instant:
		push_warning("Tried creating a hazard in ", spot, ", which is busy")
		return
	elif spot in hazard_nebula_spots and !is_instant:
		push_warning("Tried creating a nebula hazard in ", spot, ", which is busy")
		return
	var hazard := HAZARD.instantiate()
	hazard.strength = strength
	hazard.types = types
	hazard.spot = spot
	hazard.is_instant = is_instant
	hazard.hit.connect(hit)
	hazard.finished.connect(hazard_finished)
	if is_instant:
		hazard_spots[spot] = hazard
	else:
		hazard_nebula_spots[spot] = hazard
	hazard.set_time(time)
	if !is_instant:
		hazard.set_hurt_time(hurt_time)
	incoming_hazards.add_child(hazard)
	hazard.position = Vector2(spot.x * 64, spot.y * 64)


func create_coin(time: float) -> void:
	var new_coin := COIN.instantiate()
	var spot: Vector2 = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	new_coin.spot = spot
	new_coin.set_time(time)
	new_coin.finished.connect(coin_finished)
	new_coin.position = Vector2(spot.x * 64, spot.y * 64)
	incoming_hazards.add_child(new_coin)


func direct_hit(strength: int, type: game_manager.damage_types) -> void:
	damaged.emit(strength, type)


func hit(spot: Vector2, strength: int, type: game_manager.damage_types) -> void:
	if spot == current_pos:
		damaged.emit(strength, type)


func hazard_finished(hazard: Hazard) -> void:
	if hazard.is_instant:
		hazard_spots.erase(hazard_spots.keys()[hazard_spots.values().find(hazard)])
	else:
		hazard_nebula_spots.erase(hazard_nebula_spots.keys()[hazard_nebula_spots.values().find(hazard)])
	hazard.queue_free()


func coin_finished(spot: Vector2) -> void:
	if spot == current_pos:
		coin_got.emit()


func move(to: Vector2) -> bool:
	if is_moving:
		return false
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
		return true
	else:
		tween.kill()
		return false


func get_free_spot() -> Vector2:
	var spots: Array = [
		Vector2.UP + Vector2.LEFT, Vector2.UP, Vector2.UP + Vector2.RIGHT,
		Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT,
		Vector2.DOWN + Vector2.LEFT, Vector2.DOWN, Vector2.DOWN + Vector2.RIGHT
	]
	for spot in hazard_spots:
		if spot in spots:
			spots.erase(spot)
	return spots.pick_random()


func get_free_nebula_spot() -> Vector2:
	var spots: Array = [
		Vector2.UP + Vector2.LEFT, Vector2.UP, Vector2.UP + Vector2.RIGHT,
		Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT,
		Vector2.DOWN + Vector2.LEFT, Vector2.DOWN, Vector2.DOWN + Vector2.RIGHT
	]
	for spot in hazard_nebula_spots:
		if spot in spots:
			spots.erase(spot)
	return spots.pick_random()


func _on_rocket_hit(hit_rocket: rocket) -> void:
	var spot: Vector2 = Vector2.ZERO
	spot.x = floori((hit_rocket.position.x - 96) / 64) + 2
	spot.y = floori((hit_rocket.position.y - 96) / 64) + 2
	hit(spot, hit_rocket.damage, game_manager.damage_types.PHYSICAL)


func _on_star_flare_hit(damage: int) -> void:
	direct_hit(damage, game_manager.damage_types.HEAT)


func _on_map_location_changed(new_location: map_node) -> void:
	current_location = new_location
	start()
	new_location_set_up.emit()


func _on_hazard_timer_1_timeout() -> void:
	propagate_hazard(0)


func _on_hazard_timer_2_timeout() -> void:
	propagate_hazard(1)


func _on_coin_timer_timeout() -> void:
	create_coin(5.0)
