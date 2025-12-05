class_name SteamParticles
extends GPUParticles2D

var wind_angle: float

@warning_ignore("shadowed_variable")
func set_up(wind_speed: float, wind_angle: float) -> void:
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
	m.color = Color(m.color, randf_range(0.2, 0.4))\
			.darkened(randf_range(0.0, 0.3))
			
	lifetime = randf_range(2.8, 3.8)
	amount = randi_range(400, 550)
	explosiveness = randf_range(0.0, 0.2)


func rotate_steam(target_direction: float, duration: float) -> void:
	create_tween().tween_property(
				self,
				":rotation",
				(wind_angle-TAU*target_direction/8.0),
				duration
			).set_trans(Tween.TRANS_LINEAR)
