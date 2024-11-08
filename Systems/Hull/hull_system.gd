extends system


const PATCH = preload("res://Systems/Hull/Patch/patch.tscn")
const HOLE = preload("res://Systems/Hull/Hole/hole.tscn")


@onready var holes: Node2D = $Holes
@onready var patches: Node2D = $Patches


var patch_number: int = 5
var max_patch_number: int = 15

var counter_patch: int = 0
var counter_hole: int = 0


func add_patch() -> void:
	var new_patch := PATCH.instantiate()
	new_patch.patch_installed.connect(_on_patch_installed)
	new_patch.patch_completed.connect(_on_patch_completed)
	patches.add_child(new_patch)
	#new_patch.index = set_patch_counter()
	new_patch.initial_pos = Vector2(-264, 176)
	new_patch.position = Vector2(-264, 176)


func add_hole(hole_position: Vector2) -> void:
	var new_hole := HOLE.instantiate()
	holes.add_child(new_hole)
	#new_hole.index = set_hole_counter()
	new_hole.position = hole_position


func set_patch_counter() -> int:
	counter_patch += 1
	return counter_patch - 1


func set_hole_counter() -> int:
	counter_hole += 1
	return counter_hole - 1


func _on_patch_installed(patch: Patch, hole: Hole) -> void:
	patch.position = hole.position
	patch.set_marks()


func _on_patch_completed(patch: Patch, hole: Hole) -> void:
	pass
