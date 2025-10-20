extends CPUParticles2D

var wind_angle: float

@warning_ignore("shadowed_variable")
func set_up(wind_speed: float, wind_angle: float) -> void:
	initial_velocity_min = wind_speed
	initial_velocity_max = wind_speed
	self.wind_angle = wind_angle
	direction = Vector2.from_angle(wind_angle)
	color = Color(color, randf_range(0.4, 0.6))\
			.darkened(randf_range(0.0, 0.3))
	lifetime = randf_range(2.8, 3.8)
	amount = randi_range(400, 550)
	explosiveness = randf_range(0.0, 0.2)


func _on_train_rotation_started(target_direction: float, duration: float) -> void:
	create_tween().tween_property(
				self,
				":rotation",
				(wind_angle-TAU*target_direction/8.0),
				duration
			).set_trans(Tween.TRANS_LINEAR)
