extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func update(score: float) -> void:
	text = str(roundi(score))
	animation_player.play("changed")
