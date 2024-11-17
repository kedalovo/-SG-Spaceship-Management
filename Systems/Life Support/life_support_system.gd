extends system

const ALGAE_SCENE = preload("res://Systems/Life Support/Algae/algae.tscn")
@onready var algae_container: Node = $"Algae Container"
@onready var cooker_area: Area2D = $"Cooker Area"
@onready var damage_timer: Timer = $DamageTimer
@onready var camera: Camera2D = $Camera2D
@onready var animator: AnimationPlayer = $Animator

var algae_in_cooker: Array[Algae] = []

var constant_damage: int = 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		add_fuel()
	if event.is_action_pressed("test1"):
		var zoom := randf_range(0.5, 2.0)
		camera.zoom = Vector2(zoom, zoom)


func get_health() -> int:
	var total_hp: int = 0
	for body in cooker_area.get_overlapping_bodies():
		if body is Algae:
			total_hp += body.health
	return total_hp


func add_fuel() -> void:
	var new_algae = ALGAE_SCENE.instantiate()
	new_algae.position = Vector2(randi_range(-152, -72), -36)
	algae_container.add_child(new_algae)


func open() -> void:
	super.open()
	camera.enabled = true
	animator.play("open")


func _damage(strength: int, type: game_manager.damage_types):
	if type == game_manager.damage_types.HEAT:
		is_damaged = true
		constant_damage = 1 + strength
		damage_timer.start(10 + strength * 5)


func _on_cooker_area_body_entered(body: Node2D) -> void:
	if body is Algae:
		if !(body.is_cooking or body.is_cooked):
			algae_in_cooker.append(body)


func _on_cooker_area_body_exited(body: Node2D) -> void:
	if body is Algae:
		if body.is_cooking:
			body.is_cooking = false
			algae_in_cooker.erase(body)


func _on_dispose_area_body_entered(body: Node2D) -> void:
	if body is Algae:
		algae_in_cooker.erase(body)
		body.queue_free()


func _on_cook_timer_timeout() -> void:
	if !algae_in_cooker.is_empty():
		algae_in_cooker[randi()%algae_in_cooker.size()].cook(constant_damage)


func _on_damage_timer_timeout() -> void:
	constant_damage = 1
	is_damaged = false
