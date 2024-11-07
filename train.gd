class_name Train
extends Node2D

static var train_scene: PackedScene = preload("res://train.tscn")

const tile_size: int = 64

var speed: float = 1.0 # default 

var directions: Array[int] = [-1, 0, 1]
var directionIndex: int = 1;
var direction: int:
	get:
		return directions[directionIndex]
	set(v):
		var index = directions.find(v)
		if index == -1:
			directionIndex = 0
		else:
			directionIndex = index
		

enum TrainColor {RED = 0, ORANGE = 1, YELLOW = 2, GREEN = 3, BLUE = 4, PURPLE = 5}
var color: TrainColor: # this should be "ready only after init"
	set = set_color


signal moved(t: Train)


func set_color(c: TrainColor) -> void:
	color = c
	$Sprite.region_rect= Rect2(tile_size*color, tile_size*randi_range(3,5), tile_size, tile_size)


static func new_train(num_stations: int, train_speed: float) -> Train:
	var scene = preload("res://train.tscn")
	
	var t: Train = scene.instantiate()
	t.color = TrainColor.values()[randi_range(0, num_stations-1)]
	
	t.speed = train_speed
	
	return t


func move() -> void:
	var tween: Tween = create_tween()
	
	var duration: float = (1.0 + (sqrt(2)-1)*abs(direction)) / speed
	var delta = Vector2(tile_size * 1.0, tile_size * direction)
	
	# move forward
	tween.tween_property(self, "position", position + delta, duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func(): moved.emit(self))
	# rotation
	create_tween().tween_property(self, "rotation_degrees", 45*direction, 0.2/speed).set_trans(Tween.TRANS_LINEAR)
	

func fade_in() -> void:
	$AnimationPlayer.play("fade_in")


func fade_out(was_success: bool) -> void:
	if not was_success:
		var shader: Resource = preload("res://grayscale.gdshader")
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = shader
		shader_material.set_shader_parameter("engine_time_sec", Time.get_ticks_msec() / 1000.0)
		shader_material.set_shader_parameter("duration", 0.2)
		$Sprite.material = shader_material
	$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		queue_free()
