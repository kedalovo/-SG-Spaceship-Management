extends Node2D


class_name rocket


signal finished(finished_rocked: rocket)


@onready var sprite: Sprite2D = $Sprite
@onready var animator: AnimationPlayer = $Sprite/Animator
@onready var progress: TextureProgressBar = $Progress
@onready var ballistic_lines: Sprite2D = $"Ballistic Lines"


var target: Node2D

var speed: float = 0.0

var damage: int = 0


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	global_position += (target.global_position - global_position).normalized() * speed * delta * 5 * exp(animator.current_animation_position)
	sprite.look_at(target.global_position)
	sprite.rotate(deg_to_rad(90.0))


func _process(_delta: float) -> void:
	progress.value = animator.current_animation_position / animator.current_animation_length * 100


func set_time(time: float) -> void:
	$Sprite/Animator.speed_scale = 1.0 / time


func set_start_time(time: float) -> void:
	$"Start Timer".wait_time = time


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"start":
		finished.emit(self)
		queue_free()


func _on_start_timer_timeout() -> void:
	$Sprite/Animator.play(&"start")
	set_physics_process(true)
	if game_manager.is_ballistic:
		set_process(true)
		progress.show()
		ballistic_lines.show()
	else:
		progress.hide()
		ballistic_lines.hide()
