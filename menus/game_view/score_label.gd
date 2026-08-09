extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation := animation_player.get_animation("changed")
@onready var animation_track := animation.find_track(".:theme_override_colors/font_color", Animation.TYPE_VALUE)

func update(score: String, color: Color) -> void:
	text = score
	animation.track_set_key_value(animation_track, 1, color)
	animation_player.play("changed")
