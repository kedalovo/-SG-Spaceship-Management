extends Node2D


func _on_area_body_entered(body: Node2D) -> void:
	print("Body entered!")


func _on_area_body_exited(body: Node2D) -> void:
	pass
