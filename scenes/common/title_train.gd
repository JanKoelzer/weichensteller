extends Node2D

@export var animate_intro: bool = false

func _ready() -> void:
	if animate_intro:
		$IntroAnimation.play("intro")
	else:
		# Steam was visible at the wrong position, so
		# I added the next line to stall the output for a small time
		await get_tree().process_frame
		$Train/SteamParticles.emitting = true
