extends VBoxContainer

@onready var audio_option_button: OptionButton = %AudioOptionButton
@onready var language_option_button: OptionButton = %LanguageOptionButton
@onready var change_setting_audio_stream_player: AudioStreamPlayer = $ChangeSettingAudioStreamPlayer

func _ready() -> void:
	audio_option_button.selected = 0 if UISettings.sound_enabled else 1
	language_option_button.selected = 1 if UISettings.locale.begins_with("de") else 0


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 0:
		UISettings.locale = "en"
	else:
		UISettings.locale = "de"
	change_setting_audio_stream_player.play()


func _on_audio_option_button_item_selected(index: int) -> void:
	UISettings.sound_enabled = index == 0
	change_setting_audio_stream_player.play()
