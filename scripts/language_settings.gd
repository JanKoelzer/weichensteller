extends Node

@onready var locale: String = OS.get_locale_language():
	get: return locale


func _ready() -> void:
	TranslationServer.set_locale(locale)
