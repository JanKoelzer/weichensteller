class_name SteamParticles
extends AbstractExhaustParticles

@warning_ignore("shadowed_variable_base_class")
func set_up(train_rotation: float, wind_speed: float, wind_angle: float, steam_color: GradientTexture1D) -> void:
	super.set_up(train_rotation, wind_speed, wind_angle, steam_color)

	process_material.color_initial_ramp  = steam_color	
	
	# add some variation for each instance
	process_material.color = Color(process_material.color, process_material.color.a * randf_range(0.9, 1.1))
	lifetime *= randf_range(0.8, 1.2)
	@warning_ignore("narrowing_conversion")
	amount *= randf_range(0.8, 1.2)
	explosiveness *= randf_range(0.0, 1.5)
