extends VBoxContainer

const AUDIO_OFF_DB := -80
const AUDIO_ON_DB := 0

@onready var audio_option_button := $AudioSettings/AudioOptionButton
@onready var language_option_button := %LanguageOptionButton


func _ready() -> void:
	var audio_setting := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	audio_option_button.selected = 0 if audio_setting == AUDIO_ON_DB else 1
	language_option_button.selected = 1 if TranslationServer.get_locale().begins_with("de") else 0

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://difficulty_settings.tscn")


func _on_highscore_button_pressed() -> void:
	get_tree().change_scene_to_file("res://highscore_menu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://credits_menu.tscn")


func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file("res://help_menu.tscn")


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 0:
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("de")


func _on_audio_option_button_item_selected(index: int) -> void:
	if index == 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), AUDIO_ON_DB)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), AUDIO_OFF_DB)
