extends CPUParticles2D

# Unlike SteamParticles, this exhausted is not rotate with (or against)
# the train, because it is hardly visible anyway.

func set_up(wind_speed: float, wind_direction: Vector2) -> void:
	initial_velocity_min = wind_speed
	initial_velocity_max = wind_speed
	direction = wind_direction
	lifetime = randf_range(0.2, 0.4)
	amount = randi_range(40, 60)
	color = Color(color, randf_range(0.8, 1.0))\
			.darkened(randf_range(0.0, 0.2))
