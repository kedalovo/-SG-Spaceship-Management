extends Node2D


class_name system


signal finished_animation(is_open: bool)
signal fixed(fixed_system: system)


var animator: AnimationPlayer

var upgrade_tiers: int
var current_tier: int

var is_damaged: bool
var is_animation_backwards: bool


func _ready() -> void:
	animator = get_node("Animator")
	animator.animation_finished.connect(_on_animation_finished)


func upgrade(to_tier: int) -> void:
	to_tier = clampi(to_tier, current_tier, upgrade_tiers)


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	push_error("Damage not implemented")


func fix() -> void:
	if is_damaged:
		is_damaged = false
		fixed.emit(self)


func open() -> void:
	show()
	animator.play(&"open")


func close() -> void:
	is_animation_backwards = true
	animator.play_backwards(&"open")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"open" and !is_animation_backwards:
		finished_animation.emit(true)
	if anim_name == &"open" and is_animation_backwards:
		is_animation_backwards = false
		hide()
		finished_animation.emit(false)
