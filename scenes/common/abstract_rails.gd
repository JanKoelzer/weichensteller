@abstract class_name AbstractRails
extends TileMapLayer

var Train_scene: PackedScene = preload("res://scenes/game_view/train.tscn")

signal train_started(sum_trains_started: int)
signal scored()
signal errored()
signal end()

@onready var train_creation_timer: Timer = $TrainCreationTimer
@onready var trains: Node2D = $Trains
@onready var error_audio_stream_player: AudioStreamPlayer = $ErrorAudioStreamPlayer
@onready var score_audio_stream_player: AudioStreamPlayer = $ScoreAudioStreamPlayer
@onready var activate_switch_audio_stream_player: AudioStreamPlayer = $ActivateSwitchAudioStreamPlayer
@onready var deactivate_switch_audio_stream_player: AudioStreamPlayer = $DeactivateSwitchAudioStreamPlayer

var col_count: int
var row_count: int 
var game_settings: GameSettings
var colors: Dictionary[int, Train.TrainColor]

var generate_trains := true:
	get: return not train_creation_timer.is_stopped()
	set(v):
		if not v and not train_creation_timer.is_stopped(): 
			train_creation_timer.stop()
		elif v and train_creation_timer.is_stopped():
			train_creation_timer.stop()

var trains_on_track := 0:
	get: return trains_on_track
	set(v):
		trains_on_track = v
		if trains_on_track <= 0:
			end.emit()


var sum_trains_started := 0:
	get: return sum_trains_started
	set(v):
		sum_trains_started = v
		train_started.emit(v)

# wind changes for each game. it is forwarded to trains and their exhaust
var wind_angle: float
var wind_speed: float


# called by "the world"
func start() -> void:
	set_train_on_tracks()
	

func stop() -> void:
	generate_trains = false


func create_railways() -> void:
	var n := game_settings.selected_stations.size()
	# reset everything
	self.clear()
	for row in row_count:
		for col in range(col_count):
			if col < col_count - 1:
				# set straight line
				set_cell(Vector2i(col, row), 0, Vector2i(3, 0))
			else:
				# set station of matching color
				set_cell(Vector2i(col, row), 0, Vector2i(colors[row], 2))
	
	# set minimal switches
	var cols_for_up: Array
	var cols_for_down: Array
	var valid_setup := false
	while not valid_setup:
		cols_for_up = range(1, col_count - 1)
		cols_for_up.shuffle()
		cols_for_up = cols_for_up.slice(0, n)
		
		cols_for_down = range(1, col_count - 1)
		cols_for_down.shuffle()
		cols_for_down = cols_for_down.slice(0, n)
		
		cols_for_down.sort()
		cols_for_up.sort()
		
		# check, that switch would not replace each other
		valid_setup = true
		for i: int in range(1, n):
			for j: int in range(n-1):
				if cols_for_down[i] == cols_for_up[-j-1]\
				and i == j+1:
					valid_setup = false

	for row: int in range(n - 1):
		set_switch(cols_for_down[row], row, 1)
		set_switch(cols_for_up[-row-1], row+1, -1)

	# set extra switches
	var num_extra_switches := game_settings.num_extra_switches
	while num_extra_switches > 0:
		var pos := Vector2i(randi_range(1, col_count - 2), randi_range(0, n-1))
		if get_cell_tile_data(pos) != null\
		and not get_cell_tile_data(pos).get_custom_data("is_switch"):
			set_switch(pos.x, pos.y)
			num_extra_switches -= 1


func set_switch(x: int, y: int, direction: int = 0) -> void:
	# if unset, set direction
	if direction == 0:
		direction = randi_range(0, 1) * 2 - 1

	# check, if switch would lead outside the map:
	if y + direction < 0 or y + direction >= game_settings.selected_stations.size():
		# if so, invert direction
		direction = -direction
		
	var atlas_coord_x := randi_range(0, 1)
	var alternative := 0 if direction == 1 else 1
	set_cell(Vector2i(x, y), 0, Vector2i(atlas_coord_x, 0), alternative)


func pause_trains() -> void:
	trains.process_mode = Node.PROCESS_MODE_DISABLED
	train_creation_timer.paused = true
	

func resume_trains() -> void:
	trains.process_mode = Node.PROCESS_MODE_INHERIT
	train_creation_timer.paused = false


func get_cell_at(local: Vector2) -> Vector2i:
	return local_to_map(local)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			switch(get_cell_at(get_local_mouse_position()))


# active or deavtive a switch
func switch(cell: Vector2i) -> void:
	var data := get_cell_tile_data(cell)
	
	if data == null:
		# no cell selected
		return
	
	# only handle clicks on switches
	if(data.get_custom_data("is_switch")):
		var cell_atlas_coords := get_cell_atlas_coords(cell)
		var cell_alternative := get_cell_alternative_tile(cell)
		var new_atlas_coords: Vector2i
		var audioPlayer: AudioStreamPlayer
		if data.get_custom_data("is_active"):
			new_atlas_coords = cell_atlas_coords - Vector2i(1, 0)
			audioPlayer = deactivate_switch_audio_stream_player
		else:
			new_atlas_coords = cell_atlas_coords + Vector2i(1, 0)
			audioPlayer = activate_switch_audio_stream_player

		audioPlayer.play()
		set_cell(cell, 0, new_atlas_coords, cell_alternative)
	

func _on_train_moved(train: Train) -> void:
	var cell := get_cell_at(train.position)
	var data := get_cell_tile_data(cell)
	
	if data == null:
		train.queue_free()
		return
	
	if data.get_custom_data("is_active"):
		train.direction = data.get_custom_data("switch_direction")
	else:
		train.direction = 0
		
	if data.get_custom_data("is_end"):
		if data.get_custom_data("train_color") == train.color:
			score_audio_stream_player.play()
			train.fade_out(true)
			scored.emit()
		else:
			error_audio_stream_player.play()
			train.fade_out(false)
			errored.emit()
		trains_on_track -= 1	
		
	train.move()

@abstract func set_train_on_tracks() -> Train

func _set_train_on_tracks(type: Train.TrainType, color: Train.TrainColor, track: int, speed: float) -> Train:
	var t := Train_scene.instantiate() as Train
	trains.add_child(t)
	trains.move_child(t, 0)
	var new_position := Vector2(0, tile_set.tile_size.y * track  + tile_set.tile_size.y / 2.0)
	t.init(tile_set.tile_size.x, color, type, new_position, speed, wind_speed, wind_angle )
	t.moved.connect(_on_train_moved)
	t.move()
	trains_on_track += 1
	sum_trains_started += 1
	return t
