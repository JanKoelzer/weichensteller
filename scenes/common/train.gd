class_name Train
extends Node2D

signal moved(t: Train)


enum TrainType {
		ELECTRIC = 0,
		DIESEL1 = 1,
		DIESEL2 = 2,
		STEAM = 3
}


enum TrainColor {
		RED = 0,
		ORANGE = 1,
		YELLOW = 2,
		GREEN = 3,
		BLUE = 4,
		PURPLE = 5,
}

# A gradient corresponding to each TrainColor to color the steam/exhaust
const STEAM_COLOR_GRADIENTS: Array[GradientTexture1D] = [
			preload("uid://bfyp84mohhcv2"),
			preload("uid://lphrcohx2aty"),
			preload("uid://dtj5opb32tfm7"),
			preload("uid://dmcyuxdun2let"),
			preload("uid://d2wtwffpra4my"),
			preload("uid://bsxxfpxk5v1mu")]


@onready var steam_particles: SteamParticles = $SteamParticles
@onready var spark_particles: SparkParticles = $SparkParticles
@onready var exhaust_particles: ExhaustParticles = $ExhaustParticles


var tile_size := 120

@export var speed: float

var directions: Array[int] = [-1, 0, 1]
var directionIndex := 1
@export var direction: int:
	get:
		return directions[directionIndex]
	set(v):
		var index := directions.find(v)
		directionIndex = index if index != -1 else 0

var color: TrainColor
var wind_angle: float

func init(new_tile_size: int,
		new_color: TrainColor,
		new_type: TrainType,
		new_position: Vector2i,
		new_speed: float,
		wind_speed: float,
		new_wind_angle: float) -> void:
	position = new_position
	color = new_color
	speed = new_speed
	wind_angle = new_wind_angle
	
	self.tile_size = new_tile_size
	
	# u and v are the trains coordinates in the tileset
	var u := color
	
	var v := new_type + 3 # for "+3" see structure of tileset
	$Sprite.region_rect = Rect2(tile_size*u, tile_size*v, tile_size, tile_size)
	
	# electric engine?
	if new_type == TrainType.ELECTRIC:
		spark_particles.set_up()
	else:
		remove_child(spark_particles)
		
	# diesel engine?
	if new_type == TrainType.DIESEL1 or new_type == TrainType.DIESEL2:
		exhaust_particles.set_up(rotation, wind_speed, wind_angle, STEAM_COLOR_GRADIENTS[color])
	else:
		remove_child(exhaust_particles)
	
	# steam engine?
	if new_type == TrainType.STEAM:
		steam_particles.set_up(rotation, wind_speed, wind_angle, STEAM_COLOR_GRADIENTS[color])
	else:
		remove_child(steam_particles)


func move() -> void:
	var tween := create_tween()
	
	# duration to next tile differs for straight vs. diagonal
	var duration: float = (1.0 + (sqrt(2)-1)*abs(direction)) / speed
	var delta := Vector2(tile_size * 1.0, tile_size * direction)
	
	# move forward	
	tween.tween_property(self, ":position", position + delta, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func() -> void: moved.emit(self))
	
	# rotate train
	var anim_duration := 0.2/speed
	create_tween().tween_property(
			self,
			":rotation",
			TAU*direction/8.0,
			anim_duration
		).set_trans(Tween.TRANS_LINEAR)
	# emit signal, so SteamParticles can adapt
	if steam_particles:
		steam_particles.rotate_exhaust(direction, anim_duration)
	elif exhaust_particles:
		exhaust_particles.rotate_exhaust(direction, anim_duration)

func fade_in() -> void:
	$FadePlayer.play(&"fade_in")


func fade_out(was_success: bool) -> void:
	speed = 0.0
	if not was_success:
		var shader_material := preload("res://resources/shader/grayscale.tres")
		shader_material.set_shader_parameter(&"engine_time_sec", Time.get_ticks_msec() / 1000.0)
		$Sprite.material = shader_material
	$FadePlayer.play(&"fade_out")


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == &"fade_out":
		queue_free()
