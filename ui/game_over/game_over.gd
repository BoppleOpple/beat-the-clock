extends Control

func _is_ActorBase(node: Node) -> bool:
		return node is ActorBase

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
	var actors: Array[Node] = []
	actors += get_tree().get_nodes_in_group("Players").filter(_is_ActorBase)
	actors += get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)
	
	#print(actors.map(func(actor): return actor.should_free))
	
	if actor == GameManager.get_local_player():
		$UI/Modulate/Title.text = "Game Over"
		$UI/Modulate/Title.modulate = Color.INDIAN_RED
	else:
		for enemies in actors:
			if enemies.should_free == false:
				return
		$UI/Modulate/Title.text = "Victory!"
		$UI/Modulate/Title.modulate = Color.LIME
		
	$UI/Modulate.show()
	$UI/Modulate.modulate.a = 0.0		
			
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($UI/Modulate, "modulate:a", 1.0, 1.0)
	tween.tween_property(Engine, "time_scale", 0.01, 1.0)
	tween.tween_property($UI/Modulate/Title, "modulate", $UI/Modulate/Title.modulate, 0.1)
