extends Node

var locale = null:
	get: return locale


func _ready() -> void:
	locale = OS.get_locale_language()
	TranslationServer.set_locale(locale)
