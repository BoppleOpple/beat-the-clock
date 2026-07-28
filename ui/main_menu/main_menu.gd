extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/MenuButtons/Play.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_multiplayer_pressed() -> void:
	$UI/Multiplayer.show()
	$UI/Multiplayer/MarginContainer/Rows/UpperColumns/RightColumn/IPBox/IPText.grab_focus()

func _on_options_pressed() -> void:
	$UI/Options.show()
	$"UI/Options/Margin/HSplitContainer/Left Column/Display".grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_focus_reset() -> void:
	$UI/MenuButtons/Play.grab_focus()
