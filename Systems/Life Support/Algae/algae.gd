extends RigidBody2D

class_name Algae


@onready var outline: Sprite2D = $Outline
@onready var sprite: Sprite2D = $Sprite


var health: float = 100.0
var is_cooked: bool = false
var is_cooking: bool = false

var is_held: bool = false


func cook(damage: float) -> void:
	is_cooking = true
	if !is_cooked:
		health -= damage * game_manager.wear_modifier
		if health <= 0:
			health = 0
			is_cooked = true
			is_cooking = false
			call_deferred("set_collision_layer_value", 16, true)
		sprite.modulate = Color.WHITE.darkened((100.0 - health) / 100.0)
		apply_central_impulse(Vector2(randi()%300-150, randi()%300-150))


func _physics_process(_delta: float) -> void:
	if is_held:
		apply_central_force((get_global_mouse_position() - global_position) * 50)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_held = false
		outline.hide()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_held = true


func _on_mouse_entered() -> void:
	outline.show()


func _on_mouse_exited() -> void:
	if !is_held:
		outline.hide()
