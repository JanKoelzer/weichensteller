extends VBoxContainer

const AUDIO_OFF_DB = -80
const AUDIO_ON_DB = 0

func _ready() -> void:
	var audio_setting = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$AudioCheckbox.button_pressed = audio_setting == AUDIO_ON_DB
	$LanguageCheckbox.button_pressed = not TranslationServer.get_locale().begins_with("de") 
	
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


func _on_audio_checkbox_pressed() -> void:
	if ($AudioCheckbox.button_pressed):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)


func _on_language_button_pressed() -> void:
	if $LanguageCheckbox.button_pressed:
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("de")
