extends Node

signal locale_changed(locale: String)
signal sound_enabled_changed(enabled: bool)
signal privacy_accepted_changed()


var locale: String = OS.get_locale_language():
	get: return locale
	set(v):
		if v != locale:
			locale = v
			TranslationServer.set_locale(v)
			locale_changed.emit(v)


var sound_enabled: bool = true:
	get: return sound_enabled
	set(v):
		if v != sound_enabled:
			sound_enabled = v
			sound_enabled_changed.emit(v)
			var master_bus := AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(master_bus, !sound_enabled)


var privacy_accpeted: bool = false:
	get: return privacy_accpeted
	set(v):
		if v == true:
			privacy_accpeted = true
			privacy_accepted_changed.emit()


var file := ConfigFile.new()
const config_filename := "user://ui.cfg"
const config_section := "UI"
const privacy_section := "Privacy"


func _ready() -> void:
	# At the first run on a device, there is no config file,
	# so the default values are used .
	# The settings are then stored in a config file.
	# After that, this config file is loaded, everytime the
	# game starts. The loaded values are used as settings.
	
	# load before connecting to signal, so changes do not result in infinite loops
	load_from_file()
	
	locale_changed.connect(func(_l: String) -> void: save_to_file())
	sound_enabled_changed.connect(func(_b: bool) -> void: save_to_file())
	privacy_accepted_changed.connect(save_to_file)


func load_from_file() -> void:
	# At the first run on a device, there is no config file,
	# so the default values are used (see CONSTs above).
	# The settings are then stored in a config file.
	# After that, this config file is loaded, everytime the
	# game starts. The loaded values are used as settings.
	var err := file.load(config_filename)
	
	if err != OK:
		save_to_file()
	
	locale = file.get_value(config_section, "locale", locale)
	sound_enabled = file.get_value(config_section, "sound_enabled", sound_enabled)
	privacy_accpeted = file.get_value(privacy_section, "accepted", privacy_accpeted)


func save_to_file() -> void:
	file.set_value(config_section, "locale", locale)
	file.set_value(config_section, "sound_enabled", sound_enabled)
	
	file.set_value(privacy_section, "accepted", privacy_accpeted)
	
	file.save(config_filename)
