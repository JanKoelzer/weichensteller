extends CPUParticles2D

var wind_angle: float

func set_up(wind_speed: float, wind_direction: Vector2) -> void:
	initial_velocity_min = wind_speed
	initial_velocity_max = wind_speed
	wind_angle = wind_direction.angle()
	direction = wind_direction
	color = Color(color, randf_range(0.4, 0.6))\
			.darkened(randf_range(0.0, 0.3))
	lifetime = randf_range(2.8, 3.8)
	amount = randi_range(400, 550)
	explosiveness = randf_range(0.0, 0.2)


func _on_train_rotation_started(target_direction: float, duration: float) -> void:
	create_tween().tween_property(
				self,
				"direction",
				direction.rotated(wind_angle-TAU*target_direction/8.0),
				duration
			).set_trans(Tween.TRANS_LINEAR)
