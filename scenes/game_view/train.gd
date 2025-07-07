class_name Train
extends Node2D

signal moved(t: Train)

enum TrainColor {
		RED = 0,
		ORANGE = 1,
		YELLOW = 2,
		GREEN = 3,
		BLUE = 4,
		PURPLE = 5,
}

var tile_size := 64

var speed: float

var directions: Array[int] = [-1, 0, 1]
var directionIndex := 1
var direction: int:
	get:
		return directions[directionIndex]
	set(v):
		var index := directions.find(v)
		directionIndex = index if index != -1 else 0


var color: TrainColor


func init(new_tile_size: int,
		new_color: TrainColor,
		new_position: Vector2i,
		new_speed: float,
		wind_speed: float,
		wind_direction: Vector2) -> void:
	position = new_position
	color = new_color
	speed = new_speed
	
	self.tile_size = new_tile_size
	
	var u := color
	var v := randi_range(3, 6)
	
	if v == 3:
		set_up_sparks()
	else:
		remove_child($SparkParticles)
		
	if v == 4 or v == 5:
		set_up_exhaust(
				Vector2i(-24, 2) if v == 5 else Vector2i(-25, -10),
				wind_speed,	wind_direction)
	else:
		remove_child($ExhaustParticles)
		
	if v == 6:
		set_up_smoke(wind_speed, wind_direction)
	else:
		remove_child($SteamParticles)
		
	$Sprite.region_rect = Rect2(tile_size*u, tile_size*v, tile_size, tile_size)


func set_up_sparks() -> void:
	$SparkParticles/Timer.wait_time = randf_range(2, 5)


func set_up_exhaust(exhaust_position: Vector2i, wind_speed: float, wind_direction: Vector2) -> void:
	$ExhaustParticles.position = exhaust_position
	$ExhaustParticles.initial_velocity_min = wind_speed
	$ExhaustParticles.initial_velocity_max = wind_speed
	$ExhaustParticles.direction = wind_direction
	$ExhaustParticles.lifetime = randf_range(0.2, 0.4)
	$ExhaustParticles.amount = randi_range(40, 60)
	$ExhaustParticles.color = \
			Color($ExhaustParticles.color, randf_range(0.8, 1.0))\
			.darkened(randf_range(0.0, 0.2))


func set_up_smoke(wind_speed: float, wind_direction: Vector2) -> void:
	$SteamParticles.initial_velocity_min = wind_speed
	$SteamParticles.initial_velocity_max = wind_speed
	$SteamParticles.direction = wind_direction
	$SteamParticles.color = \
			Color($SteamParticles.color, randf_range(0.4, 0.6))\
			.darkened(randf_range(0.0, 0.3))
	$SteamParticles.lifetime = randf_range(2.8, 3.8)
	$SteamParticles.amount = randi_range(400, 550)
	$SteamParticles.explosiveness = randf_range(0.0, 0.2)


func move() -> void:
	var tween := create_tween()
	
	var duration: float = (1.0 + (sqrt(2)-1)*abs(direction)) / speed
	var delta := Vector2(tile_size * 1.0, tile_size * direction)
	
	# move forward	
	tween.tween_property(self, "position", position + delta, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func() -> void: moved.emit(self))
	# rotation
	create_tween().tween_property(
			self,
			"rotation_degrees",
			45*direction,
			0.2/speed
		).set_trans(Tween.TRANS_LINEAR)
	var steam_particles := get_node_or_null("SteamParticles") as CPUParticles2D
	if steam_particles != null:
		create_tween().tween_property(
				steam_particles,
				"direction",
				steam_particles.direction.rotated(-45*direction),
				0.2/speed
			).set_trans(Tween.TRANS_LINEAR)

func fade_in() -> void:
	$FadePlayer.play("fade_in")


func fade_out(was_success: bool) -> void:
	speed = 0.0
	if not was_success:
		var shader := preload("res://shader/grayscale.gdshader")
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		shader_material.set_shader_parameter("engine_time_sec", Time.get_ticks_msec() / 1000.0)
		shader_material.set_shader_parameter("duration", 0.5)
		$Sprite.material = shader_material
	$FadePlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		queue_free()


func _on_spark_timer_timeout() -> void:
	$SparkParticles.position.y = randi_range(-10, 10)
	$SparkParticles.emitting = true
	$SparkParticles/Timer.start(randf_range(3, 8))
