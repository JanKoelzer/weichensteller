extends AbstractRails

func _ready() -> void:
	init()
	set_train_on_tracks()

func init() -> void:
	self.col_count = 19
	self.wind_angle = TAU/8.0
	self.wind_speed = 25
	for t: Train in $Trains.get_children():
		trains_on_track += 1
		sum_trains_started += 1
		t.wind_angle = self.wind_angle
		t.moved.connect(_on_train_moved)
		t.move()


var current_train_color := 2
func set_train_on_tracks() -> Train:
	current_train_color += 1
	current_train_color %= Train.TrainColor.values().size()

	return _set_train_on_tracks(
		Train.TrainType.values().pick_random(),
		current_train_color,
		[3, 4, 7].pick_random(),
		1.0
	)
