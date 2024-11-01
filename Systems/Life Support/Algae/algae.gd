extends RigidBody2D

class_name Algae


@onready var timer: Timer = $Timer
@onready var impulse_timer: Timer = $ImpulseTimer

var health: int = 100
var is_cooking: bool = false
var is_cooked: bool = false

var is_held: bool = false


func cook():
	is_cooking = true
	timer.start()
	impulse_timer.start(randf()*2 + 1)


func _physics_process(delta: float) -> void:
	if is_held:
		apply_central_force((get_global_mouse_position() - global_position) * 50)


func _on_timer_timeout() -> void:
	health -= 1
	modulate = Color.WHITE.darkened((100 - health) / 100.0)
	if health < 0:
		is_cooked = true
		is_cooking = false
		timer.stop()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_held = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_held = true


func _on_impulse_timer_timeout() -> void:
	if !is_held and (is_cooking or is_cooked):
		apply_central_impulse(Vector2(randi()%300-150, randi()%300-150))
