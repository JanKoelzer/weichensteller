extends Node

var sprite: Sprite2D = null
var target_position: Vector2 = Vector2.ZERO
var sprite_position: Vector2 = Vector2.ZERO
var speed: Vector2 = Vector2(10.0, 4.0)
var movement_enabled := true


var animiation_player: AnimationPlayer

# Gets called ONCE, when the program is started
func _ready() -> void:
	animiation_player = AnimationPlayer.new()

	# Want to react to scene changes in order
	# to set background.position to where it
	# has been last.
	get_tree().scene_changed.connect(scene_changed)
	
	# Start the movement (before _process kicks in)
	scene_changed()
	

# Gets called everytime the scene changes
func scene_changed() -> void:
	sprite = get_tree().current_scene.find_child("BackgroundSprite")
	if sprite == null:
		movement_enabled = false
	else:
		sprite.position = sprite_position


func _process(delta: float) -> void:
	if not movement_enabled:
		return
		
	for i in range(2): # for both directions x and y:
		# if we are close to the target position...
		if abs(sprite.position[i] - target_position[i]) < abs(speed[i]):
			# ..change direction
			speed[i] *= -1
			target_position[i] = - (sprite.get_rect().size[i] - get_viewport().get_visible_rect().size[i]) - target_position[i]
				
	# move and save position for use in next scene
	sprite_position += speed * delta
	sprite.position = sprite_position

	
