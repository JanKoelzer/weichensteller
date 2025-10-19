extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	%CopyrightLabel.text = FileAccess.get_file_as_string("res://LICENSE")
	%ThirdPartyLabel.text ="\n".join([
				"Lizenzen verwendeter Software und Assets:",
				Engine.get_license_text(),
				FileAccess.get_file_as_string("res://legal/THIRD_PARTY.txt")
	])
	%DisclaimerLabel.text = FileAccess.get_file_as_string("res://legal/disclaimer.txt")
	%CoffeeLabel.text = tr(&"BUY_ME_A_COFFE") + " " + %CoffeeLabel.text
	
func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_coffee_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
