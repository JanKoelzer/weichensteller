extends CPUParticles2D

@onready var timer: Timer = $Timer

func set_up() -> void:
	# let sparks appear after some random time
	# (position and time is later changed via _on_timer_timeout)
	timer.wait_time = randf_range(2, 5)

func _on_timer_timeout() -> void:
	position.y = randi_range(-18, 18)
	emitting = true
	timer.start(randf_range(2, 5))
