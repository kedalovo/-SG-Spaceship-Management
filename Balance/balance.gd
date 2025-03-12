extends Node2D


@onready var board: Sprite2D = $Board
@onready var animator: AnimationPlayer = $Animator
@onready var selector_1: Sprite2D = $"Selectors/Selector 1"
@onready var selector_2: Sprite2D = $"Selectors/Selector 2"


var value: int:
	get:
		return value
	set(v):
		value = clampi(v, 0, 10)
		set_balance(v)


func set_balance(new_balance: int) -> void:
	for coin_idx in board.get_children().size():
		if coin_idx < new_balance:
			board.get_child(coin_idx).show()
		else:
			board.get_child(coin_idx).hide()


func set_flash(amount: int) -> void:
	amount = clampi(amount, 0, 2)
	match amount:
		0:
			selector_1.hide()
			selector_2.hide()
		1:
			selector_1.show()
			selector_2.hide()
		2:
			selector_1.show()
			selector_2.show()


func _on_store_balance_flash() -> void:
	animator.play(&"flash")
