extends Node2D

@export var animate_intro: bool = false

func _ready() -> void:
	if animate_intro:
		$IntroAnimation.play("intro")
	else:
		$Train/SteamParticles.emitting = true
