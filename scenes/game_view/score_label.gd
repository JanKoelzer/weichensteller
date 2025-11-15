extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func update(score: String) -> void:
	text = score
	animation_player.play("changed")
