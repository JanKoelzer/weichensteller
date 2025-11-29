class_name ExhaustParticles
extends GPUParticles2D

var wind_angle: float

# Unlike SteamParticles, this exhausted is not rotate with (or against)
# the train, because it is hardly visible anyway.

@warning_ignore("shadowed_variable")
func set_up(wind_speed: float, wind_angle: float) -> void:
	position.y = randf_range(-6, 6)
	
	var m: ParticleProcessMaterial = process_material
	m.initial_velocity_min = wind_speed
	m.initial_velocity_max = wind_speed
	
		# set the particle direction according to the wind
	self.wind_angle = wind_angle
	var dir := Vector2.from_angle(wind_angle)
	m.direction = Vector3(dir.x, dir.y, 0)
	
	# Multiply each particle by this color.
	# To make different trains output different steam,
	# this is in script and not preset in the editor
	m.color = Color(m.color, randf_range(0.8, 1.0))\
			.darkened(randf_range(0.0, 0.2))
	
	lifetime = randf_range(0.2, 0.4)
	amount = randi_range(40, 60)
	explosiveness = randf_range(0, 0.2)
