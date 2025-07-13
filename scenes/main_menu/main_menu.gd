extends VBoxContainer


@onready var audio_option_button := $AudioSettings/AudioOptionButton
@onready var language_option_button := %LanguageOptionButton


func _ready() -> void:
	audio_option_button.selected = 0 if UISettings.sound_enabled else 1
	language_option_button.selected = 1 if UISettings.locale.begins_with("de") else 0


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_menu/difficulty_menu.tscn")


func _on_highscore_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/highscore_menu/highscore_menu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits_menu/credits_menu.tscn")


func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/help_menu/help_menu.tscn")


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 0:
		UISettings.locale = "en"
	else:
		UISettings.locale = "de"


func _on_audio_option_button_item_selected(index: int) -> void:
	UISettings.sound_enabled = index == 0
