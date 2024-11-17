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


enum TrainColor {RAINBOW = -1, RED = 0, ORANGE = 1, YELLOW = 2, GREEN = 3, BLUE = 4, PURPLE = 5}
var color: TrainColor: # this should be "read only after init"
	set = set_color


signal moved(t: Train)


func set_color(c: TrainColor) -> void:
	color = c
	if color == TrainColor.RAINBOW:
		$Sprite.region_rect= [Rect2(tile_size*5, 0, tile_size, tile_size),Rect2(tile_size*5, tile_size, tile_size, tile_size), Rect2(tile_size*4, tile_size, tile_size, tile_size)].pick_random()
		$RainbowPlayer.play("rainbow")
	else:
		$Sprite.region_rect= Rect2(tile_size*color, tile_size*randi_range(3,6), tile_size, tile_size)


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
	$FadePlayer.play("fade_in")


func fade_out(was_success: bool) -> void:
	speed = 0.0
	if not was_success:
		var shader: Resource = preload("res://grayscale.gdshader")
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = shader
		shader_material.set_shader_parameter("engine_time_sec", Time.get_ticks_msec() / 1000.0)
		shader_material.set_shader_parameter("duration", 1.0)
		$Sprite.material = shader_material
	$FadePlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		queue_free()
