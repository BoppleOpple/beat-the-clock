extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/Modulate.hide()
	$UI/Modulate.modulate.a = 0.0
	$UI/Modulate/MenuButtons/Restart.grab_focus()

func _on_restart_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")

func _on_player_death(actor: ActorBase) -> void:
	$UI/Modulate.show()
	$UI/Modulate.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($UI/Modulate, "modulate:a", 1.0, 1.0)
	tween.tween_property(Engine, "time_scale", 0.01, 1.0)
	if actor is Player:
		$UI/Modulate/Title.text = "Game Over"
		$UI/Modulate/Title.add_theme_color_override("font_color", Color.INDIAN_RED)
	else:
		$UI/Modulate/Title.text = "Victory!"
		$UI/Modulate/Title.add_theme_color_override("font_color", Color.LIME_GREEN)
