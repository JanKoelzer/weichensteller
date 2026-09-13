extends AbstractRails

func _ready() -> void:
	init()
	set_train_on_tracks()

func init() -> void:
	self.col_count = 19
	self.wind_angle = TAU/8.0
	self.wind_speed = 25


func start_tutorial_train_1() -> void:
	_set_train_on_tracks(
		Train.TrainType.ELECTRIC1,
		Train.TrainColor.GREEN,
		0,
		1
	)

func start_tutorial_train_2() -> void:
	_set_train_on_tracks(
		Train.TrainType.STEAM1,
		Train.TrainColor.YELLOW,
		0,
		1
	)

func set_train_on_tracks() -> Train:
	return null
