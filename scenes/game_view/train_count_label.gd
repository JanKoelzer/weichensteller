extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func update(sum_trains_started: int) -> void:
	text = str(sum_trains_started)
	animation_player.play("changed")
