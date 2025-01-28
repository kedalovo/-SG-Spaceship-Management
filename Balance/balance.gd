extends Node2D


@onready var board: Sprite2D = $Board
@onready var animator: AnimationPlayer = $Animator


var value: int:
	get:
		return value
	set(v):
		value = clampi(v, 0, 10)
		print("Balance is: ", value)
		set_balance(v)


func set_balance(new_balance: int) -> void:
	for coin_idx in board.get_children().size():
		if coin_idx < new_balance:
			board.get_child(coin_idx).show()
		else:
			board.get_child(coin_idx).hide()


func _on_store_balance_flash() -> void:
	animator.play(&"flash")
