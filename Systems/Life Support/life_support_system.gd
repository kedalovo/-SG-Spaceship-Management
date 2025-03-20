extends system


signal algae_ran_out
signal algae_added


const LIFE_SUPPORT_UPGRADE = preload("res://Systems/Life Support/Assets/Life Support upgrade.png")
const ALGAE_SCENE = preload("res://Systems/Life Support/Algae/algae.tscn")

@onready var algae_container: Node2D = $"Algae Container"
@onready var cooker_area: Area2D = $"Cooker Area"
@onready var damage_timer: Timer = $DamageTimer
@onready var camera: Camera2D = $Camera2D
@onready var empty_timer: Timer = $"Empty Timer"

var algae_in_cooker: Array[Algae] = []

var constant_damage: float = 0.5

var is_empty: bool


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


func start() -> void:
	$CookTimer.start()


func upgrade(to_tier: int) -> void:
	if current_tier == 0 and to_tier == 1:
		super.upgrade(to_tier)
		$Sprite.texture = LIFE_SUPPORT_UPGRADE
		for child in $Collisions.get_children():
			child.disabled = true
		for child in $"Collisions Upgraded".get_children():
			child.disabled = false
		for child in $Boundary.get_children():
			child.disabled = true
		for child in $"Boundary Upgraded".get_children():
			child.disabled = false
		cooker_area.monitoring = false
		$"Upgraded Cooker Area".monitoring = true
		$"Dispose Area".monitoring = false
		$"Upgraded Dispose Area".monitoring = true
	elif current_tier == 1 and to_tier == 2:
		$"Algae Sorter".gravity_space_override = Area2D.SpaceOverride.SPACE_OVERRIDE_COMBINE


func _damage(strength: int, type: game_manager.damage_types):
	if type == game_manager.damage_types.HEAT:
		print("Life support system: damaged")
		is_damaged = true
		constant_damage = 0.5 + strength
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
	if body is Algae and body.is_cooked:
		algae_in_cooker.erase(body)
		body.queue_free()


func _on_cook_timer_timeout() -> void:
	if !algae_in_cooker.is_empty():
		if is_empty:
			is_empty = false
			empty_timer.stop()
			algae_added.emit()
		algae_in_cooker[randi()%algae_in_cooker.size()].cook(constant_damage)
	else:
		if is_empty:
			pass
		else:
			is_empty = true
			empty_timer.start()


func _on_damage_timer_timeout() -> void:
	constant_damage = 0.5
	fix()


func _on_empty_timer_timeout() -> void:
	is_damaged = true
	algae_ran_out.emit()
