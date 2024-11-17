extends TileMapLayer

var train_scene: PackedScene = preload("res://train.tscn")

signal train_started(sum_trains_started: int)
signal scored()
signal errored()
signal end()

const COL_COUNT = 16

var generate_trains: bool = true:
	get: return not $TrainCreationTimer.is_stopped()
	set(v):
		if not v and not $TrainCreationTimer.is_stopped(): 
			$TrainCreationTimer.stop()
		elif v and $TrainCreationTimer.is_stopped():
			$TrainCreationTimer.stop()
			
var trains_on_track: int = 0:
	get: return trains_on_track
	set(v):
		trains_on_track = v
		if trains_on_track <= 0:
			end.emit()


var sum_trains_started: int = 0:
	get: return sum_trains_started
	set(v):
		sum_trains_started = v
		train_started.emit(v)


func _ready() -> void:
	create_railways()


func start() -> void:
	set_train_on_tracks()


func create_railways() -> void:
	var n: int = GameSettings.num_stations
	# reset everything
	self.clear()
	for row in range(GameSettings.num_stations):
		for col in range(COL_COUNT):
			set_cell(Vector2i(col, row), 0, Vector2i(4, 0))
			if col == COL_COUNT - 1:
				set_cell(Vector2i(col, row), 0, Vector2i(row, 2))
	
	# set minimal switches
	var cols: Array = range(1, COL_COUNT - 1)
	cols.shuffle() 
	var cols_for_up: Array = cols.slice(0, n)
	var cols_for_down: Array = cols.slice(n, 2*n)

	cols_for_down.sort()
	cols_for_up.sort()
	cols_for_up.reverse()
	for row in range(n - 1):
		set_switch(cols_for_down[row], row, 1)
		set_switch(cols_for_up[row], row+1, -1)# n - 1 - row, -1)

	# set extra switches
	var num_extra_switches: int = GameSettings.num_extra_switches
	while num_extra_switches > 0:
		var pos: Vector2i = Vector2i(randi_range(1, COL_COUNT - 2), randi_range(0, n - 1))		
		if get_cell_tile_data(pos) != null and not get_cell_tile_data(pos).get_custom_data("is_switch"):
			set_switch(pos.x, pos.y)
			num_extra_switches -= 1


func set_switch(x: int, y: int, direction: int = 0) -> void:
	# if unset, set direction
	if direction == 0:
		direction = randi_range(0, 1) * 2 - 1

	# use direction only, if possible
	if y + direction < 0 or y + direction >= GameSettings.num_stations:
				direction = -direction
	var atlas_coord_x: int = randi_range(0, 1) if direction == 1 else randi_range(2, 3)
	set_cell(Vector2i(x, y), 0, Vector2i(atlas_coord_x, 0))


func pause_trains() -> void:
	$Trains.process_mode = Node.PROCESS_MODE_DISABLED
	$TrainCreationTimer.paused = true
	

func resume_trains() -> void:
	$Trains.process_mode = Node.PROCESS_MODE_INHERIT
	$TrainCreationTimer.paused = false


func get_cell_at(local: Vector2) -> Vector2i:
	return local_to_map(local)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			switch(get_cell_at(get_local_mouse_position()))


# active or deavtive a switch
func switch(cell: Vector2i) -> void:
	var data: TileData = get_cell_tile_data(cell)
	var new_atlas_coords: Vector2i
	var audioPlayer: AudioStreamPlayer
	
	if data == null:
		# no cell selected
		return
	
	
	if(data.get_custom_data("is_switch")):
		assert(data.get_custom_data("switch_direction") != 0)
		if data.get_custom_data("switch_direction") == -1:
			if data.get_custom_data("is_active"):
				new_atlas_coords = Vector2i(2,0)
				audioPlayer = $DeactivateSwitchAudioStreamPlayer		
			else:
				new_atlas_coords = Vector2i(3,0)
				audioPlayer = $ActivateSwitchAudioStreamPlayer
		elif data.get_custom_data("switch_direction") == 1:
			if data.get_custom_data("is_active"):
				new_atlas_coords = Vector2i(0,0)
				audioPlayer = $DeactivateSwitchAudioStreamPlayer
			else:
				new_atlas_coords = Vector2i(1,0)
				audioPlayer = $ActivateSwitchAudioStreamPlayer
				
		audioPlayer.play()
		set_cell(cell, 0, new_atlas_coords)
	

func _on_train_moved(train: Train) -> void:
	var cell: Vector2i = get_cell_at(to_local(train.position))
	var data: TileData = get_cell_tile_data(cell)
	
	if data == null:
		train.queue_free()
		return
	
	if data.get_custom_data("is_switch") and data.get_custom_data("is_active"):
		train.direction = data.get_custom_data("switch_direction")
	else:
		train.direction = 0
		
	if data.get_custom_data("is_end"):
		if data.get_custom_data("train_color") == train.color or train.color == Train.TrainColor.RAINBOW:
			$ScoreAudioStreamPlayer.play()
			train.fade_out(true)
			scored.emit()
		else:
			$ErrorAudioStreamPlayer.play()
			train.fade_out(false)
			errored.emit()
		trains_on_track -= 1	
		
	train.move()


func set_train_on_tracks() -> void:
	var train_speed: float = GameSettings.speed + sum_trains_started / 50.0 # slowly increase speed over time	
	var t: Train = train_scene.instantiate()
	
	$Trains.add_child(t)
	t.speed = train_speed
	var track: int = randi_range(0, GameSettings.num_stations - 1)
	t.position = Vector2(0, tile_set.tile_size.y * track  + tile_set.tile_size.y / 2.0)
	
	if GameSettings.joker_enabled and sum_trains_started > 5 and randi_range(0, 24) == 0:
		t.color = Train.TrainColor.RAINBOW
	else:
		# do not use TrainColor.RAINBOW, which has index 0
		t.color = Train.TrainColor.values()[randi_range(1, GameSettings.num_stations)]
	
	t.fade_in()
	trains_on_track += 1
	sum_trains_started += 1
	t.moved.connect(_on_train_moved)
	t.move()
	
	# set timer for next train
	var wait_time: float =  COL_COUNT/(train_speed*GameSettings.num_concurrent_trains + sum_trains_started/40.0) # "+ sum_trains_started/40	" to make trains appear "faster faster" than the speed increases → overall traffic increases
	$TrainCreationTimer.wait_time = wait_time
	$TrainCreationTimer.start()
