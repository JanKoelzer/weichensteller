class_name SteamParticles
extends AbstractExhaustParticles

@warning_ignore("shadowed_variable_base_class")
func set_up(speed: float, train_rotation: float, wind_speed: float, wind_angle: float, steam_color: GradientTexture1D) -> void:
	# Base class handles wind
	super.set_up(speed, train_rotation, wind_speed, wind_angle, steam_color)
	
	# set steam color for this train
	process_material.color_initial_ramp = steam_color
	
	# add some variation for each instance
	create_random_texture()
	process_material.color = Color(process_material.color, process_material.color.a * randf_range(0.9, 1.1))
	lifetime *= randf_range(0.8, 1.2)
	@warning_ignore("narrowing_conversion")
	amount *= randf_range(0.8, 1.2) * speed
	explosiveness *= randf_range(0.0, 1.5)
	
	
func create_random_texture() -> void:
	# Use some noise to create unique textures for each train
	var noise: FastNoiseLite = preload("res://resources/textures/steam_noise.tres")
	noise.seed = randi()
	
	# Use a mask to clip the noise to a round shape
	var mask := preload("res://resources/textures/steam_particle_mask.tres").get_image()

	# Create the image
	var img: Image = Image.create_empty(mask.get_width(), mask.get_height(), false, Image.Format.FORMAT_RGBA8)
	for x in img.get_width():
		for y in img.get_height():
			var color := Color(1, 1, 1,\
					mask.get_pixel(x, y).a\
					* (noise.get_noise_2d(x/2.0, y/2.0)+1) /2
				)

			img.set_pixel(x, y, color)
			
	texture = ImageTexture.create_from_image(img)
