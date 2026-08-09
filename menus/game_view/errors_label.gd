extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func update(error_count: int, limit_reached: bool = false) -> void:
	text = str(error_count)
	animation_player.play("changed")
	if limit_reached:
		animation_player.get_animation("changed").loop_mode = Animation.LoopMode.LOOP_LINEAR
	else:
		animation_player.get_animation("changed").loop_mode = Animation.LoopMode.LOOP_NONE

	
