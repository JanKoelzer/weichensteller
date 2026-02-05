class_name ExhaustParticles
extends AbstractExhaustParticles


@warning_ignore("shadowed_variable_base_class")
func set_up(train_rotation: float, wind_speed: float, wind_angle: float, color: GradientTexture1D) -> void:
	super.set_up(train_rotation, wind_speed, wind_angle, color)
	position.y = randf_range(-6, 6)
	
	# add some variante for each instance
	process_material.color = Color(process_material.color, randf_range(0.8, 1.0))\
			.darkened(randf_range(0.0, 0.2))
	lifetime *= randf_range(0.7, 0.3)
	@warning_ignore("narrowing_conversion")
	amount *= randf_range(0.8, 1.2)
	explosiveness *= randf_range(0, 2.0)
