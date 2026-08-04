extends Control

@export var animate_intro: bool = false

@onready var steam_particles: SteamParticles = $TitleTrain/Train/SteamParticles
@onready var intro_animation: AnimationPlayer = $TitleTrain/IntroAnimation

func _ready() -> void:
	steam_particles.create_random_texture()
	
	if animate_intro:
		intro_animation.play("intro")
	else:
		# Steam was visible at the wrong position, so
		# I added the next line to stall the output for a small time
		await get_tree().process_frame
		steam_particles.emitting = true
