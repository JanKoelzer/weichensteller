extends AbstractRails

func init(num_cols: int, settings: GameSettings) -> void:
	assert(num_cols > 2)
	assert(settings.is_valid())
	
	self.game_settings = settings
	self.col_count = num_cols
	self.wind_angle = randf_range(-PI/8, PI/8) + TAU/4.0 # Note: 0° is upwards
	self.wind_speed = 25 + randf()*25
	
	# create an array that maps each row to a (selected) color
	row_count = game_settings.selected_stations.size()
	var color_keys := game_settings.selected_stations.keys()
	color_keys.sort()
	for i in row_count:
		colors.set(i, color_keys[i])
	create_railways()


func set_train_on_tracks() -> Train:
	var new_speed := game_settings.speed + sum_trains_started / 50.0 # slowly increase speed over time	
	var t := _set_train_on_tracks(
		game_settings.selected_stations.keys().pick_random(), # color
		randi_range(0, game_settings.num_stations - 1), # track
		new_speed
	)
	
	t.fade_in()

	# set timer for next train
	# "+ sum_trains_started/40" to make trains appear "faster faster" than
	# the speed increases → overall traffic increases
	var wait_time :=  col_count/(new_speed*game_settings.num_concurrent_trains + sum_trains_started/40.0)
	train_creation_timer.wait_time = wait_time
	train_creation_timer.start()

	return t
