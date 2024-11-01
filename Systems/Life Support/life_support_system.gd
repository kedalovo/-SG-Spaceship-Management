extends system

const ALGAE_SCENE = preload("res://Systems/Life Support/Algae/algae.tscn")


func add_fuel():
	pass


func _on_cooker_area_body_entered(body: Node2D) -> void:
	if body is Algae:
		if !(body.is_cooking or body.is_cooked):
			body.cook()


func _on_dispose_area_body_entered(body: Node2D) -> void:
	if body is Algae:
		if body.is_cooked:
			body.queue_free()
