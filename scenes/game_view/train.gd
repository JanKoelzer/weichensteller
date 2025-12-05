class_name Train
extends Node2D

signal moved(t: Train)
signal rotation_started(direction: float, duration: float)

enum TrainColor {
		RED = 0,
		ORANGE = 1,
		YELLOW = 2,
		GREEN = 3,
		BLUE = 4,
		PURPLE = 5,
}

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

func init(new_tile_size: int,
		new_color: TrainColor,
		new_position: Vector2i,
		new_speed: float,
		wind_speed: float,
		wind_angle: float) -> void:
	position = new_position
	color = new_color
	speed = new_speed
	
	self.tile_size = new_tile_size
	
	# u and v are the trains coordinates in the tileset
	var u := color
	var v := randi_range(3, 6) #randomly select one type of train
	$Sprite.region_rect = Rect2(tile_size*u, tile_size*v, tile_size, tile_size)
	
	# electric engine?
	if v == 3:
		spark_particles.set_up()
	else:
		remove_child(spark_particles)
		
	# diesel engine?
	if v == 4 or v == 5:
		exhaust_particles.set_up(wind_speed, wind_angle)
	else:
		remove_child(exhaust_particles)
	
	# steam engine?
	if v == 6:
		steam_particles.set_up(wind_speed, wind_angle)
	else:
		remove_child(steam_particles)


func move() -> void:
	var tween := create_tween()
	
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
	rotation_started.emit(direction, anim_duration) 

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


@warning_ignore("shadowed_variable")
func _on_train_rotation_started(direction: float, duration: float) -> void:
	steam_particles.rotate_steam(direction, duration)
