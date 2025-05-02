extends RigidBody2D

class_name Algae


@onready var outline: Sprite2D = $Outline
@onready var sprite: Sprite2D = $Sprite
@onready var sound: AudioStreamPlayer2D = $Sound


var health: float = 100.0
var is_cooked: bool = false
var is_cooking: bool = false

var is_held: bool = false


func cook(damage: float) -> void:
	if !is_cooked:
		if !is_cooking:
			print("[ALGAE] Started cooking")
		is_cooking = true
		health -= damage * clampf(game_manager.wear_modifier / 2.0, 1.0, 5.0)
		if health <= 0:
			health = 0
			is_cooked = true
			is_cooking = false
			call_deferred("set_collision_layer_value", 16, true)
		sprite.modulate = Color.WHITE.darkened((100.0 - health) / 100.0)
		apply_central_impulse(Vector2(randi()%300-150, randi()%300-150))


func _physics_process(_delta: float) -> void:
	if is_held and !is_cooking:
		apply_central_force((get_global_mouse_position() - global_position) * 50)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_held:
		print("[ALGAE] Released")
		is_held = false
		outline.hide()
		sound.pitch_scale = 1.1
		sound.play()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !is_held:
		if !is_cooked:
			print("[ALGAE] Picked up")
		is_held = true
		sound.pitch_scale = 1.0
		sound.play()


func _on_mouse_entered() -> void:
	if !is_cooking:
		if !is_held:
			sound.pitch_scale = 0.9
			sound.play()
		outline.show()


func _on_mouse_exited() -> void:
	if !is_held:
		outline.hide()
