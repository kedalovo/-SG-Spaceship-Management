extends system


const PATCH = preload("res://Systems/Hull/Patch/patch.tscn")
const HOLE = preload("res://Systems/Hull/Hole/hole.tscn")


@onready var holes: Node2D = $Holes
@onready var patches: Node2D = $Patches
@onready var camera: Camera2D = $Camera2D
@onready var balance_label: Label = $"Balance Label"
@onready var lose_timer: Timer = $"Lose Timer"


var patch_number: int:
	get:
		return patch_number
	set(v):
		patch_number = clampi(v, 0, max_patch_number)
		game_manager.patch_amount = patch_number
		print("[VALUE] Patch amount now ", game_manager.patch_amount)
		balance_label.text = str(patch_number)
var max_patch_number: int = 15


func _ready() -> void:
	super._ready()
	if !game_manager.is_loading_save:
		for i in 5:
			add_patch()


func open() -> void:
	for hole in holes.get_children():
		hole.position = game_manager.get_random_hole_position()
	super.open()


func close() -> void:
	for patch in patches.get_children():
		if patch.is_completed:
			patch.queue_free()
		else:
			patch.reset()
	super.close()


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	if _type == game_manager.damage_types.PHYSICAL:
		if _strength > 0:
			lose_timer.start()
		for i in _strength:
			if !is_damaged:
				is_damaged = true
			print("Hull system: damaged")
			add_random_hole()


func add_patch() -> void:
	patch_number += 1
	var new_patch := PATCH.instantiate()
	new_patch.patch_installed.connect(_on_patch_installed)
	new_patch.patch_completed.connect(_on_patch_completed)
	patches.add_child(new_patch)
	if current_tier > 0:
		new_patch.is_bigger = true
	if current_tier > 1:
		new_patch.is_halved = true
	new_patch.initial_pos = Vector2(-248, 160)
	new_patch.position = Vector2(-248, 160)


func add_hole(hole_position: Vector2) -> void:
	var new_hole := HOLE.instantiate()
	holes.add_child(new_hole)
	new_hole.position = hole_position


func add_random_hole() -> void:
	var pos: Vector2 = game_manager.get_random_hole_position()
	if holes.get_child_count() < 1:
		add_hole(pos)
	else:
		var condition: bool = true
		while condition:
			for i in holes.get_children():
				if pos.distance_to(i.position) > 150:
					print(pos.distance_to(i.position), " false")
					condition = false
				else:
					print(pos.distance_to(i.position), " true")
					condition = true
					pos = game_manager.get_random_hole_position()
					break
		add_hole(pos)


func get_holes_num() -> int:
	return holes.get_child_count()


func _on_patch_installed(patch: Patch, hole: Hole) -> void:
	patch.position = hole.position
	patch.set_marks()


func _on_patch_completed(_patch: Patch, hole: Hole) -> void:
	hole.queue_free()
	patch_number -= 1
	if holes.get_child_count() == 1:
		fix()
		lose_timer.stop()
	else:
		push_error(holes.get_child_count())


func _on_lose_timer_timeout() -> void:
	lose.emit()
