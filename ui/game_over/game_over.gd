extends Control

var game_over_sent: Dictionary = {}

var round_complete: bool = false

var _slowmo_tween: Tween = null

func _is_ActorBase(node: Node) -> bool:
		return node is ActorBase

func is_showing() -> bool:
	return $UI/Modulate.visible


func _ready() -> void:
	$UI/Modulate.hide()
	$UI/Modulate.modulate.a = 0.0
	if _is_server_or_singleplayer():
		$UI/Modulate/MenuButtons/Restart.disabled = true
		$UI/Modulate/MenuButtons/MainMenu.grab_focus()
	else:
		# Only the host may restart the shared game state.
		$UI/Modulate/MenuButtons/Restart.disabled = true
		$UI/Modulate/MenuButtons/Restart.visible = false
		$UI/Modulate/MenuButtons/MainMenu.grab_focus()

func _process(_delta: float) -> void:
	if not _is_server_or_singleplayer():
		return

	var players: Array = GameManager.get_all_players()

	for p in players:
		if p.should_free:
			var id: int = p.get_multiplayer_authority()
			if not game_over_sent.get(id, false):
				game_over_sent[id] = true
				_send_game_over(id)

	if round_complete or players.is_empty():
		return

	var living_players: Array = players.filter(func(p): return not p.should_free)

	if living_players.is_empty():
		_broadcast_round_complete_safe()
		return

	if living_players.size() != 1:
		return

	var enemies: Array[Node] = get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)
	var living_enemies: Array = enemies.filter(func(e): return not e.should_free)
	if living_enemies.is_empty():
		_send_victory(living_players[0].get_multiplayer_authority())
		_broadcast_round_complete_safe()

func _send_game_over(id: int) -> void:
	if multiplayer.multiplayer_peer == null or id == multiplayer.get_unique_id():
		_show_game_over()
	else:
		_show_game_over.rpc_id(id)

func _send_victory(id: int) -> void:
	if multiplayer.multiplayer_peer == null or id == multiplayer.get_unique_id():
		_show_victory()
	else:
		_show_victory.rpc_id(id)

func _on_restart_pressed() -> void:
	if not _is_server_or_singleplayer():
		return  # clients cannot restart the shared game
	var main = get_tree().current_scene
	if main and main.has_method("_restart_game"):
		main._restart_game()

func _on_main_menu_pressed() -> void:
	_kill_slowmo_tween()
	Engine.time_scale = 1.0
	NetworkManager.disconnect_game()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")

func _is_server_or_singleplayer() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()

func _broadcast_round_complete_safe() -> void:
	if multiplayer.multiplayer_peer != null:
		_broadcast_round_complete.rpc()
	else:
		_broadcast_round_complete()

func _kill_slowmo_tween() -> void:
	if _slowmo_tween != null and _slowmo_tween.is_valid():
		_slowmo_tween.kill()
	_slowmo_tween = null

####################
#    RPC METHODS   #
####################

@rpc("authority", "call_remote", "reliable")
func _show_game_over() -> void:
	$UI/Modulate/Title.text = "Game Over"
	$UI/Modulate/Title.modulate = Color.INDIAN_RED
	_show_overlay()

@rpc("authority", "call_remote", "reliable")
func _show_victory() -> void:
	$UI/Modulate/Title.text = "Victory!"
	$UI/Modulate/Title.modulate = Color.LIME
	_show_overlay()

func _show_overlay() -> void:
	$UI/Modulate.show()
	$UI/Modulate.modulate.a = 0.0

	_kill_slowmo_tween()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($UI/Modulate, "modulate:a", 1.0, 1.0)
	if multiplayer.multiplayer_peer == null:
		tween.set_ignore_time_scale(true)
		tween.tween_property(Engine, "time_scale", 0.01, 1.0)
		_slowmo_tween = tween
	tween.tween_property($UI/Modulate/Title, "modulate", $UI/Modulate/Title.modulate, 0.1)

@rpc("authority", "call_local", "reliable")
func _broadcast_round_complete() -> void:
	round_complete = true
	if _is_server_or_singleplayer():
		$UI/Modulate/MenuButtons/Restart.disabled = false
		if $UI/Modulate.visible:
			$UI/Modulate/MenuButtons/Restart.grab_focus()

@rpc("authority", "call_local", "reliable")
func _reset() -> void:
	game_over_sent.clear()
	round_complete = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	$UI/Modulate.hide()
	$UI/Modulate.modulate.a = 0.0
	if _is_server_or_singleplayer():
		$UI/Modulate/MenuButtons/Restart.disabled = true
