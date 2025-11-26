extends Node

signal changed(prop: String, new: Variant)

var file := ConfigFile.new()
const config_filename := "user://difficulty.cfg"
const config_section := "Difficulty"

const MIN_SPEED = 0.75
const MAX_SPEED = 2.0
const DEFAULT_SPEED = 1.0
const MIN_STATIONS = 3
const MAX_STATIONS = 6
const DEFAULT_STATIONS : Dictionary[int, bool] = {
	Train.TrainColor.RED: true,
	Train.TrainColor.ORANGE: true,
	Train.TrainColor.YELLOW: true,
	Train.TrainColor.GREEN: true,
	Train.TrainColor.BLUE: true,
} # Only use TRUE and ERASE unused
const MIN_CONCURRENT_TRAINS = 2
const MAX_CONCURRENT_TRAINS = 5
const DEFAULT_CONCURRENT_TRAINS = 3
const MIN_EXTRA_SWITCHES = 0
const MAX_EXTRA_SWITCHES = 10
const DEFAULT_EXTRA_SWITCHES = 5
const MIN_ERRORS = 0
const MAX_ERRORS = 10
const DEFAULT_MAX_ERRORS = 5

var speed: float = DEFAULT_SPEED:
	get: return speed
	set(v):
		speed = clampf(v, MIN_SPEED, MAX_SPEED)
		changed.emit("speed", v)

var selected_stations: Dictionary[int, bool] = DEFAULT_STATIONS:
	get: return selected_stations
	set(v):
		for k: int in v.keys():
			if k >= MAX_STATIONS or k < 0:
				return
		selected_stations = v.duplicate()
		# always emit the signal to update/not update views
		changed.emit("selected_stations", v)

var num_stations: int:
	get: return selected_stations.size()

var num_concurrent_trains: int = DEFAULT_CONCURRENT_TRAINS:
	get: return num_concurrent_trains
	set(v):
		num_concurrent_trains = clampi(v, MIN_CONCURRENT_TRAINS, MAX_CONCURRENT_TRAINS)
		changed.emit("num_concurrent_trains", v)

var num_extra_switches: int = DEFAULT_EXTRA_SWITCHES:
	get: return num_extra_switches
	set(v):
		num_extra_switches = clampi(v, MIN_EXTRA_SWITCHES, MAX_EXTRA_SWITCHES)
		changed.emit("num_extra_switches", v)

var max_errors: int = DEFAULT_MAX_ERRORS:
	get: return max_errors
	set(v):
		max_errors = clampi(v, MIN_ERRORS, MAX_ERRORS)
		changed.emit("max_errors", v)

# currently always turened off
var joker_enabled: bool = false

func _ready() -> void:
	# At the first run on a device, there is no config file,
	# so the default values are used (see CONSTs above).
	# The settings are then stored in a config file.
	# After that, this config file is loaded, everytime the
	# game starts. The loaded values are used as settings.
	
	# load before connecting to signal, so changes do not result in infinite loops
	load_from_file()
	changed.connect(func(_prop: String, _v: Variant) -> void:
		save_to_file()
	)

func score_factor() -> float:
	var k := 1.0
	k *= speed**1.2
	k *= (float(num_concurrent_trains)/DEFAULT_CONCURRENT_TRAINS)**1.2
	k *= (float(num_stations)/DEFAULT_STATIONS.size())**2
	k *= 1 + 0.08*(DEFAULT_EXTRA_SWITCHES-num_extra_switches)
	k *= 1 + 0.1*(DEFAULT_MAX_ERRORS-max_errors)
	k = snappedf(k, 0.01)
	return k

func is_valid() -> bool:
	return selected_stations.size() >= 3


func load_from_file() -> void:
	var err := file.load(config_filename)
	
	if err != OK:
		save_to_file()	
	
	speed = file.get_value(config_section, "speed", speed)
	selected_stations = {}
	var stations_as_string := \
			file.get_value(config_section, "selected_stations",\
			",".join(selected_stations.keys())
	) as String
	for station: int in Array(stations_as_string.split(",", false)).map(func(s: String) -> int: return int(s)):
		selected_stations[station] = true
	
	num_concurrent_trains = file.get_value(config_section, "num_concurrent_trains", num_concurrent_trains)	
	num_extra_switches = file.get_value(config_section, "num_extra_switches", num_extra_switches)	
	max_errors = file.get_value(config_section, "max_errors", max_errors)	
	


func save_to_file() -> void:
	file.set_value(config_section, "speed", speed)
	file.set_value(config_section, "selected_stations", ",".join(selected_stations.keys()))
	file.set_value(config_section, "num_concurrent_trains", num_concurrent_trains)
	file.set_value(config_section, "num_extra_switches", num_extra_switches)
	file.set_value(config_section, "max_errors", max_errors)
	
	file.save(config_filename)
