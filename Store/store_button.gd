extends TextureButton


class_name store_button


signal upgrade_bought(new_upgrade: game_manager.store_items, amount: int)
signal failed_buy_attempt
signal hover(btn: store_button)
signal hover_stop


@export var upgrade: game_manager.store_items
@export var is_bottom_button: bool = false
@export var time: float = 3.0
@export var price: int = 1
@export_multiline var custom_tooltip: String

@onready var sprite: Sprite2D = $Sprite
@onready var progress: TextureProgressBar = $Progress
@onready var timer: Timer = $Timer
@onready var animator: AnimationPlayer = $Sprite/Animator

var sprite_outline: Sprite2D


func _ready() -> void:
	if is_bottom_button:
		sprite_outline = $Sprite/Outline


func _process(_delta: float) -> void:
	if timer.is_stopped():
		progress.value = 0
	else:
		progress.value = 100 - roundf(timer.time_left / time * 100)
	#label.text = str(progress.value) + '\n' + str(time) + '\n' + str(timer.time_left)


func update_texture(new_texture: Texture2D) -> void:
	sprite.texture = new_texture


func _on_button_down() -> void:
	if game_manager.balance < price or upgrade == game_manager.store_items.OUT_OF_STOCK:
		animator.play(&"shake")
		if is_bottom_button:
			sprite_outline.hide()
		failed_buy_attempt.emit()
		return
	timer.start(time)


func _on_button_up() -> void:
	timer.stop()


func _on_mouse_entered() -> void:
	if is_bottom_button:
		sprite_outline.show()
	else:
		sprite.modulate = Color("2dff00")
	hover.emit(self)


func _on_mouse_exited() -> void:
	if !timer.is_stopped():
		timer.stop()
	if is_bottom_button:
		sprite_outline.hide()
	else:
		sprite.modulate = Color("378a0c")
	hover_stop.emit()


func _on_timer_timeout() -> void:
	upgrade_bought.emit(upgrade, price)
