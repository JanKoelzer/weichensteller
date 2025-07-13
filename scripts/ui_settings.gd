extends Node

signal locale_changed(locale: String)
signal sound_enabled_changed(enabled: bool)

const AUDIO_OFF_DB := -80
const AUDIO_ON_DB := 0

@onready var locale: String = OS.get_locale_language():
	get: return locale
	set(v):
		if v != locale:
			locale = v
			TranslationServer.set_locale(v)
			locale_changed.emit(v)
			save_to_file()

@onready var sound_enabled: bool = true:
	get: return sound_enabled
	set(v):
		if v != sound_enabled:
			sound_enabled = v
			sound_enabled_changed.emit(v)
			save_to_file()
			if sound_enabled:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), AUDIO_ON_DB)
			else:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), AUDIO_OFF_DB)

var file := ConfigFile.new()
const config_filename := "user://ui.cfg"

func _ready() -> void:
	# At the first run on a device, there is no config file,
	# so the default values are used (see CONSTs above).
	# The settings are then stored in a config file.
	# After that, this config file is loaded, everytime the
	# game starts. The loaded values are used as settings.
	load_from_file()
	
	TranslationServer.set_locale(locale)

func load_from_file() -> void:
	var err := file.load(config_filename)
	
	if err != OK:
		save_to_file()	
	
	locale = file.get_value("UI", "locale", locale)
	sound_enabled = file.get_value("UI", "sound_enabled", sound_enabled)
	
func save_to_file() -> void:
	file.set_value("UI", "locale", locale)
	file.set_value("UI", "sound_enabled", sound_enabled)
	
	file.save(config_filename)
