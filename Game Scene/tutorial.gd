extends Node


signal request(req: String)


@onready var animator: AnimationPlayer = $Animator


const ANIM_LIST: Array[StringName] = [
	&"tutorial_1_introduction",
	&"tutorial_2_map",
	&"tutorial_3_timer",
	&"tutorial_4_controls",
	&"tutorial_5_coins",
	&"tutorial_6_shop",
	&"tutorial_7_systems",
	&"tutorial_7_1_life_support",
	&"tutorial_7_2_engines",
	&"tutorial_7_3_hull",
	&"tutorial_7_4_electrical",
	&"tutorial_7_5_external",
	&"tutorial_7_6_computer",
	&"tutorial_8_end",
]

var current_anim: StringName = &""


func start() -> void:
	animator.play(&"tutorial_1_introduction")


func proceed() -> void:
	animator.play(ANIM_LIST[ANIM_LIST.find(current_anim) + 1])


func _on_continue_button_pressed() -> void:
	match current_anim:
		&"tutorial_1_introduction":
			proceed()
			request.emit("map")
		&"tutorial_3_timer":
			proceed()
		&"tutorial_4_controls":
			proceed()
		&"tutorial_5_coins":
			animator.play(&"RESET")
			request.emit("coin")
		&"tutorial_6_shop":
			proceed()
		&"tutorial_7_systems":
			proceed()
			request.emit("systems")
		&"tutorial_8_end":
			get_tree().change_scene_to_file("res://Start Menu/start_menu.tscn")


func _on_animator_animation_started(anim_name: StringName) -> void:
	if anim_name != &"RESET":
		current_anim = anim_name
