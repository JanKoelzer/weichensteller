class_name SteamParticles
extends AbstractExhaustParticles

@warning_ignore("shadowed_variable_base_class")
func set_up(train_rotation: float, wind_speed: float, wind_angle: float) -> void:
	super.set_up(train_rotation, wind_speed, wind_angle)
	
	# Multiply each particle by this color.
	# To make different trains output different steam,
	# this is in script and not preset in the editor
	process_material.color = Color(process_material.color, randf_range(0.2, 0.4))\
			.darkened(randf_range(0.0, 0.3))
			
	lifetime = randf_range(2.8, 3.8)
	amount = randi_range(400, 550)
	explosiveness = randf_range(0.0, 0.2)
