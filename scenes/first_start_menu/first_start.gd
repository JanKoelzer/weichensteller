extends VBoxContainer

@onready var privacy_container: ScrollContainer = %PrivacyContainer
@onready var introduction: VBoxContainer = $Introduction
@onready var tutorial_button: Button = %TutorialButton
@onready var close_button: Button = %CloseButton
@onready var audio_settings: HBoxContainer = $UISettingsControls/AudioSettings
@onready var language_settings: HBoxContainer = $UISettingsControls/LanguageSettings

func _on_close_button_pressed() -> void:
	UISettings.privacy_accpeted = true
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_tutorial_button_pressed() -> void:
	UISettings.privacy_accpeted = true
	close_button.visible = true
	tutorial_button.visible = false
	privacy_container.visible = false
	language_settings.visible = false
	introduction.visible = true
	audio_settings.visible = true
	introduction.start_tutorial()
