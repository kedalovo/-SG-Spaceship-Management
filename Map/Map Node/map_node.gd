extends Node2D


class_name map_node


signal mouse_entered(node: map_node)
signal mouse_exited(node: map_node)
signal button_pressed(node: map_node)


@onready var icon: Sprite2D = $Icon
@onready var debug_label: Label = $"Debug Label"
@onready var animator: AnimationPlayer = $Icon/Animator

@onready var hover_audio: AudioStreamPlayer = $"Hover Audio"
@onready var press_audio: AudioStreamPlayer = $"Press Audio"

var true_texture: Texture2D = preload("res://Map/Map Node/Icons/Wormhole.png")

var wormhole: map_node

var connected_to_nodes: Array[map_node] = []

var hazards: Array[game_manager.hazard_types] = []
var hazards_intensity: Array[int] = []
var hazards_types: Array[Array] = []

var map_index: Vector2i = Vector2i(-1, -1)

var reason: int = 0
var difficulty: int = 0

var disabled: bool = false
var is_continuation: bool = false
var is_secret: bool = true
var is_available: bool = false
var has_destination: bool = false
var has_wormhole: bool = false
var is_wormhole: bool = false


func add_connections(new_connections: Array) -> void:
	if is_continuation:
		for i in new_connections:
			if !i.disabled and i not in connected_to_nodes:
				connected_to_nodes.append(i)
				i.is_continuation = true


func toggle_availability(new_state: bool) -> void:
	is_available = new_state
	if has_wormhole:
		wormhole.is_available = new_state


func setup_wormhole() -> void:
	wormhole.reparent(get_parent())
	wormhole.position = position + Vector2(randf_range(-32.0, 32.0), randf_range(-32.0, -64.0))
	wormhole.is_secret = false
	wormhole.modulate = Color("5d1212")
	wormhole.spin()


func toggle_highlight(on: bool) -> void:
	match on:
		true:
			animator.play(&"highlight")
		false:
			animator.play(&"RESET")


func spin() -> void:
	animator.play(&"spin")


func check_destinations() -> void:
	if has_destination:
		var not_connected: bool = true
		for i in connected_to_nodes:
			if !i.disabled:
				not_connected = false
		has_destination = not_connected


func set_debug(text: String) -> void:
	debug_label.text = text


func update_icon() -> void:
	if !is_secret:
		icon.texture = true_texture


func set_default_texture(new_texture: Texture2D) -> void:
	icon.texture = new_texture


func set_texture(new_texture: Texture2D) -> void:
	true_texture = new_texture


func set_difficulty(new_difficulty: int) -> void:
	if difficulty == 0 and new_difficulty > difficulty:
		difficulty = new_difficulty
		match new_difficulty:
			1:
				icon.modulate = Color("00cb00")
			2:
				icon.modulate = Color("cbc800")
			3:
				icon.modulate = Color("cb0000")
		if difficulty == 2:
			for i in hazards.size():
				var haz = hazards[i]
				var haz_int = clampi(hazards_intensity[i], 1, 5)
				match haz:
					game_manager.hazard_types.ASTEROID_FIELD:
						if randi() % (6 - haz_int) == 0:
							hazards_types.append([[game_manager.damage_types.HEAT, game_manager.damage_types.ELECTRICITY].pick_random()])
						else:
							hazards_types.append([])
					game_manager.hazard_types.NEBULA:
						if randi() % (6 - haz_int) == 0:
							hazards_types.append([game_manager.damage_types.HEAT])
						else:
							hazards_types.append([])
					_:
						hazards_types.append([])
		elif difficulty == 3:
			for i in hazards.size():
				var haz = hazards[i]
				var haz_int = hazards_intensity[i]
				match haz:
					game_manager.hazard_types.ASTEROID_FIELD:
						if randi() % (6 - haz_int) == 0:
							hazards_types.append([[game_manager.damage_types.HEAT, game_manager.damage_types.ELECTRICITY].pick_random()])
						else:
							hazards_types.append([game_manager.damage_types.HEAT, game_manager.damage_types.ELECTRICITY])
					game_manager.hazard_types.NEBULA:
						hazards_types.append([game_manager.damage_types.HEAT])
					_:
						hazards_types.append([])


func _on_mouse_grab_mouse_entered() -> void:
	mouse_entered.emit(self)
	hover_audio.play()


func _on_mouse_grab_mouse_exited() -> void:
	mouse_exited.emit(self)


func _on_button_pressed() -> void:
	press_audio.play()
	if is_available:
		print("Pressed on location")
		button_pressed.emit(self)
	else:
		print("Pressed on unavailable location")
