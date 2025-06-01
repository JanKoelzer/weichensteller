extends Node

signal changed(prop: String, new: Variant)

const MIN_SPEED = 0.75
const MAX_SPEED = 2.0
const DEFAULT_SPEED = 1.0
const MIN_STATIONS = 3
const MAX_STATIONS = 6
#const DEFAULT_STATIONS = 5
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
const MIN_BRAKES = 0
const MAX_BRAKES = 5
const DEFAULT_BRAKES = 3
const DEFAULT_AUTO_BRAKE_ENABLED = true
const DEFAULT_AUTO_BRAKE_THRESHOLD = 2
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
		for k in v.keys():
			if k >= MAX_STATIONS or k < 0:
				return
		selected_stations = v
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

var num_brakes: int = DEFAULT_BRAKES:
	get: return num_brakes
	set(v):
		num_brakes = clampi(v, MIN_BRAKES, MAX_BRAKES)
		changed.emit("num_brakes", v)

# currently not customizable
const auto_brake_threshold: int = DEFAULT_AUTO_BRAKE_THRESHOLD

var auto_brake_enabled: bool = DEFAULT_AUTO_BRAKE_ENABLED:
	get: return auto_brake_enabled
	set(v):
		auto_brake_enabled = v
		changed.emit("auto_brake_enabled", v)

var max_errors: int = DEFAULT_MAX_ERRORS:
	get: return max_errors
	set(v):
		max_errors = clampi(v, MIN_ERRORS, MAX_ERRORS)
		changed.emit("max_errors", v)

# currently always turened off
var joker_enabled: bool = false

func score_factor() -> float:
	var k := 1.0
	k *= speed**1.2
	k *= (float(num_concurrent_trains)/DEFAULT_CONCURRENT_TRAINS)**1.2
	k *= (float(num_stations)/DEFAULT_STATIONS.size())**2
	k *= 1 + 0.08*(DEFAULT_EXTRA_SWITCHES-num_extra_switches)
	k *= 1 + 0.05*(DEFAULT_BRAKES-num_brakes)
	k *= 1 + 0.1*(DEFAULT_MAX_ERRORS-max_errors)
	return k

func is_valid() -> bool:
	return selected_stations.size() >= 3
