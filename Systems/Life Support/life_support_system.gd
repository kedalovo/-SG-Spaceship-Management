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
var live_algae_in_cooker: Array[Algae] = []

var constant_damage: float = 0.5

var is_empty: bool


func _ready() -> void:
	super._ready()
	for i in 10:
		add_fuel()


func get_health() -> int:
	var total_hp: int = 0
	for body in cooker_area.get_overlapping_bodies():
		if body is Algae:
			total_hp += body.health
	return total_hp


func add_fuel() -> void:
	var new_algae = ALGAE_SCENE.instantiate()
	new_algae.position = Vector2(randi_range(-152, -88), randi_range(-36, 0))
	algae_container.add_child(new_algae)
	game_manager.algae_amount += 1


func start() -> void:
	$CookTimer.start()


func stop() -> void:
	$CookTimer.stop()
	empty_timer.stop()


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
			live_algae_in_cooker.append(body)


func _on_cooker_area_body_exited(body: Node2D) -> void:
	if body is Algae:
		if body.is_cooking:
			body.is_cooking = false
			algae_in_cooker.erase(body)
			live_algae_in_cooker.erase(body)


func _on_dispose_area_body_entered(body: Node2D) -> void:
	if body is Algae and body.is_cooked:
		algae_in_cooker.erase(body)
		body.queue_free()


func _on_cook_timer_timeout() -> void:
	if !live_algae_in_cooker.is_empty():
		if is_empty:
			is_empty = false
			print("Cooker filled, stopped timer")
			empty_timer.stop()
			algae_added.emit()
		var picked: int = randi()%live_algae_in_cooker.size()
		live_algae_in_cooker[picked].cook(constant_damage)
		if live_algae_in_cooker[picked].is_cooked:
			live_algae_in_cooker.remove_at(picked)
	else:
		is_empty = true
		if empty_timer.is_stopped():
			print("Cooker is empty, starting timer...")
			empty_timer.start()


func _on_damage_timer_timeout() -> void:
	constant_damage = 0.5
	fix()


func _on_empty_timer_timeout() -> void:
	if live_algae_in_cooker.is_empty():
		print("Cooker is empty for a while!!!")
		is_damaged = true
		algae_ran_out.emit()
