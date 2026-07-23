extends Control

@onready var playbutton: Button = $UI/MenuButtons/Play
@onready var optionsbutton: Button = $UI/MenuButtons/Options
@onready var exitbutton: Button = $UI/MenuButtons/Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
