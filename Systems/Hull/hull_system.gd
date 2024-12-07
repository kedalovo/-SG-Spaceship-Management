extends system


const PATCH = preload("res://Systems/Hull/Patch/patch.tscn")
const HOLE = preload("res://Systems/Hull/Hole/hole.tscn")


@onready var holes: Node2D = $Holes
@onready var patches: Node2D = $Patches
@onready var camera: Camera2D = $Camera2D


var patch_number: int = 5
var max_patch_number: int = 15


func _ready() -> void:
	super._ready()
	for i in patch_number:
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
		for i in _strength:
			print("Hull system: damaged")
			add_hole(game_manager.get_random_hole_position())


func add_patch() -> void:
	var new_patch := PATCH.instantiate()
	new_patch.patch_installed.connect(_on_patch_installed)
	new_patch.patch_completed.connect(_on_patch_completed)
	patches.add_child(new_patch)
	if current_tier > 0:
		new_patch.is_bigger = true
	if current_tier > 1:
		new_patch.is_halved = true
	new_patch.initial_pos = Vector2(-264, 176)
	new_patch.position = Vector2(-264, 176)


func add_hole(hole_position: Vector2) -> void:
	var new_hole := HOLE.instantiate()
	holes.add_child(new_hole)
	new_hole.position = hole_position


func _on_patch_installed(patch: Patch, hole: Hole) -> void:
	patch.position = hole.position
	patch.set_marks()


func _on_patch_completed(_patch: Patch, hole: Hole) -> void:
	hole.queue_free()
	if holes.get_child_count() == 1:
		fix()
