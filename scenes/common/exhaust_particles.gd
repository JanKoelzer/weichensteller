class_name ExhaustParticles
extends AbstractExhaustParticles


@warning_ignore("shadowed_variable_base_class")
func set_up(train_rotation: float, wind_speed: float, wind_angle: float) -> void:
	super.set_up(train_rotation, wind_speed, wind_angle)
	position.y = randf_range(-6, 6)
	
	# Multiply each particle by this color.
	# To make different trains output different steam,
	# this is in script and not preset in the editor
	process_material.color = Color(process_material.color, randf_range(0.8, 1.0))\
			.darkened(randf_range(0.0, 0.2))
	
	lifetime = randf_range(0.2, 0.4)
	amount = randi_range(40, 60)
	explosiveness = randf_range(0, 0.2)
