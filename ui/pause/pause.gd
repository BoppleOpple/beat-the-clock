extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Popup.visible = false
	$Popup/Options.hide()
	self.process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		$Popup.visible = not $Popup.visible
		get_tree().paused = $Popup.visible
		if $Popup/Options.visible:
			$Popup/Options._on_back_pressed()
			$Popup/Options.hide()
		


func _on_back_pressed() -> void:
	$Popup.visible = false
	get_tree().paused = false


func _on_options_pressed() -> void:
	$Popup/Options.show()


func _on_reset_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	$Popup.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")
